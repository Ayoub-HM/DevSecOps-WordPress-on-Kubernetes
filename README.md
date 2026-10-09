# WordPress sur Kubernetes : haute disponibilité et DevSecOps

TP DevSecOps, M2 Cybersécurité & IA (EFREI).
WordPress et MariaDB déployés avec Helm sur deux clusters minikube (une VM Hyper-V chacun), en **actif/passif avec bascule automatique**, et sécurisés par une démarche DevSecOps : secrets sortis du code, scans de sécurité, pipeline GitHub Actions.

---

## 1. Architecture

```text
                    http://172.17.169.100  (adresse commune, keepalived)
                               │
          ┌────────────────────┴────────────────────┐
          ▼                                         ▼
  VM 2 · 172.17.169.30 (active)            VM 1 · 172.17.169.20 (copie)
  ┌───────────────────────────┐            ┌───────────────────────────┐
  │ minikube                  │            │ minikube                  │
  │  WordPress ── MariaDB     │  binlog    │  WordPress ── MariaDB     │
  │  (chart 34.1.3) (28.1.1)  │ ─────────► │               read_only   │
  │  PVC 1Gi       PVC 500Mi  │  uploads   │  PVC 1Gi       PVC 2Gi    │
  │                           │ ─────────► │                           │
  └───────────────────────────┘ cron+SSH   └───────────────────────────┘
```

| Élément | Rôle |
|---|---|
| `wordpress-release` | Chart `bitnami/wordpress` 34.1.3, données dans un PVC de 1Gi |
| `mariadb-release` | Chart `bitnami/mariadb` 28.1.1 en mode standalone, binlog activé |
| Réplication | Asynchrone par binlog, la copie suit l'active via le service `relais-mariadb` (port-forward 3306) |
| Images (`uploads`) | Copiées chaque minute de l'active vers la copie (tar + SSH) |
| Gardien | Service `ha-watchdog` : promeut la copie si l'active est muette 5 minutes |
| Adresse commune | `172.17.169.100`, portée par keepalived sur la VM active |

**Écarts assumés par rapport à l'énoncé** : MariaDB simple avec réplication entre deux clusters au lieu de Galera dans un seul cluster ; stockage S3 (MinIO) abandonné au profit d'une copie par cron ; Liqo, k8gb et Azure hors périmètre (seuls leurs secrets, présents dans l'historique, sont traités). Détails dans [docs/architecture.md](docs/architecture.md).

---

## 2. Contenu du dépôt

```text
db_values.yaml            Réglages MariaDB communs aux deux VM
wp_values.yaml            Réglages WordPress communs
values/db-vm1.yaml        MariaDB VM 1 : server-id 1, read-only, disque 2Gi
values/db-vm2.yaml        MariaDB VM 2 : server-id 2, disque 500Mi, ressources, sondes
values/wp-vm2.yaml        WordPress VM 2 : ressources réduites
k8s/secrets.example.yaml  Modèle des Secrets Kubernetes (aucune vraie valeur)
ops/                      Exploitation HA : scripts d'installation, systemd, procédure de bascule
docs/                     Architecture, inventaire des secrets, plan de révocation, top 5, journal
reports/                  Rapports de scans (valeurs toujours caviardées)
.github/workflows/        Pipeline DevSecOps
.gitleaksignore           Empreintes des anciens secrets connus (aucune valeur)
.pre-commit-config.yaml   Hook gitleaks avant chaque commit
```

> **Règle d'or** : ne jamais appliquer le fichier `values/` d'une VM sur l'autre. Deux `server-id` identiques cassent la réplication, et une taille de disque différente fait refuser la mise à niveau.

---

## 3. Déploiement (sur chaque VM)

### Prérequis

Docker, minikube, kubectl, Helm, `jq`, `nc`, une clé SSH entre les deux VM (`ssh-copy-id ayoub@<autre VM>`).

```bash
minikube start --driver=docker
```

### Étape 1 : créer les Secrets (avant Helm)

Les fichiers values ne contiennent **aucun mot de passe**, seulement le nom des Secrets (`existingSecret`). Il faut donc les créer d'abord. Les valeurs sont saisies sans s'afficher et ne passent jamais par Git :

```bash
read -rsp "Mot de passe root MariaDB : " ROOT_PW; echo
read -rsp "Mot de passe utilisateur WordPress en base : " DB_PW; echo
read -rsp "Mot de passe admin WordPress : " WP_PW; echo
kubectl create secret generic mariadb-credentials \
  --from-literal=mariadb-root-password="$ROOT_PW" --from-literal=mariadb-password="$DB_PW"
kubectl create secret generic wordpress-credentials \
  --from-literal=wordpress-password="$WP_PW" --from-literal=mariadb-password="$DB_PW"
unset ROOT_PW DB_PW WP_PW
```

Le format attendu est décrit dans [k8s/secrets.example.yaml](k8s/secrets.example.yaml).

### Étape 2 : MariaDB

```bash
# VM 1 (copie)
helm upgrade --install mariadb-release oci://registry-1.docker.io/bitnamicharts/mariadb --version 28.1.1 \
  -f db_values.yaml -f values/db-vm1.yaml

# VM 2 (active)
helm upgrade --install mariadb-release oci://registry-1.docker.io/bitnamicharts/mariadb --version 28.1.1 \
  -f db_values.yaml -f values/db-vm2.yaml
```

### Étape 3 : WordPress

```bash
# VM 1
helm upgrade --install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress --version 34.1.3 \
  -f wp_values.yaml

# VM 2
helm upgrade --install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress --version 34.1.3 \
  -f wp_values.yaml -f values/wp-vm2.yaml
```

### Méthode pour toute modification du cluster

1. Sauvegarde : `helm get values <release> -o yaml > ~/backups/...` (jamais affiché à l'écran).
2. Essai à blanc : `helm upgrade ... --dry-run=server` (le mode `server` est nécessaire pour lire les Secrets).
3. Application, puis vérification : pods `Running 1/1`, site en `200`, réplication `Yes / Yes`.

---

## 4. Haute disponibilité

### Mise en place de la réplication (une fois)

Sur l'active : un compte de réplication.

```sql
CREATE USER 'repl'@'%' IDENTIFIED BY '<REPL_PASSWORD>';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
```

Sur la copie : importer un dump de l'active (`mariadb-dump --single-transaction --master-data=2 --databases wordpress`), puis :

```sql
CHANGE MASTER TO MASTER_HOST='<IP de l''active>', MASTER_PORT=3306,
  MASTER_USER='repl', MASTER_PASSWORD='<REPL_PASSWORD>',
  MASTER_LOG_FILE='<fichier du dump>', MASTER_LOG_POS=<position du dump>;
START SLAVE;
```

Contrôle : `SHOW SLAVE STATUS\G` doit afficher `Slave_IO_Running: Yes` et `Slave_SQL_Running: Yes`.

### Bascule automatique

Installation identique sur les deux VM (VM 1 puis VM 2), le script reconnaît la VM par son adresse :

```bash
bash ops/ha-install.sh      # gardien, promotion, rétrogradation, relais, cron des images
```

Puis, sur chaque VM, enregistrer le mot de passe `repl` dans `~/ha/ha.conf` (fichier local, droits 600, hors Git).

| Fichier dans `~/ha/` | Rôle |
|---|---|
| `ROLE` | `active` ou `standby` : pilote tout le reste |
| `watchdog.sh` | Sur la copie : teste l'autre VM toutes les 30 s (ping et port 3306). Muette 5 min → `promote.sh` |
| `promote.sh` | Arrête et oublie la réplication, passe la base en écriture, rend le réglage permanent (`helm upgrade`) |
| `demote.sh` | **À lancer à la main** sur une VM qui revient : recopie la base depuis l'active, relance la réplication, repasse en lecture seule |
| `sync-uploads.sh` | Copie les images depuis l'active ; refuse de copier si les deux VM se disent actives |
| `failover.log` | Journal de toutes les bascules |

Cycle complet :

```text
VM 2 active, VM 1 surveille
   │  VM 2 muette 5 min
   ▼
VM 1 promue automatiquement
   │  VM 2 revient → ~/ha/demote.sh sur la VM 2 (taper OUI)
   ▼
VM 1 active, VM 2 surveille … et inversement
```

Le retour d'une VM reste **volontairement manuel** : un humain vérifie qu'elle est saine avant qu'elle recopie la base, ce qui évite les bascules en boucle.

### Adresse unique du site

```bash
bash ops/vip-install.sh     # keepalived + publication du site sur le port 80
```

keepalived donne l'adresse `172.17.169.100` à la VM dont le `ROLE` est `active` (option `nopreempt` : l'adresse ne revient pas toute seule sur une VM qui redémarre). Le site est toujours sur **http://172.17.169.100**.

### Commandes utiles

```bash
cat ~/ha/ROLE                                   # rôle de la VM
journalctl -u ha-watchdog -f                    # suivre le gardien
tail ~/ha/failover.log                          # historique des bascules
ip -4 addr show | grep 172.17.169.100           # l'adresse commune est-elle ici ?
DRYRUN=1 ~/ha/promote.sh                        # test de promotion sans effet
```

### Limites

- Réplication asynchrone : une panne peut perdre les toutes dernières secondes d'écriture.
- Le gardien ne bascule que si l'autre VM est **totalement** muette ; un MariaDB en panne sur une VM allumée ne déclenche rien (choix prudent contre le split-brain).
- Sans troisième machine arbitre, une coupure réseau seule entre les VM pourrait rendre les deux actives : la copie des images le détecte et s'arrête, mais les bases divergent.

---

## 5. DevSecOps

### Secrets

1. **Détection** : `gitleaks` sur tout l'historique a trouvé 20 secrets (12 clés privées, 8 clés d'API) dans le commit `897f51d` de l'ancienne promo. Inventaire caviardé : [docs/secrets-inventaire.md](docs/secrets-inventaire.md).
2. **Sortie du code** : mots de passe déplacés des fichiers values vers des Secrets Kubernetes (`existingSecret`).
3. **Révocation** : un secret commité reste dans l'historique et dans toutes les copies du dépôt, il doit être révoqué par son propriétaire. Voir [docs/plan-revocation.md](docs/plan-revocation.md).
4. **Prévention** : hook pre-commit gitleaks en local, et job gitleaks bloquant dans la pipeline. `.gitleaksignore` contient seulement les empreintes des 20 anciens secrets, pour ne bloquer que les nouveaux.

Activer le hook après un clone :

```bash
pipx install pre-commit && pre-commit install
```

### Pipeline GitHub Actions

`.github/workflows/devsecops.yml`, à chaque push et pull request, dans cet ordre (une étape en échec arrête les suivantes) :

| Étape | Outil | Bloquant |
|---|---|---|
| 1. Secrets | gitleaks, tout l'historique | Oui |
| 2. Code | Checkov (IaC) et Semgrep (SAST), en parallèle | Oui |
| 3. Manifestes réels | `helm template`, puis Checkov et Trivy | Non, rapport téléchargeable |
| 4. Image | Trivy : configuration (CRITICAL) et image WordPress | Config oui, image en rapport |

Toutes les actions sont **figées par empreinte SHA** : Semgrep avait signalé les étiquettes `@v4` modifiables (risque de chaîne d'approvisionnement, comme les compromissions de `trivy-action`).

### Rapports

| Fichier | Contenu |
|---|---|
| `reports/gitleaks-initial.json` | Scan initial des secrets (caviardé) |
| `reports/trivy-*.json` | Failles de l'image WordPress |
| `reports/checkov.json`, `reports/semgrep.json` | Analyse IaC et SAST |
| `reports/precommit-blocage.txt` | Preuve du blocage d'un faux secret par le hook |
| `docs/top5.md` | Les 5 problèmes les plus graves et leurs corrections |

---

## 6. Incidents rencontrés

| Symptôme | Cause | Correction |
|---|---|---|
| Réplication arrêtée (erreur 1062) | WordPress écrivait sur la copie (wp-cron) | `read_only` permanent sur la copie, resynchronisation |
| MariaDB redémarre en boucle | Sonde liveness de 1 s dépassée sous charge | Délai de 10 s, seuil de 6 échecs (`values/db-vm2.yaml`) |
| Commandes lancées sur la mauvaise VM | Même nom d'hôte sur les deux VM | Garde-fou `hostname -I` en tête de chaque commande |
| `trivy-action@0.28.0` introuvable | Version retirée côté GitHub | Image Docker officielle `aquasec/trivy:0.75.0` |

---

## 7. Reste à faire

- Scan OWASP ZAP baseline sur le site et ticket `docs/tickets/ZAP-001.md`.
- Révoquer les anciens secrets et changer les mots de passe de labo.
- Figer les images par version ou digest au lieu de `:latest`.
- Coffre de secrets (Sealed Secrets, External Secrets ou Vault) : un Secret Kubernetes n'est qu'encodé en base64.
- Dependabot pour les mises à jour des actions GitHub.

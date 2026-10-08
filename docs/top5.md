# Top 5 des constats de scan

Les scans portent sur le dépôt courant. Aucun correctif n’est appliqué dans cette phase. Checkov ne fournit pas de champ de gravité dans son JSON ; les niveaux ci-dessous sont donc des estimations explicites. Les alertes `CKV_SECRET_6` pointent vers les noms de références `existingSecret`, pas vers des valeurs de mot de passe.

| Outil | Gravité | Constat et explication | Risque | Correction proposée | Impact cluster |
| --- | --- | --- | --- | --- | --- |
| Checkov `CKV_K8S_21` | Faible, estimée (gravité absente du rapport) | `k8s/secrets.example.yaml` nomme le namespace `default` pour `mariadb-credentials`. | Le namespace partagé offre moins d’isolation qu’un namespace dédié. | Rendre le namespace configurable dans le modèle et documenter son choix lors du déploiement. | Non : changement statique du modèle seulement. |
| Checkov `CKV_K8S_21` | Faible, estimée (gravité absente du rapport) | `k8s/secrets.example.yaml` nomme le namespace `default` pour `wordpress-credentials`. | Même risque d’isolation réduite pour le Secret WordPress. | Rendre le namespace configurable dans le modèle et documenter son choix lors du déploiement. | Non : changement statique du modèle seulement. |
| Checkov `CKV_SECRET_6` | Faux positif probable ; gravité non fournie | `db_values.yaml` contient le nom de référence `auth.existingSecret`, que Checkov classe comme chaîne à forte entropie. | Risque de masquer une vraie alerte si les faux positifs ne sont pas distingués des valeurs secrètes. Le fichier référence un Secret Kubernetes et ne contient pas le mot de passe. | Vérifier la règle puis ajouter une exclusion ciblée et justifiée pour cette clé, sans exclure les scans de secrets en général. | Non : réglage statique du scanner. |
| Checkov `CKV_SECRET_6` | Faux positif probable ; gravité non fournie | `wp_values.yaml` contient les noms de référence `existingSecret` et `externalDatabase.existingSecret`, signalés par la même règle. | Même risque de bruit et de masquage d’une vraie alerte ; ces chaînes sont des noms de Secret, pas leurs valeurs. | Vérifier la règle puis ajouter une exclusion ciblée et justifiée pour ces chemins uniquement. | Non : réglage statique du scanner. |
| Checkov, parsing `terraform_plan` | Information | Le scan signale une erreur de parsing dans le framework `terraform_plan`; aucun fichier ni chemin précis n’est fourni dans le rapport. | Une erreur de parsing peut rendre la couverture du scan incomplète. | Configurer Checkov pour les frameworks présents dans le dépôt (Kubernetes/Helm) et consigner explicitement l’absence de Terraform. | Non : configuration du scanner uniquement. |

## Résultat des autres scans

- Trivy : 0 vulnérabilité HIGH et 0 CRITICAL sur l’image réellement utilisée (`registry-1.docker.io/bitnami/wordpress:latest`) et sur `bitnami/wordpress`.
- Semgrep avec `p/default` : 0 résultat et 0 erreur.
- Les rapports générés ont été vérifiés avec Gitleaks : aucun secret détecté.
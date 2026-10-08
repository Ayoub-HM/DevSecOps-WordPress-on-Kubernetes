# WordPress local sur Kubernetes

Ce projet déploie WordPress et MariaDB sur un cluster Minikube.

## Composants

- WordPress avec le chart Bitnami
- MariaDB avec le chart Bitnami
- Kubernetes via Minikube

## Prérequis

- Docker
- Minikube
- kubectl
- Helm

## Déploiement

Démarrer Minikube sur chaque VM :

```bash
minikube start --driver=docker
```

Déployer MariaDB avec le fichier propre à la VM.

VM 1 (copie) :

```bash
helm upgrade --install mariadb-release oci://registry-1.docker.io/bitnamicharts/mariadb --version 28.1.1 \
  -f db_values.yaml -f values/db-vm1.yaml
```

VM 2 (active) :

```bash
helm upgrade --install mariadb-release oci://registry-1.docker.io/bitnamicharts/mariadb --version 28.1.1 \
  -f db_values.yaml -f values/db-vm2.yaml
```

Déployer WordPress.

VM 1 :

```bash
helm upgrade --install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress --version 34.1.3 \
  -f wp_values.yaml
```

VM 2 :

```bash
helm upgrade --install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress --version 34.1.3 \
  -f wp_values.yaml -f values/wp-vm2.yaml
```

Ne jamais utiliser le fichier de valeurs d’une VM sur l’autre. Des `server-id` identiques cassent la réplication ; une taille de disque différente peut faire refuser une mise à niveau.

Pour accéder au site :

```bash
minikube service wordpress-release --url
```

## Haute disponibilité

Voir [ops/README.md](ops/README.md) pour les consignes d’exploitation et de bascule.

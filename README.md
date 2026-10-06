# WordPress local en Kubernetes

Ce projet fournit une installation locale de WordPress avec MariaDB et MinIO S3-compatible sur Minikube.

## Composants

- WordPress avec le chart Bitnami
- MariaDB standalone
- MinIO pour le stockage d'objets S3
- Kubernetes et Docker via Minikube

## Prérequis

- Docker
- Minikube
- kubectl
- Helm
- Go

## Démarrage

```bash
minikube start --driver=docker
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install mariadb-release oci://registry-1.docker.io/bitnamicharts/mariadb \
  --values db_values.yaml

./build-minio.sh
minikube image load local/minio:latest
kubectl apply -f minio.yaml

helm upgrade --install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress \
  --values wp_values.yaml
```

## MinIO

La source MinIO est fournie dans le dossier `minio`. L'image locale est construite à partir du code source afin d'éviter les images publiques qui ne sont plus maintenues.

- API S3 : `http://localhost:9000`
- Console : `http://localhost:9001`
- utilisateur : `minioadmin`
- mot de passe : `minioadmin`

## Nettoyage

```bash
helm uninstall wordpress-release
helm uninstall mariadb-release
kubectl delete -f minio.yaml
```

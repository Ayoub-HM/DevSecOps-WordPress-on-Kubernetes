# Introduction

Les intervenants Tony, Khellaf, Sami, Wissam, Lucas, Aymane et Soufiane, travaillent sur un projet visant à mettre en place une infrastructure redondante pour héberger un produit en utilisant des clusters et des mécanismes de réplication tels que MariaDB Galera.\
\
Le projet se divise en deux parties : la première consiste en l'installation standard d'un Wordpress avec une base de données en cluster Galera et des fichiers multimédias stockés sur S3, le tout dans un cluster Kubernetes. Ils privilégient l'utilisation d'Helm Charts et doivent fournir une documentation détaillée. La seconde partie est consacrée à la recherche et l'étude de trois technologies alternatives pour lier les deux clusters et les faire se comporter comme un seul depuis l'extérieur. Pour cela, ils envisagent d'utiliser Admiralty, Liqo et K8GB. Leur objectif global est de fournir une infrastructure stable et performante pour héberger un produit, en utilisant les meilleures technologies disponibles.

## Présentation du projet et de ses objectifs

Le projet vise à mettre en place une infrastructure redondante pour héberger un produit en utilisant des clusters et des mécanismes de réplication tels que MariaDB Galera. Il se divise en deux parties distinctes : la première consiste en l'installation standard d'un Wordpress avec une base de données en cluster Galera et des fichiers multimédias stockés sur S3, le tout dans un cluster Kubernetes, tandis que la seconde partie est consacrée à la recherche et l'étude de trois technologies alternatives pour lier les deux clusters et les faire se comporter comme un seul depuis l'extérieur. L'objectif global est de fournir une infrastructure stable et performante pour héberger un produit, en utilisant les meilleures technologies disponibles.&#x20;

### Pour réaliser ce projet, les prérequis suivants sont nécessaires :&#x20;

- Un poste de travail sous Linux, Windows ou Mac OS X.
- Un environnement de développement pour Kubernetes tel que Minikube et Docker.
- Accès aux services d'AWS et Microsoft Azure pour la mise en production.

# Partie 1 - Utiliser les Charts de Bitnami en utilisant Minikube

Minikube est le moyen officiel d'exécuter Kubernetes localement. Il s'agit d'un outil qui exécute un cluster Kubernetes à un seul nœud à l'intérieur d'une machine virtuelle (VM) sur votre ordinateur. C'est un moyen facile d'essayer Kubernetes et il est également utile pour les scénarios de test et de développement.

Ici, on va faire la configuration requise pour deployer l'application Wordpress de Bitnami ([Helm Charts to deploy WordPress in Kubernetes](https://bitnami.com/stack/wordpress/helm "Helm Charts to deploy WordPress in Kubernetes")) sur Kubernetes à l'aide de Minikube.

### Étape 1 : Configuration de la plate-forme

La première étape pour travailler avec des clusters Kubernetes est d'avoir installé Minikube si vous avez choisi de travailler en local.

Installez Minikube sur votre système local, soit en utilisant un logiciel de virtualisation tel que VirtualBox, soit en utilisant un terminal local.

- Consultez la page des dernières versions de Minikube ([Releases · kubernetes/minikube](https://github.com/kubernetes/minikube/releases "Releases · kubernetes/minikube")).
- Sélectionnez la distribution que vous souhaitez télécharger en fonction de votre système d'exploitation.
- Ouvrez une nouvelle fenêtre de console sur le système local ou ouvrez votre VirtualBox.
- Pour obtenir la dernière version de Minikube, exécutez la commande suivante en fonction de votre système d'exploitation. Remplacez l'espace réservé OS\_DISTRIBUTION par la distribution logicielle correspondant à votre plate-forme, à savoir "darwin" pour OS X, "linux" pour Linux et "windows" pour Windows.
  - ```
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-OS_DISTRIBUTION-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
    ```

### Étape 2 : Créer un cluster Kubernetes

En démarrant Minikube, un cluster à nœud unique est créé. Exécutez la commande suivante dans votre terminal pour terminer la création du cluster :

```
minikube start
```

Pour exécuter vos commandes sur les clusters Kubernetes, vous avez besoin du CLI kubectl. Vérifiez l'étape 3 pour terminer l'installation de kubectl.

### Étape 3 : Installer l'outil de ligne de commande Kubectl

Pour commencer à travailler sur un cluster Kubernetes, il est nécessaire d'installer la ligne de commande Kubernetes (kubectl). Suivez ces étapes pour installer la CLI kubectl :

Exécutez les commandes suivantes pour installer le CLI kubectl. OS\_DISTRIBUTION est un espace réservé pour la distribution binaire de kubectl, n'oubliez pas de le remplacer par la distribution correspondant à votre système d'exploitation (OS).

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/OS_DISTRIBUTION/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Étape 4 : Installation et configuration de Helm

La manière la plus simple d'exécuter et de gérer des applications dans un cluster Kubernetes est d'utiliser Helm. Helm vous permet d'effectuer des opérations clés pour la gestion des applications, telles que l'installation, la mise à niveau ou la suppression

Pour installer Helm v3.x, exécutez les commandes suivantes :

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

Ajoutez le dépôt Bitnami à Helm avec la commande suivante :

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### Étape 5 : Installer la Solution à l'aide d'un Chart de Helm

Un Chart Helm décrit une version spécifique d'une application, également connue sous le nom de "release".

La "release" comprend des fichiers avec les ressources nécessaires à Kubernetes et des fichiers qui décrivent l'installation, la configuration, l'utilisation.

En exécutant la commande helm install, l'application sera déployée sur le cluster Kubernetes.  Vous pouvez installer plus d'un Charts sur le ou les clusters de Minikube.

### MariaDB Galera packagé par Bitnami

MariaDB Galera est une solution de cluster de base de données multi-primaire pour la réplication synchrone et la haute disponibilité ([MariaDB Galera Cluster](https://mariadb.com/kb/en/galera-cluster/ "MariaDB Galera Cluster")).

Pour installer la carte avec le nom maria-release :

```
helm install maria-release oci://registry-1.docker.io/bitnamicharts/mariadb-galera --values ./db_values.yaml
```

La commande déploie MariaDB Galera sur le cluster Kubernetes dans sa configuration par défaut. La section [Paramètres](https://github.com/bitnami/charts/tree/main/bitnami/mariadb-galera/#parameters) répertorie les paramètres qui peuvent être configurés lors de l'installation.

### Le stockage d'objets Bitnami basé sur MinIO®

MinIO(R) est un serveur de stockage d'objets, compatible avec le service de stockage de données dans le cloud Amazon S3, principalement utilisé pour stocker des données non structurées (telles que des photos, des vidéos, des fichiers journaux, etc.).

```
helm install minio-release oci://registry-1.docker.io/bitnamicharts/minio
```

Ces commandes déploient MinIO® sur le cluster Kubernetes dans la configuration par défaut. La section [Paramètres](https://github.com/bitnami/charts/tree/main/bitnami/minio/#parameters) répertorie les paramètres qui peuvent être configurés lors de l'installation.

### WordPress packagé par Bitnami

WordPress est la plateforme de gestion de contenu et de blog la plus populaire au monde. Puissant et simple, il est utilisé par tous, de l'étudiant à l'entreprise internationale, pour créer des sites web beaux et fonctionnels.

```
helm install wordpress-release oci://registry-1.docker.io/bitnamicharts/wordpress --values ./wp_values.yaml
```

Ce Chart met en place WordPress sur un cluster Kubernetes à l'aide du gestionnaire de packages Helm. Il est à utiliser avec le fichier values.yaml.

Les packages Bitnami peuvent être utilisés avec Kubeapps pour la mise en place et la gestion des packages Helm dans les clusters.

La commande déploie WordPress sur le cluster Kubernetes dans la configuration par défaut. La section [Paramètres](https://github.com/bitnami/charts/tree/main/bitnami/wordpress/#parameters) répertorie les paramètres qui peuvent être configurés lors de l'installation.

# Partie 2 - R\&D

La deuxième partie du projet consiste à étudier trois technologies alternatives qui ont pour but de lier deux clusters pour les faire fonctionner comme un seul système de l'extérieur. Le succès de cette partie sera évalué en fonction de la documentation fournie et des résultats obtenus. Il est possible de faire des recherches pour trouver ces technologies. La première étape consiste à utiliser l'outil Admiralty pour définir des règles dans le cluster pour placer les pods qui arrivent et définir les liens manuellement avec les adresses IP publiques. La deuxième étape vise à lier les deux clusters en utilisant Liqo pour établir un VPN entre eux et faire croire à un deuxième cluster qu'il est un node, puis utiliser un LB en frontend pour les lier. La troisième étape consiste à répartir la charge des deux côtés en utilisant l'outil K8GB pour assurer un équilibrage de charge multi-cluster et garantir qu'un cluster soit le symétrique de l'autre.

Outil Liqo pour établir un VPN entre deux clusters

Démarrage rapide 


Ce tutoriel vise à présenter comment installer Liqo et pratiquer avec ses capacités les plus remarquables. Vous apprendrez à créer un cluster virtuel en appairant deux clusters Kubernetes et à y déployer une application simple.

Liqo est un projet open source qui permet la création d'un cluster Kubernetes multi-cluster et multi-cloud. Vous pouvez utiliser Liqo pour connecter vos deux clusters Kubernetes sur Azure et les faire fonctionner comme un seul cluster. Voici comment installer et configurer Liqo sur vos deux clusters Kubernetes sur Azure :

# Prérequis

- Deux clusters Kubernetes sur Azure dans des régions différentes.
- Une clé secrète pour l'authentification entre les clusters.
- Une adresse IP publique pour le point d'entrée Liqo depuis l'extérieur du cluster.
- [Docker](https://www.docker.com/), the container runtime.
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl), the command-line tool for Kubernetes.
- [Helm](https://helm.sh/docs/intro/install/), the package manager for Kubernetes.
- [curl](https://curl.se/), to interact with the tutorial applications through HTTP/HTTPS.
- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), the Kubernetes in Docker runtime.
- [liqoctl](https://docs.liqo.io/en/stable/installation/liqoctl.html) command-line tool to interact with Liqo.

Tout d’abord, vérifiez que vous êtes conforme aux exigences.

Ensuite, ouvrons un terminal sur votre machine et lançons le script suivant, qui crée une paire de clusters avec KinD. Chaque cluster est constitué de deux nœuds (un pour le plan de contrôle et un pour un simple travailleur) :

```bash
git clone https://github.com/liqotech/liqo.git
cd liqo
git checkout v0.8.0
cd examples/quick-start
./setup.sh
```


Vous pouvez inspecter les clusters déployés en tapant :

```bash
kind get clusters
```

Vous devriez voir ces résultats:

```cmd
rome milan
```

Cela signifie que deux clusters KinD sont déployés et exécutés sur votre hôte.

Ensuite, vous pouvez simplement inspecter l’état des clusters. Pour ce faire, vous pouvez exporter la variable `KUBECONFIG` pour spécifier le fichier d’identité pour **kubectl** et **liqoctl**, puis contacter le cluster.

Par défaut, les kubeconfigs des deux clusters sont stockés dans le répertoire (`./liqo_kubeconf_rome`, `./liqo_kubeconf_milan`). Vous pouvez exporter les variables d’environnement appropriées exploitées pour le reste du didacticiel (c’est-à-dire `KUBECONFIG` et `KUBECONFIG_MILAN`), en faisant référence à leur emplacement, via les éléments suivants :

```cmd
export KUBECONFIG="$PWD/liqo_kubeconf_rome"
```
```cmd
export KUBECONFIG_cluster2="$PWD/liqo_kubeconf_milan"
```

Nous vous suggérons d’exporter le kubeconfig du premier cluster par défaut (c’est-à-dire `KUBECONFIG`), car il sera le point d’entrée du cluster virtuel et vous interagirez principalement avec lui.

Sur le premier cluster, vous pouvez obtenir les pods disponibles en tapant simplement :

```bash
kubectl get pods -A
```

De même, sur le second cluster, vous pouvez observer les pods en cours d’exécution :

```cmd
kubectl get pods -A --kubeconfig "$KUBECONFIG_MILAN`
```
Si les commandes ci-dessus renvoient chacune une sortie semblable à la suivante, vos clusters sont prêts.

```txt
NAMESPACE            NAME                                           READY    STATUS    RESTARTS   AGE
kube-system          coredns-558bd4d5db-9vdr9                        1/1     Running   0          3m58s
kube-system          coredns-558bd4d5db-tzdxg                        1/1     Running   0          3m58s
kube-system          etcd-cluster1-control-plane                     1/1     Running   0          4m10s
kube-system          kindnet-fcspl                                   1/1     Running   0          3m58s
kube-system          kindnet-q6qkm                                   1/1     Running   0          3m42s
kube-system          kube-apiserver-cluster1-control-plane           1/1     Running   0          4m10s
kube-system          kube-controller-manager-cluster1-control-plane  1/1     Running   0          4m11s
kube-system          kube-proxy-2c9bl                                1/1     Running   0          3m42s
kube-system          kube-proxy-7nngv                                1/1     Running   0          3m58s
kube-system          kube-scheduler-cluster1-control-plane           1/1     Running   0          4m11s
local-path-storage   local-path-provisioner-85494db59d-skd55         1/1     Running   0          3m58s
```


# Installation de Liqo
Vous allez maintenant installer Liqo sur les deux clusters, en utilisant les noms de caractérisation suivants :

rome : le cluster local, où vous allez déployer et contrôler les applications.

milan : Le cluster distant, où une partie de vos charges de travail sera déchargée.

Vous pouvez installer Liqo sur le cluster Rome en lançant :

```cmd
liqoctl install kind --cluster-name rome
```
Cette commande générera la configuration appropriée pour votre cluster KinD, puis installera Liqo.

De même, vous pouvez installer Liqo sur le cluster Milan en lançant :

```cmd
liqoctl install kind --cluster-name milan --kubeconfig "$KUBECONFIG_MILAN"
```
Sur les deux clusters, vous devriez voir la sortie suivante:

```txt
 INFO  Kubernetes clients successfully initialized
 INFO  Installer initialized
 INFO  Cluster configuration correctly retrieved
 INFO  Installation parameters correctly generated
 INFO  All Set! You can now proceed establishing a peering (liqoctl peer --help for more information)
```
Et les pods Liqo doivent être running:

```cmd
kubectl get pods -n liqo
```
```txt
NAME                                       READY   STATUS    RESTARTS   AGE
liqo-auth-74c795d84c-x2p6h                 1/1     Running   0          2m8s
liqo-controller-manager-6c688c777f-4lv9d   1/1     Running   0          2m8s
liqo-crd-replicator-6c64df5457-bq4tv       1/1     Running   0          2m8s
liqo-gateway-78cf7bb86b-pkdpt              1/1     Running   0          2m8s
liqo-metric-agent-5667b979c7-snmdg         1/1     Running   0          2m8s
liqo-network-manager-5b5cdcfcf7-scvd9      1/1     Running   0          2m8s
liqo-proxy-6674dd7bbd-kr2ls                1/1     Running   0          2m8s
liqo-route-7wsrx                           1/1     Running   0          2m8s
liqo-route-sz75m                           1/1     Running   0          2m8s
```

De plus, vous pouvez vérifier l’état de l’installation et les principaux paramètres de configuration de Liqo en utilisant:

```cmd
liqoctl status
```

# Homologuer deux clusters
Une fois Liqo installé dans vos clusters, vous pouvez établir de nouveaux appairages. Dans cet exemple, étant donné que les deux serveurs API sont mutuellement accessibles, vous utiliserez [l’approche d’appairage hors bande](https://docs.liqo.io/en/stable/features/peering.html#featurespeeringoutofbandcontrolplane).

Tout d’abord, obtenez la commande peer du cluster Milan:

```cmd
liqoctl generate peer-command --kubeconfig "$KUBECONFIG_MILAN"
```

Ensuite, copiez et collez la commande dans le cluster Rome:

```cmd
liqoctl peer out-of-band milan --auth-url [redacted] --cluster-id [redacted] --auth-token [redacted]
```

Désormais, le plan de contrôle Liqo dans le cluster Rome contactera le point de terminaison d’authentification fourni fournissant le jeton au cluster Milan pour obtenir son identité Kubernetes.

Vous pouvez vérifier l’état de l’homologation en exécutant :

```cmd
kubectl get foreignclusters
```

La sortie doit ressembler à ce qui suit, indiquant que le tunnel réseau inter-clusters a été établi et qu’un appairage sortant est actuellement actif (c’est-à-dire que le cluster Rome peut décharger les charges de travail vers celui de Milan, mais pas l’inverse) :
```txt
NAME    TYPE        OUTGOING PEERING   INCOMING PEERING   NETWORKING    AUTHENTICATION   AGE
Milan   OutOfBand   Established        None               Established   Established      12s
```
En même temps, vous devez voir un nœud virtuel (liqo-Milan) en plus de vos nœuds physiques:

```cmd
kubectl get nodes
```
```txt
NAME                     STATUS   ROLES           AGE     VERSION
liqo-milan               Ready    agent           27s     v1.25.0
cluster1-control-plane   Ready    control-plane   7m6s    v1.25.0
cluster1-worker          Ready    <none>          6m33s   v1.25.0
```
Vous pouvez vérifier l’état de l’appairage et récupérer des informations plus avancées à l’aide des éléments suivants :

```cmd
liqoctl status peer milan
```

# Tirer parti des ressources distantes

Désormais, vous pouvez déployer une application Kubernetes standard dans un environnement multi-cluster comme vous le feriez dans un scénario de cluster unique (c’est-à-dire qu’aucune modification n’est requise).

## Démarrer une application hello world

Si vous souhaitez déployer une application planifiée sur des nœuds virtuels Liqo, vous devez d’abord créer un namespace dans lequel votre espace sera démarré. Dites ensuite à Liqo de rendre cet namespace éligible pour le déchargement du pod.

```cmd
kubectl create namespace liqo-demo
```
```cmd
liqoctl offload namespace liqo-demo
```

La commande `liqoctl offload namespace` permet à Liqo de décharger le namespace sur le cluster distant. Étant donné qu’aucune configuration supplémentaire n’est fournie, Liqo ajoutera un suffixe au nom du namespace pour le rendre unique sur le cluster distant (voir la page d’utilisation dédiée pour plus d’informations concernant [les configurations de déchargement de namespace](https://docs.liqo.io/en/stable/usage/namespace-offloading.html)).


Les nœuds virtuels ont [une tache](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) qui empêche les pods d’être programmés sur eux. Le webhook Liqo ajoutera la tolérance pour cette tache aux pods créés dans les espaces de noms compatibles Liqo.

Ensuite, vous pouvez déployer une application de démo dans le namespace `liqo-demo` du cluster local:

```cmd
kubectl apply -f ./manifests/hello-world.yaml -n liqo-demo
```

Le fichier `hello-world.yaml` représente un service simple `nginx`. Il contient deux pods exécutant une image `nginx` et un service exposant les pods au cluster. Un espace s’exécute dans le cluster local, tandis que l’autre est forcé d’être planifié sur le cluster distant.

Info

Contrairement aux exemples traditionnels, le déploiement ci-dessus introduit une contrainte d’affinité. Cela oblige Kubernetes à planifier le premier pod (`nginx-local`) sur un nœud physique et le second (`nginx-remote`) sur un nœud virtuel. Les nœuds virtuels sont comme les nœuds Kubernetes traditionnels, mais ils représentent des clusters distants et portent le label `liqo.io/type: virtual-node`.

Lorsque la contrainte d’affinité n’est pas spécifiée, le scheduler Kubernetes sélectionne le meilleur nœud d’hébergement en fonction des ressources disponibles. Par conséquent, chaque pods peut être planifié dans le cluster local ou dans le cluster distant.

Vous pouvez maintenant vérifier l’état des pods. La sortie doit être similaire à celle ci-dessous, confirmant que le pod `nginx` fonctionne localement, tandis que l’autre est hébergé par le nœud virtuel (`liqo-milan`)

`kubectl get pod -n liqo-demo -o wide`

```cmd
Et la sortie devrait ressembler à ceci:

NAME           READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
nginx-local    1/1     Running   0          10s   10.200.1.11   cluster1-worker   <none>           <none>
nginx-remote   1/1     Running   0          9s    10.202.1.10   liqo-cluster2    <none>           <none>
```
## Vérifiez la connectivité du pod
Une fois que les deux pods fonctionnent correctement, il est possible de vérifier l’une des abstractions introduites par Liqo. En effet, Liqo permet à chaque pod d’être contacté de manière transparente par tous les autres pods et nœuds physiques (selon le modèle Kubernetes), qu’il soit hébergé par le cluster local ou par le cluster distant.

Tout d’abord, récupérons l’adresse IP des pods `nginx`:

```cmd
LOCAL_POD_IP=$(kubectl get pod nginx-local -n liqo-demo --template={{.status.podIP}})
```
```cmd
REMOTE_POD_IP=$(kubectl get pod nginx-remote -n liqo-demo --template={{.status.podIP}})
```
```cmd
echo "Local Pod IP: ${LOCAL_POD_IP} - Remote Pod IP: ${REMOTE_POD_IP}"
```
Vous pouvez lancer un pod et exécuter `curl` à partir de l’intérieur du cluster:

```cmd
kubectl run --image=curlimages/curl curl -n default -it --rm --restart=Never -- curl ${LOCAL_POD_IP}
```
```cmd
kubectl run --image=curlimages/curl curl -n default -it --rm --restart=Never -- curl ${REMOTE_POD_IP}
```
Les deux commandes doivent aboutir à un résultat positif (c'est-à-dire renvoyer une page Web demo), que chaque pod soit exécuté localement ou à distance.

## Exposez les pods via un service

Le `hello-world.yaml` crée en outre un service conçu pour desservir le trafic vers les pods précédemment déployés. Il s'agit d'un [service Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/) traditionnel et peut fonctionner avec Liqo sans modifications.

En effet, en inspectant le Service, il est possible de constater que les deux pods `nginx` sont correctement spécifiés comme endpoints. Néanmoins, il convient de noter que le premier endpoint (`10.200.1.10:80`) fait référence à un pod s'exécutant dans le cluster local, tandis que le second (`10.202.1.9:80`) pointe vers un pod hébergé par le cluster distant.

```cmd
kubectl describe service liqo-demo -n liqo-demo
```
```cmd
Name:              liqo-demo
Namespace:         liqo-demo
Labels:            <none>
Annotations:       <none>
Selector:          app=liqo-demo
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.94.41.143
IPs:               10.94.41.143
Port:              web  80/TCP
TargetPort:        web/TCP
Endpoints:         10.200.1.11:80,10.202.1.10:80
Session Affinity:  None
Events:
  Type    Reason                Age                From                     Message
  ----    ------                ----               ----                     -------
  Normal  SuccessfulReflection  51s (x2 over 51s)  liqo-service-reflection  Successfully reflected object to cluster "Milan"
```
## Vérifiez la connectivité du service

Il est désormais possible de contacter le Service : comme d'habitude, Kubernetes transmettra la requête HTTP à l'un des pods back-end disponibles. De plus, tous les mécanismes traditionnels fonctionnent toujours de manière transparente (par exemple, la découverte DNS), même si l'un des pods s'exécute réellement dans un cluster distant.

Vous pouvez lancer un pod et exécuter un `curl` depuis l'intérieur du cluster :

```cmd
kubectl run --image=curlimages/curl curl -n default -it --rm --restart=Never -- \
    curl --silent liqo-demo.liqo-demo.svc.cluster.local | grep 'Server'
```

En exécutant la commande précédente plusieurs fois, vous remarquerez qu’une partie des demandes est traitée par l’espace exécuté dans le cluster local, et en partie par celui du cluster distant (c’est-à-dire que la valeur du serveur change).

## Lancer une application de microservice

Il est très courant dans un environnement cloud de déployer des applications de microservices composées de nombreux pods interagissant entre eux. Ce modèle est pris en charge de manière transparente par Liqo et l’abstraction du cluster virtuel.

Vous pouvez lancer une [application de microservices](https://github.com/GoogleCloudPlatform/microservices-demo) fournie par Google, qui comprend plusieurs services coopérants exploitant différents protocoles réseau :

```kubectl apply -k ./manifests/demo-application -n liqo-demo```

Par défaut, Kubernetes planifie chaque espace dans le cluster local ou distant, optimisant chaque déploiement en fonction des ressources disponibles. Cependant, vous pouvez lancer avec des contraintes d’affinité pour forcer Kubernetes à planifier chaque composant dans un emplacement spécifique et voir que tout continue de fonctionner correctement. Plus précisément, le manifeste ci-dessus force le composant frontal à être exécuté dans le cluster local, car cela est nécessaire pour activer la redirection de port, qui est exploitée ci-dessous.

Chaque composant de démonstration est exposé en tant que service et accessible par d’autres composants. Cependant, étant donné que personne ne sait, a priori, où chaque service sera déployé (localement ou dans le cluster distant), Liqo [répliques](https://docs.liqo.io/en/stable/features/offloading.html#featureresourcereflection) tous les services Kubernetes sur les deux clusters, bien que l’espace correspondant puisse ne s’exécuter que dans un seul emplacement. Par conséquent, chaque microservice déployé sur des clusters peut atteindre les autres de manière transparente : indépendamment du cluster dans lequel un pod est déployé, chaque pod peut contacter d’autres services et tirer parti des mécanismes de découverte traditionnels de Kubernetes (par exemple, la découverte DNS et les variables d’environnement).

En outre, plusieurs autres objets (`ConfigMaps` et `Secrets`) à l’intérieur d’un namespace sont répliqués dans le cluster distant au sein du namespace jumeau, garantissant ainsi que les applications complexes peuvent fonctionner de manière transparente entre les clusters. 

## Observer le déploiement de l’application
Une fois que l'application démo est déployé, vous pouvez observer la création des différents pods :

`watch kubectl get pods -n liqo-demo -o wide`

À l’état stable, vous devriez voir une sortie semblable à la suivante. Différents pods peuvent être hébergés par les nœuds locaux (rome-worker dans l’exemple ci-dessous) ou par le cluster distant (liqo-milan dans l’exemple ci-dessous), en fonction des décisions de planification.

```cmd
NAME                                     READY   STATUS    RESTARTS        AGE     IP            NODE          NOMINATED NODE   READINESS GATES
adservice-84cdf76d7d-6s8pq               1/1     Running   0               5m1s    10.202.1.11   liqo-cluster2    <none>           <none>
cartservice-5c9c9c7b4-w49gr              1/1     Running   0               5m1s    10.202.1.12   liqo-cluster2    <none>           <none>
checkoutservice-6cb9bb8cd8-5w2ht         1/1     Running   0               5m1s    10.202.1.13   liqo-cluster2    <none>           <none>
currencyservice-7d4bd86676-5b5rq         1/1     Running   0               5m1s    10.202.1.14   liqo-cluster2    <none>           <none>
emailservice-c9b45cdb-6zjrk              1/1     Running   0               5m1s    10.202.1.15   liqo-cluster2    <none>           <none>
frontend-58b9b98d84-hg4xz                1/1     Running   0               5m1s    10.200.1.13   cluster1-worker   <none>           <none>
loadgenerator-5f8cd58cd4-wvqqq           1/1     Running   0               5m1s    10.202.1.16   liqo-cluster2    <none>           <none>
nginx-local                              1/1     Running   0               7m35s   10.200.1.11   cluster1-worker   <none>           <none>
nginx-remote                             1/1     Running   0               7m34s   10.202.1.10   liqo-cluster2    <none>           <none>
paymentservice-69558cf7bb-v4zjw          1/1     Running   0               5m      10.202.1.17   liqo-cluster2    <none>           <none>
productcatalogservice-55c58b57cb-k8mfq   1/1     Running   0               5m      10.202.1.18   liqo-cluster2    <none>           <none>
recommendationservice-55cd66cf64-6fz9w   1/1     Running   0               5m      10.202.1.19   liqo-cluster2    <none>           <none>
redis-cart-5d45978b94-wjd97              1/1     Running   0               5m      10.202.1.20   liqo-cluster2    <none>           <none>
shippingservice-5df47fc86-f867j          1/1     Running   0               4m59s   10.202.1.21   liqo-cluster2    <none>           <none>
```
## Accéder à l’application de démonstration
Une fois le déploiement opérationnel, vous pouvez commencer à utiliser l’application de démonstration et vérifier que tout fonctionne correctement, même si ses composants sont répartis sur plusieurs clusters Kubernetes.

Par défaut, la page Web frontend est exposée via un service `LoadBalancer`, qui peut être inspecté à l’aide de:

```cmd
kubectl get service -n liqo-demo frontend-external
```

La commande `kubectl port-forward` permet transférer les requêtes de votre ordinateur local (`http://localhost:8080`) vers le service frontend :

```cmd
kubectl port-forward -n liqo-demo service/frontend-external 8080:80
```

Ouvrez la page http://localhost:8080 dans votre navigateur et profitez de l’application de démo.

## Démantelez l'environnement  
Notre exemple est terminé. Maintenant, nous pouvons supprimer toutes les ressources créées et démolir le terrain de jeu.

## Décharger les namespaces
Avant de commencer le processus de désinstallation, assurez-vous que tous les espaces de noms sont déchargés :

```cmd
liqoctl unoffload namespace liqo-demo
```

Chaque espace qui a été déchargé vers un cluster distant va être reprogrammé sur le cluster local.

## Révoquer les interconnexion
De même, assurez-vous que tous les peerings sont révoqués :

```cmd
liqoctl unpeer out-of-band milan
```

À la fin du processus, le nœud virtuel est supprimé du cluster local.

## Désinstaller Liqo
Vous pouvez maintenant désinstaller Liqo de vos clusters avec `liqoctl`:

```cmd
liqoctl uninstall
```
```cmd
liqoctl uninstall --kubeconfig="$KUBECONFIG_cluster2"
```

Par défaut, les CRDs Liqo resteront dans le cluster, mais ils peuvent être supprimés avec `--purge`

```cmd
liqoctl uninstall --purge
```
```cmd
liqoctl uninstall --purge --kubeconfig="$KUBECONFIG_MILAN"
```
## Détruire les clusters

Pour démonter les clusters KinD, vous pouvez émettre :

```cmd
kind delete cluster --name rome
```
```cmd
kind delete cluster --name milan
```   
# Prérequis pour mettre en place k8gb
Avant de commencer, vous devez vous assurer que vous disposez des éléments suivants :

- Un cluster Kubernetes en cours d'exécution sur Azure
- Un compte Azure avec les autorisations nécessaires pour accéder au cluster Kubernetes
- Une connexion SSH à votre cluster Kubernetes

## Installation de K8GB
La première étape consiste à installer K8GB dans votre cluster Kubernetes. Vous pouvez utiliser la commande suivante pour installer K8GB via Helm :

```shell
helm repo add k8gb https://k8gb.io
helm install k8gb k8gb/k8gb
```

Configuration de K8GB
Une fois K8GB installé, vous pouvez le configurer pour fournir une résolution de noms de domaine globale et de la haute disponibilité pour les services Kubernetes. Voici les étapes de configuration à suivre :

## Étape 1 : Configuration des enregistrements DNS
Vous devez configurer les enregistrements DNS pour les services que vous souhaitez rendre disponibles à l'échelle mondiale. Vous pouvez utiliser un service de DNS tiers tel que Cloudflare ou Azure DNS pour créer ces enregistrements DNS. Voici un exemple de configuration d'un enregistrement DNS pour un service :
- dns-config.yml

```yml
apiVersion: k8gb.io/v1alpha1
kind: DNSTarget
metadata:
  name: myservice
  namespace: mynamespace
spec:
  geoTag: us
  targetType: svc
  targetRef:
    name: myservice
    namespace: mynamespace
```

Dans cet exemple, le service "myservice" dans l'espace de noms "mynamespace" est configuré pour être accessible depuis les États-Unis. Vous pouvez modifier la spécification "geoTag" pour permettre à votre service d'être accessible depuis d'autres régions.

## Étape 2 : Configuration des redondances DNS
Vous pouvez configurer des redondances DNS pour garantir une haute disponibilité pour vos services. Vous pouvez utiliser la commande suivante pour créer une redondance DNS pour un enregistrement DNS donné :
- redondance.yml

```yml
apiVersion: k8gb.io/v1alpha1
kind: DNSTarget
metadata:
  name: myservice-replica
  namespace: mynamespace
spec:
  geoTag: us
  targetType: svc
  targetRef:
    name: myservice
    namespace: mynamespace
  dnsZone:
    name: mydomain.com
```

Dans cet exemple, une redondance DNS est créée pour l'enregistrement DNS "myservice" dans l'espace de noms "mynamespace". Vous pouvez modifier la spécification "dnsZone" pour spécifier une zone DNS différente pour la redondance.

## Étape 3 : Configuration de la bande passante
Vous pouvez configurer des limites de bande passante pour limiter le trafic réseau vers vos services. Vous pouvez utiliser la commande suivante pour définir des limites de bande passante pour un enregistrement DNS donné :
- bp.yml

```yml
apiVersion: k8gb.io/v1alpha1
kind: DNSTarget
metadata:
  name: myservice
  namespace: mynamespace
spec:
  geoTag: us
  targetType: svc
  targetRef:
    name: myservice
    namespace: mynamespace
  strategy:
    provider: route53
    preventGeoSplit: true
    latency
```
### Quick Start
- Simply run

```shell
make deploy-full-local-setup
```


# Installer K8GB sur un cluster AKS à l'aide de la chart Helm :

Tout d'abord, assurez-vous que vous avez installé Helm sur votre machine locale et qu'il est configuré pour se connecter à votre cluster AKS. Pour cela, vous pouvez utiliser la commande suivante :

```helm init --kube-context <nom_de_votre_cluster_aks>```

Ensuite, ajoutez le référentiel K8GB Helm à Helm à l'aide de la commande suivante :

```helm repo add k8gb https://k8gb.io```

Mettez à jour vos référentiels Helm à l'aide de la commande suivante :

```helm repo update```


Créez un fichier values.yaml qui contient les valeurs personnalisées que vous souhaitez utiliser pour l'installation de K8GB. Vous pouvez trouver un exemple de fichier values.yaml sur le référentiel GitHub de K8GB.

Installez la chart Helm K8GB à l'aide de la commande suivante :

```helm install k8gb/k8gb --version <version> --namespace <namespace> --name <nom_de_votre_installation> -f values.yaml```

Notez que vous devez remplacer <version> par la version que vous souhaitez installer, <namespace> par le namespace que vous voulez utiliser et <nom_de_votre_installation> par le nom que vous souhaitez donner à votre installation.

Vérifiez que l'installation a été effectuée en exécutant la commande suivante :

```kubectl get pods -n <namespace>```

Vous devriez voir les pods K8GB en cours d'exécution dans le namespace que vous avez spécifié.

Pour utiliser K8GB, vous devez configurer vos services DNS. Vous pouvez trouver des instructions détaillées sur la configuration de K8GB sur le site Web de K8GB.
  
# Prérequis pour installer Admiralty
  
Avant de commencer l'installation d'Admiralty, vous devez avoir les éléments suivants :

1. Deux clusters Kubernetes fonctionnels sur Azure, connectés via Liqo
2. K8GB installé et configuré sur chaque cluster
3. Le client `kubectl` installé et configuré pour se connecter aux deux clusters Kubernetes
4. L'outil Helm installé sur votre machine

## Étape 1 : Ajout du dépôt Helm Admiralty  

La première étape consiste à ajouter le dépôt Helm Admiralty à votre liste de sources de dépôts Helm. Pour ce faire, exécutez la commande suivante :

```bash
helm repo add admiralty https://charts.admiralty.io
```  

## Étape 2 : Installation du contrôleur Admiralty
  
Maintenant que le dépôt Helm Admiralty est ajouté, vous pouvez installer le contrôleur Admiralty en utilisant la commande suivante :
  
```bash
helm install admiralty admiralty/admiralty
```
  
Cette commande va installer le contrôleur Admiralty dans votre cluster Kubernetes.
  
## Étape 3 : Configuration des clés d'accès Azure  

Le contrôleur Admiralty a besoin d'accéder à votre compte Azure pour fonctionner correctement. Pour cela, vous devez configurer les clés d'accès Azure dans le cluster Kubernetes en utilisant un secret Kubernetes. Pour créer le secret, exécutez la commande suivante :

```bash
 kubectl create secret generic azure-credentials \
    --from-literal=AZURE_SUBSCRIPTION_ID=<subscription_id> \
    --from-literal=AZURE_TENANT_ID=<tenant_id> \
    --from-literal=AZURE_CLIENT_ID=<client_id> \
    --from-literal=AZURE_CLIENT_SECRET=<client_secret>
```

Remplacez `<subscription_id>`, `<tenant_id>`, `<client_id>` et `<client_secret>` par les informations d'identification Azure appropriées.  
  
## Étape 4 : Configuration des points de terminaison Admiralty

Maintenant que le contrôleur Admiralty est installé et que les clés d'accès Azure sont configurées, vous pouvez configurer les points de terminaison Admiralty en utilisant des annotations Kubernetes sur les objets de ressource Kubernetes. Pour cela, vous devez utiliser les annotations spécifiques K8GB fournies avec Admiralty pour définir les clusters source et destination. Par exemple, pour configurer le point de terminaison Admiralty pour un déploiement Kubernetes, vous pouvez utiliser les annotations suivantes :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  annotations:
    k8gb.io/replicas: "1"
    k8gb.io/healthcheck: "/healthz"
    k8gb.io/origin-endpoints: "nginx.default.svc.cluster.local"
    k8gb.io/destination-rules: |
      {
        "priority": 1,
        "rules": [
          {
            "host": "nginx.default.svc.cluster.local",
            "http": {
              "paths": [
                {
                  "path": "/",
                  "backend": {
                    "serviceName": "nginx",
                    "servicePort": 80
                  }
                }
              ]
            }
          }
        ]
      }
    admiralty.io/anchor: "true"
    admiralty.io/fleet: "fleet-a"
spec:
  replicas: 1
```  
## Étape 5 : Mise en place de la solution en local

Dans ce projet, nous avons suivi la documentation fournie pour effectuer le déploiement multi-cluster. Le déploiement consiste en un frontend exécuté sur deux clusters différents. Nous avons utilisé la commande "make deploy-full-local-setup" pour exécuter les différentes étapes décrites dans la documentation. La raison de ce choix était que l'un de nos comptes Azure avait atteint sa limite de dépenses de 100€, nous empêchant ainsi de déployer les clusters sur Azure. Par conséquent, nous avons opté pour la solution alternative proposée par un collaborateur, qui était très simple à reproduire sur deux clusters distincts. Il suffisait de remplacer les fichiers de configuration kubeconfig "US" et "EU" par ceux de nos propres clusters.

Dans le but d'effectuer une démonstration rapide, nous procèdons à la duplication du dépôt GitHub du projet sur l'instance, tout en récupérant également le fichier binaire de k3d (K3s in Docker) en chemin.
  
![Screen1](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/8b10c0b1-1ed2-43ab-8ad0-dddaf278e57e)
![Screen2](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/2d65255b-bd0c-4866-820b-68ba7c99f972)

Installation de kubectl et helm.
  
![Screen3](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/096652d8-4433-440d-9c05-8be95352db1a)
![Screen4](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/4ab9cc3e-4652-4d45-9d30-24054fc42883)
![Screen5](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/76a6c1eb-a9a1-4e99-afec-d6a3094b31ab)
![Screen6](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/25a52895-f009-419a-af6c-d5a94cb28f7b)
![Screen7](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/42ae7f1e-721c-420c-aa71-5e2cd8b12b67)
![Screen8](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/d96e8e66-7a4b-4780-ade6-3b98489546f1)
![Screen9](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/52cd527c-9261-40b2-9662-12e44d2cbdb5)
![Screen10](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/baca769e-0e18-4bf3-8ba3-6e70d7f3c074)
![Screen11](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/5e85f077-858f-442a-bba8-804278592c4f)
![Screen12](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/e3e67a99-0cd1-4bb9-a1b2-ce693761d62a)
![Screen13](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/53497552-3b85-4532-beef-ae1bf00b3efd)
![Screen14](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/3e5cd695-a19b-4ce8-8fce-1077ce68a18d)
![Screen15](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/448be5b8-bc38-4eb8-89ad-8d64d0624361)
![Screen16](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/22bb4c43-1bbb-4f3b-aa94-60ed4f811ff5)
  
Voici les différents clusters :
  
![ScreenList](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/a5a465c8-6425-416c-bc2c-4dcd51228110)
![ScreenControl](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/1b8ad29b-d167-4f22-8a93-4a7e29388814)
  
Une partie monitoring avec Prometheus est également présentes :
  
![ScreenProm](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/06929e37-16c7-4761-abd8-4f7c2df70836)
![ScreenProm2](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/b6e40013-dd0d-4af1-ad1e-01090f42c2f9)
![ScreenProm3](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/c8ca39f6-879c-40b0-afae-cff004846ebb)
<img width="802" alt="ScreenProm4" src="https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/5276ea7e-e625-48c0-898e-4b5225371389">

<img width="759" alt="ScreenFrontend" src="https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/1ab169f0-c426-4ddc-adb6-c0d0d390f459">

![ScreenGetall](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/cf3bbb5c-72d4-4027-8946-2f171f13aa86)
Dans cette architecture, nous avons mis en place deux clusters où "podinfo" est déployé. Chaque cluster a été étiqueté en fonction de la région qu'il dessert. L'objectif de cette démonstration est d'accéder à "podinfo" en utilisant la commande "wget -qO -- failover.cloud.example.com". En fonction du cluster dans lequel "podinfo" est exécuté, il renverra uniquement les valeurs "eu" ou "us". Cela permet de démontrer la capacité de "podinfo" à fournir une réponse en fonction de la région du cluster dans lequel il se trouve.
  
![ScreenFailover](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/3a20baef-cf4f-4c0d-8c61-bfc29485e9e1)
![ScreenStop](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/30e871a5-2e81-4b62-b73f-6efc1c4dbf65)
![ScreenTestFailover](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/536df7a5-f385-48d5-8212-84c0e81fc54a)
![ScreenStart](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/0075e7ab-1593-4636-87f8-a57f0c174224)
![ScreenTestFail](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/90c0584f-c9c7-4126-b5a5-3b54ea270673)
![ScreenRR1](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/ee797e4e-311e-4a9e-8817-09b00f4cd51a)
![ScreenRR2](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/30e73359-c1c7-442e-abee-fd7798b5832a)
 
Suppression de l'environnement de test :
 
![ScreenDestroy](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/754562c0-8a54-47fc-b4c8-f5641fc76082)

Nous effectuons la récupération locale du client "liqoctl" ainsi qu'une copie du dépôt correspondant sur GitHub : 

![ScreenLiqo](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/3eeebb90-24c2-42d0-bdfd-f9841bf69d10)
![ScreenLiqo2](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/2980c2a1-c307-4b95-a4aa-44a3af9a6a68)

Le dépôt GitHub contient un script de configuration qui illustre la création de trois clusters k3s et déploie l'application d'infrastructure appropriée au-dessus de ces clusters : 
  
![Screenliqo3](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/d850da4d-f436-46a0-914b-da42bf8d13ab)

Nous procédons au peering entre les clusters :
  
![ScreenPeering](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/044fbfca-7ecb-4703-828f-bceb34c2914d)
![ScreenPeeringEsta](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/146f72cf-0dcd-4df6-85a4-ecc37192f91e)

Dans le cluster "gslb-eu", un nouveau nœud virtuel nommé "liqo-gslb-us" a été créer :

![ScreenNode](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/86813b76-8fd4-44dc-96a3-5a3e4664c86c)
  
Une fois que le peering Liqo est établi et que le nœud virtuel est prêt, nous sommes en mesure de déployer l'application de démonstration "podinfo". 
Cette application offre une page web affichant diverses informations, notamment le nom du pod. 
Cela facilite l'identification de la réplique spécifique qui génère la réponse HTTP :
  
![ScreenHelm](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/1ac8b42f-2db5-4d1d-9ad8-8e1fbcf9025c)
![ScreenNginx](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/f5d0ebe9-d838-463f-b68c-1e1fc885a764)

Pour chaque installation locale de K8GB, une ressource Gslb est créée, contenant les informations sur l'Ingress et la stratégie spécifiée (dans ce cas, RoundRobin). ExternalDNS est ensuite utilisé pour mettre à jour les enregistrements DNS en conséquence: 
  
![ScreenKube](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/7a1d6570-8f58-41a4-abb9-c388e85f0f07)
![ScreenKube2](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/6ee213ef-5865-4063-9e04-70faff5e3b56)

Les ressources Gslb dans les deux clusters sont presque identiques, à l'exception du champ geoTag qui diffère entre "eu" et "us" dans ce cas.

![ScreenKube3](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/45317671-68f2-4135-b460-4269f76305ac)
![ScreenCluster](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/786e87de-4832-4332-ac76-b792eb127b38)
![ScreenKubeConf](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/1981f1ef-1a6a-413c-8243-55dd5afd48f2)

Étant donné que "podinfo" est un service HTTP, il est possible de le contacter en utilisant la commande "curl" avec l'option "-v" pour déterminer le nœud ciblé. 
Le serveur DNS est utilisé pour résoudre le nom d'hôte en l'adresse IP du service.

![ScreenLIQOCl](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/7b4c60fb-4909-43a0-8fec-7706cd593e57)
![ScreenCTL](https://github.com/Ysejal/wordpress-ha-s3/assets/72010054/03cf0473-b51c-4a51-a8c0-05832c2581f5)






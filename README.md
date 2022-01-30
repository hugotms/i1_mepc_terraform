# TP 3 - Mise en place infrastructure cloud

Ce projet a été réalisé par Valentin SALMON et Hugo TOMASI (I1 EPSI Nantes). Le produit qui a été mis en place au cours de ce TP est Nextcloud. Ce dernier a été choisi en raison de sa grande modularité.

## Description

L'utilisation de ce module nécessite d'avoir terraform d'installé sur son poste (ou sa machine de développement).

Le cloud provider Scaleway a été utilisé pour mener à bien ce projet. Les services utilisés sont le service Kubernetes, le service de base de données PostgreSQL. A ceux-ci s'ajoutent la création d'un LoadBalancer destiné à rendre accessible nos instances Nextcloud depuis l'extérieur.

## Exécution (Linux / MacOS)
Avant le lancement du projet, les commandes suivantes doivent être exécutées:

```bash
export SCW_ACCESS_KEY=<VOTRE_ACCESS_KEY>
export SCW_SECRET_KEY=<VOTRE_SECRET_KEY>
export SCW_DEFAULT_PROJECT_ID=<VOTRE_PROJECT_ID>
```

Une fois ceci fait, il conviendra de faire un `terraform init` afin d'initialiser le projet. Enfin, afin de lancer la configuration, un `terraform apply` devra être exécuté.

## Accès à Nextcloud

Lorsque Terraform a terminé sa configuration, il vous faut aller récupérer sur Scaleway l'adresse IP du load balancer qui a été créé. L'accès à notre instance Nextcloud se fait en entrant dans une barre de recherche l'url suivante : `http://<IP_DU_LOADBALANCER>/`.

Les logins pour y accéder sont : `admin` comme username et `epsi2021` en password.

Normalement, vous devriez ensuite accéder à la page d'accueil de Nextcloud.

## Axes d'améliorations

Notre LoadBalancer nous permet d'accéder à notre application sur le port 80, en HTTP donc. La mise en place de l'HTTPS (donc avec la création d'un certificat) est une étape plus que cruciale pour une application type Nextcloud et ce même pour un usage personnel.

Le type de machines/instances choisies pour réaliser ce TP ne sont pas viable pour une application qui serait mise en production ou qui contiendrait des données sensibles. Des solutions beaucoup plus adaptées sont fournies par Scaleway et devrait être privilégiées.

De plus, si une ébauche de backup de base de données a été réalisée, une sécurisation plus importante devrait être réalisée.

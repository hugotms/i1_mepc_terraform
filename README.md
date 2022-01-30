# TP 3 - Mise en place infrastructure cloud

Ce projet a été réalisé par Valentin SALMON et Hugo TOMASI (I1 EPSI Nantes).

## Description

L'utilisation de ce module nécessite d'avoir terraform d'installé sur son poste (ou sa machine de développement).

Le cloud provider Scaleway a été utilisé pour mener à bien ce projet. Les services utilisés sont le service Kubernetes, le service de base de données PostgreSQL. A ceux-ci s'ajoutent la création d'une IP publique ainsi que la création d'un groupe de sécurité (destiné à servir de firewall à notre réseau).

## Exécution (Linux / MacOS)
Avant le lancement du projet, les commandes suivantes doivent être exécutées:

```bash
export SCW_ACCESS_KEY=<VOTRE_ACCESS_KEY>
export SCW_SECRET_KEY=<VOTRE_SECRET_KEY>
export SCW_DEFAULT_PROJECT_ID=<VOTRE_PROJECT_ID>
```

Une fois ceci fait, il conviendra de faire un `terraform init` afin d'initialiser le projet.

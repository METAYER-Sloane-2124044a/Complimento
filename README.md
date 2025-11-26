# Complimento Project 🌸

**Complimento** est un site web générateur de compliments. Son objectif : remonter le moral de ses utilisateurs !

## Services et Langages 📖

Le projet utilise divers services et langages de programmation :

- HTML/CSS/JavaScript : pour construire notre site
- S3 : pour stocker nos fichiers web
- Lambda : pour récupérer des informations spécifiques à l'aide de fonctions
- API Gateway : pour accéder aux lambdas
- DynamoDB : pour stocker des informations et images nécessaires au site dans une base de données NoSQL
- IAC (Infrastructure As Code) : pour automatiser l'infrastructure
- Python : pour initialiser notre base de données et implémenter les lambdas

## Prerequis 📋

- python >= 3.8
- boto3>=1.40.74

- OpenTofu : https://opentofu.org/docs/
- LocalStack : https://docs.localstack.cloud/
- AWS CLI
- Docker

## Guide d'installation ⬇️

- Installer AWS CLI

```bash
pip install awscli-local
```

- Configurer AWS CLI

```bash
aws configure
```

utiliser les valeurs suivantes :

```bash
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
Default output format [None]: json
```

## Guide de démarrage ▶️

_Pour toutes les demandes de confirmations, rentrer `yes`_

1. Créer le fichiers `terraform.tfvars` :

A partir du fichier `terraform.tfvars.example`, créer le fichier `terraform.tfvars` à la racine et rentrer les valeurs liée à votre configuration.

2. Ouvrir Docker
3. Lancer le `docker-compose.yml`
4. Initialiser le projet avec OpenTofu :

```bash
tofu init
```

5. Prévisualise les ressources à créer avec OpenTofu :

```bash
tofu plan
```

6. Déployer le projet avec OpenTofu :

```bash
tofu apply
```

7. Supprimer les ressources après utilisation du site (optionnel)

```bash
tofu destroy
```

# Explications des fichiers `.tf` ❔

L'ensemble des fichiers `.tf` se situent à la racine du projet.

Les fichiers de configuration du projet sont :

- `variable.tf` : définit les variables utilisées plusieurs fois dans les autres fichiers `.tf`
- `output.tf` : affiche des informations après le déploiement du projet

- `locals.tf` : définit les variables locales partagées entre différentes ressources
- `providers.tf` : configure AWS (simulation via LocalStack)
- `s3.tf` : définit les ressources à stocker
- `apigateway.tf` : configure l'IaC pour donner accès aux lambdas
- `lambda.tf`: configure les fonctions lambdas et les permissions
- `dynamodb.tf`: crée les collections et les alimente

## Guide d'utilisation des lambdas 🌐

- la fonction `get_handler_compliment` est liée à la route:

`http://localhost:4566/restapis/<id-rest-api>/dev/_user_request_/compliment?type=<type>`

Celle-ci récupère un message (compliment) aléatoire en fonction d'un type.

## Collaborateurs 🌟

- Carlier Lucynda `@CuteCookieBear`
- Medina Emma `@Memma31`
- Métayer Sloane `@METAYER-Sloane-2124044a`

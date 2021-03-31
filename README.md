# ESIR S8 - Projet Programmation Serveur Web

Pour la partie TP du module programmation serveur web, nous développerons un backend d'une application web, basé sur le 
framework `NestJS`.
`NestJS` est écrit en Typescript et permet un grand nombre d'automatisations et procure un ensemble d'outils qui rend le 
développement d'un backend agréable et simple.

## Pré-requis

Il vous faut [installer `NodeJS`](https://nodejs.org/en/download/) pour pouvoir installer et utiliser `NestJS`.
Suivez la procédure en fonction de votre système d'exploitation.

L'IDE à utiliser est [VisualCode Studio](https://code.visualstudio.com/). Une fois installé, vous pouvez le lancer depuis
un terminal en vous plaçant dans le repertoire de votre projet et en tapant la commande : 

```shell=
code .
``` 

Afin de tester le backend, nous allons aussi utiliser des commandes [`curl`](https://curl.se/download.html). 
Veillez à bien installer cette commande et à la rendre disponible dans votre terminal (_e.g._ ajoutez le à votre variable
d'environnement `$PATH` si vous êtes sur Linux). Des scripts `curl` seront fourni afin de vérifier votre implémentation 
du service web backend.
Pour des tests pas à pas, `curl` reste un bon atout mais vous pouvez aussi employer [PostMan](https://www.postman.com/)
qui fournit une interface graphique pour gérer les paramètres des requêtes.

## Organisation

Le code source du projet doit être poussé sur un dépôt gitlab dédié. Vous veillerez à garder ce dépôt privé ainsi que de
donner les droits d'accès aux évaluateurs.

## Projet

Le projet portera sur la numérisation de la gestion des associations par les services publics.

Il s'agira de gérer les informations des utilisateurs, c'est-à-dire les personnes qui sont rattachées à une association,
ainsi que ces dites associations.

Dans la gestion de ces associations, plusieurs départements entrent en jeux comme le département des finances ou le 
département juridique.

À la fin, l'application devra être capable de :
- gérer les utilisateurs : création, récupération, listing, mis à jours et suppression.
- gérer les associations : création, récupération, listing, mis à jours et suppression.

Les détails de conception ainsi que les procédures seront décrites au fur et à mesure du projet

## Étapes du projet

Afin de vous guider, le projet a été divisé en étapes. Vous devez absolument arrivé au moins à l'étape 5. Si vous 
complétez l'étape 6, 7 et 8, je vous tire mon chapeau.

1. [Premiers pas avec NestJS](./premiers_pas_avec_nestjs.md)
2. [Contrôleurs et première API](./controleurs_et_premiere_api.md)
3. [Modules et logique métier](./modules_et_logiques_metiers.md)
4. [TypeORM, Repository et données](typeorm_repository_et_donnees.md)
5. [Développement](./developpement.md)
6. [OpenAPI](./openapi.md)
7. [Tester son backend NestJS](./tester_son_backend_nestjs.md)
8. [Sécurité](./securite.md)

## Modalités d'évaluation

Le projet est la seule évaluation du module.

- Soutenance de présentation du projet et de la compréhension des notions.
- Points Bonus si étapes 6, 7, 8.
- Appréciation de la gestion du dépôt git : nombre de commits message de commits, régularité des commits, etc.
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

```shell
code .
``` 

Afin de tester le backend, nous allons aussi utiliser des commandes [`curl`](https://curl.se/download.html). 
Veillez à bien installer cette commande et à la rendre disponible dans votre terminal (_e.g._ ajoutez le à votre variable
d'environnement `$PATH` si vous êtes sur Linux). Des scripts `curl` seront fournis afin de vérifier votre implémentation 
du service web backend.
Pour des tests pas à pas, `curl` reste un bon atout mais vous pouvez aussi employer [PostMan](https://www.postman.com/)
qui fournit une interface graphique pour gérer les paramètres des requêtes.

## Projet

Le projet portera sur la numérisation de la gestion des associations par les services publics.

Il s'agira de gérer les informations des utilisateurs, c'est-à-dire les personnes qui sont rattachées à une association,
ainsi que ces dites associations.

Dans la gestion de ces associations, plusieurs départements entrent en jeux comme le département des finances ou le 
département juridique.

À la fin, l'application devra être capable de :
- gérer les utilisateurs : création, récupération, listing, mise à jour et suppression.
- gérer les associations : création, récupération, listing, mise à jour et suppression.

Les détails de conception ainsi que les procédures seront décrites au fur et à mesure du projet.

## Étapes du projet

Afin de vous guider, le projet a été divisé en étapes. Vous devez absolument arriver au moins à l'étape 7. Si vous 
complétez l'étape 8, je vous tire mon chapeau.

1. [Premiers pas avec NestJS](./premiers_pas_avec_nestjs.md)
2. [Contrôleurs et première API](./controleurs_et_premiere_api.md)
3. [Modules et logique métier](./modules_et_logiques_metiers.md)
4. [TypeORM, Repository et données](typeorm_repository_et_donnees.md)
5. [OpenAPI](./openapi.md)
6. [Tester son backend NestJS](./tester_son_backend_nestjs.md)
7. [Sécurité](./securite.md)
8. [Développement](./developpement.md)

## Modalités d'évaluation

Le projet est la seule évaluation du module. Le projet sera réalisé en binôme. Vous devrez rendre votre projet 
sous la forme d’un projet **privé** sur le [GitLab de l’ISTIC](https://gitlab.istic.univ-rennes1.fr) sur lequel vous 
aurez mis votre code source ainsi qu’un rapport détaillant vos choix de mapping ORM et d'API. Un fichier README 
à la racine du projet GitLab devra en décrire le contenu et l’organisation.
Vous devrez inviter vos évaluateurs au projet GitLab et leur envoyer l’adresse du projet par mail au plus tard
le 27/04/22 à minuit (CET) pour le groupe 2 (soutenance le **28 avril** ), et au plus tard le 29/04/22 à midi (CET) pour le groupe 1 (soutenance le **29 avril** )
lors de votre dernière séance de travaux pratiques.

Voici les critères d'évaluation utilisés :

- Soutenance de présentation du projet et de la compréhension des notions.
- Appréciation de la gestion du dépôt git : nombre de commits, message de commits, régularité des commits, etc.

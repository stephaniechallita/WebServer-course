# Premiers pas avec NestJS

## Installation et Création de projet

Pour installer `NestJS`, vous pouvez utiliser la ligne de commande suivante : 

```shell
npm i -g @nestjs/cli
```

Il se peut que vous devez avoir les droits d'administration.
Avec cette commande, vous avez à disposition un ensemble de commandes qui permet de générer du code pour votre backend `NestJS`

Pour générer un squelette de projet `NestJS`, il suffit d'utiliser la ligne de commande suivante :

```shell
nest new fr-administration
```

Choisissez `npm` comme `package manager`.

Pour les machines de l'ISTIC/ESIR, une alternative est de suivre la procédure suivante :

```sh
git clone https://github.com/nestjs/typescript-starter.git fr-administration
cd fr-administration
npm install
```

Puis, au lieu de lancer la commande `nest`, utilisez `node node_modules/@nestjs/cli/bin/nest.js`.

Par exemple: 

```
nest g s services
```

est équivalent à :

```
node node_modules/@nestjs/cli/bin/nest.js g s services
```

Pour améliorer votre confort, ajoutez à votre `.bashrc` dans votre `HOME` la ligne:

```sh
alias nest='node /<absolute_path/>node_modules/@nestjs/cli/bin/nest.js'
```

En remplaçant `/<absolute_path/>node_modules/@nestjs/cli/bin/nest.js` par le path correct (la commande `pwd` peut vous aider).

Vous n'avez pas besoin de lancer la commande `nest new fr-administration`.

#### Explications:

La commande `npm i -g @nestjs/cli` ajoute l'interface de ligne de commandes (**cli**: Command Line Interface) `nest` à votre terminal.
Lorsque vous clonez le projet `nestjs/typescript-starter.git`, celui-ci a la dépendance à la **cli** `nest` et donc lorsque vous lancez `npm install`, vous téléchargez la **cli** pour votre projet.

De ce fait, vous obtenez la **cli** `nest` "localement" à votre projet, c'est pour cela qu'on utilise : `node node_modules/@nestjs/cli/bin/nest.js`.

Finalement, en utilisant un alias, vous obtenez une commande `nest` tout comme vous l'aurez obtenu avec 
`npm i -g @nestjs/cli`, modulo le fait que si vous supprimez votre projet, et donc ses dépendances, vous n'aurez plus la **cli** `nest`.

## Lancement et test

Une fois installé, vous pouvez lancer votre backend avec les commandes suivantes :

```shell
cd fr-administration
npm run start
```

Pour tester, ouvrez un second terminal et lancer la commande suivante :

```shell
curl http://localhost:3000
```

Quand aucune méthode HTTP n'est spécifiée, `curl` utilise la méthode HTTP `GET` par défaut.
Cette commande va donc faire une requête `GET`, sur l'url `http://localhost`, sur le port `3000`. C'est à cette adresse et sur ce port que le backend `NestJS` tourne par défaut.

Vous devriez observer sur la console le message suivant :

```shell
$ curl http://localhost:3000 
Hello World!%
```

## Description du projet

### `package.json`

Situé à la racine du projet, ce fichier permet de spécifier les dépendences et des routines que vous souhaitez lancer sur votre backend. 
On peut voir le `package.json` comme le `pom.xml` d'un projet maven, pour un projet NestJS (en fait, pour un projet NodeJS mais c'est un détail).

Par exemple, lorsque nous avons lancé la commande `npm run start`, cette commande exécute la commande `nest start`. Cette correspondance est définie dans le fichier `package.json`, plus particulièrement dans l'élément `scripts`:

```json
"scripts": {
    ...
    "start": "nest start",
    ...
},
```

Vous pouvez étudier ce fichier et essayer les divers commandes pre-configurées. De même, le fichier `package.json` décrit toutes les dépendences et les versions de ces dépendences.


### `src/main.ts`

Le fichier `src/main.ts` est le "main" du backend, c'est-à-dire, c'est ce fichier qui lance le backend.

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000);
}
bootstrap();
```

### Modules

Dans un projet `NestJS`, le code est divisé en "modules", qui peuvent être vu comme des packages (au sens Java).
Usuellement, un module a une certaine responsabilité métier et contient toutes les "couches" (controlleur, service et repository) de l'application concernant cette responsabilité métier.

Dans le squelette généré par `NestJS`, on a :

```
src
├── app.controller.spec.ts // fichier de test du controller app
├── app.controller.ts // controller app
├── app.module.ts // module app
├── app.service.ts // service ou providers app
└── main.ts
```

Ce squelette est voué à disparaître, mis à part le fichier `app.module.ts`, qui va aggréger tous nos modules, il servira de "module root", ainsi que le fichier `main.ts` qui servira à lancer notre backend.

Vous remarquerez qu'avec `NestJS`, il y a une convention de nommage de fichier : `<business>.<layer>.ts`, ou `<business>` dénote la responsabilité métier et `<layer>` dénote la couche, _e.g._ `controller` ou `service`.

## Création d'un premier module

Pour générer un nouveau module, il suffit d'utiliser la ligne de commande suivante :

```shell
$ nest g module users
CREATE src/users/users.module.ts (82 bytes)
UPDATE src/app.module.ts (312 bytes)
```

Avec cette commande, on voit que `nest` a créé un nouveau repertoire : `src/users`, et y a inséré un nouveau fichier `users.module.ts` qui définit le module qui sera responsable des utilisateurs.
`nest` a également mis à jours le fichier `src/app.module.ts`, notre "module root" pour y importer le nouveau module créé :

```diff
@Module({
- imports: [],
+ imports: [UsersModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

## Un mot sur Typescript

La syntaxe et le paradigme de programmation de `Typescript` sont à la croisée de ceux de `Javascript` et de `Java`.

L'IDE à utiliser est [VisualCode Studio](https://code.visualstudio.com/). Une fois installé, vous pouvez le lancer depuis un terminal en vous plaçant dans le repertoire de votre projet et en tapant la commande : 


```shell
code .
``` 

# Premiers pas avec NestJS

## Installation

Pour installer `NestJS`, vous pouvez utiliser la ligne de commande suivante : 

```shell
npm i -g @nestjs/cli
```

Il se peut que vous devez avoir les droits d'administration.
Avec cette commande, vous avez à disposition un ensemble de commandes qui permet de générer du code pour votre backend `NestJS`

## Création de projet

Pour générer un squelette de projet `NestJS`, il suffit d'utiliser la ligne de commande suivante :

```shell
nest new fr-administration
```

Choisissez `npm` comme `package manager`.

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

Cette commande va faire une requête `GET`, sur l'url `http://localhost`, sur le port `3000`. C'est à cette adresse et sur ce port que le backend `NestJS` tourne par défaut.

Vous devriez observer sur la console le message suivant :

```shell
$ curl http://localhost:3000 
Hello World!%
```

## Description du projet

### `package.json`

Situé à la racine du projet, ce fichier permet de spécifier les dépendences et des routines que vous souhaitez lancer sur votre backend.

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

Ce squelette est vouée à disparaître, mis à part le fichier `app.module.ts`, qui va aggréger tous nos modules, il servira de "module root", ainsi que le fichier `main.ts` qui servira à lancer notre backend.

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

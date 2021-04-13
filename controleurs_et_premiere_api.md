# Contrôleurs et première API

## Premier contrôleur

Ici, l'objectif est de créer une couche "contrôleur" pour notre module `users` précédemment généré.

Générer le squelette du contrôleur avec la commande suivante :

```shell
$ nest g controller users
CREATE src/users/users.controller.spec.ts (485 bytes)
CREATE src/users/users.controller.ts (99 bytes)
UPDATE src/users/users.module.ts (170 bytes)
```

Dans `src/users/users.controller.ts`, on a :

```typescript
@Controller('users')
export class UsersController {}
```

Ici, le "decorator" `@Controller('users')` (on peut voir ça comme une annotation à la Java) spécifie que la classe
`UsersController` est un contrôleur.
Il va permettre de gérer les requêtes faites par un client.

## Premier endpoint

Pour définir un "endpoint", c'est-à-dire, une URL qui permet d'accéder aux resources du serveur, on utilise aussi des 
décorateurs, mais cette fois-ci sur les méthodes de la class `UsersController`.

Ajoutez la méthode suivante à `UsersController` :

```typescript
import { ..., Get, ... } from '@nestjs/common';
...
@Get()
getAll(): string[] {
    return ['a', 'b', 'c'];
}
```

Ici, on a une méthode appelée `getAll`, qui return un tableau de string : `string[]`.

Le décorateur `Get()` spécifie quelle méthode de requête, au sens HTTP, cette méthode gère.
Il existe des décorateurs pour chacune des méthodes de requêtes : `Get`, `Post`, `Put`, `Delete`, etc.

Lancer le serveur avec `npm run start` et lancer une requête `GET` sur le nouveau endpoint avec la commande suivante :

```shell
$ curl http://localhost:3000/users 
["a","b","c"]%
```

Comme le décorateur `Get()` n'a pas de paramètre, cette méthode gère les requêtes `GET` sur l'URL 
`http://localhost:3000/users`, ou `users` est l'endpoint "général" du controller, spécifié avec le décorateur `@Controller('users')`

Modifiez la méthode `getAll()` :

```diff
- @Get()
+ @Get('all')
getAll(): string[] {
    return ['a', 'b', 'c'];
}
```

Et testez les deux requêtes suivantes après avoir relancé le serveur :

```shell
$ curl http://localhost:3000/users
{"statusCode":404,"message":"Cannot GET /users","error":"Not Found"}%
$ curl http://localhost:3000/users/all
["a","b","c"]%
```

### Astuce

Lancer votre serveur avec `npm run start:dev` et `Nest` recompilera et relancera votre serveur à chaque modification.

## User Model

Nous allons créer un modèle d'utilisateur. Pour cela, créez un nouveau fichier dans le module `users`, et nommez-le 
`user.entity.ts`.

Dans ce fichier, on va déclarer une nouvelle classe qui répond au besoin ci-dessous :

| User |
|------|
| id: number |
| lastname: string |
| firstname: string |


Déclarer un tableau d'utilisateurs en constante dans le fichier `UsersController` :

```typescript
import { User } from './user.entity';

const users : User[] = [
    {
        id: 0,
        lastname: 'Doe',
        firstname: 'John'
    }
]
@Controller('users')
export class UsersController {
    ...
}
```

Votre modèle de `User` doit répondre parfaitement à cette définition. Ainsi, votre backend peut automatiquement 
transformer les données (qui sont en format `JSON` ici) en des objets d'instance `User`.

Ici, on initialise le tableau `users` avec un utilisateur dont l'id est égal à zéro avec pour nom "Doe" et prénom "John".

## CRUD

Maintenant que vous avez un modèle d'utilisateur, implémenter toutes les méthodes `CRUD` (**C**reate, **R**etrieve, 
**U**pdate, **D**elete) des utilisateurs dans `UsersController`.

Il s'agit de manipuler le tableau précédemment déclaré comme s'il s'agissait de votre base de données.

Regarder la section [Tests](https://hackmd.io/@nMppG5vYSi6CqfaB-nrZ5w/SkWcB2Xhw#Tests) où un script cURL est fourni 
pour vous aider à tester votre backend.

### Création

Pour la création, il faut implémenter un nouvel `endpoint` qui supporte la méthode `POST`, en vertu des bonnes pratiques
`REST`.
Pour cela, il faut utiliser le décorateur `@Post()`

Ce nouvel `endpoint` a aussi besoin de données d'entrée (input), qui sont les informations du nouvel utilisateur.
Pour cela, il faut ajouter un paramètre de la méthode qui va supporter ce `endpoint`.
Sur ce paramètre, on utilise le décorateur `@Body()` pour spécifier que le paramètre aura les valeurs du "body" de ma 
requête.

Cela donnera quelque chose comme :

```typescript
import { ..., Body, Post, ... } from '@nestjs/common';
...
@Post()
create(@Body() input: any): User {
    ...
}
```
À vous de compléter le corps de la méthode.

`any` est de "n'importe quel" type, et peut-être manipulé comme du `JSON`.

Si `input = { id: '0', lastname: 'Doe', firstname: 'John' }` alors `input.id` permet d'accéder à la valeur `id` du JSON.

Pour la création, c'est le backend qui gère les ids.

### Récupération des données

Pour la récupération des données, on souhaite supporter **au moins** deux ces deux requêtes :

```shell
GET http://localhost/users
GET http://localhost/users/<id>
# Par exemple
GET http://localhost/users/0
# Doit me retourner l'utilisateur avec l'id 0, c'est-à-dire John Doe.
```

Le premier endpoints est plutôt immédiat.
Le second nécessite l'implémentation du support d'une nouvelle URL, paramétrée, ici par l'id.

Pour ce faire, on utilise un string spécial dans le décorateur `Get()` ainsi qu'un paramètre, avec le décorateur `@Param()`.

Dans notre cas, on utilisera quelque chose comme cela :

```typescript
import { ..., Param, ... } from '@nestjs/common';
...
@Get(':id')
getById(@Param() parameter): User {
    ...
}
```

Ici, on paramétrise l'url avec `:id` dans le décorateur `@Get`. Aussi, le paramètre de la méthode `@Param() parameter`
nous permet de récupérer cette valeur en faisant `parameter.id`.

À vous d'implémenter le corps de la méthode, qui doit retourner l'utilisateur qui a pour `id`, l'id passé en paramètre.

Regarder de ce [côté](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array) pour 
trouver une api qui facilitera l'implémentation.

### Mise à jour

La mise à jour mixera les notions vues pour la création et la récupération.
On implémentera la méthode qui supporte les requêtes `PUT` sur l'URL `http://localhost:3000/users/<id>`, et qui prend en
paramètre les informations de mise à jour.

### Deletion

Pour la suppression, on utilisera des requêtes de méthode `DELETE`.
Pour supprimer un élément d'un tableau en TypeScript, regardez du côté de 
[Array.prototype.splice()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice).

Utiliser la fonction `delete users[id]` remplace la valeur par `undefined`, et ne retire pas complétement l'élément du 
tableau.

### Traitement des erreurs

Pour traiter les erreurs, par exemple lorsqu'il n'existe pas d'utilisateur qui a l'id fourni par le client, alors le serveur doit répondre avec un code d'erreur HTTP approprié : 404.

Pour implémenter cela vous pouvez utiliser :

```typescript
if (something()) {
	throw new HttpException('message', HTTP_STATUS);
}
```
Où il faut remplacer `HTTP_STATUS` par un attribut de la classe `Http_Status`. Par exemple, pour un 404 Not found, on va faire :

```typescript
throw new HttpException(`Could not find a user with the id ${parameter.id}`, HttpStatus.NOT_FOUND)
```

## Tests

Une fois que vous avez implémenté toutes les méthodes, et que votre backend supporte tous les `endpoints` décrits 
ci-dessus, vous pouvez le tester avec ce [script de test](./scripts/controleurs_et_premiere_api_test.sh).

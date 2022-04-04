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

```diff
-import { Controller } from '@nestjs/common';
+import { Controller, Get } from '@nestjs/common';

@Controller('users')
export class UsersController {

+    @Get()
+    getAll(): string[] {
+        return ['a', 'b', 'c'];
+    }

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
`http://localhost:3000/users`, où `users` est l'endpoint "général" du controller, spécifié avec le décorateur `@Controller('users')`

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

Comme nous avons modifié le décorateur de la méthode `getAll()`, de `Get()` à `Get('all')`, l'endpoint gérer par notre méthode `getAll()` est `http://localhost:3000/users/all` et non plus `http://localhost:3000/users`, d'où le `404 Not Found` retourné.

En fait, l'endpoint géré par une méthode avec un décorateur de méthode HTTP (`Get()`, `Post()`, etc.) est la concaténation de l'endpoint général du contrôleur, dans notre cas `'users'` car nous avons `@Controller('users')`, et de l'endpoint spécifié par le décorateur de la méthode, dans notre cas `'all'` car nous avons `Get('all')`. Dans le cas où le décorateur de méthode ne spécifie pas d'endpoint, alors méthode gérera l'endpoint générale du contrôleur.

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

Il s'agit de manipuler le tableau précédemment déclaré comme s'il s'agissait de votre base de données. Dans la suite du projet, nous remplacerons ce tableau par une véritable base de données.

## CRUD

Maintenant que vous avez un modèle d'utilisateur, implémenter toutes les méthodes `CRUD` (**C**reate, **R**etrieve, 
**U**pdate, **D**elete) des utilisateurs dans `UsersController`.

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
À vous de compléter le corps de la méthode. Cette méthode doit :
* créer une nouvelle instance de `User` (la syntaxe "à la Java" fonctionne : `new User(param1, param2)`)
* ajouter cette nouvelle instance à notre "base de données", qui est le tableau de `User`, _i.e._ `const users : User[]`, les tableaux en typescript peuvent être vus comme des `List` en Java, et la fonction `push` permet d'ajouter un élément (_.e.g_ `users.push(newUser)`)
* retourner cette nouvelle instance au client

`any` est de "n'importe quel" type, et est manipulé comme du `JSON`.

Si `input = { id: '0', lastname: 'Doe', firstname: 'John' }` alors `input.id` permet d'accéder à la valeur `id` du JSON.

Pour la création, c'est le backend qui gère les ids.

Voici une commande CURL qui peut vous servir à tester votre implémentation :

```sh
$ curl -X POST -d 'firstname=Jane&lastname=Doe' http://localhost:3000/users/
{"id":1,"firstname":"Jane","lastname":"Doe"}
```

Faites attention, si vous modifiez l'état de votre tableau `users`, il se peut que les résultats des requêtes soient differents.
Dans le doute, relancer manuellement votre backend, et votre tableau `users` sera de nouveau initialisé uniquement avec l'élement par défaut, _i.e._

```typescript
 {
    id: 0,
    lastname: 'Doe',
    firstname: 'John'
}
```

### Récupération des données

Pour la récupération des données, on souhaite supporter **au moins** deux ces deux requêtes :

1. `GET http://localhost:3000/users` => renvoie toutes les utilisateurs, _i.e._ le tableau `users`.
2. `GET http://localhost:3000/users/:id` => ou :id doit être remplacé par un nombre représentant l'id de l'utilisateur qu'on souhaite récupérer.
Par exemple, si je souhaite récupérer l'élement par défaut de mon tableau `users`, je ferais :
GET http://localhost/users/0, et le retour devrait être `{id: 0, lastname: Doe, firstname: John}`.

Le premier endpoint est plutôt immédiat. Inspirez-vous des endpoints qui ont été faites à la section au-dessus "Premier endpoint".

Voici une commande CURL pour tester si votre backend supporte bien l'endpoint http://localhost/users : 

```sh
$ curl http://localhost:3000/users
[{"id":0,"lastname":"Doe","firstname":"John"}]
```

Vous noterez la présence des brackets [] qui signifie qu'il s'agit d'un tableau.


Le second endpoint pourrait être qualifié de "dynamique", c'est-à-dire qu'il s'agit ici d'un modèle d'endpoint, où on a dans l'endpoint un paramètre : l'`id`.

Pour ce faire, on utilise un string spécial dans le décorateur `Get()` ainsi qu'un paramètre, avec le décorateur `@Param()`.

Dans notre cas, on utilisera l'endpoint de méthode `:id`. Cela donnera quelque chose comme cela :

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
trouver une api qui facilitera l'implémentation, en particulier la fonction `filter()`.

Vous allez peut-être devoir "caster" vos variables et vos paramètres pour les comparer.
En typescript, il suffit d'écrire le symbole `+` devant une variable pour la caster en entier, utilisé l'opérateur `===` pour comparer les valeurs.
Ici, il s'agit de retrouver l'élément du tableau `users` qui a son champ `id` égal à celui passer en paramètre, _i.e._ `parameter.id`.

Voici une commande CURL pour tester si votre backend supporte bien l'endpoint http://localhost/users/:id : 

```sh
$ curl http://localhost:3000/users/0
{"id":0,"lastname":"Doe","firstname":"John"}
```

Vous noterez l'absence des brackets [] qui signifie qu'il s'agit d'un seul élément et non pas d'un tableau.

#### Digression sur les endpoints dynamiques

On peut utiliser ce genre de paramètre autant que l'on souhaite. Par exemple, je peux supporter l'url suivante : `users/0/api/John/` grâce au décorateur suivant : `@Get(':id/api/:lastname)` (en rappelant que le `users` vient de l'endpoint général du contrôleur). Pour récupérer les valeurs, on utilise toujours le paramètre décoré avec `@Param()`. 
Pour conlure, voici un exemple complet : 

```typescript
@Get(':id/api/:lastname')
cetteMéthodeNeDoitPasÊtreImplémentée(@Param() parameter): void {
    console.log(parameter.id);
    console.log(parameter.lastname);
}
```

En faisant `curl http://localhost:3000/users/0/api/John`, j'aurais sur la console du serveur :
```txt
0
John
```

Cette dernière méthode N'est PAS à ajouter à votre serveur. Elle sert d'exemple pour expliquer les endpoints dynamiques.

### Mise à jour

La mise à jour mixera les notions vues pour la création et la récupération.
On implémentera la méthode qui supporte les requêtes `PUT` sur l'URL `http://localhost:3000/users/:id`, et qui prend en
paramètre les informations de mise à jour, _i.e._ le nom et le prénom.
Vous aurez donc besoin à la fois d'un `@Param() parameter` pour récupérer l'id de l'endpoint dynamique et le `@Body() input` pour
récupérer les nouvelles valeurs du nom et du prénom.

Vous ne mettrez à jour les champs de l'élement `user`, _i.e._ `firstname` et `lastname`, que si ceux-ci sont passés en paramètre.
Pour cela, vérifiez avant la mise à jour, que la valeur n'est pas égale à `undefined`, _e.g._ `input.firstname !== undefined`.

Voici une commande CURL pour tester si votre backend supporte bien les requêtes PUT sur l'endpoint http://localhost/users/:id :

```sh
$ curl -X PUT -d 'firstname=Jane' http://localhost:3000/users/0
{"id":0,"lastname":"Doe","firstname":"Jane"}
```

### Deletion

Pour la suppression, on utilisera des requêtes de méthode `DELETE` sur l'URL `http://localhost:3000/users/:id`. Cette méthode supprime l'utilisateur avec l'id passé dans l'url.
Pour la valeur retournée, on pourrait retourner un booléen pour spécifier que la suppression s'est bien passée, ou non.
Pour supprimer un élément d'un tableau en TypeScript, regardez du côté de 
[Array.prototype.splice()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice).

Il **NE** faut **PAS** utiliser la fonction `delete`, par exemple en faisant `delete users[id]`. La fonction `delete` remplace la valeur par `undefined`, et ne retire pas complétement l'élément du tableau.

Voici une commande CURL pour tester si votre backend supporte bien les requêtes DELETE sur l'endpoint http://localhost/users/:id : 

```sh
$ curl -X DELETE http://localhost:3000/users/0
```

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

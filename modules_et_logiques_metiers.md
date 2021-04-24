# Modules et logique métier

## Introduction

Comme énoncé précédemment, chaque module a une et une seule responsabilité métier.
Par exemple, le `users.module` est responsable de tous les utilisateurs, tandis que le `associations.module` est 
responsable des associations.

Cependant, pour compléter leurs tâches, les modules doivent parfois (souvent en fait) travailler ensemble.

Dans l'étape précédente, nous avons vu comment développer le "front du backend", c'est-à-dire la couche `controller`.
Pour rappel, cette couche est responsable de gérer les requêtes HTTP faites par les clients ainsi que de déclarer tous 
les `endpoints` dont on a besoin.

### Bonnes pratiques

On ne met donc pas la logique métier dans cette couche. On utilise une nouvelle couche, qui est la couche 
`services` qui va contenir tous les algorithmes pour implémenter notre logique métier.

Les `controllers` vont donc appeler des méthodes des `services` pour effectuer les traitements, obtenir un résultat et le
renvoyer aux clients.

Pour que les modules travaillent ensemble, on passe par la couche `services`, c'est-à-dire que c'est les services qui 
vont s'appeler entre eux, quand il y a besoin.

Le `users.controller` utilise uniquement le `service.services`. Dans le cas où le traitement demandé 
par le client (par sa requête) nécessite l'intervention d'un autre `service`, _e.g._ le `associations.service`, c'est 
le `users.service` qui va appeler le `associations.service`, et non pas le `users.controller`, même si la requête est gérer par le `users.controller`.

## Plan

Dans cette partie du projet nous allons effectuer les étapes suivantes :

1. Générer un service utilisateur;
2. Déplacer la "base de données" (le tableau `users`) du contrôleur vers le service car c'est le service qui gère la logique;
3. Déplacer toutes la logique: création, récupération, mise à jour et suppression du contrôleur vers le service;
4. Mettre à jours le contrôleur pour qu'il appel les bonnes méthodes du service.
Pour résumer les deux derniers points, on a :
`users.controller.ts`:
```diff
...
@Post()
create(@Body() input: any): User {
-   // le code que vous avez implémenté lors de l'étape précèdente
+   this.service.create(input.firstname, input.lastname)
    return user;
}
```
et dans le `users.service.ts`:
```diff
...
+create(firstname: string, lastname: string): User {
+   // le code que vous avez implémenté lors de l'étape précèdente
+    return user;
+}
...
```

5. Nous générerons ensuite un nouveau module : le module des associations. De la même manière, vous devrez y developpé:
* Un modèle d'association;
* Un Contrôleur qui gérera toutes les requêtes CRUD, et délèguera la logique au service des associations;
* Un Service qui implémentera la logique;
6. Finalement, nous verrons comment faire travailler ensemble les services `users` et `associations`, afin de fournir une nouvelle API permettant de calculer l'âge moyen des membres (utilisateurs) d'une associations. Cette requête sera faire sur une endpoints définies par le contrôleur associations, qui délèguera la logique de calcul au service associations. Le service associations aura alors besoin du servicer users pour ce calcul.

## Génération d'un service `users`

On peut générer un service `users` en utilisant la ligne de commande suivante :

```shell
$ nest g service users
CREATE src/users/users.service.spec.ts (453 bytes)
CREATE src/users/users.service.ts (89 bytes)
UPDATE src/users/users.module.ts (247 bytes)
```

Cette commande génère deux nouveaux fichiers : `users.service.ts`, le service, et `users.service.spec.ts` son fichier de
test.  Aussi, cette commande ajoute aux `providers` le nouveau service créé.

### Code généré du service

```typescript
@Injectable()
export class UsersService {}
```

Dans cette classe, le décorateur `Injectable()` permet à NestJS d'injecter le service dans un autre afin qu'ils puissent
travailler ensemble.

Nous verrons dans la suite, un exemple d'injection.

## Première implémentation de logique métier

Tout d'abord, ajoutez à la définition d'`User` un attribut `age`, de type `number`: 

```typescript
public age: number;
```

Déplacez le tableau d'utilisateurs `const users: User[]` déclaré dans le `users.controller` vers le `users.service` et 
ajoutez l'âge de John Doe, il a 23 ans :

```typescript
{
        id: 0,
        lastname: 'Doe',
        firstname: 'John',
        age: 23
}
```

Vous devez maintenant mettre à jour toutes les fonctions du `controller` pour que la logique soit implémentée dans le `service`.

Le `controller` va appeler le `service` pour réaliser les traitements en fonction des requêtes des clients. 
Pour cela, il a besoin d'une instance de service.

C'est là que le décorateur `@Intejectable()` prend tout son sens : on peut simplement déclarer un nouvel attribut dans le constructeur du `controller`, et `NestJS` s'occupe de tout, c'est-à-dire que `NestJS` instanciera lui-même le service, et l'injectera au moment de la création du contrôleur. Voici ce à quoi resemble le constructeur du  `controller` des utilisateurs :

```typescript
constructor(
    private service: UsersService
) {}
```

Dans le `controller`, vous pouvez faire appel aux méthodes du `service` avec `this.service.myMethod(myParameter);`.

Une fois le `controller` et le `service` mis à jours, implémenté une méthode, dans le `users.service`, qui prend entrée un tableau 
d'id(`ids: number[]`), et qui calcul la moyenne d'âge des utilisateurs désignés par ces ids. La signature est comme qui 
suit :

```typescript
public getAgeAverageById(ids: number[]) : number {
    ...
}
```

Les fonctions [`filter`](https://www.tutorialspoint.com/typescript/typescript_array_filter.htm) et 
[`reduce`](https://www.tutorialspoint.com/typescript/typescript_array_reduce.htm) peuvent être utiles.

Par la même occasion, vous pouvez ajouter un nouvel endpoints dans votre `users.controller` pour pouvoir appeler cette méthode avec une requête GET.

## Module, Controlleur et Service Association

Générez un module, un contrôleur et un service `associations` (par conventions, les modules, contrôleurs, services, etc. 
sont toujours au pluriel).

Dans le `service`, déclarez un tableau d'associations : `const associations: Association[]` et remplissez-le avec au 
moins une association.

Implémentez, de la même manière que pour les utilisateurs, les opérations CRUD des associations définies comme suit :

| Association |
| --- |
| id: number |
| idUsers: number[] |
| name: string |

Dans le `service`, déclarez un tableau d'associations : `const associations: Association[]` et remplissez-le avec au 
moins une association.

Implémentez, de la même manière pour que les utilisateurs, les opérations CRUD pour les associations.

## Faire travailler les services ensemble

Comme dit plus haut, on fait travailler ensemble les modules au niveau de la couche "services".

Pour ce faire, les services sont "injectables" dans `NestJS`. C'est-à-dire créer ou récupérer dynamiquement des objets 
pour satisfaire des dépendances (plus d'info [ici](https://fr.wikipedia.org/wiki/Injection_de_d%C3%A9pendances)).

Lorsqu'on génère un `service` avec `NestJS`, il est par défaut injectable. Pour l'injecter dans un autre service il 
suffit d'appliquer la même méthode que pour les contrôleurs :

`associations.service.ts`:
```typescript
constructor(
    private service: UsersService
) {}
```

Cependant, comme le `service` provient d'un autre module, il faut explicitement exporter ce `service` depuis son module.

Modifiez `users.module.ts` comme qui suit :

```diff
    providers: [UsersService],
+   exports: [UsersService]
```
et importer le module `users` dans le module `association` : 

`associations.module.ts` :
```diff
    providers: [AssociationsService],
+   imports: [UsersService]
```

Une fois l'injection faite, implémentez la méthode suivante dans le `associations.service`, qui renvoie la moyenne d'âge
des utilisateurs (désignées par leur `id`) d'une association donnée, désignée elle-même par son `id` :

`associations.service.ts` :
```typescript
public getAgeAverageById(id: number): number {
    // TODO
}
```

Cette méthode doit s'appuyer sur la méthode du `service` user.

Mettez également à jour le `association.controller` afin d'offrir une API aux clients pour qu'ils puissent récupérer ces
informations.

## Tests

De même, vous pouvez tester votre backend avec ce [script cURL](scripts/modules_et_logiques_metiers_test.sh).

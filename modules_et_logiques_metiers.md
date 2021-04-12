# Modules et logique métier

## Introduction

Comme énoncé précédemment, chaque module a une et une seule responsabilité métier.
Par exemple, le module `users` est responsable de tous les utilisateurs, tandis que le module `associations` est 
responsable des associations.

Cependant, pour compléter leurs tâches, les modules doivent parfois (souvent en fait) travailler ensemble.

Dans l'étape précédente, nous avons vu comment développer le "front du backend", c'est-à-dire la couche `controller`.
Pour rappel, cette couche est responsable de gérer les requêtes HTTP faites par les clients ainsi que de déclarer tous 
les `endpoints` dont on a besoin.

### Bonnes pratiques

Logiquement, on ne met donc pas la logique métier dans cette couche. On utilise une nouvelle couche, qui est la couche 
`services` qui va contenir tous les algorithmes pour implémenter notre logique métier.

Les `controllers` vont donc appeler des méthodes des `services` pour effectuer les traitements, obtenir un résultat et le
renvoyer aux clients.

Pour que les modules travaillent ensemble, on passe par la couche `services`, c'est-à-dire que c'est les services qui 
vont s'appeler entre eux, quand il y a besoin.

Le `controller` des utilisateurs utilise uniquement le `service` des utilisateurs. Dans le cas où le traitement demandé 
par le client (par sa requête) nécessite l'intervention d'un autre `service`, _e.g._ le service des associations, c'est 
le `service` des utilisateurs users qui va appeler le `service` des associations, et non pas le `controller`.

## Génération d'un service `users`

Tout comme le reste, on peut générer un service `users` en utilisant la ligne de commande suivante :

```shell
$ nest g service users
CREATE src/users/users.service.spec.ts (453 bytes)
CREATE src/users/users.service.ts (89 bytes)
UPDATE src/users/users.module.ts (247 bytes)
```

Cette commande génére deux nouveaux fichiers : `users.service.ts`, le service, et `users.service.spec.ts` son fichier de
test.  Aussi, cette commande ajoute aux `providers` le nouveau service crée.

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

Vous devez maintenant mettre à jours toutes les fonctions du `controller` pour que la logiques soit implémentée dans le `service`.

Le `controller` va maintenant appeler le `service` pour réaliser les traitements en fonction des requêtes des clients. Pour cela, il a besoin d'une instance de service.

C'est là que le décorateur `@Intejectable()` prend tout son sens : on peut simplement déclarer un nouvel attribut dans le constructeur du `controller`, et `NestJS` s'occupe de tout. Voici le ce à quoi resemble le constructor du  `controller` des utilisateurs :

```typescript
constructor(
    private service: UsersService
) {}
```

Dans le `controller`, vous pouvez faire appel aux méthodes du `service` avec `this.service.myMethod(myParameter);`.

Une fois le `controller` et le `service` mis à jours, implémenté une méthode qui prend entrée un tableau 
d'id(`ids: number[]`), et qui calcul la moyenne d'âge des utilisateurs désignés par ces ids. La signature est comme qui 
suit :

```typescript
public getAgeAverageById(ids: number[]) : number {
    ...
}
```

Les fonctions [`filter`](https://www.tutorialspoint.com/typescript/typescript_array_filter.htm) et 
[`reduce`](https://www.tutorialspoint.com/typescript/typescript_array_reduce.htm) peuvent être utiles.

## Module, Controlleur et Service Association

Généré un module, un contrôleur et un service `associations` (par conventions, les modules, contrôleurs, services, etc. 
sont toujours au pluriel).

Dans le `service`, déclarez un tableau d'associations : `const associations: Association[]` et remplissez-le avec au 
moins une association.

Implémentez, de la même manière pour que les utilisateurs, les opérations CRUD des associations définit comme qui suit :

| Association |
| --- |
| id: number |
| idUsers: number[] |
| name: string |

## Faire travailler les services ensemble

Comme dit plus haut, on fait travailler ensemble les modules au niveau de la couche "services".

Pour ce faire, les services sont "injectables" dans `NestJS`. C'est-à-dire créer ou récupérer dynamiquement des objets 
pour satisfaire des dépendances (plus d'info [ici](https://fr.wikipedia.org/wiki/Injection_de_d%C3%A9pendances)).

Lorsqu'on génère un `service` avec `NestJS`, il est par défaut injectable. Pour l'injecter dans un autre service il 
suffit d'appliquer la même méthode que pour les contrôleurs :

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

Une fois l'injection faite, implémentez la méthode suivante dans le `service` associations, qui renvoie la moyenne d'âge
des personnes (désignées par leur `id`) d'une association donnée, désignée par son `id` :

```typescript
public getAgeAverageById(id: number): number
```

Cette méthode doit s'appuyer sur la méthode du `service` user.

Mettez également à jour les `controllers` afin d'offrir une API aux clients pour qu'ils puissent récupérer ces
informations.

## Tests

De même, vous pouvez tester votre backend avec ce [script cURL](scripts/modules_et_logiques_metiers_test.sh).

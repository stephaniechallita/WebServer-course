# Tester son backend NestJS

Les tests automatisés permettent de vérifier le bon comportement du programme. Dans cette partie, nous nous attarderons 
sur les tests unitaires des contrôleurs d'un backend NestJS. Cependant, la logique est la même pour les services.

## Démarrage

Pour tester votre backend, il faut d'abord installer les bons modules :

```shell
npm i --save-dev @nestjs/testing
```

Nous utiliserons le framework de test [jest](https://github.com/facebook/jest) qui est celui utilisé par défaut dans 
NestJS.

## Premier test du contrôleur des `users`

Si vous avez suivi les parties précédentes, NestJS génère automatiquement le fichier de tests lorsque vous utilisez la
commande `nest g co users`, et celui-ci s'appellera `users.controller.spec.ts` :

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';

describe('UsersController', () => {
  let controller: UsersController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
    }).compile();

    controller = module.get<UsersController>(UsersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Le test d'un backend est un peu fastidieux et délicat à cause des différentes injections qui sont faites, sur de 
multiples-couches (contrôleurs, services, repositories). Nous allons tester cette partie du backend car elle est la plus
"simple", d'un point de vue des injections des differents services/repositories.

Tout d'abord, notre contrôleur a besoin d'un service. Une bonne pratique de test est de faire unitairement, c'est-à-dire,
séparer les tests des différents composants (ou faire de gros tests d'intégration, mais ici on s'attardera sur les tests 
unitaires). De fait, il ne faut pas reposer les tests du contrôleur sur l'implémentation des services car si un bug 
réside dans les services, les tests du contrôleur risquent d'échouer et le temps de débuggage s'allonger.

Pour cela, nous allons "*mocker*", c'est-à-dire utiliser de fausses et artificielles implémentations pour remplir le rôle 
des services et des repositories.

Lancez la commande suivante : `npm run test users.controller` vous devriez observer une erreur, comme : 
> Nest can't resolve dependencies of the UsersController (?). Please make sure that the argument UsersService at index [0] is available in the RootTestModule context.

Pour résoudre ce problème, faites les modifications suivantes dans votre fichier de test :

```diff
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
+import { UsersService } from './users.service';

describe('UsersController', () => {
  let controller: UsersController;
+  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
+      providers: [UsersService]
    }).compile();

+    service = module.get<UsersService>(UsersService);
    controller = module.get<UsersController>(UsersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Une fois fait, relancer la commande, et maintenant il manque le repository pour injecter le service :
> Nest can't resolve dependencies of the UsersService (?). Please make sure that the argument UserRepository at index [0] is available in the RootTestModule context.

Pour résoudre ce problème, on va mocker aussi le repository de la façon suivante : 

```diff
import { Test, TestingModule } from '@nestjs/testing';
+import { getRepositoryToken } from '@nestjs/typeorm';
+import { Repository } from 'typeorm';
+import { User } from './user.entity';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

+export type MockType<T> = {
+  [P in keyof T]?: jest.Mock<{}>;
+};

+export const repositoryMockFactory: () => MockType<Repository<any>> = jest.fn(() => ({
+  findOne: jest.fn(entity => entity),
+}));

describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        UsersService,
+        { provide: getRepositoryToken(User), useFactory: repositoryMockFactory}
      ]
    }).compile();

    service = module.get<UsersService>(UsersService);
    controller = module.get<UsersController>(UsersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Relancez la commande, et cela devrait passer.

Maintenant que cela fonctionne, attardons-nous un peu sur le test : 

```typescript
it('should be defined', () => {
    expect(controller).toBeDefined();
});
```

Ici, la méthode `it()` prend en paramètre un string, qui explicite ce que le test vérifie, et une fonction qui est le 
test.
Les méthodes `expect()` et `toBeXXX()` (il faut remplacer les `XXX` par quelque chose, comme ici `Defined`) permettent de faire l'assertion, c'est-à-dire : `expect(controller).toBeDefined()` 
veut dire "on s'attend que la variable `controller` soit définie."

Voici l'implémentation du test de l'API `getAll()` du contrôleur :

```typescript
  describe('getAll', () => {
    it('should return an array of users', async () => {
      const expected = Promise.all([{ 
          id: 0, 
          firstname: 'John',
          lastname: 'Doe',
          age: 23
      }]);
      jest.spyOn(service, 'getAll').mockImplementation(() => expected);
      expect(await controller.getAll()).toBe(await expected);
    });
  });
```

Quelques détails :

1. On déclare une valeur oracle (`expected`) qui sera comparée au retour de l'API que nous testons, _i.e._ `getAll()` 
   (ligne 3 à 8) ;
2. On utilise Jest pour mocker le service, c'est-à-dire que l'on crée une "fausse" implémentation de la méthode  
`getAll()` (du service cette fois-ci !) en la faisant simplement retourner la valeur `expected` (ligne 8) ;
3. Finalement, on appelle la méthode `getAll()` du contrôleur (la méthode que l'on veut tester), et on la compare à la 
   valeur oracle créée en 1 (ligne 10).

Noter que dans ce code, la fonction `it`, qui fournit un texte décrivant le contrat du test, a été enveloppée par une 
méthode `describe()`, qui elle fournit un nom pour le test. La méthode `describe()` n'est pas obligatoire, et vous pouvez
enchaîner les fonctions `it()` comme bon vous semble.

## Tester avec des paramètres

Nous allons maintenant nous attarder sur le test de l'endpoint `get`, implémenté par une méthode nommée `getById()`.
Contrairement à `getAll()`, celle-ci prend en entrée un paramètre, un entier désignant l'id du user.

Pour cela, rien de plus simple, il nous faut simplement mocker la méthode `get(id)` du service sous-jacent et 
préciser le paramètre lors de l'appel dans le `expect()` :

```typescript
 describe('getById', () => {
    it('should return a single user, with the provided id', async () => {
      const expected = await Promise.all([{ 
        /* TODO */
      }]);
      jest.spyOn(service, /* TODO */).mockImplementation(id => {
        return Promise.resolve(/* TODO */);
      });
      expect(await controller.getById({id: 0})).toBe(/* TODO */);
    })
  });
```

Attention, le test ci-dessous n'est pas complet mais donne une grande partie de ce qu'il faut faire ! Vous savez dès à 
présent tous les mécanismes pour tester tout votre backend.

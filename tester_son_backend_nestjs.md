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

## Premier test du contrôleur des `association-forms`

Si vous avez suivi les parties précédentes, NestJS génère automatiquement le fichier de tests lorsque vous utilisez la
commande `nest g co association-forms`, et celui-ci s'appellera `association-forms.controller.spec.ts` :

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { AssociationFormsController } from './association-forms.controller';

describe('AssociationFormsController', () => {
  let controller: AssociationFormsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssociationFormsController],
    }).compile();

    controller = module.get<AssociationFormsController>(AssociationFormsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Le test d'un backend est un peu fastidieux et délicat à cause des différentes injections qui sont faites, sur de 
multiples-couches (contrôleurs, services, repositories). Nous allons tester cette partie du backend car elle est la plus
"simple", d'un point de vue des injections des differents services/repository.

Tout d'abord, notre contrôleur a besoin d'un service. Une bonne pratique de test est de faire unitairement, c'est-à-dire,
séparer les tests des différents composants (ou faire de gros tests d'intégration, mais ici on s'attardera sur les tests 
unitaires). De fait, il ne faut pas reposer les tests du contrôleurs sur l'implémentation des services car si un bug 
réside dans les services, les tests du controleurs risquent d'échouer et le temps de débuggage s'allonger.

Pour cela, nous allons "*mocker*", c'est-à-dire utiliser de fausse et artificielle implémentation pour remplir le rôle 
des services et des repositories.

Lancez la commande suivante : `npm run test association-forms.controller` vous devriez observer une erreur, comme : 
> Nest can't resolve dependencies of the AssociationFormsController (?). Please make sure that the argument AssociationFormsService at index [0] is available in the RootTestModule context.

Pour résoudre ce problème, faites les modifications suivantes dans votre fichier de test :

```diff
import { Test, TestingModule } from '@nestjs/testing';
import { AssociationFormsController } from './association-forms.controller';
+ import { AssociationFormsService } from './association-forms.service';


describe('AssociationFormsController', () => {
  let controller: AssociationFormsController;
+  let service: AssociationFormsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssociationFormsController],
+      providers: [ AssociationFormsService,]
    }).compile();

+    service = module.get<AssociationFormsService>(AssociationFormsService);
    controller = module.get<AssociationFormsController>(AssociationFormsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Une fois fait, relancer la commande, et maintenant il manque le repository pour injecter le service :
> Nest can't resolve dependencies of the AssociationFormsService (?). Please make sure that the argument AssociationFormRepository at index [0] is available in the RootTestModule context.

Pour résoudre ce problème, on va mocker aussi le repository de la façon suivante : 

```diff
import { Test, TestingModule } from '@nestjs/testing';
+import { getRepositoryToken } from '@nestjs/typeorm';
+import { Repository } from 'typeorm';
+import { AssociationForm } from './association-form.entity';
import { AssociationFormsController } from './association-forms.controller';
import { AssociationFormsService } from './association-forms.service';

+export type MockType<T> = {
+  [P in keyof T]?: jest.Mock<{}>;
+};

+export const repositoryMockFactory: () => MockType<Repository<any>> = jest.fn(() => ({
+  findOne: jest.fn(entity => entity),
+}));

describe('AssociationFormsController', () => {
  let controller: AssociationFormsController;
  let service: AssociationFormsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AssociationFormsController],
      providers: [
        AssociationFormsService,
+        { provide: getRepositoryToken(AssociationForm), useFactory: repositoryMockFactory}
      ],
    }).compile();

    service = module.get<AssociationFormsService>(AssociationFormsService);
    controller = module.get<AssociationFormsController>(AssociationFormsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
```

Relancez la commande, et cela devrait passer. Maintenant que cela fonctionne, attardons-nous un peu sur le test : 

```typescript
it('should be defined', () => {
    expect(controller).toBeDefined();
});
```

Ici, la méthode `it()` prend en paramètre un string, qui explicite ce que le test vérifie, et une fonction qui est le 
test.
Les méthodes `expect()` et `toBeXXX()` permette de faire l'assertion, c'est-à-dire : `expect(controller).toBeDefined()` 
veut dire "on s'attend que la variable `controller` soit définie."

Voici l'implémentation du test de l'API `getAll` du contrôleur :

```typescript
describe('getAll', () => {
    it('should return an array of association forms', async () => {
      const expected = Promise.all([{ 
          id: 0, 
          financialValidation: false, 
          legalValidation: false 
      }]);
      jest.spyOn(service, 'getAll').mockImplementation(() => expected);
      expect(await controller.getAll()).toBe(await expected);
    });
});
```

Quelques détails :

1. On déclare une valeur oracle (`expected`) qui sera comparé au retour de l'API que nous testons, _i.e._ `getAll()` 
   (ligne 3 à 7) ;
2. On utilise Jest pour mocker le service, c'est-à-dire que l'on crée une "fausse" implémentation de la méthode 
   `getAll()` (du service cette fois-ci !) en la faisant simplement retourner la valeur `expected` (ligne 8) ;
3. Finalement, on appelle la méthode `getAll()` du contrôleur (la méthode que l'on veut tester), et on la compare à la 
   valeur oracle créée en 1 (ligne 9).

Noter que dans ce code, la fonction `it`, qui fournit un texte décrivant le contrat du test, a été enveloppée par une 
méthode `describe()`, qui elle fournit un nom pour le test. La méthode `describe()` n'est pas obligatoire, et vous pouvez
enchaîner les fonctions `it()` comme bon vous semble.

## Tester avec des paramètres

Nous allons maintenant nous attarder sur le test de l'endpoint `get`, implémenté par une méthode nommée `get()`.
Contrairement à `getAll()`, celle-ci prend en entrée un paramètre, un entier désignant l'id du procès verbal.

Pour cela, rien de plus simple, il nous faut simplement mocker la méthode `get(id)` du service sous-jacent et 
préciser le paramètre lors de l'appel dans le `expect()` :

```typescript
 describe('get', () => {
    it('should return a single association form, with the provided id', async () => {
      /** Omitted **/ 
      jest.spyOn(service, 'get').mockImplementation(id => {
        return Promise.resolve(expected[id]);
      });
      expect(await controller.get({id: 0})).toBe(/** To be done **/);
    })
  });
```

Attention, le test ci-dessous n'est pas complet mais donne une grande partie de ce qu'il faut faire ! Vous savez dès à 
présent tous les mécanismes pour tester tout votre backend.

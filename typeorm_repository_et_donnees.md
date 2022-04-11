# TypeORM, Repository et données

Une application web digne de ce nom utilise une base de données pour gérer et sauvegarder ses données, et non pas des 
tableaux codés en dur !

C'est pour cela, dans cette partie, nous allons mettre en place la base de données, et ainsi utiliser 
[TypeORM](https://typeorm.io/#/) qui est une bibliothèque d'"object relational mapping" (ORM) en TypeScript.

Pour la base de données, nous utiliserons [SQLite](https://www.sqlite.org/index.html) qui permet de gérer une base de 
données relationnelle "sans serveur", c'est-à-dire que la base de données sera un simple fichier. Cela permet d'avoir 
une base de données rapidement, légère et portable. Étant donné que nous n'avons pas de grand besoin pour notre 
application, SQLite remplira parfaitement son rôle.

Cependant, SQLite n'est pas le choix par défaut pour une application de production. Voici un petit comparatif des 
différentes bases de données relationnelles [ici](https://www.digitalocean.com/community/tutorials/sqlite-vs-mysql-vs-postgresql-a-comparison-of-relational-database-management-systems) (EN).

## Préparatifs

Nous allons commencer par installer les pré-requis pour la suite du projet.

### Installer SQLite

Premièrement, installer SQLite sur votre machine : voir la [doc](https://www.sqlite.org/download.html).

Si vous avez un Linux ([source](https://smallbusiness.chron.com/use-sqlite-ubuntu-46774.html)), tapez la commande 
suivante dans votre terminal :
```shell
sudo apt-get install sqlite3 libsqlite3-dev
```

Puis lancez la commande :
```shell
sqlite3 mydatabase.db
```

Une fois le prompt de `sqlite3` activé, tapez la commande suivante qui créera la base de données (avec le point !) :

```shell
.databases
```

Ceci créera une base de données dans le fichier `mydatabase.db`.

### Installer TypeORM avec NestJS

Pour installer TypeORM, tapez la commande suivante à la racine de votre projet :

```shell
npm install --save @nestjs/typeorm typeorm sqlite3
```

Puis importez dans votre `app.module.ts` le module `TypeORMModule` de la façon suivante :

```diff
@Module({
  imports: [
+    TypeOrmModule.forRoot({
+      type: 'sqlite',
+      database: 'mydatabase.db',
+      entities: [],
+      synchronize: true,
+    }),
    UsersModule, AssociationsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

Ici, on spécifie le type de base de données ainsi que le fichier utilisé. Vérifiez que lorsque vous lancez votre backend,
il n'y a pas d'erreur : `npm run start`.

### Erreur possible

Si vous obtenez le message suivant:
```txt
TypeError: (0 , rxjs_1.lastValueFrom) is not a function
```
quand vous lancez votre backend (`npm run start`), faites la commande `npm i rxjs@^7` puis retestez !

## Entités

Nous allons maintenant faire de nos entités, _i.e._ `user.entity.ts` et `association.entity.ts` de réelles entités d'un point
de vue TypeORM, c'est-à-dire, des objets à sauvegarder en base.

Pour ce faire, vous devez utiliser les décorateurs correctement. Référez-vous au cours dans lequel nous avons vu ces 
décorateurs brièvement ou à la [documentation officielle](https://docs.nestjs.com/techniques/database) de NestJS 
(attention la documentation de NestJS utilise mysql comme base de données).

Vous devez donc :
1. Ajouter le décorator de classe `@Entity()` sur vos classes `User` et `Association`.
2. Ajouter un décorator à chacun des champs des classes `User` et `Association` afin de spécifier leur mapping vers la base de données.

Pensez-bien à quels décorateurs vous allez utiliser. Vous ne devriez pas modifier les définitions des classes, sauf pour
`association.entity`, où on ne stockera plus les id des utilisateurs mais les utilisateurs directements :

```diff
- public idUsers: number[];
+ public users: User[];
```

Pour chaque nouvelle entité déclarée, via le décorateur `@Entity()`, vous devez enregistrer cette nouvelle entité auprès de TypeORM dans le AppModule :

```diff
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'mydatabase.db',
      entities: [
+        User,
+        Association
      ],
      synchronize: true,
    }),
    UsersModule, AssociationsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

Il s'agit ici de dire explicitement à TypeORM quelles sont les entités de notre serveur. Il pourra alors gérer beaucoup de choses pour nous, comme par exemple les `Repository`, la couche que nous verrons juste après et qui s'occupe de la communication avec la base de données.

Une fois vos classes `Association` et `User` "transformées" en entités, nous devons maintenant mettre à jour les `users.service` et `associations.service` en conséquence.

Pour la création d'Association, nous partirons du principe que tous les Users (donc membres de l'Association) existent **avant** la création de l'Association. De ce fait, les données d'entrée pour la création d'Association restent les mêmes que pour le [TP3](https://github.com/stephaniechallita/WebServer/blob/master/modules_et_logiques_metiers.md) : `idUsers: number[], name: string`.
À partir des `idUsers`, `associations.service` doit demander au `users.service` de lui fournir les Users correspondant afin de créer la nouvelle Association.

Dans la suite du TP, vous trouverez des indications de modifications afin de vous aider à bien mettre à jour les services.

## Injection du Repository

Pour les prochaines modifications, nous devons injecter les `repositories` dans les services correspondants. 
Par exemple, pour `users.service.ts`, on aura :

```diff
...
+import { InjectRepository } from '@nestjs/typeorm';
+import { Repository } from 'typeorm';
...

-const users: User[] = [
-    {
-        id: 0,
-        lastname: 'Doe',
-        firstname: 'John',
-        age: 23
-    }
-]

@Injectable()
export class UsersService {

+constructor(
+    @InjectRepository(User)
+    private repository: Repository<User>
+) {}
```

Ici, on supprime la "base de données", _i.e._ le tableau codé en dur que l'on utilisait, et on injecte un `Repository`, qui devient un 
attribut de notre classe `UsersService`. Le `Repository` va faire l'interface avec la base de données (dans notre cas, le fichier `mydatabase.db` créé plus haut et géré par SQLite)

Vous devrez aussi ajouter dans le `users.module.ts` l'import suivant :

```diff
@Module({
+ imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService]
})
```

Mettez à jour `users.service.ts` et faites de même pour `associations.service.ts` et `associations.module.ts` pour que ceux-ci n'utilisent plus de tableau mais la classe `Repository` de TypeORM. La section suivante décrit l'API des `Repository` afin de vous aidez à apporter les modifications
requises.

D'un point de vue facilité, attaquez-vous en premier au module `users`, dont les modifications sont plus simples que pour le module `associations`.

### API de Repository

Concernant la manipulation du `Repository`, toutes les méthodes des repositories sont asynchrones. Pour une question de 
facilité, on utilisera le mot-clés `await` devant chaque appel de méthode pour attendre son résultat. Cela nécessitera 
de déclarer vos méthodes de `services` **ET** de `controllers` asynchrones aussi (avec le mot-clé `async` ainsi que de modifier son retour en Promesse,
_e.g._ `Promise<User>`).

Par exemple pour `getById`, on aura :

```diff
- public getById(idToFind: number): User {
+ public async getById(idToFind: number): Promise<User> {
```

Voici les méthodes qui nous intéresseront pour le moment :

- `repository.create({})` : création d'une entité. Le paramètre de cette fonction est les données sous forme de JSON. 
  Elle retourne la nouvelle entité créée. Par exemple :
```typescript
const newUser = await this.repository.create({
    id: 0, 
    lastname: 'Doe', 
    firstname: 'John', 
    age: 23 
})
```
**Attention** la méthode `create` n'enregistre pas la nouvelle entité dans la base de données. Pour cela, voyez la 
méthode `save()`.
- `save(entity)` : sauvegarde l'entité passée en paramètre dans la base de données. La méthode `save` est utilisée pour 
  la création et la mise à jour.
- `repository.find(FindOperator)` : retourne toutes les entités du repository qui correspondent au `FindOperator`(voir 
  ci-dessous) passé en paramètre.
- `repository.findOne(FindOperator)` : retourne une entité de la base de données qui correspond au `FindOperator`(voir 
  ci-dessous) passé en paramètre.
- `repository.delete(entity)` : supprime de la base de données l'entité passée en paramètre.
- `FindOperator` : on peut voir les `FindOperator` comme des prédicats sur les entités. Ils servent à paramétrer les 
  recherches. Par exemple, le `FindOperator` le plus demandé serait celui qui permet de trouver une entité avec un 
  certain id. Celui-ci s'écrit comme qui suit :
```typescript=
this.repository.findOne({id: Equal(idToFind)});
```

Le `FindOperator` a une forme de JSON, où la clé est la colonne sur laquelle on cherche à mettre la condition, et la 
valeur est le prédicat. Ici, on cherche l'`id` qui est égal `Equal()` à l'`idToFind`. Pour plus d'informations sur les 
`FindOperator`, voir la [documentation officielle](https://typeorm.io/#/find-options).

Pour la mise à jour (`update`), il vous sera peut-être plus simple et plus lisible de récupérer la bonne `entity` à partir de l'id (`getById(id)`),
mettre à jour les champs de l'entité récupérée, puis d'appeler `this.repository.save(entity);` pour mettre à jour.

### Configuration de la récupération des données associées

Pour la gestion de la récupération des données associées, lazy loading ou tout charger, vous pouvez utiliser le paramètre `{eager: true}` dans les décorateurs d'associations (`@ManyToMany()` par exemple) pour signaler à TypeOrm que vous souhaitez charger toutes les données en une seule fois (quand la valeur est true). 
Pour mettre en place le lazy loading, vous devez utiliser `false` (ou ne pas utiliser `eager`par défaut), et utiliser une Promesse comme type pour votre attribut. Pour récupérer la valeur, vous devrez alors utiliser soit un `await` soit une construction `.then()`.

Par exemple, pour le `@ManyToMany` entre Association et User, on aura :

Pour le lazy loading, `association.entity.ts`:
```typescript
/* ... */
  @ManytoMany(type => User)
  @JoinTable()
  users: Promise<User[]>
/* ... */
```
Pour tout charger à chaque requête, `association.entity.ts`:
```typescript
/* ... */
  @ManytoMany(type => User, { eager: true })
  @JoinTable()
  users: User[]
/* ... */
```

Cette configuration n'affecte pas les associations (au sens relationnel) sous-jacentes, _e.g._ si j'ai un eager sur les users d'une association, ça ne veut pas dire que j'ai eager sur une association d'une autre entité aux users. Chaque association doit/peut être configurée.

### Possible erreur

Lors de la modification, vous aurez peut-être l'erreur suivante : 

```txt
Unable to connect to the database. Retrying (1)... +11ms
TypeORMError: Entity metadata for User#association was not found.
```

Si c'est le cas, supprimez le fichier de base de données `mydatabase.db` et créez en un nouveau en suivant à nouveau la procédure ci-dessus.

## Tests

Maintenant qu'on a une base de données, il sera plus contraignant de manipuler les données, et notamment gérer l'état 
pendant le développement. 
Premièrement, assurez-vous que votre fichier de base de données est vide (supprimez-le et 
recrééez-le si besoin). 
Deuxièmement, créez une copie de votre base de données, nommez-la `mydatabase.db.old`. 
Dans la suite, les scripts de tests utiliserons le fichier `mydatabase.db.old` pour "hard reset" la base de données (et repartir d'une base vide)
On peut donc dire que le fichier `mydatabase.db.old` nous servira de backup.
Utilisez le [script suivant](./scripts/typeorm_repository_et_donnees_test.sh) pour (ré-)initialiser la base de données et tester votre backend.

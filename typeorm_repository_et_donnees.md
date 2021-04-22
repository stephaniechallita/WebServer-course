# TypeORM, Repository et données

Une application web digne de ce nom utilise une base de données pour gérer et sauvegarder ses données, et non pas des 
tableaux codés en dur !

C'est pour cela, dans cette partie, nous allons mettre en place la base de données, et ainsi utiliser 
[TypeORM](https://typeorm.io/#/) qui est une bibliothèque d'"object relational mapping" (ORM) en TypeScript.

Pour la base de données, nous utiliserons [SQLite](https://www.sqlite.org/index.html) qui permet de gérer une base de 
données relationnelle "sans serveur", c'est-à-dire que la base de données sera un simple fichier. Cela permet d'avoir 
une base de donnée rapidement, légère et portable. Étant donné que nous n'avons pas de grand besoin pour notre 
application, SQLite remplira parfaitement son rôle.

Cependant, SQLite n'est pas le choix par défaut pour une application de production. Voici un petit comparatif des 
differentes bases de données relationnelles [ici](https://www.digitalocean.com/community/tutorials/sqlite-vs-mysql-vs-postgresql-a-comparison-of-relational-database-management-systems) (EN).

## Préparatifs

Nous allons commencer par installer les pré-requis pour la suite du projet.

### Installer SQLite

Premièrement, installer SQLite sur votre machine : voir la [doc](https://www.sqlite.org/download.html).

Si vous avez un Linux ([source](https://smallbusiness.chron.com/use-sqlite-ubuntu-46774.html)), tapez la commande 
suivante dans votre terminal :
```shell
sudo apt-get install sqlite3 libsqlite3-dev
```

Puis lancer la commande :
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

Puis importer dans votre `app.module.ts` le module `TypeORMModule` de la façon suivante :

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

Ici, on spécifie le type de base de données ainsi que le fichier utilisé. Vérifier que lorsque vous lancez votre backend,
il n'y a pas d'erreur : `npm run start`.

## Entités

Nous allons maintenant faire de nos entités, _i.e._ `user.entity.ts` et `association.entity.ts` de réels entités d'un point
de vue TypeORM, c'est-à-dire, des objets à sauvegarder en base.

Pour ce faire, vous devez utiliser les décorateurs correctement. Référez-vous au cours dans lequel nous avons vu ces 
décorateurs brièvement ou à la [documentation officielle](https://docs.nestjs.com/techniques/database) de NestJS 
(attention la documentation de NestJS utilise mysql comme base de données).

Pensez-bien à quels décorateurs vous allez utiliser. Vous ne devriez pas modifier les définitions des classes, sauf pour
`association.entity`:

```diff
- public idUsers: number[];
+ public users: User[];
```

Mettez à jour le AssociationsService, en conséquence.

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

## Injection du Repository

Maintenant, nous allons injecter le `repository` dans nos services. Pour ce faire, modifiez le `users.service.ts`:

```diff
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

Ici, on supprime la "base de données", _i.e._ le tableau que l'on utilisait, et on injecte un Repository, qui devient un 
attribut de notre classe `UserService`.

Vous devrez aussi ajouter dans le `user.module.ts` l'import suivant :

```diff
@Module({
+ imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService]
})
```

Mettez à jour `users.service.ts` et faites de même pour `associations.service.ts` et `associations.module.ts` pour que 
ceux-ci n'utilisent plus de tableau mais la classe `Repository` de TypeORM.

### API de Repository

Concernant la manipulation du `Repository`, toutes les méthodes des repository sont asynchrones. Pour une question de 
facilité, on utilisera le mot-clés `await` devant chaque appel de méthode pour attendre son résultat. Cela nécessitera 
de déclarer vos méthodes de service asynchrone aussi (avec le mot-clé `async` ainsi que de modifier son retour en Promesse,
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
this.repository.find({id: Equal(idToFind)});
```
Le `FindOperator` a une forme de JSON, où la clé est la colonne sur laquelle on cherche à mettre la condition, et la 
valeur est le prédicat. Ici, on cherche l'`id` qui est égal `Equal()` à l'`idToFind`. Pour plus d'informations sur les 
`FindOperator`, voir la [documentation officielle](https://typeorm.io/#/find-options).

## Tests

Maintenant qu'on a une base de données, il sera plus contraignant de manipuler les données, et notamment gérer l'état 
pendant le développement. Premièrement, assurez-vous que votre fichier de base de données est vide (supprimez-le et 
recrééez-le si besoin). Deuxièmement, créez une copie de votre base de données, nommez-la `mydatabase.db.old`. Ce 
fichier nous servira de backup. Utilisez le [script suivant](./scripts/typeorm_resporistory_et_donnees_test.sh) pour 
(ré-)initialiser la base de données.

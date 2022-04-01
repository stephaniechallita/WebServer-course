# Gestion des injections cycliques

Rapidement, vous constaterez que vous obtenez, normalement, plusieurs dépendences cycliques, _i.e._ des modules qui dépendent des uns et des autres.
Par exemple, et ce n'est peut-être pas le seul, les modules qui gèrent les roles et les associations dépendent de l'un et de l'autre. En TypeScript, on aura :

* `association.module.ts`
```typescript
@Module({
  imports: [
    /* ommitted for brevity */
    RolesModule,
    TypeOrmModule.forFeature([Association])],
  controllers: [AssociationsController],
  providers: [AssociationsService],
  exports: [AssociationsService]
})
export class AssociationsModule { }
```

* `roles.module.ts`
```typescript
@Module({
    imports: [
    /* ommitted for brevity */
    AssociationsModule, 
    TypeOrmModule.forFeature([Role])],
    controllers: [RolesController],
    providers: [RolesService],
    exports: [RoleService]
})
export class RolesModule { }
```

Dans ce cas, l'injection des services dans les autres services, _e.g._ l'injection du service `AssociationService` dans `RolesService` ne peut se faire.
Pourquoi ? Eh bien pour récupérer `AssociationService`, il faut récupérer de la même façon `RolesService`, et vice-versa.

Une solution est d'utiliser le décorateur `forwardRef(() => module)` dans l'`imports` du module ainsi que dans l'injection du service dans le service.
Dans notre cas présent, cela donnerait :
* `association.module.ts`:
```typescript
@Module({
  imports: [
    /* ommitted for brevity */
    RolesModule,
    TypeOrmModule.forFeature([Association])],
  controllers: [AssociationsController],
  providers: [AssociationsService],
  exports: [AssociationsService]
})
export class AssociationsModule { }
```

* `roles.module.ts`
```typescript
@Module({
    imports: [
    /* ommitted for brevity */
    forwardRef(() => AssociationsModule), 
    TypeOrmModule.forFeature([Role])],
    controllers: [RolesController],
    providers: [RolesService],
    exports: [RoleService]
})
export class RolesModule { }
```
* `roles.service.ts`:
```typescript
@Injectable()
export class RolesService {
    constructor(
        /* ommitted for brevity */
        @Inject(forwardRef(() => AssociationsService))
        private associationsService: AssociationsService
    ) { }
```

De cette façon, NestJS saura que le service sera instancié plus tard et l'injection pourra se faire.

Pour résoudre vos problèmes, appliquez simplement le protocole suivant : 

1. Lorsque j'ai un message de type :

```txt
Nest cannot create the AssociationsModule instance.
The module at index [1] of the AssociationsModule "imports" array is undefined.

Potential causes:
- A circular dependency between modules. Use forwardRef() to avoid it. Read more: https://docs.nestjs.com/fundamentals/circular-dependency
- The module at index [1] is of type "undefined". Check your import statements and the type of the module.

Scope [AppModule -> UsersModule -> RolesModule]
Error: Nest cannot create the AssociationsModule instance.
The module at index [1] of the AssociationsModule "imports" array is undefined.
```

ou

```txt
ERROR [ExceptionHandler] Nest can't resolve dependencies of the UsersService (UserRepository, ?). Please make sure that the argument dependency at index [1] is available in the UsersModule context.

Potential solutions:
- If dependency is a provider, is it part of the current UsersModule?
- If dependency is exported from a separate @Module, is that module imported within UsersModule?
  @Module({
    imports: [ /* the Module containing dependency */ ]
  })

Error: Nest can't resolve dependencies of the UsersService (UserRepository, ?). Please make sure that the argument dependency at index [1] is available in the UsersModule context.

Potential solutions:
- If dependency is a provider, is it part of the current UsersModule?
- If dependency is exported from a separate @Module, is that module imported within UsersModule?
  @Module({
    imports: [ /* the Module containing dependency */ ]
  })
```

2. Analyser quelle injection de service fait défaut dans quel service : 
`the UsersService (UserRepository, ?). Please make sure that the argument dependency at index [1] is available in the UsersModule context.`
Avec cette ligne en particulier on sait que c'est l'injection à `l'index [1]` (le deuxième paramètre du constructeur) du service `UsersService`.

3. Le constructor du `UsersService` est définit comme cela :

```ts
constructor(
  @InjectRepository(User)
  private repository: Repository<User>,
  private rolesService: RolesService
) { }
```

4. Il me faut donc ajouter un `forwardRef()` lors de l'import du module `RolesModule` dans le module `UsersModule` (`src/app/users/users.module.ts`) :

```diff
@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
+    forwardRef(() => RolesModule)
-    RolesModule 
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService]
})
export class UsersModule {}
```

ainsi que lors de l'injection du `RolesService` dans `UsersService` (`src/app/users/users.service.ts`):

```diff
constructor(
  @InjectRepository(User)
  private repository: Repository<User>,
+  @Inject(forwardRef(() => RolesService))
  private rolesService: RolesService
) { }
```

5. Répéter l'opération jusqu'à ce qu'il n'y ait plus d'erreur.
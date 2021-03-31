# Gestion des injections cycliques

Rapidement, vous constaterez que vous obtenez, normalement, plusieurs dépendences cycliques, _i.e._ des modules qui dépendent des uns et des autres.
Par exemple, et ce n'est peut-être pas le seul, les modules qui gèrent les procès verbals et les associations dépendent de l'un et de l'autre. En TypeScript, on aura :

* `association.module.ts`
```typescript=
@Module({
  imports: [
    /* ommitted for brevity */
    VerbalProcessesModule,
    TypeOrmModule.forFeature([Association])],
  controllers: [AssociationsController],
  providers: [AssociationsService],
  exports: [AssociationsService]
})
export class AssociationsModule { }
```

* `verbal-processes.module.ts`
```typescript=
@Module({
    imports: [
    /* ommitted for brevity */
    AssociationsModule, 
    TypeOrmModule.forFeature([VerbalProcess])],
    controllers: [VerbalProcessesController],
    providers: [VerbalProcessesService],
    exports: [VerbalProcessesService]
})
export class VerbalProcessesModule { }
```

Dans ce cas, l'injection des services dans les autres services, _e.g._ l'injection du service `AssociationService` dans `VerbalProcessesService` ne peut se faire.
Pourquoi ? Eh bien pour récupérer `AssociationService`, il faut récupérer de la même façon `VerbalProcessesService`, et vice-versa.

Une solution est d'utiliser le décorateur `@forwardRef(() => mon_service)` dans l'`imports` du module ainsi que dans l'injection du service dans le service. 
Dans notre cas présent, cela donnerait :
* `association.module.ts`:
```typescript=
@Module({
  imports: [
    /* ommitted for brevity */
    VerbalProcessesModule,
    TypeOrmModule.forFeature([Association])],
  controllers: [AssociationsController],
  providers: [AssociationsService],
  exports: [AssociationsService]
})
export class AssociationsModule { }
```

* `verbal-processes.module.ts`:
```typescript=
@Module({
    imports: [
    /* ommitted for brevity */
    @forwardRef(() => AssociationsModule), 
    TypeOrmModule.forFeature([VerbalProcess])],
    controllers: [VerbalProcessesController],
    providers: [VerbalProcessesService],
    exports: [VerbalProcessesService]
})
export class VerbalProcessesModule { }
```
* `verbal-processes.service.ts`:
```typescript=
@Injectable()
export class VerbalProcessesService {
    constructor(
        /* ommitted for brevity */
        @Inject(forwardRef(() => AssociationsService))
        private associationsService: AssociationsService
    ) { }
```

De cette façon, NestJS saura que le service sera instancié plus tard et l'injection pourra se faire.
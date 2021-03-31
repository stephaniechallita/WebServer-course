# OpenAPI

Dans cette partie, nous allons ajouter à notre backend une interface **swagger**, ou [OpenAPI](https://swagger.io/specification/).

## Installation

Pour ce faire, il faut installer les modules requis :

```shell
npm install --save @nestjs/swagger swagger-ui-express
```

Modifiez votre fichier `main.ts`:

```diff
import { NestFactory } from '@nestjs/core';
+import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

+  const config = new DocumentBuilder()
+    .setTitle('Gestion des Associations')
+    .setDescription('Descriptions des APIs de la gestion des associations')
+    .setVersion('1.0')
+    .build();
+  const document = SwaggerModule.createDocument(app, config);
+  SwaggerModule.setup('api', app, document);

  await app.listen(3000);
}
bootstrap();
```

Une fois modifier, relancez votre backend, et connecter vous à `http://localhost:3000/api/`. Vous devriez obtenir votre 
interface OpenAPI.

## Configuration

### Regroupement d'API par tags

Dans la version par défaut, toutes vos apis devraient être regroupées sous le tag `defaut`. Pour configurer ces tags, 
il suffit d'ajouter aux contrôleurs le décorateur ` @ApiTags('<tag>')`. Par exemple, pour le contrôleur des utilisateurs :

```typescript
/** omis **/
import { ApiTags } from '@nestjs/swagger';

@ApiTags('users')
@Controller('users')
export class UsersController {

    constructor(
/** omis **/
```

Regroupez tous les endpoints sous des tags qui vous semblent cohérents.

### Input

Jusqu'à maintenant, nous définissions nos endpoints `POST` comme ceci :

```typescript
@Post()
public async create(@Body() input: any): Promise<User> {
    return this.service.create(input.firstname, input.lastname, input.age);
}
```

Si on observe l'interface OpenAPI corresponds on a :

![](./pictures/open_api_post_simple.png)

Ce qui n'aide pas vraiment. Pour améliorer ça, nous allons créer une nouvelle classe :

```typescript
export class UserInput {
    public firstname: string;
    public lastname: string;
    public age: number;
}
```

et modifier l'input de notre API :

```diff
@Post()
-public async create(@Body() input: any): Promise<User> {
public async create(@Body() input: UserInput): Promise<User> {
    return this.service.create(input.firstname, input.lastname, input.age);
}
```

Vous pouvez maintenant voir dans l'interface OpenAPI, que le paramètre apparait, mais qu'il n'y a pas beaucoup 
d'information. Il nous faut compléter cela, en ajoutant sur chaque attribut de la class `UserInput` le décorateur 
`@ApiProperty()`.

Vous pouvez compléter les informations du décorateur afin d'enrichir votre documentation OpenAPI comme ceci :

```typescript
@ApiProperty({
    description: 'The age of the user',
    minimum: 18,
    default: 18,
})
```

Cela apportera, dans l'ongle schéma, de nouvelles informations sur l'utilisation de cette API :

![](./pictures/open_api_post_details.png)

Cela permet également de fournir des données exemples quand à l'utilisation de l'API.

Vous pouvez dès à présent créer des objets de données d'entrée pour toutes vos APIs, ainsi que les documenter.

Pour plus d'information sur Swagger avec NestJS, voir la [documentation officielle](https://docs.nestjs.com/openapi/introduction).
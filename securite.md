# Sécurité

Le but de cette partie est de voir quelques notions de sécurité.

## Authentification

Une fonctionnalité importante d'un serveur web est de pouvoir authentifier les utilisateurs et donc de ne pas laisser 
n'importe qui obtenir toutes les informations.
Pour ce faire, nous allons mettre en place un système de mot de passe pour les utilisateurs, ainsi que la prise en 
charge d'un JWT : **JSON** **W**eb **T**oken.
Après cela, l'accès aux APIs sera restreint uniquement aux utilisateurs authentifiés, et donc avec un JWT dans le header
de leurs requêtes.

Pour cela, installez tout d'abord les modules requis :

```sh
npm install --save @nestjs/passport passport passport-local
npm install --save-dev @types/passport-local
```

Le module `passport` fournit tout le nécessaire à la mise en place de "stratégie" d'authentification. Dans notre cas, 
nous utiliserons la stratégie `passport-local`, qui met en place un système d'authentification basé sur un identifiant et
un mot de passe.

Une fois les modules installés, ajoutez à votre entité `user`, un nouvel attribut `password` de type string et modifiez 
éventuellement d'autres composants, _e.g._ le `users.service`. Cet attribut `password` sera également stocké en base. Pour le moment, 
on ne s'intéresse pas à sécuriser les mots de passe de la base de données, on verra plus tard dans le tp comment hasher les mots de passe avant de les stocker.

### Module Auth

Générez maintenant un nouveau module `auth`, et ajoutez-y un nouveau service.

Implémentez dans ce service la méthode suivante :

```typescript
public async validateUser(id: number, password: string) : Promise<User> {
    /** To be implemented **/
}
```

qui vérifie que le mot de passe (`password`) fourni en paramètre est bien le mot de passe de l'`user` désigné par son `id` passé en paramètre.
Si tel est le cas, alors la fonction retourne l'utilisateur, `undefined` si non.

### Local Strategy

Une fois implémentée, nous allons ajouter notre stratégie au module `auth`. Créez le fichier `local.strategy.ts` dans le 
module `auth` :
```typescript
import { Strategy } from "passport-local"; 

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {

    constructor(
        private authService: AuthService
    ) {
        super();
    }

    async validate(username: string, password: string): Promise<any> {
        const user: any = await this.authService.validateUser(+username, password);
        if (!user) {
            throw new UnauthorizedException();
        }
        return user;
    }
}
```

Il est impératif de garder la signature de la méthode `validate` car le module `passport` va chercher après une telle 
méthode, et si elle n'existe pas, la requête sera automatiquement rejetée. Faites attention à bien importer `Strategy` de `passport-local` (et non pas d'un autre package). 

On utilisera donc l'id de l'utilisateur comme un `username`. Il suffit de le "cast" en `number` avec le symbole `+`.

Mettez ensuite à jour votre `auth.module.ts` :

```diff
import { Module } from '@nestjs/common';
+import { PassportModule } from '@nestjs/passport';
import { UsersModule } from 'src/users/users.module';
import { AuthService } from './auth.service';
+import { LocalStrategy } from './local.strategy';

@Module({
+  imports: [UsersModule, PassportModule],
-  providers: [AuthService]
+  providers: [AuthService, LocalStrategy]
})
```

### Garde

Un mécanisme super intéressant de NestJS est le système de Gardes (Guards). Ces gardes permettent de "protéger" les 
endpoints implémentés par les contrôleurs avec un predicat (une fonction booléenne). Dans le cadre de l'authentification,
l'application des gardes est assez directe : on refuse l'accès aux utilisateurs non authentifiés ou avec des informations 
(le couple (username;password)) erronées.

On va donc mettre en place un `Guard` pour protéger certains endpoints avec l'authentification.
Premièrement, générez un contrôleur dans le module `auth` et ajoutez la méthode `login()` suivante : 

```typescript
import { Controller, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Controller('auth')
export class AuthController {
    @UseGuards(AuthGuard('local'))
    @Post('login')
    async login(@Request() request) {
      return request.user;
    }
}
```

Ici, on a plusieurs nouvelles fonctionnalités : 

1. Le décorateur `@UseGuards()` qui permet de spécifier une liste de gardes qui "protègera" l'endpoint géré par la 
   méthode. Les gardes peuvent être également spécifiés au niveau du contrôleur, afin que tous les endpoints du 
   contrôleur soient protégés par la même Garde (et ça évite de mettre des `UseGuards()` à toutes les fonctions) ;
2. Le type `AuthGuard('local')` qui est une garde spéciale d'authentification, qui utilisera la stratégie 'local',
   qui a été implémentée juste avant.
3. Le décorateur / paramètre `@Request() request` qui modélise et porte toutes les informations de la requête que le 
   client a fait.

Vous pouvez constater que le corps de cette méthode est pratiquement vide. En fait, cette méthode délègue toute la 
logique d'authentification à sa garde, et on évite alors la redondance de code.

Faites le nécessaire d'un point de vue base de données, et testez la nouvelle API avec les commandes suivantes :

```shell
# expected 201 with info of user with ID = 1
curl -X POST http://localhost:3000/auth/login -d 'username=1&password=valid_password' -v
# expecting 401 Unauthorized
curl -X POST http://localhost:3000/auth/login -d 'username=1&password=wrong_password' -v
```

Bien évidemment, faites attention aux valeurs de ces requêtes : la première a un password valide, et l'utilisateur sera 
validé, tandis que la deuxième non.

### JWT

C'est bien beau l'authentification, mais comme nous avons un serveur REST, il est stateless et donc il faut fournir à 
chaque requête les informations d'authentification, ce qui peut être lourd. C'est pour cela que nous allons mettre en 
place un **JSON W**eb **T**oken qui permettra d'authentifier l'utilisateur plus facilement.

Pour commencer, on va installer le module `passport-jwt` : 

```shell
npm install --save @nestjs/jwt passport-jwt
```

Nous allons maintenant changer la logique d'authentification dans le `auth.service` et le `auth.controller`. En effet, 
avec la garde `AuthGard()` on sait que si le corps de la méthode qui gère l'endpoint `auth/login` est exécuté, cela veut
dire que l'utilisateur a bien été authentifié, grâce à la stratégie "local" sous-jacente.

Ajoutez à votre service la méthode suivante :

```typescript
async login(user: any) {
    const payload = { username: user.id };
    return {
        access_token: this.jwtService.sign(payload),
    };
}
```

ainsi que l'import et l'injection du `JwtService` depuis le module `@nestjs/jwt` dans le constructeur du AuthService.

Ici, on utilise la méthode `sign()` du `jwtService` pour générer un jeton à partir de certaines informations de 
l'utilisateur, notamment ici son `id`.

Créez maintenant un nouveau fichier `auth/constants.ts` qui contiendra le code suivant :

```typescript
export const jwtConstants = {
  secret: 'secretKey',
};
```

Cette constante est le "sel" du jeton et doit restée secrète.

Nous allons maintenant ajouter le module `Jwt` dans `auth.module.ts` :

```diff
+import { JwtModule } from '@nestjs/jwt';
+import { jwtConstants } from './constants';

@Module({
  imports: [
    UsersModule,
    PassportModule,
+    JwtModule.register({
+      secret: jwtConstants.secret,
+      signOptions: { expiresIn: '60s' },
+    })
  ],
  providers: [AuthService, LocalStrategy],
  controllers: [AuthController]
})
export class AuthModule { }
```

Ici, on importe le `JwtModule`, et on le configure avec l'appel à la méthode `register()` en donnant un objet configuration en paramètre.
La configuration est : le secret à utiliser, qui est la constante définie à l'étape précèdente ; les `JWT` expirent au bout d'une minute.

Et on va maintenant mettre à jour la méthode `login()` du `auth.controller.ts` :

```diff
@UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() request) {
-    return request.user;
+    return this.authService.login(request.user);
  }
```

Vous pouvez maintenant tester que le backend crée bien un token en réutilisant la même commande `curl` que précédement.
Vous devriez avoir en retour le token.

```sh
$ curl -X POST http://localhost:3000/auth/login -d 'username=1&password=valid_password'
{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6MSwiaWF0IjoxNjE3NzM2NTQ4LCJleHAiOjE2MTc3MzY2MDh9.3GRHwA_Tpk_dJFddBooUZCf-2Al4EoajWziYjcMOS7E"}
```

### JWT Strategy

De la même manière que pour la stratégie locale, nous allons implémenter une stratégie `jwt`. Créez un nouveau fichier `jwt.strategy.ts` avec le code suivant : 

```typescript
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';
import { jwtConstants } from './constants';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtConstants.secret,
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username };
  }
}
```

Et ajoutez cette nouvelle stratégie à votre module `auth.module.ts`:

```diff
- providers: [AuthService, LocalStrategy],
+ providers: [AuthService, LocalStrategy, JwtStrategy],
```

### Protéger des APIs avec le token

C'est beau d'avoir un token mais il faut maintenant protéger les apis avec. De la même manière que pour la stratégie locale, _i.e._ le couple `username;password`, on peut mettre en place une garde qui s'attend à voir un token valide dans le header de la requête.
Ajoutez simplement sur un contrôleur ou sur une API specifique : 

```typescript
@UseGuards(AuthGuard('jwt'))
```

Et tada ! Passport s'occupe de tout gérer pour vous. Par exemple, si vous ajoutez la garde sur l'api `GET /users/`, vous pouvez la tester avec la ligne de commande suivante : 

```sh
curl -X GET http://localhost:3000/users -H "Content-Type: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6MSwiaWF0IjoxNjE3NzM5MzkxLCJleHAiOjE2MTc3Mzk0NTF9.p8uuEpr16YOhoCPjwWNLLQyeKDCxvbixwDa0q60whYI"
```

Vous aurez évidemment un autre token après `Bearer`.

## Fonction de Hash pour le mot de passe

Nous allons maintenant hasher le mot de passe des utilisateurs avant de le stocker en base. Premièrement, installez les modules suivants :

```shell
npm i bcrypt
npm i -D @types/bcrypt
```

Voilà le snippet de code qui permet de hasher le mot de passe : 

```typescript
import * as bcrypt from 'bcrypt';

const password: string = 'password';
const saltOrRounds = 10;
const hash = await bcrypt.hash(password, saltOrRounds);
```

Ce code est à utiliser lors de la création et l'enregistrement d'un utilisateur. 

Pour comparer un mot de passe fourni par un utilisateur et celui stocké en base, le module `bcrypt` fournit la méthode asynchrone `compare` :

```typescript
bcrypt.compare(password, hash);
```

On stockera en base le hash du mot de passe et non pas le mot de passe lui-même, dans le cas d'une fuite de votre base de données, vous protégez ainsi vos clients !

Mettez à jour votre code pour gérer les mots de passe hashés.

Si vous avez tout bien fait, le comportement n'a pas changé. Cependant, si vous affichez (attention à ne jamais le faire en dehors de ce tp) les mots de passe, vous 
obtiendrais un charabia (le hash du mot de passe en fait).

## Helmet

Helmet est une collection d'intergiciels qui ajoute des "Headers HTTP" pour protéger les applications web de failles bien connues.
Bien simple d'utilisation, il en reste néamoins puissant et très utile.

Pour installer `helmet`, utilisez la ligne de commande suivante :

```shell
npm i --save helmet
```

Ensuite, il suffit de modifier son `main.ts`, ou le fichier où l'application est bootstrappée avec :


```diff
+ import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
+  app.use(helmet());
```

En ajoutant l'option `-v` à une commande curl, vous pourrez observer que `helmet` ajoute tout un tas de headers aux réponses du serveur : 

```
< HTTP/1.1 200 OK
< Content-Security-Policy: default-src 'self';base-uri 'self';block-all-mixed-content;font-src 'self' https: data:;frame-ancestors 'self';img-src 'self' data:;object-src 'none';script-src 'self';script-src-attr 'none';style-src 'self' https: 'unsafe-inline';upgrade-insecure-requests
< X-DNS-Prefetch-Control: off
< Expect-CT: max-age=0
< X-Frame-Options: SAMEORIGIN
< Strict-Transport-Security: max-age=15552000; includeSubDomains
< X-Download-Options: noopen
< X-Content-Type-Options: nosniff
< X-Permitted-Cross-Domain-Policies: none
< Referrer-Policy: no-referrer
< X-XSS-Protection: 0
< Content-Type: application/json; charset=utf-8
< Content-Length: 348
< ETag: W/"15c-/dAWKidyV+/UGo0ucAQaRfi+Md0"
< Date: Tue, 06 Apr 2021 20:34:05 GMT
< Connection: keep-alive
< Keep-Alive: timeout=5
```

Sans `helmet`, vos réponses fuiteront le fait que votre application a été faite avec [ExpressJS](https://expressjs.com/), un framework nodejs sur lequel est bati `NestJS` pour construire des applications web. Dans le retour d'une commande `curl` sans `helmet`, vous devriez trouver quelques chose comme : 

```
X-Powered-By: Express
```

Qu'est-ce qu'on peut faire avec ça ? C'est une bonne question et c'est en dehors de la portée du projet. Cependant, ce [blog](https://www.codementor.io/@dealwap/few-ways-i-could-hijack-your-node-js-applications-h07fvj731) explique comment exploiter cette connaissance pour s'approprier des droits (par exemple d'adminstration dans votre application) ou modifier des ressources qui ne sont pas accessibles normalement (Je rappelle ici, que ce blog est à but éducatif, et vous ne devez en aucun cas reproduire ou tenter ces attaques sur de véritables applications, sous peine de sanction pénale. L'UR1 décline toute responsabilité).

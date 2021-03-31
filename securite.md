# Sécurité

Le but de cette dernière partie est de voir quelques notions de sécurité.

## Authentification

Une fonctionnalité importante d'un serveur web est de pouvoir authentifier les utilisateurs et donc de ne pas laisser 
n'importe qui obtenir toutes les informations.
Pour ce faire, nous allons mettre en place un système de mot de passe pour les utilisateurs, ainsi que la prise en 
*charge d'un JWT : **JSON** **W**eb **T**oken.
Après cela, l'accès aux APIs sera restreint uniquement aux utilisateurs authentifiés, et donc avec un JWT dans le header
de leurs requêtes.

Pour cela, install tout d'abord les modules requis :

```sh=
npm install --save @nestjs/passport passport passport-local
npm install --save-dev @types/passport-local
```

Le module `passport` fournit tout le nécessaire à la mise en place de "strategy" d'authentification. Dans notre cas, 
nous utiliserons la strategy `passport-local`, qui met en place un système d'authentification basé sur un identifiant et
un mot de passe.

Une fois les modules installés, ajoutez à votre entité `user`, un nouvel attribut `password` de type string et modifiez 
éventuellement d'autres composants, _e.g._ le `users.service`. Celui-ci sera également stocké en base. Pour le moment, 
on ne s'intéresse pas à sécuriser les mots de passe de la base de données.

### Module Auth

Générez maintenant un nouveau module `auth`, et ajoutez-y un nouveau service.

Implémentez dans ce service la méthode suivante :

```typescript=
public async validateUser(id: number, password: string) : Promise<User> {
    /** To be implemendted **/
}
```

### Local Strategy

Une fois implémenté, nous allons ajouter notre strategy au module `auth`. Créez le fichier `local.strategy.ts` dans le 
module `auth` :
```typescript=
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
méthode, et si elle n'existe pas, la requête sera automatiquement rejetée.

On utilisera donc l'id de l'utilisateur comme un `username`. Il suffit de le "cast" en `number` avec le symbole `+`.

Mettez ensuite à jours votre `auth.module.ts` :

```diff=
import { Module } from '@nestjs/common';
+import { PassportModule } from '@nestjs/passport';
import { UsersModule } from 'src/users/users.module';
import { AuthService } from './auth.service';
+import { LocalStrategy } from './local.strategy';

@Module({
+  imports: [UsersModule, PassportModule],
+  providers: [AuthService, LocalStrategy]
})
```

### Garde

Un mechanism super intéressant de NestJS est le système de Gardes (Guards). Ces gardes permettent de "protéger" les 
endpoints implémentés par les contrôleurs avec un predicat (une fonction booléenne). Dans le cadre de l'authentification,
l'application des gardes est assez directe : on refuse l'accès aux utilisateurs non authentifiés ou avec des informations 
(le couple (username;password)) erronées.

On va donc mettre en place un `Guard` pour protéger certains endpoints avec l'authentification.
Premièrement, générez un contrôleur dans le module `auth` et ajoutez la méthode `login()` suivante : 

```typescript=
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

1. Le décorateur `@UseGuards()` qui permet de spécifier une liste de garde qui "protégera" l'endpoint gérer pas la 
   méthode. Les gardes peuvent être également spécifiés au niveau du contrôleur, afin que tous les endpoints du 
   contrôleur soit protégés par la même Garde (et ça évite de mettre des `UseGuards()` à toutes les fonctions) ;
2. Le décorateur `AuthGuard('local')` qui est une garde spéciale d'authentification, qui utilisera la stratégie 'local',
   qui a été implémentée juste avant.
3. Le décorateur / paramètre `@Request() request` qui modélise et porte toutes les informations de la requête que le 
   client à fait.

Vous pouvez constater que le corps de cette méthode est pratiquement vide. En fait, cette méthode délègue toute la 
logique d'authentification à sa garde, et on évite alors de la redondance de code.

Faites le nécessaire d'un point de vue base de données, et tester la nouvelle API avec les commandes suivantes :

```shell=
# expected 200 with info of user with ID = 1
curl -X POST http://localhost:3000/auth/login -d '{"username": "1", "password": "valid_password"}' -H "Content-Type: application/json"
# expecting 401 Unauthorized
curl -X POST http://localhost:3000/auth/login -d '{"username": "1", "password": "wrong_password"}' -H "Content-Type: application/json"
```

Bien évidement, faites attention aux valeurs de ces requêtes : la première a un password valid, et l'utilisateur sera 
validé, tandis que la deuxième non.

### JWT

C'est bien bon l'authentification, mais comme nous avons un serveur REST, il est stateless et donc il faut fournir à 
chaque requête les informations d'authentification, ce qui peut être lourd. C'est pour cela que nous allons mettre en 
place un **JSON W**eb **T**oken qui permettra d'authentifier l'utilisateur plus facilement.

Pour commencer, on va installer le module `passport-jwt` : 

```shell=
npm install --save @nestjs/jwt passport-jwt
```

Nous allons maintenant changer la logique d'authentification dans le `auth.service` et le `auth.controller`. En effet, 
avec la garde `AuthGard()` on sait que si le corps de la méthode qui gère l'endpoint `auth/login` est exécuté, cela veut
dire que l'utilisateur a bien été authentifié, grâce à la stratégie "local" sous-jacente.

Ajoutez à votre service la méthode suivante :

```typescript=
async login(user: any) {
    const payload = { username: user.id };
    return {
        access_token: this.jwtService.sign(payload),
    };
}
```

ainsi que l'import et l'injection du `JwtService` depuis le module `@nestjs/jwt`.

Ici, on utilise la méthode `sign()` du `jwtService` pour générer un jeton à partir de certaine information de 
l'utilisateur.

Créez maintenant un nouveau fichier `auth/constants.ts` qui contiendra le code suivant :

```typescript=
export const jwtConstants = {
  secret: 'secretKey',
};
```

Cette constante est le "sel" du jeton et doit rester secret.

## Fonction de Hash pour le mot de passe

## Helmet
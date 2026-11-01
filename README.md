# springcoredemo

[![CI](https://github.com/LeminEly/jee-tp02-spring-boot-/actions/workflows/ci.yml/badge.svg)](https://github.com/LeminEly/jee-tp02-spring-boot-/actions/workflows/ci.yml)

TP 02 du module JEE : inversion de controle et injection de dependances avec
Spring Core.

L'application n'a aucune logique metier. Son seul objet est de rendre le
conteneur Spring **observable** : quelle implementation il injecte, s'il partage
une instance ou en cree plusieurs, et dans quel ordre il appelle le cycle de vie
d'un bean.

## Prerequis

- JDK 25. La version exacte est figee dans `.sdkmanrc`. Dans le depot :
  `sdk env`, puis verifier que `javac -version` affiche bien 25. Un JRE suffit a
  lancer l'application, pas a la compiler.
- Rien d'autre. Maven est fourni par le wrapper `./mvnw`, et le serveur est
  embarque dans l'archive.

## Lancer

Trois facons, au choix.

```sh
# 1. depuis l'IDE : executer la methode main de SpringcoredemoApplication

# 2. par le plugin Maven
./mvnw spring-boot:run        # ou : scripts/run.sh

# 3. par l'archive
./mvnw package
java -jar target/springcoredemo-0.0.1-SNAPSHOT.jar
```

L'application ecoute sur le port 8080.

## Points d'acces

| Methode | Chemin | Reponse | Exercice |
| --- | --- | --- | --- |
| GET | `/dailyworkout` | `Swim 1000 meters as a warm up` | 5.1, puis 5.8 |
| GET | `/check` | `Comparing beans: myCoach == anotherCoach, true` | 5.6 |

Aucune authentification : contrairement au TP 01, aucun starter de securite
n'est declare. C'est voulu, et explique dans `SECURITY.md`.

## Les beans de ce projet

| Bean | Classe | Declare par | Particularite |
| --- | --- | --- | --- |
| `cricketCoach` | `CricketCoach` | `@Component` | Singleton, porte `@PostConstruct` et `@PreDestroy` |
| `baseballCoach` | `BaseballCoach` | `@Component` | |
| `tennisCoach` | `TennisCoach` | `@Component` | `@Lazy` : absent du demarrage |
| `trackCoach` | `TrackCoach` | `@Component` | `@Primary` : choisi par defaut |
| `aquatic` | `SwimCoach` | `@Bean` dans `SportConfig` | Classe sans annotation, identifiant explicite |

`DemoController` recoit trois parametres : le coach `aquatic` pour
`/dailyworkout`, et deux fois `cricketCoach` pour que `/check` compare deux
references. C'est la superposition des exercices 5.6 et 5.8, expliquee dans
`REPONSES.md`.

## Etat de l'etat final, et ce qui vit dans l'historique

Certains exercices se contredisent : le depot ne peut porter qu'un etat a la
fois. Ce qui ne survit pas dans le code final reste lisible ailleurs.

| Observation | Ou la retrouver |
| --- | --- |
| `NoUniqueBeanDefinitionException` de 5.2 | `CoachAmbiguityTest`, et `scripts/demo-ambiguite.sh` |
| `@Primary` seul, puis la priorite du qualifier | `PrimaryVersusQualifierTest`, commit `feat(5.4)` |
| Deux `@Primary`, le piege | `PrimaryVersusQualifierTest` |
| `spring.main.lazy-initialization=true` | commit `feat(5.5)`, retire au commit suivant |
| `/check` a `false` en portee prototype | `BeanScopeTest`, commit `feat(5.6)` |
| `@PreDestroy` ignore sur un prototype | `REPONSES.md`, question 7 |

## Tests

```sh
./mvnw test
```

Dix tests. Le `contextLoads` genere, plus quatre classes qui figent ce que les
exercices demandent d'observer. Ces tests sont inhabituels pour un TP : ils
existent parce que plusieurs observations ne peuvent pas coexister dans le code
livre, et qu'un test les rend rejouables la ou une capture n'est qu'un
instantane.

## Qualite et integration continue

| Porte | Ou | Ce qu'elle refuse |
| --- | --- | --- |
| `pre-commit` | local et CI | Espaces en fin de ligne, YAML, JSON, TOML et XML invalides, fichiers de plus de 512 Ko, cles privees |
| `gitleaks` | local et CI | Secrets, et sur **tout** l'historique en CI |
| Message de commit | local | Tout message hors convention |
| `./mvnw test` | local et CI | Code qui ne compile pas, test rouge, mauvais JDK |
| Demarrage de l'archive | CI | Une application qui compile mais refuse de demarrer |

Chacune a ete soumise a un cas fautif et vue refuser. La distribution Maven est
verrouillee par empreinte, et les actions GitHub sont epinglees par empreinte de
commit.

Installer les controles apres un clone :

```sh
pre-commit install && pre-commit install --hook-type commit-msg
```

## Captures d'ecran

Les captures vivent dans `screenshots/`. Chacune se prend en lancant le script
indique.

| Fichier | Contenu | Script a lancer |
| --- | --- | --- |
| `01-ambiguite.png` | La trace de `NoUniqueBeanDefinitionException` et les quatre beans | `scripts/demo-ambiguite.sh` |
| `02-dailyworkout.png` | `GET /dailyworkout` | `scripts/demo-endpoints.sh` |
| `03-check.png` | `GET /check` a `true` | `scripts/demo-endpoints.sh` |
| `04-lazy.png` | Les constructeurs au demarrage, `TennisCoach` absent | `scripts/run.sh` |
| `05-cycle-de-vie.png` | `In constructor` puis `In doMyStartupStuff()` puis `In doMyCleanupStuff()` | `scripts/demo-cycle-de-vie.sh` |

Ordre conseille : `scripts/demo-ambiguite.sh` d'abord, aucune application n'ayant
besoin de tourner. Puis `scripts/run.sh` dans un terminal pour la capture 04, et
`scripts/demo-endpoints.sh` dans un second pour 02 et 03. Enfin arreter
l'application et lancer `scripts/demo-cycle-de-vie.sh`, qui gere lui-meme son
demarrage et son arret.

Avant de capturer : opacite du terminal a 100 % et autres fenetres fermees, pour
qu'aucun contenu etranger ne transparaisse.

## Reponses aux questions

Voir `REPONSES.md` : les huit questions de la section 6 de l'enonce, le tableau
des scopes complete, les mesures de chaque experience demandee, et trois ecarts
assumes par rapport a l'enonce avec leur raison.

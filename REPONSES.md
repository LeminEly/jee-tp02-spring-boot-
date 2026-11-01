# Reponses

TP 02, IoC et injection de dependances. Les huit questions de la section 6 de
l'enonce, puis les observations que les exercices demandent de noter.

Toutes les valeurs citees ici ont ete mesurees sur ce projet, pas reprises du
cours. Quand une mesure contredit ou nuance l'enonce, c'est dit.

## 1. Difference entre IoC et DI

L'inversion de controle est le principe : un objet ne construit plus ce dont il
depend, un conteneur exterieur s'en charge. L'injection de dependances est le
mecanisme qui applique ce principe : le conteneur passe les objets necessaires
a celui qui en a besoin.

Le premier dit qui decide, le second dit comment la decision arrive.

Avec `new CricketCoach()`, `DemoController` choisit lui-meme une implementation.
Il connait la classe concrete, il connait sa facon de se construire, et il
devra etre modifie si elle change. Le controle appartient au code appele.

Avec le conteneur, `DemoController` declare un besoin dans sa signature :
`DemoController(Coach theCoach)`. Il ne nomme qu'une abstraction. Spring
inspecte le contexte, trouve les candidats, en choisit un, construit le
controleur et lui passe l'instance. Le controle est passe au conteneur, d'ou
« inversion ».

La difference se voit concretement dans ce projet : passer de
`@Qualifier("cricketCoach")` a `@Qualifier("aquatic")` change l'implementation
servie, sans toucher une ligne de `DemoController`.

## 2. Pourquoi l'injection par constructeur plutot que par champ

**L'objet est toujours valide.** Un constructeur qui exige ses dependances rend
impossible la construction d'une instance incomplete. Avec l'injection par
champ, l'objet existe un instant avec ses champs a `null` ; si quelque chose lit
ce champ dans cet intervalle, on obtient un `NullPointerException` dont la
cause est loin du symptome.

**La dependance est testable.** Un constructeur public s'appelle depuis un test
ordinaire : `new DemoController(unCoachDeTest, ...)`. Un champ prive annote
`@Autowired` n'a pas de point d'entree : il faut soit lever un contexte Spring
entier, soit passer par la reflexion. Le test devient plus lent et plus fragile
que le code qu'il verifie.

**Les dependances sont visibles.** La signature du constructeur enumere tout ce
dont la classe a besoin. Un constructeur a huit parametres signale une classe
qui en fait trop, et ce signal est utile. Huit champs annotes ne se remarquent
pas.

**Le champ peut etre `final`.** Immuable apres construction, donc impossible a
remplacer par erreur, et sur dans un contexte concurrent.

Mesure annexe. L'enonce invite a retirer `@Autowired` du constructeur. Fait :
l'application demarre et `/dailyworkout` repond normalement. Depuis Spring 4.3,
l'annotation est facultative quand la classe n'a qu'un seul constructeur. Elle
est conservee dans le code livre par fidelite aux extraits de l'enonce.

## 3. Quand survient `NoUniqueBeanDefinitionException`

Elle survient quand le conteneur doit satisfaire un point d'injection declare
par son **type**, et que plusieurs beans de ce type sont eligibles sans qu'aucune
regle ne permette de trancher.

Dans ce projet, c'est l'exercice 5.2 : `DemoController` demande un `Coach`, et
quatre implementations sont annotees `@Component`. Message obtenu :

```
Parameter 0 of constructor in com.ioc.springcoredemo.rest.DemoController
required a single bean, but 4 were found:
	- baseballCoach
	- cricketCoach
	- tennisCoach
	- trackCoach
```

Deux facons de la resoudre.

**`@Qualifier("id")` au point d'injection.** On nomme le bean voulu. C'est
explicite et local : la decision est lisible la ou elle s'applique.

**`@Primary` sur une implementation.** On designe un candidat par defaut, qui
sera choisi chaque fois qu'aucun qualifier ne tranche. C'est global et implicite.

**Si les deux sont presents, `@Qualifier` gagne.** Mesure faite sur ce projet :

| Configuration | Reponse de `/dailyworkout` |
| --- | --- |
| `@Primary` sur `TrackCoach`, pas de qualifier | `Run a hard 5k!` |
| `@Primary` sur `TrackCoach` et `@Qualifier("cricketCoach")` | `Practice fast bowling for 15 minutes` |

La logique est coherente : `@Primary` repond a « lequel par defaut », tandis que
`@Qualifier` repond a « celui-ci, precisement ». Une demande precise prime sur un
defaut.

**Piege mesure.** Avec `@Primary` sur deux coachs et aucun qualifier,
l'application refuse de demarrer :

```
No qualifying bean of type 'com.ioc.springcoredemo.common.Coach' available:
more than one 'primary' bean found among candidates:
[baseballCoach, cricketCoach, tennisCoach, trackCoach]
```

Deux defauts ne font pas un defaut. Le second `@Primary` a ete retire apres la
mesure.

Ces trois situations ne peuvent pas coexister dans le code livre. Elles sont
figees dans `PrimaryVersusQualifierTest`, ou elles restent rejouables.

## 4. Comment Spring calcule l'identifiant par defaut d'un bean

Pour une classe detectee par le balayage de composants, l'identifiant est le
nom simple de la classe avec la premiere lettre en minuscule.
`CricketCoach` donne `cricketCoach`, `BaseballCoach` donne `baseballCoach`.

Pour une methode `@Bean`, l'identifiant par defaut est le **nom de la methode**.
La methode `swimCoach()` de `SportConfig` donnerait donc `swimCoach`.

Deux facons de le forcer :

- sur une classe : `@Component("monCoach")` ;
- sur une methode de configuration : `@Bean("aquatic")`, ce que fait
  `SportConfig` dans ce projet.

Verifie par `QualifierSelectionTest`, qui demande au conteneur la liste des
identifiants de type `Coach` et retrouve les quatre noms attendus.

## 5. Avantages et inconvenients de `@Lazy`

**Avantages.** Le demarrage est plus court, puisque les beans paresseux ne sont
pas construits. La memoire n'est pas occupee par des objets dont personne ne se
sert. C'est utile pour un composant lourd et rarement sollicite.

**Inconvenient majeur.** Les erreurs de configuration ne sont plus detectees au
demarrage. Une dependance manquante, un qualifier mal orthographie, une
connexion impossible : tout cela passait inapercu au lancement et surgit au
premier appel, c'est-a-dire en service plutot qu'au deploiement. On echange une
panne immediate et visible contre une panne differee et imprevisible. C'est un
mauvais echange dans la plupart des cas, d'ou « avec parcimonie ».

**Second inconvenient.** Le premier appel paie la construction. La latence du
premier utilisateur est plus mauvaise que celle des suivants.

Mesures faites sur ce projet :

| Configuration | Constructeurs executes au demarrage |
| --- | --- |
| Par defaut | les quatre coachs |
| `@Lazy` sur `TennisCoach` | les trois autres, `TennisCoach` absent |
| `spring.main.lazy-initialization=true` | aucun |

En mode global, le premier appel de `/dailyworkout` declenche la construction du
seul `CricketCoach`, et d'aucun autre. Le conteneur ne construit que ce que le
chemin demande.

`TennisCoach` peut etre paresseux parce que le controleur injecte un autre coach.
Un bean paresseux dont quelqu'un a besoin au demarrage serait construit quand
meme : `@Lazy` differe, il n'exempte pas.

## 6. `/check` passe de `true` a `false`

Ce qui a change : la portee de `CricketCoach`, passee du singleton par defaut au
prototype, par `@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)`.

Ce que cela prouve : en portee singleton, le conteneur ne cree qu'une instance et
la partage entre tous les points d'injection. Les deux champs du controleur
pointent sur le meme objet, donc `myCoach == anotherCoach` est vrai. En portee
prototype, le conteneur cree une instance neuve a chaque demande. Les deux champs
pointent sur deux objets distincts, donc la comparaison est fausse.

La comparaison porte sur l'identite des references, avec `==`, pas sur l'egalite
logique. C'est bien le nombre d'objets qui est mesure.

Confirmation independante par le compte des traces de construction :

| Portee | `/check` | Lignes `In constructor: CricketCoach` |
| --- | --- | --- |
| `singleton` | `true` | 1 |
| `prototype` | `false` | 2 |

Le compte des constructeurs dit la meme chose que la comparaison, par un autre
chemin. Une seule des deux mesures aurait pu etre un artefact.

### Tableau des scopes

| Scope | Description | Portee d'une instance |
| --- | --- | --- |
| `singleton` (defaut) | Une seule instance dans le conteneur | Toute la vie de l'application |
| `prototype` | Nouvelle instance a chaque demande | Celle de l'objet qui l'a demandee |
| `request` | Une instance par requete HTTP | La requete en cours, web uniquement |
| `session` | Une instance par session HTTP | La session de l'utilisateur, web uniquement |
| `application` | Une instance par `ServletContext` | L'application web entiere |

Les trois dernieres n'existent que dans un contexte web. Injecter un bean de
portee courte dans un bean singleton demande un mandataire
(`proxyMode = ScopedProxyMode.TARGET_CLASS`), faute de quoi le singleton
capturerait pour toujours la premiere instance rencontree.

## 7. Ordre du cycle de vie d'un bean singleton

1. Appel du **constructeur**.
2. **Injection des dependances** par setter ou par champ. Celles du constructeur
   sont deja passees a l'etape 1.
3. Appel des methodes annotees **`@PostConstruct`**. Toutes les dependances sont
   disponibles a ce moment, ce qui n'est pas le cas dans le constructeur.
4. **Usage** du bean.
5. Appel des methodes annotees **`@PreDestroy`**, a l'arret propre du conteneur.

Mesure sur ce projet, journal de l'application :

```
In constructor: CricketCoach
In doMyStartupStuff()
... usage ...
In doMyCleanupStuff()
```

La derniere ligne n'apparait qu'a l'arret propre : `Ctrl+C`, bouton Stop de
l'IDE, ou `SIGTERM`. Un `kill -9` ne laisse aucune chance au conteneur de
l'appeler.

**Pourquoi `@PreDestroy` n'est pas appele sur un prototype.** Le conteneur
construit un prototype, l'initialise, le remet au demandeur, puis **cesse d'en
garder la reference**. Il ne tient pas de registre des prototypes distribues. A
l'arret, il ne sait donc pas quels objets detruire : il n'a plus rien a
detruire. La responsabilite du nettoyage revient au code qui a demande
l'instance.

**Nuance mesuree, que l'enonce ne mentionne pas.** En portee prototype :

| Etape | Nombre d'appels |
| --- | --- |
| Constructeur | 2, un par point d'injection |
| `@PostConstruct` | 2 |
| `@PreDestroy` | 0 |

`@PostConstruct` **est** donc bien appele sur un prototype. Seule la destruction
est abandonnee. La difference tient au moment : l'initialisation a lieu pendant
que le conteneur tient encore l'objet, la destruction aurait lieu apres qu'il
l'a lache.

## 8. Trois cas ou l'on prefere `@Bean` a `@Component`

**La classe ne peut pas etre annotee.** Elle vient d'une bibliotheque tierce, ou
d'un module que l'on ne modifie pas. On ne peut pas y poser `@Component`, et le
balayage de composants ne la verra jamais. C'est le cas de `SwimCoach` dans ce
projet, volontairement laisse sans annotation.

**La construction est trop complexe pour un constructeur.** L'objet se fabrique
par une fabrique, demande un enchainement d'appels, ou depend d'une valeur
calculee. Une methode `@Bean` est du code ordinaire : elle peut faire tout cela.
Une annotation sur la classe ne le peut pas.

**On veut plusieurs instances configurees differemment du meme type.** Deux
sources de donnees, deux clients HTTP avec des delais differents, deux coachs
pour deux disciplines. `@Component` ne produit qu'un bean par classe ; plusieurs
methodes `@Bean` produisent autant d'instances distinctes, chacune avec son
identifiant.

Un quatrieme cas, utile a connaitre : `@Bean` permet de donner un identifiant
qui n'a aucun rapport avec le nom de la classe. Ici `@Bean("aquatic")` nomme le
bean par son role, pas par son implementation, de sorte que remplacer `SwimCoach`
par une autre classe ne changerait rien aux points d'injection.

## Ecarts assumes par rapport a l'enonce

Trois points ou ce depot ne fait pas litteralement ce que l'enonce decrit, avec
la raison.

**L'exercice 5.2 ne laisse aucun commit casse.** L'enonce demande de provoquer
une `NoUniqueBeanDefinitionException`. Un commit dans cet etat ferait echouer le
test `contextLoads` genere, donc la porte de pre-commit, donc l'integration
continue. L'ambiguite est prouvee autrement : `CoachAmbiguityTest` leve un
conteneur isole avec les quatre coachs et affirme que le demarrage echoue en
nommant les quatre beans. Le script `scripts/demo-ambiguite.sh` produit la trace
d'appel pour la capture, sur une copie temporaire des sources.

**L'etat final superpose plusieurs exercices.** 5.6 veut deux injections de
`cricketCoach`, 5.8 veut `@Qualifier("aquatic")`, 5.7 veut le singleton. Le
controleur recoit donc trois parametres, et `CricketCoach` est singleton. Les
etats intermediaires restent lisibles dans l'historique Git, un commit par
exercice.

**La version de Spring Boot est 4.0.9, pas 4.0.0.** L'extrait de `pom.xml` de
l'enonce ecrit `4.0.0`, ses consignes ecrivent `4.0.x`. La 4.0.9 est la derniere
stable de la branche au 1er novembre 2026, verifiee sur l'API Initializr. Elle
respecte les deux formulations.

## Extensions de la section 9

Les trois bonus sont faits. Ils vivent dans un commit separe, pour que le
livrable de base reste identifiable dans l'historique.

### 1. Portee `request`

`RequestIdentity` porte
`@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)`
et expose un identifiant tire au hasard a sa construction. Trois appels
successifs a `/requestid` renvoient trois valeurs differentes.

Le mandataire n'est pas une option. `DemoController` est un singleton, construit
une fois pour toutes au demarrage. Sans `proxyMode`, le conteneur devrait lui
injecter une instance de portee requete a un moment ou aucune requete n'existe,
et s'il y parvenait le controleur garderait cette instance pour toujours. Le
mandataire resout le probleme autrement : le controleur recoit un objet stable
qui delegue, a chaque appel, a l'instance de la requete en cours.

C'est la regle generale : un bean de portee courte injecte dans un bean de
portee longue demande un mandataire.

### 2. Injection d'une collection, et ce qu'elle coute

`/allworkouts` liste les cinq coachs. Spring fournit tous les beans d'un type
quand le point d'injection en demande une collection, sans qu'on ait a les
enumerer. `SwimCoach` y figure bien qu'il soit declare par `@Bean` et non par
`@Component` : ce qui compte est d'etre un bean, pas la facon dont on l'a
declare.

L'enonce suggere d'injecter `List<Coach>` au constructeur. Mesure faite dans les
deux sens sur ce projet :

| Injection | Constructeurs executes au demarrage |
| --- | --- |
| `List<Coach>` au constructeur | les cinq coachs, `TennisCoach` compris |
| `ObjectProvider<Coach>` | quatre, `TennisCoach` absent |

Injecter la liste directement **annule l'exercice 5.5**. Pour construire la
liste, le conteneur doit instancier chaque candidat, y compris celui qu'on avait
rendu paresseux. Le `@Lazy` n'est pas contourne : il est simplement satisfait,
puisque quelqu'un demande le bean.

Le controleur recoit donc un `ObjectProvider<Coach>`, qui ne resout la
collection qu'au premier appel de `/allworkouts`. Verification, dans cet ordre :

| Moment | `TennisCoach` construit |
| --- | --- |
| Juste apres le demarrage | 0 fois |
| Apres un appel a `/dailyworkout` | 0 fois |
| Apres un appel a `/allworkouts` | 1 fois |

Le bean paresseux est construit exactement quand il devient necessaire, et pas
avant. C'est la meilleure illustration de `@Lazy` de tout ce TP, et elle vient
d'un bonus.

### 3. `@Bean(initMethod, destroyMethod)`

`SwimCoach` porte deux methodes ordinaires, `startUp()` et `cleanUp()`, sans
aucune annotation. `SportConfig` les designe :

```java
@Bean(name = "aquatic", initMethod = "startUp", destroyMethod = "cleanUp")
```

Journal mesure :

```
In constructor: SwimCoach
In startUp(): SwimCoach
... usage ...
In cleanUp(): SwimCoach        a l'arret propre
```

Le comportement est celui de `@PostConstruct` et `@PreDestroy`, obtenu sans
toucher a la classe. C'est le meme motif que `@Bean` lui-meme : quand on ne peut
pas annoter une classe, la configuration prend le relais. Un cas reel typique
est une classe de bibliotheque dont il faut appeler `close()` a l'arret.

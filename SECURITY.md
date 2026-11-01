# Securite

## Signaler un probleme

Ce depot porte un travail pratique academique. Il n'a ni utilisateur, ni
donnee, ni exposition reseau au-dela de `localhost`. Pour signaler un probleme,
ouvrir une issue sur le depot.

## L'application n'a aucune securite, et c'est voulu

Aucun starter de securite n'est declare. Les trois points d'acces
(`/dailyworkout`, `/check`, `/allworkouts`) repondent sans authentification.

C'est une decision de l'enonce, pas un oubli. Le TP porte sur le conteneur
d'inversion de controle, et ses tests de recette s'ecrivent `curl
http://localhost:8080/dailyworkout`, sans identifiants. Ajouter Spring Security
protegerait tout par defaut, ferait repondre 401 a ces commandes, et masquerait
l'objet meme de l'exercice.

Consequence a connaitre, et a ne pas transposer : telle quelle, cette
application ne doit jamais etre exposee ailleurs que sur une boucle locale.

## Ce que le depot ne contient pas

Aucun secret, aucun jeton, aucun identifiant. L'application ne lit aucune
variable d'environnement et n'appelle aucun service distant. C'est pourquoi il
n'y a pas de `.env.example` : il n'y aurait rien a y mettre.

Le balayage de secrets tourne malgre tout, en pre-commit et sur **tout
l'historique** en integration continue. Une porte qui ne sert jamais reste une
porte : elle sert le jour ou quelqu'un colle une valeur par inadvertance.

## Chaine d'approvisionnement

- La distribution Maven telechargee par le wrapper est verrouillee par
  empreinte (`distributionSha256Sum`), verifiee le 2026-11-01 contre le fichier
  `.sha512` publie par Apache.
- Les actions GitHub sont epinglees par empreinte de commit, jamais par
  etiquette mouvante : une etiquette se redeplace, une empreinte non.
- Aucune mise a jour automatique de dependances n'est activee. Sur un depot qui
  va etre note, une demande de fusion automatique modifierait le code rendu.

## Portee

Le travail se fait sur un poste local, sur `localhost` uniquement. Aucun
deploiement, aucun conteneur, aucun hebergement.

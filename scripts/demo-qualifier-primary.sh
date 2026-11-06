#!/usr/bin/env bash
# Exercices 5.3 et 5.4 : la reponse de /dailyworkout avec @Qualifier, puis avec
# @Primary, puis avec les deux a la fois.
#
# L'etat final du depot qualifie le coach « aquatic » (exercice 5.8) : ces
# reponses n'y existent plus. Le script les rejoue depuis les commits de 5.3 et
# de 5.4, dans un dossier temporaire. Le depot n'est pas modifie.
#
# Quand : aucune application ne doit tourner sur le port 8080.
# Capture a prendre : 06-qualifier-primary.png
set -uo pipefail
. "$(dirname "$0")/lib-rejouer.sh"

COMMIT=4b792ee

echo "===== 5.3 : @Qualifier seul (commit ccf6cbc, tel quel) ====="
extraire ccf6cbc
grep -h 'public DemoController' "$copie/$P/rest/DemoController.java"
interroger /dailyworkout "Practice fast bowling for 15 minutes"

echo "===== 5.4 : @Primary seul (commit $COMMIT, @Qualifier retire) ====="
extraire "$COMMIT"
sed -i 's/@Qualifier("cricketCoach") //' "$copie/$P/rest/DemoController.java"
grep -h -B1 'class TrackCoach' "$copie/$P/common/TrackCoach.java"
grep -h 'public DemoController' "$copie/$P/rest/DemoController.java"
interroger /dailyworkout "Run a hard 5k!"

echo "===== 5.4 : les deux a la fois (commit $COMMIT, tel quel) ====="
extraire "$COMMIT"
grep -h -B1 'class TrackCoach' "$copie/$P/common/TrackCoach.java"
grep -h 'public DemoController' "$copie/$P/rest/DemoController.java"
interroger /dailyworkout "Practice fast bowling for 15 minutes"

echo "Conclusion : quand les deux sont presents, @Qualifier l'emporte sur @Primary."

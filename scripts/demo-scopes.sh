#!/usr/bin/env bash
# Exercice 5.6 : /check renvoie true en portee singleton, puis false en portee
# prototype.
#
# L'etat final du depot remet CricketCoach en singleton (exercice 5.7) : le
# false n'y existe plus. Le script le rejoue depuis le commit de 5.6, dans un
# dossier temporaire. Le depot n'est pas modifie.
#
# Quand : aucune application ne doit tourner sur le port 8080.
# Capture a prendre : 07-scopes.png
set -uo pipefail
. "$(dirname "$0")/lib-rejouer.sh"

COMMIT=1c627be

echo "===== 5.6 : singleton, la portee par defaut (commit $COMMIT, @Scope retire) ====="
extraire "$COMMIT"
sed -i '/^@Scope(/d' "$copie/$P/common/CricketCoach.java"
grep -h -B1 'class CricketCoach' "$copie/$P/common/CricketCoach.java"
interroger /check "Comparing beans: myCoach == anotherCoach, true"

echo "===== 5.6 : prototype (commit $COMMIT, tel quel) ====="
extraire "$COMMIT"
grep -h -B2 'class CricketCoach' "$copie/$P/common/CricketCoach.java"
interroger /check "Comparing beans: myCoach == anotherCoach, false"

echo "Conclusion : en prototype, chaque injection recoit sa propre instance."

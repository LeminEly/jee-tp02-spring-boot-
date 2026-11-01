#!/usr/bin/env bash
# Exercice 5.7 : montre les trois etapes du cycle de vie d'un bean singleton,
# dans l'ordre, sans intervention manuelle.
#
# Le script lance l'application, attend qu'elle soit prete, appelle un point
# d'acces, puis l'arrete proprement. L'arret propre est ce qui declenche
# @PreDestroy : un kill -9 ne le declencherait pas.
#
# Quand : aucune application ne doit tourner sur le port 8080.
# Capture a prendre : 05-cycle-de-vie.png
set -uo pipefail
cd "$(dirname "$0")/.."

if [ -f .sdkmanrc ]; then
	version=$(sed -n 's/^java=//p' .sdkmanrc)
	candidat="${SDKMAN_DIR:-$HOME/.sdkman}/candidates/java/$version"
	if [ -x "$candidat/bin/javac" ]; then
		export JAVA_HOME="$candidat"
		export PATH="$JAVA_HOME/bin:$PATH"
	fi
fi

journal=$(mktemp)
trap 'rm -f "$journal"' EXIT

echo "===== 5.7 : cycle de vie de CricketCoach ====="
echo "\$ ./mvnw package && java -jar target/springcoredemo-0.0.1-SNAPSHOT.jar"
./mvnw -q -B package -DskipTests
java -jar target/springcoredemo-0.0.1-SNAPSHOT.jar > "$journal" 2>&1 &
pid=$!

for _ in $(seq 1 60); do
	grep -q 'Started SpringcoredemoApplication' "$journal" && break
	kill -0 "$pid" 2>/dev/null || { echo "L'application s'est arretee avant d'etre prete."; tail -20 "$journal"; exit 1; }
	sleep 1
done

echo
echo "-- au demarrage :"
grep -E 'In constructor|In doMyStartupStuff' "$journal"

echo
echo "\$ curl http://localhost:8080/check"
curl -fsS http://localhost:8080/check || echo "[echec : /check n'a pas rendu 2xx]"
echo

echo
echo "-- arret propre (equivalent du Ctrl+C ou du bouton Stop de l'IDE) :"
kill "$pid"
for _ in $(seq 1 20); do
	grep -q 'In doMyCleanupStuff' "$journal" && break
	sleep 1
done
grep -E 'In doMyCleanupStuff' "$journal" || echo "[@PreDestroy n'a pas ete appele]"
wait "$pid" 2>/dev/null

echo
echo "-- l'ordre complet :"
grep -nE 'In constructor|In doMyStartupStuff|In doMyCleanupStuff' "$journal"

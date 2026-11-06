#!/usr/bin/env bash
# Section 9 : les trois extensions facultatives.
# Quand : application lancee par scripts/run.sh dans un autre terminal.
# Capture a prendre : 04-bonus.png
#
# -f sur curl : sans lui, curl rend 0 sur une reponse 4xx et le script
# afficherait du vide au lieu de signaler l'echec. Registre du socle, A.38.
set -uo pipefail

BASE=${BASE:-http://localhost:8080}

appeler() { # $1 = chemin
	if ! curl -fsS "$BASE$1"; then
		echo "[echec : $BASE$1 n'a pas rendu 2xx]"
	fi
}

echo "===== Bonus 2 : injection d'une collection, GET /allworkouts ====="
echo "\$ curl $BASE/allworkouts"
appeler /allworkouts
echo
echo "Spring a injecte tous les beans de type Coach, y compris SwimCoach qui"
echo "est declare par @Bean et non par @Component."
echo

echo "===== Bonus 1 : portee requete, GET /requestid trois fois ====="
for _ in 1 2 3; do
	echo "\$ curl $BASE/requestid"
	appeler /requestid
done
echo
echo "Trois identifiants differents : une instance par requete HTTP. Le"
echo "controleur est pourtant un singleton, cree une seule fois."

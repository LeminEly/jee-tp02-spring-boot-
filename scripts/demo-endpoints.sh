#!/usr/bin/env bash
# Montre les deux points d'acces : /dailyworkout puis /check.
# Quand : application lancee par scripts/run.sh dans un autre terminal.
# Capture a prendre : 03-endpoints.png
#
# -f sur curl : sans lui, curl rend 0 sur une reponse 4xx et le script
# afficherait du vide au lieu de signaler l'echec. Registre du socle, A.38.
set -uo pipefail

BASE=${BASE:-http://localhost:8080}

montrer() { # $1 = titre, $2 = chemin
	echo "===== $1 ====="
	echo "\$ curl $BASE$2"
	if ! curl -fsS "$BASE$2"; then
		echo "[echec : $BASE$2 n'a pas rendu 2xx]"
	fi
	echo
	echo
}

montrer "5.8 : GET /dailyworkout" "/dailyworkout"
montrer "5.6 : GET /check" "/check"

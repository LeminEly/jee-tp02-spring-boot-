# Fonctions partagees par les scripts qui rejouent un etat passe du depot.
# A sourcer, pas a executer.
#
# Un etat passe est extrait d'un commit dans un dossier temporaire, compile et
# lance la. Le depot n'est jamais modifie, et la branche courante non plus.

PORT=8080
P=src/main/java/com/ioc/springcoredemo
copies=""
trap 'rm -rf $copies' EXIT

cd "$(dirname "$0")/.."

if [ -f .sdkmanrc ]; then
	version=$(sed -n 's/^java=//p' .sdkmanrc)
	candidat="${SDKMAN_DIR:-$HOME/.sdkman}/candidates/java/$version"
	if [ -x "$candidat/bin/javac" ]; then
		export JAVA_HOME="$candidat"
		export PATH="$JAVA_HOME/bin:$PATH"
	fi
fi

# Port occupe : l'application echouerait au demarrage, ou pire, curl
# interrogerait une autre application et la capture mentirait.
if command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | grep -q ":$PORT "; then
	echo "Le port $PORT est occupe. Arretez l'application en cours, puis relancez." >&2
	exit 1
fi

extraire() { # $1 = commit ; place les sources dans $copie
	copie=$(mktemp -d)
	copies="$copies $copie"
	git archive "$1" | tar -x -C "$copie"
}

interroger() { # $1 = chemin, $2 = reponse attendue ; travaille dans $copie
	if ! (cd "$copie" && ./mvnw -q -B package -DskipTests) > "$copie/build.log" 2>&1; then
		echo "[echec de compilation]" >&2
		tail -20 "$copie/build.log" >&2
		exit 1
	fi
	java -jar "$copie/target/springcoredemo-0.0.1-SNAPSHOT.jar" > "$copie/app.log" 2>&1 &
	pid=$!
	for _ in $(seq 1 60); do
		grep -q 'Started SpringcoredemoApplication' "$copie/app.log" && break
		kill -0 "$pid" 2>/dev/null || { echo "L'application s'est arretee avant d'etre prete." >&2; tail -20 "$copie/app.log" >&2; exit 1; }
		sleep 1
	done

	echo "\$ curl http://localhost:$PORT$1"
	reponse=$(curl -fsS "http://localhost:$PORT$1") || reponse="[echec : $1 n'a pas rendu 2xx]"
	echo "$reponse"
	kill "$pid"
	wait "$pid" 2>/dev/null

	# Une capture ne vaut que si elle montre ce qu'elle pretend montrer.
	# Registre du socle, A.39.
	if [ "$reponse" != "$2" ]; then
		echo >&2
		echo "ATTENTION : reponse attendue « $2 ». Ne pas capturer." >&2
		exit 1
	fi
	echo
}

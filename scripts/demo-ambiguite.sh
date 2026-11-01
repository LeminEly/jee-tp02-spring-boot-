#!/usr/bin/env bash
# Exercice 5.2 : montre la NoUniqueBeanDefinitionException que l'enonce demande
# de provoquer.
#
# Le depot n'est jamais laisse casse. Le script copie les sources dans un
# dossier temporaire, y provoque l'ambiguite, compile et lance cette copie, puis
# efface tout. Aucun fichier du depot n'est modifie.
#
# Quand : a tout moment, mais le port 8080 doit etre libre.
# Capture a prendre : 01-ambiguite.png
set -uo pipefail
cd "$(dirname "$0")/.."
racine=$(pwd)

CONTROLEUR=src/main/java/com/ioc/springcoredemo/rest/DemoController.java
TRACK=src/main/java/com/ioc/springcoredemo/common/TrackCoach.java

# Le port doit etre libre, sinon l'application echouerait sur « Port 8080 was
# already in use » et le script presenterait cette erreur-la comme si c'etait
# l'ambiguite. Une sonde qui ne verifie pas ce qu'elle a attrape ment.
if command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | grep -q ':8080 '; then
	echo "Le port 8080 est occupe. Arretez l'application en cours, puis relancez." >&2
	exit 1
fi

if [ -f .sdkmanrc ]; then
	version=$(sed -n 's/^java=//p' .sdkmanrc)
	candidat="${SDKMAN_DIR:-$HOME/.sdkman}/candidates/java/$version"
	if [ -x "$candidat/bin/javac" ]; then
		export JAVA_HOME="$candidat"
		export PATH="$JAVA_HOME/bin:$PATH"
	fi
fi

copie=$(mktemp -d)
trap 'rm -rf "$copie"' EXIT

cp -r pom.xml mvnw .mvn src "$copie/"
cd "$copie"

# Deux modifications, et il en faut bien deux. Retirer les @Qualifier ne suffit
# pas : depuis l'exercice 5.4, TrackCoach porte @Primary, et Spring choisirait
# ce bean par defaut au lieu de se plaindre. Il faut donc aussi retirer le
# primaire pour qu'aucune regle ne permette de trancher.
sed -i 's/@Qualifier("[a-zA-Z]*") //g' "$CONTROLEUR"
sed -i '/^@Primary$/d; /^import org.springframework.context.annotation.Primary;$/d' "$TRACK"

echo "===== 5.2 : quatre Coach, aucun qualifier, aucun primaire ====="
echo "\$ grep -A 5 'public DemoController' $CONTROLEUR"
grep -A 5 'public DemoController' "$CONTROLEUR"
echo
echo "\$ ./mvnw spring-boot:run"
echo "   (compilation puis lancement, quelques secondes)"
echo

journal=$(mktemp)
# Une limite de duree : si l'application demarrait malgre tout, elle resterait
# au premier plan indefiniment et le script semblerait bloque. Mieux vaut un
# echec franc qu'une attente muette.
timeout 180 ./mvnw -q -B spring-boot:run > "$journal" 2>&1

# Les chemins des .class sont retires : ils noieraient les quatre identifiants
# de beans, qui sont le vrai sujet de l'exercice.
grep -A 20 'APPLICATION FAILED TO START' "$journal" \
	| sed -E 's#(- [a-zA-Z]+Coach): defined in .*#\1#'

# Le point qui compte : verifier que l'echec est bien celui qu'on voulait.
# Un port occupe, une erreur de compilation ou un demarrage reussi donneraient
# une capture fausse.
echo
if grep -q 'NoUniqueBeanDefinitionException\|required a single bean' "$journal"; then
	echo "Verifie : l'echec est bien une ambiguite d'injection."
	echo
	echo "L'enonce annonce 4 candidats, il y en a 5 ici. Le cinquieme est"
	echo "« aquatic », le SwimCoach declare par @Bean a l'exercice 5.8. Au"
	echo "moment ou l'enonce decrit l'exercice 5.2, il n'existait pas encore."
else
	echo "ATTENTION : l'application n'a pas echoue sur une ambiguite d'injection." >&2
	echo "Cette sortie ne prouve pas ce que l'exercice 5.2 demande. Ne pas capturer." >&2
	echo "Les 20 dernieres lignes du journal :" >&2
	tail -20 "$journal" >&2
	rm -f "$journal"
	exit 1
fi
rm -f "$journal"

echo
echo "Le depot, lui, est intact : la copie de travail vient d'etre effacee."
cd "$racine"
echo "\$ grep -A 5 'public DemoController' $CONTROLEUR"
grep -A 5 'public DemoController' "$CONTROLEUR"

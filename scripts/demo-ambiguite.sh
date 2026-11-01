#!/usr/bin/env bash
# Exercice 5.2 : montre la NoUniqueBeanDefinitionException que l'enonce demande
# de provoquer.
#
# Le depot n'est jamais laisse casse. Le script copie les sources dans un
# dossier temporaire, y retire le @Qualifier, compile et lance cette copie, puis
# efface tout. Aucun fichier du depot n'est modifie.
#
# Quand : a tout moment, aucune application n'a besoin de tourner.
# Capture a prendre : 01-ambiguite.png
set -uo pipefail
cd "$(dirname "$0")/.."
racine=$(pwd)

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
# On retire le qualifier : quatre Coach candidats, aucun moyen de choisir.
sed -i 's/@Qualifier("[a-zA-Z]*") //g' src/main/java/com/ioc/springcoredemo/rest/DemoController.java

echo "===== 5.2 : quatre Coach, aucun qualifier ====="
echo "\$ grep 'public DemoController' src/main/java/com/ioc/springcoredemo/rest/DemoController.java"
grep 'public DemoController' src/main/java/com/ioc/springcoredemo/rest/DemoController.java
echo
echo "\$ ./mvnw spring-boot:run"
echo
# Les chemins des .class sont retires : ils noieraient les quatre identifiants
# de beans, qui sont le vrai sujet de l'exercice.
./mvnw -q -B spring-boot:run 2>&1 \
	| grep -A 20 'APPLICATION FAILED TO START' \
	| sed -E 's#(- [a-zA-Z]+Coach): defined in .*#\1#'

echo
echo "Le depot, lui, est intact : la copie de travail vient d'etre effacee."
cd "$racine"
echo "\$ grep 'public DemoController' src/main/java/com/ioc/springcoredemo/rest/DemoController.java"
grep 'public DemoController' src/main/java/com/ioc/springcoredemo/rest/DemoController.java

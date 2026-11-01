#!/usr/bin/env bash
# Lance l'application sur le port 8080 par le plugin Maven.
# Quand : dans un premier terminal, avant de lancer les scripts de demo.
#         Laisser tourner. Ctrl+C pour arreter proprement, ce qui declenche
#         aussi le @PreDestroy observe a l'exercice 5.7.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .sdkmanrc ]; then
	version=$(sed -n 's/^java=//p' .sdkmanrc)
	candidat="${SDKMAN_DIR:-$HOME/.sdkman}/candidates/java/$version"
	if [ -x "$candidat/bin/javac" ]; then
		export JAVA_HOME="$candidat"
		export PATH="$JAVA_HOME/bin:$PATH"
	fi
fi

echo "===== Lancement de springcoredemo (plugin Maven) ====="
echo "\$ ./mvnw spring-boot:run"
exec ./mvnw spring-boot:run

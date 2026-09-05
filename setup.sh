#!/usr/bin/env bash
#
# Baixa o ANTLR 4.13.2 (jar completo) para tools/.
# O jar nao e versionado no repositorio (ver .gitignore).
set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSAO="4.13.2"
ANTLR_JAR="$BASE/tools/antlr-${VERSAO}-complete.jar"
PLANTUML_JAR="$BASE/tools/plantuml.jar"

mkdir -p "$BASE/tools"

if [ -f "$ANTLR_JAR" ]; then
    echo "ANTLR ${VERSAO} ja presente em tools/."
else
    echo "Baixando ANTLR ${VERSAO}..."
    curl -fSL -o "$ANTLR_JAR" "https://www.antlr.org/download/antlr-${VERSAO}-complete.jar"
fi

if [ -f "$PLANTUML_JAR" ]; then
    echo "PlantUML ja presente em tools/."
else
    echo "Baixando PlantUML (usado para gerar os diagramas de ferrovia em diagramas/)..."
    curl -fSL -o "$PLANTUML_JAR" "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
fi

echo
echo "Java em uso:"
java -version 2>&1 | sed 's/^/    /'
echo
echo "ANTLR em uso:"
java -jar "$ANTLR_JAR" 2>&1 | head -1 | sed 's/^/    /'
echo
echo "Pronto. Agora rode ./run.sh"
echo "Para regerar os diagramas: java -jar tools/plantuml.jar -tpng -o img diagramas/graphql.puml diagramas/sqlite.puml"

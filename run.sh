#!/usr/bin/env bash
#
# TP1 - Lexer / Linguagens de Programacao 2026-II
#
# Gera os lexers Java a partir das duas gramaticas ANTLR4, compila o driver
# DumpTokens e executa todos os casos de teste descritos em inputs/casos.tsv,
# gravando a saida bruta do ANTLR4 em out/.
#
# Uso: ./run.sh   (Linux, macOS ou Git Bash no Windows)
set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANTLR_JAR="$BASE/tools/antlr-4.13.2-complete.jar"
GEN="$BASE/gen"
OUT="$BASE/out"

# Portabilidade Windows: no Git Bash o java e um binario nativo, entao espera
# caminho no formato C:\... e ';' como separador de classpath.
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) CPSEP=';'; caminho() { cygpath -w "$1"; } ;;
    *)                    CPSEP=':'; caminho() { printf '%s' "$1"; } ;;
esac

PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

if [ ! -f "$ANTLR_JAR" ]; then
    echo "ANTLR nao encontrado. Rode ./setup.sh primeiro." >&2
    exit 1
fi

echo "==> 1/4 Gerando os lexers com o ANTLR 4.13.2"
rm -rf "$GEN"
mkdir -p "$GEN"
java -jar "$(caminho "$ANTLR_JAR")" -Dlanguage=Java -o "$(caminho "$GEN")" \
    -no-listener -no-visitor \
    "$(caminho "$BASE/grammars/GraphQL.g4")" \
    "$(caminho "$BASE/grammars/SQLiteLexer.g4")" 2>&1 | sed 's/^/    /'

echo "==> 2/4 Compilando o driver"
javac -nowarn -cp "$(caminho "$ANTLR_JAR")" -d "$(caminho "$GEN/classes")" \
    "$GEN"/*.java "$BASE/src/DumpTokens.java" 2>&1 | sed 's/^/    /'

echo "==> 3/4 Executando os casos de teste"
mkdir -p "$OUT"
RAW="$OUT/saida-antlr4.txt"
: > "$RAW"

while IFS=$'\t' read -r lexer regra expect arquivo justificativa; do
    case "$lexer" in \#*|"") continue ;; esac
    # clone Windows feito antes do .gitattributes pode trazer CR no fim da linha
    justificativa="${justificativa%$'\r'}"
    arquivo="${arquivo%$'\r'}"
    {
        echo "======================================================================"
        echo "CASO     : $lexer / $regra / $expect"
        echo "ARQUIVO  : $arquivo"
        echo "MOTIVO   : $justificativa"
        java -cp "$(caminho "$ANTLR_JAR")$CPSEP$(caminho "$GEN/classes")" \
            DumpTokens "$lexer" "$(caminho "$BASE/$arquivo")" 2>&1
        echo
    } >> "$RAW"
done < "$BASE/inputs/casos.tsv"

echo "==> 4/4 Montando a tabela de tokens"
"$PY" "$BASE/src/tabela.py" "$RAW" > "$OUT/tabela-tokens.md"

echo
echo "Pronto."
echo "  saida bruta : out/saida-antlr4.txt"
echo "  tabela      : out/tabela-tokens.md"

#!/usr/bin/env bash
#
# TP1 - Lexer / Linguagens de Programacao 2026-II
#
# Gera os lexers Java a partir das duas gramaticas ANTLR4, compila o driver
# DumpTokens e executa todos os casos de teste descritos em inputs/casos.tsv,
# gravando a saida bruta do ANTLR4 em out/.
#
# Uso: ./run.sh
set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANTLR_JAR="$BASE/tools/antlr-4.13.2-complete.jar"
GEN="$BASE/gen"
OUT="$BASE/out"

if [ ! -f "$ANTLR_JAR" ]; then
    echo "ANTLR nao encontrado. Rode ./setup.sh primeiro." >&2
    exit 1
fi

echo "==> 1/4 Gerando os lexers com o ANTLR 4.13.2"
rm -rf "$GEN"
mkdir -p "$GEN"
java -jar "$ANTLR_JAR" -Dlanguage=Java -o "$GEN" -no-listener -no-visitor \
    "$BASE/grammars/GraphQL.g4" "$BASE/grammars/SQLiteLexer.g4" 2>&1 | sed 's/^/    /'

echo "==> 2/4 Compilando o driver"
javac -nowarn -cp "$ANTLR_JAR" -d "$GEN/classes" \
    "$GEN"/*.java "$BASE/src/DumpTokens.java" 2>&1 | sed 's/^/    /'

echo "==> 3/4 Executando os casos de teste"
mkdir -p "$OUT"
RAW="$OUT/saida-antlr4.txt"
: > "$RAW"

while IFS=$'\t' read -r lexer regra expect arquivo justificativa; do
    case "$lexer" in \#*|"") continue ;; esac
    {
        echo "======================================================================"
        echo "CASO     : $lexer / $regra / $expect"
        echo "ARQUIVO  : $arquivo"
        echo "MOTIVO   : $justificativa"
        java -cp "$ANTLR_JAR:$GEN/classes" DumpTokens "$lexer" "$BASE/$arquivo" 2>&1
        echo
    } >> "$RAW"
done < "$BASE/inputs/casos.tsv"

echo "==> 4/4 Montando a tabela de tokens"
python3 "$BASE/src/tabela.py" "$RAW" > "$OUT/tabela-tokens.md"

echo
echo "Pronto."
echo "  saida bruta : out/saida-antlr4.txt"
echo "  tabela      : out/tabela-tokens.md"

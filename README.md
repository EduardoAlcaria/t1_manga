# TP1 - Analisadores Lexicos (Lexers) com ANTLR4

**PUCRS / Escola Politecnica - Linguagens de Programacao - 2026/II**

## Grupo

- Arthur Mello Pimentel
- Eduardo Alcaria Lopes
- Ethan Soares S. da Rosa

## Analisadores lexicos reservados

| # | Lexer | Origem |
|---|---|---|
| 1 | `GraphQL.g4` | <https://github.com/antlr/grammars-v4/blob/master/graphql/GraphQL.g4> |
| 2 | `SQLiteLexer.g4` | <https://github.com/antlr/grammars-v4/blob/master/sql/sqlite/SQLiteLexer.g4> |

Reserva registrada no forum do Moodle em 01/09/2026, 20:00.

## Regras analisadas

| Categoria | GraphQL | SQLite |
|---|---|---|
| Identificador | `NAME` | `IDENTIFIER` |
| Numero | `INT` / `FLOAT` | `NUMERIC_LITERAL` |
| Texto | `STRING` | `STRING_LITERAL` |

A analise comparativa esta em [`ANALISE.md`](ANALISE.md).

## Estrutura do repositorio

```
grammars/       gramaticas originais, sem modificacao
inputs/         24 arquivos de entrada (3 regras x 4 casos x 2 lexers)
inputs/casos.tsv  manifesto: lexer, regra, expectativa e justificativa de cada caso
src/            DumpTokens.java (driver) e tabela.py (formatador)
diagramas/      fontes dos diagramas de ferrovia (BottleCaps e PlantUML)
tools/          jar do ANTLR (baixado por setup.sh, nao versionado)
gen/            lexers Java gerados pelo ANTLR (nao versionado)
out/            resultados do ANTLR4 (nao versionado, regeravel)
```

## Ferramentas e instalacao

### 1. Java (JDK 11 ou superior)

Necessario para rodar o ANTLR e compilar os lexers gerados.

```bash
# Arch Linux
sudo pacman -S jdk-openjdk

# Debian / Ubuntu
sudo apt install default-jdk

# Verificacao
java -version
javac -version
```

Ambiente usado neste trabalho: OpenJDK 26.0.1 (instalado via [mise](https://mise.jdx.dev/)).

### 2. ANTLR 4.13.2

Baixado automaticamente pelo `setup.sh` para `tools/`:

```bash
./setup.sh
```

Equivalente manual:

```bash
mkdir -p tools
curl -L -o tools/antlr-4.13.2-complete.jar \
     https://www.antlr.org/download/antlr-4.13.2-complete.jar
```

A instalacao "global" recomendada pela documentacao oficial (aliases `antlr4` e
`grun`) tambem funciona, mas aqui o jar fica dentro do projeto para que os
resultados sejam reproduziveis por qualquer integrante sem configurar o
`CLASSPATH` da maquina:

```bash
# alternativa global, conforme https://www.antlr.org/download.html
export CLASSPATH=".:/usr/local/lib/antlr-4.13.2-complete.jar:$CLASSPATH"
alias antlr4='java -jar /usr/local/lib/antlr-4.13.2-complete.jar'
alias grun='java org.antlr.v4.gui.TestRig'
```

### 3. Python 3

Usado apenas por `src/tabela.py` para converter a saida bruta do ANTLR em
tabela Markdown. Nenhuma dependencia externa.

### 4. Ferramentas de diagrama

- **PlantUML** (usado neste repositorio) - `tools/plantuml.jar`, baixado por
  `setup.sh` junto com o ANTLR. Gera os diagramas de `diagramas/graphql.puml`
  e `diagramas/sqlite.puml` diretamente em `diagramas/img/`:

  ```bash
  java -jar tools/plantuml.jar -tpng -o img diagramas/graphql.puml diagramas/sqlite.puml
  ```

  Resultado: `diagramas/img/graphql.png` e `diagramas/img/sqlite.png`, prontos
  para colar no relatorio.

- **BottleCaps RR** (alternativa manual) - <https://www.bottlecaps.de/rr/ui>,
  aba *Edit Grammar*, colar `diagramas/regras.ebnf`, depois *View Diagram*.
- **Extensao vscode-antlr4** (`mike-lischke.vscode-antlr4`) - abre `.g4` no VS
  Code e gera o diagrama automaticamente pelo *code lens* "Railroad diagram"
  acima de cada regra. Nao exige arquivo intermediario.

#### Nota sobre um bug do PlantUML encontrado no trabalho

A versao do PlantUML usada (baixada de
`github.com/plantuml/plantuml/releases/latest` em 02/09/2026) trava com
`java.util.NoSuchElementException` em `EbnfEngine.alternation()` sempre que uma
alternativa de topo (separada por `|`) contem, ela propria, uma alternacao
aninhada dentro de `{ }`. A regra `IDENTIFIER` do SQLite tem exatamente essa
forma em tres de suas quatro alternativas. Contornamos dividindo a regra em
quatro sub-diagramas (`IDENTIFIER_ASPAS_DUPLAS`, `IDENTIFIER_CRASE`,
`IDENTIFIER_COLCHETES`, `IDENTIFIER_NUA`) em `diagramas/sqlite.puml`. A forma
completa e unificada aparece sem problema no BottleCaps (`regras.ebnf`) e na
extensao vscode-antlr4, que nao tem essa limitacao - o proprio achado virou
material de comparacao entre ferramentas no relatorio (`ANALISE.md`, secao 5).

## Como reproduzir os resultados

```bash
./setup.sh   # baixa o ANTLR 4.13.2 (uma vez)
./run.sh     # gera os lexers, compila e executa os 24 casos
```

No Windows os dois scripts rodam no **Git Bash** (instalado junto com o Git for
Windows), sem WSL. O `run.sh` detecta `MINGW/MSYS/CYGWIN` via `uname -s` e passa
os caminhos por `cygpath -w`, usando `;` como separador de classpath, que e o
que o `java` nativo espera. O `.gitattributes` forca LF nos scripts para o Git
Bash nao falhar com `$'\r': command not found`, e marca `inputs/` como `-text`
para que os arquivos de teste cheguem ao lexer byte a byte.


O `run.sh` executa quatro etapas:

1. `java -jar tools/antlr-4.13.2-complete.jar -Dlanguage=Java -o gen ...` gera
   `GraphQLLexer.java` e `SQLiteLexer.java`;
2. `javac` compila os lexers gerados junto com `src/DumpTokens.java`;
3. cada caso de `inputs/casos.tsv` e executado e a saida vai para
   `out/saida-antlr4.txt`;
4. `src/tabela.py` resume tudo em `out/tabela-tokens.md`.

O driver `DumpTokens` instala um `BaseErrorListener` proprio no lexer para
capturar as mensagens `token recognition error` de forma estruturada, em vez de
deixa-las escapar para o `stderr`.

## Rodando um caso isolado

```bash
java -cp tools/antlr-4.13.2-complete.jar:gen/classes \
     DumpTokens GraphQL inputs/graphql/num_bad_1.txt
```

Saida:

```
ENTRADA  : 10_000.00
GRAMATICA: GraphQL
TOKENS   : 3
  INT                '10'
  NAME               '_000'
  INT                '0'
ERROS    : 1
  line 1:6 token recognition error at: '.0'
```

## Uso de IA generativa

Declarado conforme exigido pelo enunciado. Ver secao *Metodologia* em
[`ANALISE.md`](ANALISE.md).

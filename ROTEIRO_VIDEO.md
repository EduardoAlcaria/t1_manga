# Roteiro de falas - TP1 Lexer (GraphQL x SQLite)

Estrutura exigida pelo enunciado: Introdução (~1 min) / Demonstração (~5 min)
/ Diagramas (~2 min) / Conclusões (~2 min). Falas divididas entre Arthur,
Eduardo e Ethan - ajustem os nomes/ordem como preferirem, mas todo mundo
precisa falar (penalidade ZERO pra quem não participa).

Isto é um **guia**, não um texto pra decorar - leiam, entendam, falem com as
próprias palavras. Falas robotizadas ou lidas contam ZERO pelo enunciado.

---

capa "Bom dia. Nosso trabalho compara dois analisadores léxicos - lexers -
gerados com a ferramenta ANTLR4: o lexer da linguagem de consultas GraphQL e
o lexer do banco de dados SQLite, ambos retirados do repositório oficial
grammars-v4."

capa "Em vez de escrever um lexer do zero, o enunciado pede pra escolher dois
prontos e comparar como cada um reconhece a mesma categoria de token.
Escolhemos três categorias presentes nos dois: identificador, número e
texto, e testamos cada uma com entradas reais rodadas no ANTLR 4.13.2 -
tudo documentado no nosso repositório, sem nenhum resultado inventado."

---

## Bloco 1 - Introdução (~1 min)

Arthur -> "Somos Arthur, Eduardo e Ethan, turma de Linguagens de Programação
2026/2. O GraphQL.g4 é uma gramática combinada - tem parser e lexer juntos -
baseada na especificação oficial da linguagem. Já o SQLiteLexer.g4 é uma
`lexer grammar` pura, escrita por Bart Kiers e Martin Mirchev, e traz cerca
de 200 tokens, a maioria palavras reservadas do SQL."

Arthur -> "A gente reservou os dois no fórum do Moodle no dia 1 de setembro.
O foco do trabalho é só a parte léxica - não mexemos em parser, nem em
compilador completo, só no jeito como cada gramática corta o texto em
tokens."

---

## Bloco 2 - Demonstração prática (~5 min)

### Eduardo -> Identificador: `NAME` (GraphQL) x `IDENTIFIER` (SQLite)

"A primeira regra que comparamos é a de identificador - nome de campo, nome
de coluna. No GraphQL, `NAME` é simples: uma letra ou underscore no
começo, seguido de letras, dígitos ou underscore. Testamos
`userProfile_2024` e `_internalFieldName` - os dois viram um único token
`NAME`, sem erro."

"Já `IDENTIFIER` do SQLite tem quatro formas diferentes: entre aspas duplas,
entre crase, entre colchetes, ou nua. Testamos `"minha coluna"` com aspas
duplas e `[Order Details]` com colchetes - as duas viram `IDENTIFIER` válido,
inclusive com espaço dentro, o que o GraphQL nunca aceitaria."

"O caso mais interessante: testamos `'minha coluna'`, com aspa **simples**,
no SQLite. A gente esperava um erro, mas o ANTLR devolveu 1 token
`STRING_LITERAL` - porque aspa simples em SQLite é string, não
identificador. E o inverso também vale: no GraphQL, `"texto"` com aspas
duplas é string, mas no SQLite a mesma coisa vira `IDENTIFIER`. O mesmo
caractere delimitador significa categorias opostas nas duas gramáticas."

### Ethan -> Número: `INT`/`FLOAT` (GraphQL) x `NUMERIC_LITERAL` (SQLite)

"A segunda regra é número, e aqui a diferença é mais forte. Testamos a
entrada sugerida pelo próprio enunciado, `10_000.00`, nos dois lexers."

"No SQLite, sai limpo: um único token `NUMERIC_LITERAL`, porque a gramática
aceita underscore como separador de milhar. No GraphQL, a mesma entrada
quebra em três pedaços - `INT` com valor `10`, depois `NAME` com valor
`_000`, porque o `_` ali começa um identificador, e sobra `.00`, que gera um
erro léxico de verdade: `token recognition error at: '.0'` - e o que resta
depois disso é outro `INT`, com valor `0`."

"Outro achado: no GraphQL, o sinal de menos fica **dentro** do número -
testamos `-3.14e+08` e saiu um único token `FLOAT`. Já no SQLite, o sinal é
separado: `-42000` vira dois tokens, um `MINUS` e um `NUMERIC_LITERAL`. Isso
quer dizer que, em GraphQL, `10-5` vira `INT(10)` seguido de `INT(-5)` - o
operador de subtração literalmente desaparece no lexer, porque GraphQL não
tem aritmética, só números com sinal."

### Arthur -> Texto: `STRING` (GraphQL) x `STRING_LITERAL` (SQLite)

"A terceira regra é texto entre aspas. GraphQL usa aspa dupla e escapa com
barra invertida, tipo a maioria das linguagens de programação. SQLite usa
aspa simples e escapa **duplicando** a própria aspa - convenção antiga,
herdada do SQL padrão."

"Testamos `'c:\pasta\arquivo'` no SQLite: aceita numa boa, porque a barra
invertida ali não tem significado especial, é só um caractere qualquer. A
mesma ideia escrita `"c:\pasta\arquivo"` no GraphQL **quebra**: o `\p` não é
um escape válido, e o ANTLR reporta três erros léxicos diferentes na mesma
linha, e o que sobra são dois tokens `NAME` bagunçados, `asta` e
`arquivo` - o início das palavras se perde junto com o erro."

"O contraste mais forte do trabalho todo é testar uma string sem fechar. No
GraphQL, `"sem fechamento` dá zero tokens e um erro léxico cobrindo a linha
inteira. No SQLite, a mesma ideia com aspa simples, `'sem fechamento`, **não
gera nenhum erro**: sai quatro tokens estranhos, porque a última regra do
SQLiteLexer é um catch-all, `UNEXPECTED_CHAR`, que aceita qualquer
caractere e nunca deixa o lexer travar."

---

## Bloco 3 - Diagramas de sintaxe (~2 min)

Eduardo -> "Além de rodar as entradas, desenhamos o diagrama de ferrovia de
cada regra - o mapa visual de todo caminho válido pra escrever aquilo. Pra
`NAME` do GraphQL, é um diagrama só, bem curto. Pra `IDENTIFIER` do SQLite,
precisou virar quatro diagramas separados, um pra cada forma aceita - o
próprio desenho já mostra que uma regra é bem mais simples que a outra."

Eduardo -> "No número a diferença é de estilo, não só de tamanho: o GraphQL
escreve a regra em oito fragmentos pequenos e nomeados, então o diagrama de
`FLOAT` vira três trilhos curtos apontando pra outros diagramas. O SQLite
escreve tudo numa regra só, então `NUMERIC_LITERAL` virou um diagrama único e
grande, com laços aninhados em três níveis."

Eduardo -> "E vale contar: tentando desenhar o `IDENTIFIER` achamos um bug de
verdade na ferramenta PlantUML - ela trava quando uma alternativa tem
alternância aninhada dentro dela. A gente documentou esse bug e contornou
dividindo a regra em quatro diagramas menores."

---

## Bloco 4 - Conclusões e aprendizados (~2 min)

Ethan -> "Meu aprendizado principal: 'entrada rejeitada' quase nunca vira
mensagem de erro. Dos doze casos que a gente projetou pra falhar, só quatro
geraram erro léxico de verdade - todos no GraphQL. Nos outros oito, o lexer
simplesmente quebrou o texto em tokens estranhos, sem avisar nada. Avaliar um
lexer exige olhar a sequência de tokens inteira, não só procurar mensagem de
erro."

Arthur -> "Eu aprendi que um erro léxico não afeta só o ponto onde acontece.
No ANTLR, quando dá erro, o `recover()` descarta um caractere e o resto da
linha desloca - vimos isso com `user-profile-name`, onde o hífen some e a
próxima palavra perde a primeira letra junto."

Eduardo -> "E eu aprendi que a fronteira entre lexer e parser é uma escolha
de projeto, não uma regra fixa. No GraphQL, o sinal de menos é parte do
número porque a linguagem não tem operador de subtração. No SQLite, o sinal
fica de fora porque o parser precisa dele como operador aritmético. A mesma
decisão de design aparece de dois jeitos opostos, e os dois fazem sentido
pro que cada linguagem precisa."

Todos -> "Foi isso que a gente descobriu comparando dois lexers prontos, com
testes reais no ANTLR4. Obrigado."

---

## Checklist antes de gravar

- [ ] `./run.sh` roda sem erro na máquina de quem for gravar (testar antes)
- [ ] Terminal com fonte grande o suficiente pra gravação
- [ ] `diagramas/img/graphql.png` e `sqlite.png` abertos e prontos pra mostrar
- [ ] Os 3 sabem explicar qualquer parte, não só a que ensaiaram (penalidade
      ZERO coletiva se alguém travar quando perguntado)
- [ ] Ninguém lendo com voz sintética nem decorando texto robótico
- [ ] Vídeo hospedado em nuvem, link enviado junto com o relatório no Moodle

## Comandos pra mostrar na tela durante o Bloco 2

```bash
# Eduardo - identificador
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens GraphQL inputs/graphql/name_ok_1.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens SQLite inputs/sqlite/ident_ok_1.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens SQLite inputs/sqlite/ident_bad_1.txt

# Ethan - numero
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens SQLite inputs/sqlite/num_ok_1.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens GraphQL inputs/graphql/num_bad_1.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens GraphQL inputs/graphql/num_ok_1.txt

# Arthur - texto
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens SQLite inputs/sqlite/str_ok_2.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens GraphQL inputs/graphql/str_bad_1.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens GraphQL inputs/graphql/str_bad_2.txt
java -cp tools/antlr-4.13.2-complete.jar:gen/classes DumpTokens SQLite inputs/sqlite/str_bad_2.txt
```

#!/usr/bin/env python3
"""Converte a saida bruta do DumpTokens (out/saida-antlr4.txt) em uma tabela
Markdown pronta para colar no relatorio do TP1."""

import sys


def parse(path):
    casos = []
    atual = None
    for linha in open(path, encoding="utf-8"):
        linha = linha.rstrip("\n")
        if linha.startswith("======"):
            atual = {"tokens": [], "erros": []}
            casos.append(atual)
        elif atual is None:
            continue
        elif linha.startswith("CASO     : "):
            lexer, regra, expect = [p.strip() for p in linha[11:].split(" / ")]
            atual.update(lexer=lexer, regra=regra, expect=expect)
        elif linha.startswith("MOTIVO   : "):
            atual["motivo"] = linha[11:]
        elif linha.startswith("ENTRADA  : "):
            atual["entrada"] = linha[11:]
        elif linha.startswith("  line "):
            atual["erros"].append(linha.strip())
        elif linha.startswith("  ") and "'" in linha:
            nome, _, resto = linha.strip().partition(" ")
            atual["tokens"].append((nome, resto.strip()))
    return casos


def resumo(caso):
    partes = ["`%s`" % nome for nome, _ in caso["tokens"]]
    if caso["erros"]:
        partes.append("**%d erro(s) lexico(s)**" % len(caso["erros"]))
    return " ".join(partes) or "(nenhum token)"


def main():
    casos = parse(sys.argv[1])
    print("# TP1 - Resultados do ANTLR4 por caso de teste\n")
    print("Gerado por `run.sh` com ANTLR 4.13.2. Saida bruta em `out/saida-antlr4.txt`.\n")

    chave = None
    for caso in casos:
        atual = (caso["lexer"], caso["regra"])
        if atual != chave:
            chave = atual
            print("\n## %s - regra `%s`\n" % atual)
            print("| Entrada | Esperado | Tokens produzidos | Qtd |")
            print("|---|---|---|---|")
        entrada = caso["entrada"].replace("|", "\\|")
        print("| `%s` | %s | %s | %d |" % (
            entrada, caso["expect"], resumo(caso).replace("|", "\\|"), len(caso["tokens"])))

    print("\n## Erros lexicos reportados pelo ANTLR4\n")
    algum = False
    for caso in casos:
        for erro in caso["erros"]:
            algum = True
            print("- `%s` (%s): %s" % (caso["entrada"], caso["lexer"], erro))
    if not algum:
        print("_Nenhum erro lexico em nenhum caso._")


if __name__ == "__main__":
    main()

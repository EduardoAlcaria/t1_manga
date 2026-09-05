import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class DumpTokens {

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("uso: DumpTokens <GraphQL|SQLite> <arquivo>");
            System.exit(2);
        }
        String grammar = args[0];
        Path input = Paths.get(args[1]);

        String raw = new String(Files.readAllBytes(input), StandardCharsets.UTF_8);
        CharStream chars = CharStreams.fromString(raw, input.toString());

        Lexer lexer;
        if ("GraphQL".equalsIgnoreCase(grammar)) {
            lexer = new GraphQLLexer(chars);
        } else if ("SQLite".equalsIgnoreCase(grammar)) {
            lexer = new SQLiteLexer(chars);
        } else {
            System.err.println("gramatica desconhecida: " + grammar);
            System.exit(2);
            return;
        }

        final List<String> errors = new ArrayList<>();
        lexer.removeErrorListeners();
        lexer.addErrorListener(new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                                    int line, int charPositionInLine, String msg,
                                    RecognitionException e) {
                errors.add("line " + line + ":" + charPositionInLine + " " + msg);
            }
        });

        List<? extends Token> tokens = lexer.getAllTokens();
        Vocabulary vocab = lexer.getVocabulary();

        System.out.println("ENTRADA  : " + escape(raw));
        System.out.println("GRAMATICA: " + grammar);
        System.out.println("TOKENS   : " + tokens.size());
        for (Token t : tokens) {
            String name = vocab.getSymbolicName(t.getType());
            if (name == null) {
                name = vocab.getDisplayName(t.getType());
            }
            String channel = t.getChannel() == Token.DEFAULT_CHANNEL ? "" : " [canal=" + t.getChannel() + "]";
            System.out.printf("  %-18s '%s'%s%n", name, escape(t.getText()), channel);
        }
        if (errors.isEmpty()) {
            System.out.println("ERROS    : nenhum");
        } else {
            System.out.println("ERROS    : " + errors.size());
            for (String e : errors) {
                System.out.println("  " + e);
            }
        }
    }


    private static String escape(String s) {
        return s.replace("\n", "<LF>")
                .replace("\r", "<CR>")
                .replace("\t", "<TAB>");
    }
}

use kite::lexer::{lex, TokenKind};
fn main() {
    let path = std::env::args().nth(1).unwrap();
    let src = std::fs::read_to_string(path).unwrap();
    let (toks, _) = lex(&src);
    for t in toks {
        let layout = matches!(
            t.kind,
            TokenKind::Newline | TokenKind::Indent | TokenKind::Dedent | TokenKind::Eof
        );
        if !layout {
            println!("{}:{}", t.span.line, t.span.column);
        }
    }
}

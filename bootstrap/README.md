# Bootstrap Kite -> Kite

Milestone 1: `lexer.ki` is the Kite lexer written in Kite.
It was checked token-by-token (line:col of every non-layout token)
against the Rust lexer (`cargo run --example dump_tokens FILE`) on 26
files, including itself: 0 differences.

Build and use:

    mkdir lex && cd lex && mkdir src && cp ../lexer.ki src/main.ki
    printf '[package]\nname="lex"\nversion="0.1.0"\n' > kite.toml
    kite build && ./target/lex some_file.ki

Next milestones (in order): parser (AST needs recursive data: pointers to
data-enum nodes), sema, IR, codegen, driver.

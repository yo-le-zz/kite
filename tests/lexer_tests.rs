//! Lexer tests: token kinds, indentation (Indent/Dedent/Newline), keywords,
//! literals, and lexer-level error recovery.

use kite::lexer::{lex, TokenKind};

fn kinds(source: &str) -> Vec<TokenKind> {
    let (tokens, diags) = lex(source);
    assert!(
        diags.is_empty(),
        "unexpected lexer diagnostics for {source:?}: {:?}",
        diags.into_vec()
    );
    tokens.into_iter().map(|t| t.kind).collect()
}

#[test]
fn empty_source_is_just_eof() {
    assert_eq!(kinds(""), vec![TokenKind::Eof]);
}

#[test]
fn keywords_are_recognized() {
    let (tokens, _) = lex("make until infinit orif else if for to in try failed finally use from import type thread async await and or not break continue true false");
    let kinds: Vec<_> = tokens.into_iter().map(|t| t.kind).collect();
    assert!(matches!(kinds[0], TokenKind::Make));
    assert!(matches!(kinds[1], TokenKind::Until));
    assert!(matches!(kinds[2], TokenKind::Infinit));
    assert!(matches!(kinds[3], TokenKind::Orif));
    assert!(matches!(kinds[4], TokenKind::Else));
}

#[test]
fn indentation_produces_indent_and_dedent() {
    let src = "make main():\n    x = 1\n    y = 2\n";
    let (tokens, diags) = lex(src);
    assert!(diags.is_empty());
    let kinds: Vec<_> = tokens.into_iter().map(|t| t.kind).collect();
    // make main ( ) : NEWLINE INDENT x = 1 NEWLINE y = 2 NEWLINE DEDENT EOF
    assert!(kinds.contains(&TokenKind::Indent));
    assert!(kinds.contains(&TokenKind::Dedent));
    assert_eq!(
        kinds
            .iter()
            .filter(|k| matches!(k, TokenKind::Indent))
            .count(),
        1
    );
    assert_eq!(
        kinds
            .iter()
            .filter(|k| matches!(k, TokenKind::Dedent))
            .count(),
        1
    );
}

#[test]
fn nested_blocks_produce_matching_indent_dedent_pairs() {
    let src = "make main():\n    if true:\n        x = 1\n    y = 2\n";
    let (tokens, diags) = lex(src);
    assert!(diags.is_empty());
    let kinds: Vec<_> = tokens.into_iter().map(|t| t.kind).collect();
    let indents = kinds
        .iter()
        .filter(|k| matches!(k, TokenKind::Indent))
        .count();
    let dedents = kinds
        .iter()
        .filter(|k| matches!(k, TokenKind::Dedent))
        .count();
    assert_eq!(indents, 2);
    assert_eq!(dedents, 2);
}

#[test]
fn brackets_suppress_layout_across_physical_lines() {
    // A multi-line list literal shouldn't emit Newline/Indent tokens
    // inside the brackets.
    let src = "make main():\n    x = [\n        1,\n        2,\n    ]\n";
    let (tokens, diags) = lex(src);
    assert!(diags.is_empty());
    let kinds: Vec<_> = tokens.into_iter().map(|t| t.kind).collect();
    // Only one Indent (entering main's body); the list's inner lines must
    // not each produce their own Indent/Newline.
    assert_eq!(
        kinds
            .iter()
            .filter(|k| matches!(k, TokenKind::Indent))
            .count(),
        1
    );
}

#[test]
fn integer_and_float_literals() {
    let toks = kinds("42 2.5");
    assert!(matches!(toks[0], TokenKind::IntLiteral(42)));
    assert!(matches!(toks[1], TokenKind::FloatLiteral(f) if (f - 2.5).abs() < 1e-9));
}

#[test]
fn string_literal_with_escapes() {
    let toks = kinds("\"hello\\nworld\"");
    match &toks[0] {
        TokenKind::StringLiteral(s) => assert_eq!(s, "hello\nworld"),
        other => panic!("expected string literal, got {other:?}"),
    }
}

#[test]
fn line_comment_is_skipped() {
    let toks = kinds("// this is a comment\nmake main():\n    return\n");
    assert!(matches!(toks[0], TokenKind::Make));
}

#[test]
fn unterminated_string_reports_diagnostic() {
    let (_, diags) = lex("\"never closed");
    assert!(diags.had_errors());
}

#[test]
fn tabs_for_indentation_are_accepted() {
    // Previously rejected outright; tabs are now a first-class
    // indentation style alongside spaces (see `docs/style.md`).
    let (_, diags) = lex("make main():\n\tx = 1\n");
    assert!(!diags.had_errors(), "unexpected diagnostics: {diags:?}");
}

#[test]
fn operators_tokenize_correctly() {
    let toks = kinds("+ - * / % == != < > <= >= = -> . :");
    assert_eq!(
        toks,
        vec![
            TokenKind::Plus,
            TokenKind::Minus,
            TokenKind::Star,
            TokenKind::Slash,
            TokenKind::Percent,
            TokenKind::EqEq,
            TokenKind::NotEq,
            TokenKind::Lt,
            TokenKind::Gt,
            TokenKind::LtEq,
            TokenKind::GtEq,
            TokenKind::Eq,
            TokenKind::Arrow,
            TokenKind::Dot,
            TokenKind::Colon,
            TokenKind::Newline,
            TokenKind::Eof,
        ]
    );
}

#[test]
fn tabs_indent_just_like_spaces() {
    let src = "make main():\n\tx = 1\n\ty = 2\n";
    let (tokens, diags) = lex(src);
    assert!(diags.is_empty(), "unexpected diagnostics: {diags:?}");
    let kinds: Vec<_> = tokens.into_iter().map(|t| t.kind).collect();
    assert!(kinds.contains(&TokenKind::Indent));
    assert!(kinds.contains(&TokenKind::Dedent));
}

#[test]
fn nested_tab_indentation_produces_two_levels() {
    let src = "make main():\n\tif true:\n\t\tx = 1\n";
    let (tokens, diags) = lex(src);
    assert!(diags.is_empty(), "unexpected diagnostics: {diags:?}");
    let indents = tokens
        .iter()
        .filter(|t| t.kind == TokenKind::Indent)
        .count();
    let dedents = tokens
        .iter()
        .filter(|t| t.kind == TokenKind::Dedent)
        .count();
    assert_eq!(indents, 2);
    assert_eq!(dedents, 2);
}

#[test]
fn a_file_can_be_entirely_tab_indented_with_no_errors() {
    let src = "make add(a: int, b: int) -> int:\n\treturn a + b\n\nmake main():\n\tif add(2, 3) == 5:\n\t\tprint(1)\n\telse:\n\t\tprint(0)\n";
    let (_, diags) = lex(src);
    assert!(diags.is_empty(), "unexpected diagnostics: {diags:?}");
}

#[test]
fn mixing_a_tab_and_spaces_at_the_same_nesting_level_is_ambiguous() {
    // A tab-indented line followed by a sibling indented with a
    // different number of spaces than the tab would expand to is
    // exactly the classic Python "TabError" case -- it must still be
    // rejected even though tabs are now accepted in general.
    let src = "make main():\n\tif true:\n        print(1)\n";
    let (_, diags) = lex(src);
    assert!(
        !diags.is_empty(),
        "expected an inconsistent-indentation error"
    );
    assert!(diags.into_vec().iter().any(|d| d.code == Some("E0004")));
}

#[test]
fn a_tab_and_eight_spaces_indenting_the_same_line_are_still_flagged() {
    // Even though a tab expands to width 8 (matching 8 spaces) under
    // this lexer's tab-stop rule, using a tab on one line and 8 literal
    // spaces on a sibling line is still a mix worth flagging: nothing
    // else in the file says that was intentional rather than an editor
    // silently substituting one for the other.
    let src = "make main():\n\tprint(1)\n        print(2)\n";
    let (_, diags) = lex(src);
    assert!(
        !diags.is_empty(),
        "expected an inconsistent-indentation error"
    );
}

//! Parser tests: statement/expression grammar, error recovery, and AST
//! shape for the new indentation-based syntax.

use kite::ast::*;
use kite::lexer::lex;
use kite::parser::parse;

fn parse_ok(source: &str) -> Program {
    let (tokens, lex_diags) = lex(source);
    assert!(
        lex_diags.is_empty(),
        "lex errors: {:?}",
        lex_diags.into_vec()
    );
    let (program, diags) = parse(tokens);
    assert!(
        diags.is_empty(),
        "parse errors for {source:?}: {:?}",
        diags.into_vec()
    );
    program.expect("parser reported no errors but returned None")
}

fn parse_err(source: &str) {
    let (tokens, _) = lex(source);
    let (program, diags) = parse(tokens);
    assert!(
        diags.had_errors() || program.is_none(),
        "expected a parse error for {source:?}"
    );
}

#[test]
fn parses_minimal_function() {
    let program = parse_ok("make main():\n    return\n");
    assert_eq!(program.functions.len(), 1);
    assert_eq!(program.functions[0].name, "main");
    assert!(program.functions[0].params.is_empty());
}

#[test]
fn parses_function_with_params_and_return_type() {
    let program = parse_ok("make add(a: int, b: int) -> int:\n    return a + b\n");
    let f = &program.functions[0];
    assert_eq!(f.params.len(), 2);
    assert_eq!(f.params[0].name, "a");
    assert!(matches!(f.params[0].ty, TypeName::Int));
    assert!(matches!(f.declared_return_type, Some(TypeName::Int)));
}

#[test]
fn parses_inferred_and_annotated_assignment() {
    let program = parse_ok("make main():\n    age = 20\n    name: string = \"Kite\"\n");
    let stmts = &program.functions[0].body.as_ref().unwrap().statements;
    assert_eq!(stmts.len(), 2);
    match &stmts[1] {
        Stmt::Assign {
            annotated_type: Some(TypeName::String),
            ..
        } => {}
        other => panic!("expected annotated string assignment, got {other:?}"),
    }
}

#[test]
fn parses_if_orif_else_chain() {
    let program = parse_ok(
        "make main():\n    if a:\n        x = 1\n    orif b:\n        x = 2\n    else:\n        x = 3\n",
    );
    match &program.functions[0].body.as_ref().unwrap().statements[0] {
        Stmt::If {
            orif_branches,
            else_branch,
            ..
        } => {
            assert_eq!(orif_branches.len(), 1);
            assert!(else_branch.is_some());
        }
        other => panic!("expected if statement, got {other:?}"),
    }
}

#[test]
fn parses_until_and_infinit_loops() {
    let program = parse_ok(
        "make main():\n    until x >= 3:\n        x = x + 1\n    infinit:\n        break\n",
    );
    assert!(matches!(
        program.functions[0].body.as_ref().unwrap().statements[0],
        Stmt::Until { .. }
    ));
    assert!(matches!(
        program.functions[0].body.as_ref().unwrap().statements[1],
        Stmt::Infinit { .. }
    ));
}

#[test]
fn parses_for_range_and_for_each() {
    let program = parse_ok("make main():\n    for i = 1 to 10:\n        print(i)\n    for item in numbers:\n        print(item)\n");
    assert!(matches!(
        program.functions[0].body.as_ref().unwrap().statements[0],
        Stmt::ForRange { .. }
    ));
    assert!(matches!(
        program.functions[0].body.as_ref().unwrap().statements[1],
        Stmt::ForEach { .. }
    ));
}

#[test]
fn parses_list_tuple_dict_literals() {
    let program = parse_ok(
        "make main():\n    a = [1, 2, 3]\n    b = (1, 2)\n    c = {\n        \"x\": 1,\n    }\n",
    );
    let stmts = &program.functions[0].body.as_ref().unwrap().statements;
    match &stmts[0] {
        Stmt::Assign {
            value: Expr::ListLiteral(items, _),
            ..
        } => assert_eq!(items.len(), 3),
        other => panic!("expected list literal, got {other:?}"),
    }
    match &stmts[1] {
        Stmt::Assign {
            value: Expr::TupleLiteral(items, _),
            ..
        } => assert_eq!(items.len(), 2),
        other => panic!("expected tuple literal, got {other:?}"),
    }
    match &stmts[2] {
        Stmt::Assign {
            value: Expr::DictLiteral(entries, _),
            ..
        } => assert_eq!(entries.len(), 1),
        other => panic!("expected dict literal, got {other:?}"),
    }
}

#[test]
fn parses_indexing_and_field_access() {
    let program = parse_ok("make main():\n    x = numbers[1]\n    y = user.name\n");
    assert!(matches!(
        &program.functions[0].body.as_ref().unwrap().statements[0],
        Stmt::Assign {
            value: Expr::Index { .. },
            ..
        }
    ));
    assert!(matches!(
        &program.functions[0].body.as_ref().unwrap().statements[1],
        Stmt::Assign {
            value: Expr::Field { .. },
            ..
        }
    ));
}

#[test]
fn parses_struct_def() {
    let program =
        parse_ok("type User:\n    name: string\n    age: int\n\nmake main():\n    return\n");
    assert_eq!(program.structs.len(), 1);
    assert_eq!(program.structs[0].fields.len(), 2);
}

#[test]
fn parses_try_failed_finally() {
    let program = parse_ok("make main():\n    try:\n        x = 1\n    failed err:\n        print(err)\n    finally:\n        print(\"done\")\n");
    match &program.functions[0].body.as_ref().unwrap().statements[0] {
        Stmt::Try {
            failed_var,
            failed_block,
            finally_block,
            ..
        } => {
            assert_eq!(failed_var.as_deref(), Some("err"));
            assert!(failed_block.is_some());
            assert!(finally_block.is_some());
        }
        other => panic!("expected try statement, got {other:?}"),
    }
}

#[test]
fn parses_imports() {
    let program =
        parse_ok("use math\nfrom collections import sort, reverse\n\nmake main():\n    return\n");
    assert_eq!(program.imports.len(), 2);
}

#[test]
fn parses_and_or_not_precedence() {
    // `not` binds tighter than `and`, which binds tighter than `or`.
    let program = parse_ok("make main():\n    x = a or b and not c\n");
    match &program.functions[0].body.as_ref().unwrap().statements[0] {
        Stmt::Assign {
            value: Expr::Binary { op: BinOp::Or, .. },
            ..
        } => {}
        other => panic!("expected top-level `or`, got {other:?}"),
    }
}

#[test]
fn parses_thread_and_async_await() {
    let program = parse_ok("async make download() -> int:\n    return 1\n\nmake main():\n    thread:\n        print(\"hi\")\n    x = await download()\n");
    assert!(program.functions[0].is_async);
    assert!(matches!(
        program.functions[1].body.as_ref().unwrap().statements[0],
        Stmt::Thread { .. }
    ));
}

#[test]
fn parses_extern_function_declaration() {
    let program = parse_ok(
        "extern make c_add(a: int, b: int) -> int\n\nmake main():\n    print(c_add(1, 2))\n",
    );
    assert!(program.functions[0].is_extern);
    assert!(program.functions[0].body.is_none());
    assert_eq!(program.functions[0].params.len(), 2);
    assert!(!program.functions[1].is_extern);
}

#[test]
fn missing_colon_after_if_is_a_parse_error() {
    parse_err("make main():\n    if x\n        y = 1\n");
}

#[test]
fn missing_indent_after_colon_is_a_parse_error() {
    parse_err("make main():\nreturn\n");
}

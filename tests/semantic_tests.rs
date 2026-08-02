//! Semantic analysis tests: type inference, scoping, mutability-free
//! reassignment rules, and the specific v0.1 restrictions (scalar-only
//! aggregates, local-only aggregates, 1-based indexing type rules).

use kite::lexer::lex;
use kite::parser::parse;
use kite::sema::analyze;

fn check_ok(source: &str) {
    let (tokens, _) = lex(source);
    let (program, parse_diags) = parse(tokens);
    assert!(
        parse_diags.is_empty(),
        "parse errors: {:?}",
        parse_diags.into_vec()
    );
    let program = program.expect("parse produced no program");
    let (typed, diags) = analyze(&program);
    assert!(
        diags.is_empty(),
        "expected no semantic diagnostics for {source:?}, got: {:?}",
        diags.into_vec()
    );
    assert!(typed.is_some());
}

fn check_err(source: &str) -> Vec<String> {
    let (tokens, _) = lex(source);
    let (program, _) = parse(tokens);
    let program = program.expect("expected the program to parse");
    let (typed, diags) = analyze(&program);
    assert!(
        typed.is_none(),
        "expected semantic analysis to fail for {source:?}"
    );
    diags.into_vec().into_iter().map(|d| d.title).collect()
}

#[test]
fn infers_scalar_types() {
    check_ok("make main():\n    age = 20\n    name = \"Kite\"\n    active = true\n    pi = 3.14\n");
}

#[test]
fn explicit_annotation_matching_value_is_ok() {
    check_ok("make main():\n    age: int = 20\n");
}

#[test]
fn explicit_annotation_mismatch_is_an_error() {
    let errors = check_err("make main():\n    age: string = 20\n");
    assert!(!errors.is_empty());
}

#[test]
fn reassignment_must_match_original_type() {
    let errors = check_err("make main():\n    x = 1\n    x = \"oops\"\n");
    assert!(errors.iter().any(|e| e.contains("type mismatch")));
}

#[test]
fn undefined_variable_is_an_error() {
    let errors = check_err("make main():\n    print(nope)\n");
    assert!(errors.iter().any(|e| e.contains("cannot find variable")));
}

#[test]
fn recursive_function_infers_return_type_from_base_case() {
    check_ok(
        "make fib(n: int) -> int:\n    if n < 2:\n        return n\n    return fib(n - 1) + fib(n - 2)\n\nmake main():\n    print(fib(10))\n",
    );
}

#[test]
fn recursive_function_without_base_case_requires_annotation() {
    let errors = check_err("make loop(n: int):\n    return loop(n)\n\nmake main():\n    return\n");
    assert!(!errors.is_empty());
}

#[test]
fn missing_main_is_an_error() {
    let errors = check_err("make helper():\n    return\n");
    assert!(errors.iter().any(|e| e.contains("no `main` function")));
}

#[test]
fn list_indexing_type_checks() {
    check_ok("make main():\n    numbers = [1, 2, 3]\n    x = numbers[1]\n");
}

#[test]
fn tuple_index_must_be_a_literal() {
    let errors = check_err("make main():\n    p = (1, 2)\n    i = 1\n    x = p[i]\n");
    assert!(errors.iter().any(|e| e.contains("literal")));
}

#[test]
fn tuple_index_out_of_range_is_an_error() {
    let errors = check_err("make main():\n    p = (1, 2)\n    x = p[5]\n");
    assert!(errors.iter().any(|e| e.contains("out of range")));
}

#[test]
fn struct_field_access_type_checks() {
    check_ok("type User:\n    name: string\n    age: int\n\nmake main():\n    u = User()\n    u.name = \"Bob\"\n    print(u.name)\n");
}

#[test]
fn unknown_struct_field_is_an_error() {
    let errors =
        check_err("type User:\n    name: string\n\nmake main():\n    u = User()\n    u.age = 1\n");
    assert!(errors.iter().any(|e| e.contains("no field")));
}

#[test]
fn functions_cannot_take_struct_parameters() {
    // Lists/tuples/dicts have no parameter type syntax at all (only
    // scalar types and struct names are valid type annotations), so the
    // grammar itself already rules those out; structs are the one
    // aggregate type that *can* be written as a parameter annotation,
    // and sema must still reject it.
    let errors = check_err(
        "type User:\n    name: string\n\nmake f(u: User):\n    return\n\nmake main():\n    return\n",
    );
    assert!(errors.iter().any(|e| e.contains("may only take")));

    check_ok("make f(x: int) -> int:\n    return x\n\nmake main():\n    print(f(1))\n");
}

#[test]
fn break_outside_loop_is_an_error() {
    let errors = check_err("make main():\n    break\n");
    assert!(errors.iter().any(|e| e.contains("break")));
}

#[test]
fn break_inside_loop_is_ok() {
    check_ok("make main():\n    infinit:\n        break\n");
}

#[test]
fn for_each_requires_a_list() {
    let errors = check_err("make main():\n    x = 5\n    for i in x:\n        print(i)\n");
    assert!(errors.iter().any(|e| e.contains("requires a list")));
}

#[test]
fn append_and_len_type_check() {
    check_ok(
        "make main():\n    numbers = [1, 2, 3]\n    append(numbers, 4)\n    print(len(numbers))\n",
    );
}

#[test]
fn append_type_mismatch_is_an_error() {
    let errors =
        check_err("make main():\n    numbers = [1, 2, 3]\n    append(numbers, \"oops\")\n");
    assert!(!errors.is_empty());
}

#[test]
fn and_or_require_bool_operands() {
    let errors = check_err("make main():\n    x = 1 and 2\n");
    assert!(errors.iter().any(|e| e.contains("bool")));
}

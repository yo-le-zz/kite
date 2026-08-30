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

#[test]
fn extern_function_can_be_called() {
    check_ok("extern make c_add(a: int, b: int) -> int\n\nmake main():\n    print(c_add(1, 2))\n");
}

#[test]
fn extern_function_call_type_checks_arguments() {
    let errors = check_err(
        "extern make c_add(a: int, b: int) -> int\n\nmake main():\n    print(c_add(1, \"oops\"))\n",
    );
    assert!(!errors.is_empty());
}

#[test]
fn enum_variants_type_check() {
    check_ok(
        "enum Color:\n    Red\n    Green\n    Blue\n\nmake main():\n    c = Color.Red\n    print(c == Color.Blue)\n",
    );
}

#[test]
fn enum_unknown_variant_is_an_error() {
    let errors = check_err("enum Color:\n    Red\n\nmake main():\n    c = Color.Purple\n");
    assert!(errors.iter().any(|e| e.contains("no variant")));
}

#[test]
fn enum_and_struct_with_same_name_is_an_error() {
    let errors =
        check_err("type Color:\n    x: int\n\nenum Color:\n    Red\n\nmake main():\n    return\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("both a struct and an enum")));
}

#[test]
fn enum_used_as_function_parameter_type_checks() {
    check_ok(
        "enum Color:\n    Red\n    Green\n\nmake is_red(c: Color) -> bool:\n    return c == Color.Red\n\nmake main():\n    print(is_red(Color.Red))\n",
    );
}

#[test]
fn char_at_and_substr_type_check() {
    check_ok("make main():\n    s = \"hello\"\n    c = char_at(s, 1)\n    t = substr(s, 1, 3)\n    print(c)\n    print(t)\n");
}

#[test]
fn char_at_rejects_non_string() {
    let errors = check_err("make main():\n    x = char_at(5, 1)\n");
    assert!(!errors.is_empty());
}

#[test]
fn substr_rejects_non_int_bounds() {
    let errors = check_err("make main():\n    s = \"hello\"\n    x = substr(s, \"a\", 3)\n");
    assert!(!errors.is_empty());
}

#[test]
fn try_block_that_always_returns_satisfies_missing_return_check() {
    // Regression test: a `try` statement always reported "falls through"
    // regardless of whether its try_block actually returned on every
    // path, causing a false-positive "does not return a value on all
    // paths" error for functions whose only statement was a
    // try/finally that itself always returned.
    check_ok(
        "make f() -> int:\n    try:\n        return 1\n    finally:\n        print(\"cleanup\")\n\nmake main():\n    print(f())\n",
    );
}

#[test]
fn try_block_that_sometimes_falls_through_still_requires_a_final_return() {
    let errors = check_err(
        "make f() -> int:\n    try:\n        if true:\n            return 1\n    finally:\n        print(\"cleanup\")\n\nmake main():\n    print(f())\n",
    );
    assert!(!errors.is_empty());
}

#[test]
fn if_without_else_and_no_fallback_return_is_a_missing_return_error() {
    // Regression test: `if cond: return x` with no `else` and nothing
    // after it used to silently pass semantic analysis -- the
    // fall-through computation for if/orif/else ANDed branch results
    // together (and treated a missing `else` as "guarantees a return"),
    // when it should OR them (any branch that can fall through means
    // the whole statement can) and treat a missing `else` as always
    // falling through.
    let errors = check_err("make f(n: int) -> int:\n    if n > 0:\n        return 1\n\nmake main():\n    print(f(5))\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("does not return a value on all paths")));
}

#[test]
fn if_orif_else_all_returning_satisfies_missing_return_check() {
    check_ok(
        "make classify(n: int) -> string:\n    if n < 0:\n        return \"neg\"\n    orif n == 0:\n        return \"zero\"\n    else:\n        return \"pos\"\n\nmake main():\n    print(classify(1))\n",
    );
}

#[test]
fn strings_can_be_concatenated_with_plus() {
    check_ok("make main():\n    a = \"foo\"\n    b = \"bar\"\n    c = a + b\n    print(c)\n");
}

#[test]
fn concatenating_a_string_with_a_non_string_is_a_type_error() {
    let errors =
        check_err("make main():\n    a = \"foo\"\n    b = 1\n    c = a + b\n    print(c)\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("cannot apply arithmetic operator")));
}

#[test]
fn subtracting_two_strings_is_still_a_type_error() {
    // `+` grew a string overload; the other arithmetic operators
    // deliberately did not.
    let errors =
        check_err("make main():\n    a = \"foo\"\n    b = \"bar\"\n    c = a - b\n    print(c)\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("cannot apply arithmetic operator")));
}

#[test]
fn read_file_write_file_arg_and_arg_count_type_check() {
    check_ok("make main():\n    content = read_file(\"a.txt\")\n    ok = write_file(\"b.txt\", content)\n    print(ok)\n    n = arg_count()\n    if n >= 1:\n        print(arg(1))\n");
}

#[test]
fn read_file_rejects_a_non_string_path() {
    let errors = check_err("make main():\n    content = read_file(1)\n    print(content)\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("`read_file` expects a string path")));
}

#[test]
fn arg_rejects_a_non_int_index() {
    let errors = check_err("make main():\n    print(arg(\"1\"))\n");
    assert!(errors
        .iter()
        .any(|e| e.contains("`arg` expects an `int` index")));
}

//! LLVM backend tests: actually invoke `clang` to turn generated LLVM IR
//! into a native executable and run it, checking real stdout. These are
//! skipped (not failed) when `clang` isn't on `PATH`, so the suite stays
//! green on machines without the LLVM toolchain installed.

use kite::driver::build_executable;
use std::process::Command;
use tempfile::tempdir;

fn clang_available() -> bool {
    Command::new("clang")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// Compiles `source` all the way to a native executable and returns its
/// captured stdout. Skips (returns `None`) if `clang` isn't installed.
fn run_kite_program(source: &str) -> Option<String> {
    if !clang_available() {
        eprintln!("skipping: clang not found on PATH");
        return None;
    }
    let dir = tempdir().expect("tempdir");
    let output_path = dir.path().join("program");
    build_executable("test.ki", source, &output_path, 0, None).expect("build_executable failed");
    let output = Command::new(&output_path)
        .output()
        .expect("failed to run compiled program");
    assert!(
        output.status.success(),
        "program exited non-zero: {output:?}"
    );
    Some(String::from_utf8_lossy(&output.stdout).to_string())
}

#[test]
fn hello_world_prints_and_runs() {
    let Some(stdout) = run_kite_program("make main():\n    print(\"Hello, Kite!\")\n") else {
        return;
    };
    assert_eq!(stdout, "Hello, Kite!\n");
}

#[test]
fn arithmetic_and_functions() {
    let source = "make add(a: int, b: int) -> int:\n    return a + b\n\nmake main():\n    print(add(3, 4))\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "7\n");
}

#[test]
fn recursion_fibonacci() {
    let source = "make fib(n: int) -> int:\n    if n < 2:\n        return n\n    return fib(n - 1) + fib(n - 2)\n\nmake main():\n    print(fib(10))\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "55\n");
}

#[test]
fn lists_are_dynamic_and_one_indexed() {
    let source = "make main():\n    xs = [10, 20, 30]\n    print(xs[1])\n    append(xs, 40)\n    print(len(xs))\n    print(xs[4])\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "10\n4\n40\n");
}

#[test]
fn out_of_bounds_index_aborts_safely_instead_of_crashing() {
    if !clang_available() {
        eprintln!("skipping: clang not found on PATH");
        return;
    }
    let dir = tempdir().expect("tempdir");
    let output_path = dir.path().join("program");
    build_executable(
        "test.ki",
        "make main():\n    xs = [1, 2, 3]\n    print(xs[10])\n",
        &output_path,
        0,
        None,
    )
    .expect("build_executable failed");
    let output = Command::new(&output_path)
        .output()
        .expect("failed to run compiled program");
    assert!(
        !output.status.success(),
        "expected a non-zero exit on out-of-bounds access"
    );
    assert_eq!(output.status.code(), Some(1));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("out of range"), "stdout was: {stdout}");
}

#[test]
fn finally_runs_on_early_return() {
    let source = "make f() -> int:\n    try:\n        return 1\n    finally:\n        print(\"cleanup\")\n    return -1\n\nmake main():\n    print(f())\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "cleanup\n1\n");
}

#[test]
fn until_and_infinit_loops_with_break() {
    let source = "make main():\n    counter = 0\n    until counter >= 3:\n        counter = counter + 1\n    print(counter)\n    tries = 0\n    infinit:\n        tries = tries + 1\n        if tries >= 5:\n            break\n    print(tries)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "3\n5\n");
}

#[test]
fn structs_and_field_assignment() {
    let source = "type User:\n    name: string\n    age: int\n\nmake main():\n    u = User()\n    u.name = \"Bob\"\n    u.age = 42\n    print(u.name)\n    print(u.age)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "Bob\n42\n");
}

#[test]
fn tuples_and_dicts() {
    let source = "make main():\n    p = (10, 20)\n    print(p[1])\n    print(p[2])\n    d = {\n        \"x\": 1,\n    }\n    print(d[\"x\"])\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "10\n20\n1\n");
}

#[test]
fn for_range_and_for_each() {
    let source = "make main():\n    for i = 1 to 3:\n        print(i)\n    xs = [7, 8, 9]\n    for x in xs:\n        print(x)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "1\n2\n3\n7\n8\n9\n");
}

#[test]
fn enums_compare_and_dispatch() {
    let source = "enum Color:\n    Red\n    Green\n    Blue\n\nmake name(c: Color) -> string:\n    if c == Color.Red:\n        return \"red\"\n    orif c == Color.Green:\n        return \"green\"\n    else:\n        return \"blue\"\n\nmake main():\n    print(name(Color.Green))\n    print(Color.Red == Color.Red)\n    print(Color.Red == Color.Blue)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "green\ntrue\nfalse\n");
}

#[test]
fn freestanding_build_produces_object_file_without_main() {
    if !clang_available() {
        eprintln!("skipping: clang not found on PATH");
        return;
    }
    let dir = tempdir().expect("tempdir");
    let output_path = dir.path().join("lib.o");
    let src = dir.path().join("main.ki");
    std::fs::write(
        &src,
        "make add(a: int, b: int) -> int:\n    return a + b\n\nmake kernel_entry() -> int:\n    return add(2, 3)\n",
    )
    .unwrap();

    kite::driver::build_project_freestanding(&src, dir.path(), &output_path, 0, None)
        .expect("freestanding build failed");

    assert!(output_path.is_file());
    let bytes = std::fs::read(&output_path).expect("read object file");
    assert!(!bytes.is_empty());
}

#[test]
fn computed_non_int_return_values_keep_their_type() {
    // Regression test: a function returning a *computed* (non-literal)
    // bool/float value used to be miscompiled -- codegen guessed the
    // return type of a temporary register as always `i64`, corrupting
    // anything that wasn't secretly int-shaped.
    let source = "make is_even(n: int) -> bool:\n    return n % 2 == 0\n\nmake half(x: float) -> float:\n    return x / 2.0\n\nmake main():\n    print(is_even(10))\n    print(is_even(7))\n    print(half(9.0))\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "true\nfalse\n4.500000\n");
}

#[test]
fn call_argument_that_is_a_computed_bool_or_float_keeps_its_type() {
    // Same bug class, but for call *arguments* built from an expression
    // rather than a bare literal/variable.
    let source = "make describe(flag: bool) -> string:\n    if flag:\n        return \"yes\"\n    return \"no\"\n\nmake main():\n    print(describe(3 > 1))\n    print(describe(1 > 3))\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "yes\nno\n");
}

#[test]
fn kite_can_call_c_via_extern_and_link() {
    if !clang_available() {
        eprintln!("skipping: clang not found on PATH");
        return;
    }
    let dir = tempdir().expect("tempdir");

    let c_path = dir.path().join("helper.c");
    std::fs::write(&c_path, "long c_double(long x) { return x * 2; }\n").unwrap();

    let src = dir.path().join("main.ki");
    std::fs::write(
        &src,
        "extern make c_double(x: int) -> int\n\nmake main():\n    print(c_double(21))\n",
    )
    .unwrap();

    let output_path = dir.path().join("prog");
    kite::driver::build_project(&src, dir.path(), &output_path, 0, None, false, &[c_path])
        .expect("build with --link should succeed");

    let output = Command::new(&output_path)
        .output()
        .expect("run compiled program");
    assert!(output.status.success());
    assert_eq!(String::from_utf8_lossy(&output.stdout), "42\n");
}

#[test]
fn kite_lib_produces_object_and_header_callable_from_c() {
    if !clang_available() {
        eprintln!("skipping: clang not found on PATH");
        return;
    }
    let dir = tempdir().expect("tempdir");
    let src = dir.path().join("main.ki");
    std::fs::write(&src, "make kite_square(x: int) -> int:\n    return x * x\n").unwrap();

    let output_path = dir.path().join("lib.o");
    let header_path = kite::driver::build_project_lib(&src, dir.path(), &output_path, 0, None)
        .expect("lib build should succeed");
    assert!(output_path.is_file());
    assert!(header_path.is_file());

    let c_main = dir.path().join("main.c");
    std::fs::write(
        &c_main,
        format!(
            "#include <stdio.h>\n#include \"{}\"\nint main(void) {{ printf(\"%lld\\n\", (long long)kite_square(6)); return 0; }}\n",
            header_path.display()
        ),
    )
    .unwrap();

    let exe_path = dir.path().join("c_prog");
    let status = Command::new("clang")
        .args([
            c_main.to_str().unwrap(),
            output_path.to_str().unwrap(),
            "-o",
            exe_path.to_str().unwrap(),
        ])
        .status()
        .expect("clang link should run");
    assert!(status.success());

    let output = Command::new(&exe_path).output().expect("run c program");
    assert!(output.status.success());
    assert_eq!(String::from_utf8_lossy(&output.stdout), "36\n");
}

#[test]
fn char_at_and_substr_work() {
    let source = "make main():\n    s = \"hello world\"\n    print(len(s))\n    print(char_at(s, 1))\n    print(substr(s, 1, 5))\n    print(substr(s, 7, 11))\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "11\n104\nhello\nworld\n");
}

#[test]
fn substr_full_string_round_trips() {
    let source = "make main():\n    s = \"kite\"\n    t = substr(s, 1, len(s))\n    print(t)\n    print(t == s)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "kite\ntrue\n");
}

#[test]
fn or_short_circuits_correctly_with_three_or_more_operands() {
    // Regression test: `or` chains longer than two operands were
    // miscompiled -- the short-circuit branch polarity for `or` reused
    // `and`'s (correct only for `and`), so `a or b or c` evaluated to
    // `true` the moment the *first* operand was false, and to the
    // *second* operand's value (ignoring that the first was true) when
    // the first operand was true.
    let source = "make is_space(c: int) -> bool:\n    return c == 32 or c == 9 or c == 13 or c == 10\n\nmake main():\n    print(is_space(32))\n    print(is_space(109))\n    print(is_space(10))\n    print(1 == 2 or 3 == 3 or 4 == 5)\n    print(1 == 2 or 3 == 4 or 5 == 6)\n";
    let Some(stdout) = run_kite_program(source) else {
        return;
    };
    assert_eq!(stdout, "true\nfalse\ntrue\ntrue\nfalse\n");
}

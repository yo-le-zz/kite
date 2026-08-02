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

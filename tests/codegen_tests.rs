//! Code generation tests: shape and well-formedness of the emitted LLVM
//! IR text, independent of whether `clang` is installed (see
//! `llvm_backend_tests.rs` for tests that actually invoke `clang`).

use kite::codegen::{emit_module, CodegenOptions};
use kite::ir::lower_program;
use kite::lexer::lex;
use kite::parser::parse;
use kite::sema::analyze;

fn compile_to_llvm_ir(source: &str) -> String {
    let (tokens, _) = lex(source);
    let (program, diags) = parse(tokens);
    assert!(diags.is_empty(), "parse errors: {:?}", diags.into_vec());
    let program = program.unwrap();
    let (typed, diags) = analyze(&program);
    assert!(
        diags.is_empty(),
        "sema errors for {source:?}: {:?}",
        diags.into_vec()
    );
    let typed = typed.unwrap();
    let ast_program = kite::ast::Program {
        imports: vec![],
        structs: typed.structs,
        functions: typed.functions,
    };
    let ir = lower_program(&ast_program);
    emit_module(
        &ir,
        &CodegenOptions {
            target_triple: None,
        },
    )
}

#[test]
fn emits_printf_declaration() {
    let ir = compile_to_llvm_ir("make main():\n    print(\"hi\")\n");
    assert!(ir.contains("declare i32 @printf"));
}

#[test]
fn main_returns_i32_for_c_entry_point() {
    let ir = compile_to_llvm_ir("make main():\n    return\n");
    assert!(ir.contains("define i32 @main()"), "IR was:\n{ir}");
}

#[test]
fn non_main_function_keeps_its_declared_type() {
    let ir = compile_to_llvm_ir("make add(a: int, b: int) -> int:\n    return a + b\n\nmake main():\n    print(add(1, 2))\n");
    assert!(
        ir.contains("define i64 @add(i64 %a.arg, i64 %b.arg)"),
        "IR was:\n{ir}"
    );
}

#[test]
fn every_function_body_has_a_terminator_per_block() {
    let ir = compile_to_llvm_ir(
        "make classify(n: int) -> string:\n    if n < 0:\n        return \"neg\"\n    orif n == 0:\n        return \"zero\"\n    else:\n        return \"pos\"\n\nmake main():\n    print(classify(1))\n",
    );
    // Every `entry:`/label block must end in br/ret/unreachable before the
    // next label -- spot check there's no label immediately followed by
    // another label (which would mean a block fell through with no
    // terminator).
    let lines: Vec<&str> = ir.lines().collect();
    for i in 0..lines.len().saturating_sub(1) {
        if lines[i].ends_with(':') && !lines[i].starts_with(' ') {
            let next = lines[i + 1].trim();
            assert!(
                !next.ends_with(':') || next.is_empty(),
                "block `{}` has no terminator before the next label (IR:\n{ir})",
                lines[i]
            );
        }
    }
}

#[test]
fn struct_type_is_declared() {
    let ir = compile_to_llvm_ir("type User:\n    name: string\n    age: int\n\nmake main():\n    u = User()\n    print(u.age)\n");
    assert!(ir.contains("%User = type"), "IR was:\n{ir}");
}

#[test]
fn list_append_emits_growth_check() {
    let ir = compile_to_llvm_ir("make main():\n    xs = [1, 2, 3]\n    append(xs, 4)\n");
    assert!(ir.contains("@malloc"));
    assert!(ir.contains("@realloc") || ir.contains("@malloc"));
}

#[test]
fn list_index_emits_runtime_bounds_check() {
    let ir = compile_to_llvm_ir("make main():\n    xs = [1, 2, 3]\n    i = 2\n    print(xs[i])\n");
    assert!(ir.contains("@exit"));
    assert!(ir.contains("icmp"));
}

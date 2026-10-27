# Bootstrapping Kite

Goal: the Kite compiler is written in Kite. The original Rust compiler is kept
as **stage0** in `archive/rust-stage0/` and is only needed to compile the first
Kite compiler.

```
stage0  archive/rust-stage0   Rust            (reference seed, kept forever)
stage1  compiler/             Kite, compiled by stage0
stage2  stage2/               Kite, compiled by stage1  -> must produce the same LLVM IR as stage1
```

## Build
```
./build.sh          # stage0 (cargo + clang) -> stage1 (kitec) -> stage2 when the port is complete
./build.sh test     # + differential tests Kite-vs-Rust
./build.sh status   # which phases are ported
./clean.sh [--deep] # remove every build output
```
Requirements: Rust (cargo) and clang. `KITE_STAGE0=/path/to/kite ./build.sh` reuses an existing stage0.
When stage1 and stage2 emit identical IR, `compiler/BOOTSTRAPPED` is written and
`scripts/package-release.sh --compiler auto` starts packaging `kitec` instead of the Rust binary.

## How the port is verified
Each ported phase is compared with the Rust implementation on every `.ki` file of
the repository (examples, prelude, the compiler's own sources) through *canonical
dumps*, byte for byte (`scripts/difftest.sh`):

| phase                    | Rust reference                     | Kite port                 | status |
|--------------------------|------------------------------------|---------------------------|--------|
| lexer (tokens + layout)  | `examples/dump_ast.rs tokens`      | `compiler/src/lexer.ki`   | done, 0 diffs |
| parser (AST + spans)     | `examples/dump_ast.rs ast`         | `compiler/src/parser.ki`  | done, 0 diffs |
| diagnostics rendering    | `src/diagnostics.rs`               | `compiler/src/diag.ki`    | ported |
| desugar + prelude inject | `src/desugar.rs`, `src/prelude.rs` | -                         | next |
| semantic analysis        | `src/sema.rs`                      | -                         | todo |
| IR lowering              | `src/ir.rs`                        | -                         | todo |
| LLVM codegen             | `src/codegen.rs`                   | -                         | todo |
| driver / CLI / projects  | `src/driver.rs`, `commands/*`, `project.rs`, `resolve.rs`, `cheader.rs` | - | todo |

`kitec tokens FILE`, `kitec ast FILE` print the canonical dumps; `kitec --capabilities` lists the ported phases.

## Design of the Kite compiler
* **AST as an arena** (`ast.ki`): uniform `Node{kind,text,span,kids}` indexed by integers.
* **Errors** are `-1` node ids plus entries in `Diags` (the Rust `Result<_, ()>`).
* Written with the 0.2 language: classes, methods, f-strings, tuples, data enums, lists of structs, the prelude.

## Switch-over plan
1. Port desugar/prelude, sema, IR, codegen, driver (each verified against stage0).
2. `kitec build` compiles `compiler/` itself -> stage2; require identical IR.
3. Package `kitec` as the default `kite`; keep `archive/rust-stage0` as the seed.

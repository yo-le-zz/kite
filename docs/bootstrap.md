# Bootstrapping Kite

Goal: the Kite compiler is written in Kite. The original Rust compiler is kept
as **stage0** in `archive/rust-stage0/` and is only needed to compile the first
Kite compiler.

```
stage0  archive/rust-stage0   Rust            (reference, kept forever)
stage1  compiler/             Kite, compiled by stage0
stage2  (target)              Kite, compiled by stage1  -> must equal stage1
```

## Build
```
./build.sh          # stage0 (cargo + clang) then stage1 -> compiler/target/kitec
./build.sh test     # + differential tests Kite-vs-Rust
make                # same, through make
```
Requirements: Rust (cargo) and clang. `KITE_STAGE0=/path/to/kite ./build.sh`
reuses an existing stage0 binary.

## How the port is verified
Each ported phase is checked against the Rust implementation on every
`.ki` file of the repository (examples, prelude, the compiler's own sources)
by comparing *canonical dumps* byte for byte:

| phase                    | Rust reference                     | Kite port             | status |
|--------------------------|------------------------------------|-----------------------|--------|
| lexer (tokens + layout)  | `examples/dump_ast.rs tokens`      | `compiler/src/lexer.ki`   | done, 0 diffs |
| parser (AST + spans)     | `examples/dump_ast.rs ast`         | `compiler/src/parser.ki`  | done, 0 diffs |
| diagnostics rendering    | `src/diagnostics.rs`               | `compiler/src/diag.ki`    | ported (rendering untested vs Rust) |
| desugar + prelude inject | `src/desugar.rs`, `src/prelude.rs` | -                     | next |
| semantic analysis        | `src/sema.rs`                      | -                     | todo |
| IR lowering              | `src/ir.rs`                        | -                     | todo |
| LLVM codegen             | `src/codegen.rs`                   | -                     | todo |
| driver / project / CLI   | `src/driver.rs`, `commands/*`, `project.rs`, `resolve.rs`, `cheader.rs` | - | todo |

`kitec tokens FILE` and `kitec ast FILE` print the canonical dumps.

## Design of the Kite compiler
* **AST as an arena** (`ast.ki`): uniform `Node{kind,text,span,kids}` indexed
  by integers. No recursive pointers, easy to walk, easy to dump.
* **Errors** are `-1` node ids plus entries in `Diags` (the Rust `Result<_, ()>`).
* The compiler is written with the language features added in 0.2: classes,
  methods, f-strings, tuples, data enums, lists of structs, the prelude.

## Switch-over plan
1. Port desugar/prelude, then sema, IR, codegen, driver (each verified against stage0).
2. `kitec build` compiles `compiler/` itself -> stage2; require stage2 == stage1
   (identical LLVM IR).
3. Make `kitec` the default `kite` binary; keep `archive/rust-stage0` as the
   seed compiler.

# Changelog

## 0.2.0 -- stable, pre-bootstrap
- f-strings, `str()`, compound operators everywhere, 0-based indexing.
- Default / named / variadic parameters, tuple unpacking.
- Lists, tuples, structs, classes pass through function boundaries (by reference) and are returned (`sret`).
- Classes: methods, `init`, single inheritance, virtual dispatch, upcasting.
- Data enums with `match`/`case`, recursive data through `ptr<T>`, pointer auto-deref, typed `null`.
- Structs containing lists/structs, lists of structs, `pop/remove/insert/clear`.
- String ordering, prelude in Kite (string helpers, `StrMap_T` hash maps).
- Codegen: allocas hoisted to the entry block, LLVM `sizeof`-based list layout.
- Bootstrap milestone 1: `bootstrap/lexer.ki` (Kite lexer in Kite, verified against the Rust lexer).

## 0.3.0 -- bootstrap milestone 2
- Repository reorganised: Rust compiler archived in `archive/rust-stage0/`.
- `compiler/`: lexer + parser + diagnostics of Kite written in Kite; token and AST
  dumps are byte-identical to the Rust compiler on all sample files.
- `build.sh` / `Makefile` for the stage0 -> stage1 build and the differential tests.
- Stage0 improvements needed by the port: receiver-type inference through fields,
  list elements, `alloc`, pointers; `p.method()` on `ptr<Class>`; `exit(code)` builtin;
  generated LLVM temporaries renamed `%.tN` so user variables can't collide;
  bare struct constructors usable as values.
- `build.sh` no longer depends on cargo's target-dir configuration; `scripts/package.sh`
  builds `.deb` (amd64/arm64) and Windows (x64/arm64) packages; release workflow added.
- Fix: `build.sh` built only the examples (`cargo build --examples`), not the `kite` binary; it now builds `--bins --examples`.
- `clean.sh` (`--deep`) removes every build output and cache of the repository.

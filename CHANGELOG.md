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

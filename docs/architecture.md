# Kite compiler architecture

Kite is a traditional multi-pass, ahead-of-time compiler:

```
source text (.ki)
    │  lexer            src/lexer/
    ▼
tokens
    │  parser           src/parser.rs
    ▼
AST                     src/ast.rs
    │  sema              src/sema.rs
    ▼
typed AST
    │  ir::lower_program  src/ir.rs
    ▼
Kite IR
    │  codegen::emit_module  src/codegen.rs
    ▼
LLVM IR text (.ll)
    │  clang (external)  src/driver.rs
    ▼
native executable
```

Each stage is its own module with a narrow, typed interface to the next
one, and each is independently unit-testable (see `tests/`). The
[`driver`](../src/driver.rs) module is the *only* place that knows the
overall pipeline order; every other module only knows its own input and
output shape.

## Lexer (`src/lexer/`)

A hand-written scanner over a `Vec<char>`, chosen over a
regex/generator-based approach to keep span tracking (byte offset + line +
column) exact, which matters for diagnostic quality.

Kite uses **significant indentation** (no braces, no semicolons), so the
lexer runs in two conceptual passes:

1. **`scan_logical_lines`** scans ordinary tokens, grouped by logical line
   (a physical line, or several joined together while inside brackets --
   `(...)`, `[...]`, `{...}` -- mirroring Python's implicit line-joining).
2. **`apply_layout`** walks those lines and inserts `Indent`/`Dedent`/
   `Newline` tokens by comparing each line's leading-space count against
   an indentation stack -- the same algorithm CPython's tokenizer uses.

Tabs are rejected outright (`E0004`) rather than given an implicit width,
to avoid the classic tabs/spaces ambiguity entirely.

## Parser (`src/parser.rs`)

Recursive descent, with a standard precedence-climbing (Pratt-style)
function for expressions:

```
or  <  and  <  not  <  ==/!=  <  </>/<=/>=  <  +/-  <  */÷/%  <  unary -  <  postfix (. [] ())
```

Blocks are delimited by `Indent`/`Dedent` rather than braces, so
`parse_block` is the one place that consumes those tokens; every other
`parse_*` function is otherwise unaware that Kite is indentation-based.

**Error recovery:** a bad statement is skipped up to the next `Newline`/
`Dedent`; a bad top-level item is skipped up to the next `use`/`from`/
`type`/`make`. This means a single mistake reports one clear error instead
of a cascade, and doesn't blank out the rest of the file.

**Disambiguating assignment from expression statements:** `x = 1` and
`print(x)` both start with an identifier. `looks_like_assignment` scans
forward (without consuming any tokens) past an identifier-rooted `.field`/
`[index]` chain to check whether it's immediately followed by `=` or `:
Type =`, without needing full backtracking.

## AST (`src/ast.rs`)

A plain, direct representation of the grammar -- `Program`, `Function`,
`Stmt`, `Expr`, `TypeName`, etc. Every node carries a `Span` so later
stages can point back at the exact source location.

`TypeName` is the *source-level* type system: `Int`, `Float`, `Bool`,
`String`, `List(elem)`, `Tuple(elems)`, `Dict(fields)`, `Struct(name)`,
`Void`.

## Semantic analysis (`src/sema.rs`)

A single tree walk that:

- resolves every identifier against a per-function scope stack (Kite has
  no closures in v0.1, so each function's scopes are independent),
- infers the type of every `name = expr` binding (or checks an explicit
  `name: Type = expr` annotation against it), and rejects reassigning a
  name to a different type,
- infers a function's return type from its `return` statements when no
  explicit `-> Type` is written (see *Return type inference* below),
- type-checks every expression, including 1-based collection indexing
  (with a compile-time bounds check wherever the index is a literal --
  tuples/dicts always require a literal index, since they're
  heterogeneous),
- enforces that `break`/`continue` only appear inside a loop.

The output is a `TypedProgram`: structurally identical to the AST, but
(if analysis succeeded) guaranteed well-typed. IR lowering re-derives
types structurally from that guarantee rather than threading a symbol
table through a second time.

### Return type inference

```
make fib(n: int) -> int:
    if n < 2:
        return n                        // <- resolves immediately: int
    return fib(n - 1) + fib(n - 2)      // <- depends on fib's own type
```

Sema locks in a function's return type the moment it can fully resolve
*any* `return` statement's expression type, in source order -- and once
locked, later statements in that same function (including recursive
self-calls) see the resolved type. For `fib`, the base case
(`return n`) resolves first and locks the type to `int`; the recursive
case then type-checks normally. If **every** `return` in a function
depends on its own not-yet-known return type (no base case), inference
fails with a clear error asking for an explicit `-> Type` annotation.

### Why aggregates are restricted

Lists, tuples, dicts, and structs in Kite v0.1 are restricted to:

- **scalar elements/fields only** (`int`/`float`/`bool`/`string`) -- no
  lists of lists, no structs containing structs, etc., and
- **local-only** -- they can never be a function parameter or return
  type.

This is what lets IR lowering assume an aggregate value is *always*
addressed by a plain local variable name, never flowing through a
temporary SSA register the way a scalar does (see `ir.rs`'s module docs).
It is a deliberate scope cut for v0.1, not an oversight -- see
`docs/roadmap.md` for the general aggregate-passing design planned for
v0.2.

## IR (`src/ir.rs`)

A small, linear, register-based intermediate representation -- the seam
where future optimization passes (constant folding, dead-code
elimination, inlining) will live, and what keeps `codegen.rs` a thin,
mechanical translation rather than a second copy of the type checker.

Key design points:

- **Not (yet) a CFG/SSA form.** Structured control flow (`if`/`until`/
  `for`/etc.) lowers directly to explicit `Label`/`Jump`/`Branch`
  instructions over a flat instruction list, which maps almost
  one-to-one onto LLVM basic blocks.
- **Lists are dynamic.** A list is a 3-word header --
  `{ i64 len, i64 cap, elem* data }` -- stored *by value* in its local's
  stack slot, with `data` pointing at a heap buffer grown by `append`
  (see `emit_list_append` in `codegen.rs`: doubles capacity, `malloc`s a
  new buffer, `memcpy`s the old contents, `free`s the old buffer). Because
  the header is copied by value, `b = a` for two list locals copies the
  `data` pointer too, giving Python-like aliasing "for free" -- **with a
  caveat**: `len`/`cap` are copied at assignment time, not shared, so
  `append`ing through one alias doesn't update the other's *length*
  unless that append also happened to trigger a fresh allocation both
  would see. A single shared header (via one more level of indirection)
  is the natural v0.2 fix -- see the roadmap.
- **`try`/`finally` via replay, not unwinding.** There's no runtime
  exception mechanism in v0.1, so the only way to leave a `try` block
  early is `return`/`break`/`continue`. `FunctionLowerer::finally_stack`
  tracks every `finally` block currently "in scope"; lowering any of
  those three statements replays (inlines) the relevant pending
  `finally` blocks *before* emitting the actual jump/return -- exactly
  what a real unwinder would run, just done by direct code duplication
  instead of landing pads. This is what makes `finally` provably always
  run, including on an early `return` from inside `try`.
- **1-based indexing, checked at the boundary.** List indexing always
  goes through a runtime bounds check (`emit_list_bounds_checked_ptr`)
  that subtracts 1 from the user-facing index and aborts via
  `printf` + `exit(1)` on an out-of-range access, rather than reading
  out-of-bounds memory.

## Codegen (`src/codegen.rs`)

Translates IR into **textual LLVM IR**, emitted as a `.ll` file. Kite
chose text generation over binding directly to LLVM's C++ API
(`llvm-sys`/`inkwell`) to keep the compiler's own dependency graph small
and decoupled from a specific LLVM version -- while still getting
everything LLVM provides for free (optimization passes, target-specific
codegen, object emission) via the system `clang` toolchain.

Runtime support is a handful of libc functions declared at the top of
every module: `printf` (for `print`), `malloc`/`free`/`memcpy` (growable
lists), `strlen`/`strcmp` (`len`/`==` on strings), and `exit` (the bounds-
check abort path). There is no bespoke Kite runtime library yet.

## Driver (`src/driver.rs`)

Wires the stages together (`check_source` runs lex -> parse -> sema ->
IR; `build_executable` additionally runs codegen and then shells out to
`clang -O<n> module.ll -o <output>`) and is the only module that knows
this order. `kite check` calls `check_source` directly; `kite build`/
`kite run` call `build_executable`.

## CLI (`src/cli.rs`, `src/commands/`)

`cli.rs` defines the argument *shape* (via `clap`); `commands/` defines
what each subcommand *does*. `src/project.rs` owns the `kite.toml`
manifest format, project discovery (walking up from the working directory
the same way Cargo finds `Cargo.toml`), and the `kite.lock` format used by
the package-manager commands.

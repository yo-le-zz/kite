# Roadmap

Kite v0.1.2 is a real, working ahead-of-time compiler with a full
pipeline down to native executables -- not a mockup. It also makes a
number of explicit, documented scope cuts to stay shippable. This page is
the honest list of what's implemented today versus what's next.

## What v0.1.2 has today

- Indentation-based syntax; no braces, no semicolons.
- Type inference for variables, with optional explicit annotation.
- Functions with scalar parameters, inferred or explicit return types,
  and recursion.
- `if`/`orif`/`else`, `until`, `infinit`, `for ... = ... to ...`,
  `for ... in ...`, `break`, `continue`.
- Growable, 1-indexed lists (`append`, `len`), fixed-arity tuples,
  compile-time-fixed-key dictionaries, structs, and C-style enums -- all
  restricted to scalar elements/fields and local-only (see
  [`docs/architecture.md`](architecture.md) for why).
- Runtime bounds checking on list access (safe abort, not undefined
  behavior).
- `try`/`failed`/`finally` parses and type-checks; `finally` is
  guaranteed to run on early `return`/`break`/`continue` out of `try`.
- `thread`/`async`/`await` parse, type-check, and run **synchronously**.
- Real multi-file, multi-directory projects: `use`/`from ... import`
  resolve against files under `src/`, with diagnostics attributed back
  to the file they actually came from.
- Two-way C interop: `extern make ...` declarations to call C from Kite,
  `kite build --link` to link it in, and `kite build --lib` (with a
  generated C header) to call Kite from C -- see
  [`docs/c-interop.md`](c-interop.md). Also `--freestanding` for
  no-hosted-runtime builds (OS/kernel code) and `--static` for
  statically linked executables.
- A Cargo-style CLI (`init`/`build`/`run`/`check`/`clean`/`bench`) with
  `--quiet`, custom output paths (`-o`/`--out-dir`), and a
  Cargo-inspired package manager (`add`/`remove`/`update`) that manages
  `kite.toml`/`kite.lock` locally.
- A full test suite: lexer, parser, semantic analysis, codegen (IR shape),
  LLVM backend (actually compiles and runs programs), and CLI tests.
- A first, real step toward self-hosting: `../../bootstrap` is a lexer
  for Kite, written in Kite, that successfully tokenizes its own source
  file. Not a full self-hosted compiler yet -- see that directory's
  README for exactly what's there and what Kite still needs before a
  parser/codegen stage is realistic.

## Bugs found by bootstrapping

Writing real Kite code by hand -- specifically, the self-hosted lexer in
`../../bootstrap` -- surfaced three genuine miscompilation/false-positive
bugs in this compiler that its own test suite hadn't happened to
exercise, all now fixed with regression tests:

- **`or` with three or more chained operands was miscompiled.** The
  short-circuit branch polarity for `or` reused `and`'s (correct only
  for `and`), so `a or b or c` evaluated to `true` the moment the first
  operand was false, and to the *second* operand's value (ignoring that
  the first was true) when the first was true. See
  `or_short_circuits_correctly_with_three_or_more_operands` in
  `tests/llvm_backend_tests.rs`.
- **`try`/`finally` always reported "falls through," ignoring whether
  `try` itself always returned.** A function whose only statement was a
  `try: return x` / `finally: ...` was incorrectly rejected as "does not
  return a value on all paths." See
  `try_block_that_always_returns_satisfies_missing_return_check` in
  `tests/semantic_tests.rs`.
- **`if`/`orif`/`else` missing-return detection used the wrong boolean
  operator.** It ANDed branch fall-through results together (and
  treated a missing `else` as "guarantees a return") when it needed to
  OR them (any branch that can fall through means the whole statement
  can) and treat a missing `else` as *always* falling through. In
  practice, an `if` with no `else` and nothing after it (e.g. `make
  f(n: int) -> int:` / `    if n > 0:` / `        return 1`) silently
  passed semantic analysis instead of being rejected. See
  `if_without_else_and_no_fallback_return_is_a_missing_return_error` in
  `tests/semantic_tests.rs`.

This is exactly the case for self-hosting work being valuable well
before it's complete: it's real code, under real pressure, in a way a
hand-picked test suite never quite is.

## v0.2: aggregates everywhere

The single biggest scope cut in v0.1 is that lists/tuples/dicts/structs
are local-only and scalar-element-only. Lifting that requires:

- A real **calling convention for aggregates** (pass-by-value semantics,
  or pointer passing with clear ownership rules) so they can be function
  parameters and return values.
- **Nested aggregates** -- lists of structs, structs containing lists,
  etc. -- which needs a general recursive LLVM type-layout system instead
  of the current flat one.
- **Unified list reference semantics.** v0.1's list header is copied by
  value on assignment, which aliases the heap buffer but not the
  length/capacity fields (see `docs/architecture.md`). v0.2 should give
  every list a single shared header (one more pointer indirection) so
  aliasing matches Python's semantics exactly.
- **Truly dynamic dictionaries.** v0.1 dictionaries require compile-time-
  known string keys (indexing is resolved to a struct field at compile
  time). A real dictionary needs a hash map runtime and a dynamic (tagged)
  value representation, which is also what `json.ki`'s heterogeneous
  values are blocked on (see `stdlib/json.ki`).

## v0.2: real error handling

`failed` is currently type-checked but unreachable -- there's no runtime
error/exception type for anything to raise. Landing this needs:

- A concrete error value representation (likely a tagged union / `Result`-
  shaped type).
- A way for operations to signal failure (starting with things like
  `stdlib/fs.ki`'s `read_file`).
- Real unwinding through nested `try` blocks (the current `finally`-replay
  strategy in `ir.rs` generalizes to this once there's something to
  actually unwind *from*, though a landing-pad-based approach may be
  worth revisiting once real errors exist, both for object-file size and
  for `panic`-style errors that shouldn't be catchable at every layer).

## v0.2: real concurrency

`thread`/`async`/`await` are intentionally honest scaffolding today (they
run inline, synchronously). Real support needs:

- `thread:` spawning an actual OS thread (`pthread_create` or
  equivalent), which requires deciding Kite's closure/capture story for
  what data a spawned thread can safely see.
- A real `async`/`await` execution model (a state-machine transform, a
  cooperative scheduler, or a stackful-coroutine runtime) rather than
  eager, synchronous evaluation.

## v0.2: a real package manager

`kite add`/`remove`/`update` today only edit `kite.toml`/`kite.lock`
locally -- there's no package registry to talk to, so `kite build`
doesn't fetch or compile anything a dependency declares. Real support
needs:

- A registry protocol (or a git/path-dependency story as a first cut,
  the way early Cargo supported path dependencies before crates.io).
- Dependency graph resolution (version constraint solving).
- A local cache (`.kite-cache/` is already scaffolded) that's actually
  populated, plus compiling dependency sources as part of `kite build`.
- **Per-symbol visibility and qualified calls.** `use`/`from ... import`
  already resolve against real files under `src/` (see the top of this
  page), but every function/struct in an imported file becomes visible
  under its own bare name -- there's no `pub`/private distinction and no
  `module.function()` qualified-call syntax yet. Both matter more once
  imports can also come from a downloaded *dependency* rather than only
  your own project's files, to avoid two dependencies' functions
  colliding by name.

## v0.2: a real standard library

`stdlib/` is currently a design scaffold (see `stdlib/README.md`) -- each
`.ki` file sketches an intended API surface as comments, not working code.
Implementing `io`/`fs`/`math`/`json`/`http`/`time`/`collections`/`system`
for real is downstream of the package-manager work above (so they can be
distributed as an installable package) and (for `json`/`http`) the
dynamic value representation mentioned earlier on this page.

## Smaller, nearer-term items

- Friendlier diagnostics for indentation mistakes (today's "expected an
  expression, found indented block" is correct but not maximally
  friendly).
- `elif`-style chained conditions already work (`orif`), but pattern
  matching (`match`/`switch`) doesn't exist yet.
- No generics: every function and struct is fully concrete. Real generic
  functions (`make max<T>(a: T, b: T) -> T:`) need monomorphization, and
  are the natural unlock for generic collections/algorithms once the
  aggregate-passing restriction above is also lifted.
- No modules/visibility system within a single file beyond "everything
  is public."
- No incremental compilation: every `kite build` recompiles every file
  in the project from scratch, however small the change. A real build
  cache (keyed on file content/mtime, à la Cargo's) is a roadmap item.
- LLVM optimization passes aren't run beyond whatever `clang -O<n>`
  applies to the generated `.ll` as a whole; Kite doesn't yet run its own
  IR-level optimization passes (constant folding, dead-code elimination,
  inlining) before handing off to LLVM.
- No low-level/manual memory control (`alloc`/`free`, raw pointers) or
  an `unsafe` block for it -- today the only heap allocation is the one
  growable-list implementation detail, entirely managed by the compiler.
  A real systems-programming story here needs a deliberate design (an
  ownership model, or a much simpler "you asked for `unsafe`, you own
  the consequences" escape hatch) rather than a bolted-on `alloc<T>()`.
- No SIMD/vector types.
- No developer tooling beyond the compiler itself: no `kite fmt`
  (formatter), `kite lint`, `kite doc` (doc-comment extraction), a
  built-in `kite test` framework, or an LSP (editor auto-completion,
  inline errors, go-to-definition). A syntax-highlighting setup for Zed
  (tree-sitter grammar + extension) exists under `editors/zed/` as a
  starting point for editor tooling more broadly -- see its own README.

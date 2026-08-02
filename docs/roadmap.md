# Roadmap

Kite v0.1.0 is a real, working ahead-of-time compiler with a full
pipeline down to native executables -- not a mockup. It also makes a
number of explicit, documented scope cuts to stay shippable. This page is
the honest list of what's implemented today versus what's next.

## What v0.1.0 has today

- Indentation-based syntax; no braces, no semicolons.
- Type inference for variables, with optional explicit annotation.
- Functions with scalar parameters, inferred or explicit return types,
  and recursion.
- `if`/`orif`/`else`, `until`, `infinit`, `for ... = ... to ...`,
  `for ... in ...`, `break`, `continue`.
- Growable, 1-indexed lists (`append`, `len`), fixed-arity tuples,
  compile-time-fixed-key dictionaries, and structs -- all restricted to
  scalar elements/fields and local-only (see
  [`docs/architecture.md`](architecture.md) for why).
- Runtime bounds checking on list access (safe abort, not undefined
  behavior).
- `try`/`failed`/`finally` parses and type-checks; `finally` is
  guaranteed to run on early `return`/`break`/`continue` out of `try`.
- `thread`/`async`/`await` parse, type-check, and run **synchronously**.
- `use`/`from ... import` parse and type-check as no-ops.
- A Cargo-style CLI (`init`/`build`/`run`/`check`/`clean`) and a
  Cargo-inspired package manager (`add`/`remove`/`update`) that manages
  `kite.toml`/`kite.lock` locally.
- A full test suite: lexer, parser, semantic analysis, codegen (IR shape),
  LLVM backend (actually compiles and runs programs), and CLI tests.

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
- Once functions/aggregates can cross module boundaries (see above), a
  real multi-file **module system**, since `use`/`from ... import`
  currently have nothing to resolve against.

## v0.2: a real standard library

`stdlib/` is currently a design scaffold (see `stdlib/README.md`) -- each
`.ki` file sketches an intended API surface as comments, not working code.
Implementing `io`/`fs`/`math`/`json`/`http`/`time`/`collections`/`system`
for real is downstream of the module system and (for `json`/`http`) the
dynamic value representation above.

## Smaller, nearer-term items

- Friendlier diagnostics for indentation mistakes (today's "expected an
  expression, found indented block" is correct but not maximally
  friendly).
- `elif`-style chained conditions already work (`orif`), but pattern
  matching (`match`/`switch`) doesn't exist yet.
- No generics: every function and struct is fully concrete.
- No modules/visibility system within a single file beyond "everything
  is public."
- LLVM optimization passes aren't run beyond whatever `clang -O<n>`
  applies to the generated `.ll` as a whole; Kite doesn't yet run its own
  IR-level optimization passes (constant folding, dead-code elimination,
  inlining) before handing off to LLVM.

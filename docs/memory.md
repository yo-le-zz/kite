# Memory

**The short version, for everyday code:** you don't manage memory in
Kite. There's no `malloc`/`free`, no `new`/`delete`, no manual
lifetimes to think about. Write your program, and values live exactly
as long as they need to:

```
make main():
    name = "Kite"
    greeting = "Hello, " + name + "!"
    print(greeting)
```

Nothing here needs cleanup code. That's true for numbers, strings,
lists, and structs alike -- if you're new to programming, or coming
from a language that made you think about this constantly, you can
stop reading here and go write Kite code.

The rest of this document is for people who want to know what's
actually happening underneath -- either out of curiosity, or because
they're writing something performance-sensitive or are working on the
compiler itself.

## What "you don't manage it" actually means today

Kite v0.1.2 does **not** have a garbage collector. What it has instead
is simpler and worth understanding honestly:

- Numbers (`int`, `float`), `bool`, and struct instances live on the
  **stack** -- ordinary local variables, freed automatically the
  moment the function they belong to returns. This is the fastest
  possible case and it's what most of a typical program's data uses.
- Strings and lists live on the **heap** (`malloc`'d), because their
  size isn't known until runtime and/or they need to outlive the exact
  statement that created them (e.g. `substr(...)`, `a + b` on two
  strings, `append(list, x)` growing past its capacity).
- Heap memory from strings/lists is **not automatically freed**. A
  Kite program leaks every string and list it ever allocates, for the
  process's entire lifetime, with one narrow exception: when a list
  outgrows its current buffer and gets reallocated, the *old* buffer
  is `free`'d right after copying (see `emit_list_append` in
  `src/codegen.rs`) -- otherwise nothing is ever freed.

For a short-lived CLI tool, script, or anything that processes a
bounded amount of data and exits, this genuinely doesn't matter -- the
OS reclaims everything when the process ends, same as it would after
an explicit `free` right before `exit`. It matters for a long-running
program (a server, a daemon) that keeps allocating in a loop forever:
that will keep growing its memory usage without bound. If you're
writing something like that today, that's the one thing to be aware
of. A real garbage collector (or some other reclamation strategy) is
future work, not something v0.1.2 has yet.

## Why this is a reasonable place to start

Manual `free`-every-allocation is exactly the class of bug (double
free, use-after-free, forgetting to free) that trips up beginners in
languages that require it, and a full tracing garbage collector or a
borrow-checker-style ownership system are both substantial compiler
features on their own. "Allocate, never free" is the simplest
correct-for-short-programs starting point -- it can never crash from a
memory bug, it just isn't suitable yet for something that needs to run
forever. Kite chose to ship that honestly rather than pretend a real
GC already exists.

## The low-level view, for advanced use

If you want to see exactly what a piece of Kite code turns into: `kite
build` always writes the generated LLVM IR to a `.ll` file next to
your output (see the message `kite build` prints on failure, or just
look at `target/` after a successful build) -- reading that is the
most precise answer to "what does this actually do in memory" for any
specific program.

A few concrete facts, if you'd rather not read IR:

- **Layout.** A list is a 3-word header -- `{ i64 length, i64
  capacity, T* data }` -- plus a separately-`malloc`'d buffer of `T`
  for the elements. A struct is a plain LLVM struct type with one
  field per declared field, in declaration order, with no hidden
  padding logic beyond what LLVM's default struct layout already does
  for the target.
- **Strings are `i8*`** -- a plain null-terminated C string pointer,
  the same representation C uses. This is exactly why Kite can hand a
  `string` straight to an `extern` C function (see
  `docs/c-interop.md`) with no conversion step.
- **1-based indexing, everywhere that touches memory by index** --
  lists, `char_at`, `substr`. This is a Kite-level convention, not a
  memory-layout detail: the compiler subtracts 1 before it ever
  touches the underlying (0-based) buffer.
- **List growth doubles capacity** once the current buffer is full
  (see `emit_list_append` in `src/codegen.rs` for the exact growth
  check and the `realloc`-by-hand-via-`malloc`+copy+`free` sequence).
- **Every heap allocation goes through plain `malloc`/`free`** (`i8*
  @malloc(i64)` / `void @free(i8*)`, declared at the top of every
  generated `.ll` file) -- there's no custom allocator, arena, or
  bump-allocator underneath it in v0.1.2.
- **`--freestanding` builds** (see `docs/architecture.md`) still emit
  the same `malloc`/`free` calls for strings/lists -- they're your
  responsibility to provide symbols for, exactly like every other
  libc function a freestanding build references, since there's no
  hosted C runtime to supply them.

None of this is something you need to hold in your head to write
ordinary Kite programs -- it's here for the moment you do need it.

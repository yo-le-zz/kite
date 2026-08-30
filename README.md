# Kite

[![CI](https://github.com/yo-le-zz/kite/actions/workflows/ci.yml/badge.svg)](https://github.com/yo-le-zz/kite/actions/workflows/ci.yml)

**Kite** is a native, ahead-of-time compiled programming language with
Python-like readability and Rust/C-level performance potential. It compiles
`.ki` source files straight to a native executable through LLVM.

```
make main():
    print("Hello, Kite!")
```

Kite is:

- **Simple by default** -- indentation-based syntax, type inference, no
  boilerplate.
- **Safe by default** -- 1-based, bounds-checked collections; a strict,
  static type checker; no undefined behavior on out-of-range access.
- **Powerful when you need it** -- structs, growable lists, functions,
  recursion, and a straight line down to LLVM IR and native machine code.

This repository is the reference compiler: `kite`, written in Rust.

> **Status:** v0.1.2. This is a real, working compiler with a full
> pipeline (lexer -> parser -> semantic analysis -> IR -> LLVM codegen ->
> native executable) -- not a toy or a mockup. It also has real, documented
> limitations; see [`docs/roadmap.md`](docs/roadmap.md) for what's next.

---

## Installation

You'll need:

- **Rust** (stable) and Cargo, to build the compiler itself.
- **clang** (any recent LLVM/clang install) on your `PATH` -- Kite emits
  LLVM IR text and shells out to `clang` to turn it into a native
  executable and link it, the same way Rust shells out to a system linker.

```bash
git clone https://github.com/yo-le-zz/kite.git
cd kite
cargo build --release
# put target/release/kite on your PATH, or run it directly:
./target/release/kite --version
```

## Hello, World

```bash
kite init hello
cd hello
kite run
```

`kite init hello` scaffolds:

```
hello/
├── kite.toml
└── src/
    └── main.ki
```

with `src/main.ki` containing:

```
make main():
    print("Hello, Kite!")
```

`kite run` type-checks, compiles, links, and immediately executes it.

## CLI

| Command | What it does |
|---|---|
| `kite init [name]` | Scaffold a new project (or the current directory if `name` is omitted) |
| `kite build [--release] [--target <triple>]` | Compile `src/main.ki` to `target/<package>` |
| `kite build --static` | Statically linked executable, no runtime shared-library dependencies |
| `kite build --link <file>` | Link in a C source/object/static-library file (repeatable) -- see [`docs/c-interop.md`](docs/c-interop.md) |
| `kite build --lib` | Build a `.o` + C header callable from C, no `main` required |
| `kite build --freestanding` | Build a `.o` with no hosted-runtime dependency at all, for OS/kernel code |
| `kite build -o <path>` / `--out-dir <dir>` | Control where build output goes |
| `kite build -q` / `--quiet` | Suppress `Compiling`/`Finished` progress output |
| `kite run` | Build, then immediately execute the result |
| `kite check [-q]` | Type-check without producing an executable |
| `kite bench [--runs N]` | Build once (release), run N times, report min/max/average/stddev timing |
| `kite clean` | Remove the `target/` directory |
| `kite add <package>[@version]` | Add a dependency to `kite.toml` |
| `kite remove <package>` | Remove a dependency |
| `kite update` | Refresh `kite.lock` |
| `kite --version` / `kite --help` | The usual |

### Kite vs Cargo

If you know Cargo, most of this is familiar:

| Cargo | Kite |
|---|---|
| `cargo new app` | `kite init app` |
| `cargo run` | `kite run` |
| `cargo build --release` | `kite build --release` |
| `cargo check` | `kite check` |
| `cargo test` | -- (no built-in test framework yet; see `docs/roadmap.md`) |
| `Cargo.toml` / `Cargo.lock` | `kite.toml` / `kite.lock` |
| `cargo add`/`remove`/`update` | `kite add`/`remove`/`update` |

### Debug vs release builds

```bash
kite build            # debug: fast to compile, unoptimized
kite build --release   # release: LLVM optimizations on, for performance
```

`kite run`/`kite run --release` do the same, then immediately execute the
result. `kite bench` always builds in release mode, since that's the
build you'd actually ship or measure.

## Language tour

### Variables -- inferred by default, annotated if you want

```
age = 20                 // inferred: int
name = "Kite"            // inferred: string
active = true            // inferred: bool
pi: float = 3.14         // explicit annotation
```

Reassigning a name later must keep its original type -- Kite is inferred,
not untyped.

### Primitive types

| Type | Example | Size / representation |
|---|---|---|
| `int` | `x: int = 10` | signed 64-bit (like C's `int64_t` / Rust's `i64`) |
| `float` | `x: float = 1.5` | 64-bit IEEE-754 double (C's `double`) |
| `bool` | `x: bool = true` | 1 bit of information, `i1` at the LLVM level (C's `bool`/`_Bool`) |
| `string` | `x: string = "hello"` | pointer to a null-terminated byte buffer (C's `const char*`) |

These are fixed sizes, not architecture-dependent -- `int` is 64-bit
regardless of host platform. There is currently no separate `int32`,
`int8`, etc.; narrower integer types are a roadmap item.

### Functions

```
make add(a: int, b: int) -> int:
    return a + b

// Return type can be omitted and inferred from `return` statements:
make double(x: int):
    return x * 2
```

### Control flow

```
if age >= 18:
    print("adult")
orif age >= 13:
    print("teen")
else:
    print("child")
```

### Loops

```
until age >= 18:          // loops *while the condition is false*
    age = age + 1

infinit:                  // unconditional loop
    tries = tries + 1
    if tries >= 3:
        break

for i = 1 to 10:           // inclusive counting loop
    print(i)

for item in numbers:       // iterate a list
    print(item)
```

The counting form's loop variable is always inferred as `int` -- it's
never written with a type annotation:

```
for i = 0 to 10:            // correct
for i: int = 0 to 10:       // incorrect -- parse error
```

### Collections -- **1-indexed**

```
numbers = [10, 20, 30]
numbers[1]                 // 10 -- Kite lists start at 1, not 0

append(numbers, 40)        // lists are growable (backed by a heap buffer)
len(numbers)                // 4

point = (10, 20)            // tuples
point[1]                    // 10

user = {                    // dictionaries (fixed, compile-time-known keys in v0.1)
    "name": "Bob",
    "age": 20,
}
user["name"]
```

### Structs

```
type User:
    name: string
    age: int

user = User()
user.name = "Bob"
user.age = 20
```

### Enums

```
enum Color:
    Red
    Green
    Blue

c = Color.Red
if c == Color.Red:
    print("it's red")
```

Enum values are a plain `int` tag under the hood (declaration order,
starting at 0) -- `print(c)` shows that number in v0.1, not the variant's
name; string variant names at runtime are a roadmap item.

### Modules -- multi-file and multi-directory projects

```
src/
├── main.ki
└── shapes/
    └── circle.ki
```

```
// src/shapes/circle.ki
make area(radius: float) -> float:
    return 3.14159 * radius * radius
```

```
// src/main.ki
use shapes.circle

make main():
    print(area(2.0))
```

A dotted module path (`shapes.circle`) resolves to a nested file under
`src/` (`src/shapes/circle.ki`), always relative to the project's `src/`
root -- not to whichever file the `use` appears in. `use module` and
`from module import name` currently behave the same way: every function
and struct in the imported file becomes available in the importing file
(there's no per-symbol export list, and no `module.function()`
qualification, yet -- see `docs/roadmap.md`).

### Calling C from Kite, and Kite from C

```
extern make c_sqrt(x: float) -> float

make main():
    print(c_sqrt(2.0))
```

```bash
kite build --link libm_wrapper.c
```

...and the other direction, building a Kite library that C calls into:

```bash
kite build --lib   # -> target/<package>.o + target/<package>.h
```

Full details (type mapping, `--freestanding` vs `--lib`, static linking)
are in [`docs/c-interop.md`](docs/c-interop.md).

### Imports

```
use shapes.circle
from shapes.circle import area
```

See "Modules" above -- `use`/`from ... import` resolve against real
files under your project's `src/`. There is no standard library to
import yet (`stdlib/` in this repo is a design scaffold, not something
`kite build` links against -- see [`docs/roadmap.md`](docs/roadmap.md)),
so `use math` errors unless you have your own `src/math.ki`.

### Error handling

```
try:
    result = 10 / divisor
    return result
failed error:
    print(error)
finally:
    print("cleanup")
```

`finally` is guaranteed to run, even if `try` exits early via `return`,
`break`, or `continue`. There is no runtime error/exception type in v0.1
yet, so `failed` is type-checked but not currently reachable -- see the
roadmap.

### Concurrency (scaffolding)

```
async make download() -> int:
    return 42

make main():
    thread:
        do_background_work()
    result = await download()
```

`thread` and `async`/`await` parse and type-check today; v0.1 runs both
**synchronously** (no real OS threads or async runtime yet). This is
explicit, documented scaffolding, not a hidden limitation -- see the
roadmap for what real concurrency support will look like.

## Package manager

```bash
kite add http@1.2.0
kite remove http
kite update
```

These manage `kite.toml`'s `[dependencies]` table and a `kite.lock`
snapshot. There is no package registry to resolve against yet in v0.1 --
`kite build` does not fetch or compile dependency sources. See
[`docs/roadmap.md`](docs/roadmap.md).

## Documentation

- [`docs/architecture.md`](docs/architecture.md) -- how the compiler is built, stage by stage.
- [`docs/builtins.md`](docs/builtins.md) -- every built-in function (`print`, `read_file`, string `+`, ...), with examples.
- [`docs/memory.md`](docs/memory.md) -- how memory works: nothing to manage for everyday code, full detail for advanced use.
- [`docs/style.md`](docs/style.md) -- tabs vs. spaces, and other style notes.
- [`docs/c-interop.md`](docs/c-interop.md) -- calling C from Kite, and Kite from C.
- [`docs/roadmap.md`](docs/roadmap.md) -- what's implemented today, and what's next.
- [`editors/zed/`](editors/zed/) -- syntax highlighting for Zed (grammar: [`tree-sitter-kite/`](tree-sitter-kite/)); see [`docs/zed-extension-publishing.md`](docs/zed-extension-publishing.md) to publish it.

## Development

```bash
cargo build          # build the compiler
cargo test           # lexer / parser / sema / codegen / LLVM backend / CLI tests
cargo fmt            # format
cargo clippy         # lint
```

Every push and pull request runs the same checks automatically via GitHub
Actions -- see [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## License

MIT -- see [`LICENSE`](LICENSE).

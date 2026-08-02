# Kite

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

> **Status:** v0.1.0. This is a real, working compiler with a full
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
| `kite run` | Build, then immediately execute the result |
| `kite check` | Type-check without producing an executable |
| `kite clean` | Remove the `target/` directory |
| `kite add <package>[@version]` | Add a dependency to `kite.toml` |
| `kite remove <package>` | Remove a dependency |
| `kite update` | Refresh `kite.lock` |
| `kite --version` / `kite --help` | The usual |

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

### Imports

```
use math
from collections import sort
```

(Parsed and type-checked in v0.1; not yet linked against a real standard
library -- see [`docs/roadmap.md`](docs/roadmap.md).)

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
- [`docs/roadmap.md`](docs/roadmap.md) -- what's implemented today, and what's next.

## Development

```bash
cargo build          # build the compiler
cargo test           # lexer / parser / sema / codegen / LLVM backend / CLI tests
cargo fmt            # format
cargo clippy         # lint
```

## License

MIT -- see [`LICENSE`](LICENSE).

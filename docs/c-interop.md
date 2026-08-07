# Calling C from Kite, and Kite from C

Kite compiles straight to LLVM IR with a plain C ABI: functions get no
name mangling, and (per `docs/architecture.md`'s aggregate restrictions)
every function parameter/return type is a scalar -- exactly the set of
types C functions traffic in. That makes C interop close to "free" once
you know the three pieces: `extern` declarations, `kite build --lib`, and
`kite build --link`.

## Kite calling C

Declare the C function's signature with `extern` -- no body, no `:`:

```
extern make c_double(x: int) -> int

make main():
    print(c_double(21))
```

Then build, telling `kite build` where the implementation lives with
`--link` (a `.c` file, a `.o` object file, or a `.a` static library --
anything `clang` can take as a link input; repeat `--link` for more than
one):

```bash
kite build --link helper.c
kite run           # or: ./target/<package>
```

`kite build --link` compiles Kite to LLVM IR as usual and then asks
`clang` to link it together with everything you passed to `--link` in one
step -- no separate manual link command needed.

## C calling Kite

Build your Kite code as a **library** instead of a program:

```bash
kite build --lib
```

This produces two files instead of an executable:

- `target/<package>.o` -- a relocatable object file with one exported,
  unmangled symbol per Kite function (skipping `extern` ones, since those
  are declarations of *other* code, not Kite's own).
- `target/<package>.h` -- a matching C header with a prototype for each
  of those functions, so you don't have to write them by hand.

No `make main():` is required for a `--lib` build -- a library is a set
of callable functions, not a standalone program. (If one of your
functions *is* named `main`, it's still just an ordinary function in
`--lib` mode; it does not become the linked program's C runtime entry
point. Don't rely on a `--lib` build's `main`, if it has one, being what
actually runs when the final binary starts -- see the mode comparison
below.)

Then, from C:

```c
#include "mathlib.h"

int main(void) {
    printf("%lld\n", (long long)kite_square(6));
    return 0;
}
```

```bash
clang main.c target/mathlib.o -o program
./program
```

## Type mapping

| Kite type | C type | Header include |
|---|---|---|
| `int` | `int64_t` | `<stdint.h>` |
| `float` | `double` | |
| `bool` | `bool` | `<stdbool.h>` |
| `string` | `const char*` | |
| `enum` (any) | `int64_t` (the variant's declaration-order tag) | |
| no return value | `void` | |

Lists, tuples, dicts, and structs can't cross a function boundary in
Kite v0.1 at all (see `docs/architecture.md`) -- including the boundary
to/from C -- so they never appear in a generated header or in a valid
`extern` declaration. `kite check`/`kite build` reject them with a clear
error before you'd ever get to the link step.

## `--freestanding` vs `--lib`: which one do I want?

Both produce a `.o` with no required `main`. The difference is what
environment the *rest* of your final link is allowed to assume:

| | `--lib` | `--freestanding` |
|---|---|---|
| Assumes a hosted libc exists at final link time | Yes | No |
| `print`, lists (`append`/`len`), etc. | Work normally | Compile, but need *you* to supply `printf`/`malloc`/etc. at link time (see below) |
| Generates a C header | Yes | No |
| Intended use | A Kite library called from a normal C/C++ program | Embedding Kite code into an OS/kernel/bare-metal build |

`--freestanding` additionally passes `-ffreestanding -fno-builtin` to
clang. Kite's runtime support for `print`/lists/`len`/etc. is always just
a handful of `declare`d external symbols (`printf`, `malloc`, `free`,
`memcpy`, `strlen`, `strcmp`, `exit`) -- see `docs/architecture.md` --
which is exactly what makes `--freestanding` safe to link into an
environment with no libc: those declarations only need to *resolve* if
you actually call `print`/lists/etc., and if you do, your own kernel/OS
build is expected to provide matching implementations, the same way any
other freestanding C object file would.

## Self-contained executables: `--static`

A normal `kite build`/`kite run` produces a dynamically linked
executable (the usual default). Add `--static` for a statically linked
one with no runtime dependency on shared libraries:

```bash
kite build --static
```

This passes `-static` to clang; it requires a static libc (e.g. glibc's
`libc.a`, or musl) to be available on the build machine, same as it
would for any other language's `-static` build.

## Controlling build output

```bash
kite build -o path/to/output          # exact output path/name
kite build --out-dir dist             # same default name, different directory
kite build --lib -o dist/mathlib.o    # combine with any build mode
```

`-o`/`--output` always wins if both are given. Without either, output
goes to `target/<package-name>` (`.o` appended automatically for
`--lib`/`--freestanding` if you don't give one yourself via `-o`).

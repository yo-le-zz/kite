# Pointers

Kite is a Python-style, beginner-friendly language by default -- see
`docs/memory.md`, "you don't manage memory in Kite" for everyday code.
Pointers are the opt-in low-level layer underneath that: real memory
addresses, manual `alloc`/`free`, and pointer arithmetic, for the kind
of code that genuinely needs it (data structures, buffers, talking to
C, OS-level programming). Nothing here is required to write ordinary
Kite programs.

## The type: `ptr<T>`

A `ptr<int>` is the address of an `int` somewhere in memory. `T` can be
`int`/`float`/`bool`/`string`/a struct name:

```
p: ptr<int> = alloc(int)
```

`ptr<ptr<T>>` (a pointer to a pointer) isn't supported yet.

## Allocating and freeing

```
p: ptr<int> = alloc(int)          // one int, zero-initialized
r: ptr<int> = alloc_n(int, 10)    // 10 contiguous ints, zero-initialized
free(p)
free(r)
```

`alloc`/`alloc_n` always zero-initialize -- reading before writing
gives you `0`/`0.0`/`false`/never (see below for why strings are the
one exception), not garbage. This costs a little speed but removes an
entire category of bugs (reading uninitialized memory) for a small,
predictable price -- the right tradeoff for a language whose everyday
half is meant to be beginner-safe.

`free` releases memory back for reuse. Like C, Kite does **not**
protect you from:

- **Using a pointer after freeing it** (a "use-after-free"). The
  memory might already have been handed out to something else.
- **Freeing the same pointer twice** (a "double free"). This can
  corrupt the allocator's own bookkeeping.
- **Never calling `free`** (a "leak"). See `docs/memory.md` --
  everything you `alloc` is your responsibility to `free`; nothing
  does it for you automatically.

These are exactly C's rules, not a Kite-specific gap: getting this
right is what "manual memory management" *means*. The payoff is that
there's no hidden runtime doing unpredictable work behind your back --
what you write is what runs.

## Reading and writing: `*p`

```
p: ptr<int> = alloc(int)
*p = 42
print(*p)   // 42
free(p)
```

`*p` reads the value `p` points to; `*p = value` writes through it.

## Taking an address: `&x`

```
x = 7
p = &x
print(*p)   // 7
*p = 99
print(x)    // 99 -- writing through p changed x itself
```

`&x` only works on a plain local variable (`int`/`float`/`bool`/
`string`) -- not a struct field, a list element, or an arbitrary
expression (`&(x + 1)` is rejected). The variable stays valid for as
long as the function it's local to is still running; don't return
`&x` from the function `x` lives in and use it afterward (that address
is gone once the function returns) -- the compiler doesn't catch this
yet, so it's on you, same as in C.

## `null`

The "no address" pointer value. Its type always has to come from
context -- Kite can't guess what kind of pointer a bare `null` is
supposed to be:

```
p: ptr<int> = null      // OK -- the annotation says what type
p = null                 // OK -- p's type is already known from above
print(p == null)         // OK -- compared against a typed pointer

x = null                 // error: cannot infer the pointer type of `null` here
```

## Pointer arithmetic

`p + n` / `p - n` move `p` by `n` *elements*, not bytes -- the compiler
scales by `sizeof(T)` for you:

```
r: ptr<int> = alloc_n(int, 5)
i = 0
until i >= 5:
    *(r + i) = i * 10
    i = i + 1

i = 0
until i >= 5:
    print(*(r + i))
    i = i + 1
free(r)
```

This is the main way to work with a heap-allocated array today: index
into it with `*(r + i)` rather than `r[i]` (`[]` indexing is for
Kite's built-in lists, which are a different, higher-level thing --
see `docs/memory.md`'s layout notes -- and don't mix with `ptr<T>`).

## Pointers as function parameters and return values

Unlike lists/tuples/dicts/structs (see `docs/architecture.md`, "Why
aggregates are restricted"), a pointer *can* cross a function boundary
-- it's just a machine address, the same size and shape as an `int`,
so there's no aggregate-passing design needed for it:

```
make set_to(p: ptr<int>, v: int):
    *p = v

make make_ptr() -> ptr<int>:
    p: ptr<int> = alloc(int)
    return p

make main():
    p = make_ptr()
    set_to(p, 123)
    print(*p)   // 123
    free(p)
```

## Pointers to structs

`alloc(SomeStruct)` works, and pointers to the same struct compare
equal the way you'd expect:

```
type Point:
    x: int
    y: int

make main():
    p: ptr<Point> = alloc(Point)
    q = p
    print(p == q)   // true

    s = *p           // copies the struct's fields into a fresh local `s`
    s.x = 3
    s.y = 4
    print(s.x + s.y) // 7
    free(p)
```

**What doesn't work yet:** reading or writing a field *directly*
through the pointer -- `(*p).x = 3` or `print((*p).x)` -- reports a
clear `E0099` error rather than silently doing something wrong.
`*p` gives you an independent **copy** of the struct (see
`docs/memory.md` on struct value semantics), so mutating that copy's
fields never reaches back through to what `p` points to -- which would
be a confusing trap to leave unflagged, so the compiler catches it at
compile time instead. Copy out (`s = *p`), work with `s`, and if you
need the change to be visible through `p` too, write it back
explicitly once real "mutate a struct through a pointer" support
lands.

## What this doesn't do (yet)

- No bounds checking on pointer arithmetic -- `*(r + 100)` on a
  10-element allocation reads/writes memory that isn't yours. Kite's
  *lists* (`[1, 2, 3]`) do bounds-check (see `docs/memory.md`); raw
  pointers deliberately don't, for the same reason C's don't -- that
  check has a real cost, and code reaching for `ptr<T>` in the first
  place is usually code that specifically wants to avoid paying it.
- No `ptr<ptr<T>>` (pointers to pointers).
- No field/element mutation directly through a pointer (`(*p).x = 3`,
  `(*p)[i] = 3`) -- see above.
- No pointer-to-list/tuple/dict (`alloc([int])` is rejected) --
  `alloc`/`alloc_n` only take a scalar type or a struct name.

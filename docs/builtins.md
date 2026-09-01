# Built-in functions

This is every function Kite gives you for free -- no `import` needed.
There are ten of them; that's the whole list (see `src/sema.rs` if you
ever want to double-check -- each one is handled by name in
`check_call`).

## Everyday ones

### `print(value)`

Prints `value` followed by a newline. Works on any type -- `int`,
`float`, `bool`, `string`.

```
print(42)          // 42
print(3.5)          // 3.5
print(true)          // true
print("hi")          // hi
```

### `len(x)`

The length of a `string` (in bytes) or a list. Returns an `int`.

```
print(len("kite"))      // 4
print(len([1, 2, 3]))   // 3
```

### `append(list, value)`

Adds `value` to the end of `list`, growing it if needed. `value` must
match the list's element type.

```
nums = [1, 2]
append(nums, 3)
print(nums)     // [1, 2, 3]
```

## Strings

Kite indexes strings **1-based**, same as lists -- `char_at(s, 1)` is
the *first* character, not the zeroth.

### `char_at(s, i)` -> `int`

The byte value (ASCII code) of the character at 1-based position `i`.

```
print(char_at("kite", 1))   // 107  (the code for 'k')
```

### `substr(s, start, end)` -> `string`

The substring from `start` to `end`, 1-based and **inclusive on both
ends**.

```
print(substr("kite", 1, 2))   // ki
print(substr("kite", 1, len("kite")))   // kite (the whole string)
```

### String concatenation with `+`

`+` on two strings joins them into a new string. It's the *only*
overload `+` has beyond `int`/`float` -- `-`, `*`, `/`, `%` are still
numbers-only.

```
name = "Kite"
greeting = "Hello, " + name + "!"
print(greeting)   // Hello, Kite!
```

Each `+` allocates a fresh string; it never mutates either operand
(see `docs/memory.md` if you want the byte-level detail).

## Files

Kite v0.1.3 has no real error/exception type yet (see
`docs/architecture.md`), so these two report failure the simplest way
that's still checkable: an empty string, or `false`.

### `read_file(path)` -> `string`

Reads the whole file at `path` and returns its contents. If the file
doesn't exist or can't be opened, returns `""` -- there's currently no
way to tell "empty file" apart from "couldn't open it" other than
checking the file's existence yourself first.

```
content = read_file("notes.txt")
if len(content) == 0:
    print("couldn't read notes.txt (or it's genuinely empty)")
else:
    print(content)
```

### `write_file(path, content)` -> `bool`

Writes `content` to `path`, creating the file if it doesn't exist and
overwriting it if it does. Returns whether the write succeeded.

```
ok = write_file("out.txt", "hello from kite\n")
if not ok:
    print("failed to write out.txt")
```

## Command-line arguments

Both are **1-based**, and neither counts the program's own path --
`arg(1)` is the first argument *you* passed, matching Python's
`sys.argv[1:]` rather than C's `argv[0]`-inclusive convention.

### `arg_count()` -> `int`

How many command-line arguments were passed.

### `arg(i)` -> `string`

The `i`-th command-line argument, 1-based. Passing an `i` outside
`1..=arg_count()` aborts the program with an error message, the same
way an out-of-range list index does.

```
make main():
    print(arg_count())
    i = 1
    until i > arg_count():
        print(arg(i))
        i = i + 1
```

```
$ kite build && ./target/myprogram foo bar
2
foo
bar
```

## Pointers

`alloc`/`alloc_n`/`free` (plus `*p`, `&x`, and `null`, which aren't
functions but work alongside them) are covered on their own in
[`docs/pointers.md`](pointers.md) -- there's enough to them (memory
semantics, what's and isn't safe) to deserve a dedicated page rather
than a short entry here.

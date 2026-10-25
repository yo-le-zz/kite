# Kite 0.2 -- language reference (stable, pre-bootstrap)

Kite reads like Python, compiles through LLVM to C-class machine code and
keeps a minimum of Rust-style safety (bounds-checked lists, typed pointers).

## Basics
- Blocks are indented. Comments start with `//`.
- Everything is 0-based: lists, `char_at`, `substr(s, start, end)` (end exclusive),
  `arg(0)` is the first command-line argument.
- Loops: `while cond:` / `until cond:` (stop when true) / `for x in xs:` /
  `for i = a to b:` (end exclusive) / `infinit:`.
- Operators: `+ - * / %`, comparisons (also on strings), `and or not`,
  bit ops `& | ^ << >> ~`, and **every compound form**: `+= -= *= /= %= &= |= ^= <<= >>=`.

## Strings
- f-strings: `f"hello {name}, {n + 1} {{literal braces}}"`.
- `str(x)` converts `int`/`float`/`bool`; `+` concatenates.
- Prelude helpers (compiled in only when used): `split join find trim
  starts_with ends_with contains_str replace_all repeat chr to_int is_space
  is_alpha is_digit is_alnum min max abs`.

## Functions
- Defaults, named arguments, variadics:
  `make f(a: int, b: int = 2, *rest: int)`, `f(1, b=5)`.
- Any value can be passed and returned: lists, tuples, structs, classes.
  Aggregates are passed by reference (callee mutations are visible), unless
  the callee reassigns the parameter name (then it works on a copy).
- Types in signatures: `int float bool string [T] (A, B) ptr<T> StructName`.
- Tuple unpacking: `a, b = pair()`.

## Collections
- Lists of scalars, strings, structs: `append pop remove(xs, i) insert(xs, i, v) clear len`.
- Typed empty list: `xs: [Tok] = []`.
- Structs can hold lists and other structs; `obj.items` aliases the real field,
  `append(obj.items, x)` mutates it.
- Hash maps: `m = StrMap_int()` (string keys; `StrMap_string`, `StrMap_float`,
  `StrMap_bool`, or `StrMap_<YourStruct>`): `m.set(k, v)`, `m.get(k)`, `m.has(k)`,
  `m.size()`, `m.keys` (insertion order).

## Classes
```
class Animal:
    name: string
    make init(self, name: string):
        self.name = name
    make speak(self) -> string:
        return "..."

class Dog(Animal):
    make speak(self) -> string:
        return "woof"
```
- `Dog("Rex")` calls `init`; `Animal.init(self, name)` calls the base version.
- Single inheritance; methods overridden in subclasses are dispatched
  dynamically (hidden class tag), so `a.speak()` on an `Animal` parameter that
  holds a `Dog` calls `Dog.speak`. A `Dog` can be passed where an `Animal` is expected.
- The receiver's class is inferred from assignments, annotated parameters and
  function return types.

## Data enums and `match`
```
enum Expr:
    Num(v: int)
    Add(l: ptr<Expr>, r: ptr<Expr>)
    Nil

match x:
    case Num(v):
        ...
    case Add(l, r):
        ...
    else:
        ...
```
Construct with `Expr.Num(3)`. Plain enums (`enum Color: Red, Green`) stay integer tags.

## Pointers and `null`
- `p = alloc(T)`, `*p = value`, `v = *p`, `p.field` / `p.field = x` (auto-deref).
- `null` takes its type from context (assignment target, argument, return type).
- Recursive data = data enums / structs holding `ptr<Self>`.

## Not in 0.2
`**kwargs`, generic user types, struct value-copy-vs-alias parity with Python for `b = a`,
dict literals with keys added at run time (use `StrMap_T`), map key deletion.

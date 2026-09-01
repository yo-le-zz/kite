# Kite standard library (design scaffold)

This directory is a **design scaffold**, not compiled code: `kite build`
does not currently resolve `use`/`from ... import` against anything here
(imports are parsed and type-checked as no-ops in v0.1 -- see
not yet implemented). Each `.ki` file below sketches the intended surface
of a future standard-library module, Python-flavored, so the eventual
implementation has a concrete shape to build toward.

| Module | Purpose |
|---|---|
| `io.ki` | Reading/writing stdin, stdout, stderr beyond `print` |
| `fs.ki` | File and directory operations |
| `math.ki` | Numeric functions and constants |
| `json.ki` | Parsing/serializing JSON |
| `http.ki` | A minimal HTTP client |
| `time.ki` | Clocks, durations, sleeping |
| `collections.ki` | List/dict helpers beyond the `append`/`len` builtins |
| `system.ki` | Process/environment/OS information |

Turning these into real, linked modules requires the aggregate-passing
and multi-file module system these will eventually sit on top of.

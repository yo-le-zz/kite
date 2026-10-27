# Kite -- what is left to do (v0.3.0)

Legend: **[blocker]** = required for the self-hosted compiler, **[lang]** language/runtime,
**[tools]** tooling, **[release]** packaging/CI, **[docs]**.

## 1. Bootstrap: port the Rust compiler to Kite  **[blocker]**
Measured on `archive/rust-stage0` (about 12 000 lines of Rust). Done: lexer, parser, diagnostics (~2 500 lines, ~21 %).
Every phase is verified against the Rust one with canonical dumps (`scripts/difftest.sh`) before moving on.

| # | phase | Rust size | Kite file to write | verification |
|---|-------|-----------|--------------------|--------------|
| 1 | desugar (defaults, named args, `*args`, unpack, classes, vcalls, data enums, `match`, void inference) | `desugar.rs` 1 147 | `compiler/src/desugar.ki` | dump of the desugared AST |
| 2 | prelude injection (`core.ki`, `StrMap_T` templates) | `prelude.rs` 122 | `compiler/src/prelude.ki` | dump after injection |
| 3 | sema (types, tables, inference, E-codes, messages) | `sema.rs` 2 001 | `compiler/src/sema.ki` | typed-AST dump + identical diagnostics on the error corpus |
| 4 | IR lowering | `ir.rs` 2 861 | `compiler/src/ir.ki` | IR text dump |
| 5 | LLVM codegen (strings, lists, sret, alloca hoisting, vcalls, `.ll` text) | `codegen.rs` 1 557 | `compiler/src/codegen.ki` | **identical `.ll`** |
| 6 | project/manifest (`kite.toml` -> need a small TOML reader), module resolution (`use`/`from`), C header generation | `project.rs`, `resolve.rs`, `cheader.rs` ~530 | `project.ki`, `resolve.ki`, `cheader.ki` | same project graph / same `.h` |
| 7 | driver + CLI: `init`, `build`, `run`, `check`, `clean`, `bench`, `package`; flags `--release`, `--target`, `--freestanding`, `--lib`, `-q`; colored output; calling `clang` | `driver.rs`, `cli.rs`, `commands/*`, `config.rs`, `info.rs`, `output/` ~1 400 | `driver.ki`, `cli.ki`, `commands.ki` | same outputs on the CLI tests |
| 8 | stage2: `kitec` compiles `compiler/` -> identical IR to stage1 | - | `./build.sh` (already scripted) | writes `compiler/BOOTSTRAPPED` |
| 9 | switch-over: package `kitec` as `kite` (`package-release.sh --compiler auto`), keep `archive/rust-stage0` as the seed | - | - | all Rust tests re-run against `kitec` |

Kite features that will probably be needed while porting (add to stage0 first):
- float formatting / parsing in the runtime (`str(float)` is `%g`; the Rust dumper uses shortest-round-trip)
- file/dir helpers (list directory, exists, mkdir, run process and capture output, env vars, `getcwd`)
- `StrMap_T` iteration helpers, `sort` for strings/ints, `reverse`, `slice`, `join` for non-strings
- better compile errors inside the prelude (spans point to the user file today)

## 2. Language and runtime  **[lang]**
- `**kwargs` (needs typed dict values or `StrMap_T` plumbing)
- user generics (`class Stack<T>`, generic functions) -- would replace the `StrMap_T` text templates
- real dynamic dict literals `{"a": 1}` with keys added at run time (today: `StrMap_T`), key deletion, int keys
- struct `b = a` aliasing like Python (today: copy); assigning a subclass to a base-typed variable
- nested collections: lists of lists, lists of tuples, tuples in structs, `[[int]]`
- `Option`/`Result` sugar and `?` propagation; `match` on plain enums, ints and strings, exhaustiveness check
- f-string format specs (`{x:.2f}`, `{n:>5}`), precise error spans inside f-strings
- multiple inheritance/traits (single inheritance + virtual dispatch exist), `super()` sugar, `__str__`-like protocol
- memory: freeing (arena/GC/ownership), leak checks, sanitizer runs in CI
- threads/async/await: finish and document (parsed, minimal runtime)
- stdlib: strings (utf-8 aware), math, files, paths, time, env, process, json, regex, sorting
- integers wider than i64, unsigned types, `u8` bytes / `[u8]` buffers
- FFI: callbacks, structs by value, varargs

## 3. Tooling  **[tools]**
- `kite fmt`, `kite doc`, `kite test` (test runner), `kite add`/dependency fetching, lock file
- language server (LSP) built on the Kite parser; reuse `kitec ast`
- update **tree-sitter-kite** and the **Zed extension** (`editors/zed`) for: `class`, `match/case`, f-strings,
  default/named/variadic params, `*args`, typed lists `[T]`, tuple types, `x, y = ...`, `ptr<T>` auto-deref
- editor support for VS Code / Neovim; syntax highlighting on the website
- REPL / playground on the website (compile to WASM or server-side)

## 4. Tests  **[tools]**
- Rust crate: add unit tests for the 0.2 features (classes/virtual dispatch, data enums, aggregates, prelude) -- today only
  the recorded-output harness (`tests/stable_examples.rs`) covers them
- error-message corpus (one file per E-code) shared by the Rust and Kite compilers
- fuzzing the lexer/parser (differential: Rust vs Kite), property tests for desugar
- benchmarks tracked in CI (`kite bench`), compile-time budget

## 5. Release / distribution  **[release]**
- Run the GitHub workflows once for real (`ci.yml`, `release.yml`, `build-installer-macos.yml`) -- they are untested
- `windows-arm64` needs real MSVC (not buildable with `cross`); GUI installer for windows-arm64 blocked by `ring`
- GUI installer (`installer/`): switch it to the new release asset names + `checksums.txt` verification, `.deb`
  and `.msi`/`winget` options, uninstall, offer to install clang; bump its version independently
- `package-release.sh`: sign artifacts (minisign/GPG), reproducible builds, upload step, SBOM
- Distribution channels: apt repository (signed), Homebrew tap, winget manifest, Scoop, AUR, Nix, Docker image
- `.deb`: man page, shell completions, `kite` bash/zsh/fish completion files
- website: real domain, docs pages, download table generated from the latest release, versioned docs
- CI cache for the bootstrap, nightly job that runs `./build.sh test` and the differential tests

## 6. Docs  **[docs]**
- `docs/language-0.3.md`: keep in sync with each language change; tutorial ("A tour of Kite"), cookbook, FAQ
- `docs/architecture.md` is outdated (still describes only the Rust pipeline) -> describe stage0/stage1/stage2 and the arena AST
- API reference for the prelude and builtins (`docs/builtins.md` predates `str`, `pop`, `exit`, `StrMap_T`)
- contributor guide: how to port a phase and run the differential tests; style guide for Kite code
- migrate the `bootstrap`/`installer` READMEs, add a CHANGELOG policy and release checklist

## 7. Housekeeping
- the repository you cloned may still contain the pre-0.3 files at the root (`Cargo.toml`, `src/`, `tests/`, `target/`):
  delete them, everything lives under `archive/rust-stage0/` now
- `stdlib/prelude/` and `archive/rust-stage0/src/prelude/` are two copies (the Rust crate must be self-contained for
  `cross`/Docker); `build.sh` warns if they drift

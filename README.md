<p align="center"><img src="assets/logo/kite-256.png" alt="Kite" width="128"></p>

# Kite

Readable like Python, fast like C, with a pinch of Rust-style safety. Version 0.3.0.

## Install
```
curl -fsSL https://kite-lang.pages.dev/install.sh | sh                 # Linux
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --deb     # Debian/Ubuntu (.deb)
curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --rpm     # Fedora/RHEL/openSUSE (.rpm)
curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh           # macOS
irm https://kite-lang.pages.dev/install.ps1 | iex                      # Windows (PowerShell)
```
Kite needs `clang` to produce native executables.

## Build from source
```
./build.sh          # Rust stage0 -> kitec (the compiler written in Kite)
./build.sh test     # + Kite-vs-Rust differential tests
./clean.sh --deep   # remove every build output
```

## Layout
| path | content |
|---|---|
| `compiler/` | the Kite compiler written in Kite (`kitec`) |
| `archive/rust-stage0/` | the original Rust compiler (stage0, kept as the bootstrap seed) |
| `stdlib/prelude/` | library code written in Kite |
| `docs/` | `language-0.2.md`, `bootstrap.md`, `architecture.md`, ... |
| `examples/` | sample programs (`stable/`, `lang5/` have recorded outputs) |
| `scripts/` | `package-release.sh`, `cross-build.sh`, `difftest.sh` |
| `editors/`, `tree-sitter-kite/`, `linguist/` | VS Code + Zed + tree-sitter support, GitHub Linguist PR material (`docs/editors.md`) |
| `installer/` | the GUI installer (Rust + iced) |
| `website/` | kite-lang.pages.dev (install scripts + landing page) |

## Releases
`scripts/package-release.sh` builds the Linux and Windows (x64, arm64) archives, the `.deb`
packages, the `.rpm` packages and `checksums.txt` into `dist/release/`. It packages the stable Rust compiler until the
bootstrap is complete (`compiler/BOOTSTRAPPED`), then the self-hosted one.

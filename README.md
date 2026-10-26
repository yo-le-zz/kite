# Kite

Readable like Python, fast like C, with a pinch of Rust-style safety.

* `docs/language-0.2.md` -- language reference
* `docs/bootstrap.md`    -- how the compiler is being rewritten in Kite
* `archive/rust-stage0/` -- the original Rust compiler (stage0, kept)
* `compiler/`            -- the Kite compiler written in Kite (`kitec`)
* `stdlib/prelude/`      -- library code written in Kite
* `examples/`            -- sample programs (`stable/` and `lang5/` have recorded outputs)

Build everything: `./build.sh` (needs cargo and clang). Run `./build.sh test`
for the differential tests.

## Packages
```
scripts/package.sh deb            # .deb for this machine (amd64 or arm64)
scripts/package.sh deb arm64      # cross .deb (needs an aarch64 linker) -- or use CI
scripts/package.sh windows        # Windows x64 + arm64 zips (cross-build; CI recommended)
scripts/package.sh all
```
Outputs land in `dist/`. `.github/workflows/release.yml` builds the Linux amd64/arm64
`.deb` and the Windows x64/arm64 zips on native runners. The `.deb` depends on `clang`;
on Windows install it with `winget install LLVM.LLVM` (the zip ships `install.ps1`).
Install the deb: `sudo apt install ./kite_0.3.0_amd64.deb`.

#!/bin/bash
# Remove every build output and cache of this repository.
#
#   ./clean.sh          clean build outputs (stage0, stage1, dist, example targets, temp dirs)
#   ./clean.sh --deep   also remove cargo target dirs of every sub-project (installer, ...)
#                       and run `cargo clean` where a Cargo.toml exists
#
# It never touches ~/.cargo, your sources, or anything outside this directory
# (except /tmp/kite_* scratch directories created by the test-suite).
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

rm_dir() { [ -e "$1" ] && { echo "  rm $1"; rm -rf "$1"; }; return 0; }

echo "==> cleaning build outputs"
rm_dir archive/rust-stage0/target
rm_dir compiler/target
rm_dir target                      # legacy location of the Rust build
rm_dir dist
rm_dir installer/target
rm_dir stage2

# Kite projects built anywhere in the tree (examples, tests, bootstrap): target/ + kite.lock caches
while IFS= read -r d; do rm_dir "$d"; done < <(find . -type d -name target \
    -not -path './.git/*' -not -path '*/node_modules/*' \
    \( -path './examples/*' -o -path './bootstrap/*' -o -path './tests/*' -o -path './stdlib/*' -o -path './docs/*' \) 2>/dev/null)

# stray generated files
find . -type f \( -name '*.ll' -o -name '*.o' -o -name '*.rlib' \) \
    -not -path './.git/*' -not -path './archive/*/src/*' -delete 2>/dev/null

# scratch dirs from test runs
rm -rf /tmp/kite_stable_* /tmp/dt_rs.txt /tmp/dt_ki.txt 2>/dev/null

if [ "${1:-}" = "--deep" ]; then
  echo "==> deep clean"
  while IFS= read -r toml; do
    dir=$(dirname "$toml")
    if command -v cargo >/dev/null 2>&1; then
      (cd "$dir" && cargo clean 2>/dev/null) && echo "  cargo clean $dir"
    fi
  done < <(find . -name Cargo.toml -not -path './.git/*' -not -path '*/node_modules/*')
  while IFS= read -r d; do rm_dir "$d"; done < <(find . -type d \( -name target -o -name .kite \) \
      -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null)
fi
echo "done."

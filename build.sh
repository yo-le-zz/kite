#!/bin/bash
# Kite build + bootstrap.
#
#   ./build.sh            build everything that can be built (see stages below)
#   ./build.sh test       same, then run the differential tests (Kite vs Rust)
#   ./build.sh status     show which compiler phases are ported to Kite
#   ./build.sh clean      remove build outputs (see also ./clean.sh)
#
# Stages
#   stage0  the Rust compiler (archive/rust-stage0)          built with cargo + clang
#   stage1  kitec, the compiler written in Kite (compiler/)   compiled by stage0
#   stage2  kitec compiled by stage1 itself                   (needs the full port)
#   stage2 must produce the same LLVM IR as stage1; when it does, compiler/BOOTSTRAPPED
#   is written and kitec can replace the Rust compiler.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
STAGE0_DIR="$ROOT/archive/rust-stage0"
STAGE0_TARGET="$STAGE0_DIR/target"   # always ours, whatever CARGO_TARGET_DIR says
STAGE0="${KITE_STAGE0:-$STAGE0_TARGET/release/kite}"
KITEC="$ROOT/compiler/target/kitec"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }

case "${1:-build}" in
  clean)  exec "$ROOT/clean.sh" ;;
  status)
    [ -x "$KITEC" ] || { echo "kitec not built yet: run ./build.sh"; exit 1; }
    bold "phases ported to Kite:"; "$KITEC" --capabilities | sed 's/^/  - /'
    [ -f "$ROOT/compiler/BOOTSTRAPPED" ] && echo "bootstrap: COMPLETE" || echo "bootstrap: in progress"
    exit 0 ;;
esac

# The Rust crate keeps its own frozen copy of the prelude (it must be self-contained for
# `cross`/Docker builds); warn when it drifts from the canonical stdlib/prelude.
for f in core.ki map.tpl; do
  cmp -s "$ROOT/stdlib/prelude/$f" "$STAGE0_DIR/src/prelude/$f" || \
    echo "warning: stdlib/prelude/$f differs from archive/rust-stage0/src/prelude/$f (stage0 uses its own copy)" >&2
done

bold "==> stage0: Rust compiler"
if [ ! -x "$STAGE0" ]; then
  (cd "$STAGE0_DIR" && CARGO_TARGET_DIR="$STAGE0_TARGET" cargo build --release --bins --examples)
fi
[ -x "$STAGE0" ] || { echo "error: stage0 binary not found at $STAGE0" >&2; exit 1; }
echo "    $("$STAGE0" --version) -> $STAGE0"

bold "==> stage1: kitec (Kite) compiled by stage0"
(cd "$ROOT/compiler" && "$STAGE0" build --release)
echo "    $("$KITEC" --version) -> $KITEC"

PORTED="$("$KITEC" --capabilities | tr '\n' ' ')"
echo "    ported phases: $PORTED"
if echo "$PORTED" | grep -qw build; then
  bold "==> stage2: kitec compiled by kitec"
  rm -rf "$ROOT/stage2" && mkdir -p "$ROOT/stage2" && cp -r "$ROOT/compiler/." "$ROOT/stage2/"
  rm -rf "$ROOT/stage2/target"
  (cd "$ROOT/stage2" && "$KITEC" build --release)
  if cmp -s "$ROOT/compiler/target/kitec.ll" "$ROOT/stage2/target/kitec.ll"; then
    echo "    stage1 and stage2 produce identical LLVM IR: bootstrap complete"
    date -u +%FT%TZ > "$ROOT/compiler/BOOTSTRAPPED"
  else
    echo "error: stage2 differs from stage1" >&2; exit 1
  fi
else
  bold "==> stage2: skipped (the port of the remaining phases is in progress; ./build.sh status)"
fi

if [ "${1:-}" = "test" ]; then
  bold "==> differential tests (Kite vs Rust)"
  cd "$ROOT"
  FILES=$(ls examples/*.ki examples/*/*.ki stdlib/prelude/core.ki compiler/src/*.ki)
  export KITE_STAGE0_TARGET="$STAGE0_TARGET"
  scripts/difftest.sh tokens $FILES
  scripts/difftest.sh ast $FILES
fi

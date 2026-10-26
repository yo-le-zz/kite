#!/bin/bash
# Kite build / bootstrap driver.
#
#   ./build.sh            build stage0 (Rust) then stage1 (kitec, written in Kite)
#   ./build.sh test       also run the differential tests (Kite vs Rust)
#   ./build.sh clean      remove build outputs
#
# Stage0 is the archived Rust compiler (archive/rust-stage0). Stage1 is the
# Kite compiler written in Kite (compiler/), compiled BY stage0.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
STAGE0_DIR="$ROOT/archive/rust-stage0"
# Always use our own target dir, whatever CARGO_TARGET_DIR / cargo config say.
STAGE0_TARGET="$STAGE0_DIR/target"
STAGE0="${KITE_STAGE0:-$STAGE0_TARGET/release/kite}"

case "${1:-build}" in
  clean)
    rm -rf "$STAGE0_TARGET" "$ROOT/compiler/target"
    exit 0;;
esac

if [ ! -x "$STAGE0" ]; then
  echo "==> stage0: building the Rust compiler (needs cargo + clang)"
  (cd "$STAGE0_DIR" && CARGO_TARGET_DIR="$STAGE0_TARGET" cargo build --release --bins --examples)
fi
if [ ! -x "$STAGE0" ]; then
  echo "error: stage0 binary not found at $STAGE0" >&2
  exit 1
fi

echo "==> stage1: compiling kitec (Kite) with stage0"
(cd "$ROOT/compiler" && "$STAGE0" build --release)
echo "    -> compiler/target/kitec"

if [ "${1:-}" = "test" ]; then
  cd "$ROOT"
  FILES=$(ls examples/*.ki examples/*/*.ki bootstrap/*.ki stdlib/prelude/core.ki compiler/src/*.ki)
  KITE_STAGE0_TARGET="$STAGE0_TARGET" scripts/difftest.sh tokens $FILES
  KITE_STAGE0_TARGET="$STAGE0_TARGET" scripts/difftest.sh ast $FILES
fi

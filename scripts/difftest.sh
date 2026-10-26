#!/bin/bash
# Differential test: Kite-in-Kite lexer/parser vs the Rust stage0 reference.
# usage: scripts_difftest.sh tokens|ast files...
mode=$1; shift
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RS=${KITE_STAGE0_TARGET:-$ROOT/archive/rust-stage0/target}/release/examples/dump_ast
KC=$ROOT/compiler/target/kitec
fail=0; n=0
for f in "$@"; do
  $RS $mode "$f" > /tmp/dt_rs.txt 2>/dev/null; rs=$?
  $KC $mode "$f" > /tmp/dt_ki.txt 2>/dev/null; ki=$?
  n=$((n+1))
  if [ $rs -ne 0 ] || [ $ki -ne 0 ]; then
    if [ $rs -ne $ki ]; then echo "EXIT DIFF $f (rs=$rs ki=$ki)"; fail=$((fail+1)); fi
    continue
  fi
  if ! cmp -s /tmp/dt_rs.txt /tmp/dt_ki.txt; then fail=$((fail+1)); echo "DIFF $f"; fi
done
echo "$mode: $n files, $fail differ"

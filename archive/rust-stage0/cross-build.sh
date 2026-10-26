#!/usr/bin/env bash
#
# build.sh -- cross-compile the `kite` compiler binary for every supported
# OS/architecture combination, with progress reporting, and package each
# result into ./dist/ ready for an installer to pick up.
#
# NOTE: this cross-compiles the `kite` CLI/compiler itself (a Rust
# binary). It has nothing to do with `kite build --target <triple>`,
# which controls what native architecture a *Kite program* is compiled
# to at runtime via clang -- that is a separate, already-implemented
# feature of the compiler (see src/driver.rs).
#
# Usage:
#   ./build.sh                          build every target below
#   ./build.sh --targets linux-x64,macos-arm64
#   ./build.sh --list                   list available target names and exit
#   ./build.sh --output-dir out         write archives to ./out instead of ./dist
#   ./build.sh --no-strip               skip stripping debug symbols
#   ./build.sh --jobs 4                 pass -j4 to cargo
#   ./build.sh -h | --help
#
# Prerequisites:
#   - Rust + Cargo, with `rustup` (used to install each target's stdlib).
#   - For the most reliable cross-compilation across every OS at once,
#     install `cross` (https://github.com/cross-rs/cross) and have Docker
#     (or Podman) running -- this script uses it automatically when
#     available. Without it, this script falls back to plain
#     `cargo build --target <triple>`, which only works for targets whose
#     linker is already installed on this machine (e.g. `mingw-w64` for
#     the `*-pc-windows-gnu` targets, `gcc-aarch64-linux-gnu` for
#     Linux/aarch64, an Apple SDK + osxcross for macOS targets, etc.).
#     A target that can't be linked here is reported and skipped rather
#     than failing the whole run -- run this script in CI (see
#     .github/workflows/) or with `cross` installed to build all of them.

set -euo pipefail

# ---------------------------------------------------------------------------
# Target matrix: internal short name -> Rust target triple -> archive kind
# ---------------------------------------------------------------------------
# short_name:triple:kind   (kind is "tar" or "zip")
ALL_TARGETS=(
  "linux-x64:x86_64-unknown-linux-gnu:tar"
  "linux-x64-musl:x86_64-unknown-linux-musl:tar"
  "linux-arm64:aarch64-unknown-linux-gnu:tar"
  "linux-arm64-musl:aarch64-unknown-linux-musl:tar"
  "macos-x64:x86_64-apple-darwin:tar"
  "macos-arm64:aarch64-apple-darwin:tar"
  "windows-x64:x86_64-pc-windows-gnu:zip"
  "windows-arm64:aarch64-pc-windows-msvc:zip"
)

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
OUTPUT_DIR="dist"
SELECTED_NAMES=""
STRIP=1
JOBS=""

usage() {
  sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --targets)
      SELECTED_NAMES="$2"; shift 2 ;;
    --output-dir)
      OUTPUT_DIR="$2"; shift 2 ;;
    --no-strip)
      STRIP=0; shift ;;
    --jobs)
      JOBS="$2"; shift 2 ;;
    --list)
      for t in "${ALL_TARGETS[@]}"; do echo "${t%%:*}"; done
      exit 0 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Pretty output helpers
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; CYAN=$'\033[36m'
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

step() { printf "%s[%d/%d]%s %s%s%s\n" "$BOLD" "$1" "$2" "$RESET" "$CYAN" "$3" "$RESET"; }
info() { printf "     %s%s%s\n" "$DIM" "$1" "$RESET"; }
ok()   { printf "     %s✔ %s%s\n" "$GREEN" "$1" "$RESET"; }
warn() { printf "     %s⚠ %s%s\n" "$YELLOW" "$1" "$RESET"; }
fail() { printf "     %s✘ %s%s\n" "$RED" "$1" "$RESET"; }

draw_progress() {
  # draw_progress <done> <total>
  local done=$1 total=$2 width=30
  local filled=$(( done * width / total ))
  local empty=$(( width - filled ))
  printf "\r%s[" "$DIM"
  printf "%0.s#" $(seq 1 "$filled" 2>/dev/null) || true
  printf "%0.s." $(seq 1 "$empty" 2>/dev/null) || true
  printf "] %d/%d%s" "$done" "$total" "$RESET"
}

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

VERSION="$(grep -m1 '^version' Cargo.toml | sed -E 's/version *= *"(.*)"/\1/')"
BIN_NAME="kite"

if [[ -n "$SELECTED_NAMES" ]]; then
  IFS=',' read -r -a WANTED <<< "$SELECTED_NAMES"
else
  WANTED=()
  for t in "${ALL_TARGETS[@]}"; do WANTED+=("${t%%:*}"); done
fi

TARGETS_TO_BUILD=()
for name in "${WANTED[@]}"; do
  found=""
  for t in "${ALL_TARGETS[@]}"; do
    if [[ "${t%%:*}" == "$name" ]]; then found="$t"; break; fi
  done
  if [[ -z "$found" ]]; then
    echo "unknown target name: $name (use --list to see available names)" >&2
    exit 1
  fi
  TARGETS_TO_BUILD+=("$found")
done

TOTAL=${#TARGETS_TO_BUILD[@]}
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/checksums.txt"

echo
printf "%sKite v%s -- multi-target release build%s\n" "$BOLD" "$VERSION" "$RESET"
printf "%sbuilding %d target(s) -> %s/%s\n\n" "$DIM" "$TOTAL" "$OUTPUT_DIR" "$RESET"

USE_CROSS=0
if command -v cross >/dev/null 2>&1 && (command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1); then
  USE_CROSS=1
  info "using 'cross' for cross-compilation (Docker/Podman backend detected)"
else
  info "'cross' not found -- falling back to 'cargo build --target' per target"
  info "(a target will be skipped here if its linker isn't installed; install"
  info " 'cross' + Docker for one-command builds of every target below)"
fi
echo

HAVE_RUSTUP=0
command -v rustup >/dev/null 2>&1 && HAVE_RUSTUP=1

JOBS_ARG=()
[[ -n "$JOBS" ]] && JOBS_ARG=(-j "$JOBS")

# ---------------------------------------------------------------------------
# Build loop
# ---------------------------------------------------------------------------
declare -a RESULT_NAME RESULT_STATUS RESULT_TIME RESULT_PATH
i=0
START_ALL=$(date +%s)

for entry in "${TARGETS_TO_BUILD[@]}"; do
  i=$((i + 1))
  short="${entry%%:*}"
  rest="${entry#*:}"
  triple="${rest%%:*}"
  kind="${rest##*:}"

  step "$i" "$TOTAL" "$short  ($triple)"
  t0=$(date +%s)

  if [[ "$HAVE_RUSTUP" -eq 1 ]]; then
    rustup target add "$triple" >/dev/null 2>&1 || true
  fi

  BUILD_OK=1
  if [[ "$USE_CROSS" -eq 1 ]]; then
    if ! cross build --release --target "$triple" "${JOBS_ARG[@]}" >/tmp/kite-build-"$short".log 2>&1; then
      BUILD_OK=0
    fi
  else
    if ! cargo build --release --target "$triple" "${JOBS_ARG[@]}" >/tmp/kite-build-"$short".log 2>&1; then
      BUILD_OK=0
    fi
  fi

  t1=$(date +%s)
  elapsed=$((t1 - t0))

  if [[ "$BUILD_OK" -eq 0 ]]; then
    fail "build failed for $short after ${elapsed}s (see /tmp/kite-build-$short.log)"
    tail -n 6 /tmp/kite-build-"$short".log | sed 's/^/       | /'
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_PATH+=("-")
    echo
    continue
  fi

  # Locate the built binary.
  bin_path="target/$triple/release/$BIN_NAME"
  if [[ "$kind" == "zip" ]]; then
    bin_path="${bin_path}.exe"
  fi
  if [[ ! -f "$bin_path" ]]; then
    fail "expected binary not found at $bin_path"
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_PATH+=("-")
    echo
    continue
  fi

  ok "compiled in ${elapsed}s"

  # Stage a package directory: kite (or kite.exe), README, LICENSE.
  stage_dir="$(mktemp -d)/kite-${VERSION}-${short}"
  mkdir -p "$stage_dir"
  cp "$bin_path" "$stage_dir/"
  [[ -f README.md ]] && cp README.md "$stage_dir/"
  [[ -f LICENSE ]] && cp LICENSE "$stage_dir/"

  staged_bin="$stage_dir/$(basename "$bin_path")"
  if [[ "$STRIP" -eq 1 && "$kind" == "tar" ]]; then
    strip "$staged_bin" 2>/dev/null || true
  fi

  archive_base="kite-${VERSION}-${short}"
  case "$kind" in
    tar)
      archive_path="$OUTPUT_DIR/${archive_base}.tar.gz"
      tar -C "$(dirname "$stage_dir")" -czf "$archive_path" "$(basename "$stage_dir")"
      ;;
    zip)
      archive_path="$OUTPUT_DIR/${archive_base}.zip"
      if command -v zip >/dev/null 2>&1; then
        (cd "$(dirname "$stage_dir")" && zip -r -q "$OLDPWD/$archive_path" "$(basename "$stage_dir")")
      else
        warn "no 'zip' command found; writing a .tar.gz instead"
        archive_path="$OUTPUT_DIR/${archive_base}.tar.gz"
        tar -C "$(dirname "$stage_dir")" -czf "$archive_path" "$(basename "$stage_dir")"
      fi
      ;;
  esac
  rm -rf "$(dirname "$stage_dir")"

  size_h=$(du -h "$archive_path" | cut -f1)
  ok "packaged -> $archive_path ($size_h)"

  if command -v sha256sum >/dev/null 2>&1; then
    (cd "$OUTPUT_DIR" && sha256sum "$(basename "$archive_path")" >> checksums.txt)
  elif command -v shasum >/dev/null 2>&1; then
    (cd "$OUTPUT_DIR" && shasum -a 256 "$(basename "$archive_path")" >> checksums.txt)
  fi

  RESULT_NAME+=("$short"); RESULT_STATUS+=("ok"); RESULT_TIME+=("${elapsed}s"); RESULT_PATH+=("$archive_path")
  echo
done

END_ALL=$(date +%s)
TOTAL_TIME=$((END_ALL - START_ALL))

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
printf "%s%s Build summary %s%s\n" "$BOLD" "----" "----" "$RESET"
printf "%-20s %-10s %-8s %s\n" "TARGET" "STATUS" "TIME" "ARCHIVE"
n_ok=0
n_fail=0
for idx in "${!RESULT_NAME[@]}"; do
  name="${RESULT_NAME[$idx]}"
  status="${RESULT_STATUS[$idx]}"
  time_s="${RESULT_TIME[$idx]}"
  path="${RESULT_PATH[$idx]}"
  if [[ "$status" == "ok" ]]; then
    n_ok=$((n_ok + 1))
    printf "%-20s %s%-10s%s %-8s %s\n" "$name" "$GREEN" "ok" "$RESET" "$time_s" "$path"
  else
    n_fail=$((n_fail + 1))
    printf "%-20s %s%-10s%s %-8s %s\n" "$name" "$RED" "failed" "$RESET" "$time_s" "$path"
  fi
done

echo
printf "%s%d succeeded, %d failed%s -- total time %ds\n" "$BOLD" "$n_ok" "$n_fail" "$RESET" "$TOTAL_TIME"
[[ -f "$OUTPUT_DIR/checksums.txt" ]] && printf "checksums written to %s/checksums.txt\n" "$OUTPUT_DIR"

if [[ "$n_fail" -gt 0 ]]; then
  echo
  warn "some targets failed to build locally -- this is expected without 'cross'"
  warn "+ Docker installed, or without the matching cross-linker toolchain for"
  warn "that OS/arch. Install 'cross' (https://github.com/cross-rs/cross) and"
  warn "re-run for a complete, all-platform build."
  exit 1
fi

exit 0

#!/usr/bin/env bash
#
# build.sh -- cross-compile the `kite` compiler binary for every supported
# OS/architecture combination (64-bit and 32-bit), with fully visible build
# output, and package each result into ./dist/<os>/<arch>/ in a format an
# installer/updater can grab straight from a GitHub release for that
# platform (.deb for Debian/Ubuntu, .zip containing the .exe for Windows,
# .tar.gz for macOS and generic Linux).
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
#   ./build.sh --no-deb                 skip building .deb packages for Linux
#   ./build.sh --quiet                  hide live cargo/cross output (log file only)
#   ./build.sh --jobs 4                 pass -j4 to cargo
#   ./build.sh -h | --help
#
# Output layout (dist/ by default):
#   dist/linux/x64/kite-0.1.0-linux-x64.tar.gz
#   dist/linux/x64/kite_0.1.0_amd64.deb
#   dist/linux/x86/kite-0.1.0-linux-x86.tar.gz
#   dist/linux/x86/kite_0.1.0_i386.deb
#   dist/macos/arm64/kite-0.1.0-macos-arm64.tar.gz
#   dist/windows/x64/kite-0.1.0-windows-x64.zip
#   dist/windows/x86/kite-0.1.0-windows-x86.zip
#   dist/checksums.txt   (paths relative to dist/)
#
# Prerequisites:
#   - Rust + Cargo, with `rustup` (used to install each target's stdlib).
#   - For the most reliable cross-compilation across every OS/arch at once,
#     install `cross` (https://github.com/cross-rs/cross) and have Docker
#     (or Podman) running -- this script uses it automatically when
#     available. Without it, this script falls back to plain
#     `cargo build --target <triple>`, which only works for targets whose
#     linker is already installed on this machine.
#   - `dpkg-deb` (Debian/Ubuntu, or `apt install dpkg-dev` elsewhere) is
#     needed to produce .deb packages for the linux-* targets. If it's not
#     found, the .deb step is skipped for that target with a warning; the
#     .tar.gz is still produced.
#   - `zip` for Windows archives (falls back to .tar.gz if missing).
#   - macOS targets (macos-x64/macos-arm64) need `cargo-zigbuild` + `zig` to
#     actually link on Linux -- plain `cross`/`cargo` cannot, since there is
#     no legally redistributable Apple SDK to bundle in a Docker image.
#     Install once with:
#       cargo install cargo-zigbuild
#       pip install ziglang   # or install zig from https://ziglang.org/download
#     Without these, macos-* targets are skipped with a build error, same
#     as before.
#   - windows-arm64 (aarch64-pc-windows-msvc) needs `cargo-xwin` to link on
#     Linux, since the MSVC linker (link.exe) only exists on Windows.
#     Install once with:
#       cargo install cargo-xwin
#     cargo-xwin downloads the redistributable parts of the Windows SDK/CRT
#     itself (under Microsoft's own redistribution terms) -- no Visual
#     Studio installation required. Without it, windows-arm64 is skipped
#     with a build error, same as before.
#
# Every build's cargo/cross output streams to your terminal live (nothing
# hidden) AND is saved to /tmp/kite-build-<target>.log for later reference.

set -euo pipefail

# ---------------------------------------------------------------------------
# Target matrix: short_name:triple:kind:os
# ---------------------------------------------------------------------------
# kind is "tar" or "zip" (the generic archive format)
# os   is "linux", "macos" or "windows" (decides which installer format(s)
#        get built on top of the generic archive, and the dist/<os>/ folder)
#
# 32-bit targets: linux-x86 / linux-x86-musl / windows-x86 (i686). macOS has
# had no supported 32-bit target since 10.14, so there's no macos-x86 here.
ALL_TARGETS=(
  "linux-x64:x86_64-unknown-linux-gnu:tar:linux"
  "linux-x64-musl:x86_64-unknown-linux-musl:tar:linux"
  "linux-x86:i686-unknown-linux-gnu:tar:linux"
  "linux-x86-musl:i686-unknown-linux-musl:tar:linux"
  "linux-arm64:aarch64-unknown-linux-gnu:tar:linux"
  "linux-arm64-musl:aarch64-unknown-linux-musl:tar:linux"
  "macos-x64:x86_64-apple-darwin:tar:macos"
  "macos-arm64:aarch64-apple-darwin:tar:macos"
  "windows-x64:x86_64-pc-windows-gnu:zip:windows"
  "windows-x86:i686-pc-windows-gnu:zip:windows"
  "windows-arm64:aarch64-pc-windows-msvc:zip:windows"
)

# Maps a Rust arch prefix to a Debian architecture name for .deb packages.
deb_arch_for_triple() {
  case "$1" in
    x86_64-*)  echo "amd64" ;;
    aarch64-*) echo "arm64" ;;
    i686-*)    echo "i386" ;;
    *)         echo "" ;;
  esac
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
OUTPUT_DIR="dist"
SELECTED_NAMES=""
STRIP=1
JOBS=""
BUILD_DEB=1
QUIET=0

usage() {
  sed -n '2,48p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --targets)
      SELECTED_NAMES="$2"; shift 2 ;;
    --output-dir)
      OUTPUT_DIR="$2"; shift 2 ;;
    --no-strip)
      STRIP=0; shift ;;
    --no-deb)
      BUILD_DEB=0; shift ;;
    --quiet)
      QUIET=1; shift ;;
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
printf "%sbuilding %d target(s) -> %s/<os>/<arch>/%s\n\n" "$DIM" "$TOTAL" "$OUTPUT_DIR" "$RESET"

USE_CROSS=0
if command -v cross >/dev/null 2>&1 && (command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1); then
  USE_CROSS=1
  info "using 'cross' for cross-compilation (Docker/Podman backend detected)"
else
  info "'cross' not found -- falling back to 'cargo build --target' per target"
  info "(a target will be skipped here if its linker isn't installed; install"
  info " 'cross' + Docker for one-command builds of every target below)"
fi

HAVE_DPKG_DEB=0
command -v dpkg-deb >/dev/null 2>&1 && HAVE_DPKG_DEB=1
if [[ "$BUILD_DEB" -eq 1 && "$HAVE_DPKG_DEB" -eq 0 ]]; then
  info "'dpkg-deb' not found -- .deb packages will be skipped (tar.gz still built)"
fi

ZIG_SHIM_DIR=""
cleanup_zig_shim() { [[ -n "$ZIG_SHIM_DIR" ]] && rm -rf "$ZIG_SHIM_DIR"; }
trap cleanup_zig_shim EXIT

HAVE_ZIGBUILD=0
if command -v cargo-zigbuild >/dev/null 2>&1; then
  if command -v zig >/dev/null 2>&1; then
    HAVE_ZIGBUILD=1
    info "'cargo-zigbuild' + 'zig' found -- macOS targets will cross-link for real"
  elif command -v python-zig >/dev/null 2>&1; then
    # `pip install ziglang` / `uv tool install ziglang` exposes the binary as
    # 'python-zig', not 'zig' -- cargo-zigbuild only looks for the latter.
    ZIG_SHIM_DIR="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nexec python-zig "$@"\n' > "$ZIG_SHIM_DIR/zig"
    chmod +x "$ZIG_SHIM_DIR/zig"
    export PATH="$ZIG_SHIM_DIR:$PATH"
    HAVE_ZIGBUILD=1
    info "'cargo-zigbuild' + 'python-zig' found -- shimmed as 'zig' on PATH for this run"
  elif python3 -c "import ziglang" >/dev/null 2>&1; then
    ZIG_SHIM_DIR="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nexec python3 -m ziglang "$@"\n' > "$ZIG_SHIM_DIR/zig"
    chmod +x "$ZIG_SHIM_DIR/zig"
    export PATH="$ZIG_SHIM_DIR:$PATH"
    HAVE_ZIGBUILD=1
    info "'cargo-zigbuild' + python 'ziglang' module found -- shimmed as 'zig' for this run"
  fi
fi
if [[ "$HAVE_ZIGBUILD" -eq 0 ]]; then
  info "'cargo-zigbuild'/'zig' not found -- macOS targets will likely fail to link"
  info "(cargo install cargo-zigbuild; then 'uv tool install ziglang' or 'pip install ziglang')"
fi

HAVE_XWIN=0
command -v cargo-xwin >/dev/null 2>&1 && HAVE_XWIN=1
if [[ "$HAVE_XWIN" -eq 0 ]]; then
  info "'cargo-xwin' not found -- windows-arm64 (MSVC) will likely fail to link"
  info "(cargo install cargo-xwin -- no Visual Studio needed)"
fi
echo

HAVE_RUSTUP=0
command -v rustup >/dev/null 2>&1 && HAVE_RUSTUP=1

JOBS_ARG=()
[[ -n "$JOBS" ]] && JOBS_ARG=(-j "$JOBS")

# ---------------------------------------------------------------------------
# Build loop
# ---------------------------------------------------------------------------
declare -a RESULT_NAME RESULT_STATUS RESULT_TIME RESULT_FILES
i=0
START_ALL=$(date +%s)

for entry in "${TARGETS_TO_BUILD[@]}"; do
  i=$((i + 1))
  short="${entry%%:*}"
  rest="${entry#*:}"
  triple="${rest%%:*}"
  rest2="${rest#*:}"
  kind="${rest2%%:*}"
  os="${rest2##*:}"
  arch_label="${short#"$os"-}"

  step "$i" "$TOTAL" "$short  ($triple)"
  t0=$(date +%s)

  if [[ "$HAVE_RUSTUP" -eq 1 ]]; then
    rustup target add "$triple" >/dev/null 2>&1 || true
  fi

  log_file="/tmp/kite-build-$short.log"
  : > "$log_file"

  if [[ "$os" == "macos" && "$HAVE_ZIGBUILD" -eq 1 ]]; then
    BUILD_CMD=(cargo zigbuild --release --target "$triple" "${JOBS_ARG[@]}")
  elif [[ "$os" == "windows" && "$triple" == *-msvc && "$HAVE_XWIN" -eq 1 ]]; then
    BUILD_CMD=(cargo xwin build --release --target "$triple" "${JOBS_ARG[@]}")
  elif [[ "$USE_CROSS" -eq 1 ]]; then
    BUILD_CMD=(cross build --release --target "$triple" "${JOBS_ARG[@]}")
  else
    BUILD_CMD=(cargo build --release --target "$triple" "${JOBS_ARG[@]}")
  fi

  # Stream the build live so nothing is hidden while it's happening, and
  # keep a full copy in the log file regardless. --quiet only affects what
  # hits the terminal, never what gets logged.
  set +e
  if [[ "$QUIET" -eq 1 ]]; then
    "${BUILD_CMD[@]}" >"$log_file" 2>&1
    BUILD_OK=$?
  else
    "${BUILD_CMD[@]}" 2>&1 | tee "$log_file" | sed 's/^/       │ /'
    BUILD_OK=${PIPESTATUS[0]}
  fi
  set -e

  t1=$(date +%s)
  elapsed=$((t1 - t0))

  if [[ "$BUILD_OK" -ne 0 ]]; then
    fail "build failed for $short after ${elapsed}s (see $log_file)"
    tail -n 6 "$log_file" | sed 's/^/       | /'
    if [[ "$os" == "macos" && "$HAVE_ZIGBUILD" -eq 0 ]]; then
      warn "tip: install 'cargo-zigbuild' + 'zig' to actually link macOS binaries from here"
    elif [[ "$os" == "windows" && "$triple" == *-msvc && "$HAVE_XWIN" -eq 0 ]]; then
      warn "tip: install 'cargo-xwin' (cargo install cargo-xwin) to link MSVC targets from here"
    fi
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_FILES+=("-")
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
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_FILES+=("-")
    echo
    continue
  fi

  ok "compiled in ${elapsed}s"

  # dist/<os>/<arch_label>/ -- e.g. dist/linux/x64-musl/, dist/windows/x86/
  target_out_dir="$OUTPUT_DIR/$os/$arch_label"
  mkdir -p "$target_out_dir"

  # Stage a package directory: kite (or kite.exe), README, LICENSE.
  work_dir="$(mktemp -d)"
  stage_dir="$work_dir/kite-${VERSION}-${short}"
  mkdir -p "$stage_dir"
  cp "$bin_path" "$stage_dir/"
  [[ -f README.md ]] && cp README.md "$stage_dir/"
  [[ -f LICENSE ]] && cp LICENSE "$stage_dir/"

  staged_bin="$stage_dir/$(basename "$bin_path")"
  if [[ "$STRIP" -eq 1 && "$kind" == "tar" ]]; then
    strip "$staged_bin" 2>/dev/null || true
  fi

  files_built=()

  # --- generic archive (always built): .tar.gz for linux/macos, .zip for windows
  archive_base="kite-${VERSION}-${short}"
  case "$kind" in
    tar)
      archive_path="$target_out_dir/${archive_base}.tar.gz"
      tar -C "$work_dir" -czf "$archive_path" "$(basename "$stage_dir")"
      ;;
    zip)
      archive_path="$target_out_dir/${archive_base}.zip"
      if command -v zip >/dev/null 2>&1; then
        (cd "$work_dir" && zip -r -q "$OLDPWD/$archive_path" "$(basename "$stage_dir")")
      else
        warn "no 'zip' command found; writing a .tar.gz instead"
        archive_path="$target_out_dir/${archive_base}.tar.gz"
        tar -C "$work_dir" -czf "$archive_path" "$(basename "$stage_dir")"
      fi
      ;;
  esac
  size_h=$(du -h "$archive_path" | cut -f1)
  ok "packaged -> $archive_path ($size_h)"
  files_built+=("$archive_path")

  # --- .deb package, Linux targets only ---
  if [[ "$os" == "linux" && "$BUILD_DEB" -eq 1 && "$HAVE_DPKG_DEB" -eq 1 ]]; then
    deb_arch="$(deb_arch_for_triple "$triple")"
    if [[ -n "$deb_arch" ]]; then
      deb_root="$work_dir/deb-${short}"
      mkdir -p "$deb_root/DEBIAN" "$deb_root/usr/bin"
      cp "$bin_path" "$deb_root/usr/bin/$BIN_NAME"
      [[ "$STRIP" -eq 1 ]] && strip "$deb_root/usr/bin/$BIN_NAME" 2>/dev/null || true
      chmod 755 "$deb_root/usr/bin/$BIN_NAME"

      installed_size=$(du -sk "$deb_root/usr" | cut -f1)
      cat > "$deb_root/DEBIAN/control" <<EOF
Package: kite
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: ${deb_arch}
Installed-Size: ${installed_size}
Maintainer: Kite project <noreply@example.com>
Description: Kite compiler and CLI
 Cross-platform command-line compiler for the Kite language.
EOF

      deb_path="$target_out_dir/kite_${VERSION}_${deb_arch}.deb"
      if dpkg-deb --build --root-owner-group "$deb_root" "$deb_path" >/dev/null 2>&1; then
        size_h=$(du -h "$deb_path" | cut -f1)
        ok "packaged -> $deb_path ($size_h)"
        files_built+=("$deb_path")
      else
        warn "dpkg-deb failed for $short, skipping .deb"
      fi
    else
      warn "no known Debian architecture for $triple, skipping .deb"
    fi
  fi

  rm -rf "$work_dir"

  for f in "${files_built[@]}"; do
    rel="${f#"$OUTPUT_DIR"/}"
    if command -v sha256sum >/dev/null 2>&1; then
      (cd "$OUTPUT_DIR" && sha256sum "$rel" >> checksums.txt)
    elif command -v shasum >/dev/null 2>&1; then
      (cd "$OUTPUT_DIR" && shasum -a 256 "$rel" >> checksums.txt)
    fi
  done

  RESULT_NAME+=("$short"); RESULT_STATUS+=("ok"); RESULT_TIME+=("${elapsed}s")
  RESULT_FILES+=("$(IFS=,; echo "${files_built[*]}")")
  echo
done

END_ALL=$(date +%s)
TOTAL_TIME=$((END_ALL - START_ALL))

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
printf "%s%s Build summary %s%s\n" "$BOLD" "----" "----" "$RESET"
printf "%-20s %-10s %-8s %s\n" "TARGET" "STATUS" "TIME" "FILES"
n_ok=0
n_fail=0
for idx in "${!RESULT_NAME[@]}"; do
  name="${RESULT_NAME[$idx]}"
  status="${RESULT_STATUS[$idx]}"
  time_s="${RESULT_TIME[$idx]}"
  files="${RESULT_FILES[$idx]}"
  if [[ "$status" == "ok" ]]; then
    n_ok=$((n_ok + 1))
    printf "%-20s %s%-10s%s %-8s %s\n" "$name" "$GREEN" "ok" "$RESET" "$time_s" "$files"
  else
    n_fail=$((n_fail + 1))
    printf "%-20s %s%-10s%s %-8s %s\n" "$name" "$RED" "failed" "$RESET" "$time_s" "$files"
  fi
done

echo
printf "%s%d succeeded, %d failed%s -- total time %ds\n" "$BOLD" "$n_ok" "$n_fail" "$RESET" "$TOTAL_TIME"

if [[ -d "$OUTPUT_DIR" ]]; then
  echo
  printf "%slayout:%s\n" "$DIM" "$RESET"
  if command -v tree >/dev/null 2>&1; then
    tree -F "$OUTPUT_DIR"
  else
    find "$OUTPUT_DIR" -type f | sort | sed "s|^|  |"
  fi
fi

[[ -f "$OUTPUT_DIR/checksums.txt" ]] && printf "\nchecksums written to %s/checksums.txt\n" "$OUTPUT_DIR"
printf "\nready for a GitHub release: upload every file under %s/ (except checksums.txt,\n" "$OUTPUT_DIR"
printf "or include it too) as release assets -- your installer can then pick the\n"
printf "right one per OS/arch from the dist/<os>/<arch>/ path or filename.\n"

if [[ "$n_fail" -gt 0 ]]; then
  echo
  warn "some targets failed to build locally -- see the per-target tips above."
  warn "Generic Linux/Windows-GNU targets need 'cross' + Docker/Podman; macOS"
  warn "targets need 'cargo-zigbuild' + 'zig'; windows-arm64 (MSVC) needs"
  warn "'cargo-xwin'. Install whichever applies and re-run for a complete build."
  exit 1
fi

exit 0
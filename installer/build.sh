#!/usr/bin/env bash
#
# build.sh -- cross-compile the Kite GUI installer (`Kite-Installer`, a Rust
# + iced desktop app) for every supported OS/architecture, with fully
# visible build output, and package each result into ./dist/<os>/<arch>/
# ready to be uploaded as GitHub release assets alongside kite's own
# archives (see kite's build.sh).
#
# Usage:
#   ./build.sh
#   ./build.sh --targets linux-x64,macos-arm64
#   ./build.sh --list
#   ./build.sh --output-dir out
#   ./build.sh --no-strip
#   ./build.sh --no-deb
#   ./build.sh --quiet
#   ./build.sh --jobs 4
#   ./build.sh -h | --help
#
# Output layout (dist/ by default):
#   dist/linux/x64/kite-installer-0.1.0-linux-x64.tar.gz
#   dist/linux/x64/kite-installer_0.1.0_amd64.deb
#   dist/macos/arm64/kite-installer-0.1.0-macos-arm64.tar.gz
#   dist/windows/x64/kite-installer-0.1.0-windows-x64.zip
#   dist/checksums.txt
#
# Prerequisites: same as kite's own build.sh --
#   - Rust + Cargo + rustup
#   - `cross` + Docker/Podman for one-command Linux/Windows-GNU cross-builds
#   - `dpkg-deb` for .deb packages on Linux targets
#   - `zip` for Windows archives
#
# NOT usable here (see the target-matrix comments below for why):
#   - `cargo-zigbuild`/`zig` cannot link this GUI app for macOS (needs the
#     real Apple SDK/frameworks) -- macos-* targets are expected to fail.
#   - `cargo-xwin` cannot currently link windows-arm64 for this app (a
#     cargo-xwin/`ring` bug) -- that target isn't in the matrix at all.

set -euo pipefail

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
  # windows-arm64 (aarch64-pc-windows-msvc) is intentionally NOT in this
  # matrix: this installer depends on `ureq` -> `rustls` -> `ring`, and
  # `ring`'s C build script currently fails under cargo-xwin for aarch64
  # (clang-cl / `/imsvc` flag handling breaks -- a cargo-xwin/ring
  # interaction bug, not something fixable from this script). kite's own
  # build.sh has no such dependency and builds windows-arm64 fine. Build
  # this one target on an actual Windows-on-ARM machine with real MSVC if
  # you need it, or track cargo-xwin/ring for a fix.
)

# macOS targets ALSO have a hard limit here: cargo-zigbuild/zig can cross-
# compile plain Rust binaries (that's how kite's own build.sh handles them),
# but this installer links AppKit/Metal/Objective-C runtime (via iced's
# macOS backend), and zig does not -- and legally cannot -- bundle Apple's
# proprietary libobjc/frameworks. Expect macos-x64/macos-arm64 to fail here
# no matter what's installed. Build those two on a real Mac, or in CI on a
# macos-* GitHub Actions runner (see .github/workflows/build-installer-macos.yml).

deb_arch_for_triple() {
  case "$1" in
    x86_64-*)  echo "amd64" ;;
    aarch64-*) echo "arm64" ;;
    i686-*)    echo "i386" ;;
    *)         echo "" ;;
  esac
}

OUTPUT_DIR="dist"
SELECTED_NAMES=""
STRIP=1
JOBS=""
BUILD_DEB=1
QUIET=0

usage() { sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --targets) SELECTED_NAMES="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --no-strip) STRIP=0; shift ;;
    --no-deb) BUILD_DEB=0; shift ;;
    --quiet) QUIET=1; shift ;;
    --jobs) JOBS="$2"; shift 2 ;;
    --list) for t in "${ALL_TARGETS[@]}"; do echo "${t%%:*}"; done; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; CYAN=$'\033[36m'
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; CYAN=""
fi

step() { printf "%s[%d/%d]%s %s%s%s\n" "$BOLD" "$1" "$2" "$RESET" "$CYAN" "$3" "$RESET"; }
info() { printf "     %s%s%s\n" "$DIM" "$1" "$RESET"; }
ok()   { printf "     %s✔ %s%s\n" "$GREEN" "$1" "$RESET"; }
warn() { printf "     %s⚠ %s%s\n" "$YELLOW" "$1" "$RESET"; }
fail() { printf "     %s✘ %s%s\n" "$RED" "$1" "$RESET"; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

VERSION="$(grep -m1 '^version' Cargo.toml | sed -E 's/version *= *"(.*)"/\1/')"
# Cargo keeps hyphens in the compiled binary's file name for a package name
# like "Kite-Installer" -- only lib crate names get underscored.
CARGO_BIN_NAME="Kite-Installer"
# ...but the name we actually ship/install as should be lowercase & Unix-y.
BIN_NAME="kite-installer"

if [[ -n "$SELECTED_NAMES" ]]; then
  IFS=',' read -r -a WANTED <<< "$SELECTED_NAMES"
else
  WANTED=(); for t in "${ALL_TARGETS[@]}"; do WANTED+=("${t%%:*}"); done
fi

TARGETS_TO_BUILD=()
for name in "${WANTED[@]}"; do
  found=""
  for t in "${ALL_TARGETS[@]}"; do [[ "${t%%:*}" == "$name" ]] && { found="$t"; break; }; done
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
printf "%sKite-Installer v%s -- multi-target release build%s\n" "$BOLD" "$VERSION" "$RESET"
printf "%sbuilding %d target(s) -> %s/<os>/<arch>/%s\n\n" "$DIM" "$TOTAL" "$OUTPUT_DIR" "$RESET"

USE_CROSS=0
if command -v cross >/dev/null 2>&1 && (command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1); then
  USE_CROSS=1
  info "using 'cross' for cross-compilation (Docker/Podman backend detected)"
else
  info "'cross' not found -- falling back to 'cargo build --target' per target"
fi

HAVE_DPKG_DEB=0
command -v dpkg-deb >/dev/null 2>&1 && HAVE_DPKG_DEB=1
[[ "$BUILD_DEB" -eq 1 && "$HAVE_DPKG_DEB" -eq 0 ]] && info "'dpkg-deb' not found -- .deb packages will be skipped"

ZIG_SHIM_DIR=""
cleanup_zig_shim() { [[ -n "$ZIG_SHIM_DIR" ]] && rm -rf "$ZIG_SHIM_DIR"; }
trap cleanup_zig_shim EXIT

HAVE_ZIGBUILD=0
if command -v cargo-zigbuild >/dev/null 2>&1; then
  if command -v zig >/dev/null 2>&1; then
    HAVE_ZIGBUILD=1
    info "'cargo-zigbuild' + 'zig' found -- macOS targets will cross-link for real"
  elif command -v python-zig >/dev/null 2>&1; then
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
[[ "$HAVE_ZIGBUILD" -eq 0 ]] && info "'cargo-zigbuild'/'zig' not found -- macOS targets will likely fail to link"
echo

HAVE_RUSTUP=0
command -v rustup >/dev/null 2>&1 && HAVE_RUSTUP=1
JOBS_ARG=(); [[ -n "$JOBS" ]] && JOBS_ARG=(-j "$JOBS")

declare -a RESULT_NAME RESULT_STATUS RESULT_TIME RESULT_FILES
i=0
START_ALL=$(date +%s)

for entry in "${TARGETS_TO_BUILD[@]}"; do
  i=$((i + 1))
  short="${entry%%:*}"; rest="${entry#*:}"
  triple="${rest%%:*}"; rest2="${rest#*:}"
  kind="${rest2%%:*}"; os="${rest2##*:}"
  arch_label="${short#"$os"-}"

  step "$i" "$TOTAL" "$short  ($triple)"
  t0=$(date +%s)

  [[ "$HAVE_RUSTUP" -eq 1 ]] && rustup target add "$triple" >/dev/null 2>&1 || true

  log_file="/tmp/kite-installer-build-$short.log"
  : > "$log_file"

  if [[ "$os" == "macos" && "$HAVE_ZIGBUILD" -eq 1 ]]; then
    BUILD_CMD=(cargo zigbuild --release --target "$triple" "${JOBS_ARG[@]}")
  elif [[ "$USE_CROSS" -eq 1 ]]; then
    BUILD_CMD=(cross build --release --target "$triple" "${JOBS_ARG[@]}")
  else
    BUILD_CMD=(cargo build --release --target "$triple" "${JOBS_ARG[@]}")
  fi

  set +e
  if [[ "$QUIET" -eq 1 ]]; then
    "${BUILD_CMD[@]}" >"$log_file" 2>&1
    BUILD_OK=$?
  else
    "${BUILD_CMD[@]}" 2>&1 | tee "$log_file" | sed 's/^/       │ /'
    BUILD_OK=${PIPESTATUS[0]}
  fi
  set -e

  t1=$(date +%s); elapsed=$((t1 - t0))

  if [[ "$BUILD_OK" -ne 0 ]]; then
    fail "build failed for $short after ${elapsed}s (see $log_file)"
    tail -n 6 "$log_file" | sed 's/^/       | /'
    if [[ "$os" == "macos" ]]; then
      warn "expected: zig can't link AppKit/Metal for a GUI app -- build macos-* on a real Mac or macOS CI runner"
    fi
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_FILES+=("-")
    echo
    continue
  fi

  bin_path="target/$triple/release/$CARGO_BIN_NAME"
  [[ "$kind" == "zip" ]] && bin_path="${bin_path}.exe"
  if [[ ! -f "$bin_path" ]]; then
    fail "expected binary not found at $bin_path"
    RESULT_NAME+=("$short"); RESULT_STATUS+=("failed"); RESULT_TIME+=("${elapsed}s"); RESULT_FILES+=("-")
    echo
    continue
  fi

  ok "compiled in ${elapsed}s"

  target_out_dir="$OUTPUT_DIR/$os/$arch_label"
  mkdir -p "$target_out_dir"

  work_dir="$(mktemp -d)"
  stage_dir="$work_dir/kite-installer-${VERSION}-${short}"
  mkdir -p "$stage_dir"
  staged_bin_name="$BIN_NAME"
  [[ "$kind" == "zip" ]] && staged_bin_name="${BIN_NAME}.exe"
  cp "$bin_path" "$stage_dir/$staged_bin_name"
  [[ -f README.md ]] && cp README.md "$stage_dir/"
  [[ -f LICENSE ]] && cp LICENSE "$stage_dir/"

  staged_bin="$stage_dir/$staged_bin_name"
  if [[ "$STRIP" -eq 1 && "$kind" == "tar" ]]; then
    strip "$staged_bin" 2>/dev/null || true
  fi

  files_built=()

  archive_base="kite-installer-${VERSION}-${short}"
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

  # --- .deb package, Linux targets only: binary + .desktop entry + icon ---
  if [[ "$os" == "linux" && "$BUILD_DEB" -eq 1 && "$HAVE_DPKG_DEB" -eq 1 ]]; then
    deb_arch="$(deb_arch_for_triple "$triple")"
    if [[ -n "$deb_arch" ]]; then
      deb_root="$work_dir/deb-${short}"
      mkdir -p "$deb_root/DEBIAN" "$deb_root/usr/bin" \
               "$deb_root/usr/share/applications" \
               "$deb_root/usr/share/icons/hicolor/256x256/apps"
      cp "$bin_path" "$deb_root/usr/bin/$BIN_NAME"
      [[ "$STRIP" -eq 1 ]] && strip "$deb_root/usr/bin/$BIN_NAME" 2>/dev/null || true
      chmod 755 "$deb_root/usr/bin/$BIN_NAME"

      if [[ -f assets/logo/256/kite-256.png ]]; then
        cp assets/logo/256/kite-256.png \
           "$deb_root/usr/share/icons/hicolor/256x256/apps/$BIN_NAME.png"
      fi

      cat > "$deb_root/usr/share/applications/$BIN_NAME.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Kite Installer
Comment=Install or update Kite
Exec=$BIN_NAME
Icon=$BIN_NAME
Terminal=false
Categories=Development;Utility;
EOF

      installed_size=$(du -sk "$deb_root/usr" | cut -f1)
      cat > "$deb_root/DEBIAN/control" <<EOF
Package: kite-installer
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: ${deb_arch}
Installed-Size: ${installed_size}
Maintainer: Kite project <noreply@example.com>
Description: Kite installer
 Graphical installer that downloads and sets up the Kite compiler/CLI.
EOF

      deb_path="$target_out_dir/kite-installer_${VERSION}_${deb_arch}.deb"
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

printf "%s%s Build summary %s%s\n" "$BOLD" "----" "----" "$RESET"
printf "%-20s %-10s %-8s %s\n" "TARGET" "STATUS" "TIME" "FILES"
n_ok=0; n_fail=0
for idx in "${!RESULT_NAME[@]}"; do
  name="${RESULT_NAME[$idx]}"; status="${RESULT_STATUS[$idx]}"
  time_s="${RESULT_TIME[$idx]}"; files="${RESULT_FILES[$idx]}"
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
printf "\nupload every file under %s/ as GitHub release assets, same as kite's own build.\n" "$OUTPUT_DIR"

if [[ "$n_fail" -gt 0 ]]; then
  echo
  warn "some targets failed -- macOS is expected to fail here (see top-of-file notes);"
  warn "build macos-x64/macos-arm64 via .github/workflows/build-installer-macos.yml instead."
  exit 1
fi

exit 0

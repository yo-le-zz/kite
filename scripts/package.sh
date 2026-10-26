#!/bin/bash
# Build installable packages of the `kite` compiler.
#
#   scripts/package.sh deb              .deb for this machine's architecture
#   scripts/package.sh deb amd64|arm64  .deb for a given architecture (cross)
#   scripts/package.sh windows          Windows zips (x64 + arm64) via cross-build
#   scripts/package.sh all              everything that can be built here
#
# Output: dist/  (kite_<version>_<arch>.deb, kite-<version>-windows-<arch>.zip)
# The packages ship the `kite` compiler (stage0). It needs `clang` at run
# time to turn LLVM IR into a native binary.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/archive/rust-stage0"
DIST="$ROOT/dist"
VERSION=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$SRC/Cargo.toml" | head -1)
mkdir -p "$DIST"

build_deb() {
  local arch=$1 triple bin
  case "$arch" in
    amd64) triple=x86_64-unknown-linux-gnu ;;
    arm64) triple=aarch64-unknown-linux-gnu ;;
    *) echo "unsupported deb architecture: $arch" >&2; return 1 ;;
  esac
  local host; host=$(dpkg --print-architecture 2>/dev/null || echo amd64)
  echo "==> deb $arch ($triple)"
  if [ "$arch" = "$host" ]; then
    (cd "$SRC" && CARGO_TARGET_DIR="$SRC/target" cargo build --release)
    bin="$SRC/target/release/kite"
  else
    if ! (cd "$SRC" && rustup target add "$triple" >/dev/null 2>&1 && \
          CARGO_TARGET_DIR="$SRC/target" cargo build --release --target "$triple"); then
      echo "   skipped: cannot cross-build $arch here (install gcc-aarch64-linux-gnu and set" >&2
      echo "   CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc, or use CI)" >&2
      return 0
    fi
    bin="$SRC/target/$triple/release/kite"
  fi
  local pkg="$DIST/pkg_$arch"
  rm -rf "$pkg"
  mkdir -p "$pkg/DEBIAN" "$pkg/usr/bin" "$pkg/usr/share/kite" "$pkg/usr/share/doc/kite"
  install -m 0755 "$bin" "$pkg/usr/bin/kite"
  strip --strip-unneeded "$pkg/usr/bin/kite" 2>/dev/null || true
  cp -r "$ROOT/stdlib" "$pkg/usr/share/kite/stdlib"
  cp -r "$ROOT/examples" "$pkg/usr/share/kite/examples"
  cp -r "$ROOT/docs"/* "$pkg/usr/share/doc/kite/" 2>/dev/null || true
  cp "$ROOT/LICENSE" "$pkg/usr/share/doc/kite/copyright" 2>/dev/null || true
  local size; size=$(du -sk "$pkg" | cut -f1)
  cat > "$pkg/DEBIAN/control" <<CTRL
Package: kite
Version: $VERSION
Section: devel
Priority: optional
Architecture: $arch
Depends: clang
Installed-Size: $size
Maintainer: yo-le-zz <noreply@example.com>
Homepage: https://github.com/yo-le-zz/kite
Description: The Kite programming language
 Readable like Python, fast like C, with a pinch of Rust-style safety.
 Compiles through LLVM; requires clang to produce native executables.
CTRL
  dpkg-deb --build --root-owner-group "$pkg" "$DIST/kite_${VERSION}_${arch}.deb" >/dev/null
  rm -rf "$pkg"
  echo "   -> dist/kite_${VERSION}_${arch}.deb"
}

build_windows() {
  echo "==> windows zips (x64 + arm64)"
  (cd "$SRC" && bash ./cross-build.sh --targets windows-x64,windows-arm64 --output-dir "$DIST") || \
    echo "   some Windows targets could not be built here; use the CI workflow (.github/workflows/release.yml)" >&2
  # add an installer script to each zip
  for z in "$DIST"/*windows*.zip; do
    [ -f "$z" ] || continue
    tmp=$(mktemp -d)
    cat > "$tmp/install.ps1" <<'PS'
# Installs kite.exe for the current user and adds it to PATH.
$dest = Join-Path $env:LOCALAPPDATA "Kite\bin"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Force "$PSScriptRoot\kite.exe" $dest
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if ($path -notlike "*$dest*") { [Environment]::SetEnvironmentVariable("Path", "$path;$dest", "User") }
Write-Host "Kite installed to $dest. Install clang too:  winget install LLVM.LLVM"
PS
    (cd "$tmp" && zip -q -u "$z" install.ps1) || true
    rm -rf "$tmp"
  done
}

case "${1:-deb}" in
  deb)     build_deb "${2:-$(dpkg --print-architecture 2>/dev/null || echo amd64)}" ;;
  windows) build_windows ;;
  all)     build_deb amd64; build_deb arm64; build_windows ;;
  *) echo "usage: $0 deb [amd64|arm64] | windows | all" >&2; exit 2 ;;
esac

#!/bin/bash
# Build the release files: Linux + Windows (+ macOS when buildable) archives,
# .deb packages and checksums, with the names the installers expect:
#
#   dist/release/kite-<ver>-linux-x64.tar.gz      kite_<ver>_amd64.deb
#   dist/release/kite-<ver>-linux-arm64.tar.gz    kite_<ver>_arm64.deb
#   dist/release/kite-<ver>-windows-x64.zip       dist/release/kite-<ver>-windows-arm64.zip
#   dist/release/checksums.txt
#
# Usage:
#   scripts/package-release.sh                  all targets that can be built here
#   scripts/package-release.sh --targets linux-x64,windows-x64
#   scripts/package-release.sh --compiler rust|kite|auto
#   scripts/package-release.sh --no-deb
#   scripts/package-release.sh --no-installer     skip the GUI installer (installer/)
#
# --compiler selects which `kite` goes into the packages:
#   rust   the stable Rust compiler (archive/rust-stage0)   <- default today
#   kite   the self-hosted compiler (`kitec`), once it is complete
#   auto   `kite` if compiler/BOOTSTRAPPED exists, otherwise `rust`
#
# Cross-compilation needs the usual toolchains (or `cross` + Docker); targets
# that cannot be linked here are reported and skipped. Use the GitHub workflow
# (.github/workflows/release.yml) to build every target on native runners.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/archive/rust-stage0"
OUT="$ROOT/dist/release"
COMPILER=auto
TARGETS=linux-x64,linux-arm64,windows-x64,windows-arm64
DEB=1
INSTALLER=1
while [ $# -gt 0 ]; do
  case "$1" in
    --compiler) COMPILER=$2; shift 2 ;;
    --targets)  TARGETS=$2;  shift 2 ;;
    --no-deb)   DEB=0; shift ;;
    --no-installer) INSTALLER=0; shift ;;
    -h|--help)  sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
if [ "$COMPILER" = auto ]; then
  if [ -f "$ROOT/compiler/BOOTSTRAPPED" ]; then COMPILER=kite; else COMPILER=rust; fi
fi
VERSION=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$SRC/Cargo.toml" | head -1)
echo "==> release $VERSION, compiler: $COMPILER, targets: $TARGETS"
if [ "$COMPILER" = kite ]; then
  echo "error: the self-hosted compiler is not packaged yet (compiler/BOOTSTRAPPED missing)." >&2
  echo "       use --compiler rust until the bootstrap is complete." >&2
  exit 1
fi
rm -rf "$OUT"; mkdir -p "$OUT"

# 1. archives (tar.gz / zip) through the cross-build matrix
"$ROOT/scripts/cross-build.sh" --targets "$TARGETS" --output-dir "$OUT" || \
  echo "   (some targets were skipped, see above)"

if [ -z "$(find "$OUT" -maxdepth 1 \( -name 'kite-*.tar.gz' -o -name 'kite-*.zip' \) 2>/dev/null)" ]; then
  echo "error: no target could be built (see the logs above)." >&2
  echo "       a target is built with 'cross' (Docker/Podman) or a native cross-linker; or use the" >&2
  echo "       GitHub workflow .github/workflows/release.yml. Try:  scripts/package-release.sh --targets linux-x64" >&2
  rm -f "$OUT/checksums.txt"
  exit 1
fi

# 2. .deb packages (Linux targets that were built)
make_deb() {
  local short=$1 arch=$2
  local tarball; tarball="$OUT/kite-${VERSION}-${short}.tar.gz"; [ -f "$tarball" ] || tarball=""
  [ -n "$tarball" ] || { echo "   no $short archive, skipping its .deb"; return 0; }
  command -v dpkg-deb >/dev/null || { echo "   dpkg-deb missing, skipping .deb"; return 0; }
  local tmp; tmp=$(mktemp -d); local pkg="$tmp/pkg"
  mkdir -p "$pkg/DEBIAN" "$pkg/usr/bin" "$pkg/usr/share/kite" "$pkg/usr/share/doc/kite" "$tmp/x"
  tar -xzf "$tarball" -C "$tmp/x"
  install -m 0755 "$(find "$tmp/x" -type f -name kite | head -1)" "$pkg/usr/bin/kite"
  cp -r "$ROOT/stdlib" "$pkg/usr/share/kite/stdlib"
  cp -r "$ROOT/examples" "$pkg/usr/share/kite/examples"
  cp -r "$ROOT/docs/." "$pkg/usr/share/doc/kite/"
  cp "$ROOT/LICENSE" "$pkg/usr/share/doc/kite/copyright"
  cat > "$pkg/DEBIAN/control" <<CTRL
Package: kite
Version: $VERSION
Section: devel
Priority: optional
Architecture: $arch
Depends: clang
Installed-Size: $(du -sk "$pkg" | cut -f1)
Maintainer: yo-le-zz <noreply@example.com>
Homepage: https://github.com/yo-le-zz/Kite
Description: The Kite programming language
 Readable like Python, fast like C, with a pinch of Rust-style safety.
 Compiles through LLVM; needs clang to produce native executables.
CTRL
  dpkg-deb --build --root-owner-group "$pkg" "$OUT/kite_${VERSION}_${arch}.deb" >/dev/null
  rm -rf "$tmp"
  echo "   -> kite_${VERSION}_${arch}.deb"
}
if [ "$DEB" = 1 ]; then
  case ",$TARGETS," in *,linux-x64,*)   make_deb linux-x64 amd64 ;; esac
  case ",$TARGETS," in *,linux-arm64,*) make_deb linux-arm64 arm64 ;; esac
fi

# 3. the GUI installer (Rust + iced): same Linux/Windows targets. windows-arm64 and macOS
#    are not buildable by cross (see installer/build.sh); they are built by the CI workflows.
if [ "$INSTALLER" = 1 ]; then
  ITARGETS=""
  for t in ${TARGETS//,/ }; do
    case "$t" in windows-arm64|macos-*) echo "   installer: $t is built by CI (not cross-buildable), skipping" ;; *) ITARGETS="$ITARGETS,$t" ;; esac
  done
  ITARGETS="${ITARGETS#,}"
  if [ -n "$ITARGETS" ]; then
    echo "==> installer (GUI): $ITARGETS"
    ITMP="$OUT/.installer"
    if "$ROOT/installer/build.sh" --targets "$ITARGETS" --output-dir "$ITMP"; then :; else
      echo "   (some installer targets were skipped, see above)"
    fi
    # flatten dist/<os>/<arch>/kite-installer-* into the release directory
    find "$ITMP" -type f \( -name 'kite-installer*' \) -exec cp {} "$OUT/" \; 2>/dev/null || true
    rm -rf "$ITMP"
  fi
fi

# 4. checksums
( cd "$OUT" && ls | grep -v checksums.txt | xargs -r sha256sum > checksums.txt ) || true
echo "==> done:"; ls -la "$OUT"

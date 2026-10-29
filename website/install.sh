#!/usr/bin/env sh
# install.sh -- installs the latest (or a pinned) `kite` release on Linux.
#
#   curl -fsSL https://kite-lang.pages.dev/install.sh | sh
#   curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --version 0.3.0
#   curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --deb        (Debian/Ubuntu: .deb via dpkg)
#   curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --rpm        (Fedora/RHEL/openSUSE: .rpm via dnf)
#   curl -fsSL https://kite-lang.pages.dev/install.sh | sh -s -- --uninstall
#
# Options:  --version X   --prefix DIR   --deb   --rpm   --no-modify-path   --uninstall   --help
# Env:      KITE_REPO (yo-le-zz/Kite)  KITE_VERSION  KITE_INSTALL_DIR ($HOME/.local/bin)
set -eu

REPO="${KITE_REPO:-yo-le-zz/Kite}"
INSTALL_DIR="${KITE_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${KITE_VERSION:-}"
USE_DEB=0; USE_RPM=0; MODIFY_PATH=1; UNINSTALL=0

if [ -t 1 ]; then B='\033[1m'; G='\033[32m'; R='\033[31m'; Y='\033[33m'; D='\033[2m'; Z='\033[0m'; else B=''; G=''; R=''; Y=''; D=''; Z=''; fi
info() { printf '%b%s%b\n' "$D" "$1" "$Z"; }
ok()   { printf '%b✔ %s%b\n' "$G" "$1" "$Z"; }
warn() { printf '%b! %s%b\n' "$Y" "$1" "$Z" >&2; }
die()  { printf '%b✘ %s%b\n' "$R" "$1" "$Z" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="${2:?--version needs a value}"; shift 2 ;;
    --prefix)  INSTALL_DIR="${2:?--prefix needs a value}/bin"; shift 2 ;;
    --deb) USE_DEB=1; shift ;;
    --rpm) USE_RPM=1; shift ;;
    --no-modify-path) MODIFY_PATH=0; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) sed -n '2,11p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

if [ "$UNINSTALL" = 1 ]; then
  rm -f "$INSTALL_DIR/kite"; ok "removed $INSTALL_DIR/kite"
  command -v dpkg >/dev/null 2>&1 && dpkg -s kite >/dev/null 2>&1 && info "a .deb install exists: sudo apt remove kite"
  exit 0
fi

# download helper: curl or wget
if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL -o "$2" "$1"; }; fetch_out() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -q -O "$2" "$1"; }; fetch_out() { wget -q -O - "$1"; }
else die "curl or wget is required"; fi
command -v tar >/dev/null 2>&1 || die "tar is required"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ARCH_LABEL=x64; DEB_ARCH=amd64 ;;
  aarch64|arm64) ARCH_LABEL=arm64; DEB_ARCH=arm64 ;;
  *) die "unsupported architecture: $ARCH" ;;
esac
LIBC=""
if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl; then LIBC="-musl"; fi
SHORT="linux-${ARCH_LABEL}${LIBC}"

if [ -z "$VERSION" ]; then
  info "resolving the latest release of $REPO..."
  TAG="$(fetch_out "https://api.github.com/repos/$REPO/releases/latest" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
  [ -n "$TAG" ] || die "could not resolve the latest release (rate limit? pass --version X)"
  VERSION="${TAG#v}"
fi
BASE="https://github.com/$REPO/releases/download/v${VERSION}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

check_clang() {
  if command -v clang >/dev/null 2>&1; then return 0; fi
  warn "clang was not found: kite needs it to build native programs."
  if   command -v apt-get >/dev/null 2>&1; then warn "  install it with:  sudo apt-get install -y clang"
  elif command -v dnf     >/dev/null 2>&1; then warn "  install it with:  sudo dnf install -y clang"
  elif command -v pacman  >/dev/null 2>&1; then warn "  install it with:  sudo pacman -S clang"
  elif command -v apk     >/dev/null 2>&1; then warn "  install it with:  sudo apk add clang"
  else warn "  install LLVM/clang from https://releases.llvm.org"; fi
}

verify() { # verify FILE NAME  (sha256 against the release's checksums.txt, when available)
  if ! fetch "$BASE/checksums.txt" "$TMP/checksums.txt" 2>/dev/null; then warn "no checksums.txt in this release: skipping verification"; return 0; fi
  want="$(grep " $2\$" "$TMP/checksums.txt" | awk '{print $1}' | head -1)"
  [ -n "$want" ] || { warn "no checksum listed for $2: skipping verification"; return 0; }
  if command -v sha256sum >/dev/null 2>&1; then have="$(sha256sum "$1" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then have="$(shasum -a 256 "$1" | awk '{print $1}')"
  else warn "no sha256 tool: skipping verification"; return 0; fi
  [ "$want" = "$have" ] || die "checksum mismatch for $2 (expected $want, got $have)"
  ok "checksum verified"
}

if [ "$USE_DEB" = 1 ]; then
  command -v dpkg >/dev/null 2>&1 || die "--deb needs a Debian/Ubuntu system (dpkg not found)"
  DEB="kite_${VERSION}_${DEB_ARCH}.deb"
  info "downloading $DEB"; fetch "$BASE/$DEB" "$TMP/$DEB" || die "download failed: $BASE/$DEB"
  verify "$TMP/$DEB" "$DEB"
  if [ "$(id -u)" = 0 ]; then dpkg -i "$TMP/$DEB"; else sudo dpkg -i "$TMP/$DEB" || sudo apt-get install -f -y; fi
  ok "kite ${VERSION} installed system-wide (/usr/bin/kite)"; exit 0
fi

if [ "$USE_RPM" = 1 ]; then
  case "$ARCH_LABEL" in x64) RPM_ARCH=x86_64 ;; arm64) RPM_ARCH=aarch64 ;; esac
  RPM="kite-${VERSION}-1.${RPM_ARCH}.rpm"
  info "downloading $RPM"; fetch "$BASE/$RPM" "$TMP/$RPM" || die "download failed: $BASE/$RPM"
  verify "$TMP/$RPM" "$RPM"
  if   command -v dnf    >/dev/null 2>&1; then SUDO=""; [ "$(id -u)" = 0 ] || SUDO=sudo; $SUDO dnf install -y "$TMP/$RPM"
  elif command -v zypper >/dev/null 2>&1; then SUDO=""; [ "$(id -u)" = 0 ] || SUDO=sudo; $SUDO zypper --non-interactive install --allow-unsigned-rpm "$TMP/$RPM"
  elif command -v rpm    >/dev/null 2>&1; then SUDO=""; [ "$(id -u)" = 0 ] || SUDO=sudo; $SUDO rpm -i "$TMP/$RPM"
  else die "--rpm needs dnf, zypper or rpm"; fi
  ok "kite ${VERSION} installed system-wide (/usr/bin/kite)"; exit 0
fi

FILE="kite-${VERSION}-${SHORT}.tar.gz"
info "installing kite ${VERSION} (${SHORT}) into ${INSTALL_DIR}"
fetch "$BASE/$FILE" "$TMP/$FILE" || die "download failed: $BASE/$FILE (does this release cover $SHORT?)"
verify "$TMP/$FILE" "$FILE"
tar -xzf "$TMP/$FILE" -C "$TMP"
BIN="$(find "$TMP" -type f -name kite | head -n1)"
[ -n "$BIN" ] || die "no 'kite' binary inside $FILE"
mkdir -p "$INSTALL_DIR"; cp "$BIN" "$INSTALL_DIR/kite"; chmod +x "$INSTALL_DIR/kite"
"$INSTALL_DIR/kite" --version >/dev/null 2>&1 || warn "the installed binary did not run (wrong libc? try the -musl build)"
ok "kite ${VERSION} installed to ${INSTALL_DIR}/kite"
check_clang

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    if [ "$MODIFY_PATH" = 1 ]; then
      LINE="export PATH=\"$INSTALL_DIR:\$PATH\""
      for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        [ -f "$rc" ] || continue
        grep -qs "$INSTALL_DIR" "$rc" || { printf '\n# added by the kite installer\n%s\n' "$LINE" >> "$rc"; info "added $INSTALL_DIR to PATH in $rc"; }
      done
      printf '%bOpen a new shell, or run:%b  %s\n' "$B" "$Z" "$LINE"
    else
      printf '%b%s is not on your PATH.%b Add:  export PATH="%s:$PATH"\n' "$B" "$INSTALL_DIR" "$Z" "$INSTALL_DIR"
    fi ;;
esac
info "check: kite --version"

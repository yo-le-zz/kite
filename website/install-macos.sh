#!/usr/bin/env sh
# install.sh -- installs the latest (or a pinned) `kite` release on macOS.
#
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh -s -- --version 0.3.0
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh -s -- --uninstall
#
# Options:  --version X   --prefix DIR   --no-modify-path   --uninstall   --help
# Env:      KITE_REPO (yo-le-zz/Kite)  KITE_VERSION  KITE_INSTALL_DIR ($HOME/.local/bin)
set -eu

REPO="${KITE_REPO:-yo-le-zz/Kite}"
INSTALL_DIR="${KITE_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${KITE_VERSION:-}"
MODIFY_PATH=1; UNINSTALL=0

if [ -t 1 ]; then B='\033[1m'; G='\033[32m'; R='\033[31m'; Y='\033[33m'; D='\033[2m'; Z='\033[0m'; else B=''; G=''; R=''; Y=''; D=''; Z=''; fi
info() { printf '%b%s%b\n' "$D" "$1" "$Z"; }
ok()   { printf '%b✔ %s%b\n' "$G" "$1" "$Z"; }
warn() { printf '%b! %s%b\n' "$Y" "$1" "$Z" >&2; }
die()  { printf '%b✘ %s%b\n' "$R" "$1" "$Z" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="${2:?--version needs a value}"; shift 2 ;;
    --prefix)  INSTALL_DIR="${2:?--prefix needs a value}/bin"; shift 2 ;;
    --no-modify-path) MODIFY_PATH=0; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) sed -n '2,11p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

if [ "$UNINSTALL" = 1 ]; then
  rm -f "$INSTALL_DIR/kite"; ok "removed $INSTALL_DIR/kite"
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
  x86_64|amd64) ARCH_LABEL=x64 ;;
  arm64|aarch64) ARCH_LABEL=arm64 ;;
  *) die "unsupported architecture: $ARCH" ;;
esac
SHORT="macos-${ARCH_LABEL}"

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
  warn "  install the Xcode command line tools:  xcode-select --install   (or: brew install llvm)"
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

FILE="kite-${VERSION}-${SHORT}.tar.gz"
info "installing kite ${VERSION} (${SHORT}) into ${INSTALL_DIR}"
fetch "$BASE/$FILE" "$TMP/$FILE" || die "download failed: $BASE/$FILE (does this release cover $SHORT?)"
verify "$TMP/$FILE" "$FILE"
tar -xzf "$TMP/$FILE" -C "$TMP"
BIN="$(find "$TMP" -type f -name kite | head -n1)"
[ -n "$BIN" ] || die "no 'kite' binary inside $FILE"
mkdir -p "$INSTALL_DIR"; cp "$BIN" "$INSTALL_DIR/kite"; chmod +x "$INSTALL_DIR/kite"
command -v xattr >/dev/null 2>&1 && xattr -d com.apple.quarantine "$INSTALL_DIR/kite" 2>/dev/null || true
"$INSTALL_DIR/kite" --version >/dev/null 2>&1 || warn "the installed binary did not run (Gatekeeper? run: xattr -d com.apple.quarantine $INSTALL_DIR/kite)"
ok "kite ${VERSION} installed to ${INSTALL_DIR}/kite"
check_clang

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    if [ "$MODIFY_PATH" = 1 ]; then
      LINE="export PATH=\"$INSTALL_DIR:\$PATH\""
      for rc in "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.bash_profile"; do
        [ -f "$rc" ] || continue
        grep -qs "$INSTALL_DIR" "$rc" || { printf '\n# added by the kite installer\n%s\n' "$LINE" >> "$rc"; info "added $INSTALL_DIR to PATH in $rc"; }
      done
      printf '%bOpen a new shell, or run:%b  %s\n' "$B" "$Z" "$LINE"
    else
      printf '%b%s is not on your PATH.%b Add:  export PATH="%s:$PATH"\n' "$B" "$INSTALL_DIR" "$Z" "$INSTALL_DIR"
    fi ;;
esac
info "check: kite --version"

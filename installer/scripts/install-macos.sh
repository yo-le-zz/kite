#!/usr/bin/env sh
# install-macos.sh -- installs the latest (or a pinned) `kite` release on macOS.
#
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | KITE_VERSION=0.2.0 sh
#   curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh -s -- --uninstall
#
# Env overrides:
#   KITE_REPO        GitHub "owner/repo"      (default: yo-le-zz/Kite)
#   KITE_VERSION      release tag to install    (default: latest)
#   KITE_INSTALL_DIR   where to put the binary    (default: $HOME/.local/bin)
set -eu

REPO="${KITE_REPO:-yo-le-zz/Kite}"
INSTALL_DIR="${KITE_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${KITE_VERSION:-}"

if [ -t 1 ]; then
  BOLD='\033[1m'; GREEN='\033[32m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'
else
  BOLD=''; GREEN=''; RED=''; DIM=''; RESET=''
fi
info() { printf '%s%s%s\n' "$DIM" "$1" "$RESET"; }
ok()   { printf '%s✔ %s%s\n' "$GREEN" "$1" "$RESET"; }
die()  { printf '%s✘ %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$INSTALL_DIR/kite"
  ok "removed $INSTALL_DIR/kite"
  exit 0
fi

command -v curl >/dev/null 2>&1 || die "curl is required but was not found"
command -v tar  >/dev/null 2>&1 || die "tar is required but was not found"
[ "$(uname -s)" = "Darwin" ] || die "this script is for macOS -- use install.sh on Linux or install.ps1 on Windows"

ARCH="$(uname -m)"
case "$ARCH" in
  arm64)  ARCH_LABEL="arm64" ;;
  x86_64) ARCH_LABEL="x64" ;;
  *) die "unsupported architecture: $ARCH" ;;
esac
SHORT="macos-${ARCH_LABEL}"

if [ -z "$VERSION" ]; then
  info "resolving latest release of $REPO..."
  API_URL="https://api.github.com/repos/$REPO/releases/latest"
  TAG="$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API_URL" \
    | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
  [ -n "$TAG" ] || die "could not resolve the latest release tag from GitHub"
  VERSION="${TAG#v}"
fi

FILE_NAME="kite-${VERSION}-${SHORT}.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/v${VERSION}/${FILE_NAME}"

info "installing kite ${VERSION} (${SHORT}) into ${INSTALL_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! curl -fsSL -o "$TMP_DIR/$FILE_NAME" "$DOWNLOAD_URL"; then
  die "download failed: $DOWNLOAD_URL (does this release cover $SHORT?)"
fi

tar -xzf "$TMP_DIR/$FILE_NAME" -C "$TMP_DIR"

BIN_PATH="$(find "$TMP_DIR" -type f -name kite | head -n1)"
[ -n "$BIN_PATH" ] || die "no 'kite' binary found inside $FILE_NAME"

mkdir -p "$INSTALL_DIR"
cp "$BIN_PATH" "$INSTALL_DIR/kite"
chmod +x "$INSTALL_DIR/kite"

# The binary isn't notarized/signed by Apple -- clear the quarantine
# attribute curl/tar may have set, otherwise Gatekeeper blocks the first run.
if command -v xattr >/dev/null 2>&1; then
  xattr -d com.apple.quarantine "$INSTALL_DIR/kite" 2>/dev/null || true
fi

ok "kite ${VERSION} installed to ${INSTALL_DIR}/kite"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    printf '%s%s is not on your PATH yet.%s\n' "$BOLD" "$INSTALL_DIR" "$RESET"
    printf 'Add this to your shell profile (~/.zprofile, ~/.zshrc, ...):\n'
    printf '  export PATH="%s:$PATH"\n' "$INSTALL_DIR"
    ;;
esac

info "if macOS still blocks the binary, run: xattr -d com.apple.quarantine $INSTALL_DIR/kite"
info "run 'kite --version' to confirm the install (after opening a new shell if PATH just changed)."

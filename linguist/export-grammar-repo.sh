#!/bin/bash
# Creates the standalone grammar repository (the VS Code extension: TextMate grammar + tests + licence)
# that Linguist vendors as a submodule.   usage: linguist/export-grammar-repo.sh <target-dir>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:?usage: $0 <target-dir>}"
[ -e "$DEST" ] && { echo "error: $DEST already exists" >&2; exit 1; }
mkdir -p "$DEST"
cp -r "$ROOT/editors/vscode/." "$DEST/"
rm -rf "$DEST/node_modules" "$DEST"/*.vsix
mkdir -p "$DEST/.github/workflows"
cat > "$DEST/.github/workflows/ci.yml" <<'YML'
name: ci
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm install --no-audit --no-fund
      - run: npm test
      - run: npm run package
      - uses: actions/upload-artifact@v4
        with: { name: vsix, path: "*.vsix" }
YML
( cd "$DEST" && git init -q -b main && git add -A && git -c user.name=kite -c user.email=kite@example.com commit -q -m "Kite grammar for VS Code and GitHub Linguist" )
echo "created $DEST (git repository with one commit). Push it to github.com/yo-le-zz/vscode-kite"

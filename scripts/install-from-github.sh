#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/CyPack/claude-code-optimization-for-all-providers/main/scripts}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

FILES=(
  "cc-provider"
  "cc-kimi"
  "cc-claude"
  "cc-mini"
  "cc-minimax"
)

fetch() {
  local url="$1"
  local out="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
    return 0
  fi

  echo "Neither curl nor wget is available." >&2
  exit 1
}

mkdir -p "$INSTALL_DIR"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

for file in "${FILES[@]}"; do
  url="$REPO_RAW_BASE/$file"
  tmp="$tmpdir/$file"
  dst="$INSTALL_DIR/$file"

  fetch "$url" "$tmp"
  chmod +x "$tmp"

  if [[ -f "$dst" ]]; then
    cp -a "$dst" "${dst}.bak.${TIMESTAMP}"
  fi

  install -m 755 "$tmp" "$dst"
done

cat <<MSG
Installed switch scripts from GitHub.
- Source: $REPO_RAW_BASE
- Install dir: $INSTALL_DIR
- Commands: cc-provider, cc-kimi, cc-claude, cc-mini, cc-minimax
MSG

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  cat <<WARN
PATH warning:
- $INSTALL_DIR is not in current PATH.
- Add this line to your shell rc file (~/.bashrc or ~/.zshrc):
  export PATH="$INSTALL_DIR:\$PATH"
WARN
fi

"$INSTALL_DIR/cc-provider" status || true

#!/usr/bin/env bash
# Apply opencode configuration from this repo into ~/.config/opencode.
set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [ ! -f "$src" ]; then
    echo "!! source missing: $src" >&2
    exit 1
  fi
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    echo "    unchanged $(basename "$dest")"
    return
  fi
  if [ -e "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%s)"
    echo "    backed up existing $(basename "$dest")"
  fi
  cp "$src" "$dest"
  echo "    copied $(basename "$dest")"
}

echo "==> Applying opencode config from $HERE -> $OPENCODE_DIR"
mkdir -p "$OPENCODE_DIR/agents"

# opencode also reads a plain opencode.json and merges it with opencode.jsonc;
# retire it so this repo's opencode.jsonc is the only global config.
if [ -f "$OPENCODE_DIR/opencode.json" ]; then
  mv "$OPENCODE_DIR/opencode.json" "$OPENCODE_DIR/opencode.json.bak.$(date +%s)"
  echo "    backed up legacy opencode.json (superseded by opencode.jsonc)"
fi

copy_file "$HERE/opencode.jsonc" "$OPENCODE_DIR/opencode.jsonc"
copy_file "$HERE/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
for agent_file in "$HERE"/agents/*.md; do
  [ -e "$agent_file" ] || continue
  copy_file "$agent_file" "$OPENCODE_DIR/agents/$(basename "$agent_file")"
done

echo
echo "==> Done. Installed:"
echo "    $OPENCODE_DIR/opencode.jsonc   <- $HERE/opencode.jsonc"
echo "    $OPENCODE_DIR/AGENTS.md        <- $HERE/AGENTS.md"
echo "    $OPENCODE_DIR/agents/*.md      <- $HERE/agents/*.md"
echo
echo "==> Notes:"
echo "    Sign in to the Vercel AI Gateway with: opencode auth login"
echo "    mobbin runs through mcp-remote: the first time opencode starts it, a browser opens"
echo "    for the Mobbin login; the token is then shared by every agent via ~/.mcp-auth."
echo "    Nothing is linked: re-run this script after editing files here."
echo
echo "==> Verify with:"
echo "    opencode mcp list"

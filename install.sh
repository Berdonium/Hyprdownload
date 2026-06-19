#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE="$SCRIPT_DIR/hyprdownload.tar.gz"
BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/hyprdownload"

if [ ! -f "$ARCHIVE" ]; then
    echo "Error: $ARCHIVE not found. Place this script alongside hyprdownload.tar.gz"
    exit 1
fi

echo "Extracting..."
tmpdir="$(mktemp -d)"
tar xzf "$ARCHIVE" -C "$tmpdir"

mkdir -p "$BIN_DIR"

if [ -f "$BIN" ]; then
    cp "$BIN" "$BIN.bak" 2>/dev/null || true
fi

cp "$tmpdir/hyprdownload-release/hyprdownload" "$BIN"
chmod +x "$BIN"
rm -rf "$tmpdir"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
    rc="$HOME/.bashrc"
    if ! grep -q "export PATH.*\$HOME/.local/bin" "$rc" 2>/dev/null; then
        echo "" >> "$rc"
        echo "# added by hyprdownload install.sh" >> "$rc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        echo "Added $BIN_DIR to PATH in $rc (restart your shell or run 'source $rc')"
    fi
fi

echo "Installed hyprdownload to $BIN"
echo "Run 'hyprdownload' to start"

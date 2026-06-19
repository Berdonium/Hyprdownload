#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/hyprdownload"
REPO="Berdonium/Hyprdownload"

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null || pwd)"

# If Cargo.toml exists locally, build from source
if [ -f "$SCRIPT_DIR/Cargo.toml" ]; then
    echo "Building from local source..."
    cd "$SCRIPT_DIR"
    cargo build --release
    mkdir -p "$BIN_DIR"
    cp target/release/hyprdownload "$BIN"

# If tar.gz is local, extract it
elif [ -f "$SCRIPT_DIR/hyprdownload.tar.gz" ]; then
    echo "Extracting local archive..."
    mkdir -p "$BIN_DIR"
    tmpdir="$(mktemp -d)"
    tar xzf "$SCRIPT_DIR/hyprdownload.tar.gz" -C "$tmpdir"
    cp "$tmpdir/hyprdownload-release/hyprdownload" "$BIN"
    rm -rf "$tmpdir"

# Otherwise clone from GitHub and extract from the bundled archive
else
    echo "Downloading from github.com/$REPO..."
    tmpdir="$(mktemp -d)"
    cd "$tmpdir"
    git clone "https://github.com/$REPO.git" .
    tar xzf hyprdownload.tar.gz -C "$tmpdir"
    mkdir -p "$BIN_DIR"
    cp hyprdownload-release/hyprdownload "$BIN"
    cd /
    rm -rf "$tmpdir"
fi

chmod +x "$BIN"

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

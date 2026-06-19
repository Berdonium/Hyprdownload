#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/hyprdownload"
REPO="Berdonium/Hyprdownload"

if [ -f "$(dirname "$0")/Cargo.toml" ]; then
    echo "Building from local source..."
    cd "$(dirname "$0")"
    cargo build --release
    mkdir -p "$BIN_DIR"
    cp target/release/hyprdownload "$BIN"
else
    echo "Cloning from github.com/$REPO..."
    tmpdir="$(mktemp -d)"
    cd "$tmpdir"
    git clone "https://github.com/$REPO.git"
    cd Hyprdownload
    cargo build --release
    mkdir -p "$BIN_DIR"
    cp target/release/hyprdownload "$BIN"
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

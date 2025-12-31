#!/bin/bash

###############################################################################
# PayloadForge - Installation Script
###############################################################################

set -e

INSTALL_DIR="$HOME/.local/share/payloadforge"
BIN_DIR="$HOME/.local/bin"

echo "╔════════════════════════════════════════╗"
echo "║      PayloadForge Installer v1.2      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check dependencies
echo "[1/5] Checking dependencies..."
MISSING=()

command -v python3 >/dev/null 2>&1 || MISSING+=("python3")
command -v brotli >/dev/null 2>&1 || MISSING+=("brotli")
command -v zip >/dev/null 2>&1 || MISSING+=("zip")
command -v unzip >/dev/null 2>&1 || MISSING+=("unzip")

if [ ${#MISSING[@]} -ne 0 ]; then
    echo "❌ Missing dependencies: ${MISSING[*]}"
    echo ""
    echo "Please install them using your package manager:"
    echo ""
    echo "  Debian/Ubuntu:  sudo apt install ${MISSING[*]}"
    echo "  Arch Linux:     sudo pacman -S ${MISSING[*]}"
    echo "  Fedora/RHEL:    sudo dnf install ${MISSING[*]}"
    echo "  OpenSUSE:       sudo zypper install ${MISSING[*]}"
    echo ""
    exit 1
else
    echo "All dependencies found"
fi

# Create directories
echo "[2/5] Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
echo "Directories created"

# Copy files
echo "[3/5] Copying files..."
cp -r bin scripts lib config "$INSTALL_DIR/"
cp payloadforge "$INSTALL_DIR/"
cp README.md "$INSTALL_DIR/"

# Create directories in install location
mkdir -p "$INSTALL_DIR"/{input,output,temp}
echo "Files copied to $INSTALL_DIR"

# Create symlink
echo "[4/5] Creating symlink..."
ln -sf "$INSTALL_DIR/payloadforge" "$BIN_DIR/payloadforge"
echo "Symlink created at $BIN_DIR/payloadforge"

# Update PATH hint
echo "[5/5] Checking PATH configuration..."
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "⚠ $BIN_DIR is not in your PATH"
    echo ""
    echo "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then run: source ~/.bashrc"
else
    echo "PATH is configured correctly"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      Installation Complete! 🎉        ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Usage: payloadforge --help"
echo "Example: payloadforge your_ota.zip"
echo ""
echo "Installation location: $INSTALL_DIR"
echo ""

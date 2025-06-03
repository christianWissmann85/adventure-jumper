#!/bin/bash

# Flutter Installation Script for WSL2 Ubuntu
# This script will install Flutter SDK natively in WSL2

echo "Flutter WSL2 Installation Script"
echo "================================"

# Check if running in WSL2
if grep -q Microsoft /proc/version; then
    echo "✓ Running in WSL2"
else
    echo "⚠ This script is designed for WSL2. Proceed with caution."
fi

# Set installation directory
FLUTTER_DIR="$HOME/development/flutter"
echo "Flutter will be installed to: $FLUTTER_DIR"

# Install required dependencies
echo ""
echo "Installing required dependencies..."
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Additional dependencies for Linux development
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev

# Create development directory
mkdir -p "$HOME/development"
cd "$HOME/development"

# Check if Flutter is already installed
if [ -d "$FLUTTER_DIR" ]; then
    echo ""
    echo "Flutter directory already exists at $FLUTTER_DIR"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing Flutter installation..."
        rm -rf "$FLUTTER_DIR"
    else
        echo "Keeping existing installation. Exiting."
        exit 0
    fi
fi

# Download Flutter SDK
echo ""
echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH
echo ""
echo "Setting up PATH..."

# Check which shell config file to use
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

# Check if Flutter path already exists in shell config
if ! grep -q "flutter/bin" "$SHELL_CONFIG"; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Flutter SDK" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:$FLUTTER_DIR/bin\"" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$PATH:$FLUTTER_DIR/bin/cache/dart-sdk/bin\"" >> "$SHELL_CONFIG"
    echo "✓ Added Flutter to PATH in $SHELL_CONFIG"
else
    echo "✓ Flutter PATH already exists in $SHELL_CONFIG"
fi

# Source the shell config
source "$SHELL_CONFIG"

# Run Flutter doctor
echo ""
echo "Running Flutter doctor..."
cd "$FLUTTER_DIR"
bin/flutter doctor -v

echo ""
echo "Flutter installation complete!"
echo ""
echo "IMPORTANT: To use Flutter in your current terminal session, run:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Or simply open a new terminal window."
echo ""
echo "To verify the installation, run:"
echo "  flutter doctor"
echo ""
echo "For the Adventure Jumper project, you'll also need to run:"
echo "  cd /home/chris/repos/adventure-jumper"
echo "  flutter pub get"
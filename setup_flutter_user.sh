#!/bin/bash

# Simplified Flutter Installation Script for WSL2 (No sudo required)
# This script will install Flutter SDK in your home directory

echo "Flutter WSL2 User Installation Script"
echo "===================================="
echo ""
echo "This script will install Flutter without requiring sudo."
echo "Note: You should have already installed required packages:"
echo "  sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa"
echo ""
read -p "Press Enter to continue..."

# Set installation directory
FLUTTER_DIR="$HOME/flutter"
echo ""
echo "Flutter will be installed to: $FLUTTER_DIR"

# Check if Flutter is already installed
if [ -d "$FLUTTER_DIR" ]; then
    echo ""
    echo "Flutter directory already exists at $FLUTTER_DIR"
    echo "Please remove it first if you want to reinstall:"
    echo "  rm -rf $FLUTTER_DIR"
    exit 1
fi

# Clone Flutter repository
echo ""
echo "Downloading Flutter SDK (this may take a few minutes)..."
cd "$HOME"
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH for current session
export PATH="$PATH:$FLUTTER_DIR/bin"
export PATH="$PATH:$FLUTTER_DIR/bin/cache/dart-sdk/bin"

# Check which shell config file to use
if [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    SHELL_CONFIG="$HOME/.profile"
fi

# Add Flutter to PATH permanently
echo ""
echo "Adding Flutter to PATH in $SHELL_CONFIG..."
echo "" >> "$SHELL_CONFIG"
echo "# Flutter SDK" >> "$SHELL_CONFIG"
echo "export PATH=\"\$PATH:$FLUTTER_DIR/bin\"" >> "$SHELL_CONFIG"
echo "export PATH=\"\$PATH:$FLUTTER_DIR/bin/cache/dart-sdk/bin\"" >> "$SHELL_CONFIG"

# Pre-download Flutter dependencies
echo ""
echo "Pre-downloading Flutter dependencies..."
"$FLUTTER_DIR/bin/flutter" precache

# Run Flutter doctor
echo ""
echo "Running Flutter doctor..."
"$FLUTTER_DIR/bin/flutter" doctor

echo ""
echo "========================================="
echo "Flutter installation complete!"
echo ""
echo "To use Flutter in your current terminal, run:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Or simply close and reopen your terminal."
echo ""
echo "Next steps:"
echo "1. Open a new terminal or run: source $SHELL_CONFIG"
echo "2. Navigate to your project: cd /home/chris/repos/adventure-jumper"
echo "3. Get dependencies: flutter pub get"
echo "4. Run tests: flutter test"
echo "========================================="
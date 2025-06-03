#!/bin/bash

echo "Flutter/Dart Environment Check"
echo "=============================="
echo ""

# Check WSL version
echo "WSL Information:"
if grep -q Microsoft /proc/version; then
    echo "✓ Running in WSL"
    cat /proc/version
else
    echo "✗ Not running in WSL"
fi
echo ""

# Check current PATH
echo "Current PATH:"
echo $PATH | tr ':' '\n' | grep -E "(flutter|dart)" || echo "No Flutter/Dart found in PATH"
echo ""

# Check for Flutter installations
echo "Looking for Flutter installations:"
echo "1. Windows mount: /mnt/c/dev/flutter"
if [ -d "/mnt/c/dev/flutter" ]; then
    echo "   ✓ Found (Windows installation)"
else
    echo "   ✗ Not found"
fi

echo "2. WSL2 native: ~/development/flutter"
if [ -d "$HOME/development/flutter" ]; then
    echo "   ✓ Found (WSL2 installation)"
else
    echo "   ✗ Not found"
fi

echo "3. WSL2 native: ~/flutter"
if [ -d "$HOME/flutter" ]; then
    echo "   ✓ Found (WSL2 installation)"
else
    echo "   ✗ Not found"
fi
echo ""

# Check if Flutter/Dart commands work
echo "Command availability:"
echo -n "flutter: "
if command -v flutter &> /dev/null; then
    echo "✓ Available at $(which flutter)"
    flutter --version 2>&1 | head -1 || echo "   ✗ Error running flutter"
else
    echo "✗ Not found"
fi

echo -n "dart: "
if command -v dart &> /dev/null; then
    echo "✓ Available at $(which dart)"
    dart --version 2>&1 || echo "   ✗ Error running dart"
else
    echo "✗ Not found"
fi
echo ""

# Check shell configuration files
echo "Shell configuration:"
for file in ~/.bashrc ~/.zshrc ~/.profile; do
    if [ -f "$file" ]; then
        echo -n "$file: "
        if grep -q "flutter" "$file"; then
            echo "✓ Contains Flutter configuration"
        else
            echo "✗ No Flutter configuration found"
        fi
    fi
done
echo ""

# Check for required packages
echo "Required packages:"
packages=("curl" "git" "unzip" "xz-utils" "zip" "libglu1-mesa")
for pkg in "${packages[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg"; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg (not installed)"
    fi
done
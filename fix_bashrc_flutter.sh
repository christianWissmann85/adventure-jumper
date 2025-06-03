#!/bin/bash

echo "Creating backup of .bashrc..."
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)

echo "Updating .bashrc to prioritize WSL2 Flutter..."

# Create a temporary file with the new content
cat > ~/.bashrc.new << 'EOF'
# Fix Flutter PATH - Remove Windows Flutter and prioritize WSL2 Flutter
# This must be at the top of .bashrc before other PATH modifications
export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/mnt/c/dev/flutter" | tr '\n' ':' | sed 's/:$//')
export PATH="/home/chris/flutter/bin:/home/chris/flutter/bin/cache/dart-sdk/bin:$PATH"

EOF

# Append the rest of the original .bashrc
cat ~/.bashrc >> ~/.bashrc.new

# Replace the old .bashrc with the new one
mv ~/.bashrc.new ~/.bashrc

echo "Done! Your .bashrc has been updated."
echo ""
echo "Now run:"
echo "  source ~/.bashrc"
echo ""
echo "Then test with:"
echo "  which flutter"
echo "  flutter --version"
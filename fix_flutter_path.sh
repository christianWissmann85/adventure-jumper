#!/bin/bash

echo "Fixing Flutter PATH priority..."
echo ""

# Remove Windows Flutter from PATH for current session
export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/mnt/c/dev/flutter" | tr '\n' ':' | sed 's/:$//')

# Add WSL2 Flutter to the beginning of PATH
export PATH="/home/chris/flutter/bin:/home/chris/flutter/bin/cache/dart-sdk/bin:$PATH"

echo "Current PATH (Flutter-related entries):"
echo $PATH | tr ':' '\n' | grep -E "(flutter|dart)" | head -5

echo ""
echo "Testing Flutter:"
which flutter
flutter --version

echo ""
echo "To make this permanent, add this to the TOP of your ~/.bashrc file:"
echo ""
echo "# Remove Windows Flutter from PATH"
echo "export PATH=\$(echo \$PATH | tr ':' '\n' | grep -v \"/mnt/c/dev/flutter\" | tr '\n' ':' | sed 's/:$//')"
echo ""
echo "# Add WSL2 Flutter to PATH (at the beginning)"
echo "export PATH=\"/home/chris/flutter/bin:/home/chris/flutter/bin/cache/dart-sdk/bin:\$PATH\""
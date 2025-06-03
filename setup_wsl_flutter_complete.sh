#!/bin/bash

echo "Complete Flutter WSL2 Setup"
echo "=========================="
echo ""

# Function to update .bashrc
update_bashrc() {
    echo "Updating .bashrc for proper Flutter configuration..."
    
    # Backup current .bashrc
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
    
    # Create new .bashrc content
    cat > ~/.bashrc.tmp << 'EOF'
# Flutter PATH configuration (must be early in file)
# Remove Windows Flutter paths and use WSL2 native Flutter
if [[ "$PATH" == *"/mnt/c/dev/flutter"* ]]; then
    export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/mnt/c/dev/flutter" | tr '\n' ':' | sed 's/:$//')
fi

# Add WSL2 Flutter to beginning of PATH
export FLUTTER_HOME="/home/chris/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Prevent Windows path pollution (optional - uncomment if needed)
# export PATH=$(echo $PATH | tr ':' '\n' | grep -v "^/mnt/c" | tr '\n' ':' | sed 's/:$//')

EOF
    
    # Append the rest of the original .bashrc, excluding old Flutter entries
    grep -v "flutter/bin" ~/.bashrc | grep -v "Flutter SDK" >> ~/.bashrc.tmp
    
    # Replace .bashrc
    mv ~/.bashrc.tmp ~/.bashrc
    
    echo "✓ .bashrc updated"
}

# Function to test Flutter
test_flutter() {
    echo ""
    echo "Testing Flutter installation..."
    
    # Source the updated bashrc
    source ~/.bashrc
    
    echo "PATH entries with Flutter:"
    echo $PATH | tr ':' '\n' | grep flutter
    
    echo ""
    echo "Which Flutter: $(which flutter)"
    echo ""
    
    if /home/chris/flutter/bin/flutter --version &>/dev/null; then
        echo "✓ Flutter is working!"
        /home/chris/flutter/bin/flutter --version
    else
        echo "✗ Flutter is not working properly"
        return 1
    fi
}

# Main execution
echo "1. Checking current Flutter installation..."
if [ -d "/home/chris/flutter" ]; then
    echo "✓ WSL2 Flutter found at /home/chris/flutter"
else
    echo "✗ WSL2 Flutter not found. Please run setup_flutter_user.sh first"
    exit 1
fi

echo ""
echo "2. Updating PATH configuration..."
update_bashrc

echo ""
echo "3. Testing Flutter..."
if test_flutter; then
    echo ""
    echo "=================================="
    echo "✓ Flutter is now properly configured!"
    echo ""
    echo "Please run these commands:"
    echo "  source ~/.bashrc"
    echo "  cd /home/chris/repos/adventure-jumper"
    echo "  flutter pub get"
    echo "=================================="
else
    echo ""
    echo "⚠ Flutter test failed. Please check the error messages above."
fi

# Optional: Create an alias for quick Flutter access
echo ""
echo "Creating Flutter alias..."
echo "alias fl='flutter'" >> ~/.bashrc
echo "✓ Added 'fl' alias for flutter"
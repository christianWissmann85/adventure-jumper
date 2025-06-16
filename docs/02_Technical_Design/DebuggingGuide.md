# Debug Infrastructure Guide

This document provides guidance on using the debug infrastructure in the Adventure Jumper project.

## Overview

The debug infrastructure provides several capabilities:

- Structured logging with different levels (debug, info, warning, error)
- Visual debugging tools (FPS counter, collision boxes, etc.)
- In-game console for viewing logs and executing commands
- Performance tracking and profiling 
- Conditional compilation for debug-only code

## Basic Logging Usage

### Using the Debug Module

The `Debug` module provides a centralized interface for all debugging functionality:

```dart
import '../utils/debug_module.dart';

// Get a logger for a specific component
final logger = Debug.logger('MyComponent');

// Log messages at different levels
logger.fine('Debug-level message');
logger.info('Information message');
logger.warning('Warning message');
logger.severe('Error message', exception, stackTrace);
```

### Using Logger Extension Methods

You can also use the extension methods directly on classes:

```dart
import '../utils/debug.dart';

class MyClass {
  void myMethod() {
    // Log using the class name automatically
    debug('Debug message');
    info('Info message');
    warning('Warning message');
    error('Error message', exception);
  }
}
```

## Debug Configuration

Debug features can be enabled or disabled through the `DebugConfig` class:

```dart
import '../utils/debug_config.dart';

// Check if a feature is enabled
if (DebugConfig.showFPS) {
  // Display FPS counter
}

// Toggle a feature
Debug.toggleFeature(DebugFeature.collisionBoxes);
```

## Debug Commands

When the in-game console is enabled, these commands are available:

| Command | Description | Example |
|---------|-------------|---------|
| help | List all available commands | `help` |
| clear | Clear the console | `clear` |
| debug | Show or set debug features | `debug fps on`, `debug collision off` |
| echo | Print a message | `echo Hello World` |
| perf | Performance monitoring | `perf start myFunction` |

## Performance Tracking

Track performance of specific code sections:

```dart
// Start tracking performance
Debug.startPerformanceTracking('loadLevel');

// Your code here
loadLevel(levelId);

// End tracking
Debug.endPerformanceTracking('loadLevel');
```

## Best Practices

1. **Use appropriate log levels:**
   - `fine`/`debug`: Verbose debugging information
   - `info`: General informational messages
   - `warning`: Potential problems that don't halt execution
   - `severe`/`error`: Errors that affect functionality

2. **Provide context in log messages:**
   - Include relevant IDs, states, and values
   - Use structured format: "Action: Result (Context)"
   - Example: "Load level: Failed (Level ID: 3, Reason: File not found)"

3. **Use conditional logging:**
   - Wrap verbose logging in conditions to avoid performance impact
   - Example: `if (DebugConfig.verbose) { logger.fine('Detailed info...'); }`

4. **Clean up debug code:**
   - Use the debug-only conditional compilation
   - Remove or disable excessive debugging before release builds

## Conditional Compilation

Use conditional compilation for debug-only code:

```dart
// Import for kDebugMode
import 'package:flutter/foundation.dart';

void myFunction() {
  // This code only runs in debug mode
  if (kDebugMode) {
    // Debug-only code here
  }
}
```

## Setting Up Visual Debugging

To add the debug overlay to your game:

```dart
// In your main game class
import '../ui/debug_overlay.dart';

class MyGame extends FlameGame {
  late final DebugOverlay debugOverlay;
  
  @override
  Future<void> onLoad() async {
    // Add debug overlay if in debug mode
    if (DebugConfig.enableDevTools) {
      debugOverlay = DebugOverlay();
      add(debugOverlay);
    }
  }
}
```

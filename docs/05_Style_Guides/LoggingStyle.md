# Logging Style Guide - Adventure Jumper

This document provides comprehensive guidelines for logging in the Adventure Jumper project, ensuring consistent and effective logging practices across the codebase.

## Overview

Adventure Jumper uses a structured logging system built on top of Dart's `package:logging` with custom integration for game-specific needs. The system provides configurable log levels, automatic error handling integration, and DevTools compatibility.

## Logging Architecture

### Core Components

- **GameLogger**: Centralized logging system with `package:logging` integration
- **Debug Module**: Unified interface for all debugging functionality
- **ErrorHandler**: Automatic routing of severe logs to error handling system
- **DebugConsole**: In-game console for viewing logs and executing commands

### Initialization

The logging system is initialized in `main.dart`:

```dart
import 'package:adventure_jumper/src/utils/debug_module.dart';

void main() {
  // Initialize debug infrastructure including logging
  await Debug.initialize(
    enableVerboseLogging: kDebugMode,
    enableInGameConsole: kDebugMode,
    enableVisualDebugging: kDebugMode,
  );

  runApp(MyApp());
}
```

## Logging Patterns by Scenario

### 1. System Initialization and Lifecycle

```dart
class AudioSystem {
  void initialize() {
    logger.info('Audio system initializing');

    try {
      // Initialization code
      logger.info('Audio system initialized successfully');
    } catch (e, stackTrace) {
      logger.severe('Audio system initialization failed', e, stackTrace);
      throw AudioInitializationException('Failed to initialize audio', cause: e);
    }
  }

  void dispose() {
    logger.info('Audio system disposing');
    // Cleanup code
    logger.fine('Audio system disposed');
  }
}
```

### 2. Asset Loading and Management

```dart
class AssetManager {
  Future<void> loadAsset(String path) async {
    logger.info('Loading asset: $path');

    try {
      // Loading logic
      logger.fine('Asset loaded successfully: $path');
    } catch (e) {
      logger.severe('Failed to load asset: $path', e);
      throw AssetException('Asset loading failed', path, 'load', cause: e);
    }
  }

  void cacheAsset(String id, Asset asset) {
    logger.fine('Caching asset: $id (size: ${asset.size} bytes)');
    // Caching logic
  }
}
```

### 3. Game State Changes

```dart
class GameStateManager {
  void changeState(GameState newState) {
    final GameState oldState = currentState;
    logger.info('Game state transition: ${oldState.name} → ${newState.name}');

    currentState = newState;

    if (logger.isLoggable(Level.FINE)) {
      logger.fine('State transition details: '
          'from=${oldState.name}, to=${newState.name}, '
          'timestamp=${DateTime.now().toIso8601String()}');
    }
  }
}
```

### 4. Player Actions and Events

```dart
class PlayerController {
  void jump() {
    if (canJump) {
      logger.fine('Player jumping (velocity: ${player.velocity.y})');
      // Jump logic
    } else {
      logger.finer('Jump attempted but not allowed (reason: ${jumpBlockReason})');
    }
  }

  void onPlayerDeath() {
    logger.info('Player death event triggered');
    logger.fine('Death cause: ${deathCause}, position: ${player.position}');
  }
}
```

### 5. Performance Monitoring

```dart
class PhysicsSystem {
  void update(double deltaTime) {
    Debug.startPerformanceTracking('physics_update');

    if (logger.isLoggable(Level.FINER)) {
      logger.finer('Physics update: entities=${entities.length}, dt=${deltaTime}');
    }

    // Physics calculations

    Debug.endPerformanceTracking('physics_update');
  }

  void resolveCollisions() {
    final int collisionCount = collisions.length;

    if (collisionCount > 0) {
      logger.fine('Resolving $collisionCount collisions');

      for (final collision in collisions) {
        logger.finer('Collision: ${collision.entityA.type} ↔ ${collision.entityB.type}');
      }
    }
  }
}
```

### 6. Error Handling and Recovery

```dart
class SaveManager {
  Future<void> saveGame(SaveData data) async {
    logger.info('Saving game: ${data.metadata}');

    try {
      await writeToFile(data);
      logger.info('Game saved successfully');
    } on FileSystemException catch (e) {
      logger.severe('Save failed - file system error', e);
      throw SaveException('Cannot write save file', e.path ?? 'unknown', 'write', cause: e);
    } catch (e) {
      logger.severe('Save failed - unexpected error', e);
      throw SaveException('Unexpected save error', 'unknown', 'save', cause: e);
    }
  }

  Future<SaveData?> loadGame() async {
    try {
      logger.info('Loading game save');
      final data = await readFromFile();
      logger.info('Game loaded successfully');
      return data;
    } catch (e) {
      logger.warning('Failed to load save file, using defaults', e);
      return null; // Fall back to default state
    }
  }
}
```

### 7. Network Operations (Future)

```dart
class NetworkManager {
  Future<void> sendRequest(String endpoint) async {
    logger.info('Network request: $endpoint');

    try {
      // Request logic
      logger.fine('Request completed: $endpoint');
    } on TimeoutException catch (e) {
      logger.warning('Request timeout: $endpoint', e);
      throw NetworkException('Request timed out', endpoint, 'send', cause: e);
    }
  }
}
```

## Testing Logging Patterns

### Unit Tests

```dart
test('Player controller handles jump input', () {
  logger.info('Testing player jump input handling');

  final player = createTestPlayer();
  logger.fine('Test player created: ${player.position}');

  player.jump();

  expect(player.isJumping, isTrue);
  logger.fine('Jump test completed successfully');
});
```

### Integration Tests

```dart
testWidgets('Game loads and displays main menu', (tester) async {
  logger.info('Starting integration test: main menu display');

  await tester.pumpWidget(AdventureJumperApp());
  await tester.pumpAndSettle();

  expect(find.text('Play'), findsOneWidget);
  logger.info('Integration test completed: main menu displayed correctly');
});
```

## Security Guidelines

### What NOT to Log

❌ **Never log these items:**

- User passwords or authentication tokens
- API keys or secret credentials
- Complete user data or personal information
- Full save file contents (log metadata only)
- Internal system paths or configuration details

### What TO Log Safely

✅ **Safe to log:**

- Operation success/failure status
- Non-sensitive metadata (file sizes, counts, timestamps)
- Error types and general error messages
- Performance metrics
- User action types (without personal data)

```dart
// ❌ Bad - exposes sensitive data
logger.info('User login: email=${user.email}, password=${user.password}');

// ✅ Good - logs operation without sensitive data
logger.info('User authentication successful');

// ❌ Bad - exposes internal paths
logger.info('Loading config from: ${Platform.environment["HOME"]}/app/config.json');

// ✅ Good - logs operation status
logger.info('Configuration loaded successfully');
```

## Performance Guidelines

### Conditional Logging for Expensive Operations

```dart
// For operations that are expensive to compute
if (logger.isLoggable(Level.FINE)) {
  final String debugInfo = computeExpensiveDebugInformation();
  logger.fine('Detailed debug info: $debugInfo');
}

// Alternative using lazy evaluation
logger.fine(() => 'Expensive computation: ${expensiveOperation()}');
```

### Avoiding Performance Impact

```dart
class HighFrequencySystem {
  int _logCounter = 0;

  void update(double deltaTime) {
    // Only log every 60 frames instead of every frame
    if (++_logCounter % 60 == 0) {
      logger.finer('High frequency system update (60 frames)');
    }
  }
}
```

## Troubleshooting Guide

### Common Logging Issues

#### 1. Logs Not Appearing

**Problem**: Logger messages not showing in console or DevTools.

**Solutions**:

- Check if GameLogger is initialized in `main.dart`
- Verify log level settings in debug/release mode
- Ensure proper import: `import '../utils/logger.dart';`
- Check if using LoggerExtension: class should extend or mixin logging capability

#### 2. Excessive Logging Output

**Problem**: Too many log messages affecting performance or readability.

**Solutions**:

- Review log levels - use `fine`/`finer` for detailed debug info
- Add conditional logging for expensive operations
- Use log level filtering in DevTools
- Reduce logging frequency in high-performance loops

#### 3. Missing Context in Logs

**Problem**: Log messages lack sufficient context for debugging.

**Solutions**:

- Include relevant IDs, states, and values in messages
- Use structured format: "Action: Result (Context)"
- Add logger names that reflect the component/system
- Include error objects and stack traces for exceptions

#### 4. Circular Import Issues

**Problem**: Import cycles when adding logger to classes.

**Solutions**:

- Use LoggerExtension instead of direct GameLogger imports
- Create static logger instances to avoid import cycles
- Import `logger.dart` directly instead of `debug_module.dart`

### Debug Console Commands

Use the in-game debug console to troubleshoot logging issues:

```
debug verbose on     # Enable verbose logging
debug all on         # Enable all debug features
clear               # Clear console output
help                # List all available commands
```

## Logger Configuration

### Debug vs Release Settings

```dart
// Debug mode configuration
GameLogger.initialize(
  enableVerboseLogging: true,
  rootLevel: Level.ALL,
  enableConsoleOutput: true,
);

// Release mode configuration
GameLogger.initialize(
  enableVerboseLogging: false,
  rootLevel: Level.INFO,
  enableConsoleOutput: false,
);
```

### Custom Logger Names

```dart
// System-specific loggers
static final _physicsLogger = GameLogger.getLogger('Physics');
static final _audioLogger = GameLogger.getLogger('Audio.Music');
static final _saveLogger = GameLogger.getLogger('Save.Manager');

// Feature-specific loggers
static final _collisionLogger = GameLogger.getLogger('Physics.Collision');
static final _inputLogger = GameLogger.getLogger('Input.Keyboard');
```

## Migration from print()

When updating existing code that uses `print()`:

1. **Assess the purpose**: Is it temporary debugging or permanent logging?
2. **Choose appropriate method**:
   - Temporary: Use `developer.log()` (plan to remove)
   - Permanent: Use structured logging with appropriate level
3. **Add proper context**: Include class name, method, relevant data
4. **Test integration**: Verify logs appear correctly in DevTools

```dart
// Before (using print)
 // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
print('Player moving left (velocity: ${velocity.x})');

// After (temporary debugging)
developer.log(
  'Player moving left (velocity: ${velocity.x})',
  name: 'PlayerController._moveLeft',
);

// After (permanent logging)
logger.fine('Player moving left (velocity: ${velocity.x})');
```

## Related Documentation

- [Debug Infrastructure Guide](../02_Technical_Design/DebuggingGuide.md) - Debug tools and visual debugging
- [Error Handling Guide](../02_Technical_Design/ErrorHandlingGuide.md) - Error logging integration
- [Documentation Style Guide](DocumentationStyle.md) - Documentation logging standards
- [Action Plan: Logging Migration](../03_Development_Process/ActionPlan_LoggingMigration.md) - Migration process and standards

---

_Last Updated: May 25, 2025_

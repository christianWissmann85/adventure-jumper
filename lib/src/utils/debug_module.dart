import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'debug_config.dart';
import 'debug_console.dart';
import 'debug_utils.dart';
import 'logger.dart';

/// Debug Module - Unified interface for all game debugging functionality
///
/// This class centralizes all debugging tools, including logging, performance
/// monitoring, and visual debugging, into a single easy-to-use API.
class Debug {
  // Private constructor to prevent instantiation
  Debug._();

  static final Logger _logger = GameLogger.getLogger('DebugModule');
  static bool _isInitialized = false;

  /// Initialize the debug module with given options
  ///
  /// This must be called before any other debug functions.
  static Future<void> initialize({
    bool enableDebugMode = kDebugMode,
    bool enableVerboseLogging = kDebugMode,
    bool enableInGameConsole = kDebugMode,
    bool enableVisualDebugging = kDebugMode,
    bool enablePerformanceTracking = kDebugMode,
    bool enableDevTools = kDebugMode,
  }) async {
    if (_isInitialized) {
      _logger.warning('Debug module already initialized');
      return;
    }

    // Configure debug settings
    DebugConfig.initialize(
      enableDebug: enableDebugMode,
      enableVerbose: enableVerboseLogging,
      enablePerformanceTracking: enablePerformanceTracking,
      enableDevTools: enableDevTools,
      enableFPS: enableVisualDebugging,
    );

    // Initialize the logger first so we can log init steps
    GameLogger.initialize(
      enableVerboseLogging: enableVerboseLogging,
      rootLevel: enableVerboseLogging ? Level.ALL : Level.INFO,
    );

    // Initialize other debugging components
    DebugUtils.initialize(
      debugMode: enableDebugMode,
      showFPS: enableVisualDebugging,
      showCollisionBoxes: enableVisualDebugging,
      logPerformance: enablePerformanceTracking,
      verboseLogging: enableVerboseLogging,
    );

    if (enableInGameConsole) {
      DebugConsole.initialize();
    }

    _isInitialized = true;
    _logger.info('Debug module initialized');
  }

  /// Get a logger for a specific component
  ///
  /// Usage: `Debug.logger('PlayerMovement').info('Player jumped');`
  static Logger logger(String name) {
    _assertInitialized();
    return GameLogger.getLogger(name);
  }

  /// Toggle debug console visibility
  static void toggleConsole() {
    _assertInitialized();
    if (DebugConfig.enableConsoleCommands) {
      DebugConsole.toggleVisibility();
    }
  }

  /// Run a debug command
  static String runCommand(String command) {
    _assertInitialized();
    if (DebugConfig.enableConsoleCommands) {
      return DebugConsole.executeCommand(command);
    }
    return 'Debug console is disabled';
  }

  /// Toggle a debug feature
  static void toggleFeature(DebugFeature feature) {
    _assertInitialized();

    switch (feature) {
      case DebugFeature.collisionBoxes:
        DebugConfig.showCollisionBoxes = !DebugConfig.showCollisionBoxes;
        _logger.info(
            'Collision boxes ${DebugConfig.showCollisionBoxes ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.velocityVectors:
        DebugConfig.showVelocityVectors = !DebugConfig.showVelocityVectors;
        _logger.info(
            'Velocity vectors ${DebugConfig.showVelocityVectors ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.fps:
        DebugConfig.showFPS = !DebugConfig.showFPS;
        _logger.info(
            'FPS display ${DebugConfig.showFPS ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.memoryUsage:
        DebugConfig.showMemoryUsage = !DebugConfig.showMemoryUsage;
        _logger.info(
            'Memory usage display ${DebugConfig.showMemoryUsage ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.entityCount:
        DebugConfig.showEntityCount = !DebugConfig.showEntityCount;
        _logger.info(
            'Entity count display ${DebugConfig.showEntityCount ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.performance:
        DebugConfig.trackPerformance = !DebugConfig.trackPerformance;
        _logger.info(
            'Performance tracking ${DebugConfig.trackPerformance ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.inspector:
        DebugConfig.enableInspector = !DebugConfig.enableInspector;
        _logger.info(
            'Inspector ${DebugConfig.enableInspector ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.entityEditor:
        DebugConfig.enableEntityEditor = !DebugConfig.enableEntityEditor;
        _logger.info(
            'Entity editor ${DebugConfig.enableEntityEditor ? "enabled" : "disabled"}',);
        break;
      case DebugFeature.consoleCommands:
        DebugConfig.enableConsoleCommands = !DebugConfig.enableConsoleCommands;
        _logger.info(
            'Console commands ${DebugConfig.enableConsoleCommands ? "enabled" : "disabled"}',);
        break;
    }
  }

  /// Start performance tracking for a section of code
  static void startPerformanceTracking(String name) {
    _assertInitialized();
    if (DebugConfig.trackPerformance) {
      DebugUtils.startPerformanceTracking(name);
    }
  }

  /// End performance tracking for a section of code
  static void endPerformanceTracking(String name) {
    _assertInitialized();
    if (DebugConfig.trackPerformance) {
      DebugUtils.endPerformanceTracking(name);
    }
  }

  /// Assert that the debug module is initialized
  static void _assertInitialized() {
    assert(_isInitialized,
        'Debug module not initialized. Call Debug.initialize() first.',);
  }
}

/// Extension methods for cleaner debug logging
extension DebugLogExtension on Object {
  /// Log a debug message
  void debug(String message) {
    GameLogger.getLogger(runtimeType.toString()).fine(message);
  }

  /// Log an info message
  void info(String message) {
    GameLogger.getLogger(runtimeType.toString()).info(message);
  }

  /// Log a warning message
  void warning(String message) {
    GameLogger.getLogger(runtimeType.toString()).warning(message);
  }

  /// Log an error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    GameLogger.getLogger(runtimeType.toString())
        .severe(message, error, stackTrace);
  }
}

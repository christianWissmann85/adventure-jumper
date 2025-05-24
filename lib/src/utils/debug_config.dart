import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Debug configuration for Adventure Jumper
///
/// This class centralizes all debug settings and flags in one place,
/// allowing for easy enabling/disabling of debugging features.
class DebugConfig {
  // Private constructor to prevent instantiation
  DebugConfig._();

  // Debug modes and flags
  static bool debugMode = kDebugMode;
  static bool verbose = kDebugMode;
  static Level logLevel = kDebugMode ? Level.ALL : Level.INFO;
  // Feature debugging flags
  static bool showCollisionBoxes = false;
  static bool showVelocityVectors = false;
  static bool showFPS = kDebugMode;
  static bool showMemoryUsage = kDebugMode;
  static bool showEntityCount = kDebugMode;
  static bool trackPerformance = kDebugMode;
  static bool logAssetLoading = kDebugMode;
  static bool logAudioOperations = kDebugMode;
  static bool logLevelLoading = true; // Important enough to log in all modes
  static bool logSaveOperations = true; // Important enough to log in all modes
  static bool logInputEvents = kDebugMode && verbose;
  static bool logNetworkOperations = true; // Important enough to log in all modes

  // Enable development-only features
  static bool enableDevTools = kDebugMode;
  static bool enableInspector = kDebugMode;
  static bool enableEntityEditor = kDebugMode;
  static bool enableConsoleCommands = kDebugMode;

  /// Initialize debug configuration
  static void initialize({
    bool? enableDebug,
    bool? enableVerbose,
    Level? customLogLevel,
    bool? enableDevTools,
    bool? enableFPS,
    bool? enableCollisionBoxes,
    bool? enablePerformanceTracking,
  }) {
    debugMode = enableDebug ?? kDebugMode;
    verbose = enableVerbose ?? debugMode;
    logLevel = customLogLevel ?? (debugMode ? Level.ALL : Level.INFO);

    // Set flags based on debug mode
    showFPS = enableFPS ?? debugMode;
    showCollisionBoxes = enableCollisionBoxes ?? false;
    trackPerformance = enablePerformanceTracking ?? debugMode;

    // Dev tools
    DebugConfig.enableDevTools = enableDevTools ?? debugMode;
  }

  /// Check if a specific debug feature is enabled
  static bool isFeatureEnabled(DebugFeature feature) {
    return switch (feature) {
      DebugFeature.collisionBoxes => showCollisionBoxes,
      DebugFeature.velocityVectors => showVelocityVectors,
      DebugFeature.fps => showFPS,
      DebugFeature.memoryUsage => showMemoryUsage,
      DebugFeature.entityCount => showEntityCount,
      DebugFeature.performance => trackPerformance,
      DebugFeature.inspector => enableInspector,
      DebugFeature.entityEditor => enableEntityEditor,
      DebugFeature.consoleCommands => enableConsoleCommands,
    };
  }
}

/// Debug features that can be individually toggled
enum DebugFeature {
  collisionBoxes,
  velocityVectors,
  fps,
  memoryUsage,
  entityCount,
  performance,
  inspector,
  entityEditor,
  consoleCommands,
}

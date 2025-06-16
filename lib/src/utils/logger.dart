import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'error_handler.dart';

/// Game Logger - Unified logging system for Adventure Jumper
///
/// This class provides a simplified interface for logging throughout the game,
/// leveraging the structured logging capabilities of package:logging
/// while integrating with our existing error handling system.
class GameLogger {
  /// Create a logger for a specific module/system
  static Logger getLogger(String name) {
    return Logger(name);
  }

  /// Initialize the logging system
  static void initialize({
    bool enableVerboseLogging = kDebugMode,
    bool enableConsoleOutput = true,
    bool enableFileLogging = false,
    Level rootLevel = Level.INFO,
  }) {
    // Configure the root logger level
    Logger.root.level = enableVerboseLogging ? Level.ALL : rootLevel;

    // Set up listeners for log records
    Logger.root.onRecord.listen((record) {
      // Format message with context
      final String loggerName = record.loggerName;
      final String message = record.message;
      final String formattedMessage = '[$loggerName] $message';

      // Handle based on log level
      if (record.level >= Level.SEVERE) {
        // Delegate to error handler for errors
        ErrorHandler.logError(
          message,
          error: record.error,
          stackTrace: record.stackTrace,
          context: loggerName,
          level: _convertLogLevel(record.level),
        );
      } else if (enableConsoleOutput) {
        if (record.level >= Level.WARNING) {
          // Use developer.log for warnings
          developer.log(
            formattedMessage,
            name: 'AdventureJumper',
            level: record.level.value,
            error: record.error,
            stackTrace: record.stackTrace,
          );
        } else {
          // For levels below WARNING (e.g., INFO, FINE, FINER, FINEST),
          // always print to console if enableConsoleOutput is true.
          // This ensures diagnostic logs appear during testing, regardless of kDebugMode.
          debugPrint('[${record.level.name}] $formattedMessage');
        }
      }

      // File logging logic would go here
      if (enableFileLogging) {
        // TODO: Implement file-based logging
      }
    });
  }

  /// Convert a logging.Level to our internal LogLevel
  static LogLevel _convertLogLevel(Level level) {
    if (level >= Level.SHOUT) return LogLevel.critical;
    if (level >= Level.SEVERE) return LogLevel.error;
    if (level >= Level.WARNING) return LogLevel.warning;
    if (level >= Level.INFO) return LogLevel.info;
    return LogLevel.debug;
  }
}

/// Logger extension for simpler use with objects/classes
extension LoggerExtension on Object {
  /// Get a logger named for this object's class
  Logger get logger => GameLogger.getLogger(runtimeType.toString());
}

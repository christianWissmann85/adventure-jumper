import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'camera.dart';
import 'exceptions.dart';

/// Debug utilities for the Adventure Jumper game
/// Provides debugging tools, logging, and visualization utilities
class DebugUtils {
  // Private constructor to prevent instantiation
  DebugUtils._();

  // Debug configuration
  static bool _debugMode = kDebugMode;
  static bool _showCollisionBoxes = false;
  static bool _showVelocityVectors = false;
  static bool _showFPS = false;
  static bool _showEntityCount = false;
  static bool _logPerformance = false;
  static bool _verboseLogging = false;

  // Debug colors
  static const Color collisionBoxColor = Colors.red;
  static const Color velocityVectorColor = Colors.blue;
  static const Color debugTextColor = Colors.white;
  static const Color performanceGoodColor = Colors.green;
  static const Color performanceWarningColor = Colors.yellow;
  static const Color performanceBadColor = Colors.red;

  // Performance tracking
  static final Map<String, PerformanceTracker> _performanceTrackers =
      <String, PerformanceTracker>{};
  static final List<String> _debugLog = <String>[];
  static const int _maxLogEntries = 1000;
  // Frame rate tracking
  static final List<double> _frameTimes = <double>[];
  static const int _maxFrameSamples = 60;

  /// Initialize debug utilities
  static void initialize({
    bool debugMode = kDebugMode,
    bool showCollisionBoxes = false,
    bool showVelocityVectors = false,
    bool showFPS = false,
    bool logPerformance = false,
    bool verboseLogging = false,
  }) {
    _debugMode = debugMode;
    _showCollisionBoxes = showCollisionBoxes;
    _showVelocityVectors = showVelocityVectors;
    _showFPS = showFPS;
    _logPerformance = logPerformance;
    _verboseLogging = verboseLogging;

    log('Debug utilities initialized', LogLevel.info);
  }

  /// Log a message with specified level
  static void log(String message, [LogLevel level = LogLevel.debug]) {
    if (!_debugMode && level == LogLevel.debug) return;

    final String timestamp = DateTime.now().toIso8601String();
    final String levelStr = level.toString().split('.').last.toUpperCase();
    final String logEntry = '[$timestamp] [$levelStr] $message';

    // Add to debug log
    _debugLog.add(logEntry);
    if (_debugLog.length > _maxLogEntries) {
      _debugLog.removeAt(0);
    }

    // Print to console based on level
    switch (level) {
      case LogLevel.error:
        developer.log(logEntry, level: 1000, name: 'AdventureJumper');
        break;
      case LogLevel.warning:
        developer.log(logEntry, level: 900, name: 'AdventureJumper');
        break;
      case LogLevel.info:
        developer.log(logEntry, level: 800, name: 'AdventureJumper');
        break;
      case LogLevel.debug:
        if (_verboseLogging) {
          developer.log(logEntry, level: 700, name: 'AdventureJumper');
        }
        break;
    }
  }

  /// Log an error with stack trace
  static void logError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log('ERROR: $message${error != null ? ' - $error' : ''}', LogLevel.error);
    if (stackTrace != null && _verboseLogging) {
      log('Stack trace: $stackTrace', LogLevel.error);
    }
  }

  /// Log performance metrics
  static void logPerformanceMetrics(String operation, double milliseconds) {
    if (!_logPerformance) return;

    final LogLevel level =
        milliseconds > 16.6 ? LogLevel.warning : LogLevel.debug;
    log('PERF: $operation took ${milliseconds.toStringAsFixed(2)}ms', level);
  }

  /// Start performance tracking for an operation
  static void startPerformanceTracking(String operation) {
    if (!_debugMode) return;

    _performanceTrackers[operation] = PerformanceTracker(
      name: operation,
      startTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// End performance tracking and log results
  static void endPerformanceTracking(String operation) {
    if (!_debugMode) return;

    final PerformanceTracker? tracker = _performanceTrackers[operation];
    if (tracker != null) {
      final int endTime = DateTime.now().millisecondsSinceEpoch;
      final int duration = endTime - tracker.startTime;

      tracker.samples.add(duration.toDouble());
      if (tracker.samples.length > 100) {
        tracker.samples.removeAt(0);
      }
      if (_logPerformance) {
        logPerformanceMetrics(operation, duration.toDouble());
      }

      _performanceTrackers.remove(operation);
    }
  }

  /// Get performance statistics for an operation
  static PerformanceStats? getPerformanceStats(String operation) {
    final PerformanceTracker? tracker = _performanceTrackers[operation];
    if (tracker == null || tracker.samples.isEmpty) return null;

    final List<double> samples = tracker.samples;
    samples.sort();

    final double sum = samples.reduce((double a, double b) => a + b);
    final double average = sum / samples.length;
    final double median = samples[samples.length ~/ 2];
    final double min = samples.first;
    final double max = samples.last;

    return PerformanceStats(
      operation: operation,
      average: average,
      median: median,
      min: min,
      max: max,
      sampleCount: samples.length,
    );
  }

  /// Update frame rate tracking
  static void updateFrameRate(double deltaTime) {
    if (!_debugMode) return;

    _frameTimes.add(deltaTime * 1000); // Convert to milliseconds
    if (_frameTimes.length > _maxFrameSamples) {
      _frameTimes.removeAt(0);
    }
  }

  /// Get current FPS
  static double getCurrentFPS() {
    if (_frameTimes.isEmpty) return 0;

    final double averageFrameTime =
        _frameTimes.reduce((double a, double b) => a + b) / _frameTimes.length;
    return 1000.0 / averageFrameTime; // Convert from ms to FPS
  }

  /// Draw debug information on screen
  static void drawDebugInfo(Canvas canvas, Size screenSize, Camera camera) {
    if (!_debugMode) return;

    double yOffset = 10;
    const double lineHeight = 20;

    // Draw FPS
    if (_showFPS) {
      final double fps = getCurrentFPS();
      final Color fpsColor = fps >= 55
          ? performanceGoodColor
          : fps >= 30
              ? performanceWarningColor
              : performanceBadColor;

      _drawDebugText(
        canvas,
        'FPS: ${fps.toStringAsFixed(1)}',
        10,
        yOffset,
        fpsColor,
      );
      yOffset += lineHeight;
    }

    // Draw entity count
    if (_showEntityCount) {
      // This would need to be passed in from the game world
      _drawDebugText(canvas, 'Entities: N/A', 10, yOffset, debugTextColor);
      yOffset += lineHeight;
    }

    // Draw camera info
    _drawDebugText(
      canvas,
      'Camera: (${camera.position.x.toStringAsFixed(1)}, ${camera.position.y.toStringAsFixed(1)})',
      10,
      yOffset,
      debugTextColor,
    );
    yOffset += lineHeight;

    // Draw memory usage (simplified)
    if (_logPerformance) {
      _drawDebugText(
        canvas,
        'Debug Log: ${_debugLog.length} entries',
        10,
        yOffset,
        debugTextColor,
      );
      yOffset += lineHeight;
    }
  }

  /// Draw collision boxes for an entity
  static void drawCollisionBox(
    Canvas canvas,
    Vector2 position,
    Vector2 size, [
    Color? color,
  ]) {
    if (!_debugMode || !_showCollisionBoxes) return;

    final Paint paint = Paint()
      ..color = color ?? collisionBoxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Rect rect = Rect.fromLTWH(position.x, position.y, size.x, size.y);
    canvas.drawRect(rect, paint);
  }

  /// Draw velocity vector for an entity
  static void drawVelocityVector(
    Canvas canvas,
    Vector2 position,
    Vector2 velocity, [
    Color? color,
  ]) {
    if (!_debugMode || !_showVelocityVectors) return;

    if (velocity.length < 0.1) return; // Don't draw very small vectors

    final Paint paint = Paint()
      ..color = color ?? velocityVectorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Offset start = Offset(position.x, position.y);
    final Offset end = Offset(position.x + velocity.x, position.y + velocity.y);

    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    const double arrowLength = 8;
    const double arrowAngle = 0.5;
    final double angle = velocity.angleTo(Vector2(1, 0));

    final Offset arrowPoint1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );

    final Offset arrowPoint2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    canvas.drawLine(end, arrowPoint1, paint);
    canvas.drawLine(end, arrowPoint2, paint);
  }

  /// Draw debug text
  static void _drawDebugText(
    Canvas canvas,
    String text,
    double x,
    double y,
    Color color,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  /// Save debug log to file
  static Future<void> saveDebugLog([String? filename]) async {
    if (_debugLog.isEmpty) return;

    try {
      final String timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final String fileName = filename ?? 'debug_log_$timestamp.txt';

      // In a real implementation, you'd use proper file I/O
      // For now, just log that we would save
      log(
        'Would save ${_debugLog.length} log entries to $fileName',
        LogLevel.info,
      );
    } on FileSystemException catch (e) {
      final GameException fileError = e.path != null
          ? FileException('Cannot write to file', e.path!, 'write', cause: e)
          : DebugLogException('Cannot write to log file', cause: e);

      logError('Failed to save debug log - file system error', fileError);
    } on FormatException catch (e) {
      final DebugLogException formatError = DebugLogException(
        'Invalid format in debug log content',
        context: e.message,
        cause: e,
      );

      logError('Failed to save debug log - format error', formatError);
    } catch (e) {
      final DebugLogException unknownError = DebugLogException(
        'Unexpected error saving debug log',
        context: e.toString(),
      );

      logError('Failed to save debug log', unknownError);
    }
  }

  /// Clear debug log
  static void clearDebugLog() {
    _debugLog.clear();
    log('Debug log cleared', LogLevel.info);
  }

  /// Get debug log entries
  static List<String> getDebugLog([int? maxEntries]) {
    if (maxEntries == null) return List.from(_debugLog);

    final int startIndex = math.max(0, _debugLog.length - maxEntries);
    return _debugLog.sublist(startIndex);
  }

  /// Assert a condition in debug mode
  static void debugAssert(bool condition, String message) {
    if (!_debugMode) return;

    if (!condition) {
      final DebugAssertionException exception =
          DebugAssertionException(message, context: 'debugAssert');
      logError('ASSERTION FAILED: $message', exception);

      if (kDebugMode) {
        throw exception;
      }
    }
  }

  /// Dump object state for debugging
  static void dumpObject(String name, Object object) {
    if (!_debugMode || !_verboseLogging) return;

    log('DUMP $name: $object');
  }

  /// Create a debug checkpoint
  static void checkpoint(String name) {
    if (!_debugMode) return;

    log('CHECKPOINT: $name');
  }

  /// Time a function execution
  static T timeFunction<T>(String name, T Function() function) {
    if (!_debugMode) return function();

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      final result = function();
      stopwatch.stop();
      logPerformanceMetrics(name, stopwatch.elapsedMicroseconds / 1000.0);
      return result;
    } on Error catch (e) {
      stopwatch.stop();
      final PerformanceTrackingException exception =
          PerformanceTrackingException(
        name,
        'Error',
        context: e.toString(),
      );
      logError('Error during timed function execution: $name', exception);
      rethrow;
    } catch (e) {
      stopwatch.stop();
      final PerformanceTrackingException exception =
          PerformanceTrackingException(
        name,
        'Exception',
        context: e.toString(),
      );
      logError('Exception during timed function execution: $name', exception);
      rethrow;
    }
  }

  // Getters and setters for debug flags
  static bool get debugMode => _debugMode;
  static bool get showCollisionBoxes => _showCollisionBoxes;
  static bool get showVelocityVectors => _showVelocityVectors;
  static bool get showFPS => _showFPS;
  static bool get showEntityCount => _showEntityCount;
  static bool get logPerformance => _logPerformance;
  static bool get verboseLogging => _verboseLogging;

  static set debugMode(bool value) => _debugMode = value;
  static set showCollisionBoxes(bool value) => _showCollisionBoxes = value;
  static set showVelocityVectors(bool value) => _showVelocityVectors = value;
  static set showFPS(bool value) => _showFPS = value;
  static set showEntityCount(bool value) => _showEntityCount = value;
  static set logPerformance(bool value) => _logPerformance = value;
  static set verboseLogging(bool value) => _verboseLogging = value;
}

/// Log levels for debug messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Performance tracker for operations
class PerformanceTracker {
  PerformanceTracker({
    required this.name,
    required this.startTime,
  });
  final String name;
  final int startTime;
  final List<double> samples = <double>[];
}

/// Performance statistics for an operation
class PerformanceStats {
  PerformanceStats({
    required this.operation,
    required this.average,
    required this.median,
    required this.min,
    required this.max,
    required this.sampleCount,
  });
  final String operation;
  final double average;
  final double median;
  final double min;
  final double max;
  final int sampleCount;

  @override
  String toString() {
    return 'PerformanceStats($operation: avg=${average.toStringAsFixed(2)}ms, '
        'med=${median.toStringAsFixed(2)}ms, '
        'min=${min.toStringAsFixed(2)}ms, '
        'max=${max.toStringAsFixed(2)}ms, '
        'samples=$sampleCount)';
  }
}

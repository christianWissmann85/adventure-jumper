import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'debug_config.dart';
import 'logger.dart';

/// Debug Console for Adventure Jumper
///
/// This class implements an in-game debug console that can be shown
/// during development to display log messages and allow executing commands.
class DebugConsole {
  // Private constructor to prevent instantiation
  DebugConsole._();

  static final Logger _logger = GameLogger.getLogger('DebugConsole');
  static final Queue<LogEntry> _logEntries = Queue<LogEntry>();
  static const int _maxEntries = 100;

  static bool _isVisible = false;
  static final List<String> _commandHistory = <String>[];
  static final Map<String, CommandHandler> _commands =
      <String, CommandHandler>{};

  /// Check if console is visible
  static bool get isVisible => _isVisible;

  /// Get log entries for display
  static List<LogEntry> get entries => _logEntries.toList();

  /// Initialize debug console
  static void initialize() {
    if (!DebugConfig.enableConsoleCommands) return;

    _logger.info('Debug console initialized');
    _registerCommands();

    // Listen to log entries
    Logger.root.onRecord.listen(_addLogRecord);
  }

  /// Show/hide console
  static void toggleVisibility() {
    _isVisible = !_isVisible;
    _logger.fine('Console visibility: $_isVisible');
  }

  /// Add a log record to console
  static void _addLogRecord(LogRecord record) {
    final LogEntry entry = LogEntry(
      message: record.message,
      level: record.level,
      source: record.loggerName,
      timestamp: record.time,
    );

    _logEntries.add(entry);
    if (_logEntries.length > _maxEntries) {
      _logEntries.removeFirst();
    }
  }

  /// Process a command
  static String executeCommand(String commandText) {
    if (commandText.trim().isEmpty) return '';

    _commandHistory.add(commandText);

    // Parse command and arguments
    final List<String> parts = commandText.trim().split(' ');
    final String command = parts[0].toLowerCase();
    final List<String> args = parts.length > 1 ? parts.sublist(1) : [];

    // Execute command
    if (_commands.containsKey(command)) {
      try {
        return _commands[command]!(args);
      } catch (e) {
        _logger.warning('Error executing command: $e');
        return 'Error: $e';
      }
    } else {
      return 'Unknown command: $command. Type "help" for available commands.';
    }
  }

  /// Register built-in commands
  static void _registerCommands() {
    // Help command
    _commands['help'] = (args) {
      String result = 'Available commands:';
      for (final String cmd in _commands.keys.toList()..sort()) {
        result += '\n  $cmd';
      }
      return result;
    };

    // Echo command
    _commands['echo'] = (args) {
      return args.join(' ');
    };

    // Clear console command
    _commands['clear'] = (args) {
      _logEntries.clear();
      return 'Console cleared';
    };

    // Debug flags command
    _commands['debug'] = (args) {
      if (args.isEmpty) {
        return 'Usage: debug [feature] [on|off]';
      }

      final String feature = args[0].toLowerCase();

      try {
        if (args.length == 1) {
          // Show status
          switch (feature) {
            case 'fps':
              return 'FPS display: ${DebugConfig.showFPS ? "on" : "off"}';
            case 'collision':
              return 'Collision boxes: ${DebugConfig.showCollisionBoxes ? "on" : "off"}';
            case 'vectors':
              return 'Velocity vectors: ${DebugConfig.showVelocityVectors ? "on" : "off"}';
            case 'memory':
              return 'Memory usage: ${DebugConfig.showMemoryUsage ? "on" : "off"}';
            case 'verbose':
              return 'Verbose logging: ${DebugConfig.verbose ? "on" : "off"}';
            case 'all':
              return 'Debug features:\n'
                  '  FPS: ${DebugConfig.showFPS ? "on" : "off"}\n'
                  '  Collision: ${DebugConfig.showCollisionBoxes ? "on" : "off"}\n'
                  '  Vectors: ${DebugConfig.showVelocityVectors ? "on" : "off"}\n'
                  '  Memory: ${DebugConfig.showMemoryUsage ? "on" : "off"}\n'
                  '  Verbose: ${DebugConfig.verbose ? "on" : "off"}';
            default:
              return 'Unknown feature: $feature';
          }
        } else {
          // Set status
          final bool enable =
              args[1].toLowerCase() == 'on' || args[1].toLowerCase() == 'true';

          switch (feature) {
            case 'fps':
              DebugConfig.showFPS = enable;
              return 'FPS display ${enable ? "enabled" : "disabled"}';
            case 'collision':
              DebugConfig.showCollisionBoxes = enable;
              return 'Collision boxes ${enable ? "enabled" : "disabled"}';
            case 'vectors':
              DebugConfig.showVelocityVectors = enable;
              return 'Velocity vectors ${enable ? "enabled" : "disabled"}';
            case 'memory':
              DebugConfig.showMemoryUsage = enable;
              return 'Memory usage ${enable ? "enabled" : "disabled"}';
            case 'verbose':
              DebugConfig.verbose = enable;
              Logger.root.level = enable ? Level.ALL : Level.INFO;
              return 'Verbose logging ${enable ? "enabled" : "disabled"}';
            case 'all':
              DebugConfig.showFPS = enable;
              DebugConfig.showCollisionBoxes = enable;
              DebugConfig.showVelocityVectors = enable;
              DebugConfig.showMemoryUsage = enable;
              DebugConfig.verbose = enable;
              Logger.root.level = enable ? Level.ALL : Level.INFO;
              return 'All debug features ${enable ? "enabled" : "disabled"}';
            default:
              return 'Unknown feature: $feature';
          }
        }
      } catch (e) {
        return 'Error: $e';
      }
    };

    // Performance command
    _commands['perf'] = (args) {
      if (args.isEmpty) {
        return 'Usage: perf [start|stop|status] [name]';
      }

      final String action = args[0].toLowerCase();

      switch (action) {
        case 'start':
          return 'Performance monitoring not yet implemented';
        case 'stop':
          return 'Performance monitoring not yet implemented';
        case 'status':
          return 'Performance monitoring not yet implemented';
        default:
          return 'Unknown perf action: $action';
      }
    };
  }
}

/// Handler for console commands
typedef CommandHandler = String Function(List<String> args);

/// Entry in the console log
class LogEntry {
  final String message;
  final Level level;
  final String source;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    required this.source,
    required this.timestamp,
  });
  Color get color => switch (level) {
        Level.SEVERE => Colors.red,
        Level.WARNING => Colors.yellow,
        Level.INFO => Colors.white,
        Level.FINE => Colors.grey,
        _ => Colors.grey.withAlpha(179), // 0.7 opacity: 0.7 * 255 ≈ 179
      };

  @override
  String toString() {
    final String time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    return '[$time] [$source] ${level.name}: $message';
  }
}

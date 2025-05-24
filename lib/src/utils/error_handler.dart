import 'dart:developer' as developer;
import 'dart:io';

import 'exceptions.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug(0),
  info(800),
  warning(900),
  error(1000),
  critical(1200);

  const LogLevel(this.value);
  final int value;
}

/// Centralized error handling and logging utility
///
/// This class provides consistent error handling patterns and logging
/// throughout the Adventure Jumper game.
class ErrorHandler {
  static const String _logName = 'AdventureJumper';

  /// Log an error with appropriate context
  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
    LogLevel level = LogLevel.error,
  }) {
    final String logMessage = _formatLogMessage(message, context, error);

    developer.log(
      logMessage,
      name: _logName,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );

    // In development, also print to console for easier debugging
    print('[$_logName] ${level.name.toUpperCase()}: $logMessage');
    if (error != null) {
      print('Error details: $error');
    }
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  /// Log info messages
  static void logInfo(String message, {String? context}) {
    logError(message, context: context, level: LogLevel.info);
  }

  /// Log debug messages
  static void logDebug(String message, {String? context}) {
    logError(message, context: context, level: LogLevel.debug);
  }

  /// Log warning messages
  static void logWarning(String message, {Object? error, String? context}) {
    logError(message, error: error, context: context, level: LogLevel.warning);
  }

  /// Log critical errors
  static void logCritical(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
  }) {
    logError(
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
      level: LogLevel.critical,
    );
  }

  /// Handle asset loading errors with recovery
  static Future<T?> handleAssetError<T>(
    Future<T> Function() operation,
    String assetPath,
    String assetType, {
    T? fallback,
    String? context,
  }) async {
    try {
      return await operation();
    } on AssetLoadingException catch (e) {
      logError(
        'Asset loading failed: ${e.message}',
        error: e,
        context: context ?? 'AssetManager',
      );
      return fallback;
    } on FormatException catch (e) {
      logError(
        'Asset format error for $assetPath',
        error: AssetCorruptedException(assetPath, assetType, context: e.message),
        context: context ?? 'AssetManager',
      );
      return fallback;
    } catch (e, stackTrace) {
      logError(
        'Unexpected asset loading error for $assetPath',
        error: AssetLoadingException(e.toString(), assetPath, assetType),
        stackTrace: stackTrace,
        context: context ?? 'AssetManager',
      );
      return fallback;
    }
  }

  /// Handle save/load operations with proper error categorization
  static Future<T?> handleSaveError<T>(
    Future<T> Function() operation,
    String operationType, {
    T? fallback,
    String? context,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } on FormatException catch (e) {
      final SaveFileCorruptedException exception = SaveFileCorruptedException(context: e.message);
      logError(
        'Save file corruption detected during $operationType',
        error: exception,
        context: context ?? 'SaveManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    } on FileSystemException catch (e) {
      SaveDataException exception;
      if (e.osError?.errorCode == 2) {
        // File not found
        exception = SaveFileNotFoundException(context: e.message);
      } else if (e.osError?.errorCode == 13) {
        // Permission denied
        exception = SavePermissionException(operationType, context: e.message);
      } else {
        exception = SaveDataException(e.message, operationType, context: e.path);
      }
      logError(
        'File system error during $operationType',
        error: exception,
        context: context ?? 'SaveManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    } catch (e, stackTrace) {
      final SaveDataException exception = SaveDataException(e.toString(), operationType);
      logError(
        'Unexpected save/load error during $operationType',
        error: exception,
        stackTrace: stackTrace,
        context: context ?? 'SaveManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    }
  }

  /// Handle audio errors with appropriate fallbacks
  static Future<T?> handleAudioError<T>(
    Future<T> Function() operation,
    String audioFile,
    String operationType, {
    T? fallback,
    String? context,
  }) async {
    try {
      return await operation();
    } on FileSystemException {
      logError(
        'Audio file not found: $audioFile',
        error: AudioFileNotFoundException(audioFile),
        context: context ?? 'AudioManager',
      );
      return fallback;
    } on FormatException catch (e) {
      logError(
        'Audio format error for $audioFile',
        error: AudioException(e.message, audioFile, operationType),
        context: context ?? 'AudioManager',
      );
      return fallback;
    } catch (e, stackTrace) {
      logError(
        'Audio playback error for $audioFile during $operationType',
        error: AudioPlaybackException(
          audioFile,
          operationType,
          context: e.toString(),
        ),
        stackTrace: stackTrace,
        context: context ?? 'AudioManager',
      );
      return fallback;
    }
  }

  /// Handle level loading errors with proper categorization
  static Future<T?> handleLevelError<T>(
    Future<T> Function() operation,
    String levelId, {
    T? fallback,
    String? context,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } on FormatException catch (e) {
      final LevelDataCorruptedException exception = LevelDataCorruptedException(levelId, context: e.message);
      logError(
        'Level data corruption detected for $levelId',
        error: exception,
        context: context ?? 'LevelManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    } on FileSystemException {
      final LevelNotFoundException exception = LevelNotFoundException(levelId);
      logError(
        'Level file not found: $levelId',
        error: exception,
        context: context ?? 'LevelManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    } catch (e, stackTrace) {
      final LevelException exception = LevelException(e.toString(), levelId, 'load');
      logError(
        'Unexpected level loading error for $levelId',
        error: exception,
        stackTrace: stackTrace,
        context: context ?? 'LevelManager',
      );
      if (shouldRethrow) throw exception;
      return fallback;
    }
  }

  /// Format log messages consistently
  static String _formatLogMessage(
    String message,
    String? context,
    Object? error,
  ) {
    final StringBuffer buffer = StringBuffer(message);
    if (context != null) {
      buffer.write(' [Context: $context]');
    }
    return buffer.toString();
  }

  /// Extract meaningful error descriptions from exceptions
  static String getErrorDescription(Object error) {
    if (error is GameException) {
      return error.message;
    }
    if (error is FormatException) {
      return 'Data format error: ${error.message}';
    }
    if (error is FileSystemException) {
      return 'File system error: ${error.message}';
    }
    if (error is ArgumentError) {
      return 'Invalid argument: ${error.message}';
    }
    if (error is StateError) {
      return 'Invalid state: ${error.message}';
    }
    return error.toString();
  }

  /// Handle file operations with proper error categorization
  static Future<T?> handleFileError<T>(
    Future<T> Function() operation,
    String filePath,
    String operationType, {
    T? fallback,
    String? context,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } on FileSystemException catch (e) {
      FileException exception;

      // Map OS error codes to specific exceptions
      if (e.osError?.errorCode == 2) {
        // File not found
        exception = FileNotFoundException(filePath, context: e.message);
      } else if (e.osError?.errorCode == 13) {
        // Permission denied
        exception = FileAccessException(filePath, operationType, context: e.message);
      } else if (e.osError?.errorCode == 17) {
        // File already exists
        exception = FileAlreadyExistsException(filePath, context: e.message);
      } else {
        // Other file system errors
        exception = FileException(
          e.message,
          filePath,
          operationType,
          context: context,
          cause: e,
        );
      }

      logError(
        'File operation error during $operationType: ${e.message}',
        error: exception,
        context: context ?? 'FileUtils',
      );

      if (shouldRethrow) throw exception;
      return fallback;
    } on FormatException catch (e) {
      final JsonParseException exception = JsonParseException(
        'Invalid file format',
        filePath,
        context: e.message,
      );

      logError(
        'File format error during $operationType of $filePath',
        error: exception,
        context: context ?? 'FileUtils',
      );

      if (shouldRethrow) throw exception;
      return fallback;
    } catch (e, stackTrace) {
      final FileException exception = FileException(
        e.toString(),
        filePath,
        operationType,
        context: context,
      );

      logError(
        'Unexpected error during $operationType of $filePath',
        error: exception,
        stackTrace: stackTrace,
        context: context ?? 'FileUtils',
      );

      if (shouldRethrow) throw exception;
      return fallback;
    }
  }
}

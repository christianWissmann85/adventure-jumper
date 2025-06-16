import 'dart:convert';
import 'dart:io';

import 'error_handler.dart';
import 'error_handling_mode.dart';
import 'exceptions.dart';

/// Helper class for converting general file I/O exceptions to specific typed exceptions
class FileExceptionHandler {
  FileExceptionHandler._(); // Private constructor to prevent instantiation

  /// Convert FileSystemException to specific FileException type
  static FileException convertFileSystemException(
    FileSystemException e,
    String filePath,
    String operation,
  ) {
    // Map common OS error codes to specific exception types
    if (e.osError?.errorCode == 2) {
      // File/directory not found
      return FileNotFoundException(filePath, context: e.message);
    } else if (e.osError?.errorCode == 13) {
      // Permission denied
      return FileAccessException(filePath, operation, context: e.message);
    } else if (e.osError?.errorCode == 17) {
      // File already exists
      return FileAlreadyExistsException(filePath, context: e.message);
    } else {
      // Generic file system error
      return FileException(e.message, filePath, operation, cause: e);
    }
  }

  /// Handle FormatException for file parsing (especially JSON)
  static GameException convertFormatException(
    FormatException e,
    String filePath,
    String contentType,
  ) {
    if (contentType == 'json') {
      return JsonParseException(
        'Invalid JSON format',
        filePath,
        context: e.message,
      );
    } else {
      return FileException(
        'Invalid file format: ${e.message}',
        filePath,
        'parse',
        context: contentType,
      );
    }
  }

  /// Wrap file operations with proper exception handling and reporting
  static Future<T?> handleOperation<T>(
    Future<T> Function() operation,
    String filePath,
    String operationType, {
    T? fallback,
    String? context,
    String? contentType,
    bool shouldRethrow = false,
    bool logError = true,
    ErrorHandlingMode? errorHandling,
  }) async {
    // If errorHandling enum is provided, it overrides shouldRethrow
    if (errorHandling != null) {
      shouldRethrow = errorHandling == ErrorHandlingMode.rethrowAfterLogging;
    }
    try {
      return await operation();
    } on FileSystemException catch (e) {
      final FileException exception = convertFileSystemException(
        e,
        filePath,
        operationType,
      );

      if (logError) {
        ErrorHandler.logError(
          'File operation error during $operationType: ${e.message}',
          error: exception,
          context: context ?? 'FileOperation',
        );
      }

      if (shouldRethrow) throw exception;
      return fallback;
    } on FormatException catch (e) {
      final GameException exception = convertFormatException(
        e,
        filePath,
        contentType ?? 'unknown',
      );

      if (logError) {
        ErrorHandler.logError(
          'File format error during $operationType of $filePath',
          error: exception,
          context: context ?? 'FileOperation',
        );
      }
      if (shouldRethrow) throw exception;
      return fallback;
    } on Exception catch (e, stackTrace) {
      final FileException exception = FileException(
        e.toString(),
        filePath,
        operationType,
        context: context,
      );

      if (logError) {
        ErrorHandler.logError(
          'Unexpected error during $operationType of $filePath',
          error: exception,
          stackTrace: stackTrace,
          context: context ?? 'FileOperation',
        );
      }

      if (shouldRethrow) throw exception;
      return fallback;
    }
  }

  /// Helper for JSON parsing operations
  static Future<Map<String, dynamic>?> parseJsonFile(
    String filePath,
    String fileContent, {
    bool shouldRethrow = false,
    String? context,
    ErrorHandlingMode? errorHandling,
  }) async {
    // If errorHandling enum is provided, it overrides shouldRethrow
    if (errorHandling != null) {
      shouldRethrow = errorHandling == ErrorHandlingMode.rethrowAfterLogging;
    }

    return handleOperation<Map<String, dynamic>>(
      () async {
        try {
          final dynamic decodedJson = json.decode(fileContent);
          if (decodedJson is Map<String, dynamic>) {
            return decodedJson;
          } else {
            throw FormatException(
              'Expected JSON object but got ${decodedJson.runtimeType}',
              fileContent,
            );
          }
        } on FormatException catch (e) {
          throw JsonParseException(
            'Invalid JSON format',
            filePath,
            context: e.message,
          );
        }
      },
      filePath,
      'parse',
      contentType: 'json',
      shouldRethrow: shouldRethrow,
      context: context ?? 'JsonParser',
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'error_handling_mode.dart';
import 'exceptions.dart';
import 'file_exception_handler.dart';

/// File utilities with specific exception handling
///
/// This utility class provides functions with enhanced exception handling
/// for file operations to replace generic catch clauses with specific
/// exception types.
class FileUtils {
  // Private constructor to prevent instantiation
  FileUtils._();

  /// Read file as string with specific exception handling
  static Future<String?> readFileAsString(
    String filePath, {
    Encoding encoding = utf8,
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return FileExceptionHandler.handleOperation<String?>(
      () async {
        final File file = File(filePath);
        if (await file.exists()) {
          return file.readAsString(encoding: encoding);
        }
        throw FileNotFoundException(filePath);
      },
      filePath,
      'read',
      context: 'FileUtils.readFileAsString',
      shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
    );
  }

  /// Write string to file with specific exception handling
  static Future<bool> writeStringToFile(
    String filePath,
    String content, {
    Encoding encoding = utf8,
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return await FileExceptionHandler.handleOperation<bool>(
          () async {
            final File file = File(filePath);

            // Create directory if it doesn't exist
            final Directory directory = Directory(path.dirname(filePath));
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }

            await file.writeAsString(content, encoding: encoding);
            return true;
          },
          filePath,
          'write',
          fallback: false,
          context: 'FileUtils.writeStringToFile',
          shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
        ) ??
        false;
  }

  /// Read JSON file and parse with specific exception handling
  static Future<Map<String, dynamic>?> readJsonFile(
    String filePath, {
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    // First read the file
    final String? content = await readFileAsString(
      filePath,
      errorHandling: errorHandling,
    );
    if (content == null) return null;

    // Then parse with specific JSON exception handling
    return FileExceptionHandler.parseJsonFile(
      filePath,
      content,
      context: 'FileUtils.readJsonFile',
      shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
    );
  }

  /// Write object to JSON file with specific exception handling
  static Future<bool> writeJsonFile(
    String filePath,
    Map<String, dynamic> data, {
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return await FileExceptionHandler.handleOperation<bool>(
          () async {
            final String jsonString = json.encode(data);
            return writeStringToFile(filePath, jsonString,
                errorHandling: errorHandling,);
          },
          filePath,
          'write_json',
          fallback: false,
          context: 'FileUtils.writeJsonFile',
          contentType: 'json',
          shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
        ) ??
        false;
  }

  /// Copy file with specific exception handling
  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath, {
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return await FileExceptionHandler.handleOperation<bool>(
          () async {
            final File sourceFile = File(sourcePath);

            // Check if source exists
            if (!await sourceFile.exists()) {
              throw FileNotFoundException(sourcePath);
            }

            // Create destination directory if needed
            final Directory destDir = Directory(path.dirname(destinationPath));
            if (!await destDir.exists()) {
              await destDir.create(recursive: true);
            }

            // Check if destination exists
            final File destFile = File(destinationPath);
            if (await destFile.exists()) {
              throw FileAlreadyExistsException(destinationPath);
            }

            await sourceFile.copy(destinationPath);
            return true;
          },
          '$sourcePath -> $destinationPath',
          'copy',
          fallback: false,
          context: 'FileUtils.copyFile',
          shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
        ) ??
        false;
  }

  /// Delete file with specific exception handling
  static Future<bool> deleteFile(
    String filePath, {
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return await FileExceptionHandler.handleOperation<bool>(
          () async {
            final File file = File(filePath);
            if (await file.exists()) {
              await file.delete();
              return true;
            }
            throw FileNotFoundException(filePath);
          },
          filePath,
          'delete',
          fallback: false,
          context: 'FileUtils.deleteFile',
          shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
        ) ??
        false;
  }

  /// List files in directory with specific exception handling
  static Future<List<String>> listFiles(
    String directoryPath, {
    List<String>? extensions,
    ErrorHandlingMode errorHandling =
        ErrorHandlingMode.suppressAndReturnFallback,
  }) async {
    return FileExceptionHandler.handleOperation<List<String>>(
      () async {
        final Directory directory = Directory(directoryPath);
        if (!await directory.exists()) {
          throw DirectoryNotFoundException(directoryPath);
        }

        final List<String> files = <String>[];
        await for (final FileSystemEntity entity in directory.list()) {
          if (entity is File) {
            final String filePath = entity.path;
            if (extensions == null ||
                extensions.any(
                  (String ext) =>
                      filePath.toLowerCase().endsWith(ext.toLowerCase()),
                )) {
              files.add(filePath);
            }
          }
        }
        return files;
      },
      directoryPath,
      'list',
      fallback: <String>[],
      context: 'FileUtils.listFiles',
      shouldRethrow: errorHandling == ErrorHandlingMode.rethrowAfterLogging,
    ).then((List<String>? result) => result ?? <String>[]);
  }

  /// Format a file-related error message with context
  static String formatErrorMessage(
    String operation,
    String path,
    String errorMessage,
  ) {
    return 'Error during $operation on "$path": $errorMessage';
  }
}

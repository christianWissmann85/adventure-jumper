/// Custom exception types for Adventure Jumper game
///
/// This file defines specific exception types to improve error handling
/// throughout the codebase, replacing generic catch clauses with
/// targeted exception handling.
library;

/// Base class for all game-specific exceptions
abstract class GameException implements Exception {
  const GameException(this.message, {this.context, this.cause});
  final String message;
  final String? context;
  final Exception? cause;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('$runtimeType: $message');
    if (context != null) {
      buffer.write(' (Context: $context)');
    }
    if (cause != null) {
      buffer.write(' (Caused by: $cause)');
    }
    return buffer.toString();
  }
}

/// Asset-related exceptions
class AssetLoadingException extends GameException {
  const AssetLoadingException(
    super.message,
    this.assetPath,
    this.assetType, {
    super.context,
    super.cause,
  });
  final String assetPath;
  final String assetType;
}

class AssetNotFoundException extends AssetLoadingException {
  const AssetNotFoundException(String assetPath, String assetType) : super('Asset not found', assetPath, assetType);
}

class AssetCorruptedException extends AssetLoadingException {
  const AssetCorruptedException(
    String assetPath,
    String assetType, {
    String? context,
  }) : super(
          'Asset file is corrupted or invalid',
          assetPath,
          assetType,
          context: context,
        );
}

/// Save/Load exceptions
class SaveDataException extends GameException {
  // 'save', 'load', 'delete', etc.

  const SaveDataException(
    super.message,
    this.operation, {
    super.context,
    super.cause,
  });
  final String operation;
}

class SaveFileCorruptedException extends SaveDataException {
  const SaveFileCorruptedException({String? context})
      : super('Save file is corrupted or unreadable', 'load', context: context);
}

class SaveFileNotFoundException extends SaveDataException {
  const SaveFileNotFoundException({String? context}) : super('Save file not found', 'load', context: context);
}

class SavePermissionException extends SaveDataException {
  const SavePermissionException(String operation, {String? context})
      : super(
          'Insufficient permissions for save operation',
          operation,
          context: context,
        );
}

/// Audio-related exceptions
class AudioException extends GameException {
  // 'play', 'pause', 'load', etc.

  const AudioException(
    super.message,
    this.audioFile,
    this.operation, {
    super.context,
    super.cause,
  });
  final String audioFile;
  final String operation;
}

class AudioFileNotFoundException extends AudioException {
  const AudioFileNotFoundException(String audioFile) : super('Audio file not found', audioFile, 'load');
}

class AudioPlaybackException extends AudioException {
  const AudioPlaybackException(
    String audioFile,
    String operation, {
    String? context,
  }) : super('Audio playback failed', audioFile, operation, context: context);
}

/// Level/World loading exceptions
class LevelException extends GameException {
  const LevelException(
    super.message,
    this.levelId,
    this.operation, {
    super.context,
    super.cause,
  });
  final String levelId;
  final String operation;
}

class LevelNotFoundException extends LevelException {
  const LevelNotFoundException(String levelId) : super('Level not found', levelId, 'load');
}

class LevelDataCorruptedException extends LevelException {
  const LevelDataCorruptedException(String levelId, {String? context})
      : super(
          'Level data is corrupted or invalid',
          levelId,
          'load',
          context: context,
        );
}

/// Input/Control exceptions
class InputException extends GameException {
  const InputException(
    super.message,
    this.inputSource, {
    super.context,
    super.cause,
  });
  final String inputSource;
}

/// Configuration exceptions
class ConfigurationException extends GameException {
  const ConfigurationException(
    super.message,
    this.configKey, {
    super.context,
    super.cause,
  });
  final String configKey;
}

/// Animation/Graphics exceptions
class GraphicsException extends GameException {
  const GraphicsException(
    super.message,
    this.component, {
    super.context,
    super.cause,
  });
  final String component;
}

/// Validation exceptions
class ValidationException extends GameException {
  const ValidationException(
    super.message,
    this.field, {
    super.context,
    super.cause,
  });
  final String field;
}

/// File operation exceptions
class FileException extends GameException {
  const FileException(
    super.message,
    this.filePath,
    this.operation, {
    super.context,
    super.cause,
  });
  final String filePath;
  final String operation; // 'read', 'write', 'copy', 'move', 'delete', etc.
}

class FileNotFoundException extends FileException {
  const FileNotFoundException(String filePath, {String? context})
      : super('File not found', filePath, 'read', context: context);
}

class FileAccessException extends FileException {
  const FileAccessException(
    String filePath,
    String operation, {
    String? context,
  }) : super('File access denied', filePath, operation, context: context);
}

class FileAlreadyExistsException extends FileException {
  const FileAlreadyExistsException(String filePath, {String? context})
      : super('File already exists', filePath, 'write', context: context);
}

class DirectoryException extends FileException {
  const DirectoryException(
    super.message,
    super.directoryPath,
    super.operation, {
    super.context,
    super.cause,
  });
}

class DirectoryNotFoundException extends DirectoryException {
  const DirectoryNotFoundException(String directoryPath, {String? context})
      : super(
          'Directory not found',
          directoryPath,
          'access',
          context: context,
        );
}

class JsonParseException extends GameException {
  const JsonParseException(
    super.message,
    this.source, {
    super.context,
    super.cause,
  });
  final String source;
}

/// Debug-related exceptions
class DebugException extends GameException {
  const DebugException(
    super.message, {
    super.context,
    super.cause,
  });
}

class DebugAssertionException extends DebugException {
  const DebugAssertionException(
    String condition, {
    String? context,
  }) : super('Assertion failed: $condition', context: context);
}

class DebugLogException extends DebugException {
  const DebugLogException(
    super.message, {
    super.context,
    super.cause,
  });
}

class PerformanceTrackingException extends DebugException {
  const PerformanceTrackingException(
    String operation,
    String errorType, {
    String? context,
  }) : super(
          'Performance tracking error ($errorType) for $operation',
          context: context,
        );
}

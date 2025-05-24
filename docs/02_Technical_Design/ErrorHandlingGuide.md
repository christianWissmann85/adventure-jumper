# Error Handling Guide

## Overview

This document outlines the standard error handling practices for the Adventure Jumper project. Consistent error handling is essential for creating a robust, maintainable game that provides helpful feedback both to developers and players.

## Core Principles

1. **Specificity**: Use the most specific exception type possible rather than generic exceptions
2. **Recovery**: Provide recovery mechanisms when possible rather than failing completely
3. **Logging**: Use appropriate logging levels for different error scenarios
4. **User Experience**: Handle errors gracefully to avoid disrupting gameplay
5. **Debugging**: Include enough context to make debugging easier

## Exception Hierarchy

Our project uses a structured exception hierarchy defined in `lib/src/utils/exceptions.dart`:

```
GameException (base class)
├── AssetLoadingException
│   ├── AssetNotFoundException
│   └── AssetCorruptedException
├── SaveDataException
│   ├── SaveFileCorruptedException
│   ├── SaveFileNotFoundException
│   └── SavePermissionException
├── AudioException
│   ├── AudioFileNotFoundException
│   └── AudioPlaybackException
├── LevelException
│   ├── LevelNotFoundException
│   └── LevelDataCorruptedException
├── InputException
├── ConfigurationException
├── GraphicsException
├── ValidationException
├── FileException
│   ├── FileNotFoundException
│   ├── FileAccessException
│   ├── FileAlreadyExistsException
│   └── DirectoryException
│       └── DirectoryNotFoundException
├── JsonParseException
└── DebugException
    ├── DebugAssertionException
    ├── DebugLogException
    └── PerformanceTrackingException
```

## Standard Error Handling Patterns

### 1. Asset Loading

When loading assets (images, audio, level data), use this pattern:

```dart
try {
  final String jsonString = await rootBundle.loadString(filePath);
  
  try {
    final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
    // Process data...
    return processedData;
  } on FormatException catch (e) {
    // JSON parsing errors
    throw JsonParseException(
      'Invalid data format',
      filePath, 
      context: e.message,
    );
  } on TypeError catch (e) {
    // Type casting errors
    throw AssetCorruptedException(
      filePath,
      'asset_type',
      context: 'Invalid data structure: ${e.toString()}',
    );
  }
} on PlatformException {
  // Platform errors when accessing assets
  throw AssetNotFoundException(filePath, 'asset_type');
} catch (e) {
  throw AssetLoadingException(
    'Failed to load asset', 
    filePath,
    'asset_type',
    context: e.toString(),
  );
}
```

### 2. File Operations

For file operations, use the FileExceptionHandler utility:

```dart
try {
  final result = await FileExceptionHandler.handleOperation<ResultType>(
    () => /* file operation */,
    filePath,
    'read', // or 'write', 'delete', etc.
    context: 'ClassName.methodName',
    shouldRethrow: true,
  );
  return result;
} on FileNotFoundException catch (e) {
  // Handle specifically when a file is not found
} on FileException catch (e) {
  // Handle other file-related errors
}
```

### 3. Debug Assertions

For asserting conditions during development:

```dart
void someFunction(required Parameter param) {
  if (param == null) {
    throw DebugAssertionException(
      'Parameter cannot be null', 
      context: 'ClassName.someFunction',
    );
  }
  
  // or use the utility:
  DebugUtils.debugAssert(param != null, 'Parameter cannot be null');
  
  // Function implementation...
}
```

### 4. Error Logging

Use the appropriate ErrorHandler methods for consistent logging:

```dart
// For information
ErrorHandler.logInfo(
  'Operation completed successfully',
  context: 'ClassName.methodName',
);

// For warnings (non-fatal issues)
ErrorHandler.logWarning(
  'Resource might be missing',
  context: 'ClassName.methodName',
  error: exception, // optional
);

// For errors (significant issues)
ErrorHandler.logError(
  'Operation failed',
  context: 'ClassName.methodName',
  error: exception, // optional
);

// For critical errors (app might be unstable)
ErrorHandler.logCritical(
  'Unrecoverable error occurred',
  context: 'ClassName.methodName',
  error: exception, // optional
);
```

### 5. Recovery Strategies

When possible, provide fallback mechanisms:

```dart
Future<List<EnemyData>> loadEnemyData(String levelId) async {
  try {
    // Try loading enemies from file
    return await loadEnemiesFromFile(levelId);
  } catch (e) {
    // Log the error
    ErrorHandler.logWarning(
      'Could not load enemies, using empty list',
      error: e,
      context: 'EnemyLoader.loadEnemyData',
    );
    
    // Return empty list as fallback
    return <EnemyData>[];
  }
}
```

## Best Practices

1. **Don't Catch What You Can't Handle**: Only catch exceptions that you can meaningfully handle or recover from
2. **Keep the Stack Clean**: Re-throw exceptions when appropriate with additional context
3. **Be Specific**: Use specific exception types rather than generic ones
4. **Handle UI Gracefully**: Show appropriate user-friendly messages in the UI when errors occur
5. **Context is King**: Always include context in error messages and logs
6. **Don't Swallow Exceptions**: Avoid empty catch blocks that hide errors
7. **Write Defensive Code**: Validate inputs and preconditions to avoid errors in the first place

## Common Patterns by Module

### Asset Loading
- Use `AssetLoadingException` and its subtypes
- Provide fallbacks when possible

### Level Data
- Use `LevelException` and its subtypes
- Handle missing or corrupted data gracefully

### Save/Load Operations
- Use `SaveDataException` and its subtypes
- Always validate save data before using it
- Handle corruption scenarios with user-friendly recovery options

### Audio
- Use `AudioException` and its subtypes
- Provide fallbacks or silence when audio can't be played

### File Operations
- Use `FileException` and its subtypes
- Use the `FileExceptionHandler` utility for consistent handling

## Conclusion

Consistent error handling makes our codebase more maintainable and provides a better experience for both developers and players. When in doubt, err on the side of providing more context and more specific exception types.

Remember that the goal of error handling is not just to prevent crashes, but to:
1. Help developers quickly identify and fix issues
2. Provide a seamless experience for players even when things go wrong
3. Ensure the game can recover from unexpected conditions when possible

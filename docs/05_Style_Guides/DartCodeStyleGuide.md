# Adventure Jumper - Code Style Guide

This document outlines the code style guidelines for the Adventure Jumper project to maintain consistency across the codebase.

## Formatting

### Line Length
- Maximum line length is 120 characters.
- For readability, try to keep lines shorter when possible.

### Trailing Commas
- Always add trailing commas in parameter lists, collections, etc., when they span multiple lines.
- This improves version control diffs when items are added or removed.

```dart
// Good - with trailing comma
final List<String> items = [
  'item1',
  'item2',
  'item3',
];

// Good - with trailing comma in function parameters
void myFunction(
  String param1,
  int param2,
  {bool namedParam = false},
);

// Bad - no trailing comma
final List<String> items = [
  'item1',
  'item2',
  'item3'
];
```

### Indentation
- Use 2 spaces for indentation.
- Do not use tabs.

### Braces
- Opening braces go on the same line as the statement.
- Closing braces go on their own line.

```dart
if (condition) {
  // Code here
}
```

## Naming Conventions

### Classes and Types
- Use `UpperCamelCase` for class names, enums, typedefs, and type parameters.
- Example: `PlayerController`, `EntityType`

### Variables, Functions, and Parameters
- Use `lowerCamelCase` for variables, functions, and parameters.
- Example: `playerHealth`, `loadAsset()`

### Private Members
- Prefix private members with underscore.
- Example: `_privateVariable`, `_privateMethod()`

### Constants
- Use `lowerCamelCase` for constants.
- Example: `maxPlayerHealth`, `defaultGameSpeed`

## Documentation

### Comments
- Use `///` for documentation comments.
- Document all public APIs.
- Include parameter descriptions and return value descriptions where applicable.

```dart
/// Loads game assets from the specified directory.
/// 
/// [directory] is the path to the asset directory.
/// Returns a Future that completes when all assets are loaded.
Future<void> loadAssets(String directory) async {
  // Implementation
}
```

### TODO Comments
- Format TODOs with the assignee and issue number if applicable:
- Example: `// TODO(username): Fix collision detection (issue #123)`

## Best Practices

### Type Annotations
- Always specify types for public API declarations.
- Prefer explicit types for local variables when it improves readability.

### Final Variables
- Prefer `final` for variables that are not reassigned.
- Use `const` where possible for compile-time constants.

### Parameters
- Use named parameters for boolean flags.
- Use named parameters when a function has 3 or more parameters.

```dart
// Good
void configure({bool enableDebug = false, bool showTutorial = true});

// Bad
void configure(bool enableDebug, bool showTutorial);
```

### Extensions
- Place extension methods in separate files named after what they extend.
- Example: For `String` extensions, use `string_extensions.dart`

## Code Organization

### File Structure
- One class per file, with file name matching the class name in snake_case.
- Group related files in directories by feature, not by type.

### Import Order
- Dart SDK imports first
- Package imports second
- Relative imports last
- Separate each group with a blank line
- Sort alphabetically within each group

```dart
import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../components/health_component.dart';
import '../utils/math_utils.dart';
```

## Tools

Run the following tools regularly:
- `dart format -l 120 lib/` - Format all code files
- `flutter analyze` - Check for lint issues
- Follow the Flutter code style when working with widgets

## Enforcement

The project uses custom analyzer options to enforce most of these guidelines automatically. See `analysis_options.yaml` for details.

// Add trailing commas script for Adventure Jumper codebase
// This script scans Dart files and adds trailing commas to function calls, lists, maps, etc.
// Run with: dart scripts/add_trailing_commas.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final rootDir = Directory('lib');
  processDirectory(rootDir);
  print('Trailing commas added successfully!');
}

void processDirectory(Directory dir) {
  final entities = dir.listSync();

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      processFile(entity);
    } else if (entity is Directory) {
      processDirectory(entity);
    }
  }
}

void processFile(File file) {
  print('Processing ${file.path}...');
  final content = file.readAsStringSync();
  final lines = LineSplitter.split(content).toList();
  bool changed = false;

  for (int i = 0; i < lines.length - 1; i++) {
    final line = lines[i];
    final nextLine = lines[i + 1];

    // Check for function parameter lists, constructor parameters, lists, maps without trailing commas
    if ((line.contains('(') && !line.contains(')') && nextLine.trim() == ')') ||
        (line.contains('[') && !line.contains(']') && nextLine.trim() == ']') ||
        (line.contains('{') && !line.contains('}') && nextLine.trim() == '}')) {
      // If the line doesn't already end with a comma, add one
      if (!line.trim().endsWith(',')) {
        lines[i] = line + ',';
        changed = true;
      }
    }
  }

  if (changed) {
    final newContent = lines.join('\n');
    file.writeAsStringSync(newContent);
    print('  - Updated with trailing commas');
  }
}

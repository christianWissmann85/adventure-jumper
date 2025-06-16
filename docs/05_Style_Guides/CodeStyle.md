# Code Style Guide

This document outlines the coding standards and conventions for the Adventure Jumper project.

## General Principles

- Write clean, readable, and maintainable code
- Optimize for readability over cleverness
- Comment meaningfully, but let code speak for itself when possible
- Follow consistent naming and formatting conventions

## Dart/Flutter Coding Standards

### Formatting

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use 2-space indentation (no tabs)
- Maximum line length: 80 characters
- Use trailing commas for multi-line parameters/collections
- Run `dart format` before committing

### Naming Conventions

- Use `camelCase` for variables, functions, and method names
- Use `PascalCase` for classes, enums, and type names
- Use `SCREAMING_SNAKE_CASE` for constants and static final variables
- Use `_leadingUnderscore` for private members
- Use meaningful, descriptive names that explain purpose

```dart
// Good
class PlayerController {
  final double moveSpeed;
  static const int MAX_HEALTH = 100;
  
  void updatePosition(Vector2 direction) {
    // Implementation
  }
  
  void _recalculateStats() {
    // Private implementation
  }
}

// Bad
class PC {
  final double ms;
  static const int mh = 100;
  
  void update(Vector2 d) {
    // Implementation
  }
}
```

### File Organization

- One class per file (with rare exceptions for tightly coupled classes)
- Group related files in dedicated directories
- Keep test files next to source files with `_test.dart` suffix
- Organize imports in this order:
  1. Dart libraries
  2. Flutter packages
  3. Third-party packages
  4. Project imports
  5. Relative imports

```dart
// Good file organization
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'package:adventure_jumper/core/game_controller.dart';

import '../player/player_data.dart';
```

### Comments and Documentation

- Use `///` for documentation comments
- Document all public APIs
- Include parameter descriptions and return values
- Explain "why" more than "what" in implementation comments

```dart
/// Applies damage to the player and triggers appropriate effects.
///
/// [amount] The raw damage amount before defense calculation
/// [source] The entity that caused the damage
/// [damageType] The type of damage (physical, fire, etc.)
/// Returns `true` if damage was applied, `false` if blocked/invulnerable
bool applyDamage(double amount, Entity source, DamageType damageType) {
  // Implementation
}
```

## Game-Specific Code Standards

### Entity Component System (ECS)

- Components should have a single responsibility
- Systems should operate on component data, not modify other systems
- Avoid tight coupling between unrelated systems
- Use dependency injection for system dependencies

```dart
// Good Component Design
class HealthComponent extends Component {
  double maxHealth;
  double currentHealth;
  bool isInvulnerable = false;
  
  // Component logic
}

// Good System Design
class HealthSystem extends System {
  void update(double dt) {
    for (final entity in entities) {
      final health = entity.getComponent<HealthComponent>();
      // Process health logic
    }
  }
}
```

### Game Logic

- Keep game loop iterations efficient and focused
- Defer expensive operations when possible
- Use object pooling for frequently created/destroyed objects
- Decouple rendering from game logic

### Flutter Integration

- Separate UI state from game state
- Use Flutter widgets for menus and UI elements
- Handle platform-specific code with appropriate abstractions
- Follow Flutter's recommended state management patterns

## Performance Considerations

- Profile early and often
- Be mindful of garbage collection
- Cache expensive computations
- Use appropriate data structures for operations

## Testing

- Write unit tests for all game logic
- Aim for high test coverage of core systems
- Use mocks or test implementations for dependencies
- Test edge cases and failure scenarios

```dart
test('Player takes damage when hit', () {
  final player = Player();
  player.health = 100;
  
  player.takeDamage(25);
  
  expect(player.health, equals(75));
});
```

## Tooling

- Use the Dart analyzer with strict settings
- Configure and use linting rules consistently
- Set up CI/CD to enforce style and test coverage

## Related Documents

### External References
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/rendering/best-practices)
- [Flame Engine Documentation](https://flame-engine.org/docs)

### Project Documents
- [Implementation Guide](../03_Development_Process/ImplementationGuide.md) - How to implement features following these standards
- [Version Control](../03_Development_Process/VersionControl.md) - Git workflow and commit message standards
- [Testing Strategy](../03_Development_Process/TestingStrategy.md) - How to test code using these standards
- [Architecture](../02_Technical_Design/Architecture.md) - System design that guides code organization

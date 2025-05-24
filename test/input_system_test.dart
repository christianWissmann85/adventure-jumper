// Test file for input system functionality
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/src/player/player.dart';
import '../lib/src/systems/input_system.dart';

void main() {
  group('InputSystem Tests', () {
    late InputSystem inputSystem;
    late Player player;

    setUp(() {
      inputSystem = InputSystem();
      player = Player(position: Vector2(100, 100));
    });

    test('should register player with input system', () {
      inputSystem.setFocusedEntity(player);
      expect(inputSystem.focusedEntity, equals(player));
      expect(inputSystem.entityCount, equals(1));
    });

    test('should track movement keys correctly', () {
      // Simulate key press
      const keyEvent = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.arrowLeft,
        physicalKey: PhysicalKeyboardKey.arrowLeft,
        timeStamp: Duration.zero,
      );

      inputSystem.handleKeyEvent(keyEvent);
      expect(inputSystem.isMovementKeyPressed('move_left'), isTrue);

      // Simulate key release
      const keyUpEvent = KeyUpEvent(
        logicalKey: LogicalKeyboardKey.arrowLeft,
        physicalKey: PhysicalKeyboardKey.arrowLeft,
        timeStamp: Duration.zero,
      );

      inputSystem.handleKeyEvent(keyUpEvent);
      expect(inputSystem.isMovementKeyPressed('move_left'), isFalse);
    });

    test('should map keys to actions correctly', () {
      // Test all movement keys
      final testCases = {
        LogicalKeyboardKey.arrowLeft: 'move_left',
        LogicalKeyboardKey.keyA: 'move_left',
        LogicalKeyboardKey.arrowRight: 'move_right',
        LogicalKeyboardKey.keyD: 'move_right',
        LogicalKeyboardKey.space: 'jump',
        LogicalKeyboardKey.keyW: 'jump',
        LogicalKeyboardKey.arrowUp: 'jump',
      };

      for (final entry in testCases.entries) {
        final keyEvent = KeyDownEvent(
          logicalKey: entry.key,
          physicalKey: PhysicalKeyboardKey.space, // Dummy physical key
          timeStamp: Duration.zero,
        );

        inputSystem.handleKeyEvent(keyEvent);
        expect(inputSystem.isMovementKeyPressed(entry.value), isTrue,
            reason: 'Key ${entry.key} should map to action ${entry.value}');

        // Reset for next test
        final keyUpEvent = KeyUpEvent(
          logicalKey: entry.key,
          physicalKey: PhysicalKeyboardKey.space,
          timeStamp: Duration.zero,
        );
        inputSystem.handleKeyEvent(keyUpEvent);
      }
    });
  });
}

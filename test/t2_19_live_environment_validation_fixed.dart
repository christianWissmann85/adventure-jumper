// Test file for T2.19: Live Test Environment Validation - Fixed Version
import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.19: Live Test Environment Validation - Fixed', () {
    group('T2.19.1: Full Game Integration Test', () {
      testWithGame<AdventureJumperGame>(
        'Complete game initialization and basic functionality',
        AdventureJumperGame.new,
        (game) async {
          // Wait for game to fully initialize with longer timeout
          await game.ready();

          // Basic initialization checks
          expect(
            game.gameWorld,
            isNotNull,
            reason: 'GameWorld should be initialized',
          );
          expect(
            game.inputSystem,
            isNotNull,
            reason: 'InputSystem should be initialized',
          );
          expect(
            game.movementSystem,
            isNotNull,
            reason: 'MovementSystem should be initialized',
          );
          expect(
            game.physicsSystem,
            isNotNull,
            reason: 'PhysicsSystem should be initialized',
          );

          // Check that player exists
          expect(
            game.gameWorld.player,
            isNotNull,
            reason: 'Player should be loaded',
          );

          final player = game.gameWorld.player!;

          // Test basic player properties
          expect(player.isAlive, isTrue, reason: 'Player should be alive');
          expect(
            player.position.y,
            lessThan(1000),
            reason: 'Player should be in valid position',
          );

          // Test input system integration
          expect(
            game.inputSystem.focusedEntity,
            equals(player),
            reason: 'Player should be focused entity',
          );

          // Test system registration
          expect(
            game.movementSystem.entityCount,
            greaterThan(0),
            reason: 'MovementSystem should have entities',
          );
          expect(
            game.physicsSystem.entityCount,
            greaterThan(0),
            reason: 'PhysicsSystem should have entities',
          );
        },
        timeout: const Timeout(
          Duration(seconds: 30),
        ), // Longer timeout for initialization
      );

      testWithGame<AdventureJumperGame>(
        'Player movement works in live environment',
        AdventureJumperGame.new,
        (game) async {
          await game.ready();
          final player = game.gameWorld.player!;

          final initialX = player.position.x;

          // Test right movement
          game.onKeyEvent(
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyD,
              logicalKey: LogicalKeyboardKey.keyD,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyD},
          );

          // Process movement for several frames
          for (int i = 0; i < 10; i++) {
            game.update(0.016);
          }

          expect(
            player.position.x,
            greaterThan(initialX),
            reason: 'Player should move right',
          );

          // Stop movement and test left
          game.onKeyEvent(
            const KeyUpEvent(
              physicalKey: PhysicalKeyboardKey.keyD,
              logicalKey: LogicalKeyboardKey.keyD,
              timeStamp: Duration.zero,
            ),
            {},
          );

          game.onKeyEvent(
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyA,
              logicalKey: LogicalKeyboardKey.keyA,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyA},
          );

          for (int i = 0; i < 10; i++) {
            game.update(0.016);
          }

          expect(
            player.velocity.x,
            lessThan(0.0),
            reason: 'Player should move left',
          );
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      testWithGame<AdventureJumperGame>(
        'Player respawn works correctly in live environment',
        AdventureJumperGame.new,
        (game) async {
          await game.ready();
          final player = game.gameWorld.player!;

          // Set some movement state
          game.onKeyEvent(
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyD,
              logicalKey: LogicalKeyboardKey.keyD,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyD},
          );

          game.update(0.016);

          // Verify movement is active
          expect(player.controller.isMovingRight, isTrue);

          // Force respawn by moving below fall threshold
          player.position.setFrom(Vector2(100, 1500));

          // Process respawn
          game.update(0.016);

          // Verify respawn occurred and input state is reset
          expect(
            player.position.y,
            lessThan(1200),
            reason: 'Player should be respawned',
          );
          expect(
            player.controller.isMovingRight,
            isFalse,
            reason: 'Movement input should be cleared after respawn',
          );
          expect(
            player.velocity.x,
            equals(0.0),
            reason: 'Velocity should be zero after respawn',
          );

          // Test that new input works after respawn
          game.onKeyEvent(
            const KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyA,
              logicalKey: LogicalKeyboardKey.keyA,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyA},
          );

          for (int i = 0; i < 5; i++) {
            game.update(0.016);
          }

          expect(
            player.velocity.x,
            lessThan(0.0),
            reason: 'Player should respond to input after respawn',
          );
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('T2.19.2: Debug Component Validation', () {
      testWithGame<AdventureJumperGame>(
        'No hardcoded debug rectangles are present',
        AdventureJumperGame.new,
        (game) async {
          await game.ready();

          // Check that no hardcoded debug rectangles exist
          final debugComponents = game.descendants().where(
                (component) =>
                    component.runtimeType.toString().contains('DebugRectangle'),
              );

          // Allow debug rectangles if they're part of the debug system (VisualDebugOverlay)
          // but not hardcoded ones like "GameTestRect" or "LoaderDebugRect"
          final hardcodedDebugComponents = debugComponents.where(
            (component) =>
                component.toString().contains('GameTestRect') ||
                component.toString().contains('LoaderDebugRect'),
          );

          expect(
            hardcodedDebugComponents.isEmpty,
            isTrue,
            reason: 'No hardcoded debug rectangles should be present',
          );
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('T2.19.3: Performance Validation', () {
      testWithGame<AdventureJumperGame>(
        'Game maintains stable performance',
        AdventureJumperGame.new,
        (game) async {
          await game.ready();

          // Run for 2 seconds worth of frames
          const int frameCount = 120; // 2 seconds at 60fps
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < frameCount; i++) {
            game.update(0.016);

            // Add some input every 20 frames to simulate gameplay
            if (i % 20 == 0) {
              game.onKeyEvent(
                const KeyDownEvent(
                  physicalKey: PhysicalKeyboardKey.space,
                  logicalKey: LogicalKeyboardKey.space,
                  timeStamp: Duration.zero,
                ),
                {LogicalKeyboardKey.space},
              );
            }
          }

          stopwatch.stop();
          final avgFrameTime = stopwatch.elapsedMicroseconds / frameCount;

          // At 60fps, each frame should take ~16.67ms = 16670 microseconds
          // Allow overhead for testing, require < 25ms per frame
          expect(
            avgFrameTime,
            lessThan(25000),
            reason:
                'Average frame time should support 40+ fps for stable gameplay',
          );
        },
        timeout: const Timeout(Duration(seconds: 45)),
      );
    });
  });
}

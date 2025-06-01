// Test file for T2.19: Create live test environment validation
import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.19: Live Test Environment Validation', () {
    late AdventureJumperGame game;
    late Player player;

    setUp(() async {
      game = AdventureJumperGame();
      await game.onLoad();
      await game.ready();

      // Wait for GameWorld to initialize
      await game.gameWorld.loaded;
      player = game.gameWorld.player!;
    });

    group('T2.19.1: Complete gameplay loop validation', () {
      testWithGame<AdventureJumperGame>(
        'Movement → Jumping → Collection cycle works correctly',
        AdventureJumperGame.new,
        (game) async {
          final player = game.gameWorld.player!;

          // Initial state validation
          expect(player.isAlive, isTrue);
          expect(player.physics!.isOnGround, isTrue);

          // Test horizontal movement
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyD,
              logicalKey: LogicalKeyboardKey.keyD,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyD},
          );

          // Process movement
          for (int i = 0; i < 3; i++) {
            game.inputSystem.update(0.016);
            player.controller.update(0.016);
            game.movement.update(0.016);
            game.physicsSystem.update(0.016);
          }

          expect(
            player.velocity.x,
            greaterThan(0.0),
            reason: 'Player should move right',
          );

          // Test jumping
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.space,
              logicalKey: LogicalKeyboardKey.space,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyD, LogicalKeyboardKey.space},
          );

          // Process jump
          for (int i = 0; i < 3; i++) {
            game.inputSystem.update(0.016);
            player.controller.update(0.016);
            game.movement.update(0.016);
            game.physicsSystem.update(0.016);
          }

          expect(
            player.velocity.y,
            lessThan(0.0),
            reason: 'Player should jump up',
          );

          // Test collectible interaction (if any AetherShards are present)
          final initialAether = player.stats.currentAether;

          // Simulate collision with an AetherShard if present
          final collectibles =
              game.gameWorld.children.whereType<dynamic>().where(
                    (child) =>
                        child.runtimeType.toString().contains('AetherShard'),
                  );

          if (collectibles.isNotEmpty) {
            // Force a collision with the first collectible
            final collectible = collectibles.first;
            player.position = (collectible as dynamic).position.clone();

            // Process collision
            game.physicsSystem.update(0.016);

            expect(
              player.stats.currentAether,
              greaterThanOrEqualTo(initialAether),
              reason: 'Aether should increase after collecting shard',
            );
          }
        },
      );
    });

    group('T2.19.2: Player respawn bug validation', () {
      testWithGame<AdventureJumperGame>(
        'Player input works correctly after respawn',
        AdventureJumperGame.new,
        (game) async {
          final player = game.gameWorld.player!;

          // Setup: Move player and set input states
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyD,
              logicalKey: LogicalKeyboardKey.keyD,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyD},
          );

          // Process input to set internal state
          game.inputSystem.update(0.016);
          player.controller.update(0.016);

          // Verify movement is working before respawn
          expect(
            player.controller.isMovingRight,
            isTrue,
            reason: 'Should be moving right before respawn',
          );
          // Force respawn by moving player below fall threshold
          player.position = Vector2(100, 1500); // Below fall threshold of 1200

          // Process respawn system
          player.controller.update(0.016);

          // Verify player was respawned
          expect(
            player.position.y,
            lessThan(1200),
            reason: 'Player should be respawned above fall threshold',
          );

          // Critical test: Input state should be reset after respawn
          expect(
            player.controller.isMovingRight,
            isFalse,
            reason: 'Movement input should be cleared after respawn',
          );
          expect(
            player.controller.isMovingLeft,
            isFalse,
            reason: 'Movement input should be cleared after respawn',
          );
          expect(
            player.velocity.x,
            equals(0.0),
            reason: 'Velocity should be zero after respawn',
          );

          // Test that new input works correctly after respawn
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyA,
              logicalKey: LogicalKeyboardKey.keyA,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.keyA},
          );

          // Process new input
          for (int i = 0; i < 5; i++) {
            game.inputSystem.update(0.016);
            player.controller.update(0.016);
            game.movement.update(0.016);
            game.physicsSystem.update(0.016);
          }

          expect(
            player.velocity.x,
            lessThan(0.0),
            reason: 'Player should respond to left input after respawn',
          );
        },
      );
    });

    group('T2.19.3: Visual debug component validation', () {
      testWithGame<AdventureJumperGame>(
        'No hardcoded debug rectangles are rendered',
        AdventureJumperGame.new,
        (game) async {
          // Check that no hardcoded debug rectangles exist in the game
          final debugComponents = game.children.where(
            (component) =>
                component.runtimeType.toString().contains('DebugRectangle') &&
                component.children
                    .any((child) => child.toString().contains('GameTestRect')),
          );

          expect(
            debugComponents.isEmpty,
            isTrue,
            reason:
                'No hardcoded debug rectangles should be present in the game',
          );

          // Verify GameWorld doesn't have hardcoded debug components
          final worldDebugComponents = game.gameWorld.children.where(
            (component) =>
                component.runtimeType.toString().contains('DebugRectangle') &&
                component.toString().contains('LoaderDebugRect'),
          );

          expect(
            worldDebugComponents.isEmpty,
            isTrue,
            reason: 'GameWorld should not have hardcoded debug rectangles',
          );
        },
      );
    });

    group('T2.19.4: System integration and performance validation', () {
      testWithGame<AdventureJumperGame>(
        'All Sprint 2 physics mechanics work in level environment',
        AdventureJumperGame.new,
        (game) async {
          final player = game.gameWorld.player!;

          // Test all physics systems are working
          expect(
            game.inputSystem.isActive,
            isTrue,
            reason: 'InputSystem should be active',
          );
          expect(
            game.movementSystem.isActive,
            isTrue,
            reason: 'MovementSystem should be active',
          );
          expect(
            game.physicsSystem.isActive,
            isTrue,
            reason: 'PhysicsSystem should be active',
          );

          // Test player is registered with all systems
          expect(
            game.inputSystem.focusedEntity,
            equals(player),
            reason: 'Player should be focused entity',
          );
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

          // Test jump mechanics work in level
          player.physics!.setOnGround(true);
          final initialY = player.position.y;

          // Perform jump
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.space,
              logicalKey: LogicalKeyboardKey.space,
              timeStamp: Duration.zero,
            ),
            {LogicalKeyboardKey.space},
          );

          // Process jump for several frames
          for (int i = 0; i < 10; i++) {
            game.inputSystem.update(0.016);
            player.controller.update(0.016);
            game.movement.update(0.016);
            game.physicsSystem.update(0.016);
            game.update(0.016);
          }

          expect(
            player.position.y,
            lessThan(initialY),
            reason: 'Player should have jumped up',
          );
          expect(
            player.velocity.y,
            lessThan(0.0),
            reason: 'Player should have upward velocity',
          );

          // Test physics mechanics (gravity, collision, landing)
          // Allow gravity to pull player back down
          for (int i = 0; i < 50; i++) {
            game.physicsSystem.update(0.016);
            game.movement.update(0.016);
            game.update(0.016);

            // Break when player lands
            if (player.physics!.isOnGround) break;
          }

          expect(
            player.physics!.isOnGround,
            isTrue,
            reason: 'Player should land back on ground',
          );
          expect(
            player.controller.jumpState.toString(),
            contains('grounded'),
            reason: 'Player should be in grounded state after landing',
          );
        },
      );

      testWithGame<AdventureJumperGame>(
        'Performance remains stable with all systems active',
        AdventureJumperGame.new,
        (game) async {
          // Run game for extended period to test performance
          const int frameCount = 120; // 2 seconds at 60fps
          final stopwatch = Stopwatch()..start();

          for (int i = 0; i < frameCount; i++) {
            game.update(0.016);

            // Simulate some player input every 10 frames
            if (i % 10 == 0) {
              game.onKeyEvent(
                KeyDownEvent(
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
          // Allow some overhead, test for < 20ms per frame
          expect(
            avgFrameTime,
            lessThan(20000),
            reason:
                'Average frame time should be under 20ms for stable 60fps performance',
          );
        },
      );
    });

    group('T2.19.5: Edge cases and error handling', () {
      testWithGame<AdventureJumperGame>(
        'Game handles edge cases gracefully',
        AdventureJumperGame.new,
        (game) async {
          final player = game.gameWorld.player!;

          // Test rapid input changes
          for (int i = 0; i < 10; i++) {
            game.onKeyEvent(
              KeyDownEvent(
                physicalKey: PhysicalKeyboardKey.keyA,
                logicalKey: LogicalKeyboardKey.keyA,
                timeStamp: Duration.zero,
              ),
              {LogicalKeyboardKey.keyA},
            );

            game.onKeyEvent(
              KeyUpEvent(
                physicalKey: PhysicalKeyboardKey.keyA,
                logicalKey: LogicalKeyboardKey.keyA,
                timeStamp: Duration.zero,
              ),
              {},
            );

            game.inputSystem.update(0.016);
            player.controller.update(0.016);
          }

          expect(
            player.isAlive,
            isTrue,
            reason: 'Player should survive rapid input changes',
          );

          // Test multiple simultaneous inputs
          game.onKeyEvent(
            KeyDownEvent(
              physicalKey: PhysicalKeyboardKey.keyA,
              logicalKey: LogicalKeyboardKey.keyA,
              timeStamp: Duration.zero,
            ),
            {
              LogicalKeyboardKey.keyA,
              LogicalKeyboardKey.keyD,
              LogicalKeyboardKey.space,
            },
          );

          // Process conflicting inputs
          game.inputSystem.update(0.016);
          player.controller.update(0.016);

          expect(
            player.isAlive,
            isTrue,
            reason: 'Player should handle conflicting inputs gracefully',
          );
        },
      );
    });
  });
}

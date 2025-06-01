// Test file for T2.19: Simplified respawn validation test
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.19: Simplified Respawn Bug Validation', () {
    late Player player;
    late PlayerController controller;

    setUp(() async {
      player = Player(position: Vector2(100, 300));
      await player.onLoad();
      controller = player.controller;
    });

    test('Input state is properly reset after respawn', () async {
      // Setup: Set some input states before respawn
      controller.handleInputAction('move_right', true);
      controller.handleInputAction('jump', true);

      // Process one frame to apply inputs
      controller.update(0.016);

      // Verify input states are active before respawn
      expect(
        controller.isMovingRight,
        isTrue,
        reason: 'Should be moving right before respawn',
      );
      expect(
        controller.jumpInputHeld,
        isTrue,
        reason: 'Jump should be held before respawn',
      );

      // Trigger respawn by moving player below fall threshold
      player.position
          .setFrom(Vector2(100, 1500)); // Below fall threshold of 1200

      // Process respawn system (this calls _respawnPlayer internally)
      controller.update(0.016);

      // Verify player was respawned to safe position
      expect(
        player.position.y,
        lessThan(1200),
        reason: 'Player should be respawned above fall threshold',
      );

      // CRITICAL TEST: Verify all input states are reset
      expect(
        controller.isMovingRight,
        isFalse,
        reason: 'Movement right should be cleared after respawn',
      );
      expect(
        controller.isMovingLeft,
        isFalse,
        reason: 'Movement left should be cleared after respawn',
      );
      expect(
        controller.jumpInputHeld,
        isFalse,
        reason: 'Jump input should be cleared after respawn',
      );
      expect(
        player.velocity.x,
        equals(0.0),
        reason: 'Velocity should be zero after respawn',
      );
      expect(
        player.velocity.y,
        equals(0.0),
        reason: 'Velocity should be zero after respawn',
      );
    });

    test('New input works correctly after respawn', () async {
      // Setup: Trigger a respawn first
      player.position.setFrom(Vector2(100, 1500));
      controller.update(0.016);

      // Verify respawn occurred
      expect(player.position.y, lessThan(1200));
      expect(controller.isMovingRight, isFalse);
      expect(controller.isMovingLeft, isFalse);

      // Test that new left movement input works after respawn
      controller.handleInputAction('move_left', true);

      // Process several frames to ensure movement is applied
      for (int i = 0; i < 5; i++) {
        controller.update(0.016);
      }

      expect(
        controller.isMovingLeft,
        isTrue,
        reason: 'Should respond to left input after respawn',
      );
      expect(
        player.velocity.x,
        lessThan(0.0),
        reason: 'Player should move left after respawn',
      );

      // Test that new right movement input works after respawn
      controller.handleInputAction('move_left', false);
      controller.handleInputAction('move_right', true);

      // Process several frames to ensure movement is applied
      for (int i = 0; i < 5; i++) {
        controller.update(0.016);
      }

      expect(
        controller.isMovingRight,
        isTrue,
        reason: 'Should respond to right input after respawn',
      );
      expect(
        player.velocity.x,
        greaterThan(0.0),
        reason: 'Player should move right after respawn',
      );
    });

    test('Jump input works correctly after respawn', () async {
      // Setup: Trigger a respawn first
      player.position.setFrom(Vector2(100, 1500));
      controller.update(0.016);

      // Verify respawn occurred and player is on ground
      expect(player.position.y, lessThan(1200));
      expect(player.physics!.isOnGround, isTrue);

      // Test jump after respawn
      controller.handleInputAction('jump', true);
      controller.update(0.016);

      expect(
        player.velocity.y,
        lessThan(0.0),
        reason: 'Player should jump after respawn',
      );
    });

    test('Respawn system preserves last safe position', () async {
      // Setup: Move player to a new safe position
      final safePosition = Vector2(200, 400);
      player.position.setFrom(safePosition);
      player.physics!.setOnGround(true);

      // Wait for safe position to update (requires being on ground for 0.5 seconds)
      for (int i = 0; i < 35; i++) {
        // 35 frames * 0.016 = 0.56 seconds
        controller.update(0.016);
      }

      // Now trigger a fall
      player.position.setFrom(Vector2(200, 1500));
      controller.update(0.016);

      // Verify respawn to the safe position (within reasonable tolerance)
      expect(
        (player.position - safePosition).length,
        lessThan(50.0),
        reason: 'Player should respawn near the last safe position',
      );
    });
  });
}

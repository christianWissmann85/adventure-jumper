import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Physics System Tests', () {
    group('Gravity Tests', () {
      test('should apply gravity to entities', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Ensure player is not on ground
        player.physics!.setOnGround(false);

        // Set initial velocity
        final initialVelocity = Vector2(0, 0);
        player.physics!.setVelocity(initialVelocity.clone());

        // Update physics system
        physicsSystem.update(0.016);

        // Verify gravity is applied (y velocity should increase)
        expect(
          player.physics!.velocity.y,
          greaterThan(initialVelocity.y),
          reason: 'Gravity should increase Y velocity downward',
        );
      });

      test('should apply correct gravity acceleration', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Ensure player is not on ground
        player.physics!.setOnGround(false);
        player.physics!.setVelocity(Vector2.zero());

        // Record position before gravity
        final initialPosition = Vector2.copy(player.position);

        // Multiple updates to see cumulative gravity effect
        for (int i = 0; i < 10; i++) {
          physicsSystem.update(0.016);
        }

        // Position should have changed due to gravity
        expect(
          player.position.y,
          greaterThan(initialPosition.y),
          reason: 'Entity should fall due to gravity',
        );

        // Velocity should continuously increase
        expect(
          player.physics!.velocity.y,
          greaterThan(0),
          reason: 'Downward velocity should increase due to gravity',
        );
      });

      test('should not apply gravity when entity is on ground', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Set player on ground with zero Y velocity
        player.physics!.setOnGround(true);
        player.physics!.setVelocity(Vector2(0, 0));

        // Update system
        physicsSystem.update(0.016);

        // Y velocity should remain at or very close to zero
        expect(
          player.physics!.velocity.y.abs() < 0.1,
          isTrue,
          reason: 'Y velocity should remain near zero when on ground',
        );
      });
    });

    group('Friction Tests', () {
      test('should apply friction on ground', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Set player on ground with horizontal velocity
        player.physics!.setOnGround(true);
        player.physics!.setVelocity(Vector2(100, 0));

        final initialVelocity = player.physics!.velocity.x;

        // Update physics
        physicsSystem.update(0.016);

        // Velocity should decrease due to friction
        expect(
          player.physics!.velocity.x.abs(),
          lessThan(initialVelocity.abs()),
          reason: 'Horizontal velocity should decrease due to ground friction',
        );
      });

      test('should eventually stop entity due to friction', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Set player on ground with horizontal velocity
        player.physics!.setOnGround(true);
        player.physics!.setVelocity(Vector2(100, 0));

        // Run many updates to let friction take effect
        for (int i = 0; i < 30; i++) {
          physicsSystem.update(0.016);
        }

        // Velocity should approach zero
        expect(
          player.physics!.velocity.x.abs() < 1.0,
          isTrue,
          reason: 'Entity should eventually stop due to friction',
        );
      });

      test('should apply less friction in air', () async {
        // Setup two identical players
        final playerOnGround = Player(position: Vector2.zero());
        final playerInAir = Player(position: Vector2(0, -100));
        await playerOnGround.onLoad();
        await playerInAir.onLoad();

        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(playerOnGround);
        physicsSystem.addEntity(playerInAir);

        // Set identical initial velocity
        final initialVelocity = Vector2(100, 0);
        playerOnGround.physics!.setVelocity(initialVelocity.clone());
        playerInAir.physics!.setVelocity(initialVelocity.clone());

        // Set ground contact appropriately
        playerOnGround.physics!.setOnGround(true);
        playerInAir.physics!.setOnGround(false);

        // Update physics
        physicsSystem.update(0.016);

        // Air friction should be less, so air player should maintain more velocity
        expect(
          playerInAir.physics!.velocity.x.abs(),
          greaterThan(playerOnGround.physics!.velocity.x.abs()),
          reason: 'Air friction should be less than ground friction',
        );
      });
    });

    group('Combined Physics Tests', () {
      test('should handle projectile motion correctly', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Set initial jumping velocity (up and right)
        player.physics!.setVelocity(Vector2(100, -100));
        player.physics!.setOnGround(false);

        final initialPosition = Vector2.copy(player.position);
        //final initialVelocity = Vector2.copy(player.physics!.velocity);

        // Track position at peak of jump
        Vector2? peakPosition;
        double lowestYVelocity = 0;

        // Simulate jump arc over multiple frames
        for (int i = 0; i < 30; i++) {
          physicsSystem.update(0.016);

          // Find peak of jump (when y velocity changes from negative to positive)
          final currentYVelocity = player.physics!.velocity.y;
          if (lowestYVelocity < 0 && currentYVelocity >= 0) {
            peakPosition = Vector2.copy(player.position);
          }
          lowestYVelocity = currentYVelocity;
        }

        // Verify horizontal motion continues
        expect(
          player.position.x,
          greaterThan(initialPosition.x),
          reason: 'Horizontal position should increase throughout the jump',
        );

        // Verify parabolic path (should rise then fall)
        expect(
          peakPosition,
          isNotNull,
          reason: 'Jump should have a peak point where y velocity reverses',
        );

        // Final y position should be below peak
        expect(
          player.position.y,
          greaterThan(peakPosition!.y),
          reason: 'Entity should fall after peak of jump',
        );

        // Final y velocity should be positive (falling)
        expect(
          player.physics!.velocity.y,
          greaterThan(0),
          reason:
              'Y velocity should become positive (downward) after jump peak',
        );
      });

      test('should handle collision with ground', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();
        final physicsSystem = PhysicsSystem();
        physicsSystem.addEntity(player);

        // Start with player falling
        player.physics!.setVelocity(Vector2(0, 100));
        player.physics!.setOnGround(false);

        // Update physics
        physicsSystem.update(0.016);

        // Now simulate collision with ground
        player.physics!.setOnGround(true);

        // Update physics again
        physicsSystem.update(0.016);

        // Y velocity should be zeroed out
        expect(
          player.physics!.velocity.y,
          equals(0),
          reason: 'Y velocity should be zeroed when landing on ground',
        );

        // Verify justLanded state
        expect(
          player.physics!.justLanded,
          isTrue,
          reason: 'justLanded should be true when first touching ground',
        );
      });
    });
  });

  group('Controller-Specific Tests', () {
    group('Player Controller Input Handling', () {
      test('should handle key state changes correctly', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        // Initial state should be no movement
        expect(player.controller.isMovingLeft, isFalse);
        expect(player.controller.isMovingRight, isFalse);
        expect(player.controller.isJumping, isFalse);

        // Trigger action changes
        player.controller.handleInputAction('move_right', true);

        // Verify state updated
        expect(player.controller.isMovingRight, isTrue);
        expect(player.controller.isMovingLeft, isFalse);

        // Change to left
        player.controller.handleInputAction('move_left', true);
        player.controller.handleInputAction('move_right', false);

        // Verify updated again
        expect(player.controller.isMovingRight, isFalse);
        expect(player.controller.isMovingLeft, isTrue);

        // Trigger jump
        player.controller.handleInputAction('jump', true);
        expect(player.controller.isJumping, isTrue);
      });

      test('should translate input to physics changes', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        // Set player on ground to allow jumping
        player.physics!.setOnGround(true);

        // No initial velocity
        expect(player.physics!.velocity.x, equals(0));
        expect(player.physics!.velocity.y, equals(0));

        // Move right
        player.controller.handleInputAction('move_right', true);
        player.controller.update(0.016);

        // Verify velocity updated
        expect(player.physics!.velocity.x, greaterThan(0));

        // Move left
        player.controller.handleInputAction('move_right', false);
        player.controller.handleInputAction('move_left', true);
        player.controller.update(0.016);

        // Verify velocity reversed
        expect(player.physics!.velocity.x, lessThan(0));

        // Jump
        player.controller.handleInputAction('jump', true);
        player.controller.update(0.016);

        // Verify jump velocity
        expect(player.physics!.velocity.y, lessThan(0));
      });

      test('should reset input state correctly', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        // Set some actions
        player.controller.handleInputAction('move_right', true);
        player.controller.handleInputAction('jump', true);

        // Verify actions are set
        expect(player.controller.isMovingRight, isTrue);
        expect(player.controller.isJumping, isTrue);

        // Reset input state
        player.controller.resetInputState();

        // Verify all inputs reset
        expect(player.controller.isMovingRight, isFalse);
        expect(player.controller.isMovingLeft, isFalse);
        expect(player.controller.isJumping, isFalse);
      });
    });

    group('Input Buffering', () {
      test('should buffer jump input when player is in air', () async {
        // Setup
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        // Configure player to be in air
        player.physics!.setOnGround(false);

        // Try to jump while in air (should be buffered)
        player.input.setActionState('jump', true);
        player.controller.update(0.016);

        // Verify y velocity unchanged since player is in air
        expect(player.physics!.velocity.y, equals(0));

        // Now land on ground
        player.physics!.setOnGround(true);

        // Update controller again to process buffered input
        player.controller.update(0.016);

        // Should now perform the jump
        expect(player.physics!.velocity.y, lessThan(0));
      });
    });
  });
}

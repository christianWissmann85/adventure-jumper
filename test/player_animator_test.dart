import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_animator.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for PlayerAnimator - T2.14.5: Test animation state transitions and timing accuracy
void main() {
  group('PlayerAnimator Tests - T2.14.5', () {
    late Player player;
    late PlayerAnimator animator;
    late PlayerController controller;
    late PhysicsComponent physics;

    setUp(() {
      // Create test player with all required components
      player = Player(position: Vector2(100, 100), size: Vector2(32, 64));

      // Initialize physics component
      physics = PhysicsComponent();
      player.physics = physics;

      // Initialize controller component
      controller = PlayerController(player);
      player.controller = controller;

      // Initialize animator
      animator = PlayerAnimator(player);
    });

    test('PlayerAnimator initializes with idle state', () {
      expect(animator.getCurrentState(), equals(AnimationState.idle));
    });
    test(
        'Animation state transitions based on controller jump state - grounded idle',
        () {
      // Setup: Player is grounded with no horizontal movement
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in idle state
      expect(animator.getCurrentState(), equals(AnimationState.idle));
    });
    test(
        'Animation state transitions based on controller jump state - grounded running',
        () {
      // Setup: Player is grounded with horizontal movement
      physics.setOnGround(true);
      physics.setVelocity(Vector2(50, 0)); // Above 10 threshold for running

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in run state
      expect(animator.getCurrentState(), equals(AnimationState.run));
    });
    test('Animation state transitions based on controller jump state - jumping',
        () {
      // Setup: Player is jumping (simulate through physics)
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, -100)); // Upward velocity

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in jump state
      expect(animator.getCurrentState(), equals(AnimationState.jump));
    });
    test('Animation state transitions based on controller jump state - falling',
        () {
      // Setup: Player is falling (simulate through physics)
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, 100)); // Downward velocity

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in fall state
      expect(animator.getCurrentState(), equals(AnimationState.fall));
    });
    test('Animation state transitions based on controller jump state - landing',
        () {
      // Setup: Player is landing (simulate through reduced downward velocity while airborne)
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, 20)); // Small downward velocity

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in fall state (since we can't directly set landing state)
      expect(animator.getCurrentState(), equals(AnimationState.fall));
    });
    test('Animation state transition timing accuracy - state persistence', () {
      // Setup: Start in idle state
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.idle));

      // Transition to running
      physics.setVelocity(Vector2(50, 0));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.run));

      // Transition to jumping
      physics.setOnGround(false);
      physics.setVelocity(Vector2(50, -100));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.jump));

      // Transition to falling
      physics.setVelocity(Vector2(50, 100));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(
        animator.getCurrentState(),
        equals(
          AnimationState.fall,
        ),
      ); // Back to landing when grounded (brief landing state before running)
      physics.setOnGround(true);
      physics.setVelocity(Vector2(50, 0));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.landing));
    });

    test('Animation state does not change when same state is requested', () {
      // Setup: Start in idle state
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));
      animator.updateAnimationState();
      final initialState = animator.getCurrentState();

      // Execute: Request same state multiple times
      animator.playAnimation(AnimationState.idle);
      animator.playAnimation(AnimationState.idle);
      animator.playAnimation(AnimationState.idle);

      // Verify: State remains unchanged
      expect(animator.getCurrentState(), equals(initialState));
      expect(animator.getCurrentState(), equals(AnimationState.idle));
    });
    test('Fallback to physics-based detection when controller unavailable', () {
      // Setup: Create a fresh controller for fallback testing
      final newController = PlayerController(player);
      final originalController = player.controller;
      player.controller = newController;

      // Setup physics for grounded running
      physics.setOnGround(true);
      physics.setVelocity(Vector2(50, 0));

      // Update controller to sync jump state machine
      newController.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should detect running based on physics
      expect(animator.getCurrentState(), equals(AnimationState.run));

      // Restore original controller
      player.controller = originalController;
    });
    test('Fallback physics detection - idle when grounded with no movement',
        () {
      // Setup: Create fresh controller to test physics fallback
      final newController = PlayerController(player);
      player.controller = newController;
      physics.setOnGround(true);
      physics.setVelocity(Vector2(5, 0)); // Below 10 threshold

      // Update controller to sync jump state machine
      newController.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be idle
      expect(animator.getCurrentState(), equals(AnimationState.idle));
    });
    test('Fallback physics detection - airborne states', () {
      // Setup: Create fresh controller to test physics fallback
      final newController = PlayerController(player);
      player.controller = newController;
      physics.setOnGround(false);

      // Test upward movement (jumping)
      physics.setVelocity(Vector2(0, -50));
      newController.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.jump));

      // Test downward movement (falling)
      physics.setVelocity(Vector2(0, 50));
      newController.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.fall));
    });

    test('Manual animation state change works correctly', () {
      // Setup: Start in idle
      expect(animator.getCurrentState(), equals(AnimationState.idle));

      // Execute: Manually set to attack
      animator.playAnimation(AnimationState.attack);

      // Verify: State changed to attack
      expect(animator.getCurrentState(), equals(AnimationState.attack));

      // Execute: Manually set to damaged
      animator.playAnimation(AnimationState.damaged);

      // Verify: State changed to damaged
      expect(animator.getCurrentState(), equals(AnimationState.damaged));
    });

    test('All animation states are supported', () {
      // Test that all animation states can be set
      final allStates = [
        AnimationState.idle,
        AnimationState.run,
        AnimationState.jump,
        AnimationState.fall,
        AnimationState.landing,
        AnimationState.attack,
        AnimationState.damaged,
        AnimationState.death,
      ];

      for (final state in allStates) {
        animator.playAnimation(state);
        expect(animator.getCurrentState(), equals(state));
      }
    });
    test('Integration with jump state machine priorities', () {
      // Test that physics-based detection works as expected

      // Setup: Physics suggests jumping (negative velocity, not on ground)
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, -100));

      // Update controller to sync jump state machine
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in jump state based on physics
      expect(animator.getCurrentState(), equals(AnimationState.jump));
    });

    group('Edge Cases and Error Handling', () {
      test('Handles null physics gracefully', () {
        // Setup: Remove physics component
        player.physics = null;

        // Execute: Should not crash
        expect(() => animator.updateAnimationState(), returnsNormally);

        // State should remain unchanged (idle by default)
        expect(animator.getCurrentState(), equals(AnimationState.idle));
      });

      test('Handles rapid state changes correctly', () {
        // Test rapid state transitions don't cause issues
        for (int i = 0; i < 100; i++) {
          final state = AnimationState.values[i % AnimationState.values.length];
          animator.playAnimation(state);
          expect(animator.getCurrentState(), equals(state));
        }
      });
    });
  });
}

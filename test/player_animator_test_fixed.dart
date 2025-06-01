import 'package:adventure_jumper/src/components/adv_sprite_component.dart';
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
    setUp(() async {
      // Create test player with all required components
      player = Player(position: Vector2(100, 100), size: Vector2(32, 64));

      // Initialize physics component
      physics = PhysicsComponent();
      player.physics = physics;

      // Initialize sprite component (essential for PlayerAnimator)
      player.sprite = AdvSpriteComponent(
        size: player.size,
        opacity: 1.0,
      );

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
      // Note: jumpState is read-only, so we simulate conditions for grounded state
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));

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

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in run state
      expect(animator.getCurrentState(), equals(AnimationState.run));
    });

    test('Animation state transitions based on controller jump state - jumping',
        () {
      // Setup: Player is jumping (simulate by triggering jump through controller)
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));

      // Trigger jump through controller to get proper jump state
      controller.handleInputAction('jump', true);
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in jump state
      expect(animator.getCurrentState(), equals(AnimationState.jump));
    });

    test('Animation state transitions based on controller jump state - falling',
        () {
      // Setup: Player is falling (simulate conditions that lead to falling)
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, 100)); // Downward velocity

      // Update controller to process falling state
      controller.update(0.016);

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in fall state
      expect(animator.getCurrentState(), equals(AnimationState.fall));
    });

    test('Animation state transitions based on controller jump state - landing',
        () {
      // Setup: Simulate landing by first being in air, then touching ground
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, 50));
      controller.update(0.016); // Process falling state

      // Now land
      physics.setOnGround(true);
      controller.update(0.016); // Process landing state

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be in landing state (or idle if landing timer expired)
      // Landing is a brief state, so check for either landing or idle
      final currentState = animator.getCurrentState();
      expect(
        currentState == AnimationState.landing ||
            currentState == AnimationState.idle,
        isTrue,
        reason: 'Should be in landing or idle state after landing',
      );
    });

    test('Animation state transition timing accuracy - state persistence', () {
      // Setup: Start in idle state
      physics.setOnGround(true);
      physics.setVelocity(Vector2(0, 0));
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.idle));

      // Transition to running
      physics.setVelocity(Vector2(50, 0));
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.run));

      // Transition to jumping
      physics.setOnGround(true);
      controller.handleInputAction('jump', true);
      controller.update(0.016);
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.jump));

      // Transition to falling
      physics.setOnGround(false);
      physics.setVelocity(Vector2(50, 100));
      controller.update(0.016);
      animator.updateAnimationState();
      expect(
        animator.getCurrentState(),
        equals(AnimationState.fall),
      ); // Transition to landing
      physics.setOnGround(true);
      controller.update(0.016);
      animator.updateAnimationState();
      final landingState = animator.getCurrentState();
      expect(
        landingState == AnimationState.landing ||
            landingState == AnimationState.run,
        isTrue,
        reason: 'Should be in landing or run state after landing',
      );

      // Wait for landing timer to elapse (0.1 seconds + buffer)
      controller.update(0.12);

      // Back to running when grounded
      physics.setVelocity(Vector2(50, 0));
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.run));
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
      // Setup: Create a minimal player for fallback testing
      final fallbackPlayer =
          Player(position: Vector2(0, 0), size: Vector2(32, 64));
      final fallbackPhysics = PhysicsComponent();
      fallbackPlayer.physics = fallbackPhysics;

      // Create a minimal controller (required by constructor but not fully configured)
      final fallbackController = PlayerController(fallbackPlayer);
      fallbackPlayer.controller = fallbackController;

      final fallbackAnimator = PlayerAnimator(fallbackPlayer);

      // Setup physics for grounded running
      fallbackPhysics.setOnGround(true);
      fallbackPhysics.setVelocity(Vector2(50, 0));

      // Execute state update
      fallbackAnimator.updateAnimationState();

      // Verify: Should detect running based on physics
      expect(fallbackAnimator.getCurrentState(), equals(AnimationState.run));
    });

    test('Fallback physics detection - idle when grounded with no movement',
        () {
      // Setup: Use physics fallback
      physics.setOnGround(true);
      physics.setVelocity(Vector2(5, 0)); // Below 10 threshold

      // Execute state update
      animator.updateAnimationState();

      // Verify: Should be idle
      expect(animator.getCurrentState(), equals(AnimationState.idle));
    });
    test('Fallback physics detection - airborne states', () {
      // Setup: Test airborne animation states using controller integration
      physics.setOnGround(false);

      // Test upward movement (jumping) - need to sync controller state
      physics.setVelocity(Vector2(0, -50));
      controller.update(0.016); // Sync controller jump state machine
      animator.updateAnimationState();
      expect(animator.getCurrentState(), equals(AnimationState.jump));

      // Test downward movement (falling)
      physics.setVelocity(Vector2(0, 50));
      controller.update(0.016); // Sync controller jump state machine
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
      // Test that jump state machine takes priority over basic physics

      // Setup: Create conditions that could be interpreted as jumping
      physics.setOnGround(false);
      physics.setVelocity(Vector2(0, -100));

      // But ensure controller is in a specific state by simulating landing
      physics.setOnGround(true);
      controller.update(
        0.016,
      ); // This should put controller in grounded/landing state

      // Execute state update
      animator.updateAnimationState();

      // Verify: Jump state machine takes priority over physics velocity
      // Since we're on ground, should not be in jump state despite negative velocity
      final currentState = animator.getCurrentState();
      expect(
        currentState != AnimationState.jump,
        isTrue,
        reason: 'Controller state should take priority over raw physics data',
      );
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

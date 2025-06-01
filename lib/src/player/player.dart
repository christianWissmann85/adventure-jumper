import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import '../components/adv_sprite_component.dart';
import '../components/aether_component.dart';
import '../components/debug_rectangle_component.dart';
import '../components/health_component.dart';
import '../components/input_component.dart';
import '../components/input_modes.dart';
import '../components/physics_component.dart';
import '../entities/entity.dart';
import 'player_animator.dart';
import 'player_controller.dart';
import 'player_stats.dart';

/// Main player entity class (Kael)
/// Handles player representation, component management, and state coordination
class Player extends Entity {
  late PlayerController controller;
  late PlayerAnimator animator;
  late PlayerStats stats; // Additional components specific to Player
  late HealthComponent health;
  late AetherComponent aether;
  late InputComponent input;

  Player({
    Vector2? position,
    super.size,
  }) : super(
          position: position ?? Vector2.zero(),
          id: 'player',
          type: 'player',
        );
  @override
  Future<void> setupEntity() async {
    await super.setupEntity();
    print('[Player] setupEntity() called - size: $size');

    // Set up collision callback to handle interactions with other entities
    onCollision =
        _handleCollision; // Initialize physics component (inherited from Entity)
    // CRITICAL FIX: Set bounciness to 0 to prevent bouncing off platforms
    physics = PhysicsComponent(
      bounciness: 0.0, // No bouncing for stable platform landing
    );
    add(physics!); // CRITICAL FIX: Configure collision component for player boundaries
    // This enables collision detection with platforms and other entities
    collision.setHitboxSize(size);
    collision.addCollisionTag('player');
    collision.addCollisionTag('entity');

    // Debug logging to confirm collision setup
    print(
      '[Player] Collision hitbox configured: size=$size, tags=[player, entity]',
    );
    print('[Player] Collision component active: ${collision.isActive}');

    // Initialize sprite component (inherited from Entity)
    sprite = AdvSpriteComponent(
      size:
          size, // Now using PositionComponent's size parameter instead of spriteSize
      opacity: 1.0,
    );
    add(sprite!);
    print('[Player] AdvSpriteComponent added to player');

    // Create a temporary fallback visual using DebugRectangleComponent
    // This ensures the player is visible while sprites load and provides extensive debug logging
    final DebugRectangleComponent playerFallback = DebugRectangleComponent(
      size: size,
      position: Vector2.zero(),
      color: const Color(0xFF3498DB), // Blue color like placeholder
      debugName: 'PlayerFallback',
      priority: -1, // Lower priority so it renders behind sprite components
    );
    add(playerFallback);

    // Initialize input component for player input handling
    input = InputComponent(
      inputMode: InputMode.active,
      inputSource: InputSource.keyboard,
      bufferingMode: InputBufferingMode.enabled,
    );
    // Set up input callbacks to forward to controller
    input.onActionChanged = _handleInputAction;
    add(input);

    // Initialize player-specific components
    health = HealthComponent();
    aether = AetherComponent();
    add(health);
    add(aether); // Initialize subsystems
    controller = PlayerController(this);
    animator = PlayerAnimator(this);
    stats = PlayerStats();
    print('[Player] Adding PlayerController to component tree...');
    add(controller);
    print('[Player] PlayerController added successfully');
    add(animator);
    add(stats); // Implementation needed: Load player sprites
    // Implementation needed: Set initial position
    // Implementation needed: Configure physics properties

    print(
      '[Player] setupEntity() completed - total children: ${children.length}',
    );

    // Debug: List all children
    print('[Player] Children list:');
    for (int i = 0; i < children.length; i++) {
      final child = children.elementAt(i);
      print('  Child $i: ${child.runtimeType}');
    }
  }

  /// Handle input action changes from InputComponent
  void _handleInputAction(String actionName, bool actionValue) {
    // Forward input actions to the controller
    controller.handleInputAction(actionName, actionValue);
  }

  /// Handle player taking damage
  void takeDamage(double amount) {
    stats.takeDamage(amount);
    // Implementation needed: Trigger damage animation/effects
    if (sprite?.isMounted == true) {
      // Apply damage effect
    }
  }

  /// Handle player healing
  void heal(double amount) {
    stats.heal(amount);
    // Implementation needed: Trigger healing effects
    if (sprite?.isMounted == true) {
      // Apply healing effect
    }
  }

  /// Check if player is alive
  bool get isAlive => stats.isAlive;

  /// Get current player position
  Vector2 get playerPosition => position;

  /// Get the input component for external system integration
  InputComponent get inputComponent =>
      input; // T2.3.1: Jump mechanics integration with PhysicsComponent

  /// Attempt to perform a jump if conditions are met
  /// Returns true if jump was executed, false otherwise
  bool tryJump({double? customForce}) {
    // Use the controller's new public method
    return controller.attemptJump();
  }

  /// Check if player can currently jump
  bool get canJump => controller.canPerformJump();

  /// Get current jump state
  String get jumpState => controller.jumpState.toString();

  /// Check if player is currently grounded
  bool get isGrounded => controller.isGrounded;

  /// Check if player is currently jumping (ascending)
  bool get isJumping => controller.isJumping;

  /// Check if player is currently falling
  bool get isFalling => controller.isFalling;

  /// Check if player is in landing state
  bool get isLanding => controller.isLanding;

  /// Get remaining jump cooldown time
  double get jumpCooldownRemaining => controller.jumpCooldownRemaining;

  /// Get remaining coyote time
  double get coyoteTimeRemaining => controller.coyoteTimeRemaining;

  /// Apply external force to player (useful for external systems)
  void applyForce(Vector2 force) {
    physics?.applyForce(force);
  }

  /// Apply impulse to player (instant velocity change)
  void applyImpulse(Vector2 impulse) {
    physics?.applyImpulse(impulse);
  }

  /// Set player velocity directly
  void setVelocity(Vector2 velocity) {
    physics?.setVelocity(velocity);
  }

  /// Get current player velocity
  Vector2 get velocity => physics?.velocity ?? Vector2.zero();

  /// T2.3.5: Jump parameter configuration methods for testing/tuning

  /// Reset jump state (useful for testing or level transitions)
  void resetJumpState() {
    controller.resetInputState();
  }

  /// Get detailed jump state information for debugging
  Map<String, dynamic> getJumpDebugInfo() {
    return {
      'jumpState': jumpState.toString(),
      'isGrounded': isGrounded,
      'canJump': canJump,
      'jumpCooldownRemaining': jumpCooldownRemaining,
      'coyoteTimeRemaining': coyoteTimeRemaining,
      'velocity': velocity.toString(),
      'isOnGround': physics?.isOnGround ?? false,
      'justLanded': physics?.justLanded ?? false,
      'justLeftGround': physics?.justLeftGround ?? false,
    };
  }

  /// Handle collision with another entity
  void _handleCollision(Entity other) {
    print('[Player] _handleCollision called with ${other.type} entity');

    // Handle different types of collisions
    switch (other.type) {
      case 'collectible':
        // Collectibles handle their own pickup logic
        // Player just acknowledges the collision
        print('[Player] Collision with collectible acknowledged');
        break;
      case 'enemy':
        // Handle enemy collisions (damage, etc.)
        break;
      case 'platform':
        // Handle platform/environment collisions
        break;
      default:
        // Handle other collision types
        break;
    }
  }
}

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
import '../systems/interfaces/movement_coordinator.dart';
import '../systems/interfaces/movement_request.dart';
import '../systems/interfaces/movement_response.dart';
import '../systems/interfaces/physics_coordinator.dart';
import 'player_animator.dart';
import 'player_controller.dart';
import 'player_stats.dart';

/// Main player entity class (Kael)
/// Handles player representation, component management, and state coordination
import '../game/adventure_jumper_game.dart';

class Player extends Entity with HasGameReference<AdventureJumperGame> {
  late PlayerController controller;
  late PlayerAnimator animator;
  late PlayerStats stats; // Additional components specific to Player
  late HealthComponent health;
  late AetherComponent aether;
  late InputComponent input;

  // Physics coordination interface for position queries (PHY-3.3.1)
  IPhysicsCoordinator? _physicsCoordinator;
  // Movement coordination interface for movement requests (PHY-3.3.2-Bis.2)
  IMovementCoordinator? _movementCoordinator;
  Player({
    Vector2? position,
    super.size,
  }) : super(
          position: position ?? Vector2.zero(),
          id: 'player',
          type: 'player',
        ) {
    // Initialize stats in constructor to prevent LateInitializationError
    stats = PlayerStats();
  }
  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

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

    // Initialize sprite component (inherited from Entity)
    sprite = AdvSpriteComponent(
      size: size, 
      opacity: 1.0,
    );
    add(sprite!);

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
    // PHY-3.3.1 & PHY-3.3.2: Assign coordinators from gameRef
    // gameRef is guaranteed to be available in onLoad/onMount, which calls setupEntity.
    _physicsCoordinator = game.physicsSystem;
    _movementCoordinator = game.movementSystem;

    controller = PlayerController(
      this,
      movementCoordinator: _movementCoordinator,
      physicsCoordinator: _physicsCoordinator,
    );
    animator = PlayerAnimator(this);
    add(controller);
    add(animator);
    add(stats); // Implementation needed: Load player sprites
    // Implementation needed: Set initial position
    // Implementation needed: Configure physics properties
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

  /// Get current player position through physics coordinator (PHY-3.3.1)
  /// This replaces direct position access to enforce position ownership
  Future<Vector2> getPlayerPosition() async {
    if (_physicsCoordinator == null) {
      // Fallback validation: unauthorized direct position access attempt
      _validatePositionAccess('getPlayerPosition');
      return position; // Temporary fallback during transition
    } // Use physics coordinator for proper position queries
    // Use entity hashCode as entityId (consistent with physics system _findEntityById)
    return await _physicsCoordinator!.getPosition(hashCode);
  }

  /// Legacy getter for backward compatibility (PHY-3.3.1)
  /// @deprecated Use getPlayerPosition() instead for proper position queries
  Vector2 get playerPosition {
    // Validation for unauthorized position access attempts
    _validatePositionAccess('playerPosition getter');
    return position; // Temporary fallback during transition
  }

  /// Get the input component for external system integration
  InputComponent get inputComponent =>
      input; // T2.3.1: Jump mechanics integration with PhysicsComponent
  /// Attempt to perform a jump if conditions are met
  /// Returns a `Future<bool>` indicating if jump was executed
  Future<bool> tryJump({double? customForce}) async {
    // Use the controller's new async public method
    return await controller.attemptJump();
  }

  /// Check if player can currently jump
  /// Returns a `Future<bool>` for async compatibility with the refactored controller
  Future<bool> canJump() async => await controller.canPerformJump();

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
  Future<Map<String, dynamic>> getJumpDebugInfo() async {
    return {
      'jumpState': jumpState.toString(),
      'isGrounded': isGrounded,
      'canJump': await canJump(),
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

  // ============================================================================
  // PHY-3.3.2-Bis.2: Movement Coordinator Integration
  // ============================================================================
  /// Inject movement coordinator for movement requests (PHY-3.3.2-Bis.2)
  /// This method should be called by the movement system during entity setup
  void setMovementCoordinator(IMovementCoordinator coordinator) {
    _movementCoordinator = coordinator;
    print('[Player] Movement coordinator injected for movement requests');

    // Update controller with new coordinator if already initialized
    controller.setMovementCoordinator(coordinator);
  }

  /// Submit movement request through coordinator (PHY-3.3.2-Bis.2)
  /// Provides proper movement request submission for player actions
  Future<bool> requestMovement({
    required Vector2 direction,
    required double speed,
    MovementType type = MovementType.walk,
  }) async {
    if (_movementCoordinator == null) {
      print(
        '[Player] WARNING: Movement coordinator not available - using fallback',
      );
      // Fallback to direct physics manipulation (temporary during transition)
      physics?.setVelocity(Vector2(direction.x * speed, physics!.velocity.y));
      return true;
    } // Use movement coordinator for proper request processing
    final request = MovementRequest(
      entityId: hashCode,
      direction: direction,
      magnitude: speed,
      type: type,
      priority: MovementPriority.high, // Player movement has high priority
    );

    final response = await _movementCoordinator!.submitMovementRequest(request);
    return response.status == MovementResponseStatus.success;
  }

  // ============================================================================
  // PHY-3.3.1: Physics Coordinator Integration
  // ============================================================================
  /// Inject physics coordinator for position queries (PHY-3.3.1)
  /// This method should be called by the physics system during entity setup
  void setPhysicsCoordinator(IPhysicsCoordinator coordinator) {
    _physicsCoordinator = coordinator;
    print('[Player] Physics coordinator injected for position queries');
  }

  /// Get comprehensive physics state through coordinator (PHY-3.3.1)
  /// Provides full physics information for systems that need detailed state
  Future<Vector2> getPhysicsPosition() async {
    if (_physicsCoordinator == null) {
      _validatePositionAccess('getPhysicsPosition');
      return position;
    }
    return await _physicsCoordinator!.getPosition(hashCode);
  }

  /// Get physics velocity through coordinator (PHY-3.3.1)
  /// Replaces direct velocity access to maintain consistency
  Future<Vector2> getPhysicsVelocity() async {
    if (_physicsCoordinator == null) {
      _validatePositionAccess('getPhysicsVelocity');
      return physics?.velocity ?? Vector2.zero();
    }
    return await _physicsCoordinator!.getVelocity(hashCode);
  }

  /// Check grounded state through coordinator (PHY-3.3.1)
  /// Provides authoritative ground contact information
  Future<bool> getPhysicsGroundedState() async {
    if (_physicsCoordinator == null) {
      _validatePositionAccess('getPhysicsGroundedState');
      return physics?.isOnGround ?? false;
    }
    return await _physicsCoordinator!.isGrounded(hashCode);
  }

  /// Validate unauthorized position access attempts (PHY-3.3.1)
  /// Logs violations and helps identify code that needs refactoring
  void _validatePositionAccess(String accessMethod) {
    print('[Player] WARNING: Direct position access via $accessMethod - '
        'This violates position ownership. Use physics coordinator queries instead.');

    // In development, we could throw an exception to force proper usage:
    // throw StateError('Direct position access not allowed. Use getPlayerPosition() instead.');
  }
}

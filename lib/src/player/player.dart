import 'package:flame/components.dart';

import '../components/adv_sprite_component.dart';
import '../components/aether_component.dart';
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
  late PlayerStats stats;

  // Additional components specific to Player
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
    // Initialize physics component (inherited from Entity)
    physics = PhysicsComponent();
    add(physics!);

    // Initialize sprite component (inherited from Entity)
    sprite = AdvSpriteComponent();
    add(sprite!);

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
    add(aether);

    // Initialize subsystems
    controller = PlayerController(this);
    animator = PlayerAnimator(this);
    stats = PlayerStats();
    add(controller);
    add(animator);

    // Implementation needed: Load player sprites
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
}

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
    Vector2? size,
  }) : super(
          position: position ?? Vector2.zero(),
          size: size,
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
  InputComponent get inputComponent => input;
}

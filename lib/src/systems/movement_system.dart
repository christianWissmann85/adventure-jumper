import 'package:flame/components.dart';

import '../components/physics_component.dart';
import '../components/transform_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';

/// System that manages entity movement processing
/// Handles velocity application, position updates, and movement constraints
class MovementSystem extends BaseFlameSystem {
  MovementSystem() : super();

  // Configuration
  double _globalTimeScale = 1;

  @override
  bool canProcessEntity(Entity entity) {
    // Only process entities with physics components
    return entity.physics != null;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Apply scaled time
    final double scaledDt = dt * _globalTimeScale;

    // Process entity movement
    final TransformComponent transform = entity.transformComponent;
    final PhysicsComponent physics =
        entity.physics!; // Safe now with canProcessEntity check

    // Skip static entities (don't move)
    if (physics.isStatic) return;

    // Note: Gravity and physics are now handled by PhysicsSystem
    // This system only handles position updates based on velocity

    // Apply velocity to position
    final Vector2 velocity = physics.velocity;
    if (velocity.x != 0 || velocity.y != 0) {
      final Vector2 oldPosition = transform.position.clone();
      final Vector2 newPosition = transform.position + (velocity * scaledDt);
      transform.setPosition(newPosition);

      // Update entity position to match transform
      entity.position = newPosition;

      // Debug output for position changes
      if ((velocity.x.abs() > 1.0 || velocity.y.abs() > 1.0)) {
        print(
            'Movement: Entity ${entity.id} moved from ${oldPosition.x.toStringAsFixed(1)},${oldPosition.y.toStringAsFixed(1)} to ${newPosition.x.toStringAsFixed(1)},${newPosition.y.toStringAsFixed(1)} (velocity: ${velocity.x.toStringAsFixed(1)},${velocity.y.toStringAsFixed(1)})');
      }
    }
  }

  /// Set global time scale for all movement
  void setTimeScale(double timeScale) {
    _globalTimeScale = timeScale;
  }

  // Getters
  double get timeScale => _globalTimeScale;

  @override
  void initialize() {
    // Initialize movement system
  }
}

import 'package:flame/components.dart';

import '../components/adv_sprite_component.dart';
import '../components/collision_component.dart';
import '../components/physics_component.dart';
import '../components/transform_component.dart';

/// Base entity class for all game objects
/// Provides common functionality for entities in the game world
abstract class Entity extends PositionComponent {
  Entity({
    required Vector2 super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    String? id,
    String? type,
  }) {
    if (id != null) _id = id;
    if (type != null) _type = type;
  } // Common properties for all entities
  late TransformComponent transformComponent;
  late CollisionComponent collision;
  // Optional components (may be null if not needed)
  PhysicsComponent? physics;
  AdvSpriteComponent? sprite;

  // Entity state
  bool _isActive = true;
  String _id = '';
  String _type = 'entity';

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Create and add required components
    transformComponent = TransformComponent();
    collision = CollisionComponent();
    add(transformComponent);
    add(collision);

    // Setup entity-specific components
    await setupEntity();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    // Entity-specific update logic
    updateEntity(dt);
  }

  /// Custom entity setup (to be implemented by subclasses)
  Future<void> setupEntity() async {
    // Override in subclasses
  }

  /// Custom entity update logic (to be implemented by subclasses)
  void updateEntity(double dt) {
    // Override in subclasses
  }

  /// Handle collision with another entity
  void onCollision(Entity other) {
    // Override in subclasses
  }

  /// Activate the entity
  void activate() {
    _isActive = true;
  }

  /// Deactivate the entity
  void deactivate() {
    _isActive = false;
  }

  /// Get entity ID
  String get id => _id;

  /// Get entity type
  String get type => _type;

  /// Check if entity is active
  bool get isActive => _isActive;
}

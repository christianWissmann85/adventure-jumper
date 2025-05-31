import 'dart:ui';

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

  // Collision callback - this is assignable from external code
  Function(Entity)? onCollision;

  @override
  Future<void> onLoad() async {
    print('[Entity] onLoad() called - id: $_id, type: $_type');
    await super.onLoad();

    // Create and add required components
    transformComponent = TransformComponent();
    collision = CollisionComponent();
    await add(transformComponent);
    await add(collision);

    // Setup entity-specific components after components are added
    await setupEntity();
    print(
      '[Entity] onLoad() completed - id: $_id, type: $_type, children: ${children.length}',
    );
  }

  @override
  void onMount() {
    print('[Entity] onMount() called - id: $_id, type: $_type');
    super.onMount();
    print(
      '[Entity] onMount() completed - id: $_id, type: $_type, isMounted: $isMounted',
    );
  }

  @override
  void onGameResize(Vector2 size) {
    print(
      '[Entity] onGameResize() called - id: $_id, type: $_type, size: $size',
    );
    super.onGameResize(size);
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

  /// Trigger collision with another entity
  void triggerCollision(Entity other) {
    // Call collision callback if set
    onCollision?.call(other);
  }

  /// Activate the entity
  void activate() {
    _isActive = true;
  }

  /// Deactivate the entity
  void deactivate() {
    _isActive = false;
  }

  @override
  void render(Canvas canvas) {
    // Add debug print to track Entity render calls
    print(
      '[Entity] RENDER METHOD CALLED - id: $_id, type: $_type, children: ${children.length}',
    );

    // Always call super.render to ensure the component tree is processed correctly
    super.render(canvas);
  }

  /// Get entity ID
  String get id => _id;

  /// Get entity type
  String get type => _type;

  /// Check if entity is active
  bool get isActive => _isActive;
}

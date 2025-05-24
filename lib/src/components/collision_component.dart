import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Component that handles collision detection and response
/// Provides utilities for managing hitboxes and collision events
class CollisionComponent extends Component with CollisionCallbacks {
  CollisionComponent({
    Vector2? hitboxSize,
    Vector2? hitboxOffset,
    bool? isActive,
    bool? isOneWay,
    List<String>? collisionTags,
  }) {
    if (hitboxSize != null) _hitboxSize = hitboxSize;
    if (hitboxOffset != null) _hitboxOffset = hitboxOffset;
    if (isActive != null) _isActive = isActive;
    if (isOneWay != null) _isOneWay = isOneWay;
    if (collisionTags != null) _collisionTags = collisionTags;
  }

  // Collision properties
  Vector2 _hitboxSize = Vector2.zero();
  Vector2 _hitboxOffset = Vector2.zero();
  bool _isActive = true;
  bool _isOneWay = false;
  List<String> _collisionTags = <String>['default'];

  // Hitbox components
  late ShapeHitbox _hitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize hitbox
    if (parent is PositionComponent) {
      final PositionComponent parentComp = parent as PositionComponent;

      // Default hitbox size to parent size if not specified
      if (_hitboxSize == Vector2.zero() && parentComp.size != Vector2.zero()) {
        _hitboxSize = parentComp.size.clone();
      }

      // Create appropriate hitbox shape
      _hitbox = RectangleHitbox(
        size: _hitboxSize,
        position: _hitboxOffset,
        isSolid: !_isOneWay,
      );

      // Add hitbox to parent
      parentComp.add(_hitbox);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update collision active state
    if (_hitbox.isMounted) {
      // Note: Flame collision components manage their own active state
      // We can check isActive instead of setting it
    }
  }

  /// Set hitbox size
  void setHitboxSize(Vector2 size) {
    _hitboxSize = size.clone();
    if (_hitbox.isMounted) {
      (_hitbox as RectangleHitbox).size = size;
    }
  }

  /// Set hitbox offset from parent position
  void setHitboxOffset(Vector2 offset) {
    _hitboxOffset = offset.clone();
    if (_hitbox.isMounted) {
      _hitbox.position = offset;
    }
  }

  /// Set collision active state
  void setActive(bool active) {
    _isActive = active;
    if (_hitbox.isMounted) {
      // Note: ShapeHitbox doesn't have an active setter in current Flame version
      // Active state is managed internally by the collision system
    }
  }

  /// Add a collision tag
  void addCollisionTag(String tag) {
    if (!_collisionTags.contains(tag)) {
      _collisionTags.add(tag);
    }
  }

  /// Remove a collision tag
  void removeCollisionTag(String tag) {
    _collisionTags.remove(tag);
  }

  /// Check if entity has a specific collision tag
  bool hasCollisionTag(String tag) {
    return _collisionTags.contains(tag);
  }

  // Getters/setters
  Vector2 get hitboxSize => _hitboxSize;
  Vector2 get hitboxOffset => _hitboxOffset;
  bool get isActive => _isActive;
  set isOneWay(bool value) => _isOneWay = value;
  bool get isOneWay => _isOneWay;
  List<String> get collisionTags => _collisionTags;
  ShapeHitbox get hitbox => _hitbox;
}

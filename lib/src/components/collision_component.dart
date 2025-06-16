import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../systems/interfaces/collision_notifier.dart' as notifier;
import '../systems/interfaces/physics_state.dart';
import '../utils/logger.dart';
import 'interfaces/collision_integration.dart';

/// PHY-3.1.3: Enhanced CollisionComponent with collision system coordination
///
/// Component that handles collision detection and response
/// Provides utilities for managing hitboxes and collision events
///
/// Key enhancements:
/// - Collision state management and grounded state tracking
/// - Collision event generation and physics coordination
/// - Integration with ICollisionNotifier interface patterns
/// - Movement validation based on collision state
class CollisionComponent extends Component
    with CollisionCallbacks
    implements ICollisionIntegration {
  CollisionComponent({
    Vector2? hitboxSize,
    Vector2? hitboxOffset,
    bool? isActive,
    bool? isOneWay,
    List<String>? collisionTags,
    bool createTestHitbox = true,
    notifier.SurfaceMaterial? surfaceMaterial, // Added for surface material
  }) {
    if (hitboxSize != null) _hitboxSize = hitboxSize;
    if (hitboxOffset != null) _hitboxOffset = hitboxOffset;
    if (isActive != null) _isActive = isActive;
    if (isOneWay != null) this.isOneWay = isOneWay;
    if (collisionTags != null) _collisionTags = collisionTags;
    this.surfaceMaterial = surfaceMaterial ?? notifier.SurfaceMaterial.none; // Initialize surfaceMaterial

    // Create a hitbox immediately for testing if needed
    if (createTestHitbox &&
        hitboxSize != null &&
        hitboxSize != Vector2.zero()) {
      _hitbox = RectangleHitbox(
        size: _hitboxSize,
        position: _hitboxOffset,
        isSolid: !this.isOneWay,
      );
    }
  }

  // Collision properties
  Vector2 _hitboxSize = Vector2.zero();
  Vector2 _hitboxOffset = Vector2.zero();
  bool _isActive = true;
  bool isOneWay = false;
  List<String> _collisionTags = <String>['default'];
  late final notifier.SurfaceMaterial surfaceMaterial; // Added for surface material
  // Hitbox components
  ShapeHitbox? _hitbox;

  // PHY-3.1.3: Collision state management
  final List<CollisionInfo> _activeCollisions = [];
  notifier.GroundInfo? _groundInfo;
  bool _isColliding = false;

  // Logger for collision events
  static final _logger = GameLogger.getLogger('CollisionComponent');

  // Coyote time configuration
  static const Duration _kCoyoteTimeDuration = Duration(milliseconds: 150);

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
        isSolid: !isOneWay,
      );

      // Add hitbox to parent
      parentComp.add(_hitbox!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update collision active state
    if (_hitbox != null && _hitbox!.isMounted) {
      // Note: Flame collision components manage their own active state
      // We can check isActive instead of setting it
    }
  }

  /// Set hitbox size
  void setHitboxSize(Vector2 size) {
    _hitboxSize = size.clone();
    // Only update hitbox if it has been initialized and mounted
    if (_hitbox != null && _hitbox!.isMounted) {
      (_hitbox as RectangleHitbox).size = size;
    }
  }

  /// Set hitbox offset from parent position
  void setHitboxOffset(Vector2 offset) {
    _hitboxOffset = offset.clone();
    // Only update hitbox if it has been initialized and mounted
    if (_hitbox != null && _hitbox!.isMounted) {
      _hitbox!.position = offset;
    }
  }

  /// Set collision active state
  void setActive(bool active) {
    _isActive = active;
    if (_hitbox != null && _hitbox!.isMounted) {
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
  List<String> get collisionTags => List.unmodifiable(_collisionTags);
  ShapeHitbox get hitbox {
    if (_hitbox == null) {
      // Create a test hitbox if not initialized yet (for tests)
      if (_hitboxSize != Vector2.zero()) {
        _hitbox = RectangleHitbox(
          size: _hitboxSize,
          position: _hitboxOffset,
          isSolid: !isOneWay,
        );
      } else {
        throw StateError('Hitbox accessed before initialization. '
            'In tests, make sure to provide a hitboxSize.');
      }
    }
    return _hitbox!;
  }

  // ============================================================================
  // PHY-3.1.3: ICollisionIntegration Implementation
  // ============================================================================

  @override
  Future<void> processCollisionEvent(CollisionEvent event) async {
    _logger.fine(
        'Processing collision event: ${event.type} for entity ${event.entityId}',);

    switch (event.type) {
      case CollisionEventType.collisionStart:
        _activeCollisions.add(event.collisionInfo);
        _isColliding = true;
        onCollisionEnter(event.collisionInfo);
        break;

      case CollisionEventType.collisionEnd:
        _activeCollisions.removeWhere(
            (c) => c.collisionId == event.collisionInfo.collisionId,);
        _isColliding = _activeCollisions.isNotEmpty;
        onCollisionExit(event.collisionInfo);
        break;

      case CollisionEventType.collisionUpdate:
        // Update existing collision info
        final index = _activeCollisions.indexWhere(
            (c) => c.collisionId == event.collisionInfo.collisionId,);
        if (index >= 0) {
          _activeCollisions[index] = event.collisionInfo;
        }
        break;

      case CollisionEventType.groundContact:
      case CollisionEventType.groundLost:
        // Handle through updateGroundState
        break;
    }
  }

  @override
  Future<void> updateGroundState(notifier.GroundInfo groundInfo) async {
    final wasGrounded = _groundInfo?.isGrounded ?? false;
    _groundInfo = groundInfo;

    // Notify if ground state changed
    if (groundInfo.isGrounded != wasGrounded) {
      onGroundContact(groundInfo);

      _logger.fine(groundInfo.isGrounded
          ? 'Ground contact detected'
          : 'Ground contact lost',);
    }
  }

  @override
  Future<bool> validateMovement(Vector2 movement) async {
    // Check if movement would cause collision
    final predictedCollisions = await predictCollisions(movement);

    // Allow movement if no blocking collisions predicted
    for (final collision in predictedCollisions) {
      if (collision.collisionType == 'wall' ||
          collision.collisionType == 'solid') {
        return false;
      }
    }

    return true;
  }

  @override
  Future<List<CollisionInfo>> getActiveCollisions() async {
    return List.unmodifiable(_activeCollisions);
  }

  @override
  Future<bool> hasActiveCollisions() async {
    return _isColliding;
  }

  @override
  Future<notifier.GroundInfo?> getGroundInfo() async {
    return _groundInfo;
  }

  /// Returns true if the entity is currently on the ground or within the coyote time window.
  Future<bool> isEffectivelyGrounded() async {
    final groundInfo = _groundInfo; // groundInfo is of type notifier.GroundInfo?

    if (groundInfo?.isGrounded ?? false) { // Handles case where groundInfo is null or isGrounded is false
      return true;
    }

    // At this point, either groundInfo is null, or groundInfo.isGrounded is false.
    // We only care about coyote time if groundInfo is not null and isGrounded was false.
    if (groundInfo != null) {
      // Now we know groundInfo is not null.
      // groundInfo.lastGroundedTime is non-nullable DateTime, so lastTimeGrounded is also non-nullable.
      final lastTimeGrounded = groundInfo.lastGroundedTime;
      final timeSinceLeftGround = DateTime.now().difference(lastTimeGrounded);
      if (timeSinceLeftGround <= _kCoyoteTimeDuration) {
        _logger.finer('Coyote time active: ${timeSinceLeftGround.inMilliseconds}ms since left ground.');
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<CollisionInfo>> predictCollisions(Vector2 movement) async {
    // This would typically query the collision system for potential collisions
    // For now, return empty list as this requires collision system integration
    _logger.fine('Predicting collisions for movement: $movement');
    return [];
  }

  @override
  Future<bool> isMovementBlocked(Vector2 direction) async {
    // Check active collisions for blocking in the given direction
    for (final collision in _activeCollisions) {
      // Consider only collisions that are inherently blocking (like walls or ceilings)
      final isBlockingType = collision.collisionType == notifier.CollisionType.wall.name ||
                             collision.collisionType == notifier.CollisionType.ceiling.name;

      if (isBlockingType) {
        // Check if collision normal opposes movement direction
        final dotProduct = collision.contactNormal.dot(direction.normalized());
        if (dotProduct < -0.7) { // Threshold for opposing directions
          _logger.finer('Movement blocked by ${collision.collisionType} (normal: ${collision.contactNormal}, direction: $direction)');
          return true;
        }
      }
    }
    return false;
  }

  @override
  void onCollisionEnter(CollisionInfo collision) {
    _logger.fine(
        'Collision entered: ${collision.collisionType} with ${collision.collisionId}',);

    // Handle specific collision types
    if (collision.collisionType == 'ground') {
      // Ground collision handled by updateGroundState
    }
  }

  @override
  void onCollisionExit(CollisionInfo collision) {
    _logger.fine(
        'Collision exited: ${collision.collisionType} with ${collision.collisionId}',);
  }

  @override
  void onGroundContact(notifier.GroundInfo groundInfo) {
    _logger.fine(groundInfo.isGrounded
        ? 'Grounded on ${groundInfo.groundSurface.material.name} surface'
        : 'Left ground',);
  }

  @override
  Future<void> syncWithPhysics(PhysicsState physicsState) async {
    // Sync collision state with physics state

    // Update ground state from physics
    if (physicsState.isGrounded != (_groundInfo?.isGrounded ?? false)) {
      if (physicsState.isGrounded) {
        // Create ground info from physics state
        final groundCollision = physicsState.activeCollisions
            .firstWhere((c) => c.collisionType == 'ground',
                orElse: () => CollisionInfo.ground(
                      id: 'physics_ground',
                      contactPoint: physicsState.position,
                    ),);

        await updateGroundState(notifier.GroundInfo.grounded(
          entityId: parent?.hashCode ?? 0,
          groundNormal: groundCollision.contactNormal,
          surface: notifier.CollisionSurface.solid(),
        ),);
      } else {
        await updateGroundState(notifier.GroundInfo.airborne(
          parent?.hashCode ?? 0,
          _groundInfo?.lastGroundedTime ?? DateTime.now(),
        ),);
      }
    }

    // Sync active collisions
    _activeCollisions.clear();
    _activeCollisions.addAll(physicsState.activeCollisions);
    _isColliding = _activeCollisions.isNotEmpty;
  }

  @override
  Future<void> clearCollisionState() async {
    _activeCollisions.clear();
    _groundInfo = null;
    _isColliding = false;

    _logger.fine('Collision state cleared');
  }

  // ============================================================================
  // Flame Collision Callbacks Integration
  // ============================================================================

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other,) {
    super.onCollisionStart(intersectionPoints, other);

    // Convert Flame collision to our collision info
    final collision = CollisionInfo(
      collisionId: other.hashCode.toString(),
      collisionType: _determineCollisionType(other),
      contactPoint: intersectionPoints.first,
      contactNormal: _calculateContactNormal(intersectionPoints, other),
    );

    // Process through our system
    processCollisionEvent(CollisionEvent(
      entityId: parent?.hashCode.toString() ?? 'unknown',
      type: CollisionEventType.collisionStart,
      collisionInfo: collision,
    ),);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    // Find and remove the collision
    final collisionId = other.hashCode.toString();
    final collision = _activeCollisions.firstWhere(
      (c) => c.collisionId == collisionId,
      orElse: () => CollisionInfo(
        collisionId: collisionId,
        collisionType: 'unknown',
        contactPoint: Vector2.zero(),
        contactNormal: Vector2(0, -1),
      ),
    );

    processCollisionEvent(CollisionEvent(
      entityId: parent?.hashCode.toString() ?? 'unknown',
      type: CollisionEventType.collisionEnd,
      collisionInfo: collision,
    ),);
  }

  // Helper methods for Flame collision integration
  String _determineCollisionType(PositionComponent other) {
    // Determine collision type based on component type or tags
    final typeName = other.runtimeType.toString().toLowerCase();

    if (typeName.contains('platform') || typeName.contains('ground')) {
      return 'ground';
    } else if (typeName.contains('wall')) {
      return 'wall';
    } else if (typeName.contains('enemy')) {
      return 'enemy';
    }

    return 'solid';
  }

  Vector2 _calculateContactNormal(
      Set<Vector2> intersectionPoints, PositionComponent other,) {
    // Simple normal calculation - can be enhanced
    if (intersectionPoints.isEmpty) return Vector2(0, -1);

    final otherCenter = other.position + (other.size / 2);
    final thisCenter =
        (parent as PositionComponent?)?.position ?? Vector2.zero();

    final direction = (thisCenter - otherCenter).normalized();
    return direction;
  }
}

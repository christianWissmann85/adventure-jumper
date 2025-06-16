import 'package:flame/components.dart';

/// Collision information for physics state tracking.
///
/// Represents individual collision events or contact points that are
/// currently affecting the entity's physics state.
class CollisionInfo {
  /// Identifier of the colliding entity or surface
  final String collisionId;

  /// Type of collision (ground, wall, ceiling, entity, etc.)
  final String collisionType;

  /// Contact point in world coordinates
  final Vector2 contactPoint;

  /// Normal vector of the collision surface
  final Vector2 contactNormal;

  /// Penetration depth (if applicable)
  final double penetrationDepth;

  /// Whether this collision is currently active
  final bool isActive;

  /// Timestamp when collision was detected
  final DateTime detectedAt;

  CollisionInfo({
    required this.collisionId,
    required this.collisionType,
    required this.contactPoint,
    required this.contactNormal,
    this.penetrationDepth = 0.0,
    this.isActive = true,
  }) : detectedAt = DateTime.now();

  /// Create ground collision info.
  factory CollisionInfo.ground({
    required String id,
    required Vector2 contactPoint,
    Vector2? normal,
    double penetrationDepth = 0.0,
  }) {
    return CollisionInfo(
      collisionId: id,
      collisionType: 'ground',
      contactPoint: contactPoint,
      contactNormal: normal ?? Vector2(0, -1),
      penetrationDepth: penetrationDepth,
    );
  }

  /// Create wall collision info.
  factory CollisionInfo.wall({
    required String id,
    required Vector2 contactPoint,
    required Vector2 normal,
    double penetrationDepth = 0.0,
  }) {
    return CollisionInfo(
      collisionId: id,
      collisionType: 'wall',
      contactPoint: contactPoint,
      contactNormal: normal,
      penetrationDepth: penetrationDepth,
    );
  }

  /// Get collision age in milliseconds.
  int get ageInMilliseconds {
    return DateTime.now().difference(detectedAt).inMilliseconds;
  }

  @override
  String toString() {
    return 'CollisionInfo(id: $collisionId, type: $collisionType, active: $isActive)';
  }
}

/// Comprehensive physics state information for an entity.
///
/// This class provides a complete snapshot of an entity's physics state,
/// including position, velocity, forces, collision information, and
/// internal physics system state. Used for system coordination, debugging,
/// and state validation.
///
/// **Design Principles:**
/// - Immutable snapshot of physics state at a specific time
/// - Comprehensive information for all physics-related systems
/// - Built-in validation and consistency checking
/// - Performance monitoring and accumulation detection
///
/// **Usage Example:**
/// ```dart
/// final state = await physicsCoordinator.getPhysicsState(playerId);
///
/// if (state.hasAccumulation) {
///   // Trigger accumulation prevention
///   await physicsCoordinator.clearAccumulatedForces(playerId);
/// }
///
/// if (state.isGrounded && !state.wasGrounded) {
///   // Landing detected - trigger landing effects
///   audioSystem.playLandingSound();
/// }
/// ```
class PhysicsState {
  /// Entity identifier this state belongs to
  final int entityId;

  /// Current position in world coordinates
  final Vector2 position;

  /// Current velocity vector
  final Vector2 velocity;

  /// Current acceleration vector
  final Vector2 acceleration;

  /// Entity mass
  final double mass;

  /// Gravity scale factor applied to this entity
  final double gravityScale;

  /// Current friction coefficient
  final double friction;

  /// Current restitution (bounce) factor
  final double restitution;

  /// Whether entity is static (not affected by physics)
  final bool isStatic;

  /// Whether entity is affected by gravity
  final bool affectedByGravity;

  /// Current grounded state
  final bool isGrounded;

  /// Previous grounded state (for transition detection)
  final bool wasGrounded;

  /// List of active collisions
  final List<CollisionInfo> activeCollisions;

  /// Accumulated forces that will be applied next physics update
  final Vector2 accumulatedForces;

  /// Number of contact points currently active
  final int contactPointCount;

  /// Internal physics update counter (for accumulation detection)
  final int updateCount;

  /// Last physics update timestamp
  final DateTime lastUpdateTime;

  /// Timestamp when this state snapshot was created
  final DateTime snapshotTime;

  /// Additional debug information
  final Map<String, dynamic>? debugData;

  /// Create a physics state snapshot.
  PhysicsState({
    required this.entityId,
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.mass,
    required this.gravityScale,
    required this.friction,
    required this.restitution,
    required this.isStatic,
    required this.affectedByGravity,
    required this.isGrounded,
    required this.wasGrounded,
    required this.activeCollisions,
    required this.accumulatedForces,
    required this.contactPointCount,
    required this.updateCount,
    required this.lastUpdateTime,
    this.debugData,
  }) : snapshotTime = DateTime.now();

  /// Create a default/clean physics state.
  ///
  /// Useful for resetting entity physics or creating initial states.
  factory PhysicsState.clean({
    required int entityId,
    required Vector2 position,
    double mass = 1.0,
    double gravityScale = 1.0,
    double friction = 0.1,
    double restitution = 0.0,
    bool isStatic = false,
    bool affectedByGravity = true,
  }) {
    return PhysicsState(
      entityId: entityId,
      position: position,
      velocity: Vector2.zero(),
      acceleration: Vector2.zero(),
      mass: mass,
      gravityScale: gravityScale,
      friction: friction,
      restitution: restitution,
      isStatic: isStatic,
      affectedByGravity: affectedByGravity,
      isGrounded: false,
      wasGrounded: false,
      activeCollisions: const [],
      accumulatedForces: Vector2.zero(),
      contactPointCount: 0,
      updateCount: 0,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Check if entity is currently moving.
  ///
  /// **Parameters:**
  /// - [threshold]: Minimum velocity magnitude to consider as moving (default: 0.1)
  ///
  /// **Returns:** true if velocity magnitude exceeds threshold
  bool isMoving([double threshold = 0.1]) {
    return velocity.length > threshold;
  }

  /// Check if entity is falling.
  ///
  /// **Returns:** true if entity has significant downward velocity and is not grounded
  bool get isFalling {
    return !isGrounded && velocity.y > 10.0; // Falling threshold
  }

  /// Check if entity is jumping.
  ///
  /// **Returns:** true if entity has upward velocity
  bool get isJumping {
    return velocity.y < -10.0; // Jump threshold (negative Y is up)
  }

  /// Check for physics value accumulation issues.
  ///
  /// **CRITICAL FOR BUG RESOLUTION**: Detects the accumulation patterns
  /// that cause progressive movement slowdown and complete stoppage.
  ///
  /// **Detection Criteria:**
  /// - Excessive accumulated forces
  /// - Abnormally high friction/restitution values
  /// - Too many contact points
  /// - Rapidly increasing update counts
  ///
  /// **Returns:** true if accumulation is detected
  bool get hasAccumulation {
    // Check for excessive accumulated forces
    if (accumulatedForces.length > 1000.0) return true;

    // Check for abnormal friction/restitution buildup
    if (friction > 0.5 || restitution > 1.0) return true;

    // Check for excessive contact points
    if (contactPointCount > 10) return true;

    // Check for extremely high velocity (may indicate accumulation)
    if (velocity.length > 2000.0) return true;

    return false;
  }

  /// Check if physics state values are valid (finite, not NaN).
  ///
  /// **Returns:** true if all values are valid for physics processing
  bool get isValid {
    // Check position validity
    if (!position.x.isFinite || !position.y.isFinite) return false;

    // Check velocity validity
    if (!velocity.x.isFinite || !velocity.y.isFinite) return false;

    // Check acceleration validity
    if (!acceleration.x.isFinite || !acceleration.y.isFinite) return false;

    // Check accumulated forces validity
    if (!accumulatedForces.x.isFinite || !accumulatedForces.y.isFinite) {
      return false;
    }

    // Check physics properties validity
    if (!mass.isFinite || mass <= 0) return false;
    if (!gravityScale.isFinite) return false;
    if (!friction.isFinite || friction < 0) return false;
    if (!restitution.isFinite || restitution < 0) return false;

    return true;
  }

  /// Check if grounded state changed since last update.
  ///
  /// **Returns:** true if grounded state transitioned
  bool get groundedStateChanged {
    return isGrounded != wasGrounded;
  }

  /// Check if entity just landed.
  ///
  /// **Returns:** true if entity transitioned from not grounded to grounded
  bool get justLanded {
    return isGrounded && !wasGrounded;
  }

  /// Check if entity just left ground.
  ///
  /// **Returns:** true if entity transitioned from grounded to not grounded
  bool get justLeftGround {
    return !isGrounded && wasGrounded;
  }

  /// Get ground collision information.
  ///
  /// **Returns:** First ground collision found, or null if not grounded
  CollisionInfo? get groundCollision {
    for (final collision in activeCollisions) {
      if (collision.collisionType == 'ground' && collision.isActive) {
        return collision;
      }
    }
    return null;
  }

  /// Get wall collisions.
  ///
  /// **Returns:** List of active wall collisions
  List<CollisionInfo> get wallCollisions {
    return activeCollisions
        .where((c) => c.collisionType == 'wall' && c.isActive)
        .toList();
  }

  /// Get total kinetic energy.
  ///
  /// **Returns:** Current kinetic energy (0.5 * mass * velocity^2)
  double get kineticEnergy {
    return 0.5 * mass * velocity.length2;
  }

  /// Get physics state age in milliseconds.
  ///
  /// **Returns:** Time elapsed since last physics update
  int get stateAgeMs {
    return DateTime.now().difference(lastUpdateTime).inMilliseconds;
  }

  /// Check if physics state is stale.
  ///
  /// **Parameters:**
  /// - [thresholdMs]: Staleness threshold in milliseconds (default: 100ms)
  ///
  /// **Returns:** true if state hasn't been updated recently
  bool isStale([int thresholdMs = 100]) {
    return stateAgeMs > thresholdMs;
  }

  /// Create a copy of this state with modified parameters.
  ///
  /// Useful for state transformation or testing.
  PhysicsState copyWith({
    int? entityId,
    Vector2? position,
    Vector2? velocity,
    Vector2? acceleration,
    double? mass,
    double? gravityScale,
    double? friction,
    double? restitution,
    bool? isStatic,
    bool? affectedByGravity,
    bool? isGrounded,
    bool? wasGrounded,
    List<CollisionInfo>? activeCollisions,
    Vector2? accumulatedForces,
    int? contactPointCount,
    int? updateCount,
    DateTime? lastUpdateTime,
    Map<String, dynamic>? debugData,
  }) {
    return PhysicsState(
      entityId: entityId ?? this.entityId,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      acceleration: acceleration ?? this.acceleration,
      mass: mass ?? this.mass,
      gravityScale: gravityScale ?? this.gravityScale,
      friction: friction ?? this.friction,
      restitution: restitution ?? this.restitution,
      isStatic: isStatic ?? this.isStatic,
      affectedByGravity: affectedByGravity ?? this.affectedByGravity,
      isGrounded: isGrounded ?? this.isGrounded,
      wasGrounded: wasGrounded ?? this.wasGrounded,
      activeCollisions: activeCollisions ?? this.activeCollisions,
      accumulatedForces: accumulatedForces ?? this.accumulatedForces,
      contactPointCount: contactPointCount ?? this.contactPointCount,
      updateCount: updateCount ?? this.updateCount,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      debugData: debugData ?? this.debugData,
    );
  }

  @override
  String toString() {
    return 'PhysicsState('
        'entityId: $entityId, '
        'position: $position, '
        'velocity: $velocity, '
        'grounded: $isGrounded, '
        'moving: ${isMoving()}, '
        'valid: $isValid, '
        'accumulation: $hasAccumulation'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhysicsState &&
        other.entityId == entityId &&
        other.position == position &&
        other.velocity == velocity &&
        other.acceleration == acceleration &&
        other.isGrounded == isGrounded &&
        other.updateCount == updateCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      entityId,
      position,
      velocity,
      acceleration,
      isGrounded,
      updateCount,
    );
  }
}

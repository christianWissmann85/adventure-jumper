import 'package:flame/components.dart';

import '../../utils/math_utils.dart';

/// Collision notification interface for system coordination and event handling.
///
/// This interface establishes the collision notification system for the
/// Physics-Movement System Refactor effort (PHY-2.1.1), providing structured
/// collision event handling and system coordination without position modification.
///
/// **Event-Driven Architecture:**
/// - Collision detection results notification
/// - Grounded state change events
/// - Collision response coordination
/// - System boundary enforcement
///
/// **Design Principles:**
/// - Read-only collision information access
/// - Event-based system coordination
/// - No position modification (physics system ownership)
/// - Performance-optimized event delivery
///
/// **System Integration Pattern:**
/// ```dart
/// // Register for collision events
/// collisionNotifier.addCollisionListener(this);
///
/// // Query collision state for validation
/// if (await collisionNotifier.isGrounded(entityId)) {
///   await processGroundedAction(entityId);
/// }
/// ```
abstract class ICollisionNotifier {
  // ============================================================================
  // Collision Query Interface
  // ============================================================================

  /// Get active collisions for entity.
  ///
  /// Retrieves list of current active collisions for the specified entity.
  /// Used for collision state validation and decision making.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to query for active collisions
  ///
  /// **Returns:** List of active collision information
  ///
  /// **Usage:**
  /// ```dart
  /// final collisions = await notifier.getCollisionsForEntity(playerId);
  /// for (final collision in collisions) {
  ///   processCollisionEffect(collision);
  /// }
  /// ```
  Future<List<CollisionInfo>> getCollisionsForEntity(int entityId);

  /// Detect collisions for entity list.
  ///
  /// Performs collision detection for a list of entities and returns
  /// collision results. Used for batch collision processing.
  ///
  /// **Parameters:**
  /// - [entities]: List of entity identifiers to check for collisions
  ///
  /// **Returns:** List of detected collision information
  Future<List<CollisionInfo>> detectCollisions(List<int> entities);

  /// Check if entity is grounded.
  ///
  /// Determines if entity is currently in contact with ground surface,
  /// including coyote time considerations for forgiving jump mechanics.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check grounded state
  ///
  /// **Returns:** True if entity is grounded or within coyote time
  ///
  /// **Grounded Conditions:**
  /// - Entity has ground contact collision
  /// - Ground contact is valid surface type
  /// - Within coyote time after losing ground contact
  Future<bool> isGrounded(int entityId);

  /// Get ground normal vector.
  ///
  /// Retrieves the normal vector of the ground surface the entity
  /// is in contact with. Used for movement and physics calculations.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to get ground normal for
  ///
  /// **Returns:** Ground surface normal vector
  ///
  /// **Default:** Returns Vector2(0, -1) if no ground contact
  Future<Vector2> getGroundNormal(int entityId);

  /// Get remaining coyote time.
  ///
  /// Returns the remaining coyote time for the entity, allowing for
  /// forgiving jump mechanics after leaving ground contact.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check coyote time for
  ///
  /// **Returns:** Remaining coyote time in seconds
  Future<double> getCoyoteTimeRemaining(int entityId);

  /// Get ground surface information.
  ///
  /// Retrieves detailed information about the ground surface the
  /// entity is in contact with.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to get ground surface for
  ///
  /// **Returns:** Ground surface information or null if not grounded
  Future<CollisionSurface?> getGroundSurface(int entityId);

  // ============================================================================
  // Movement Validation Interface
  // ============================================================================

  /// Check if movement is blocked by collisions.
  ///
  /// Validates whether movement in specified direction would be blocked
  /// by current collision constraints.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check movement for
  /// - [direction]: Movement direction to validate
  ///
  /// **Returns:** True if movement is blocked, false if clear
  ///
  /// **Validation Factors:**
  /// - Current collision state
  /// - Movement direction against collision normals
  /// - Surface properties and interaction rules
  Future<bool> isMovementBlocked(int entityId, Vector2 direction);

  /// Check if position is valid for entity.
  ///
  /// Validates whether specified position would be valid for the entity
  /// based on collision constraints and world boundaries.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to validate position for
  /// - [position]: Position to validate
  ///
  /// **Returns:** True if position is valid, false otherwise
  Future<bool> isPositionValid(int entityId, Vector2 position);

  /// Predict collisions for movement.
  ///
  /// Predicts what collisions would occur if entity moves by specified
  /// movement vector. Used for movement validation and planning.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to predict collisions for
  /// - [movement]: Movement vector to predict
  ///
  /// **Returns:** List of predicted collision information
  Future<List<CollisionInfo>> predictCollisions(int entityId, Vector2 movement);

  /// Get entity grounded information.
  ///
  /// Retrieves comprehensive grounded state information including
  /// ground surface details and coyote time status.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to get grounded info for
  ///
  /// **Returns:** Complete grounded state information
  Future<GroundInfo> getGroundInfo(int entityId);

  // ============================================================================
  // Collision Event Management
  // ============================================================================

  /// Add collision event listener.
  ///
  /// Registers a listener to receive collision events. Used by systems
  /// that need to respond to collision state changes.
  ///
  /// **Parameters:**
  /// - [listener]: Event listener to register
  ///
  /// **Event Types:**
  /// - Collision start/end events
  /// - Ground state change events
  /// - Surface interaction events
  void addCollisionListener(ICollisionEventListener listener);

  /// Remove collision event listener.
  ///
  /// Unregisters a collision event listener to stop receiving events.
  ///
  /// **Parameters:**
  /// - [listener]: Event listener to unregister
  void removeCollisionListener(ICollisionEventListener listener);

  /// Notify input validation.
  ///
  /// Called when input system validates input against collision state.
  /// Used for coordination between input processing and collision detection.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity performing input validation
  /// - [inputAction]: Input action being validated
  void notifyInputValidation(int entityId, String inputAction);

  // ============================================================================
  // Physics Coordination
  // ============================================================================

  /// Handle ground state change.
  ///
  /// Called when entity ground state changes. Coordinates ground state
  /// updates with physics system and dependent systems.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity with ground state change
  /// - [isGrounded]: New grounded state
  /// - [groundNormal]: Ground surface normal (if grounded)
  ///
  /// **Coordination Actions:**
  /// - Update internal grounded state
  /// - Notify registered event listeners
  /// - Coordinate with physics system
  Future<void> onGroundStateChanged(
    int entityId,
    bool isGrounded,
    Vector2 groundNormal,
  );

  /// Validate collision response.
  ///
  /// Validates collision response calculations before physics system
  /// applies collision resolution.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity involved in collision response
  /// - [collision]: Collision information to validate
  ///
  /// **Validation Checks:**
  /// - Collision response vector validity
  /// - Response magnitude within reasonable bounds
  /// - No conflicting collision responses
  Future<void> validateCollisionResponse(int entityId, CollisionInfo collision);

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Handle collision processing error.
  ///
  /// Called when collision processing encounters errors. Implements
  /// error recovery and maintains system stability.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity that encountered collision error
  /// - [error]: Collision error information
  ///
  /// **Error Recovery:**
  /// - Log error for debugging
  /// - Apply fallback collision state
  /// - Notify dependent systems of error
  /// - Maintain collision system stability
  void onCollisionProcessingError(int entityId, CollisionError error);
}

/// Collision event listener interface for systems responding to collision events.
///
/// Provides interface for systems that need to respond to collision state
/// changes and events within the collision notification system.
abstract class ICollisionEventListener {
  /// Handle collision start event.
  ///
  /// Called when new collision is detected between entities.
  ///
  /// **Parameters:**
  /// - [collision]: Collision information for new collision
  void onCollisionStart(CollisionInfo collision);

  /// Handle collision end event.
  ///
  /// Called when collision between entities ends.
  ///
  /// **Parameters:**
  /// - [collision]: Collision information for ended collision
  void onCollisionEnd(CollisionInfo collision);

  /// Handle ground state change event.
  ///
  /// Called when entity ground state changes (grounded/airborne).
  ///
  /// **Parameters:**
  /// - [entityId]: Entity with ground state change
  /// - [isGrounded]: New grounded state
  /// - [groundNormal]: Ground surface normal vector
  void onGroundStateChanged(
    int entityId,
    bool isGrounded,
    Vector2 groundNormal,
  );

  /// Handle surface change event.
  ///
  /// Called when entity contact surface changes (different surface types).
  ///
  /// **Parameters:**
  /// - [entityId]: Entity with surface change
  /// - [surface]: New surface information
  void onSurfaceChanged(int entityId, CollisionSurface surface);
}

/// Collision information for event handling and system coordination.
///
/// Provides comprehensive collision data for collision processing,
/// event generation, and system coordination.
class CollisionInfo {
  /// First entity involved in collision
  final int entityA;

  /// Second entity involved in collision
  final int entityB;

  /// Collision contact point in world coordinates
  final Vector2 contactPoint;

  /// Collision surface normal vector
  final Vector2 contactNormal;

  /// Collision penetration depth
  final double penetrationDepth;

  /// Collision separation vector
  final Vector2 separationVector;

  /// Type of collision (ground, wall, entity, etc.)
  final CollisionType collisionType;

  /// Surface properties at collision point
  final CollisionSurface surface;

  /// Timestamp when collision was detected
  final DateTime timestamp;

  /// Whether collision is still active
  final bool isActive;

  /// Collision velocity at impact
  final Vector2 impactVelocity;

  /// Additional collision metadata
  final Map<String, dynamic> metadata;

  const CollisionInfo({
    required this.entityA,
    required this.entityB,
    required this.contactPoint,
    required this.contactNormal,
    required this.penetrationDepth,
    required this.separationVector,
    required this.collisionType,
    required this.surface,
    required this.timestamp,
    required this.isActive,
    required this.impactVelocity,
    this.metadata = const {},
  });

  /// Create ground collision info
  factory CollisionInfo.ground({
    required int entityId,
    required Vector2 contactPoint,
    required Vector2 groundNormal,
    required double penetrationDepth,
    required CollisionSurface surface,
  }) {
    return CollisionInfo(
      entityA: entityId,
      entityB: -1, // Ground entity ID
      contactPoint: contactPoint,
      contactNormal: groundNormal,
      penetrationDepth: penetrationDepth,
      separationVector: groundNormal * penetrationDepth,
      collisionType: CollisionType.ground,
      surface: surface,
      timestamp: DateTime.now(),
      isActive: true,
      impactVelocity: Vector2.zero(),
    );
  }

  /// Create wall collision info
  factory CollisionInfo.wall({
    required int entityId,
    required Vector2 contactPoint,
    required Vector2 wallNormal,
    required double penetrationDepth,
    required CollisionSurface surface,
  }) {
    return CollisionInfo(
      entityA: entityId,
      entityB: -2, // Wall entity ID
      contactPoint: contactPoint,
      contactNormal: wallNormal,
      penetrationDepth: penetrationDepth,
      separationVector: wallNormal * penetrationDepth,
      collisionType: CollisionType.wall,
      surface: surface,
      timestamp: DateTime.now(),
      isActive: true,
      impactVelocity: Vector2.zero(),
    );
  }

  /// Check if collision involves specific entity
  bool involvesEntity(int entityId) {
    return entityA == entityId || entityB == entityId;
  }

  /// Get other entity in collision
  int getOtherEntity(int entityId) {
    if (entityA == entityId) return entityB;
    if (entityB == entityId) return entityA;
    throw ArgumentError('Entity $entityId not involved in this collision');
  }

  /// Check if collision is ground contact
  bool get isGroundCollision {
    return collisionType == CollisionType.ground ||
        (contactNormal.y < -0.7 && contactNormal.y > -1.0);
  }

  /// Check if collision is wall contact
  bool get isWallCollision {
    return collisionType == CollisionType.wall ||
        (contactNormal.x.abs() > 0.7 && contactNormal.y.abs() < 0.7);
  }

  /// Check if collision is valid
  bool get isValid {
    return entityA >= 0 &&
        entityB >= -2 && // Allow ground (-1) and wall (-2) IDs
        MathUtils.isVector2Finite(contactPoint) &&
        MathUtils.isVector2Finite(contactNormal) &&
        penetrationDepth >= 0 &&
        MathUtils.isVector2Finite(separationVector) &&
        MathUtils.isVector2Finite(impactVelocity);
  }

  /// Get collision age in milliseconds
  int get ageInMilliseconds {
    return DateTime.now().difference(timestamp).inMilliseconds;
  }

  /// Create copy with updated values
  CollisionInfo copyWith({
    int? entityA,
    int? entityB,
    Vector2? contactPoint,
    Vector2? contactNormal,
    double? penetrationDepth,
    Vector2? separationVector,
    CollisionType? collisionType,
    CollisionSurface? surface,
    DateTime? timestamp,
    bool? isActive,
    Vector2? impactVelocity,
    Map<String, dynamic>? metadata,
  }) {
    return CollisionInfo(
      entityA: entityA ?? this.entityA,
      entityB: entityB ?? this.entityB,
      contactPoint: contactPoint ?? this.contactPoint,
      contactNormal: contactNormal ?? this.contactNormal,
      penetrationDepth: penetrationDepth ?? this.penetrationDepth,
      separationVector: separationVector ?? this.separationVector,
      collisionType: collisionType ?? this.collisionType,
      surface: surface ?? this.surface,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
      impactVelocity: impactVelocity ?? this.impactVelocity,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'CollisionInfo(entities: $entityA-$entityB, type: ${collisionType.name}, '
        'depth: ${penetrationDepth.toStringAsFixed(2)}, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CollisionInfo &&
        other.entityA == entityA &&
        other.entityB == entityB &&
        other.contactPoint == contactPoint &&
        other.contactNormal == contactNormal &&
        other.penetrationDepth == penetrationDepth &&
        other.collisionType == collisionType;
  }

  @override
  int get hashCode {
    return Object.hash(
      entityA,
      entityB,
      contactPoint,
      contactNormal,
      penetrationDepth,
      collisionType,
    );
  }
}

/// Ground information for character grounded state management.
///
/// Provides comprehensive ground contact information for character
/// movement validation and jump mechanics.
class GroundInfo {
  /// Entity identifier
  final int entityId;

  /// Whether entity is currently grounded
  final bool isGrounded;

  /// Ground surface normal vector
  final Vector2 groundNormal;

  /// Time when entity was last grounded
  final DateTime lastGroundedTime;

  /// Remaining coyote time for forgiving jumps
  final double coyoteTimeRemaining;

  /// Ground surface information
  final CollisionSurface groundSurface;

  /// Whether entity was grounded in previous frame
  final bool wasGroundedLastFrame;

  /// Ground contact stability (for moving platforms)
  final bool isStableGround;

  /// Ground movement velocity (for moving platforms)
  final Vector2 groundVelocity;

  const GroundInfo({
    required this.entityId,
    required this.isGrounded,
    required this.groundNormal,
    required this.lastGroundedTime,
    required this.coyoteTimeRemaining,
    required this.groundSurface,
    required this.wasGroundedLastFrame,
    required this.isStableGround,
    required this.groundVelocity,
  });

  /// Create airborne ground info
  factory GroundInfo.airborne(int entityId, DateTime lastGroundedTime) {
    return GroundInfo(
      entityId: entityId,
      isGrounded: false,
      groundNormal: Vector2(0, -1),
      lastGroundedTime: lastGroundedTime,
      coyoteTimeRemaining: 0.0,
      groundSurface: CollisionSurface.none(),
      wasGroundedLastFrame: false,
      isStableGround: false,
      groundVelocity: Vector2.zero(),
    );
  }

  /// Create grounded ground info
  factory GroundInfo.grounded({
    required int entityId,
    required Vector2 groundNormal,
    required CollisionSurface surface,
    bool isStable = true,
    Vector2? groundVelocity,
  }) {
    return GroundInfo(
      entityId: entityId,
      isGrounded: true,
      groundNormal: groundNormal,
      lastGroundedTime: DateTime.now(),
      coyoteTimeRemaining: 0.15, // 150ms coyote time
      groundSurface: surface,
      wasGroundedLastFrame: true,
      isStableGround: isStable,
      groundVelocity: groundVelocity ?? Vector2.zero(),
    );
  }

  /// Check if can jump (grounded or coyote time)
  bool get canJump => isGrounded || coyoteTimeRemaining > 0;

  /// Check if ground state changed this frame
  bool get groundedStateChanged => isGrounded != wasGroundedLastFrame;

  /// Check if ground info is valid
  bool get isValid {
    return entityId > 0 &&
        MathUtils.isVector2Finite(groundNormal) &&
        coyoteTimeRemaining >= 0 &&
        MathUtils.isVector2Finite(groundVelocity);
  }

  @override
  String toString() {
    return 'GroundInfo(entity: $entityId, grounded: $isGrounded, '
        'canJump: $canJump, stable: $isStableGround)';
  }
}

/// Collision surface properties for interaction handling.
///
/// Defines surface properties that affect collision response and
/// character movement behavior.
class CollisionSurface {
  /// Surface material type
  final SurfaceMaterial material;

  /// Surface friction coefficient
  final double friction;

  /// Surface bounce/restitution coefficient
  final double restitution;

  /// Whether surface is slippery
  final bool isSlippery;

  /// Whether surface can be wall-jumped
  final bool allowsWallJump;

  /// Whether surface is one-way (can pass through from below)
  final bool isOneWay;

  /// Surface movement velocity (for moving platforms)
  final Vector2 velocity;

  /// Surface tilt angle in radians
  final double tiltAngle;

  /// Additional surface properties
  final Map<String, dynamic> properties;

  const CollisionSurface({
    required this.material,
    required this.friction,
    required this.restitution,
    required this.isSlippery,
    required this.allowsWallJump,
    required this.isOneWay,
    required this.velocity,
    required this.tiltAngle,
    this.properties = const {},
  });

  /// Create default solid surface
  factory CollisionSurface.solid() {
    return CollisionSurface(
      material: SurfaceMaterial.stone,
      friction: 0.8,
      restitution: 0.0,
      isSlippery: false,
      allowsWallJump: true,
      isOneWay: false,
      velocity: Vector2.zero(),
      tiltAngle: 0.0,
    );
  }

  /// Create ice surface
  factory CollisionSurface.ice() {
    return CollisionSurface(
      material: SurfaceMaterial.ice,
      friction: 0.1,
      restitution: 0.0,
      isSlippery: true,
      allowsWallJump: false,
      isOneWay: false,
      velocity: Vector2.zero(),
      tiltAngle: 0.0,
    );
  }

  /// Create bounce surface
  factory CollisionSurface.bouncy() {
    return CollisionSurface(
      material: SurfaceMaterial.rubber,
      friction: 0.6,
      restitution: 0.8,
      isSlippery: false,
      allowsWallJump: false,
      isOneWay: false,
      velocity: Vector2.zero(),
      tiltAngle: 0.0,
    );
  }

  /// Create no surface (for airborne state)
  factory CollisionSurface.none() {
    return CollisionSurface(
      material: SurfaceMaterial.none,
      friction: 0.0,
      restitution: 0.0,
      isSlippery: false,
      allowsWallJump: false,
      isOneWay: false,
      velocity: Vector2.zero(),
      tiltAngle: 0.0,
    );
  }

  /// Check if surface is valid for standing
  bool get isValidStandingSurface {
    return material != SurfaceMaterial.none &&
        !isSlippery &&
        tiltAngle.abs() < 0.785; // 45 degrees
  }

  /// Get effective friction with surface tilt
  double get effectiveFriction {
    if (isSlippery) return friction * 0.1;
    return friction * (1.0 - (tiltAngle.abs() / 1.57)); // Reduce with tilt
  }

  @override
  String toString() {
    return 'CollisionSurface(material: ${material.name}, friction: ${friction.toStringAsFixed(2)}, '
        'slippery: $isSlippery, oneWay: $isOneWay)';
  }
}

/// Surface material types for collision surfaces.
enum SurfaceMaterial {
  none, // No surface contact
  stone, // Default solid surface
  ice, // Slippery surface
  rubber, // Bouncy surface
  metal, // Hard surface with echo
  wood, // Medium friction surface
  grass, // Soft surface
  water, // Liquid surface
  sand, // Loose surface
  mud, // Sticky surface
}

/// Collision type classification for event handling.
enum CollisionType {
  none, // No specific collision type / default state
  ground, // Ground contact collision
  wall, // Wall contact collision
  ceiling, // Ceiling contact collision
  entity, // Entity-to-entity collision
  pickup, // Collectible item collision
  trigger, // Trigger zone collision
  damage, // Damage-dealing collision
  platform, // Moving platform collision
}

/// Collision error types for error handling.
enum CollisionErrorType {
  invalidPosition, // Entity position is invalid
  processingTimeout, // Collision processing took too long
  inconsistentState, // Collision state is inconsistent
  memoryExhaustion, // Too many collision objects
  algorithmFailure, // Collision algorithm failed
}

/// Collision processing error information.
class CollisionError {
  /// Type of collision error
  final CollisionErrorType type;

  /// Error message description
  final String message;

  /// Entity that encountered the error
  final int entityId;

  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Error severity level
  final CollisionErrorSeverity severity;

  /// Additional error context
  final Map<String, dynamic> context;

  const CollisionError({
    required this.type,
    required this.message,
    required this.entityId,
    required this.timestamp,
    required this.severity,
    this.context = const {},
  });

  /// Create collision error
  factory CollisionError.create({
    required CollisionErrorType type,
    required String message,
    required int entityId,
    CollisionErrorSeverity severity = CollisionErrorSeverity.warning,
    Map<String, dynamic> context = const {},
  }) {
    return CollisionError(
      type: type,
      message: message,
      entityId: entityId,
      timestamp: DateTime.now(),
      severity: severity,
      context: context,
    );
  }

  @override
  String toString() {
    return 'CollisionError(type: ${type.name}, entity: $entityId, '
        'severity: ${severity.name}, message: $message)';
  }
}

/// Collision error severity levels.
enum CollisionErrorSeverity {
  info, // Informational message
  warning, // Warning condition
  error, // Error condition
  critical, // Critical error requiring immediate attention
}

import 'package:flame/components.dart';

import '../systems/interfaces/collision_notifier.dart'; // Added for SurfaceMaterial
import '../systems/interfaces/physics_state.dart' hide CollisionInfo;
import 'interfaces/physics_integration.dart';

/// PHY-3.1.1: Enhanced PhysicsComponent with IPhysicsIntegration
///
/// Component that handles physics simulation for entities
/// Manages velocity, acceleration, gravity, and other physics properties
///
/// Now implements IPhysicsIntegration interface for proper coordination
/// with PhysicsSystem, including:
/// - State synchronization with PhysicsSystem
/// - Accumulation prevention mechanisms
/// - Component lifecycle management
/// - Error recovery procedures
class PhysicsComponent extends Component implements IPhysicsIntegration {
  PhysicsComponent({
    Vector2? velocity,
    Vector2? acceleration,
    double? mass,
    double? friction,
    double? restitution,
    double? gravityScale,
    bool? isStatic,
    bool? isSensor,
    bool? affectedByGravity,
    double? bounciness, // Added bounciness
    bool? useEdgeDetection, // Added useEdgeDetection
  }) {
    if (velocity != null) _velocity = velocity;
    if (acceleration != null) _acceleration = acceleration;
    if (mass != null) _mass = mass;
    if (friction != null) _friction = friction;
    if (restitution != null) _restitution = restitution;
    if (gravityScale != null) _gravityScale = gravityScale;
    if (isStatic != null) this.isStatic = isStatic;
    if (isSensor != null) this.isSensor = isSensor;
    if (affectedByGravity != null) this.affectedByGravity = affectedByGravity;
    if (bounciness != null) {
      _restitution = bounciness; // Use _restitution for bounciness
    }
    if (useEdgeDetection != null) this.useEdgeDetection = useEdgeDetection;
  }

  // Physics properties
  Vector2 _velocity = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  double _mass = 1;
  double _friction = 0.1;
  double _restitution = 0.2; // Internal field for bounciness
  double _gravityScale = 1;
  bool isStatic = false; // Static objects don't move
  bool isSensor = false; // Sensor objects don't collide physically
  bool affectedByGravity = true;

  // Ground contact state
  bool _isOnGround = false;
  bool _wasOnGround = false;
  SurfaceMaterial? _currentGroundSurfaceMaterial;


  // T2.5.1: Enhanced landing detection with collision normals
  Vector2? _lastCollisionNormal;
  Vector2? _lastSeparationVector;
  double _lastLandingVelocity = 0.0;
  Vector2? _lastLandingPosition;
  String? _lastPlatformType;

  // T2.6: Edge detection properties
  bool _isNearLeftEdge = false;
  bool _isNearRightEdge = false;
  double _leftEdgeDistance = double.infinity;
  double _rightEdgeDistance = double.infinity;
  final double _edgeDetectionThreshold =
      32.0; // Distance threshold for edge proximity
  Vector2? _leftEdgePosition;
  Vector2? _rightEdgePosition;
  bool useEdgeDetection =
      false; // Whether this component should have edges detected by PhysicsSystem

  // Max velocity capping
  final double _maxVelocityX = 400;
  final double _maxVelocityY = 800;
  @override
  void update(double dt) {
    super.update(dt);

    if (isStatic) return; // Static objects don't update physics

    // Store previous ground state
    _wasOnGround = _isOnGround;

    // Physics processing is now handled by PhysicsSystem
    // This ensures consistent physics simulation across all entities
    // Acceleration is reset by PhysicsSystem after integration
  }

  /// Apply a force to this entity
  void applyForce(Vector2 force) {
    if (isStatic) return;
    _acceleration += force / _mass;
  }

  /// Apply an impulse (instant change in velocity)
  void applyImpulse(Vector2 impulse) {
    if (isStatic || mass <= 0) return; // Cannot apply impulse to static or massless objects

    final Vector2 deltaVelocity = impulse / mass;
    velocity.add(deltaVelocity);
  }

  /// Apply a knockback force to this entity (as an impulse)
  void applyKnockback(Vector2 knockbackForce) {
    if (isStatic) return;
    // Knockback is typically applied as an immediate change in velocity (impulse)
    applyImpulse(knockbackForce);
  }

  /// Set velocity directly
  void setVelocity(Vector2 newVelocity) {
    _velocity = newVelocity.clone();
  }

  /// Set X velocity
  void setVelocityX(double x) {
    _velocity.x = x;
  }

  /// Set Y velocity
  void setVelocityY(double y) {
    _velocity.y = y;
  }

  /// Set ground contact state
  void setOnGround(bool onGround, {SurfaceMaterial? groundMaterial}) {
    _isOnGround = onGround;
    if (_isOnGround) {
      // Store the provided material, or null if the ground has no specific material / null was passed.
      _currentGroundSurfaceMaterial = groundMaterial;
    } else {
      _currentGroundSurfaceMaterial = null;
    }
  }

  /// T2.5.1: Set landing data for enhanced detection
  void setLandingData({
    Vector2? collisionNormal,
    Vector2? separationVector,
    double? landingVelocity,
    Vector2? landingPosition,
    String? platformType,
  }) {
    if (collisionNormal != null) _lastCollisionNormal = collisionNormal.clone();
    if (separationVector != null) {
      _lastSeparationVector = separationVector.clone();
    }
    if (landingVelocity != null) _lastLandingVelocity = landingVelocity;
    if (landingPosition != null) _lastLandingPosition = landingPosition.clone();
    if (platformType != null) _lastPlatformType = platformType;
  }

  // T2.6.1: Set edge detection data
  void setEdgeDetectionData({
    bool? isNearLeftEdge,
    bool? isNearRightEdge,
    double? leftEdgeDistance,
    double? rightEdgeDistance,
    Vector2? leftEdgePosition,
    Vector2? rightEdgePosition,
  }) {
    if (isNearLeftEdge != null) _isNearLeftEdge = isNearLeftEdge;
    if (isNearRightEdge != null) _isNearRightEdge = isNearRightEdge;
    if (leftEdgeDistance != null) _leftEdgeDistance = leftEdgeDistance;
    if (rightEdgeDistance != null) _rightEdgeDistance = rightEdgeDistance;
    if (leftEdgePosition != null) _leftEdgePosition = leftEdgePosition.clone();
    if (rightEdgePosition != null) {
      _rightEdgePosition = rightEdgePosition.clone();
    }
  }

  // Getters/setters
  Vector2 get velocity => _velocity;
  Vector2 get acceleration => _acceleration;
  double get mass => _mass;
  double get friction => _friction;
  double get restitution => _restitution; // Kept for direct access if needed
  double get bounciness => _restitution; // Getter for bounciness
  set bounciness(double value) =>
      _restitution = value.clamp(0.0, 1.0); // Setter for bounciness, clamped
  double get gravityScale => _gravityScale;
  double get maxVelocityX => _maxVelocityX;
  double get maxVelocityY => _maxVelocityY;


  bool get isOnGround => _isOnGround;
  bool get wasOnGround => _wasOnGround;
  bool get justLanded => _isOnGround && !_wasOnGround;
  bool get justLeftGround => !_isOnGround && _wasOnGround;


  // T2.5.1: Enhanced landing detection getters
  Vector2? get lastCollisionNormal => _lastCollisionNormal?.clone();
  Vector2? get lastSeparationVector => _lastSeparationVector?.clone();
  double get lastLandingVelocity => _lastLandingVelocity;
  Vector2? get lastLandingPosition => _lastLandingPosition?.clone();
  String? get lastPlatformType => _lastPlatformType;

  /// Returns the surface material of the ground the entity is currently on.
  /// Defaults to SurfaceMaterial.none if not grounded or if the material is unspecified.
  SurfaceMaterial get currentGroundSurfaceMaterial {
    if (!_isOnGround) {
      return SurfaceMaterial.none;
    }
    return _currentGroundSurfaceMaterial ?? SurfaceMaterial.none;
  }

  // T2.6.1: Edge detection getters
  bool get isNearLeftEdge => _isNearLeftEdge;
  bool get isNearRightEdge => _isNearRightEdge;
  bool get isNearAnyEdge => _isNearLeftEdge || _isNearRightEdge;
  double get leftEdgeDistance => _leftEdgeDistance;
  double get rightEdgeDistance => _rightEdgeDistance;
  double get edgeDetectionThreshold => _edgeDetectionThreshold;
  Vector2? get leftEdgePosition => _leftEdgePosition?.clone();
  Vector2? get rightEdgePosition => _rightEdgePosition?.clone();

  /// Set gravity scale multiplier
  void setGravityScale(double scale) {
    _gravityScale = scale;
  }

  /// Clear all forces (equivalent to clearForces)
  void clearForces() {
    _acceleration.setZero();
  }

  // ============================================================================
  // PHY-3.1.1: IPhysicsIntegration Implementation
  // ============================================================================

  @override
  Future<void> updatePhysicsState(PhysicsState state) async {
    // Synchronize component state with authoritative physics state
    _velocity.setFrom(state.velocity);
    _acceleration.setFrom(state.acceleration);
    _isOnGround = state.isGrounded;
    _wasOnGround = state.wasGrounded;

    // Update physics properties if they've changed
    _mass = state.mass;
    _gravityScale = state.gravityScale;
    _friction = state.friction;
    _restitution = state.restitution;
    isStatic = state.isStatic;
    affectedByGravity = state.affectedByGravity;

    // Notify of state update
    onPhysicsUpdate(state);
  }

  @override
  Future<void> resetPhysicsValues() async {
    // Reset all physics values to clean defaults
    _velocity.setZero();
    _acceleration.setZero();
    _isOnGround = false;
    _wasOnGround = false;

    // Reset collision tracking
    _lastCollisionNormal = null;
    _lastSeparationVector = null;
    _lastLandingVelocity = 0.0;
    _lastLandingPosition = null;
    _lastPlatformType = null;

    // Reset edge detection
    _isNearLeftEdge = false;
    _isNearRightEdge = false;
    _leftEdgeDistance = double.infinity;
    _rightEdgeDistance = double.infinity;
    _leftEdgePosition = null;
    _rightEdgePosition = null;

    // Reset to default physics properties
    _mass = 1.0;
    _gravityScale = 1.0;
    _friction = 0.1;
    _restitution = 0.2;
    isStatic = false;
    affectedByGravity = true;
  }

  @override
  Future<void> preventAccumulation() async {
    // Clear any accumulated forces
    _acceleration.setZero();

    // Clamp velocity to prevent excessive accumulation
    if (_velocity.length > 1000.0) {
      _velocity.normalize();
      _velocity.scale(1000.0);
    }

    // Reset collision tracking to prevent contact point accumulation
    _lastCollisionNormal = null;
    _lastSeparationVector = null;
  }

  @override
  Future<Vector2> getPosition() async {
    // Position is managed by the Entity, not the component
    // This method should be overridden by the entity or coordinated through the physics system
    if (parent is PositionComponent) {
      return (parent as PositionComponent).position.clone();
    }
    return Vector2.zero();
  }

  @override
  Future<Vector2> getVelocity() async {
    return _velocity.clone();
  }

  @override
  Future<bool> isGrounded() async {
    return _isOnGround;
  }

  @override
  Future<PhysicsProperties> getPhysicsProperties() async {
    return PhysicsProperties(
      mass: _mass,
      gravityScale: _gravityScale,
      friction: _friction,
      restitution: _restitution,
      isStatic: isStatic,
      affectedByGravity: affectedByGravity,
      useEdgeDetection: useEdgeDetection,
    );
  }

  @override
  void onPhysicsUpdate(PhysicsState state) {
    // Hook for subclasses to respond to physics updates
    // Can be overridden for specific entity behaviors
  }

  @override
  void onCollision(CollisionInfo collision) {
    // Update collision tracking
    if (collision.collisionType == CollisionType.ground) {
      _lastCollisionNormal = collision.contactNormal.clone();
      _lastLandingPosition = collision.contactPoint.clone();
      _lastLandingVelocity = _velocity.y;
    }
  }

  @override
  void onGroundStateChanged(bool isGrounded) {
    _wasOnGround = _isOnGround;
    _isOnGround = isGrounded;

    if (isGrounded && !_wasOnGround) {
      // Just landed
      _lastLandingVelocity = _velocity.y;
      if (parent is PositionComponent) {
        _lastLandingPosition = (parent as PositionComponent).position.clone();
      }
    }
  }

  /// Get current physics state for synchronization
  PhysicsState getPhysicsState() {
    final position = parent is PositionComponent
        ? (parent as PositionComponent).position.clone()
        : Vector2.zero();
    // Use entity id if parent is an Entity, otherwise use hashCode
    int entityId = 0;
    if (parent != null) {
      try {
        // Check if parent has an id getter (Entity class)
        final dynamic parentDynamic = parent;
        final id = parentDynamic.id;
        if (id != null && id is String && id.isNotEmpty) {
          entityId = id.hashCode;
        } else {
          entityId = parent.hashCode;
        }
      } catch (_) {
        entityId = parent.hashCode;
      }
    }

    return PhysicsState(
      entityId: entityId,
      position: position,
      velocity: _velocity.clone(),
      acceleration: _acceleration.clone(),
      isGrounded: _isOnGround,
      wasGrounded: _wasOnGround,
      mass: _mass,
      gravityScale: _gravityScale,
      friction: _friction,
      restitution: _restitution,
      isStatic: isStatic,
      affectedByGravity: affectedByGravity,
      activeCollisions: [], // Empty for now
      accumulatedForces: Vector2.zero(),
      contactPointCount: 0,
      updateCount: 0,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// Get position from parent entity
  Vector2 get position {
    if (parent is PositionComponent) {
      return (parent as PositionComponent).position;
    }
    return Vector2.zero();
  }

  // ============================================================================
  // Component Lifecycle Management (PHY-3.1.1)
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Initialize component with clean physics state
    await resetPhysicsValues();
  }

  @override
  void onRemove() {
    // Clean up physics state before removal
    _velocity.setZero();
    _acceleration.setZero();
    super.onRemove();
  }
}

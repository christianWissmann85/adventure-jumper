import 'package:flame/components.dart';

/// Component that handles physics simulation for entities
/// Manages velocity, acceleration, gravity, and other physics properties
class PhysicsComponent extends Component {
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
    if (isStatic != null) _isStatic = isStatic;
    if (isSensor != null) _isSensor = isSensor;
    if (affectedByGravity != null) _affectedByGravity = affectedByGravity;
    if (bounciness != null)
      _restitution = bounciness; // Use _restitution for bounciness
    if (useEdgeDetection != null) _useEdgeDetection = useEdgeDetection;
  }

  // Physics properties
  Vector2 _velocity = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  double _mass = 1;
  double _friction = 0.1;
  double _restitution = 0.2; // Internal field for bounciness
  double _gravityScale = 1;
  bool _isStatic = false; // Static objects don't move
  bool _isSensor = false; // Sensor objects don't collide physically
  bool _affectedByGravity = true;

  // Environmental properties
  final Vector2 _gravity = Vector2(0, 9.8); // Default gravity
  // Ground contact state
  bool _isOnGround = false;
  bool _wasOnGround = false;

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
  bool _useEdgeDetection =
      false; // Whether this component should have edges detected by PhysicsSystem

  // Max velocity capping
  final double _maxVelocityX = 400;
  final double _maxVelocityY = 800;
  @override
  void update(double dt) {
    super.update(dt);

    if (_isStatic) return; // Static objects don't update physics

    // Store previous ground state
    _wasOnGround = _isOnGround;

    // Physics processing is now handled by PhysicsSystem
    // This ensures consistent physics simulation across all entities
    // Acceleration is reset by PhysicsSystem after integration
  }

  /// Apply a force to this entity
  void applyForce(Vector2 force) {
    if (_isStatic) return;
    _acceleration += force / _mass;
  }

  /// Apply an impulse (instant change in velocity)
  void applyImpulse(Vector2 impulse) {
    if (_isStatic) return;
    _velocity += impulse / _mass;
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
  void setOnGround(bool onGround) {
    _isOnGround = onGround;
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
  bool get isStatic => _isStatic;
  set isStatic(bool value) => _isStatic = value;
  bool get isSensor => _isSensor;
  set isSensor(bool value) => _isSensor = value;
  bool get isOnGround => _isOnGround;
  bool get wasOnGround => _wasOnGround;
  bool get justLanded => _isOnGround && !_wasOnGround;
  bool get justLeftGround => !_isOnGround && _wasOnGround;
  bool get affectedByGravity => _affectedByGravity;
  set affectedByGravity(bool value) => _affectedByGravity = value;

  // T2.5.1: Enhanced landing detection getters
  Vector2? get lastCollisionNormal => _lastCollisionNormal?.clone();
  Vector2? get lastSeparationVector => _lastSeparationVector?.clone();
  double get lastLandingVelocity => _lastLandingVelocity;
  Vector2? get lastLandingPosition => _lastLandingPosition?.clone();
  String? get lastPlatformType => _lastPlatformType;

  // T2.6.1: Edge detection getters
  bool get isNearLeftEdge => _isNearLeftEdge;
  bool get isNearRightEdge => _isNearRightEdge;
  bool get isNearAnyEdge => _isNearLeftEdge || _isNearRightEdge;
  double get leftEdgeDistance => _leftEdgeDistance;
  double get rightEdgeDistance => _rightEdgeDistance;
  double get edgeDetectionThreshold => _edgeDetectionThreshold;
  Vector2? get leftEdgePosition => _leftEdgePosition?.clone();
  Vector2? get rightEdgePosition => _rightEdgePosition?.clone();
  bool get useEdgeDetection => _useEdgeDetection; // Getter for useEdgeDetection
  set useEdgeDetection(bool value) =>
      _useEdgeDetection = value; // Setter for useEdgeDetection

  /// Set gravity scale multiplier
  void setGravityScale(double scale) {
    _gravityScale = scale;
  }
}

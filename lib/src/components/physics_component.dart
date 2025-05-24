import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';

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
  }

  // Physics properties
  Vector2 _velocity = Vector2.zero();
  Vector2 _acceleration = Vector2.zero();
  double _mass = 1;
  double _friction = 0.1;
  double _restitution = 0.2; // Bounciness
  double _gravityScale = 1;
  bool _isStatic = false; // Static objects don't move
  bool _isSensor = false; // Sensor objects don't collide physically
  bool _affectedByGravity = true;

  // Environmental properties
  final Vector2 _gravity = Vector2(0, 9.8); // Default gravity

  // Ground contact state
  bool _isOnGround = false;
  bool _wasOnGround = false;

  // Max velocity capping
  final double _maxVelocityX = 400;
  final double _maxVelocityY = 800;

  @override
  void update(double dt) {
    super.update(dt);

    if (_isStatic) return; // Static objects don't update physics

    // Store previous ground state
    _wasOnGround = _isOnGround;

    // Apply gravity
    if (_affectedByGravity) {
      _acceleration.y += _gravity.y * _gravityScale;
    }

    // Apply acceleration to velocity
    _velocity += _acceleration * dt;

    // Apply friction when on ground
    if (_isOnGround) {
      _velocity.x *= 1 - _friction;
    }

    // Cap velocity
    _velocity.x = _velocity.x.clamp(-_maxVelocityX, _maxVelocityX);
    _velocity.y = _velocity.y.clamp(-_maxVelocityY, _maxVelocityY);

    // Apply velocity to position
    if (parent is PositionComponent) {
      final NotifyingVector2 parentPos = (parent as PositionComponent).position;
      parentPos.x += _velocity.x * dt;
      parentPos.y += _velocity.y * dt;
    }

    // Reset acceleration
    _acceleration = Vector2.zero();
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

  // Getters/setters
  Vector2 get velocity => _velocity;
  Vector2 get acceleration => _acceleration;
  double get mass => _mass;
  double get friction => _friction;
  double get restitution => _restitution;
  bool get isStatic => _isStatic;
  set isStatic(bool value) => _isStatic = value;
  bool get isSensor => _isSensor;
  set isSensor(bool value) => _isSensor = value;
  bool get isOnGround => _isOnGround;
  bool get wasOnGround => _wasOnGround;
  bool get justLanded => _isOnGround && !_wasOnGround;
  bool get justLeftGround => !_isOnGround && _wasOnGround;
  set affectedByGravity(bool value) => _affectedByGravity = value;
}

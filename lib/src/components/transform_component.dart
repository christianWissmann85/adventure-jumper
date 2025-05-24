import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';

/// Component that handles transformation operations for entities
/// Provides utilities for managing position, scale, rotation, etc.
class TransformComponent extends Component {
  TransformComponent({
    Vector2? position,
    Vector2? scale,
    double? rotation,
  }) {
    if (position != null) _position = position;
    if (scale != null) _scale = scale;
    if (rotation != null) _rotation = rotation;
  }

  // Transform properties
  Vector2 _position = Vector2.zero();
  Vector2 _scale = Vector2.all(1);
  double _rotation = 0;
  Vector2 _pivot = Vector2.zero();

  // Previous frame state for interpolation
  Vector2 _prevPosition = Vector2.zero();
  final double _prevRotation = 0;

  @override
  void onMount() {
    super.onMount();

    // Initialize with parent's position if available
    if (parent is PositionComponent) {
      final NotifyingVector2 parentPos = (parent as PositionComponent).position;
      _position = parentPos.clone();
      _prevPosition = parentPos.clone();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update parent position if available
    if (parent is PositionComponent) {
      // Store previous position for interpolation
      _prevPosition = (parent as PositionComponent).position.clone();

      // Update parent with current position
      (parent as PositionComponent).position = _position.clone();
      (parent as PositionComponent).scale = _scale;
      (parent as PositionComponent).angle = _rotation;
    }
  }

  /// Set position
  void setPosition(Vector2 newPosition) {
    _position = newPosition.clone();
  }

  /// Set x coordinate
  void setX(double x) {
    _position.x = x;
  }

  /// Set y coordinate
  void setY(double y) {
    _position.y = y;
  }

  /// Set scale
  void setScale(Vector2 newScale) {
    _scale = newScale.clone();
  }

  /// Set uniform scale
  void setUniformScale(double scale) {
    _scale = Vector2.all(scale);
  }

  /// Set rotation angle in radians
  void setRotation(double angle) {
    _rotation = angle;
  }

  /// Set rotation angle in degrees
  void setRotationDegrees(double degrees) {
    _rotation = degrees * 0.0174533; // Convert degrees to radians
  }

  /// Set pivot point for rotation
  void setPivot(Vector2 pivot) {
    _pivot = pivot.clone();
  }

  // Getters
  Vector2 get position => _position;
  Vector2 get scale => _scale;
  double get rotation => _rotation;
  Vector2 get pivot => _pivot;
  Vector2 get prevPosition => _prevPosition;
  double get prevRotation => _prevRotation;
}

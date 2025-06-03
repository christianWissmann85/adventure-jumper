import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';

import '../utils/logger.dart';
import 'interfaces/transform_integration.dart';

/// PHY-3.1.2: Enhanced TransformComponent with read-only position access
///
/// Component that handles transformation operations for entities
/// Provides utilities for managing position, scale, rotation, etc.
///
/// Key enhancements:
/// - Read-only position access enforcement for non-physics systems
/// - Position synchronization with physics system state updates
/// - Position validation procedures preventing unauthorized access
/// - Proper state tracking for physics synchronization
class TransformComponent extends Component implements ITransformIntegration {
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

  // PHY-3.1.2: Physics synchronization tracking
  static const String _authorizedSystem = 'PhysicsSystem';
  double _lastSyncTime = 0.0;
  bool _isSynchronized = false;
  String? _syncError;

  // Logger for access violations
  static final _logger = GameLogger.getLogger('TransformComponent');

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

  /// Set position - DEPRECATED: Use syncWithPhysics for position updates
  /// This method now throws an exception to enforce physics ownership
  @Deprecated('Position updates must go through PhysicsSystem')
  void setPosition(Vector2 newPosition) {
    _logPositionViolation('setPosition', 'Unknown');
    throw PositionAccessViolation(
      message:
          'Direct position modification not allowed. Use PhysicsSystem for position updates.',
      violatingSystem: 'Unknown',
      attemptedOperation: 'setPosition',
    );
  }

  /// Set x coordinate - DEPRECATED: Use syncWithPhysics for position updates
  /// This method now throws an exception to enforce physics ownership
  @Deprecated('Position updates must go through PhysicsSystem')
  void setX(double x) {
    _logPositionViolation('setX', 'Unknown');
    throw PositionAccessViolation(
      message:
          'Direct position modification not allowed. Use PhysicsSystem for position updates.',
      violatingSystem: 'Unknown',
      attemptedOperation: 'setX',
    );
  }

  /// Set y coordinate - DEPRECATED: Use syncWithPhysics for position updates
  /// This method now throws an exception to enforce physics ownership
  @Deprecated('Position updates must go through PhysicsSystem')
  void setY(double y) {
    _logPositionViolation('setY', 'Unknown');
    throw PositionAccessViolation(
      message:
          'Direct position modification not allowed. Use PhysicsSystem for position updates.',
      violatingSystem: 'Unknown',
      attemptedOperation: 'setY',
    );
  }

  /// Set scale
  @override
  void setScale(Vector2 newScale) {
    _scale = newScale.clone();
  }

  /// Set uniform scale
  void setUniformScale(double scale) {
    _scale = Vector2.all(scale);
  }

  /// Set rotation angle in radians
  @override
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

  // Getters - PHY-3.1.2: Position is read-only
  Vector2 get position =>
      _position.clone(); // Return clone to prevent external modification
  Vector2 get scale => _scale;
  double get rotation => _rotation;
  Vector2 get pivot => _pivot;
  Vector2 get prevPosition =>
      _prevPosition.clone(); // Return clone to prevent external modification
  double get prevRotation => _prevRotation;

  // ============================================================================
  // PHY-3.1.2: ITransformIntegration Implementation
  // ============================================================================

  @override
  Vector2 getPosition() => _position.clone();

  @override
  Vector2 getScale() => _scale.clone();

  @override
  double getRotation() => _rotation;

  @override
  Vector2 getPreviousPosition() => _prevPosition.clone();

  @override
  void syncWithPhysics(Vector2 position, {String? callerSystem}) {
    // Validate caller authorization
    if (!isAuthorizedCaller(callerSystem ?? '')) {
      _logPositionViolation('syncWithPhysics', callerSystem ?? 'Unknown');
      throw PositionAccessViolation(
        message: 'Unauthorized position synchronization attempt',
        violatingSystem: callerSystem ?? 'Unknown',
        attemptedOperation: 'syncWithPhysics',
      );
    }

    // Store previous position for interpolation
    _prevPosition = _position.clone();

    // Update position from physics
    _position.setFrom(position);

    // Update synchronization state
    _lastSyncTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _isSynchronized = true;
    _syncError = null;

    // Sync with parent if available
    if (parent is PositionComponent) {
      (parent as PositionComponent).position.setFrom(_position);
    }
  }

  @override
  bool isAuthorizedCaller(String callerSystem) {
    return callerSystem == _authorizedSystem;
  }

  @override
  bool isSynchronized() => _isSynchronized;

  @override
  double getLastSyncTime() => _lastSyncTime;

  @override
  String? getSynchronizationError() => _syncError;

  // Private helper to log position access violations
  void _logPositionViolation(String operation, String violatingSystem) {
    _logger.warning(
      'Position access violation: System "$violatingSystem" attempted "$operation". '
      'Position updates must go through PhysicsSystem.',
    );

    // Mark as desynchronized
    _isSynchronized = false;
    _syncError = 'Access violation by $violatingSystem';
  }
}

import 'dart:math';

import 'package:flame/components.dart';

/// Camera system with follow mechanics and effects
/// Handles camera movement, following player, and visual effects
class GameCamera extends Component {
  // Will be used in Sprint 2 when implementing smooth camera following
  // ignore: unused_field
  final Vector2 _targetPosition = Vector2.zero();
  Component? _followTarget;
  // Will be used in Sprint 2 when implementing smooth camera following
  // ignore: unused_field
  double _followSpeed = 5;
  Rectangle<int>? _bounds;

  /// Set the target for camera to follow
  void follow(Component target) {
    _followTarget = target;
  }

  /// Stop following current target
  void stopFollowing() {
    _followTarget = null;
  }

  /// Set camera follow speed
  void setFollowSpeed(double speed) {
    _followSpeed = speed;
  }

  /// Set camera bounds to constrain movement
  void setBounds(Rectangle<int> bounds) {
    _bounds = bounds;
  }

  /// Get current camera bounds
  Rectangle<int>? get bounds => _bounds;
  @override
  void update(double dt) {
    super.update(dt);

    if (_followTarget != null && _followTarget!.isMounted) {
      // Get target position
      if (_followTarget is PositionComponent) {
        final PositionComponent targetComp = _followTarget as PositionComponent;
        final Vector2 targetPosition = targetComp.position.clone();

        // Update target position for camera
        _targetPosition.setFrom(targetPosition);

        // Apply smooth camera following with lerp
        if (parent?.parent is CameraComponent) {
          final CameraComponent camera = parent!.parent as CameraComponent;
          final Vector2 currentPosition = camera.viewfinder.position.clone();

          // Lerp towards target position
          final Vector2 newPosition = currentPosition +
              ((_targetPosition - currentPosition) * _followSpeed * dt);

          // Apply camera bounds if set
          if (_bounds != null) {
            newPosition.x = newPosition.x
                .clamp(_bounds!.left.toDouble(), _bounds!.right.toDouble());
            newPosition.y = newPosition.y
                .clamp(_bounds!.top.toDouble(), _bounds!.bottom.toDouble());
          }

          // Apply the new camera position
          camera.viewfinder.position = newPosition;
        }
      }
    }
  }

  /// Shake the camera with given intensity and duration
  void shake(double intensity, double duration) {
    // TODO(camera): Implement camera shake effect
  }

  /// Smoothly move camera to target position
  void moveTo(Vector2 targetPosition, {double duration = 1.0}) {
    // TODO(camera): Implement smooth camera movement
  }
}

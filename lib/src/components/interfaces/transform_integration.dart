import 'package:flame/components.dart';

/// PHY-3.1.2: Interface for transform component integration
///
/// This interface defines the contract for transform components that need to
/// integrate with the PhysicsSystem through read-only position access patterns.
///
/// Key principles:
/// - Position updates ONLY through PhysicsSystem
/// - Read-only access for non-physics systems
/// - State synchronization with physics updates
/// - Validation of unauthorized access attempts
abstract class ITransformIntegration {
  // Position access (read-only)
  /// Get current position (read-only access)
  Vector2 getPosition();

  /// Get current scale
  Vector2 getScale();

  /// Get current rotation
  double getRotation();

  /// Get previous position for interpolation
  Vector2 getPreviousPosition();

  // Physics synchronization
  /// Synchronize transform with physics position (only callable by PhysicsSystem)
  void syncWithPhysics(Vector2 position, {String? callerSystem});

  /// Validate if caller is authorized to update position
  bool isAuthorizedCaller(String callerSystem);

  // Transform operations (non-position)
  /// Set scale (allowed for all systems)
  void setScale(Vector2 scale);

  /// Set rotation (allowed for all systems)
  void setRotation(double rotation);

  // State queries
  /// Check if transform is synchronized with physics
  bool isSynchronized();

  /// Get last synchronization timestamp
  double getLastSyncTime();

  /// Get synchronization error if any
  String? getSynchronizationError();
}

/// Position access violation exception
class PositionAccessViolation implements Exception {
  final String message;
  final String violatingSystem;
  final String attemptedOperation;

  PositionAccessViolation({
    required this.message,
    required this.violatingSystem,
    required this.attemptedOperation,
  });

  @override
  String toString() =>
      'PositionAccessViolation: $message (System: $violatingSystem, Operation: $attemptedOperation)';
}

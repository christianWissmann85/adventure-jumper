import 'package:flame/components.dart';

import '../../systems/interfaces/collision_notifier.dart' as notifier;
import '../../systems/interfaces/physics_state.dart';

/// PHY-3.1.3: Interface for collision component integration
///
/// This interface defines the contract for collision components that need to
/// integrate with the CollisionSystem and PhysicsSystem through the coordination
/// patterns established in the Physics-Movement refactor.
///
/// Key responsibilities:
/// - Collision state management and grounded state tracking
/// - Collision event generation and physics coordination
/// - Integration with ICollisionNotifier interface patterns
/// - Movement validation based on collision state
abstract class ICollisionIntegration {
  // Collision state management
  /// Process a collision event from the collision system
  Future<void> processCollisionEvent(CollisionEvent event);

  /// Update ground contact state with detailed information
  Future<void> updateGroundState(notifier.GroundInfo groundInfo);

  /// Validate if a movement in the given direction is allowed
  Future<bool> validateMovement(Vector2 movement);

  // Collision queries
  /// Get list of active collisions
  Future<List<CollisionInfo>> getActiveCollisions();

  /// Check if currently colliding with any object
  Future<bool> hasActiveCollisions();

  /// Get detailed ground contact information
  Future<notifier.GroundInfo?> getGroundInfo();

  /// Check if collision would occur with the given movement
  Future<List<CollisionInfo>> predictCollisions(Vector2 movement);

  /// Check if movement is blocked in a specific direction
  Future<bool> isMovementBlocked(Vector2 direction);

  // Collision notifications
  /// Called when collision begins
  void onCollisionEnter(CollisionInfo collision);

  /// Called when collision ends
  void onCollisionExit(CollisionInfo collision);

  /// Called when ground contact state changes
  void onGroundContact(notifier.GroundInfo groundInfo);

  // State synchronization
  /// Synchronize collision state with physics system
  Future<void> syncWithPhysics(PhysicsState physicsState);

  /// Clear all collision state (used for reset/respawn)
  Future<void> clearCollisionState();
}

/// Collision event data
class CollisionEvent {
  final String entityId;
  final CollisionEventType type;
  final CollisionInfo collisionInfo;
  final double timestamp;

  CollisionEvent({
    required this.entityId,
    required this.type,
    required this.collisionInfo,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;
}

/// Collision event types
enum CollisionEventType {
  collisionStart,
  collisionEnd,
  collisionUpdate,
  groundContact,
  groundLost,
}

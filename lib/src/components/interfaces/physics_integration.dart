import 'package:flame/components.dart';

import '../../systems/interfaces/collision_notifier.dart'; // For CollisionInfo
import '../../systems/interfaces/physics_state.dart' hide CollisionInfo; // Hide its version of CollisionInfo

/// PHY-3.1.1: Interface for physics component integration
///
/// This interface defines the contract for components that need to integrate
/// with the PhysicsSystem through the coordination patterns established in
/// the Physics-Movement refactor.
///
/// Implementing this interface ensures proper:
/// - State synchronization with PhysicsSystem
/// - Accumulation prevention mechanisms
/// - Lifecycle management for physics state
/// - Error recovery procedures
abstract class IPhysicsIntegration {
  // Physics state management
  /// Update the component's physics state with authoritative data from PhysicsSystem
  Future<void> updatePhysicsState(PhysicsState state);

  /// Reset all physics values to clean defaults, preventing accumulation
  Future<void> resetPhysicsValues();

  /// Prevent physics value accumulation by clearing accumulated forces and contact points
  Future<void> preventAccumulation();

  // Physics queries
  /// Get current position (read-only access to prevent unauthorized updates)
  Future<Vector2> getPosition();

  /// Get current velocity vector
  Future<Vector2> getVelocity();

  /// Check if entity is currently grounded
  Future<bool> isGrounded();

  /// Get comprehensive physics properties
  Future<PhysicsProperties> getPhysicsProperties();

  // Physics notifications
  /// Called when physics state is updated by PhysicsSystem
  void onPhysicsUpdate(PhysicsState state);

  /// Called when collision occurs
  void onCollision(CollisionInfo collision);

  /// Called when grounded state changes
  void onGroundStateChanged(bool isGrounded);
}

/// Physics properties data structure for IPhysicsIntegration
class PhysicsProperties {
  final double mass;
  final double gravityScale;
  final double friction;
  final double restitution;
  final bool isStatic;
  final bool affectedByGravity;
  final bool useEdgeDetection;

  const PhysicsProperties({
    required this.mass,
    required this.gravityScale,
    required this.friction,
    required this.restitution,
    required this.isStatic,
    required this.affectedByGravity,
    required this.useEdgeDetection,
  });

  /// Create default physics properties
  factory PhysicsProperties.defaults() {
    return const PhysicsProperties(
      mass: 1.0,
      gravityScale: 1.0,
      friction: 0.1,
      restitution: 0.2,
      isStatic: false,
      affectedByGravity: true,
      useEdgeDetection: false,
    );
  }
}

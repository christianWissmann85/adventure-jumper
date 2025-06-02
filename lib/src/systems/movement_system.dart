import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../components/physics_component.dart';
import '../components/transform_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';
import 'interfaces/physics_coordinator.dart';

/// System that manages entity movement processing
/// Handles movement request generation and coordination with PhysicsSystem
///
/// **PHY-2.3.1**: Refactored to remove direct position updates and use
/// request-based coordination via IPhysicsCoordinator interface
class MovementSystem extends BaseFlameSystem {
  MovementSystem({IPhysicsCoordinator? physicsCoordinator}) : super() {
    _physicsCoordinator = physicsCoordinator;
  }

  // Dependencies - will be injected by system manager
  IPhysicsCoordinator? _physicsCoordinator;

  // Configuration
  double _globalTimeScale = 1;

  @override
  bool canProcessEntity(Entity entity) {
    // Only process entities with physics components
    return entity.physics != null;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Apply scaled time
    final double scaledDt = dt * _globalTimeScale;

    // Skip processing if time scale is zero to avoid division by zero
    if (_globalTimeScale == 0.0) return;

    // Process entity movement
    final TransformComponent transform = entity.transformComponent;
    final PhysicsComponent physics =
        entity.physics!; // Safe now with canProcessEntity check

    // Skip static entities (don't move)
    if (physics.isStatic) return;

    // PHY-2.3.1: Request-based coordination replaces direct position updates
    // Generate movement requests based on current velocity instead of direct manipulation

    final Vector2 velocity = physics.velocity;
    if (velocity.x != 0 || velocity.y != 0) {
      final Vector2 oldPosition = transform.position.clone();

      // Check if physics coordinator is available for new request-based pattern
      if (_physicsCoordinator != null) {
        // NEW: Request-based movement coordination
        _requestMovementFromVelocity(
          entity.hashCode,
          velocity,
          dt,
        ); // Use original dt, not scaledDt
      } else {
        // LEGACY: Fallback to direct updates (to be removed after coordinator injection)
        _applyDirectMovement(entity, velocity, scaledDt, oldPosition);
      }
    }
  }

  /// NEW: Generate movement request from current velocity
  /// PHY-2.3.1 implementation - replaces direct position updates
  void _requestMovementFromVelocity(int entityId, Vector2 velocity, double dt) {
    try {
      // Calculate movement direction and speed from velocity
      final Vector2 direction = velocity.normalized();
      final double baseSpeed = velocity.length / dt; // Base speed from velocity
      final double scaledSpeed =
          baseSpeed * _globalTimeScale; // Apply time scale to speed

      // Submit movement request to physics coordinator
      // Using established MovementRequest.walk pattern internally
      _physicsCoordinator!.requestMovement(entityId, direction, scaledSpeed);

      // Debug logging for velocity-based movement requests
      if (scaledSpeed > 1.0) {
        developer.log(
          'Movement: Generated request for Entity $entityId (direction: ${direction.x.toStringAsFixed(1)},${direction.y.toStringAsFixed(1)}, speed: ${scaledSpeed.toStringAsFixed(1)})',
          name: 'MovementSystem',
        );
      }
    } catch (error) {
      developer.log(
        'Movement: Failed to generate movement request for Entity $entityId: $error',
        name: 'MovementSystem',
      );
      // Fallback: No movement if request fails
    }
  }

  /// LEGACY: Direct movement application (to be removed after full coordinator integration)
  void _applyDirectMovement(
    Entity entity,
    Vector2 velocity,
    double scaledDt,
    Vector2 oldPosition,
  ) {
    final Vector2 newPosition =
        entity.transformComponent.position + (velocity * scaledDt);
    entity.transformComponent.setPosition(newPosition);

    // CRITICAL ISSUE - Direct position update (WILL BE REMOVED)
    entity.position = newPosition;

    // Debug output for direct position changes
    if ((velocity.x.abs() > 1.0 || velocity.y.abs() > 1.0)) {
      developer.log(
        'Movement: LEGACY Entity ${entity.id} moved from ${oldPosition.x.toStringAsFixed(1)},${oldPosition.y.toStringAsFixed(1)} to ${newPosition.x.toStringAsFixed(1)},${newPosition.y.toStringAsFixed(1)} (velocity: ${velocity.x.toStringAsFixed(1)},${velocity.y.toStringAsFixed(1)})',
        name: 'MovementSystem',
      );
    }
  }

  /// Set global time scale for all movement
  void setTimeScale(double timeScale) {
    _globalTimeScale = timeScale;
  }

  /// Inject physics coordinator for request-based coordination
  /// PHY-2.3.1: Enables transition from direct updates to request-based pattern
  void setPhysicsCoordinator(IPhysicsCoordinator coordinator) {
    _physicsCoordinator = coordinator;
    developer.log(
      'Movement: Physics coordinator injected - enabling request-based movement',
      name: 'MovementSystem',
    );
  }

  // Getters
  double get timeScale => _globalTimeScale;

  @override
  void initialize() {
    // Initialize movement system
    developer.log(
      'Movement: System initialized - ${_physicsCoordinator != null ? "request-based" : "legacy"} mode',
      name: 'MovementSystem',
    );
  }
}

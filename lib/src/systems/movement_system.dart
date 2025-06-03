import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../components/physics_component.dart';
import '../components/transform_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';
import 'interfaces/physics_coordinator.dart';
import 'interfaces/movement_request.dart';
import 'interfaces/movement_response.dart';
import 'request_processing/movement_request_processor.dart';
import 'request_processing/request_validator.dart';

/// System that manages entity movement processing
/// Handles movement request generation and coordination with PhysicsSystem
///
/// **PHY-2.3.1**: Refactored to remove direct position updates and use
/// request-based coordination via IPhysicsCoordinator interface
/// **PHY-2.3.2**: Integrated request processing pipeline with validation
/// **PHY-2.3.3**: Full physics coordination integration
class MovementSystem extends BaseFlameSystem {
  MovementSystem({IPhysicsCoordinator? physicsCoordinator}) : super() {
    _physicsCoordinator = physicsCoordinator;
    if (_physicsCoordinator != null) {
      _requestProcessor = MovementRequestProcessor(_physicsCoordinator!);
    }
  }

  // Dependencies - will be injected by system manager
  IPhysicsCoordinator? _physicsCoordinator;

  // Request processing pipeline (PHY-2.3.2)
  MovementRequestProcessor? _requestProcessor;

  // Request validation (PHY-2.3.2)
  final RequestValidator _validator = RequestValidator();

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
  /// PHY-2.3.3 implementation - full physics coordination integration
  void _requestMovementFromVelocity(
      int entityId, Vector2 velocity, double dt,) async {
    try {
      // Calculate movement direction and speed from velocity
      final Vector2 direction = velocity.normalized();
      final double baseSpeed = velocity.length / dt; // Base speed from velocity
      final double scaledSpeed =
          baseSpeed * _globalTimeScale; // Apply time scale to speed

      // Create structured movement request (PHY-2.3.2)
      final request = MovementRequest.walk(
        entityId: entityId,
        direction: direction,
        speed: scaledSpeed,
        priority: MovementPriority.normal,
      );

      // Validate request before processing (PHY-2.3.2)
      final validationResult = _validator.validateMovementRequest(request);
      if (!validationResult.isValid) {
        developer.log(
          'Movement: Invalid request for Entity $entityId: ${validationResult.errorMessage}',
          name: 'MovementSystem',
        );
        return;
      }

      // Process through pipeline if available (PHY-2.3.3)
      if (_requestProcessor != null) {
        final response = await _requestProcessor!.processRequest(request);

        if (response.status != MovementResponseStatus.success) {
          developer.log(
            'Movement: Request failed for Entity $entityId: ${response.constraintReason ?? "Unknown reason"}',
            name: 'MovementSystem',
          );
        }
      } else {
        // Direct coordinator call as fallback
        _physicsCoordinator!.requestMovement(entityId, direction, scaledSpeed);
      }

      // Debug logging for velocity-based movement requests
      if (scaledSpeed > 1.0) {
        developer.log(
          'Movement: Processed request for Entity $entityId (direction: ${direction.x.toStringAsFixed(1)},${direction.y.toStringAsFixed(1)}, speed: ${scaledSpeed.toStringAsFixed(1)})',
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
  /// PHY-2.3.3: Creates request processor for full pipeline integration
  void setPhysicsCoordinator(IPhysicsCoordinator coordinator) {
    _physicsCoordinator = coordinator;
    _requestProcessor = MovementRequestProcessor(coordinator);
    developer.log(
      'Movement: Physics coordinator injected - enabling request-based movement with full pipeline',
      name: 'MovementSystem',
    );
  }

  // Getters
  double get timeScale => _globalTimeScale;

  /// Create movement request with responsiveness preservation (PHY-2.3.4)
  /// Ensures movement feels responsive despite request-based architecture
  MovementRequest createResponsiveMovementRequest({
    required int entityId,
    required Vector2 direction,
    required double speed,
    MovementType type = MovementType.walk,
  }) {
    // Apply movement curves for responsiveness
    final responsiveSpeed = _applyMovementCurve(speed, type);

    // Use higher priority for player movement to ensure responsiveness
    final priority = type == MovementType.dash
        ? MovementPriority.high
        : MovementPriority.normal;

    return MovementRequest(
      entityId: entityId,
      type: type,
      direction: direction,
      magnitude: responsiveSpeed,
      priority: priority,
    );
  }

  /// Apply movement curves to maintain game feel (PHY-2.3.4)
  double _applyMovementCurve(double baseSpeed, MovementType type) {
    switch (type) {
      case MovementType.walk:
        // Smooth acceleration curve for walking
        return baseSpeed * _smoothAccelerationCurve(_globalTimeScale);

      case MovementType.dash:
        // Instant response for dashing
        return baseSpeed * 1.5 * _globalTimeScale;

      case MovementType.jump:
        // Preserve jump height consistency
        return baseSpeed;

      default:
        return baseSpeed * _globalTimeScale;
    }
  }

  /// Smooth acceleration curve for natural movement feel
  double _smoothAccelerationCurve(double t) {
    // Ease-in-out curve for smooth acceleration
    if (t < 0.5) {
      return 2 * t * t;
    } else {
      return 1 - 2 * (1 - t) * (1 - t);
    }
  }

  /// Validate movement responsiveness metrics (PHY-2.3.4)
  bool validateMovementResponsiveness(double requestTime, double responseTime) {
    const double maxAcceptableLatency = 33.34; // 2 frames at 60fps
    final latency = responseTime - requestTime;

    if (latency > maxAcceptableLatency) {
      developer.log(
        'Movement: Responsiveness warning - latency ${latency.toStringAsFixed(1)}ms exceeds 2 frame threshold',
        name: 'MovementSystem',
      );
      return false;
    }

    return true;
  }

  /// Get movement system statistics including responsiveness metrics
  Map<String, dynamic> get statistics {
    final stats = <String, dynamic>{
      'mode': _requestProcessor != null
          ? 'pipeline'
          : (_physicsCoordinator != null ? 'request-based' : 'legacy'),
      'timeScale': _globalTimeScale,
    };

    if (_requestProcessor != null) {
      stats['pipeline'] = _requestProcessor!.statistics;
    }

    stats['validation'] = _validator.statistics;
  
    return stats;
  }

  @override
  void initialize() {
    // Initialize movement system
    final mode = _requestProcessor != null
        ? "full pipeline mode"
        : (_physicsCoordinator != null ? "request-based mode" : "legacy mode");
    developer.log(
      'Movement: System initialized - $mode',
      name: 'MovementSystem',
    );
  }

  /// Process any queued movement requests (PHY-2.3.3)
  @override
  void update(double dt) {
    super.update(dt);

    // Process queued requests if pipeline is available
    if (_requestProcessor != null) {
      _requestProcessor!.processAllQueuedRequests();
    }
  }
}

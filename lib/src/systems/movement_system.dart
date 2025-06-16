import 'dart:developer' as developer;

import 'package:flame/components.dart';
import 'package:logging/logging.dart';

import '../components/physics_component.dart';
import '../components/transform_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';
import 'interfaces/movement_coordinator.dart';
import 'interfaces/movement_request.dart';
import 'interfaces/movement_response.dart';
import 'interfaces/physics_coordinator.dart';
import 'interfaces/physics_state.dart';
import 'request_processing/movement_request_processor.dart';
import 'request_processing/request_validator.dart';

// Logger for movement system
final Logger logger = Logger('MovementSystem');

/// System that manages entity movement processing
/// Handles movement request generation and coordination with PhysicsSystem
///
/// **PHY-2.3.1**: Refactored to remove direct position updates and use
/// request-based coordination via IPhysicsCoordinator interface
/// **PHY-2.3.2**: Integrated request processing pipeline with validation
/// **PHY-2.3.3**: Full physics coordination integration
/// **PHY-3.3.2-Bis.2**: Implements IMovementCoordinator interface for Player entity coordination
class MovementSystem extends BaseFlameSystem implements IMovementCoordinator {
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
    int entityId,
    Vector2 velocity,
    double dt,
  ) async {
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
    // CRITICAL ISSUE - Direct position update (WILL BE REMOVED)
    // The call to entity.transformComponent.setPosition(newPosition); was removed here as it's deprecated
    // and entity.position = newPosition; (below) is expected to handle the transform component update.
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

  /// PHY-3.3.2-Bis.2: Inject movement coordinator for Player entities
  @override
  void onEntityAdded(Entity entity) {
    super.onEntityAdded(entity);

    // PHY-3.3.2-Bis.2: Inject movement coordinator for Player entities
    if (entity.type == 'player') {
      try {
        final player = entity as dynamic;
        if (player.setMovementCoordinator != null) {
          player.setMovementCoordinator(this);
          logger.info('Movement coordinator injected into Player entity');
        }
      } catch (e) {
        logger.warning('Failed to inject movement coordinator into Player: $e');
      }
    }
  }

  // ============================================================================
  // IMovementCoordinator Implementation
  // ============================================================================

  /// Submit movement request for processing (PHY-3.3.2-Bis.2)
  @override
  Future<MovementResponse> submitMovementRequest(
    MovementRequest request,
  ) async {
    if (_physicsCoordinator == null) {
      return MovementResponse.failed(
        request: request,
        reason: 'Physics coordinator not available',
      );
    }

    // Validate request
    final validationResult = _validator.validateMovementRequest(request);
    if (!validationResult.isValid) {
      return MovementResponse.failed(
        request: request,
        reason: validationResult.errorMessage ?? 'Invalid request',
      );
    }

    // Process through physics coordinator
    try {
      switch (request.type) {
        case MovementType.walk:
        case MovementType.dash:
          return await _physicsCoordinator!.requestMovement(
            request.entityId,
            request.direction,
            request.magnitude,
          );
        case MovementType.jump:
          return await _physicsCoordinator!.requestJump(
            request.entityId,
            request.magnitude,
          );
        case MovementType.stop:
          await _physicsCoordinator!.requestStop(request.entityId);
          return MovementResponse.success(
            request: request,
            actualVelocity: Vector2.zero(),
            actualPosition:
                await _physicsCoordinator!.getPosition(request.entityId),
            isGrounded: await _physicsCoordinator!.isGrounded(request.entityId),
          );
        default:
          return MovementResponse.failed(
            request: request,
            reason: 'Unsupported movement type: ${request.type}',
          );
      }
    } catch (e) {
      logger.warning('Movement request processing failed: $e');
      return MovementResponse.failed(
        request: request,
        reason: 'Processing error: $e',
      );
    }
  }

  /// Submit batch requests (basic implementation)
  @override
  Future<List<MovementResponse>> submitBatchRequests(
    List<MovementRequest> requests,
  ) async {
    final responses = <MovementResponse>[];
    for (final request in requests) {
      responses.add(await submitMovementRequest(request));
    }
    return responses;
  }

  /// Handle movement input (convenience method)
  @override
  Future<MovementResponse> handleMovementInput(
    int entityId,
    Vector2 direction,
    double speed,
  ) async {
    final request = MovementRequest.walk(
      entityId: entityId,
      direction: direction,
      speed: speed,
    );
    return await submitMovementRequest(request);
  }

  /// Handle jump input (basic implementation)
  @override
  Future<MovementResponse> handleJumpInput(
    int entityId,
    double force, {
    bool variableHeight = true,
  }) async {
    final request = MovementRequest.jump(
      entityId: entityId,
      force: force,
    );
    return await submitMovementRequest(request);
  }

  /// Handle stop input
  @override
  Future<MovementResponse> handleStopInput(int entityId) async {
    final request = MovementRequest.stop(entityId: entityId);
    return await submitMovementRequest(request);
  }

  // ============================================================================
  // Movement State Queries (Basic Implementation)
  // ============================================================================

  @override
  Future<bool> canMove(int entityId) async {
    return _physicsCoordinator != null;
  }

  @override
  Future<bool> canJump(int entityId) async {
    if (_physicsCoordinator == null) return false;
    return await _physicsCoordinator!.isGrounded(entityId);
  }

  @override
  Future<bool> canDash(int entityId) async {
    return _physicsCoordinator != null;
  }

  @override
  Future<List<MovementType>> getAvailableActions(int entityId) async {
    final actions = <MovementType>[];
    if (await canMove(entityId)) {
      actions.addAll([MovementType.walk, MovementType.stop]);
    }
    if (await canJump(entityId)) {
      actions.add(MovementType.jump);
    }
    if (await canDash(entityId)) {
      actions.add(MovementType.dash);
    }
    return actions;
  }

  @override
  Future<bool> isActionBlocked(MovementType action, int entityId) async {
    switch (action) {
      case MovementType.walk:
        return !(await canMove(entityId));
      case MovementType.jump:
        return !(await canJump(entityId));
      case MovementType.dash:
        return !(await canDash(entityId));
      default:
        return false;
    }
  }

  // ============================================================================
  // Accumulation Prevention (Basic Implementation)
  // ============================================================================

  @override
  void preventAccumulation(int entityId) {
    if (_physicsCoordinator != null) {
      _physicsCoordinator!.resetPhysicsState(entityId);
    }
  }

  @override
  Future<bool> hasAccumulation(int entityId) async {
    // Basic implementation - could be enhanced with actual accumulation detection
    return false;
  }

  // ============================================================================
  // Error Handling (Basic Implementation)
  // ============================================================================

  @override
  void onMovementRequestFailed(MovementRequest request, String reason) {
    logger.warning(
      'Movement request failed for entity ${request.entityId}: $reason',
    );
  }

  @override
  void onMovementError(
    int entityId,
    String error,
    Map<String, dynamic>? context,
  ) {
    logger.warning('Movement error for entity $entityId: $error');
  }

  // ============================================================================
  // System Coordination (Basic Implementation)
  // ============================================================================

  @override
  Future<void> updateMovementState(
    int entityId,
    PhysicsState physicsState,
  ) async {
    // Basic implementation - could be enhanced with state tracking
  }

  @override
  Future<void> resetMovementState(int entityId) async {
    // Basic implementation - could be enhanced with state management
  }
  @override
  Future<bool> validateSystemIntegrity() async {
    return _physicsCoordinator != null;
  }

  @override
  Future<MovementState> getMovementState(int entityId) async {
    // Basic implementation - return idle state
    return MovementState.idle(entityId);
  }
}

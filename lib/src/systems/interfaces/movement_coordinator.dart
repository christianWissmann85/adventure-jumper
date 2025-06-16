import 'package:flame/components.dart';

import '../../utils/math_utils.dart';
import 'movement_request.dart';
import 'movement_response.dart';
import 'physics_state.dart';

/// Movement system coordination interface for input processing and request handling.
///
/// This interface establishes the movement system coordination layer for the
/// Physics-Movement System Refactor effort (PHY-2.1.1), providing structured
/// movement request processing and state validation.
///
/// **Movement Processing Pipeline:**
/// - Input validation against physics state
/// - Movement request generation and submission
/// - Request-response coordination with physics system
/// - Movement capability queries for input validation
///
/// **Design Principles:**
/// - Request-based movement processing (no direct physics manipulation)
/// - Input validation against current physics state
/// - Capability-based input filtering
/// - Error recovery for failed movement requests
///
/// **System Integration Pattern:**
/// ```dart
/// // Input system generates movement requests
/// final response = await movementCoordinator.submitMovementRequest(request);
///
/// // Validate movement capabilities before input processing
/// if (await movementCoordinator.canMove(entityId)) {
///   await movementCoordinator.handleMovementInput(entityId, direction, speed);
/// }
/// ```
abstract class IMovementCoordinator {
  // ============================================================================
  // Movement Request Processing
  // ============================================================================

  /// Submit movement request for processing.
  ///
  /// Primary method for submitting movement requests to the physics system.
  /// Validates request parameters and coordinates with physics for execution.
  ///
  /// **Parameters:**
  /// - [request]: Movement request with validated parameters
  ///
  /// **Returns:** MovementResponse with execution results and applied values
  ///
  /// **Validation:**
  /// - Request parameters must be valid and within system limits
  /// - Entity must exist and have movement capabilities
  /// - Movement must not conflict with current physics constraints
  ///
  /// **Example:**
  /// ```dart
  /// final request = MovementRequest.walk(
  ///   entityId: playerId,
  ///   direction: Vector2(1, 0),
  ///   speed: 200.0,
  /// );
  /// final response = await coordinator.submitMovementRequest(request);
  /// ```
  Future<MovementResponse> submitMovementRequest(MovementRequest request);

  /// Submit multiple movement requests in batch.
  ///
  /// Optimized processing for multiple requests, typically used for
  /// complex input sequences or multi-entity movement coordination.
  ///
  /// **Parameters:**
  /// - [requests]: List of movement requests to process
  ///
  /// **Returns:** List of MovementResponse objects corresponding to each request
  ///
  /// **Processing Order:** Requests processed by priority, then submission order
  Future<List<MovementResponse>> submitBatchRequests(
    List<MovementRequest> requests,
  );

  /// Handle direct movement input from input system.
  ///
  /// Convenience method for direct input processing. Generates appropriate
  /// MovementRequest and submits for processing.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  /// - [direction]: Normalized movement direction
  /// - [speed]: Movement speed in pixels per second
  ///
  /// **Returns:** MovementResponse with processing results
  Future<MovementResponse> handleMovementInput(
    int entityId,
    Vector2 direction,
    double speed,
  );

  /// Handle jump input with variable height support.
  ///
  /// Processes jump input with support for variable jump height based on
  /// input duration. Validates jump capability before processing.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  /// - [force]: Jump force magnitude
  /// - [variableHeight]: Enable variable height based on input duration
  ///
  /// **Returns:** MovementResponse indicating jump success/failure
  Future<MovementResponse> handleJumpInput(
    int entityId,
    double force, {
    bool variableHeight = true,
  });

  /// Handle stop movement input.
  ///
  /// Processes stop input to halt entity movement. May apply gradual
  /// deceleration rather than instant stopping for natural feel.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  ///
  /// **Returns:** MovementResponse with stop processing results
  Future<MovementResponse> handleStopInput(int entityId);

  // ============================================================================
  // Movement State Queries
  // ============================================================================

  /// Check if entity can perform movement.
  ///
  /// Validates entity movement capabilities against current physics state
  /// and any active movement constraints.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check movement capability
  ///
  /// **Returns:** True if entity can move, false otherwise
  ///
  /// **Validation Factors:**
  /// - Entity exists and has movement component
  /// - No blocking movement constraints active
  /// - Physics state allows movement
  Future<bool> canMove(int entityId);

  /// Check if entity can perform jump.
  ///
  /// Validates jump capability based on grounded state, jump cooldown,
  /// and any active jump constraints.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check jump capability
  ///
  /// **Returns:** True if entity can jump, false otherwise
  ///
  /// **Jump Requirements:**
  /// - Entity must be grounded or within coyote time
  /// - No active jump cooldown
  /// - Entity has jump capability
  Future<bool> canJump(int entityId);

  /// Check if entity can perform dash.
  ///
  /// Validates dash capability based on dash cooldown, energy availability,
  /// and movement state.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check dash capability
  ///
  /// **Returns:** True if entity can dash, false otherwise
  Future<bool> canDash(int entityId);

  /// Get current movement state for entity.
  ///
  /// Retrieves comprehensive movement state information for debugging
  /// and coordination purposes.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to query movement state
  ///
  /// **Returns:** MovementState with current movement information
  Future<MovementState> getMovementState(int entityId);

  /// Get available movement actions for entity.
  ///
  /// Returns list of movement actions currently available to the entity
  /// based on physics state and capabilities.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to query available actions
  ///
  /// **Returns:** List of available movement actions
  Future<List<MovementType>> getAvailableActions(int entityId);

  /// Check if specific movement action is blocked.
  ///
  /// Validates whether a specific movement action is currently blocked
  /// by constraints or physics state.
  ///
  /// **Parameters:**
  /// - [action]: Movement action to check
  /// - [entityId]: Entity to check action availability
  ///
  /// **Returns:** True if action is blocked, false if available
  Future<bool> isActionBlocked(MovementType action, int entityId);

  // ============================================================================
  // Accumulation Prevention
  // ============================================================================

  /// Prevent physics accumulation for entity.
  ///
  /// Called during rapid input sequences to prevent physics accumulation
  /// that can cause degradation over time.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to prevent accumulation for
  ///
  /// **Prevention Actions:**
  /// - Clamp velocity and forces to safe ranges
  /// - Apply accumulation damping
  /// - Reset problematic physics values
  void preventAccumulation(int entityId);

  /// Check if entity has physics accumulation.
  ///
  /// Detects physics accumulation that may cause degradation or instability.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to check for accumulation
  ///
  /// **Returns:** True if accumulation detected, false otherwise
  Future<bool> hasAccumulation(int entityId);

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Handle failed movement request.
  ///
  /// Called when movement request processing fails. Provides error recovery
  /// and fallback procedures.
  ///
  /// **Parameters:**
  /// - [request]: Failed movement request
  /// - [reason]: Failure reason description
  ///
  /// **Error Recovery:**
  /// - Log error for debugging
  /// - Attempt fallback movement if applicable
  /// - Notify dependent systems of failure
  void onMovementRequestFailed(MovementRequest request, String reason);

  /// Handle movement processing error.
  ///
  /// Called when movement processing encounters errors. Implements error
  /// recovery procedures to maintain system stability.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity that encountered error
  /// - [error]: Error information
  /// - [context]: Additional error context
  void onMovementError(
    int entityId,
    String error,
    Map<String, dynamic>? context,
  );

  // ============================================================================
  // System Coordination
  // ============================================================================

  /// Update movement state from physics system.
  ///
  /// Called by physics system to update movement state after physics
  /// processing. Maintains synchronization between systems.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity with updated state
  /// - [physicsState]: Current physics state
  ///
  /// **Synchronization:**
  /// - Update movement state with physics results
  /// - Validate state consistency
  /// - Update movement capabilities based on new state
  Future<void> updateMovementState(int entityId, PhysicsState physicsState);

  /// Reset movement state for entity.
  ///
  /// Resets movement state during entity lifecycle events such as respawn
  /// or teleportation. Prevents state accumulation issues.
  ///
  /// **Parameters:**
  /// - [entityId]: Entity to reset movement state
  ///
  /// **Reset Actions:**
  /// - Clear movement history
  /// - Reset movement capabilities
  /// - Clear pending movement requests
  Future<void> resetMovementState(int entityId);

  /// Validate movement system integrity.
  ///
  /// Performs system-wide validation of movement state consistency and
  /// coordination with physics system.
  ///
  /// **Returns:** True if system integrity is valid, false otherwise
  ///
  /// **Validation Checks:**
  /// - Movement state consistency
  /// - Physics system synchronization
  /// - Request processing pipeline integrity
  Future<bool> validateSystemIntegrity();
}

/// Movement state information for coordination and debugging.
///
/// Provides comprehensive movement state data for system coordination,
/// debugging, and validation purposes.
class MovementState {
  /// Entity identifier
  final int entityId;

  /// Current movement type being performed
  final MovementType currentMovement;

  /// Target velocity from movement processing
  final Vector2 targetVelocity;

  /// Current input direction
  final Vector2 inputDirection;

  /// Current movement speed
  final double movementSpeed;

  /// Whether entity is currently moving
  final bool isMoving;

  /// Whether entity was moving in previous frame
  final bool wasMoving;

  /// Last successful physics synchronization time
  final DateTime lastPhysicsSync;

  /// Number of physics synchronization attempts
  final int syncAttempts;

  /// Whether movement and physics are synchronized
  final bool isSynchronized;

  /// Last confirmed position from physics system
  final Vector2 lastConfirmedPosition;

  /// Active movement constraints
  final List<String> activeConstraints;

  /// Movement capabilities for this entity
  final Map<MovementType, bool> capabilities;

  /// Last movement request processing time
  final DateTime lastRequestTime;

  /// Number of pending movement requests
  final int pendingRequests;

  /// Movement error count for this entity
  final int errorCount;

  /// Whether accumulation prevention is active
  final bool accumulationPrevention;

  const MovementState({
    required this.entityId,
    required this.currentMovement,
    required this.targetVelocity,
    required this.inputDirection,
    required this.movementSpeed,
    required this.isMoving,
    required this.wasMoving,
    required this.lastPhysicsSync,
    required this.syncAttempts,
    required this.isSynchronized,
    required this.lastConfirmedPosition,
    required this.activeConstraints,
    required this.capabilities,
    required this.lastRequestTime,
    required this.pendingRequests,
    required this.errorCount,
    required this.accumulationPrevention,
  });

  /// Create movement state with default values
  factory MovementState.idle(int entityId) {
    return MovementState(
      entityId: entityId,
      currentMovement: MovementType.stop,
      targetVelocity: Vector2.zero(),
      inputDirection: Vector2.zero(),
      movementSpeed: 0.0,
      isMoving: false,
      wasMoving: false,
      lastPhysicsSync: DateTime.now(),
      syncAttempts: 0,
      isSynchronized: true,
      lastConfirmedPosition: Vector2.zero(),
      activeConstraints: [],
      capabilities: {
        MovementType.walk: true,
        MovementType.jump: true,
        MovementType.stop: true,
      },
      lastRequestTime: DateTime.now(),
      pendingRequests: 0,
      errorCount: 0,
      accumulationPrevention: false,
    );
  }

  /// Create copy with updated values
  MovementState copyWith({
    MovementType? currentMovement,
    Vector2? targetVelocity,
    Vector2? inputDirection,
    double? movementSpeed,
    bool? isMoving,
    bool? wasMoving,
    DateTime? lastPhysicsSync,
    int? syncAttempts,
    bool? isSynchronized,
    Vector2? lastConfirmedPosition,
    List<String>? activeConstraints,
    Map<MovementType, bool>? capabilities,
    DateTime? lastRequestTime,
    int? pendingRequests,
    int? errorCount,
    bool? accumulationPrevention,
  }) {
    return MovementState(
      entityId: entityId,
      currentMovement: currentMovement ?? this.currentMovement,
      targetVelocity: targetVelocity ?? this.targetVelocity,
      inputDirection: inputDirection ?? this.inputDirection,
      movementSpeed: movementSpeed ?? this.movementSpeed,
      isMoving: isMoving ?? this.isMoving,
      wasMoving: wasMoving ?? this.wasMoving,
      lastPhysicsSync: lastPhysicsSync ?? this.lastPhysicsSync,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      isSynchronized: isSynchronized ?? this.isSynchronized,
      lastConfirmedPosition:
          lastConfirmedPosition ?? this.lastConfirmedPosition,
      activeConstraints: activeConstraints ?? this.activeConstraints,
      capabilities: capabilities ?? this.capabilities,
      lastRequestTime: lastRequestTime ?? this.lastRequestTime,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      errorCount: errorCount ?? this.errorCount,
      accumulationPrevention:
          accumulationPrevention ?? this.accumulationPrevention,
    );
  }

  /// Check if movement state is valid
  bool get isValid {
    return entityId > 0 &&
        MathUtils.isVector2Finite(targetVelocity) &&
        MathUtils.isVector2Finite(inputDirection) &&
        movementSpeed.isFinite &&
        movementSpeed >= 0 &&
        syncAttempts >= 0 &&
        MathUtils.isVector2Finite(lastConfirmedPosition) &&
        pendingRequests >= 0 &&
        errorCount >= 0;
  }

  /// Check if movement state has detected movement
  bool get hasMovement {
    return isMoving || targetVelocity.length > 0.1;
  }

  /// Check if physics synchronization is current
  bool get isPhysicsSyncCurrent {
    final timeSinceSync = DateTime.now().difference(lastPhysicsSync);
    return isSynchronized && timeSinceSync.inMilliseconds < 100; // Within 100ms
  }

  /// Check if movement capability is available
  bool hasCapability(MovementType type) {
    return capabilities[type] ?? false;
  }

  /// Get movement state summary for debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'entityId': entityId,
      'currentMovement': currentMovement.name,
      'targetVelocity':
          '${targetVelocity.x.toStringAsFixed(1)}, ${targetVelocity.y.toStringAsFixed(1)}',
      'inputDirection':
          '${inputDirection.x.toStringAsFixed(1)}, ${inputDirection.y.toStringAsFixed(1)}',
      'movementSpeed': movementSpeed.toStringAsFixed(1),
      'isMoving': isMoving,
      'wasMoving': wasMoving,
      'isSynchronized': isSynchronized,
      'syncAttempts': syncAttempts,
      'activeConstraints': activeConstraints.join(', '),
      'pendingRequests': pendingRequests,
      'errorCount': errorCount,
      'accumulationPrevention': accumulationPrevention,
      'isValid': isValid,
      'hasMovement': hasMovement,
      'physicsSync': isPhysicsSyncCurrent ? 'current' : 'stale',
    };
  }

  @override
  String toString() {
    return 'MovementState(entity: $entityId, movement: ${currentMovement.name}, '
        'moving: $isMoving, synchronized: $isSynchronized, valid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovementState &&
        other.entityId == entityId &&
        other.currentMovement == currentMovement &&
        other.targetVelocity == targetVelocity &&
        other.inputDirection == inputDirection &&
        other.movementSpeed == movementSpeed &&
        other.isMoving == isMoving &&
        other.wasMoving == wasMoving &&
        other.isSynchronized == isSynchronized;
  }

  @override
  int get hashCode {
    return Object.hash(
      entityId,
      currentMovement,
      targetVelocity,
      inputDirection,
      movementSpeed,
      isMoving,
      wasMoving,
      isSynchronized,
    );
  }
}

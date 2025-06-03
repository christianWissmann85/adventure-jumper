import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../interfaces/movement_request.dart';
import '../interfaces/movement_response.dart';
import '../interfaces/physics_coordinator.dart';

/// Processes movement requests with validation, queuing, and conflict resolution.
///
/// This processor implements the request processing pipeline as specified in
/// PHY-2.3.2 of the Physics-Movement System Refactor. It handles:
/// - Request validation and sanitization
/// - Priority-based queuing
/// - Conflict resolution for simultaneous requests
/// - Error recovery and fallback behavior
///
/// **Design Principles:**
/// - Process requests in priority order
/// - Prevent conflicting movements on the same entity
/// - Maintain performance with efficient queue management
/// - Provide detailed logging for debugging
class MovementRequestProcessor {
  /// Physics coordinator for executing validated requests
  final IPhysicsCoordinator _physicsCoordinator;

  /// Request queues organized by entity ID
  final Map<int, Queue<MovementRequest>> _requestQueues = {};

  /// Active requests being processed (one per entity)
  final Map<int, MovementRequest> _activeRequests = {};

  /// Request processing statistics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _conflictedRequests = 0;

  /// Maximum queue size per entity to prevent memory issues
  static const int maxQueueSize = 10;

  /// Maximum request age before expiration (milliseconds)
  static const int requestTimeoutMs = 100;

  MovementRequestProcessor(this._physicsCoordinator);

  /// Process a movement request through the pipeline.
  ///
  /// **Pipeline Steps:**
  /// 1. Validate request data
  /// 2. Check for conflicts with active requests
  /// 3. Queue if necessary based on priority
  /// 4. Execute request through physics coordinator
  /// 5. Handle response and errors
  ///
  /// **Returns:** Movement response indicating success/failure
  Future<MovementResponse> processRequest(MovementRequest request) async {
    _totalRequests++;

    // Step 1: Validate request
    if (!_validateRequest(request)) {
      _failedRequests++;
      return MovementResponse.failed(
        request: request,
        reason: 'Invalid request data',
      );
    }

    // Step 2: Check for expired requests
    if (request.isExpired(requestTimeoutMs)) {
      _failedRequests++;
      developer.log(
        'Request expired for entity ${request.entityId} (age: ${request.ageInMilliseconds}ms)',
        name: 'MovementRequestProcessor',
      );
      return MovementResponse.failed(
        request: request,
        reason: 'Request expired',
      );
    }

    // Step 3: Handle conflicts and queuing
    final existingActive = _activeRequests[request.entityId];
    if (existingActive != null) {
      // Entity already has an active request
      return _handleConflict(request, existingActive);
    }

    // Step 4: Mark as active and process
    _activeRequests[request.entityId] = request;

    try {
      // Execute request through physics coordinator
      final response = await _executeRequest(request);

      if (response.wasSuccessful) {
        _successfulRequests++;
      } else {
        _failedRequests++;
      }

      return response;
    } catch (error) {
      _failedRequests++;
      developer.log(
        'Error processing request for entity ${request.entityId}: $error',
        name: 'MovementRequestProcessor',
        error: error,
      );

      return MovementResponse.failed(
        request: request,
        reason: 'Processing error: $error',
      );
    } finally {
      // Remove from active requests
      _activeRequests.remove(request.entityId);

      // Process any queued requests for this entity
      _processQueuedRequests(request.entityId);
    }
  }

  /// Validate request before processing.
  bool _validateRequest(MovementRequest request) {
    // Use built-in validation
    if (!request.isValid) {
      developer.log(
        'Invalid request for entity ${request.entityId}: $request',
        name: 'MovementRequestProcessor',
      );
      return false;
    }

    // Additional validation for specific types
    switch (request.type) {
      case MovementType.walk:
      case MovementType.dash:
        // Ensure reasonable speed limits
        if (request.magnitude > 10000) {
          developer.log(
            'Speed too high for entity ${request.entityId}: ${request.magnitude}',
            name: 'MovementRequestProcessor',
          );
          return false;
        }
        break;

      case MovementType.jump:
        // Ensure reasonable jump force
        if (request.magnitude > 5000) {
          developer.log(
            'Jump force too high for entity ${request.entityId}: ${request.magnitude}',
            name: 'MovementRequestProcessor',
          );
          return false;
        }
        break;

      case MovementType.impulse:
        // Ensure reasonable impulse force
        if (request.magnitude > 20000) {
          developer.log(
            'Impulse too high for entity ${request.entityId}: ${request.magnitude}',
            name: 'MovementRequestProcessor',
          );
          return false;
        }
        break;

      case MovementType.stop:
        // Stop requests are always valid if they pass basic validation
        break;
    }

    return true;
  }

  /// Handle conflicting requests for the same entity.
  MovementResponse _handleConflict(
    MovementRequest newRequest,
    MovementRequest activeRequest,
  ) {
    _conflictedRequests++;

    // Compare priorities
    if (newRequest.priority.index > activeRequest.priority.index) {
      // New request has higher priority - queue it
      _queueRequest(newRequest);

      developer.log(
        'Queued higher priority ${newRequest.type} request for entity ${newRequest.entityId}',
        name: 'MovementRequestProcessor',
      );

      return MovementResponse.blocked(
        request: newRequest,
        currentPosition: Vector2.zero(), // Position not available here
        isGrounded: false,
        reason: 'Request queued - higher priority',
      );
    } else if (newRequest.type == MovementType.stop &&
        activeRequest.type != MovementType.stop) {
      // Stop requests always interrupt non-stop requests
      _queueRequest(newRequest);

      return MovementResponse.blocked(
        request: newRequest,
        currentPosition: Vector2.zero(), // Position not available here
        isGrounded: false,
        reason: 'Stop request queued',
      );
    } else {
      // Reject lower or equal priority requests
      developer.log(
        'Rejected ${newRequest.type} request for entity ${newRequest.entityId} - conflict with active request',
        name: 'MovementRequestProcessor',
      );

      return MovementResponse.blocked(
        request: newRequest,
        currentPosition: Vector2.zero(), // Position not available here
        isGrounded: false,
        reason: 'Conflict with active request',
      );
    }
  }

  /// Queue a request for later processing.
  void _queueRequest(MovementRequest request) {
    final queue = _requestQueues.putIfAbsent(
      request.entityId,
      () => Queue<MovementRequest>(),
    );

    // Prevent queue overflow
    if (queue.length >= maxQueueSize) {
      // Remove oldest request
      final removed = queue.removeFirst();
      developer.log(
        'Queue overflow for entity ${request.entityId} - removed ${removed.type} request',
        name: 'MovementRequestProcessor',
      );
    }

    queue.add(request);
  }

  /// Process queued requests for an entity.
  void _processQueuedRequests(int entityId) async {
    final queue = _requestQueues[entityId];
    if (queue == null || queue.isEmpty) return;

    // Get highest priority request
    MovementRequest? nextRequest;
    for (final request in queue) {
      if (nextRequest == null || request.compareTo(nextRequest) < 0) {
        nextRequest = request;
      }
    }

    if (nextRequest != null) {
      queue.remove(nextRequest);

      // Clean up empty queue
      if (queue.isEmpty) {
        _requestQueues.remove(entityId);
      }

      // Process the queued request
      developer.log(
        'Processing queued ${nextRequest.type} request for entity $entityId',
        name: 'MovementRequestProcessor',
      );

      await processRequest(nextRequest);
    }
  }

  /// Execute a validated request through the physics coordinator.
  Future<MovementResponse> _executeRequest(MovementRequest request) async {
    switch (request.type) {
      case MovementType.walk:
      case MovementType.dash:
        // Use requestMovement for directional movement
        return await _physicsCoordinator.requestMovement(
          request.entityId,
          request.normalizedDirection,
          request.magnitude,
        );

      case MovementType.jump:
        // Use requestJump for vertical movement
        return await _physicsCoordinator.requestJump(
          request.entityId,
          request.magnitude,
        );

      case MovementType.stop:
        // Use requestStop for immediate halt
        await _physicsCoordinator.requestStop(request.entityId);
        return MovementResponse.success(
          request: request,
          actualVelocity: Vector2.zero(),
          actualPosition:
              await _physicsCoordinator.getPosition(request.entityId),
          isGrounded: await _physicsCoordinator.isGrounded(request.entityId),
        );

      case MovementType.impulse:
        // Use requestImpulse for force application
        await _physicsCoordinator.requestImpulse(
          request.entityId,
          request.direction * request.magnitude,
        );
        return MovementResponse.success(
          request: request,
          actualVelocity:
              await _physicsCoordinator.getVelocity(request.entityId),
          actualPosition:
              await _physicsCoordinator.getPosition(request.entityId),
          isGrounded: await _physicsCoordinator.isGrounded(request.entityId),
        );
    }
  }

  /// Process all queued requests for all entities.
  ///
  /// Called during system update to handle any pending requests.
  void processAllQueuedRequests() {
    // Create a copy of entity IDs to avoid modification during iteration
    final entityIds = List<int>.from(_requestQueues.keys);

    for (final entityId in entityIds) {
      if (!_activeRequests.containsKey(entityId)) {
        _processQueuedRequests(entityId);
      }
    }
  }

  /// Clear all queued requests for an entity.
  ///
  /// Used when an entity is destroyed or reset.
  void clearEntityRequests(int entityId) {
    _requestQueues.remove(entityId);
    _activeRequests.remove(entityId);

    developer.log(
      'Cleared all requests for entity $entityId',
      name: 'MovementRequestProcessor',
    );
  }

  /// Get current statistics for monitoring.
  Map<String, int> get statistics => {
        'total': _totalRequests,
        'successful': _successfulRequests,
        'failed': _failedRequests,
        'conflicted': _conflictedRequests,
        'activeRequests': _activeRequests.length,
        'queuedRequests':
            _requestQueues.values.fold(0, (sum, queue) => sum + queue.length),
      };

  /// Reset statistics counters.
  void resetStatistics() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _conflictedRequests = 0;
  }

  /// Clear all requests and queues.
  ///
  /// Used for system reset or shutdown.
  void clear() {
    _requestQueues.clear();
    _activeRequests.clear();
    resetStatistics();

    developer.log(
      'Cleared all requests and queues',
      name: 'MovementRequestProcessor',
    );
  }
}

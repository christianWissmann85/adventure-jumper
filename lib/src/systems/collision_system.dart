import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:logging/logging.dart';

import '../entities/entity.dart';
import '../utils/math_utils.dart';
import 'base_flame_system.dart';
import 'interfaces/collision_notifier.dart';
import 'interfaces/physics_coordinator.dart';

/// PHY-3.4.1: CollisionSystem implementing ICollisionNotifier interface
///
/// Main collision detection and coordination system with primary focus on
/// **Physics Coordination & Event Handling**. Operates within the established
/// execution order (Priority: 70) to provide accurate collision detection,
/// grounded state management, and seamless integration with Physics and Movement
/// systems through IPhysicsCoordinator interface.
///
/// **Key Features:**
/// - High-performance collision detection optimized for 60fps
/// - Grounded state management with coyote time support
/// - Event-driven collision notification system
/// - Physics coordination without position modification
/// - Spatial partitioning for performance optimization
///
/// **System Integration:**
/// - Detects collisions without modifying positions
/// - Coordinates responses through IPhysicsCoordinator
/// - Generates events for dependent systems
/// - Maintains grounded state for movement decisions
///
/// **Execution Order:** Priority 70 (after Physics at 80, before Audio at 20)
class CollisionSystem extends BaseFlameSystem implements ICollisionNotifier {
  /// Logger for collision system events
  static final Logger _logger = Logger('CollisionSystem');

  /// Physics coordinator for collision response coordination
  IPhysicsCoordinator? _physicsCoordinator;

  /// Collision event listeners
  final List<ICollisionEventListener> _eventListeners = [];

  /// Active collisions for each entity
  final Map<int, List<CollisionInfo>> _entityCollisions = {};

  /// Grounded state information for each entity
  final Map<int, GroundInfo> _groundedStates = {};

  /// Spatial grid for performance optimization
  final Map<String, List<int>> _spatialGrid = {};

  /// Collision processing statistics
  final List<double> _processingTimes = [];
  static const int _maxProcessingTimesSamples = 60;

  /// Coyote time duration (forgiving jump mechanics)
  static const double _coyoteTimeDuration = 0.15; // 150ms

  /// Grid cell size for spatial partitioning
  static const double _gridCellSize = 64.0;

  /// Maximum collisions processed per frame
  static const int _maxCollisionsPerFrame = 50;

  /// Performance thresholds
  static const double _maxProcessingTimeMs = 2.0; // 2ms frame budget
  CollisionSystem({IPhysicsCoordinator? physicsCoordinator}) : super() {
    _physicsCoordinator = physicsCoordinator;
  }

  /// Set the physics coordinator (dependency injection)
  void setPhysicsCoordinator(IPhysicsCoordinator coordinator) {
    _physicsCoordinator = coordinator;
  }

  @override
  void initialize() {
    super.initialize();
    _entityCollisions.clear();
    _groundedStates.clear();
    _spatialGrid.clear();
    _processingTimes.clear();
    _logger.info('CollisionSystem initialized with physics coordination');
  }

  @override
  bool canProcessEntity(Entity entity) {
    // Process entities with collision components or those requiring collision detection
    return entity.physics != null;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Individual entity processing handled in processSystem
    // This method required by BaseFlameSystem but collision detection
    // is performed on entity collections for efficiency
  }

  @override
  void processSystem(double dt) {
    if (!isActive) return;

    final stopwatch = Stopwatch()..start();

    try {
      // 1. Update coyote times
      _updateCoyoteTimes(dt);

      // 2. Build spatial grid for optimization
      _buildSpatialGrid();

      // 3. Detect collisions
      final collisions = _detectCollisions();

      // 4. Process collision events
      _processCollisionEvents(collisions, dt);

      // 5. Update grounded states
      _updateGroundedStates(collisions, dt);

      // 6. Coordinate with physics system
      _coordinateWithPhysics(collisions);

      // 7. Clean up expired collisions
      _cleanupExpiredCollisions();
    } catch (error, stackTrace) {
      _logger.severe('Collision processing error: $error', error, stackTrace);
      _handleSystemError(error);
    } finally {
      stopwatch.stop();
      _recordProcessingTime(stopwatch.elapsedMicroseconds / 1000.0);
    }
  }

  // ============================================================================
  // ICollisionNotifier Implementation - Collision Query Interface
  // ============================================================================

  @override
  Future<List<CollisionInfo>> getCollisionsForEntity(int entityId) async {
    return List.from(_entityCollisions[entityId] ?? []);
  }

  @override
  Future<List<CollisionInfo>> detectCollisions(List<int> entities) async {
    final collisions = <CollisionInfo>[];

    for (int i = 0; i < entities.length; i++) {
      final entityAId = entities[i];
      final entityA = _findEntityById(entityAId);
      if (entityA == null) continue;

      for (int j = i + 1; j < entities.length; j++) {
        final entityBId = entities[j];
        final entityB = _findEntityById(entityBId);
        if (entityB == null) continue;

        final collision = await _checkEntityCollision(entityA, entityB);
        if (collision != null) {
          collisions.add(collision);
        }
      }
    }

    return collisions;
  }

  @override
  Future<bool> isGrounded(int entityId) async {
    final groundInfo = _groundedStates[entityId];
    return groundInfo?.canJump ?? false;
  }

  @override
  Future<Vector2> getGroundNormal(int entityId) async {
    final groundInfo = _groundedStates[entityId];
    return groundInfo?.groundNormal ?? Vector2(0, -1);
  }

  @override
  Future<double> getCoyoteTimeRemaining(int entityId) async {
    final groundInfo = _groundedStates[entityId];
    return groundInfo?.coyoteTimeRemaining ?? 0.0;
  }

  @override
  Future<CollisionSurface?> getGroundSurface(int entityId) async {
    final groundInfo = _groundedStates[entityId];
    return groundInfo?.groundSurface;
  }

  // ============================================================================
  // Movement Validation Interface
  // ============================================================================

  @override
  Future<bool> isMovementBlocked(int entityId, Vector2 direction) async {
    final collisions = _entityCollisions[entityId] ?? [];

    for (final collision in collisions) {
      if (!collision.isActive) continue;

      // Check if movement direction conflicts with collision normal
      final dot = direction.dot(collision.contactNormal);
      if (dot < -0.1) {
        // Moving into collision surface
        return true;
      }
    }

    return false;
  }

  @override
  Future<bool> isPositionValid(int entityId, Vector2 position) async {
    final entity = _findEntityById(entityId);
    if (entity == null) return false;

    // Check if position would cause collisions
    final predictions =
        await predictCollisions(entityId, position - entity.position);
    return predictions.isEmpty;
  }

  @override
  Future<List<CollisionInfo>> predictCollisions(
    int entityId,
    Vector2 movement,
  ) async {
    final entity = _findEntityById(entityId);
    if (entity == null) return [];

    final predictedCollisions = <CollisionInfo>[];
    final targetPosition = entity.position + movement;

    // Check against all other entities
    for (final otherEntity in entities) {
      if (otherEntity.hashCode == entityId || !otherEntity.isActive) continue;

      final collision =
          await _predictEntityCollision(entity, otherEntity, targetPosition);
      if (collision != null) {
        predictedCollisions.add(collision);
      }
    }

    return predictedCollisions;
  }

  @override
  Future<GroundInfo> getGroundInfo(int entityId) async {
    return _groundedStates[entityId] ??
        GroundInfo.airborne(entityId, DateTime.now());
  }

  // ============================================================================
  // Collision Event Management
  // ============================================================================

  @override
  void addCollisionListener(ICollisionEventListener listener) {
    if (!_eventListeners.contains(listener)) {
      _eventListeners.add(listener);
      _logger.fine('Added collision event listener: ${listener.runtimeType}');
    }
  }

  @override
  void removeCollisionListener(ICollisionEventListener listener) {
    if (_eventListeners.remove(listener)) {
      _logger.fine('Removed collision event listener: ${listener.runtimeType}');
    }
  }

  @override
  void notifyInputValidation(int entityId, String inputAction) {
    // Coordinate input validation with collision state
    _logger
        .finest('Input validation for entity $entityId, action: $inputAction');
  }

  // ============================================================================
  // Physics Coordination
  // ============================================================================
  @override
  Future<void> onGroundStateChanged(
    int entityId,
    bool isGrounded,
    Vector2 groundNormal,
  ) async {
    final currentState = _groundedStates[entityId];

    // Create new ground state
    final newGroundInfo = isGrounded
        ? GroundInfo.grounded(
            entityId: entityId,
            groundNormal: groundNormal,
            surface: CollisionSurface.solid(),
          )
        : GroundInfo.airborne(
            entityId,
            currentState?.lastGroundedTime ?? DateTime.now(),
          );

    _groundedStates[entityId] = newGroundInfo;

    // Coordinate with physics system for ground state changes
    if (_physicsCoordinator != null) {
      try {
        // Notify physics coordinator of ground state change for proper coordination
        final entity = _findEntityById(entityId);
        if (entity?.physics != null) {
          entity!.physics!.setOnGround(isGrounded);
        }
      } catch (error) {
        _logger
            .warning('Failed to coordinate ground state with physics: $error');
      }
    }

    // Notify event listeners
    for (final listener in _eventListeners) {
      try {
        listener.onGroundStateChanged(entityId, isGrounded, groundNormal);
      } catch (error) {
        _logger.warning('Error notifying ground state change: $error');
      }
    }

    _logger.fine(
      'Ground state updated for entity $entityId: grounded=$isGrounded',
    );
  }

  @override
  Future<void> validateCollisionResponse(
    int entityId,
    CollisionInfo collision,
  ) async {
    // Validate collision response calculations
    if (!collision.isValid) {
      _logger.warning(
        'Invalid collision detected for entity $entityId: $collision',
      );
      return;
    }

    // Check response vector validity
    if (!MathUtils.isVector2Finite(collision.separationVector)) {
      _logger.warning('Invalid separation vector for entity $entityId');
      return;
    }

    // Check magnitude bounds
    if (collision.separationVector.length > 100.0) {
      _logger.warning(
        'Excessive separation vector magnitude for entity $entityId: ${collision.separationVector.length}',
      );
    }

    // Coordinate with physics system for collision response validation
    if (_physicsCoordinator != null) {
      try {
        // Validate that the collision response is consistent with physics state
        final currentPosition =
            await _physicsCoordinator!.getPosition(entityId);
        final currentVelocity = await _physicsCoordinator!.getVelocity(
          entityId,
        );

        // Ensure collision response won't cause physics state inconsistencies
        if (collision.collisionType == CollisionType.ground &&
            currentVelocity.y > 0) {
          _logger.warning(
            'Ground collision detected while moving upward for entity $entityId',
          );
        }

        // Validate position is finite and reasonable
        if (!MathUtils.isVector2Finite(currentPosition)) {
          _logger.warning(
            'Invalid physics position detected for entity $entityId: $currentPosition',
          );
        }
      } catch (error) {
        _logger.warning(
          'Failed to validate collision response with physics: $error',
        );
      }
    }

    _logger.finest('Collision response validated for entity $entityId');
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  @override
  void onCollisionProcessingError(int entityId, CollisionError error) {
    _logger.severe('Collision processing error for entity $entityId: $error');

    // Apply error recovery based on error type
    switch (error.type) {
      case CollisionErrorType.invalidPosition:
        _handleInvalidPositionError(entityId);
        break;
      case CollisionErrorType.processingTimeout:
        _handleProcessingTimeoutError(entityId);
        break;
      case CollisionErrorType.inconsistentState:
        _handleInconsistentStateError(entityId);
        break;
      case CollisionErrorType.memoryExhaustion:
        _handleMemoryExhaustionError();
        break;
      case CollisionErrorType.algorithmFailure:
        _handleAlgorithmFailureError(entityId);
        break;
    }
  }

  // ============================================================================
  // Private Implementation Methods
  // ============================================================================

  /// Update coyote times for all grounded states
  void _updateCoyoteTimes(double dt) {
    final toUpdate = <int, GroundInfo>{};

    for (final entry in _groundedStates.entries) {
      final entityId = entry.key;
      final currentInfo = entry.value;

      if (!currentInfo.isGrounded && currentInfo.coyoteTimeRemaining > 0) {
        final newCoyoteTime =
            math.max(0.0, currentInfo.coyoteTimeRemaining - dt);
        toUpdate[entityId] = GroundInfo(
          entityId: entityId,
          isGrounded: false,
          groundNormal: currentInfo.groundNormal,
          lastGroundedTime: currentInfo.lastGroundedTime,
          coyoteTimeRemaining: newCoyoteTime,
          groundSurface: currentInfo.groundSurface,
          wasGroundedLastFrame: currentInfo.wasGroundedLastFrame,
          isStableGround: currentInfo.isStableGround,
          groundVelocity: currentInfo.groundVelocity,
        );
      }
    }

    toUpdate.forEach((entityId, groundInfo) {
      _groundedStates[entityId] = groundInfo;
    });
  }

  /// Build spatial grid for collision optimization
  void _buildSpatialGrid() {
    _spatialGrid.clear();

    for (final entity in entities) {
      if (!entity.isActive) continue;

      final gridKey = _getGridKey(entity.position);
      _spatialGrid.putIfAbsent(gridKey, () => <int>[]).add(entity.hashCode);
    }
  }

  /// Get spatial grid key for position
  String _getGridKey(Vector2 position) {
    final gridX = (position.x / _gridCellSize).floor();
    final gridY = (position.y / _gridCellSize).floor();
    return '${gridX}_$gridY';
  }

  /// Detect all collisions in current frame
  List<CollisionInfo> _detectCollisions() {
    final collisions = <CollisionInfo>[];
    final processed = <String>{};

    for (final cellEntities in _spatialGrid.values) {
      for (int i = 0; i < cellEntities.length; i++) {
        final entityAId = cellEntities[i];
        final entityA = _findEntityById(entityAId);
        if (entityA == null) continue;

        for (int j = i + 1; j < cellEntities.length; j++) {
          final entityBId = cellEntities[j];
          final entityB = _findEntityById(entityBId);
          if (entityB == null) continue;

          // Avoid duplicate processing
          final pairKey =
              '${math.min(entityAId, entityBId)}_${math.max(entityAId, entityBId)}';
          if (processed.contains(pairKey)) continue;
          processed.add(pairKey);

          final collision = _checkCollisionSync(entityA, entityB);
          if (collision != null) {
            collisions.add(collision);

            // Limit collisions per frame for performance
            if (collisions.length >= _maxCollisionsPerFrame) {
              _logger.warning(
                'Max collisions per frame reached: $_maxCollisionsPerFrame',
              );
              return collisions;
            }
          }
        }
      }
    }

    return collisions;
  }

  /// Check collision between two entities (synchronous)
  CollisionInfo? _checkCollisionSync(Entity entityA, Entity entityB) {
    // Basic AABB collision detection
    final aLeft = entityA.position.x;
    final aRight = entityA.position.x + entityA.size.x;
    final aTop = entityA.position.y;
    final aBottom = entityA.position.y + entityA.size.y;

    final bLeft = entityB.position.x;
    final bRight = entityB.position.x + entityB.size.x;
    final bTop = entityB.position.y;
    final bBottom = entityB.position.y + entityB.size.y;

    // Check for overlap
    if (aRight <= bLeft ||
        bRight <= aLeft ||
        aBottom <= bTop ||
        bBottom <= aTop) {
      return null; // No collision
    }

    // Calculate collision details
    final overlapX = math.min(aRight - bLeft, bRight - aLeft);
    final overlapY = math.min(aBottom - bTop, bBottom - aTop);

    final Vector2 normal;
    final double penetrationDepth;
    final Vector2 separationVector;

    if (overlapX < overlapY) {
      // Horizontal collision
      final signX = (entityA.position.x + entityA.size.x / 2) >
              (entityB.position.x + entityB.size.x / 2)
          ? 1.0
          : -1.0;
      normal = Vector2(signX, 0);
      penetrationDepth = overlapX;
      separationVector = Vector2(overlapX * signX, 0);
    } else {
      // Vertical collision
      final signY = (entityA.position.y + entityA.size.y / 2) >
              (entityB.position.y + entityB.size.y / 2)
          ? 1.0
          : -1.0;
      normal = Vector2(0, signY);
      penetrationDepth = overlapY;
      separationVector = Vector2(0, overlapY * signY);
    }

    final contactPoint = Vector2(
      (math.max(aLeft, bLeft) + math.min(aRight, bRight)) / 2,
      (math.max(aTop, bTop) + math.min(aBottom, bBottom)) / 2,
    );

    final collisionType = _determineCollisionType(normal);

    return CollisionInfo(
      entityA: entityA.hashCode,
      entityB: entityB.hashCode,
      contactPoint: contactPoint,
      contactNormal: normal,
      penetrationDepth: penetrationDepth,
      separationVector: separationVector,
      collisionType: collisionType,
      surface: CollisionSurface.solid(),
      timestamp: DateTime.now(),
      isActive: true,
      impactVelocity: Vector2.zero(),
    );
  }

  /// Check collision between two entities (asynchronous)
  Future<CollisionInfo?> _checkEntityCollision(
    Entity entityA,
    Entity entityB,
  ) async {
    return _checkCollisionSync(entityA, entityB);
  }

  /// Predict collision for entity movement
  Future<CollisionInfo?> _predictEntityCollision(
    Entity entity,
    Entity other,
    Vector2 targetPosition,
  ) async {
    // Create temporary entity at target position for collision check
    final originalPosition = entity.position.clone();
    entity.position = targetPosition;

    final collision = _checkCollisionSync(entity, other);

    // Restore original position
    entity.position = originalPosition;

    return collision;
  }

  /// Determine collision type from normal vector
  CollisionType _determineCollisionType(Vector2 normal) {
    if (normal.y < -0.7) {
      return CollisionType.ground;
    } else if (normal.y > 0.7) {
      return CollisionType.ceiling;
    } else if (normal.x.abs() > 0.7) {
      return CollisionType.wall;
    } else {
      return CollisionType.entity;
    }
  }

  /// Process collision events and notifications
  void _processCollisionEvents(List<CollisionInfo> collisions, double dt) {
    // Update entity collision maps
    _entityCollisions.clear();

    for (final collision in collisions) {
      _entityCollisions
          .putIfAbsent(collision.entityA, () => <CollisionInfo>[])
          .add(collision);
      _entityCollisions
          .putIfAbsent(collision.entityB, () => <CollisionInfo>[])
          .add(collision);

      // Notify event listeners
      for (final listener in _eventListeners) {
        try {
          listener.onCollisionStart(collision);
        } catch (error) {
          _logger.warning('Error notifying collision start: $error');
        }
      }
    }
  }

  /// Update grounded states based on collision results  // ============================================================================
  // PHY-3.4.2: Enhanced Grounded State Management Helper Methods
  // ============================================================================
  /// Determine surface type from collision information
  CollisionSurface _determineSurfaceType(CollisionInfo collision) {
    // Extract material information from collision
    if (collision.collisionType == CollisionType.platform) {
      return CollisionSurface.solid(); // Platform surfaces are solid
    } else {
      // Check for special surface types based on collision context
      // This could be enhanced with entity metadata
      return CollisionSurface.solid();
    }
  }

  /// Check if ground surface is stable (not moving platform)
  bool _isStableGround(CollisionInfo collision) {
    // For now, assume all ground is stable
    // This could be enhanced to check for moving platforms
    return collision.collisionType != CollisionType.platform;
  }

  /// Calculate ground velocity for moving platforms
  Vector2 _calculateGroundVelocity(CollisionInfo collision) {
    // For now, return zero velocity
    // This could be enhanced to get velocity from moving platforms
    return Vector2.zero();
  }

  /// Coordinate ground state changes with physics system
  Future<void> _coordinateGroundStateChange(
    int entityId,
    GroundInfo groundInfo,
  ) async {
    if (_physicsCoordinator == null) return;

    try {
      // Check physics state consistency when ground state changes
      final isValid =
          await _physicsCoordinator!.validateStateConsistency(entityId);
      if (!isValid) {
        _logger.warning(
          'Physics state inconsistency detected for entity $entityId during ground state change',
        );
      }

      _logger.fine(
        'Coordinated ground state change with physics: '
        'entity=$entityId, grounded=${groundInfo.isGrounded}',
      );
    } catch (error) {
      _logger.warning(
        'Failed to coordinate ground state change with physics: $error',
      );
    }
  }

  /// PHY-3.4.2: Enhanced grounded state management with coyote time per TDD specifications
  void _updateGroundedStates(List<CollisionInfo> collisions, double dt) {
    final groundedEntities = <int, CollisionInfo>{};

    // 1. Identify ground collisions with normal validation
    for (final collision in collisions) {
      if (collision.isGroundCollision) {
        // Validate ground normal (should point upward)
        if (collision.contactNormal.y < -0.7) {
          groundedEntities[collision.entityA] = collision;
        }
      }
    }

    // 2. Update all existing grounded states with coyote time countdown
    for (final entry in _groundedStates.entries.toList()) {
      final entityId = entry.key;
      final currentInfo = entry.value;
      final groundCollision = groundedEntities[entityId];
      final isNowGrounded = groundCollision != null;

      // Calculate new coyote time
      final newCoyoteTime = isNowGrounded
          ? _coyoteTimeDuration
          : math.max(0, currentInfo.coyoteTimeRemaining - dt);

      // Get ground normal from collision or maintain previous
      final groundNormal = groundCollision?.contactNormal ??
          currentInfo.groundNormal; // Create updated ground info
      final newGroundInfo = GroundInfo(
        entityId: entityId,
        isGrounded: isNowGrounded,
        groundNormal: groundNormal,
        lastGroundedTime:
            isNowGrounded ? DateTime.now() : currentInfo.lastGroundedTime,
        coyoteTimeRemaining: newCoyoteTime.toDouble(),
        groundSurface: isNowGrounded
            ? _determineSurfaceType(groundCollision)
            : currentInfo.groundSurface,
        wasGroundedLastFrame: currentInfo.isGrounded,
        isStableGround: isNowGrounded && _isStableGround(groundCollision),
        groundVelocity: isNowGrounded
            ? _calculateGroundVelocity(groundCollision)
            : Vector2.zero(),
      );

      _groundedStates[entityId] = newGroundInfo;

      // 3. Coordinate with physics system for accurate ground detection
      if (newGroundInfo.groundedStateChanged) {
        _coordinateGroundStateChange(entityId, newGroundInfo);
      }

      // 4. Notify event listeners of state changes
      if (newGroundInfo.groundedStateChanged) {
        onGroundStateChanged(
          entityId,
          isNowGrounded,
          groundNormal,
        );

        _logger.fine(
          'Ground state changed for entity $entityId: '
          '${isNowGrounded ? "grounded" : "airborne"} '
          '(coyote: ${newCoyoteTime.toStringAsFixed(3)}s)',
        );
      }
    }

    // 5. Add new entities that became grounded
    for (final entry in groundedEntities.entries) {
      final entityId = entry.key;
      final collision = entry.value;

      if (!_groundedStates.containsKey(entityId)) {
        final newGroundInfo = GroundInfo.grounded(
          entityId: entityId,
          groundNormal: collision.contactNormal,
          surface: _determineSurfaceType(collision),
          isStable: _isStableGround(collision),
          groundVelocity: _calculateGroundVelocity(collision),
        );

        _groundedStates[entityId] = newGroundInfo;
        _coordinateGroundStateChange(entityId, newGroundInfo);
        onGroundStateChanged(entityId, true, collision.contactNormal);

        _logger.fine('New grounded entity detected: $entityId');
      }
    }

    // 6. Remove entities with expired coyote time
    _groundedStates.removeWhere((entityId, groundInfo) {
      final shouldRemove =
          !groundInfo.isGrounded && groundInfo.coyoteTimeRemaining <= 0;
      if (shouldRemove) {
        _logger.fine('Removing expired ground state for entity $entityId');
      }
      return shouldRemove;
    });
  }

  /// Coordinate collision responses with physics system
  void _coordinateWithPhysics(List<CollisionInfo> collisions) {
    // This system doesn't modify positions - it coordinates responses through IPhysicsCoordinator
    // The physics system will handle actual collision resolution
    for (final collision in collisions) {
      // Validate each collision response with physics coordinator
      validateCollisionResponse(collision.entityA, collision);
    }
  }

  /// Clean up expired and inactive collisions
  void _cleanupExpiredCollisions() {
    final currentTime = DateTime.now();
    const maxAge = Duration(seconds: 1);

    for (final entityCollisions in _entityCollisions.values) {
      entityCollisions.removeWhere(
        (collision) =>
            !collision.isActive ||
            currentTime.difference(collision.timestamp) > maxAge,
      );
    }

    // Remove empty collision lists
    _entityCollisions.removeWhere((_, collisions) => collisions.isEmpty);
  }

  /// Find entity by ID
  Entity? _findEntityById(int entityId) {
    try {
      return entities.firstWhere((entity) => entity.hashCode == entityId);
    } catch (e) {
      return null;
    }
  }

  /// Record processing time for performance monitoring
  void _recordProcessingTime(double timeMs) {
    _processingTimes.add(timeMs);

    // Keep only recent samples
    while (_processingTimes.length > _maxProcessingTimesSamples) {
      _processingTimes.removeAt(0);
    }

    // Check performance threshold
    if (timeMs > _maxProcessingTimeMs) {
      _logger.warning(
        'Collision processing exceeded budget: ${timeMs.toStringAsFixed(2)}ms',
      );
    }
  }

  /// Get average processing time
  double get averageProcessingTime {
    if (_processingTimes.isEmpty) return 0.0;
    return _processingTimes.reduce((a, b) => a + b) / _processingTimes.length;
  }

  /// Check if collision system performance is optimal
  bool get isPerformanceOptimal {
    return averageProcessingTime <= _maxProcessingTimeMs;
  }

  /// Handle system-level errors
  void _handleSystemError(dynamic error) {
    _logger.severe('CollisionSystem encountered critical error: $error');

    // Attempt to maintain system stability
    try {
      _entityCollisions.clear();
      _spatialGrid.clear();
    } catch (e) {
      _logger.severe('Failed to clear collision system state: $e');
    }
  }

  // Error handling methods
  void _handleInvalidPositionError(int entityId) {
    _logger.warning('Handling invalid position error for entity $entityId');
    // Remove invalid collision data
    _entityCollisions.remove(entityId);
  }

  void _handleProcessingTimeoutError(int entityId) {
    _logger.warning('Handling processing timeout error for entity $entityId');
    // Skip collision processing for this entity this frame
  }

  void _handleInconsistentStateError(int entityId) {
    _logger.warning('Handling inconsistent state error for entity $entityId');
    // Reset collision state for entity
    _entityCollisions.remove(entityId);
    _groundedStates.remove(entityId);
  }

  void _handleMemoryExhaustionError() {
    _logger.warning('Handling memory exhaustion error');
    // Clear collision history to free memory
    _entityCollisions.clear();
    _processingTimes.clear();
  }

  void _handleAlgorithmFailureError(int entityId) {
    _logger.warning('Handling algorithm failure error for entity $entityId');
    // Use fallback collision detection
    _entityCollisions.remove(entityId);
  }

  @override
  void dispose() {
    _eventListeners.clear();
    _entityCollisions.clear();
    _groundedStates.clear();
    _spatialGrid.clear();
    _processingTimes.clear();

    _logger.info('CollisionSystem disposed');
    super.dispose();
  }
}

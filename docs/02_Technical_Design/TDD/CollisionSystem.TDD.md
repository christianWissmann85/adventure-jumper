# Collision System - Technical Design Document

## 1. Overview

Defines the collision detection and response system with primary focus on **Physics Coordination & Event Handling**. This system operates within the established execution order (Priority: 70) to provide accurate collision detection, grounded state management, and seamless integration with the Physics and Movement systems through the IPhysicsCoordinator interface.

> **Related Documents:**
>
> - [PhysicsSystem TDD](PhysicsSystem.TDD.md) - Physics system specification and coordination
> - [MovementSystem TDD](MovementSystem.TDD.md) - Movement system integration patterns
> - [SystemIntegration TDD](SystemIntegration.TDD.md) - Physics-movement coordination protocols
> - [SystemArchitecture TDD](SystemArchitecture.TDD.md) - System execution order and priorities
> - [PlayerCharacter TDD](PlayerCharacter.TDD.md) - Character collision integration
> - [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) - Refactor strategy
> - [Critical Report: Physics Movement System Degradation](../../07_Reports/Critical_Report_Physics_Movement_System_Degradation.md) - Root cause analysis

### Purpose

- **Primary**: Provide accurate collision detection integrated with physics coordinate system
- Detect and respond to collisions without interfering with PhysicsSystem position ownership
- Manage grounded state for movement system decision making
- Generate collision events for dependent systems (audio, animation, combat)
- Integrate collision response with physics state updates through ICollisionNotifier
- Support collision-based movement blocking while respecting system boundaries

### Scope

- Collision detection algorithms optimized for 60fps performance
- Grounded state management with coyote time support
- Event-based collision notification system
- Integration with physics coordinate system without position modification
- Wall sliding, platform detection, and environmental interaction
- Performance-optimized spatial partitioning for large levels

### System Integration Focus

This TDD specifically supports the **Physics-Movement System Refactor** through:

- **Clear System Boundaries**: Collision detection only, no position modifications
- **Physics Coordination**: All collision responses coordinated through IPhysicsCoordinator
- **Event-Driven Architecture**: Collision notifications without direct system coupling
- **State Synchronization**: Grounded state synchronized with physics simulation
- **Performance Integration**: Collision processing within 16.67ms frame budget

## 2. Class Design

### Core Collision Classes

```dart
// Main collision system component - integrates with physics coordination
class CollisionSystem extends BaseFlameSystem implements ICollisionNotifier {
  late final IPhysicsCoordinator _physicsCoordinator;
  late final CollisionDetector _detector;
  late final GroundedStateManager _groundedManager;
  late final CollisionEventBus _eventBus;

  // System execution (Priority: 70 - after physics processing)
  @override
  void update(double dt) {
    // Collision detection pipeline
    // Event generation and notification
    // Grounded state updates
  }
}

// Spatial partitioning for performance optimization
class CollisionDetector {
  late final SpatialGrid _spatialGrid;
  late final CollisionAlgorithms _algorithms;

  // High-performance collision detection
  List<CollisionInfo> detectCollisions(List<Entity> entities);
  bool checkSpecificCollision(Entity a, Entity b);
  List<CollisionInfo> getCollisionsForEntity(int entityId);
}

// Grounded state management with physics coordination
class GroundedStateManager {
  late final IPhysicsCoordinator _physicsCoordinator;
  final Map<int, GroundedState> _groundedStates = {};

  // Grounded state coordination with physics
  Future<void> updateGroundedState(int entityId, List<CollisionInfo> collisions);
  bool isGrounded(int entityId);
  double getGroundNormal(int entityId);
}

// Event bus for collision notifications
class CollisionEventBus {
  final List<ICollisionEventListener> _listeners = [];

  // Event propagation to dependent systems
  void notifyCollisionStart(CollisionInfo collision);
  void notifyCollisionEnd(CollisionInfo collision);
  void notifyGroundStateChanged(int entityId, bool isGrounded);
}
```

### Key Responsibilities

- **CollisionSystem**: Main coordination and system integration
- **CollisionDetector**: Optimized collision detection algorithms
- **GroundedStateManager**: Grounded state with physics synchronization
- **CollisionEventBus**: Event-driven notifications to dependent systems

## 3. Data Structures

### Collision Information

```dart
// Comprehensive collision data for physics coordination
class CollisionInfo {
  final int entityA;
  final int entityB;
  final Vector2 contactPoint;
  final Vector2 contactNormal;
  final double penetrationDepth;
  final CollisionType type;
  final double timestamp;
  final CollisionSurface surface;

  CollisionInfo({
    required this.entityA,
    required this.entityB,
    required this.contactPoint,
    required this.contactNormal,
    required this.penetrationDepth,
    required this.type,
    required this.surface,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
}

// Collision type classification for physics response
enum CollisionType {
  ground,          // Floor/platform collision
  wall,            // Vertical surface collision
  ceiling,         // Overhead collision
  platform,        // One-way platform
  hazard,          // Damage-dealing collision
  trigger,         // Event trigger collision
  interactive,     // Interaction prompt collision
}

// Surface properties affecting physics response
class CollisionSurface {
  final double friction;        // Surface friction coefficient
  final double bounce;          // Restitution coefficient
  final bool isOneWay;         // Platform passthrough
  final bool isSlippery;       // Ice/low friction surface
  final bool isSticky;         // Wall-sliding surface
  final SurfaceAudio audioType; // Audio cue classification

  const CollisionSurface({
    this.friction = 1.0,
    this.bounce = 0.0,
    this.isOneWay = false,
    this.isSlippery = false,
    this.isSticky = false,
    this.audioType = SurfaceAudio.stone,
  });
}
```

### Grounded State Management

```dart
// Grounded state with coyote time and physics coordination
class GroundedState {
  final int entityId;
  final bool isGrounded;
  final Vector2 groundNormal;
  final double lastGroundedTime;
  final double coyoteTimeRemaining;
  final CollisionSurface groundSurface;
  final bool wasGroundedLastFrame;

  GroundedState({
    required this.entityId,
    required this.isGrounded,
    required this.groundNormal,
    required this.lastGroundedTime,
    required this.coyoteTimeRemaining,
    required this.groundSurface,
    required this.wasGroundedLastFrame,
  });

  // Coyote time calculation for forgiving jump mechanics
  bool get canJump => isGrounded || coyoteTimeRemaining > 0;

  // State change detection for event generation
  bool get groundedStateChanged => isGrounded != wasGroundedLastFrame;
}

// Collision event data for system notifications
class CollisionEvent {
  final CollisionEventType type;
  final int entityId;
  final CollisionInfo? collisionInfo;
  final GroundedState? groundedState;
  final double timestamp;

  CollisionEvent({
    required this.type,
    required this.entityId,
    this.collisionInfo,
    this.groundedState,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
}

enum CollisionEventType {
  collisionStart,     // New collision detected
  collisionEnd,       // Collision resolved
  groundedChanged,    // Grounded state changed
  surfaceChanged,     // Ground surface type changed
  wallSlideStart,     // Wall sliding initiated
  wallSlideEnd,       // Wall sliding ended
}
```

## 4. Algorithms

### Collision Detection Pipeline

```dart
// Optimized collision detection with spatial partitioning
class CollisionDetectionAlgorithm {

  // Frame-based collision detection (Priority: 70)
  List<CollisionInfo> detectCollisions(List<Entity> entities, double dt) {
    // 1. Spatial partitioning update (O(n) complexity)
    _spatialGrid.updateGrid(entities);

    // 2. Broad-phase collision detection
    final candidatePairs = _spatialGrid.getBroadPhasePairs();

    // 3. Narrow-phase collision detection
    final collisions = <CollisionInfo>[];
    for (final pair in candidatePairs) {
      final collision = _narrowPhaseDetection(pair.entityA, pair.entityB);
      if (collision != null) {
        collisions.add(collision);
      }
    }

    // 4. Collision filtering and validation
    return _filterValidCollisions(collisions);
  }

  // High-precision narrow-phase detection
  CollisionInfo? _narrowPhaseDetection(Entity entityA, Entity entityB) {
    // AABB vs AABB collision detection
    // Separating Axis Theorem for complex shapes
    // Contact point and normal calculation
    // Penetration depth measurement
  }
}
```

### Grounded State Algorithm

```dart
// Grounded state with coyote time and physics coordination
class GroundedStateAlgorithm {

  Future<void> updateGroundedState(int entityId, List<CollisionInfo> collisions) {
    final currentState = _groundedStates[entityId] ?? _createDefaultState(entityId);

    // 1. Check for ground collisions
    final groundCollisions = collisions.where((c) =>
      c.type == CollisionType.ground &&
      c.contactNormal.y < -0.7 // Normal pointing upward
    ).toList();

    // 2. Calculate new grounded state
    final newIsGrounded = groundCollisions.isNotEmpty;
    final groundNormal = newIsGrounded
      ? groundCollisions.first.contactNormal
      : Vector2(0, -1);

    // 3. Update coyote time
    final coyoteTime = newIsGrounded
      ? COYOTE_TIME_DURATION
      : math.max(0, currentState.coyoteTimeRemaining - dt);

    // 4. Create updated state
    final newState = GroundedState(
      entityId: entityId,
      isGrounded: newIsGrounded,
      groundNormal: groundNormal,
      lastGroundedTime: newIsGrounded ? DateTime.now().millisecondsSinceEpoch.toDouble() : currentState.lastGroundedTime,
      coyoteTimeRemaining: coyoteTime,
      groundSurface: newIsGrounded ? groundCollisions.first.surface : currentState.groundSurface,
      wasGroundedLastFrame: currentState.isGrounded,
    );

    // 5. Update state and notify changes
    _groundedStates[entityId] = newState;

    // 6. Coordinate with physics system
    if (newState.groundedStateChanged) {
      await _physicsCoordinator.onGroundStateChanged(entityId, newState.isGrounded, groundNormal);
      _eventBus.notifyGroundStateChanged(entityId, newState.isGrounded);
    }
  }
}
```

## 5. API/Interfaces

### Collision Notification Interface

```dart
// Primary interface for collision system coordination
abstract class ICollisionNotifier {
  // Collision detection results
  Future<List<CollisionInfo>> getCollisionsForEntity(int entityId);
  Future<List<CollisionInfo>> detectCollisions(List<Entity> entities);

  // Grounded state management
  Future<bool> isGrounded(int entityId);
  Future<Vector2> getGroundNormal(int entityId);
  Future<double> getCoyoteTimeRemaining(int entityId);
  Future<CollisionSurface> getGroundSurface(int entityId);

  // Physics coordination methods
  Future<void> onGroundStateChanged(int entityId, bool isGrounded, Vector2 groundNormal);
  Future<void> validateCollisionResponse(int entityId, CollisionInfo collision);

  // Event management
  void addCollisionListener(ICollisionEventListener listener);
  void removeCollisionListener(ICollisionEventListener listener);

  // Error handling
  void onCollisionProcessingError(int entityId, CollisionError error);
}

// Event listener interface for dependent systems
abstract class ICollisionEventListener {
  void onCollisionStart(CollisionInfo collision);
  void onCollisionEnd(CollisionInfo collision);
  void onGroundStateChanged(int entityId, bool isGrounded, Vector2 groundNormal);
  void onSurfaceChanged(int entityId, CollisionSurface surface);
}

// Physics coordination interface for collision responses
abstract class ICollisionPhysicsCoordinator {
  // Collision response requests to physics system
  Future<void> requestCollisionResponse(int entityId, CollisionInfo collision);
  Future<void> requestPositionCorrection(int entityId, Vector2 correctionVector);
  Future<void> requestVelocityModification(int entityId, Vector2 velocityChange);

  // Physics state queries for collision validation
  Future<Vector2> getEntityPosition(int entityId);
  Future<Vector2> getEntityVelocity(int entityId);
  Future<AABB> getEntityBounds(int entityId);

  // Error handling and recovery
  void onCollisionResponseFailed(int entityId, CollisionInfo collision, String reason);
}
```

### Collision Query Interface

```dart
// Interface for systems querying collision information
abstract class ICollisionQuery {
  // Real-time collision queries
  Future<bool> isEntityGrounded(int entityId);
  Future<List<CollisionInfo>> getActiveCollisions(int entityId);
  Future<CollisionInfo?> raycast(Vector2 origin, Vector2 direction, double maxDistance);
  Future<List<Entity>> getEntitiesInArea(AABB area);

  // Collision prediction
  Future<List<CollisionInfo>> predictCollisions(int entityId, Vector2 velocity, double dt);
  Future<bool> wouldCollide(int entityId, Vector2 targetPosition);

  // Surface information
  Future<CollisionSurface> getSurfaceAt(Vector2 position);
  Future<Vector2> getSurfaceNormal(Vector2 position);
}
```

## 6. Dependencies

### System Dependencies

- **Physics System**: For collision response coordination via IPhysicsCoordinator
- **Movement System**: For grounded state queries and movement validation
- **Render System**: For entity bounds and position information
- **Audio System**: For collision sound event notifications
- **Animation System**: For collision-triggered animation events

### Physics-Movement Integration Dependencies

- **IPhysicsCoordinator**: Primary interface for collision response coordination
- **ICollisionNotifier**: Interface for providing collision information to other systems
- **Event Coordination**: Collision events synchronized with physics state updates
- **State Synchronization**: Grounded state synchronized with physics simulation
- **Error Recovery**: Collision processing failures coordinated with physics error handling

### Component Dependencies

- Entity bounds components for collision shape information
- Transform components for position and rotation data
- Level geometry components for static collision surfaces
- SystemIntegration.TDD.md patterns for cross-system communication

## 7. File Structure

```
lib/
  src/
    systems/
      collision/
        collision_system.dart              # Main collision system
        collision_detector.dart            # Spatial partitioning and detection
        grounded_state_manager.dart        # Grounded state with physics coordination
        collision_event_bus.dart           # Event notification system
        spatial_grid.dart                  # Performance optimization
      interfaces/
        collision_notifier.dart            # ICollisionNotifier interface
        collision_query.dart               # ICollisionQuery interface
        collision_physics_coordinator.dart # ICollisionPhysicsCoordinator interface
      collision_processing/
        collision_algorithms.dart          # Detection algorithms
        collision_response.dart            # Response coordination
        surface_properties.dart            # Surface material definitions
    events/
      collision_events.dart               # Collision event data structures
    data/
      collision_info.dart                 # CollisionInfo and related structures
      grounded_state.dart                 # GroundedState data structures
```

## 8. Performance Considerations

### Optimization Strategies

- **Spatial Partitioning**: Grid-based spatial partitioning for O(n) broad-phase detection
- **Frame Budget Management**: Collision processing within 2ms of 16.67ms frame budget
- **Event Batching**: Collision events batched and processed at frame boundaries
- **Memory Pooling**: CollisionInfo objects reused to reduce garbage collection
- **Early Exit Optimization**: Quick rejection tests before expensive narrow-phase detection

### Memory Management

- **Object Pooling**: Reuse CollisionInfo and GroundedState objects
- **Spatial Grid Optimization**: Efficient cell allocation and deallocation
- **Event Queue Management**: Bounded event queues with overflow handling
- **State Caching**: Ground state caching to reduce repeated calculations

## 9. Testing Strategy

### Unit Tests

- Collision detection accuracy across various entity shapes and sizes
- Grounded state calculation with coyote time edge cases
- Event notification timing and order validation
- Spatial partitioning performance and correctness
- Physics coordination interface compliance

### Integration Tests

- CollisionSystem integration with PhysicsSystem via IPhysicsCoordinator
- Grounded state synchronization with physics simulation
- Event propagation to AudioSystem and AnimationSystem
- Performance testing: collision processing within frame budget
- Error handling coordination with physics error recovery

### Physics-Movement Integration Tests

- Collision response coordination preventing position conflicts
- Grounded state changes synchronized with physics state
- Event timing validation ensuring proper system execution order
- Error recovery testing for collision processing failures

## 10. Implementation Notes

### Physics-Movement Coordination Patterns

**Collision Response Coordination:**

```dart
// Example: Collision response coordinated through physics system
class CollisionResponseHandler {
  final IPhysicsCoordinator _physics;

  Future<void> handleCollision(CollisionInfo collision) async {
    // 1. Validate collision with physics state
    final currentPos = await _physics.getEntityPosition(collision.entityA);

    // 2. Calculate response vector
    final responseVector = _calculateCollisionResponse(collision);

    // 3. Request physics to apply response (no direct position modification)
    await _physics.requestPositionCorrection(collision.entityA, responseVector);

    // 4. Update grounded state if ground collision
    if (collision.type == CollisionType.ground) {
      await _updateGroundedState(collision.entityA, collision);
    }

    // 5. Notify dependent systems
    _eventBus.notifyCollisionStart(collision);
  }
}
```

**Grounded State Coordination:**

```dart
// Example: Grounded state management with physics synchronization
class GroundedStateCoordinator {
  final IPhysicsCoordinator _physics;

  Future<void> updateGroundedState(int entityId, List<CollisionInfo> collisions) async {
    final wasGrounded = _groundedStates[entityId]?.isGrounded ?? false;

    // 1. Calculate new grounded state
    final groundCollision = _findGroundCollision(collisions);
    final isGrounded = groundCollision != null;

    // 2. Update internal state
    _groundedStates[entityId] = GroundedState(
      entityId: entityId,
      isGrounded: isGrounded,
      groundNormal: groundCollision?.contactNormal ?? Vector2(0, -1),
      // ... other properties
    );

    // 3. Coordinate with physics system
    if (wasGrounded != isGrounded) {
      await _physics.onGroundStateChanged(
        entityId,
        isGrounded,
        groundCollision?.contactNormal ?? Vector2(0, -1)
      );
    }

    // 4. Notify movement system
    _eventBus.notifyGroundStateChanged(entityId, isGrounded);
  }
}
```

**Error Handling and Recovery:**

```dart
// Example: Collision processing error handling
class CollisionErrorHandler {
  final IPhysicsCoordinator _physics;

  void handleCollisionError(int entityId, CollisionError error) {
    switch (error.type) {
      case CollisionErrorType.invalidPosition:
        // Request physics to validate and correct position
        _physics.validateEntityPosition(entityId);
        break;

      case CollisionErrorType.processingTimeout:
        // Skip collision processing for this frame
        _logCollisionTimeout(entityId, error);
        break;

      case CollisionErrorType.inconsistentState:
        // Request full state reset through physics coordinator
        _physics.resetEntityState(entityId);
        break;
    }
  }
}
```

**Performance Optimization with System Boundaries:**

```dart
// Example: Optimized collision detection respecting system boundaries
class OptimizedCollisionDetection {
  final IPhysicsCoordinator _physics;

  List<CollisionInfo> detectCollisions(List<Entity> entities, double dt) {
    // 1. Get physics-validated entity positions (read-only access)
    final entityPositions = <int, Vector2>{};
    for (final entity in entities) {
      entityPositions[entity.id] = _physics.getEntityPosition(entity.id);
    }

    // 2. Spatial partitioning using validated positions
    _spatialGrid.updateGrid(entityPositions);

    // 3. Broad-phase detection
    final candidatePairs = _spatialGrid.getBroadPhasePairs();

    // 4. Narrow-phase detection with position validation
    final collisions = <CollisionInfo>[];
    for (final pair in candidatePairs) {
      final collision = _detectCollision(pair, entityPositions);
      if (collision != null && _validateCollision(collision)) {
        collisions.add(collision);
      }
    }

    return collisions;
  }
}
```

### System Execution Timing

**Frame Processing Order (Priority: 70):**

```
Frame Start
    ↓
1. Input System (Priority: 100) - Capture input
2. Movement System (Priority: 90) - Process movement requests
3. Physics System (Priority: 80) - Update positions and physics
4. COLLISION SYSTEM (Priority: 70) - Detect collisions, update grounded state
5. AI/Combat Systems (Priority: 60-40) - Game logic
6. Animation System (Priority: 30) - Update animations
7. Audio System (Priority: 20) - Collision sound effects
8. Render System (Priority: 10) - Visual rendering
Frame End
```

### Integration Validation

- ✅ **System Boundaries**: CollisionSystem detects only, PhysicsSystem responds only
- ✅ **Event Coordination**: All collision events properly timed with physics updates
- ✅ **State Synchronization**: Grounded state synchronized with physics simulation
- ✅ **Performance Integration**: Collision processing within frame budget allocation
- ✅ **Error Recovery**: Collision errors coordinated with physics error handling

## 11. Future Considerations

### Expandability

- **Advanced Collision Shapes**: Support for complex polygon and mesh colliders
- **Dynamic Collision Properties**: Runtime modification of surface properties
- **Collision Optimization**: Advanced spatial data structures (octrees, BSP trees)
- **Physics Material System**: Comprehensive surface interaction system

### Integration Enhancements

- **Predictive Collision**: Collision prediction for smooth movement
- **Continuous Collision Detection**: High-speed entity collision handling
- **Multi-threaded Processing**: Parallel collision detection for performance
- **Analytics Integration**: Collision frequency and performance monitoring

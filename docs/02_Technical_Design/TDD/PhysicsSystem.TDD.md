# Physics System - Technical Design Document

## 1. Overview

Defines the implementation of the core physics simulation system for Adventure Jumper, emphasizing **Fluid & Expressive Movement** that enables responsive gameplay and predictable physics behavior. This system manages gravity, velocity integration, collision detection, and physics state management with focus on maintaining consistent performance and preventing physics degradation.

> **Design & Technical References:**
>
> - [System Architecture TDD](SystemArchitecture.TDD.md) - Base system architecture and ECS integration
> - [Movement System TDD](MovementSystem.TDD.md) - Physics-movement integration patterns
> - [Player Character TDD](PlayerCharacter.TDD.md) - Character physics specifications
> - [Game Design: Core Mechanics](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) - Physics requirements
> - [Bug Report: Movement After Respawn](../../07_Reports/Bug_Report_T2_19_Movement_After_Respawn.md) - Critical physics issues identified

### Purpose

- **Primary**: Provide consistent and predictable physics simulation supporting fluid movement
- Implement gravity, velocity integration, and collision detection optimized for 60fps gameplay
- Manage physics component state lifecycle to prevent degradation and accumulation issues
- Enable precise collision detection and response for platformer mechanics
- Support system integration patterns that maintain component state consistency
- Provide performance monitoring and validation for physics operations

### Scope

- Physics simulation with gravity, acceleration, and velocity integration
- Collision detection and resolution system with spatial optimization
- Physics component state management and lifecycle procedures
- System integration patterns with MovementSystem and other physics-dependent systems
- Performance monitoring and validation framework
- State reset and cleanup procedures to prevent physics degradation

### Design Cohesion Focus: Predictable Physics Foundation

This TDD specifically supports the **Fluid & Expressive Movement** design pillar through:

- **Consistent Behavior**: Physics simulation that behaves predictably across all gameplay scenarios
- **Performance Stability**: Maintains 60fps physics processing without degradation over time
- **Component Integrity**: Prevents physics state accumulation and component synchronization issues
- **System Coordination**: Enables seamless integration with movement and collision systems
- **State Management**: Provides clear lifecycle procedures for physics component state consistency

## 2. Class Design

### Core Physics System Classes

```dart
// Main physics simulation system
class PhysicsSystem extends BaseFlameSystem {
  // Configuration and state
  double _timeScale = 1.0;
  Vector2 _gravity = Vector2(0, PhysicsConstants.gravity);
  bool _enableCollision = true;

  // Performance monitoring
  final List<double> _frameTimes = [];
  double _averageFrameTime = 0;
  final int _maxFrameTimeSamples = 60;

  // Collision processing
  final List<CollisionData> _collisions = <CollisionData>[];
  final Map<String, List<Entity>> _spatialHash = {};

  @override
  bool canProcessEntity(Entity entity) {
    // Process entities with physics components or requiring collision detection
    return entity.physics != null || entity.type == 'collectible';
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Apply physics simulation to individual entity
    processEntityPhysics(entity, dt);
  }

  @override
  void processSystem(double dt) {
    // System-wide physics processing
    // 1. Process all entity physics
    // 2. Detect and resolve collisions
    // 3. Handle edge detection
    // 4. Update performance metrics
  }

  // Core physics operations
  void processEntityPhysics(Entity entity, double dt);
  void integrateVelocity(PhysicsComponent physics, double dt);
  void applyTerminalVelocityConstraints(PhysicsComponent physics);
  void applyHorizontalFrictionAndDrag(PhysicsComponent physics, double dt, bool wasOnGround);

  // Collision system
  void detectCollisions();
  void resolveCollisions(double dt);
  void processEdgeDetection();

  // Performance monitoring
  void recordFrameTime(DateTime startTime);
  double get averageFrameTime => _averageFrameTime;
  String getPerformanceStatus();
  bool get isPerformanceOptimal;

  // State management
  void resetPhysicsState(Entity entity);
  void validateComponentState(Entity entity);
}
```

### Supporting Classes

```dart
// Enhanced collision data structure with separation vectors
class CollisionData {
  final Entity entityA;
  final Entity entityB;
  final Vector2 separationVector;
  final Vector2 normal;
  final double penetrationDepth;
  final Vector2 contactPoint;

  CollisionData({
    required this.entityA,
    required this.entityB,
    required this.separationVector,
    required this.normal,
    required this.penetrationDepth,
    required this.contactPoint,
  });
}

// Collision layers for different entity types
enum CollisionLayer {
  player(1),
  platform(2),
  enemy(4),
  collectible(8),
  projectile(16),
  environment(32);

  const CollisionLayer(this.mask);
  final int mask;

  bool canCollideWith(CollisionLayer other) {
    return (mask & other.mask) != 0;
  }
}

// Physics state validator
class PhysicsStateValidator {
  static bool validatePhysicsComponent(PhysicsComponent physics);
  static bool validateEntityPosition(Entity entity);
  static bool validateVelocityConstraints(PhysicsComponent physics);
  static void resetToSafeState(PhysicsComponent physics);
}
```

## 3. Data Structures

### Physics System State

```dart
class PhysicsSystemState {
  double timeScale;                      // Global physics time scaling
  Vector2 gravity;                       // World gravity vector
  bool collisionEnabled;                 // Collision detection toggle

  List<CollisionData> activeCollisions; // Current frame collisions
  Map<String, List<Entity>> spatialHash; // Spatial partitioning data

  // Performance tracking
  List<double> frameTimes;               // Recent frame processing times
  double averageFrameTime;               // Moving average of frame times
  int performanceStatus;                 // Current performance classification
}
```

### Physics Component State

```dart
class PhysicsComponentState {
  Vector2 position;          // Current position
  Vector2 velocity;          // Current velocity
  Vector2 acceleration;      // Current acceleration

  double mass;               // Entity mass
  double gravityScale;       // Gravity scaling factor
  double friction;           // Surface friction coefficient
  double restitution;        // Bounce factor

  bool isStatic;            // Static entity flag
  bool affectedByGravity;   // Gravity application flag
  bool isOnGround;          // Ground contact state
  bool wasOnGround;         // Previous ground state (for friction)

  // State validation
  DateTime lastUpdate;       // Last physics update timestamp
  int updateCount;          // Total updates applied
  Vector2 lastValidPosition; // Last known valid position
}
```

## 4. Algorithms

### Velocity Integration Algorithm

```
function integrateVelocity(physics: PhysicsComponent, dt: double):
  // Store current state for validation
  oldPosition = physics.parent.position.clone()

  // Apply acceleration to velocity
  physics.velocity.x += physics.acceleration.x * dt
  physics.velocity.y += physics.acceleration.y * dt

  // Apply velocity to position
  entity = physics.parent as Entity
  entity.position.x += physics.velocity.x * dt
  entity.position.y += physics.velocity.y * dt

  // CRITICAL: Synchronize TransformComponent
  entity.transformComponent.setPosition(entity.position)

  // Validate position change
  positionDelta = entity.position - oldPosition
  if positionDelta.length > MAXIMUM_POSITION_DELTA:
    // Reset to safe state
    entity.position = physics.lastValidPosition
    physics.velocity.setZero()
    logWarning("Physics integration exceeded safe limits")
  else:
    physics.lastValidPosition = entity.position.clone()

  // Reset acceleration after integration
  physics.acceleration.setZero()

  // Update physics component state tracking
  physics.lastUpdate = DateTime.now()
  physics.updateCount++
```

### Physics State Reset Procedure

```
function resetPhysicsState(entity: Entity):
  if entity.physics == null:
    return

  physics = entity.physics

  // Reset velocity and acceleration
  physics.velocity.setZero()
  physics.acceleration.setZero()

  // Reset ground state
  physics.isOnGround = false
  physics.wasOnGround = false

  // Validate and reset position if needed
  if not isValidPosition(entity.position):
    entity.position = getSpawnPosition(entity)

  // Synchronize components
  entity.transformComponent.setPosition(entity.position)
  physics.lastValidPosition = entity.position.clone()

  // Reset state tracking
  physics.lastUpdate = DateTime.now()
  physics.updateCount = 0

  logInfo("Physics state reset for entity: ${entity.id}")
```

### Collision Detection Algorithm

```
function detectCollisions():
  collisions.clear()

  // Build spatial hash for broad-phase detection
  buildSpatialHash()

  // Check all entity pairs in same spatial cells
  for each spatialCell in spatialHash:
    entities = spatialCell.entities
    for i = 0 to entities.length - 1:
      for j = i + 1 to entities.length:
        entityA = entities[i]
        entityB = entities[j]

        // Skip if layers cannot collide
        if not entityA.collisionLayer.canCollideWith(entityB.collisionLayer):
          continue

        // Perform narrow-phase collision detection
        collisionData = detectEntityCollision(entityA, entityB)
        if collisionData != null:
          collisions.add(collisionData)
```

## 5. API/Interfaces

### Physics System Interface

```dart
interface IPhysicsSystem {
  // System management
  void initialize();
  void update(double dt);
  void dispose();

  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
  bool canProcessEntity(Entity entity);

  // Physics operations
  void processEntityPhysics(Entity entity, double dt);
  void resetPhysicsState(Entity entity);
  void validatePhysicsState(Entity entity);

  // Collision management
  void detectCollisions();
  void resolveCollisions(double dt);
  List<CollisionData> getActiveCollisions();

  // Configuration
  void setGravity(Vector2 gravity);
  void setTimeScale(double timeScale);
  void setCollisionEnabled(bool enabled);

  // Performance monitoring
  double get averageFrameTime;
  String getPerformanceStatus();
  bool get isPerformanceOptimal;
}
```

### Physics Component Interface

```dart
interface IPhysicsComponent {
  // State properties
  Vector2 get position;
  Vector2 get velocity;
  Vector2 get acceleration;

  // Physics properties
  double get mass;
  double get gravityScale;
  bool get isStatic;
  bool get affectedByGravity;
  bool get isOnGround;

  // State management
  void setVelocity(Vector2 velocity);
  void applyForce(Vector2 force);
  void applyImpulse(Vector2 impulse);
  void setOnGround(bool onGround);
  void resetState();

  // Validation
  bool isValid();
  void validateState();
}
```

## 6. Dependencies

### System Dependencies

- **Base Flame System**: Core system architecture and ECS integration
- **Movement System**: Coordinated position updates and state management
- **Collision System**: Entity collision detection and response
- **Transform Component**: Position and orientation management
- **Game Config**: Physics constants and configuration values

### Component Dependencies

- **PhysicsComponent**: Core physics properties and state
- **CollisionComponent**: Collision boundaries and interaction data
- **TransformComponent**: Position and spatial transformation data
- **Entity**: Parent entity providing component access and identity

### External Dependencies

- **Flame Engine**: Core game loop and component lifecycle
- **Vector2 Math**: Position and velocity calculations
- **Dart Collections**: Entity management and spatial data structures

## 7. File Structure

```
lib/
  src/
    systems/
      physics_system.dart           # Main physics system implementation
      base_flame_system.dart        # Base system architecture
    components/
      physics_component.dart        # Physics properties and state
      collision_component.dart      # Collision detection data
      transform_component.dart      # Position and transformation
    utils/
      physics_constants.dart        # Physics configuration constants
      collision_utils.dart          # Collision detection utilities
      edge_detection_utils.dart     # Platform edge detection
    entities/
      entity.dart                   # Base entity with component access

test/
  physics_enhancement_test.dart     # Physics system validation tests
  system_integration_test.dart      # Physics-movement integration tests
  collision_enhancement_test.dart   # Collision detection tests
```

## 8. Performance Considerations

### Optimization Strategies

- **Spatial Partitioning**: Spatial hash for efficient collision broad-phase detection (O(n + k) vs O(n²))
- **Component Caching**: Cache physics component references to avoid repeated lookups
- **Vector Pooling**: Reuse Vector2 objects to reduce garbage collection pressure
- **Selective Processing**: Skip physics for static entities and out-of-bounds entities
- **Frame Time Monitoring**: Track processing times to identify performance degradation

### Memory Management

- **Object Pooling**: Reuse CollisionData and Vector2 objects across frames
- **Spatial Hash Cleanup**: Clear spatial partitioning data each frame to prevent accumulation
- **Component Validation**: Regular validation to detect and correct state corruption
- **Performance History**: Limit frame time history to prevent unbounded memory growth

### Critical Performance Targets

- **Frame Processing**: <16.67ms total physics processing time (60fps target)
- **Entity Processing**: <0.1ms per entity for basic physics simulation
- **Collision Detection**: <5ms for collision detection across all entities
- **Memory Allocation**: <1MB additional allocation per frame during normal gameplay

## 9. Testing Strategy

### Unit Tests

- **Physics Integration**: Velocity integration accuracy with various delta times
- **State Management**: Physics component state reset and validation procedures
- **Collision Detection**: Collision detection accuracy and separation vector calculation
- **Performance Monitoring**: Frame time tracking and performance status reporting

### Integration Tests

- **Physics-Movement Coordination**: Verify PhysicsSystem and MovementSystem work together correctly
- **Component Synchronization**: Test TransformComponent and entity position consistency
- **State Lifecycle**: Validate physics component state across entity lifecycle events
- **Performance Stability**: Long-term performance testing to detect degradation patterns

### Design Cohesion Testing

- **Movement Support Tests**: Verify physics enables fluid and responsive movement
- **Performance Consistency Tests**: Confirm physics maintains 60fps across gameplay scenarios
- **State Integrity Tests**: Validate physics state remains consistent during complex interactions
- **Integration Stability Tests**: Test physics system integration with all dependent systems

### Critical Validation Requirements

- **Physics Degradation Prevention**: Tests specifically designed to detect physics value accumulation
- **Component State Consistency**: Validation of TransformComponent and entity position synchronization
- **System Integration Validation**: Tests ensuring proper coordination between PhysicsSystem and MovementSystem
- **Performance Regression Detection**: Automated detection of physics performance degradation over time

## 10. Implementation Notes

### Sprint-Aligned Development Phases

**Sprint 1: Foundation Physics**

- Core physics simulation with gravity and velocity integration
- Basic collision detection and response
- Physics component state management
- _Validation_: Stable physics simulation at 60fps without degradation

**Sprint 2-3: Integration and Optimization**

- MovementSystem integration and position update coordination
- Spatial partitioning for collision optimization
- Performance monitoring and validation framework
- _Validation_: Seamless physics-movement integration without conflicts

**Sprint 4-6: Advanced Features and Stability**

- Advanced collision features and edge detection
- Physics state validation and recovery procedures
- Comprehensive integration testing
- _Validation_: Robust physics system supporting complex gameplay scenarios

**Sprint 7+: Polish and Validation**

- Performance optimization and memory management
- Advanced debugging and diagnostic tools
- Final validation against design pillar requirements
- _Validation_: Physics system fully supports Fluid & Expressive Movement design goals

### Design Cohesion Validation Checkpoints

**Fluid & Expressive Movement Metrics:**

- **Physics Stability**: No physics degradation over extended gameplay sessions
- **Position Consistency**: TransformComponent and entity position remain synchronized
- **Integration Seamless**: PhysicsSystem and MovementSystem coordinate without conflicts
- **Performance Predictable**: Consistent frame times without accumulation or degradation
- **State Management Reliable**: Physics component state resets properly across all scenarios

**Critical Implementation Guidelines:**

- **Position Update Ownership**: Only PhysicsSystem modifies entity positions during physics processing
- **Component Synchronization**: Always update TransformComponent when modifying entity position
- **State Validation**: Regular validation of physics component state to prevent corruption
- **Performance Monitoring**: Continuous monitoring of frame times and performance metrics
- **Integration Coordination**: Clear interfaces and communication patterns with MovementSystem

### Physics State Management Principles

**State Consistency Rules:**

- Physics component state must be validated before processing
- Entity position and TransformComponent must remain synchronized
- Physics values must be reset properly during entity lifecycle events
- Component state accumulation must be prevented through proper cleanup procedures

**Integration Patterns:**

- PhysicsSystem owns physics simulation and position updates during processing
- MovementSystem coordinates with PhysicsSystem for movement input translation
- Clear system execution order prevents processing conflicts
- Shared component access follows documented protocols

## 11. Future Considerations

### Expandability

- Advanced physics features (soft body physics, particle systems)
- Multi-threaded physics processing for performance scaling
- Physics debugging tools and visual diagnostic systems
- Integration with advanced movement mechanics (wall running, gravity manipulation)

### Advanced Optimization

- GPU-accelerated collision detection for large entity counts
- Predictive physics for network multiplayer support
- Advanced spatial partitioning algorithms (octrees, BSP trees)
- Physics level-of-detail for distant entities

## Related Design Documents

- See [Movement System TDD](MovementSystem.TDD.md) for physics-movement integration specifications
- See [System Architecture TDD](SystemArchitecture.TDD.md) for base system architecture patterns
- See [Player Character TDD](PlayerCharacter.TDD.md) for character-specific physics requirements
- See [Bug Report: Movement After Respawn](../../07_Reports/Bug_Report_T2_19_Movement_After_Respawn.md) for critical physics issues and investigation results
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for physics requirements from game design perspective

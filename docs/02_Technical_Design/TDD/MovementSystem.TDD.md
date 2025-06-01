# Movement System - Technical Design Document

## 1. Overview

Defines the implementation of the movement processing system for Adventure Jumper, focusing on **Fluid & Expressive Movement** through coordinated integration with the physics system. This system manages movement input translation, position update coordination, and movement state management while maintaining seamless integration with physics simulation.

> **Design & Technical References:**
>
> - [Physics System TDD](PhysicsSystem.TDD.md) - Core physics simulation and integration patterns
> - [System Architecture TDD](SystemArchitecture.TDD.md) - Base system architecture and coordination
> - [Player Character TDD](PlayerCharacter.TDD.md) - Character movement specifications
> - [Input System Reference](../SystemsReference.md) - Input processing integration
> - [Bug Report: Movement After Respawn](../../07_Reports/Bug_Report_T2_19_Movement_After_Respawn.md) - Movement-physics integration issues

### Purpose

- **Primary**: Coordinate movement processing with physics system to prevent position update conflicts
- Translate movement input into physics forces and velocity changes
- Manage movement state synchronization between components
- Provide movement constraints and validation for gameplay mechanics
- Ensure seamless integration with physics simulation without duplication or conflicts
- Support movement debugging and state monitoring

### Scope

- Movement input processing and translation to physics operations
- Position update coordination with PhysicsSystem to prevent conflicts
- Movement state management and validation
- Integration patterns with physics simulation system
- Movement constraints and boundary enforcement
- Performance monitoring for movement processing

### Design Cohesion Focus: Movement-Physics Integration

This TDD specifically supports the **Fluid & Expressive Movement** design pillar through:

- **System Coordination**: Clear integration patterns with PhysicsSystem preventing conflicts
- **Input Responsiveness**: Immediate translation of input to physics forces for fluid control
- **State Consistency**: Maintains synchronized movement state across all components
- **Position Integrity**: Prevents position update conflicts through documented ownership patterns
- **Performance Stability**: Efficient movement processing that doesn't interfere with physics simulation

## 2. Class Design

### Core Movement System Classes

```dart
// Main movement processing system
class MovementSystem extends BaseFlameSystem {
  // Configuration
  double _globalTimeScale = 1.0;

  // Movement state tracking
  final Map<String, MovementState> _movementStates = {};

  // Integration coordination
  PhysicsSystem? _physicsSystem;
  bool _coordinateWithPhysics = true;

  @override
  bool canProcessEntity(Entity entity) {
    // Process entities with physics components for movement
    // Note: This system coordinates WITH physics, doesn't replace it
    return entity.physics != null;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Process movement state for entity
    // CRITICAL: This system does NOT update positions directly
    // Instead, it coordinates with PhysicsSystem for position updates
    processMovementState(entity, dt);
  }

  @override
  void processSystem(double dt) {
    // System-wide movement processing
    // 1. Update movement states
    // 2. Coordinate with physics system
    // 3. Validate movement constraints
    // 4. Monitor performance
  }

  // Movement processing (DOES NOT update positions directly)
  void processMovementState(Entity entity, double dt);
  void validateMovementConstraints(Entity entity);
  void synchronizeWithPhysics(Entity entity);

  // Movement state management
  MovementState getMovementState(Entity entity);
  void updateMovementState(Entity entity, MovementState state);
  void resetMovementState(Entity entity);

  // Physics system coordination
  void setPhysicsSystem(PhysicsSystem physicsSystem);
  void requestPositionUpdate(Entity entity, Vector2 newPosition);
  void requestVelocityChange(Entity entity, Vector2 velocity);

  // Movement constraints
  void applyMovementConstraints(Entity entity);
  bool isValidMovementRequest(Entity entity, Vector2 requestedPosition);
}
```

### Supporting Classes

```dart
// Movement state data
class MovementState {
  // Movement properties
  Vector2 targetVelocity;         // Desired velocity from input
  Vector2 inputDirection;         // Current input direction
  double movementSpeed;           // Current movement speed

  // State flags
  bool isMoving;                  // Movement input active
  bool wasMoving;                 // Previous movement state
  MovementType currentMovement;   // Type of movement (walk, run, etc.)

  // Constraints
  Vector2 movementBounds;         // Movement boundary limits
  List<MovementConstraint> constraints; // Active movement constraints

  // Integration coordination
  DateTime lastPhysicsSync;       // Last physics coordination timestamp
  Vector2 lastConfirmedPosition;  // Last position confirmed by physics
  int syncAttempts;               // Physics sync attempts counter

  MovementState({
    Vector2? targetVelocity,
    Vector2? inputDirection,
    this.movementSpeed = 0.0,
    this.isMoving = false,
    this.wasMoving = false,
    this.currentMovement = MovementType.idle,
    Vector2? movementBounds,
    List<MovementConstraint>? constraints,
  }) {
    this.targetVelocity = targetVelocity ?? Vector2.zero();
    this.inputDirection = inputDirection ?? Vector2.zero();
    this.movementBounds = movementBounds ?? Vector2.zero();
    this.constraints = constraints ?? [];
    this.lastPhysicsSync = DateTime.now();
    this.lastConfirmedPosition = Vector2.zero();
    this.syncAttempts = 0;
  }
}

// Movement types
enum MovementType {
  idle,
  walking,
  running,
  jumping,
  falling,
  dashing,
  wallSliding
}

// Movement constraints
abstract class MovementConstraint {
  bool isValidMovement(Entity entity, Vector2 requestedPosition);
  Vector2 constrainMovement(Entity entity, Vector2 requestedPosition);
}

// Boundary constraint implementation
class BoundaryConstraint extends MovementConstraint {
  final Rect boundaryRect;

  BoundaryConstraint(this.boundaryRect);

  @override
  bool isValidMovement(Entity entity, Vector2 requestedPosition) {
    return boundaryRect.contains(Offset(requestedPosition.x, requestedPosition.y));
  }

  @override
  Vector2 constrainMovement(Entity entity, Vector2 requestedPosition) {
    return Vector2(
      requestedPosition.x.clamp(boundaryRect.left, boundaryRect.right),
      requestedPosition.y.clamp(boundaryRect.top, boundaryRect.bottom),
    );
  }
}

// Physics integration coordinator
class MovementPhysicsCoordinator {
  static void synchronizeMovementWithPhysics(
    Entity entity,
    MovementState movementState,
    PhysicsSystem physicsSystem
  );

  static bool validatePhysicsSync(Entity entity, MovementState movementState);
  static void handleSyncFailure(Entity entity, MovementState movementState);
}
```

## 3. Data Structures

### Movement System State

```dart
class MovementSystemState {
  double globalTimeScale;                         // Movement timing scale
  bool coordinateWithPhysics;                     // Physics integration enabled
  PhysicsSystem? physicsSystemReference;          // Reference to physics system

  Map<String, MovementState> movementStates;      // Per-entity movement states
  List<MovementConstraint> globalConstraints;     // System-wide constraints

  // Performance tracking
  int entitiesProcessed;                          // Entities processed this frame
  double lastProcessingTime;                      // Last frame processing time
  int physicsCoordinationAttempts;                // Physics sync attempts
  int physicsCoordinationFailures;                // Physics sync failures
}
```

### Movement Integration Data

```dart
class MovementIntegrationData {
  // Position coordination
  Vector2 requestedPosition;      // Position requested by movement
  Vector2 confirmedPosition;      // Position confirmed by physics
  Vector2 positionDelta;          // Difference between requested and confirmed

  // Velocity coordination
  Vector2 requestedVelocity;      // Velocity requested by movement
  Vector2 appliedVelocity;        // Velocity applied by physics

  // Synchronization state
  bool isSynchronized;            // Movement and physics are synchronized
  DateTime lastSyncTime;          // Last successful synchronization time
  int syncFailureCount;           // Number of consecutive sync failures

  // Validation
  bool isValidState;              // Current state is valid and consistent
  String? lastValidationError;    // Last validation error message
}
```

## 4. Algorithms

### Movement State Processing Algorithm

```
function processMovementState(entity: Entity, dt: double):
  // Get current movement state
  movementState = getMovementState(entity)

  // CRITICAL: Do NOT update position directly
  // Movement system coordinates WITH physics system

  // Process movement input and constraints
  if entity.hasMovementInput():
    targetVelocity = calculateTargetVelocity(entity, dt)
    inputDirection = getInputDirection(entity)

    // Apply movement constraints
    constrainedVelocity = applyMovementConstraints(entity, targetVelocity)

    // Update movement state
    movementState.targetVelocity = constrainedVelocity
    movementState.inputDirection = inputDirection
    movementState.isMoving = (constrainedVelocity.length > 0)
    movementState.currentMovement = determineMovementType(entity, constrainedVelocity)
  else:
    // No movement input
    movementState.targetVelocity = Vector2.zero()
    movementState.inputDirection = Vector2.zero()
    movementState.isMoving = false
    movementState.currentMovement = MovementType.idle

  // Coordinate with physics system for actual position updates
  if coordinateWithPhysics && physicsSystem != null:
    synchronizeWithPhysics(entity, movementState)

  // Update movement state tracking
  movementState.wasMoving = movementState.isMoving
  updateMovementState(entity, movementState)

  // Validate final state
  validateMovementState(entity, movementState)
```

### Physics Coordination Algorithm

```
function synchronizeWithPhysics(entity: Entity, movementState: MovementState):
  // CRITICAL: This is the key integration pattern
  // MovementSystem requests changes, PhysicsSystem applies them

  if not physicsSystem.canProcessEntity(entity):
    return

  // Request velocity change through physics system
  if movementState.targetVelocity != entity.physics.velocity:
    requestVelocityChange(entity, movementState.targetVelocity)

  // Validate physics applied the requested velocity
  appliedVelocity = entity.physics.velocity
  velocityDelta = movementState.targetVelocity - appliedVelocity

  if velocityDelta.length > VELOCITY_SYNC_THRESHOLD:
    // Physics system modified the requested velocity
    // Update movement state to match physics reality
    movementState.targetVelocity = appliedVelocity
    movementState.syncAttempts++

    if movementState.syncAttempts > MAX_SYNC_ATTEMPTS:
      logWarning("Movement-Physics sync failure for entity: ${entity.id}")
      resetMovementState(entity)
      return

  // Record successful synchronization
  movementState.lastPhysicsSync = DateTime.now()
  movementState.syncAttempts = 0
  movementState.lastConfirmedPosition = entity.position.clone()
```

### Movement State Reset Procedure

```
function resetMovementState(entity: Entity):
  movementState = getMovementState(entity)

  // Reset movement properties
  movementState.targetVelocity.setZero()
  movementState.inputDirection.setZero()
  movementState.movementSpeed = 0.0

  // Reset state flags
  movementState.isMoving = false
  movementState.wasMoving = false
  movementState.currentMovement = MovementType.idle

  // Reset synchronization state
  movementState.lastPhysicsSync = DateTime.now()
  movementState.lastConfirmedPosition = entity.position.clone()
  movementState.syncAttempts = 0

  // Clear constraints if needed
  movementState.constraints.clear()

  // Coordinate reset with physics system
  if physicsSystem != null:
    requestVelocityChange(entity, Vector2.zero())

  updateMovementState(entity, movementState)
  logInfo("Movement state reset for entity: ${entity.id}")
```

## 5. API/Interfaces

### Movement System Interface

```dart
interface IMovementSystem {
  // System management
  void initialize();
  void update(double dt);
  void dispose();

  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
  bool canProcessEntity(Entity entity);

  // Movement processing
  void processMovementState(Entity entity, double dt);
  void resetMovementState(Entity entity);
  void validateMovementState(Entity entity);

  // Physics coordination
  void setPhysicsSystem(PhysicsSystem physicsSystem);
  void requestVelocityChange(Entity entity, Vector2 velocity);
  bool isPhysicsCoordinated(Entity entity);

  // Movement constraints
  void addMovementConstraint(Entity entity, MovementConstraint constraint);
  void removeMovementConstraint(Entity entity, MovementConstraint constraint);
  bool isValidMovementRequest(Entity entity, Vector2 requestedPosition);

  // State management
  MovementState getMovementState(Entity entity);
  void updateMovementState(Entity entity, MovementState state);

  // Configuration
  void setTimeScale(double timeScale);
  void setPhysicsCoordination(bool enabled);
}
```

### Movement State Interface

```dart
interface IMovementState {
  // Movement properties
  Vector2 get targetVelocity;
  Vector2 get inputDirection;
  double get movementSpeed;
  MovementType get currentMovement;

  // State flags
  bool get isMoving;
  bool get wasMoving;

  // Constraints
  List<MovementConstraint> get constraints;

  // Physics coordination
  DateTime get lastPhysicsSync;
  int get syncAttempts;
  bool get isSynchronized;

  // State management
  void reset();
  void updateFromInput(Vector2 inputDirection, double speed);
  void applyConstraints();
  bool isValid();
}
```

## 6. Dependencies

### System Dependencies

- **Physics System**: Primary integration partner for position updates and velocity changes
- **Input System**: Source of movement input and control state
- **Base Flame System**: Core system architecture and lifecycle management
- **Transform Component**: Position and spatial data coordination

### Component Dependencies

- **PhysicsComponent**: Target for velocity changes and physics state coordination
- **TransformComponent**: Position data access (READ-ONLY for MovementSystem)
- **InputComponent**: Movement input data source

### External Dependencies

- **Flame Engine**: Core game loop and component lifecycle
- **Vector2 Math**: Movement calculations and coordinate transformations
- **Dart Collections**: Movement state management and constraint storage

## 7. File Structure

```
lib/
  src/
    systems/
      movement_system.dart          # Main movement system implementation
      physics_system.dart          # Physics system integration partner
      base_flame_system.dart        # Base system architecture
    components/
      physics_component.dart        # Physics state integration
      transform_component.dart      # Position data access
      input_component.dart          # Movement input source
    utils/
      movement_constants.dart       # Movement configuration constants
      movement_constraints.dart     # Movement constraint implementations
    entities/
      entity.dart                   # Base entity with component access

test/
  movement_system_test.dart         # Movement system unit tests
  movement_physics_integration_test.dart # Movement-physics coordination tests
  movement_constraints_test.dart    # Movement constraint tests
```

## 8. Performance Considerations

### Optimization Strategies

- **State Caching**: Cache movement states to avoid repeated calculations
- **Lazy Evaluation**: Only process movement when input changes occur
- **Constraint Optimization**: Efficient constraint checking with early termination
- **Physics Coordination Batching**: Batch physics system requests to minimize overhead

### Memory Management

- **Movement State Pooling**: Reuse MovementState objects to reduce allocation
- **Constraint Caching**: Cache constraint results for repeated evaluations
- **State Cleanup**: Proper cleanup of movement states when entities are removed
- **Integration Data Optimization**: Minimize data stored for physics coordination

### Critical Performance Targets

- **Movement Processing**: <0.1ms per entity for movement state processing
- **Physics Coordination**: <1ms total coordination overhead per frame
- **Constraint Evaluation**: <0.05ms per constraint check
- **Memory Allocation**: <100KB additional allocation per frame during normal gameplay

## 9. Testing Strategy

### Unit Tests

- **Movement State Processing**: Validate movement state updates from various input scenarios
- **Physics Coordination**: Test coordination patterns with PhysicsSystem
- **Constraint Application**: Verify movement constraints work correctly
- **State Reset Procedures**: Validate movement state reset and recovery

### Integration Tests

- **Movement-Physics Integration**: Test seamless coordination with PhysicsSystem
- **Input-Movement Translation**: Verify input correctly translates to movement requests
- **Component Synchronization**: Test consistency between movement state and physics state
- **System Coordination**: Validate proper system execution order and coordination

### Design Cohesion Testing

- **Movement Fluidity Tests**: Verify movement feels responsive and smooth
- **Physics Integration Tests**: Confirm movement and physics work together seamlessly
- **State Consistency Tests**: Validate movement state remains consistent across all scenarios
- **Performance Stability Tests**: Test movement processing doesn't degrade over time

### Critical Validation Requirements

- **Position Update Prevention**: Ensure MovementSystem never directly modifies entity positions
- **Physics Coordination Validation**: Test proper coordination patterns with PhysicsSystem
- **State Synchronization Testing**: Validate movement and physics state remain synchronized
- **Constraint Effectiveness Testing**: Verify movement constraints work without conflicting with physics

## 10. Implementation Notes

### Sprint-Aligned Development Phases

**Sprint 1: Core Movement Processing**

- Basic movement state management and input translation
- Initial physics system coordination patterns
- Simple movement constraints implementation
- _Validation_: Movement input translates to physics velocity changes correctly

**Sprint 2-3: Physics Integration**

- Advanced physics coordination and synchronization
- Position update ownership clarification and enforcement
- Movement constraint integration with physics system
- _Validation_: Seamless movement-physics integration without conflicts

**Sprint 4-6: Advanced Features**

- Complex movement constraints and boundary enforcement
- Performance optimization and state caching
- Advanced debugging and diagnostic capabilities
- _Validation_: Robust movement system supporting complex gameplay scenarios

**Sprint 7+: Polish and Validation**

- Final performance optimization and memory management
- Comprehensive integration testing with all game systems
- Advanced movement features and customization options
- _Validation_: Movement system fully supports Fluid & Expressive Movement design goals

### Critical Implementation Guidelines

**Position Update Ownership:**

- **NEVER**: MovementSystem must never directly modify entity positions
- **ALWAYS**: Use physics system coordination for all position changes
- **VALIDATE**: Confirm physics system applied requested changes correctly
- **RECOVER**: Handle cases where physics system modifies requested values

**Physics Integration Patterns:**

- **Request-Based**: Movement system requests changes, physics system applies them
- **Validation-Based**: Always validate physics system applied requested changes
- **Coordination-Based**: Clear communication patterns between systems
- **Recovery-Based**: Handle coordination failures gracefully

### Movement-Physics Coordination Principles

**System Responsibilities:**

- **MovementSystem**: Processes movement input, manages movement state, coordinates with physics
- **PhysicsSystem**: Applies physics simulation, manages entity positions, handles collision
- **Clear Boundaries**: No overlap in position update responsibilities
- **Coordinated Operation**: Systems work together through documented interfaces

**Integration Best Practices:**

- Use request-response patterns for system coordination
- Validate all inter-system communication results
- Implement graceful failure handling for coordination issues
- Maintain clear separation of concerns between systems

## 11. Future Considerations

### Expandability

- Advanced movement mechanics (wall running, gravity surfing, momentum preservation)
- AI movement integration for non-player entities
- Network multiplayer movement prediction and synchronization
- Advanced movement constraints (dynamic obstacles, moving platforms)

### Advanced Optimization

- Multi-threaded movement processing for large entity counts
- Predictive movement for network lag compensation
- Advanced caching strategies for complex movement patterns
- Movement recording and playback for debugging and analytics

## Related Design Documents

- See [Physics System TDD](PhysicsSystem.TDD.md) for physics simulation and integration specifications
- See [Player Character TDD](PlayerCharacter.TDD.md) for character-specific movement requirements
- See [System Architecture TDD](SystemArchitecture.TDD.md) for base system coordination patterns
- See [Bug Report: Movement After Respawn](../../07_Reports/Bug_Report_T2_19_Movement_After_Respawn.md) for movement-physics integration issues
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for movement requirements from game design perspective
- See [Input System Reference](../SystemsReference.md) for input processing integration patterns

# System Architecture - Technical Design Document

## 1. Overview

Defines the high-level architecture of Adventure Jumper, emphasizing design cohesion principles that support Fluid & Expressive Movement, Engaging & Dynamic Combat, and Progressive Mastery throughout Kael's journey.

> **Related Documents:**
>
> - [Architecture Overview](../Architecture.md) - High-level architecture diagrams
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Design principles and validation criteria
> - [Agile Sprint Plan](../../04_Project_Management/AgileSprintPlan.md) - Sprint delivery timeline
> - [Component Reference](../ComponentsReference.md) - Component usage across modules
> - [AssetPipeline.md](../AssetPipeline.md) - Asset strategy supporting architecture
> - [PhysicsSystem TDD](PhysicsSystem.TDD.md) - Physics system specification
> - [MovementSystem TDD](MovementSystem.TDD.md) - Movement system integration patterns
> - [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) - Critical refactor strategy

### Purpose

- Establish architectural patterns that enhance responsive gameplay and player expression
- Define component communication protocols that support seamless system integration
- Ensure scalable and maintainable code structure that grows with player abilities
- Guide implementation decisions that prioritize player experience over technical complexity
- **Specify physics-movement system integration patterns to prevent performance degradation**

### Scope

- Game engine integration (Flame) optimized for 60fps gameplay
- Component-based architecture supporting fluid movement and combat integration
- System communication patterns enabling real-time responsiveness
- Performance optimization strategies for smooth player experience
- Design cohesion validation framework ensuring technical decisions support game vision
- **Physics-movement coordination interfaces preventing system conflicts and accumulation issues**

## 2. Class Design

### Core Architecture Classes

```dart
// Main game class - entry point and system coordinator
class AdventureJumperGame extends FlameGame {
  // System managers
  // Game state management
  // Scene coordination
}

// Base component for all game entities
abstract class Entity extends Component {
  // Common component functionality
  // State management
  // Lifecycle methods
}

// System interface that all systems implement
abstract class System {
  // System active state
  bool get isActive;
  set isActive(bool value);

  // System priority for update order
  int get priority;
  set priority(int value);

  // Core system methods
  void update(double dt);
  void initialize();
  void dispose();

  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
}

// Base system implementation
abstract class BaseSystem implements System {
  // Entity list for tracking
  final List<Entity> _entities = <Entity>[];

  // System state
  bool _isActive = true;
  int _priority = 0;

  // Entity management
  void addEntity(Entity entity) {
    if (canProcessEntity(entity) && !_entities.contains(entity)) {
      _entities.add(entity);
      onEntityAdded(entity);
    }
  }

  void removeEntity(Entity entity) {
    if (_entities.remove(entity)) {
      onEntityRemoved(entity);
    }
  }

  // System update loop
  void update(double dt) {
    if (!isActive) return;

    // Process all registered entities
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;
      processEntity(entity, dt);
    }

    // Handle system-wide logic
    processSystem(dt);
  }

  // Override these in derived systems
  bool canProcessEntity(Entity entity);
  void processEntity(Entity entity, double dt);
  void processSystem(double dt) {}
  void onEntityAdded(Entity entity) {}
  void onEntityRemoved(Entity entity) {}
}

// Flame-specific system implementation
abstract class BaseFlameSystem extends Component implements System {
  // Entity list for tracking
  final List<Entity> _entities = <Entity>[];

  // System state
  bool _isActive = true;
  int _priority = 0;

  // Entity management
  void addEntity(Entity entity) {
    if (canProcessEntity(entity) && !_entities.contains(entity)) {
      _entities.add(entity);
      onEntityAdded(entity);
    }
  }

  void removeEntity(Entity entity) {
    if (_entities.remove(entity)) {
      onEntityRemoved(entity);
    }
  }

  // Component integration
  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    // Process all registered entities
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;
      processEntity(entity, dt);
    }

    // Handle system-wide logic
    processSystem(dt);
  }

  // Override these in derived systems
  bool canProcessEntity(Entity entity);
  void processEntity(Entity entity, double dt);
  void processSystem(double dt) {}
  void onEntityAdded(Entity entity) {}
  void onEntityRemoved(Entity entity) {}
}
```

### Key Responsibilities

- **AdventureGame**: Main game loop, system coordination, scene management
- **GameComponent**: Base functionality for all game entities
- **GameSystem**: Abstract base for specialized systems (Combat, AI, Audio, etc.)

## 3. Data Structures

### Game Configuration

```dart
class GameConfig {
  // Performance settings
  // Control mappings
  // Audio settings
  // Graphics quality
}
```

### System Organization

```dart
// Systems are added to the game world directly
class GameWorld {
  // Add systems to the game
  void addSystem(System system);

  // Systems organized by function with defined execution order
  late final InputSystem inputSystem;          // Priority: 100, extends BaseFlameSystem
  late final MovementSystem movementSystem;    // Priority: 90,  extends BaseFlameSystem
  late final PhysicsSystem physicsSystem;      // Priority: 80,  extends BaseFlameSystem
  late final CollisionSystem collisionSystem;  // Priority: 70,  extends BaseFlameSystem
  late final AISystem aiSystem;                // Priority: 60,  extends BaseSystem
  late final CombatSystem combatSystem;        // Priority: 50,  extends BaseSystem
  late final AetherSystem aetherSystem;        // Priority: 40,  extends BaseSystem
  late final AnimationSystem animationSystem;  // Priority: 30,  extends BaseSystem
  late final AudioSystem audioSystem;          // Priority: 20,  extends BaseSystem
  late final RenderSystem renderSystem;        // Priority: 10,  extends BaseSystem
  late final DialogueSystem dialogueSystem;    // Priority: 5,   extends BaseSystem
}
```

### Physics-Movement System Integration Patterns

#### IPhysicsCoordinator Interface

```dart
// Coordination interface for physics-movement system communication
abstract class IPhysicsCoordinator {
  // Movement request methods
  void requestMovement(int entityId, Vector2 direction, double speed);
  void requestJump(int entityId, double force);
  void requestStop(int entityId);
  void requestImpulse(int entityId, Vector2 impulse);

  // State query methods
  bool isGrounded(int entityId);
  Vector2 getVelocity(int entityId);
  Vector2 getPosition(int entityId);
  bool hasCollisionBelow(int entityId);

  // State management methods
  void resetPhysicsState(int entityId);
  void clearAccumulatedForces(int entityId);
  void setPositionOverride(int entityId, Vector2 position); // For respawn/teleport only
}
```

#### Request-Response Protocol

```dart
// Movement request data structure
class MovementRequest {
  final int entityId;
  final Vector2 direction;
  final double speed;
  final MovementType type;
  final double timestamp;

  bool validate() {
    return entityId >= 0 && speed >= 0.0 && direction.isFinite;
  }
}

// Physics response structure
class PhysicsResponse {
  final int entityId;
  final Vector2 actualVelocity;
  final Vector2 actualPosition;
  final bool grounded;
  final List<CollisionInfo> collisions;
}
```

#### Component Ownership Rules

```dart
// Position Update Ownership: PHYSICS SYSTEM ONLY
// The PhysicsSystem is the SINGLE source of truth for entity positions
class PhysicsSystem extends BaseFlameSystem implements IPhysicsCoordinator {
  // EXCLUSIVE ownership of position updates
  void _updateEntityPosition(Entity entity, Vector2 newPosition) {
    // Only this method may modify entity.position
  }

  // Velocity modification permissions: Physics System primary, limited delegation
  void _updateVelocity(Entity entity, Vector2 velocity) {
    // Primary velocity control
  }
}

// Movement System: REQUEST-ONLY access to physics
class MovementSystem extends BaseFlameSystem {
  late final IPhysicsCoordinator _physics;

  // NO DIRECT position/velocity modification allowed
  void _handleInput(Entity entity, InputState input) {
    // Translate input to physics requests only
    _physics.requestMovement(entity.id, inputDirection, moveSpeed);
  }
}
```

## 4. Algorithms

### System Execution Order & Frame Timing

#### Primary Update Sequence (Per Frame)

```
Frame Start
    ↓
1. INPUT SYSTEM (Priority: 100)
   - Capture player input
   - Process input buffering
   - Generate input events
    ↓
2. MOVEMENT SYSTEM (Priority: 90)
   - Process input events
   - Generate movement requests
   - Send requests to PhysicsSystem
    ↓
3. PHYSICS SYSTEM (Priority: 80)
   - Process movement requests
   - Apply forces and impulses
   - Integrate velocity
   - Update positions (EXCLUSIVE)
   - Clear accumulated forces
    ↓
4. COLLISION SYSTEM (Priority: 70)
   - Detect collisions
   - Generate collision events
   - Update physics state flags
    ↓
5. AI/COMBAT/OTHER SYSTEMS (Priority: 60-40)
   - Process game logic
   - React to physics/collision state
    ↓
6. ANIMATION SYSTEM (Priority: 30)
   - Update animations based on movement state
   - Sync visual state with physics
    ↓
7. AUDIO SYSTEM (Priority: 20)
   - Trigger sound effects
   - Update spatial audio
    ↓
8. RENDER SYSTEM (Priority: 10)
   - Render visual components
   - Apply visual effects
    ↓
Frame End
```

#### State Synchronization Rules

**Physics State Authority:**

- **Position**: PhysicsSystem has EXCLUSIVE write access
- **Velocity**: PhysicsSystem primary, MovementSystem requests only
- **Grounded State**: CollisionSystem writes, others read-only
- **Forces**: Multiple systems can request, PhysicsSystem clears

**Critical Timing Requirements:**

- Movement requests must be processed within same frame
- Physics integration must complete before collision detection
- State resets must occur before next frame's input processing
- Maximum 1 frame latency for input → visual feedback

### Component Update Ordering

- Priority-based system updates
- Dependency resolution for system initialization
- Event propagation patterns

### System Processing Flow

1. Entity added to game world
2. Each system evaluates the entity using `canProcessEntity()`
3. If a system can process the entity, it adds it to its internal list
4. On each update, systems process their entities in order of priority
5. Within each system, `processEntity()` is called for each active entity
6. After entity processing, `processSystem()` handles system-wide logic

### ECS Refactoring

The System architecture was refactored to improve maintainability and reduce code duplication:

- Created standardized base classes for all systems
- Implemented consistent entity filtering and processing patterns
- Reduced duplicate code across systems by ~200 lines
- Added backward compatibility methods for legacy code
- Standardized lifecycle management (initialize, update, dispose)

### Memory Management

- Object pooling for frequently created/destroyed entities
- Efficient component storage and retrieval
- Asset loading and unloading strategies

## 5. API/Interfaces

### System API

```dart
// Core System interface
abstract class System {
  // Whether this system is active
  bool get isActive;
  set isActive(bool value);

  // Priority for update order (higher values update first)
  int get priority;
  set priority(int value);

  // Core methods
  void update(double dt);
  void initialize();
  void dispose();

  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
}

// BaseSystem extension points
abstract class BaseSystem implements System {
  // Entity filtering
  bool canProcessEntity(Entity entity);

  // Entity processing
  void processEntity(Entity entity, double dt);

  // System-wide processing
  void processSystem(double dt);

  // Entity callbacks
  void onEntityAdded(Entity entity);
  void onEntityRemoved(Entity entity);
}
```

### Physics-Movement Integration API

```dart
// Primary coordination interface
abstract class IPhysicsCoordinator {
  // Movement request methods
  void requestMovement(int entityId, Vector2 direction, double speed);
  void requestJump(int entityId, double force);
  void requestStop(int entityId);
  void requestImpulse(int entityId, Vector2 impulse);

  // State query methods (read-only access for other systems)
  bool isGrounded(int entityId);
  Vector2 getVelocity(int entityId);
  Vector2 getPosition(int entityId);
  bool hasCollisionBelow(int entityId);

  // State management methods
  void resetPhysicsState(int entityId);
  void clearAccumulatedForces(int entityId);
  void setPositionOverride(int entityId, Vector2 position); // Respawn/teleport only
}

// Movement system interface for input handling
abstract class IMovementHandler {
  void handleMovementInput(int entityId, Vector2 direction, double intensity);
  void handleJumpInput(int entityId, bool pressed);
  void handleStopInput(int entityId);
}

// Collision notification interface
abstract class ICollisionNotifier {
  void onCollisionEnter(int entityId, CollisionInfo collision);
  void onCollisionExit(int entityId, CollisionInfo collision);
  void onGroundStateChanged(int entityId, bool grounded);
}
```

### State Management & Accumulation Prevention

```dart
// Physics state container with accumulation limits
class PhysicsState {
  Vector2 position;
  Vector2 velocity;
  Vector2 accumulatedForces;
  bool grounded;

  // Accumulation prevention constants
  static const double MAX_VELOCITY = 1000.0;
  static const double MAX_FORCE_ACCUMULATION = 500.0;
  static const double FORCE_DECAY_RATE = 0.98;
  static const double VELOCITY_DAMPING = 0.99;

  // Prevent physics value accumulation
  void preventAccumulation() {
    // Clamp velocity to prevent runaway values
    velocity = velocity.clamped(MAX_VELOCITY);

    // Limit force accumulation
    accumulatedForces = accumulatedForces.clamped(MAX_FORCE_ACCUMULATION);

    // Apply natural damping
    if (velocity.length < 0.1) {
      velocity = Vector2.zero();
    }

    if (accumulatedForces.length < 0.1) {
      accumulatedForces = Vector2.zero();
    }
  }

  // Complete state reset for respawn/level transition
  void resetState() {
    velocity = Vector2.zero();
    accumulatedForces = Vector2.zero();
    grounded = false;
  }
}
```

````

### Component Integration
```dart
// Components are added to entities
class Entity {
  // Add a component to this entity
  void add(Component component);

  // Get components by type
  T? getComponent<T extends Component>();
  List<T> getComponents<T extends Component>();
}
````

### System Integration Error Handling

```dart
// Error handling for physics-movement coordination
enum PhysicsErrorType {
  invalidMovementRequest,
  accumulationDetected,
  stateDesynchronization,
  positionOverrideFailure,
  forceApplicationFailure
}

class PhysicsIntegrationError extends Error {
  final PhysicsErrorType type;
  final int entityId;
  final String details;
  final StackTrace? stackTrace;

  PhysicsIntegrationError(this.type, this.entityId, this.details, [this.stackTrace]);

  @override
  String toString() => 'PhysicsIntegrationError: $type for entity $entityId - $details';
}

// Error recovery procedures
abstract class IErrorRecovery {
  void handlePhysicsError(PhysicsIntegrationError error);
  void recoverFromAccumulation(int entityId);
  void forceStateReset(int entityId);
}
```

## 6. Dependencies

### External Dependencies

- **Flame Engine**: Core game framework
- **Flutter**: UI and platform integration
- **Dart**: Programming language and runtime

### Internal Dependencies

- All game systems depend on this architecture
- Asset management system
- Configuration management

## 7. File Structure

```
lib/
  game/
    adventure_game.dart              # Main game class
    core/
      game_component.dart            # Base component class
      game_system.dart              # Base system class
      system_registry.dart          # System management
      game_config.dart              # Configuration data
    systems/
      [individual system files]     # Specific system implementations
    events/
      game_events.dart              # Event system
      event_bus.dart               # Event communication
```

## 8. Performance Considerations

### Optimization Strategies

- Component pooling for enemies and effects
- Efficient update loop ordering
- Selective rendering based on viewport
- Asset streaming for large worlds

### Memory Management

- Automatic cleanup of unused components
- Efficient data structures for large collections
- Lazy loading of non-critical systems

## 9. Testing Strategy

### Unit Tests

- Individual component functionality
- System initialization and cleanup
- Event propagation correctness

### Integration Tests

- System communication protocols
- Performance under load
- Memory usage patterns

## 10. Implementation Notes

### Sprint-Aligned Development Phases

1. **Sprint 1**: Core architecture and 11-module scaffolding (Foundation)
   - Base classes for all 65+ planned classes
   - System registry and basic communication
   - Design Cohesion validation framework implementation
2. **Sprint 2-3**: System Integration and Movement Foundation
   - Player movement systems emphasizing responsiveness
   - Basic physics optimized for gameplay feel
   - Input handling with buffering for fluid control
3. **Sprint 4-6**: Combat Integration and Ability Framework
   - Combat systems that enhance rather than interrupt movement
   - Ability framework supporting progressive mastery
   - Performance optimization for smooth gameplay
4. **Sprint 7+**: Advanced Features and Polish
   - World-specific mechanics integration
   - Advanced ability combinations
   - Final optimization and accessibility features

### Design Cohesion Validation Checkpoints

**Fluid & Expressive Movement Validation:**

- Input lag measurement: Target <2 frames for all player actions
- Movement transition smoothness verification
- Physics consistency testing across platforms
- Ability combo responsiveness validation

**Engaging & Dynamic Combat Validation:**

- Combat-movement integration testing
- Multiple approach validation for encounters
- Feedback clarity assessment (audio/visual)
- Damage calculation fairness verification

**Progressive Mastery Validation:**

- Ability complexity growth assessment
- Player skill expression metrics
- Learning curve progression testing
- Consistent growth pattern validation

### Design Patterns Used

- **Component Pattern**: For game entity composition supporting modularity
- **Observer Pattern**: For event handling enabling loose coupling
- **Strategy Pattern**: For swappable system behaviors supporting different play styles
- **Factory Pattern**: For component creation enabling consistent initialization
- **Coordinator Pattern**: For physics-movement system communication (IPhysicsCoordinator)
- **Request-Response Pattern**: For safe cross-system communication without tight coupling

### Architecture Principles Supporting Design Cohesion

- **Responsiveness First**: All systems prioritize immediate feedback over complex simulation
- **Composable Design**: Systems built to work together seamlessly (movement + combat)
- **Progressive Complexity**: Architecture supports natural growth in player capabilities
- **Clear Interfaces**: Well-defined boundaries between systems for maintainability
- **Single Source of Truth**: PhysicsSystem owns all position updates to prevent conflicts
- **Request-Based Communication**: Systems coordinate through formal interfaces rather than direct access

### Physics-Movement Integration Implementation Notes

#### Critical Success Factors for Refactor

1. **System Boundary Enforcement**: Strict adherence to ownership rules prevents conflicts
2. **Accumulation Prevention**: Automatic limits and decay prevent physics value runaway
3. **State Synchronization**: Clear timing rules ensure consistent system state
4. **Error Recovery**: Robust error handling maintains system stability
5. **Performance Preservation**: No computational overhead from coordination patterns

#### Integration Validation Checkpoints

```dart
// Validation functions for integration health
class IntegrationValidator {
  // Verify no direct position access outside PhysicsSystem
  static bool validatePositionOwnership();

  // Check for physics value accumulation
  static bool checkAccumulationLimits(PhysicsState state);

  // Verify system execution order compliance
  static bool validateExecutionOrder();

  // Ensure request-response timing requirements
  static bool validateResponseTiming();
}
```

#### Performance Monitoring

```dart
// Monitor integration performance
class PhysicsIntegrationMetrics {
  // Track request-response latency
  Duration requestProcessingTime;

  // Monitor accumulation prevention effectiveness
  int accumulationPreventionCount;

  // System execution timing validation
  Map<String, Duration> systemExecutionTimes;

  // Frame timing compliance
  bool framingTimingCompliant;
}
```

## 11. Future Considerations

### Scalability

- Plugin architecture for modding support
- Network multiplayer foundation
- Cross-platform optimization

### Maintainability

- Clear separation of concerns
- Well-defined interfaces
- Comprehensive documentation

## Related Design Documents

- See [Architecture Overview](../Architecture.md) for high-level system design
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for gameplay systems integration
- See [Code Style Guide](../../05_Style_Guides/CodeStyle.md) for implementation standards
- See [TDD Overview](README.md) for all technical system details
- See [PhysicsSystem TDD](PhysicsSystem.TDD.md) for detailed physics system specification
- See [MovementSystem TDD](MovementSystem.TDD.md) for movement system integration patterns
- See [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) for refactor strategy
- See [Physics-Movement Refactor Task Tracker](../../04_Project_Management/Physics-movement-refactor-task-tracker.md) for implementation progress

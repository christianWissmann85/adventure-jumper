# Physics-Movement Refactor: Task-to-Code Mapping

## 📋 Document Overview

This document provides a comprehensive mapping between each technical task in the [Physics-Movement Refactor Task Tracker](Physics-movement-refactor-task-tracker.md) and the specific code files, modules, and documentation that need to be modified. This serves as the implementation blueprint for developers.

**Document Status**: 🟢 COMPLETE  
**Last Updated**: June 2, 2025  
**Version**: v1.0.0

## 🎯 Mapping Purpose

1. **Clear Implementation Path**: Map each granular task to specific code locations
2. **Impact Assessment**: Understand which files are affected by each change
3. **Dependency Tracking**: Identify code dependencies between tasks
4. **Test Coverage**: Map tasks to their required test files
5. **Documentation Updates**: Link code changes to documentation requirements

---

## 📁 File Categories Overview

### **Core Systems** (Primary Refactor Targets)

- `lib/src/systems/physics_system.dart` - 925 lines, primary physics simulation
- `lib/src/systems/movement_system.dart` - 72 lines, movement processing
- `lib/src/systems/input_system.dart` - Input handling and processing
- `lib/src/systems/base_system.dart` - Base system architecture
- `lib/src/systems/system.dart` - System interface definitions

### **Critical Components** (Integration Points)

- `lib/src/components/physics_component.dart` - Physics state data
- `lib/src/components/transform_component.dart` - Position/rotation data
- `lib/src/components/input_component.dart` - Input state management
- `lib/src/components/collision_component.dart` - Collision detection

### **Player Integration** (Affected by Refactor)

- `lib/src/player/player.dart` - Main player entity
- `lib/src/player/player_controller.dart` - Player control logic
- `lib/src/player/player_animator.dart` - Animation coordination
- `lib/src/entities/entity.dart` - Base entity system

### **Test Files** (Validation & Regression)

- `test/physics_enhancement_test.dart` - Physics system validation
- `test/movement_polish_test.dart` - Movement system testing
- `test/t2_19_*.dart` - Live test environment validations
- `test/system_integration_test.dart` - Cross-system integration

### **Documentation** (Technical Specifications)

- `docs/02_Technical_Design/TDD/PhysicsSystem.TDD.md` - Physics system spec
- `docs/02_Technical_Design/TDD/MovementSystem.TDD.md` - Movement system spec
- `docs/02_Technical_Design/TDD/SystemArchitecture.TDD.md` - Architecture patterns

---

## 🔍 Phase 1: Documentation & Design - Task Mappings

### ✅ v0.1.0.1 - Critical TDD Creation (COMPLETED)

#### PHY-1.1.1: Create PhysicsSystem.TDD.md ✅

**Status**: COMPLETED

```
📄 Documentation Files:
├── docs/02_Technical_Design/TDD/PhysicsSystem.TDD.md [CREATED]

📋 Content Areas:
├── Physics simulation algorithms and ownership patterns
├── Component lifecycle and synchronization requirements
├── Performance monitoring and validation framework
├── Integration patterns with movement, collision, input systems
└── State reset procedures to prevent physics degradation
```

#### PHY-1.1.2: Create MovementSystem.TDD.md ✅

**Status**: COMPLETED

```
📄 Documentation Files:
├── docs/02_Technical_Design/TDD/MovementSystem.TDD.md [CREATED]

📋 Content Areas:
├── Movement-physics integration coordination patterns
├── Position update ownership clarification (coordinate WITH physics)
├── State synchronization procedures between movement and physics
├── Movement constraint management and validation
└── Request-response model for movement coordination
```

### 🟡 v0.1.0.2 - Architecture Enhancement (IN PROGRESS)

#### PHY-1.2: Update SystemArchitecture.TDD.md

```
📄 Primary Files:
├── docs/02_Technical_Design/TDD/SystemArchitecture.TDD.md [UPDATE REQUIRED]

🔧 Required Changes:
├── PHY-1.2.1: Add physics-movement coordination patterns
│   ├── Define IPhysicsCoordinator interface specification
│   ├── Document request/response protocols between systems
│   └── Specify state synchronization rules and timing
├── PHY-1.2.2: Document system execution order
│   ├── Input → Movement → Physics → Collision sequence
│   ├── Frame timing considerations and budget allocation
│   └── System priority definitions and conflict resolution
└── PHY-1.2.3: Specify component ownership rules
    ├── Position update ownership (PhysicsSystem exclusive)
    ├── Velocity modification permissions and constraints
    └── State reset responsibilities and procedures

📚 Reference Files:
├── docs/02_Technical_Design/TDD/PhysicsSystem.TDD.md [reference]
├── docs/02_Technical_Design/TDD/MovementSystem.TDD.md [reference]
└── docs/02_Technical_Design/SystemsReference.md [update]
```

#### PHY-1.3: Create System Integration Guidelines

```
📄 New Files to Create:
├── docs/02_Technical_Design/TDD/SystemIntegration.TDD.md [CREATE]

🔧 Content Structure:
├── PHY-1.3.1: Request/response protocols
│   ├── MovementRequest data structure definition
│   ├── Response handling patterns and error codes
│   └── Error recovery procedures and fallback mechanisms
├── PHY-1.3.2: State synchronization procedures
│   ├── Component update sequence and timing
│   ├── Transform synchronization between physics and entities
│   └── Physics state consistency validation
├── PHY-1.3.3: Error handling patterns
│   ├── Invalid state detection algorithms
│   ├── Recovery mechanisms and automatic correction
│   └── Debug logging standards and error reporting
└── PHY-1.3.4: Performance requirements
    ├── Frame time budgets per system (16.67ms target)
    ├── Memory allocation limits and pooling strategies
    └── Update frequency targets and optimization guidelines

📚 Integration Points:
├── lib/src/systems/physics_system.dart [lines 100-200, interface methods]
├── lib/src/systems/movement_system.dart [lines 20-50, coordination logic]
└── lib/src/systems/base_system.dart [communication patterns]
```

### 🔴 v0.1.0.3 - Dependency Analysis (PENDING)

#### PHY-1.4: Review and Update Dependent TDDs

```
📄 Files Requiring Updates:

├── PHY-1.4.1: PlayerCharacter.TDD.md Updates
│   📄 docs/02_Technical_Design/TDD/PlayerCharacter.TDD.md
│   🔧 Changes Required:
│   ├── Movement request integration patterns
│   ├── Physics state management during player lifecycle
│   ├── Respawn procedures with proper state reset
│   └── Player-specific physics configuration

├── PHY-1.4.2: CollisionSystem.TDD.md Updates
│   📄 docs/02_Technical_Design/TDD/CollisionSystem.TDD.md [CREATE if missing]
│   🔧 Changes Required:
│   ├── Physics system coordination and timing
│   ├── Collision event handling and response propagation
│   ├── State update timing and sequence
│   └── Integration with physics ownership model

├── PHY-1.4.3: InputSystem.TDD.md Updates
│   📄 docs/02_Technical_Design/TDD/InputSystem.TDD.md [CREATE if missing]
│   🔧 Changes Required:
│   ├── Movement system integration patterns
│   ├── Input state management and buffering
│   ├── Action mapping updates for movement requests
│   └── Input validation and constraint checking

└── PHY-1.4.4: EntityComponent.TDD.md Updates
    📄 docs/02_Technical_Design/TDD/EntityComponent.TDD.md [CREATE if missing]
    🔧 Changes Required:
    ├── Component lifecycle changes and ownership
    ├── Physics integration patterns per component type
    ├── State synchronization requirements
    └── Component communication protocols

📚 Code References for Updates:
├── lib/src/player/player_controller.dart [input-movement integration]
├── lib/src/components/collision_component.dart [collision handling]
├── lib/src/systems/input_system.dart [input processing]
└── lib/src/entities/entity.dart [component lifecycle]
```

#### PHY-1.5: Create Detailed Implementation Plan

```
📄 New Files to Create:
├── docs/04_Project_Management/Physics-Refactor-Implementation-Plan.md [CREATE]

🔧 Content Structure:
├── PHY-1.5.1: Code modification checklist
│   ├── List all 23 files requiring changes (mapped below)
│   ├── Modification order based on dependencies
│   └── Test requirements per file change
├── PHY-1.5.2: Migration strategy
│   ├── Feature flag implementation in systems
│   ├── Gradual rollout plan (systems → components → entities)
│   └── Compatibility maintenance during transition
├── PHY-1.5.3: Rollback procedures
│   ├── Git checkpoint strategy per microversion
│   ├── Rollback decision criteria and triggers
│   └── Recovery time objectives and procedures
└── PHY-1.5.4: Test requirements
    ├── Unit test coverage targets (>90% for modified files)
    ├── Integration test scenarios and automation
    └── Performance benchmarks and validation criteria

📊 Files Requiring Changes (Complete List):
Systems (5 files):
├── lib/src/systems/physics_system.dart [MAJOR REFACTOR]
├── lib/src/systems/movement_system.dart [MAJOR REFACTOR]
├── lib/src/systems/input_system.dart [MODERATE UPDATE]
├── lib/src/systems/base_system.dart [INTERFACE UPDATES]
└── lib/src/systems/system.dart [INTERFACE ADDITIONS]

Components (4 files):
├── lib/src/components/physics_component.dart [MODERATE UPDATE]
├── lib/src/components/transform_component.dart [MINOR UPDATE]
├── lib/src/components/input_component.dart [MINOR UPDATE]
└── lib/src/components/collision_component.dart [MINOR UPDATE]

Player/Entities (4 files):
├── lib/src/player/player.dart [MODERATE UPDATE]
├── lib/src/player/player_controller.dart [MAJOR REFACTOR]
├── lib/src/player/player_animator.dart [MINOR UPDATE]
└── lib/src/entities/entity.dart [MINOR UPDATE]

Tests (10 files):
├── test/physics_enhancement_test.dart [MAJOR UPDATE]
├── test/movement_polish_test.dart [MAJOR UPDATE]
├── test/t2_19_*.dart [VALIDATION UPDATES]
├── test/system_integration_test.dart [NEW TESTS]
└── [Additional test files as needed]
```

---

## 🔍 Phase 2: Core System Refactor - Task Mappings

### 🔴 v0.2.0.1 - Physics System Analysis (PENDING)

#### PHY-2.1: Comprehensive PhysicsSystem Analysis

```
📄 Primary Analysis Target:
├── lib/src/systems/physics_system.dart [925 lines total]

🔧 Analysis Tasks:
├── PHY-2.1.1: Map all position update locations
│   🎯 Target Code Sections:
│   ├── Lines 200-400: Entity position updates and velocity integration
│   ├── Lines 500-700: Collision response and position correction
│   ├── Lines 800-925: Frame update and transform synchronization
│   📋 Deliverables:
│   ├── Position update method inventory
│   ├── Call graph of position modifications
│   └── Dependency map of affected methods
│
├── PHY-2.1.2: Identify integration points
│   🎯 Target Integration Areas:
│   ├── MovementSystem connections [grep "movement" in physics_system.dart]
│   ├── TransformComponent updates [search for "transform" updates]
│   ├── Entity position synchronization [entity.position assignments]
│   📋 Deliverables:
│   ├── Integration point documentation
│   ├── Data flow diagrams
│   └── Coupling analysis report
│
├── PHY-2.1.3: Document accumulation issues
│   🎯 Problem Areas to Analyze:
│   ├── Friction accumulation patterns [search for friction calculations]
│   ├── Contact point buildup [collision contact management]
│   ├── State persistence problems [state reset/cleanup methods]
│   📋 Deliverables:
│   ├── Accumulation pattern documentation
│   ├── Memory leak analysis
│   └── State lifecycle audit
│
└── PHY-2.1.4: Create refactor impact assessment
    📋 Deliverables:
    ├── Affected systems list with impact scores
    ├── Risk analysis matrix
    └── Performance implications assessment

📄 Output Documents:
├── docs/04_Project_Management/PhysicsSystem-Analysis-Report.md [CREATE]
├── docs/04_Project_Management/Refactor-Impact-Assessment.md [CREATE]

🔗 Related Files for Analysis:
├── lib/src/components/physics_component.dart [state structure]
├── lib/src/systems/movement_system.dart [integration patterns]
├── test/physics_enhancement_test.dart [current test coverage]
└── test/t2_19_simplified_live_test.dart [degradation test cases]
```

### 🔴 v0.2.0.2 - Coordination Interface Design (PENDING)

#### PHY-2.2: Create IPhysicsCoordinator Interface

```
📄 New Files to Create:
├── lib/src/systems/interfaces/physics_coordinator.dart [CREATE]

🔧 Interface Implementation:
├── PHY-2.2.1: Design movement request methods
│   💻 Code Structure:
│   abstract class IPhysicsCoordinator {
│     Future<MovementResponse> requestMovement(String entityId, Vector2 direction, double speed);
│     Future<JumpResponse> requestJump(String entityId, double force);
│     Future<void> requestStop(String entityId);
│   }
│   🎯 Implementation Location:
│   ├── lib/src/systems/physics_system.dart [implement interface]
│   └── lib/src/systems/movement_system.dart [use interface]
│
├── PHY-2.2.2: Implement state query methods
│   💻 Code Structure:
│   bool isGrounded(String entityId);
│   Vector2 getVelocity(String entityId);
│   Vector2 getPosition(String entityId);
│   PhysicsState getPhysicsState(String entityId);
│   🎯 Implementation Location:
│   ├── lib/src/systems/physics_system.dart [lines 100-150, add methods]
│
├── PHY-2.2.3: Add state management methods
│   💻 Code Structure:
│   void resetPhysicsState(String entityId);
│   void clearAccumulatedForces(String entityId);
│   void validateStateConsistency(String entityId);
│   🎯 Implementation Location:
│   ├── lib/src/systems/physics_system.dart [lines 50-100, state management]
│
└── PHY-2.2.4: Create unit tests for interface
    📄 Test Files:
    ├── test/systems/physics_coordinator_test.dart [CREATE]
    └── test/systems/physics_coordinator_integration_test.dart [CREATE]

📚 Supporting Files:
├── lib/src/systems/interfaces/movement_request.dart [CREATE - data structures]
├── lib/src/systems/interfaces/movement_response.dart [CREATE - response types]
└── lib/src/systems/interfaces/physics_state.dart [CREATE - state definitions]
```

#### PHY-2.3: Implement MovementRequest System

```
📄 New Files to Create:
├── lib/src/systems/request_processing/movement_request_processor.dart [CREATE]
├── lib/src/systems/request_processing/request_queue.dart [CREATE]

🔧 Implementation Tasks:
├── PHY-2.3.1: Create MovementRequest data structure
│   📄 lib/src/systems/interfaces/movement_request.dart
│   💻 Code Structure:
│   class MovementRequest {
│     final String entityId;
│     final Vector2 direction;
│     final double speed;
│     final MovementType type;
│     final DateTime timestamp;
│     final RequestPriority priority;
│   }
│
├── PHY-2.3.2: Implement request validation
│   📄 lib/src/systems/request_processing/request_validator.dart [CREATE]
│   💻 Code Structure:
│   class RequestValidator {
│     ValidationResult validateMovementRequest(MovementRequest request);
│     bool isValidDirection(Vector2 direction);
│     bool isValidSpeed(double speed, String entityId);
│   }
│
├── PHY-2.3.3: Add request queuing system
│   📄 lib/src/systems/request_processing/request_queue.dart
│   💻 Code Structure:
│   class RequestQueue {
│     void enqueue(MovementRequest request);
│     MovementRequest? dequeue();
│     List<MovementRequest> getRequestsForEntity(String entityId);
│   }
│   🎯 Integration Location:
│   ├── lib/src/systems/physics_system.dart [lines 50-80, add queue processing]
│
└── PHY-2.3.4: Create request processing pipeline
    📄 lib/src/systems/request_processing/movement_request_processor.dart
    💻 Code Structure:
    class MovementRequestProcessor {
      Future<MovementResponse> processRequest(MovementRequest request);
      void processQueuedRequests();
      void handleRequestConflicts(List<MovementRequest> conflicts);
    }
    🎯 Integration Location:
    ├── lib/src/systems/physics_system.dart [lines 150-200, add processor calls]

📄 Test Files:
├── test/systems/movement_request_test.dart [CREATE]
├── test/systems/request_queue_test.dart [CREATE]
└── test/systems/request_processor_test.dart [CREATE]
```

### 🔴 v0.2.0.3 - Physics System Refactor (PENDING)

#### PHY-2.4: Implement PhysicsSystem Position Ownership

```
📄 Primary Modification Target:
├── lib/src/systems/physics_system.dart [MAJOR REFACTOR - 925 lines]

🔧 Refactoring Tasks:
├── PHY-2.4.1: Centralize position update method
│   🎯 Target Code Areas:
│   ├── Lines 200-250: Current position update scattered calls
│   ├── Lines 300-350: Velocity integration methods
│   ├── Lines 400-450: Entity position synchronization
│   💻 New Code Structure:
│   void _updateEntityPosition(String entityId, Vector2 newPosition) {
│     // Single source of truth for position updates
│     // Update entity.position
│     // Sync TransformComponent
│     // Emit position change events
│     // Validate state consistency
│   }
│   📋 Changes Required:
│   ├── Replace all direct entity.position assignments
│   ├── Channel all position changes through central method
│   └── Add position change validation and logging
│
├── PHY-2.4.2: Remove external position modifications
│   🎯 Files to Audit and Modify:
│   ├── lib/src/systems/movement_system.dart [lines 30-50, remove position updates]
│   ├── lib/src/player/player_controller.dart [remove direct position assignments]
│   ├── lib/src/entities/entity.dart [make position setter private/protected]
│   ├── lib/src/components/transform_component.dart [add position change events]
│   📋 Changes Required:
│   ├── Replace position assignments with physics requests
│   ├── Add validation for unauthorized position changes
│   └── Create migration path for existing code
│
├── PHY-2.4.3: Implement transform synchronization
│   🎯 Target Integration:
│   ├── lib/src/components/transform_component.dart [add sync methods]
│   ├── lib/src/systems/physics_system.dart [lines 100-150, add sync calls]
│   💻 Code Structure:
│   void _synchronizeTransform(String entityId, Vector2 newPosition) {
│     final entity = entityManager.getEntity(entityId);
│     final transform = entity.getComponent<TransformComponent>();
│     transform.position = newPosition;
│     transform.markDirty();
│     _notifyPositionChange(entityId, newPosition);
│   }
│
├── PHY-2.4.4: Add position update events
│   📄 New Files:
│   ├── lib/src/events/position_change_event.dart [CREATE]
│   ├── lib/src/events/physics_event_bus.dart [CREATE]
│   💻 Event System:
│   class PositionChangeEvent {
│     final String entityId;
│     final Vector2 oldPosition;
│     final Vector2 newPosition;
│     final DateTime timestamp;
│   }
│   🎯 Integration Points:
│   ├── lib/src/systems/physics_system.dart [emit events on position change]
│   ├── lib/src/systems/render_system.dart [listen for position events]
│   └── lib/src/systems/audio_system.dart [spatial audio updates]
│
└── PHY-2.4.5: Create comprehensive tests
    📄 Test Files:
    ├── test/systems/physics_position_ownership_test.dart [CREATE]
    ├── test/systems/transform_synchronization_test.dart [CREATE]
    ├── test/integration/position_update_integration_test.dart [CREATE]
    └── test/performance/position_update_performance_test.dart [CREATE]

🔗 Affected Integration Points:
├── lib/src/systems/render_system.dart [listen for position events]
├── lib/src/systems/collision_system.dart [coordinate with physics updates]
├── lib/src/systems/animation_system.dart [sync with position changes]
└── lib/src/world/portal.dart [physics-based teleportation]
```

#### PHY-2.5: Add Physics State Reset Procedures

```
📄 Primary Modification Target:
├── lib/src/systems/physics_system.dart [lines 50-100, state management area]

🔧 Implementation Tasks:
├── PHY-2.5.1: Implement resetPhysicsState method
│   💻 Code Structure:
│   void resetPhysicsState(String entityId) {
│     final physicsComponent = getPhysicsComponent(entityId);
│     physicsComponent.velocity = Vector2.zero();
│     physicsComponent.acceleration = Vector2.zero();
│     physicsComponent.angularVelocity = 0.0;
│     physicsComponent.contactPoints.clear();
│     physicsComponent.appliedForces.clear();
│     _clearAccumulatedValues(entityId);
│     _validateStateReset(entityId);
│   }
│   🎯 Integration Points:
│   ├── Player respawn procedures
│   ├── Level transition handling
│   └── Debug reset commands
│
├── PHY-2.5.2: Add force accumulation clearing
│   💻 Code Structure:
│   void _clearAccumulatedValues(String entityId) {
│     final physicsComponent = getPhysicsComponent(entityId);
│     physicsComponent.frictionAccumulator = 0.0;
│     physicsComponent.gravityAccumulator = Vector2.zero();
│     physicsComponent.impulseAccumulator = Vector2.zero();
│     physicsComponent.rotationalDamping = 1.0;
│   }
│   🎯 Critical for Issue Resolution:
│   ├── Prevents physics degradation over time
│   ├── Resets accumulated friction causing slowdown
│   └── Clears accumulated contact forces
│
├── PHY-2.5.3: Reset contact points properly
│   💻 Code Structure:
│   void _resetContactPoints(String entityId) {
│     final physicsComponent = getPhysicsComponent(entityId);
│     physicsComponent.contactPoints.clear();
│     physicsComponent.contactNormals.clear();
│     physicsComponent.contactPenetrations.clear();
│     physicsComponent.isGrounded = false;
│     _recalculateGroundState(entityId);
│   }
│
└── PHY-2.5.4: Test state reset completeness
    📄 Test Files:
    ├── test/systems/physics_state_reset_test.dart [CREATE]
    ├── test/integration/respawn_state_reset_test.dart [CREATE]
    └── test/regression/physics_degradation_prevention_test.dart [CREATE]

🔗 Integration Requirements:
├── lib/src/player/player.dart [call resetPhysicsState on respawn]
├── lib/src/systems/movement_system.dart [coordinate state resets]
├── lib/src/world/level_manager.dart [reset on level transitions]
└── test/t2_19_*.dart [validate degradation fix]
```

### 🔴 v0.2.0.4 - Movement System Refactor (PENDING)

#### PHY-2.6: Refactor MovementSystem to Request Model

```
📄 Primary Modification Target:
├── lib/src/systems/movement_system.dart [MAJOR REFACTOR - 72 lines total]

🔧 Refactoring Tasks:
├── PHY-2.6.1: Remove direct position updates
│   🎯 Current Code to Replace (lines 30-50):
│   // OLD CODE - Direct position manipulation
│   entity.position += movement;
│   entity.getComponent<TransformComponent>().position = entity.position;
│
│   💻 New Code Structure:
│   // NEW CODE - Request-based movement
│   final request = MovementRequest(
│     entityId: entity.id,
│     direction: inputDirection,
│     speed: movementSpeed,
│     type: MovementType.walk
│   );
│   final response = await physicsCoordinator.requestMovement(request);
│   _handleMovementResponse(response);
│
├── PHY-2.6.2: Implement physics request calls
│   💻 Code Structure:
│   class MovementSystem extends BaseSystem {
│     late IPhysicsCoordinator physicsCoordinator;
│
│     void update(double deltaTime) {
│       for (final entity in movingEntities) {
│         final input = entity.getComponent<InputComponent>();
│         if (input.hasMovementInput) {
│           _processMovementInput(entity, input, deltaTime);
│         }
│       }
│     }
│
│     Future<void> _processMovementInput(Entity entity, InputComponent input, double deltaTime) {
│       final direction = _calculateMovementDirection(input);
│       final speed = _calculateMovementSpeed(entity, input);
│       return physicsCoordinator.requestMovement(entity.id, direction, speed);
│     }
│   }
│
├── PHY-2.6.3: Update movement processing logic
│   🎯 Areas to Refactor:
│   ├── Lines 10-30: Input processing and direction calculation
│   ├── Lines 35-55: Speed calculation and movement application
│   ├── Lines 60-72: State updates and event handling
│   💻 New Logic Flow:
│   1. Process input to determine movement intent
│   2. Calculate desired movement parameters
│   3. Submit movement request to physics system
│   4. Handle response and update movement state
│   5. Trigger movement events and animations
│
├── PHY-2.6.4: Maintain movement feel/responsiveness
│   🎯 Critical Requirements:
│   ├── Preserve current movement responsiveness
│   ├── Maintain movement speed consistency
│   ├── Keep jump height and timing identical
│   ├── Preserve movement acceleration curves
│   💻 Implementation:
│   class MovementFeelPreserver {
│     double calculateResponseSpeed(MovementType type);
│     Vector2 applyMovementCurve(Vector2 baseMovement, double deltaTime);
│     void validateMovementConsistency(MovementResponse response);
│   }
│
└── PHY-2.6.5: Create integration tests
    📄 Test Files:
    ├── test/systems/movement_system_refactor_test.dart [CREATE]
    ├── test/integration/movement_physics_coordination_test.dart [CREATE]
    ├── test/regression/movement_feel_preservation_test.dart [CREATE]
    └── test/performance/movement_request_performance_test.dart [CREATE]

🔗 Integration Points:
├── lib/src/systems/input_system.dart [coordinate input handling]
├── lib/src/systems/animation_system.dart [movement animation triggers]
├── lib/src/player/player_controller.dart [player-specific movement logic]
└── lib/src/systems/audio_system.dart [movement sound effects]
```

#### PHY-2.7: Implement Accumulation Prevention

```
📄 Primary Modification Targets:
├── lib/src/systems/physics_system.dart [lines 500-600, accumulation areas]
├── lib/src/components/physics_component.dart [add accumulation tracking]

🔧 Implementation Tasks:
├── PHY-2.7.1: Add maximum value constraints
│   💻 Code Structure in PhysicsComponent:
│   class PhysicsComponent extends Component {
│     static const double MAX_VELOCITY = 1000.0;
│     static const double MAX_ACCELERATION = 500.0;
│     static const double MAX_FRICTION_ACCUMULATION = 10.0;
│
│     Vector2 _velocity = Vector2.zero();
│     double _frictionAccumulator = 0.0;
│
│     set velocity(Vector2 value) {
│       _velocity = value.clampLength(0.0, MAX_VELOCITY);
│     }
│
│     void addFriction(double friction) {
│       _frictionAccumulator += friction;
│       if (_frictionAccumulator > MAX_FRICTION_ACCUMULATION) {
│         _frictionAccumulator = MAX_FRICTION_ACCUMULATION;
│         _triggerAccumulationWarning();
│       }
│     }
│   }
│   🎯 Integration in PhysicsSystem:
│   ├── Add validation calls before physics updates
│   ├── Implement constraint enforcement in update loop
│   └── Add accumulation monitoring and alerting
│
├── PHY-2.7.2: Implement contact point cleanup
│   💻 Code Structure:
│   class ContactPointManager {
│     static const int MAX_CONTACT_POINTS = 8;
│     static const double CONTACT_LIFETIME = 0.1; // seconds
│
│     void cleanupOldContacts(String entityId, double currentTime) {
│       final physicsComponent = getPhysicsComponent(entityId);
│       physicsComponent.contactPoints.removeWhere((contact) =>
│         currentTime - contact.timestamp > CONTACT_LIFETIME);
│
│       if (physicsComponent.contactPoints.length > MAX_CONTACT_POINTS) {
│         _trimContactPoints(physicsComponent);
│       }
│     }
│
│     void _trimContactPoints(PhysicsComponent component) {
│       component.contactPoints.sort((a, b) =>
│         b.timestamp.compareTo(a.timestamp));
│       component.contactPoints = component.contactPoints
│         .take(MAX_CONTACT_POINTS).toList();
│     }
│   }
│   🎯 Integration Location:
│   ├── lib/src/systems/physics_system.dart [lines 600-650, contact processing]
│
├── PHY-2.7.3: Add velocity drift prevention
│   💻 Code Structure:
│   class VelocityDriftPrevention {
│     static const double VELOCITY_THRESHOLD = 0.01;
│     static const double DRIFT_CORRECTION_FACTOR = 0.98;
│
│     Vector2 preventDrift(Vector2 velocity, bool isGrounded) {
│       if (isGrounded && velocity.length < VELOCITY_THRESHOLD) {
│         return Vector2.zero(); // Stop micro-movements
│       }
│
│       if (velocity.length > 0.0) {
│         velocity *= DRIFT_CORRECTION_FACTOR; // Gradual dampening
│       }
│
│       return velocity;
│     }
│   }
│   🎯 Integration Location:
│   ├── lib/src/systems/physics_system.dart [lines 300-350, velocity updates]
│
└── PHY-2.7.4: Create long-running tests
    📄 Test Files:
    ├── test/regression/physics_accumulation_prevention_test.dart [CREATE]
    ├── test/stress/long_running_physics_stability_test.dart [CREATE]
    ├── test/performance/accumulation_prevention_performance_test.dart [CREATE]
    └── test/integration/contact_cleanup_integration_test.dart [CREATE]

    💻 Critical Test Scenarios:
    ├── Run physics simulation for 10+ minutes continuous gameplay
    ├── Monitor friction accumulation over 1000+ collisions
    ├── Validate contact point memory doesn't grow indefinitely
    └── Test velocity stability during extended idle periods

🔗 Monitoring Integration:
├── lib/src/debug/physics_monitor.dart [CREATE - accumulation tracking]
├── lib/src/systems/debug_system.dart [add accumulation alerts]
└── test/t2_19_simplified_live_test.dart [validate fix effectiveness]
```

---

## 🔍 Phase 3: Component Updates - Task Mappings

### 🔴 v0.3.0.1 - Player Component Updates (PENDING)

#### PHY-3.1: Update PlayerController for New Patterns

```
📄 Primary Modification Target:
├── lib/src/player/player_controller.dart [MAJOR REFACTOR]

🔧 Refactoring Tasks:
├── PHY-3.1.1: Update input handling to use requests
│   💻 Current Code Pattern (lines 50-80):
│   // OLD: Direct position manipulation
│   if (input.left) player.position.x -= speed * deltaTime;
│   if (input.right) player.position.x += speed * deltaTime;
│   if (input.jump && isGrounded) player.velocity.y = jumpForce;
│
│   💻 New Code Pattern:
│   if (input.left || input.right) {
│     final direction = Vector2(input.right ? 1 : -1, 0);
│     await movementSystem.requestMovement(player.id, direction, speed);
│   }
│   if (input.jump && await physicsSystem.isGrounded(player.id)) {
│     await physicsSystem.requestJump(player.id, jumpForce);
│   }
│
└── PHY-3.1.2: Implement respawn state reset
    💻 Code Structure:
    void respawnPlayer(Vector2 spawnPosition) {
      // Reset physics state to prevent degradation
      physicsSystem.resetPhysicsState(player.id);

      // Request teleportation to spawn point
      physicsSystem.requestTeleport(player.id, spawnPosition);

      // Reset player-specific state
      player.health = player.maxHealth;
      player.invulnerabilityTimer = 0.0;

      // Clear any pending movement requests
      movementSystem.clearPendingRequests(player.id);

      // Reset animation state
      playerAnimator.resetToIdle();
    }

🔗 Integration Requirements:
├── lib/src/systems/movement_system.dart [coordinate with player controller]
├── lib/src/systems/physics_system.dart [handle player-specific requests]
├── lib/src/player/player_animator.dart [sync with movement changes]
└── lib/src/player/player.dart [update respawn procedures]

📄 Test Files:
├── test/player/player_controller_refactor_test.dart [CREATE]
├── test/integration/player_respawn_physics_test.dart [CREATE]
└── test/regression/player_movement_feel_test.dart [CREATE]
```

---

## 📊 Complete File Modification Summary

### **Critical System Files** (Major Changes Required)

```
🔥 HIGH IMPACT (Major Refactor Required):
├── lib/src/systems/physics_system.dart [925 lines] - Complete ownership model refactor
├── lib/src/systems/movement_system.dart [72 lines] - Request-based architecture
├── lib/src/player/player_controller.dart - Input handling refactor
└── lib/src/components/physics_component.dart - State management updates

🟠 MODERATE IMPACT (Significant Updates):
├── lib/src/systems/input_system.dart - Movement integration updates
├── lib/src/systems/base_system.dart - Interface additions
├── lib/src/components/transform_component.dart - Synchronization logic
├── lib/src/player/player.dart - Respawn procedure updates
└── lib/src/entities/entity.dart - Position access control

🟡 LOW IMPACT (Minor Updates):
├── lib/src/systems/system.dart - Interface definitions
├── lib/src/components/input_component.dart - Request integration
├── lib/src/components/collision_component.dart - Physics coordination
├── lib/src/player/player_animator.dart - Movement sync updates
├── lib/src/systems/render_system.dart - Position event listening
├── lib/src/systems/audio_system.dart - Spatial updates
└── lib/src/systems/animation_system.dart - Position change handling
```

### **New Files to Create** (17 New Files)

```
📁 lib/src/systems/interfaces/
├── physics_coordinator.dart - IPhysicsCoordinator interface
├── movement_request.dart - Request data structures
├── movement_response.dart - Response type definitions
└── physics_state.dart - State type definitions

📁 lib/src/systems/request_processing/
├── movement_request_processor.dart - Request processing logic
├── request_queue.dart - Request queuing system
└── request_validator.dart - Request validation

📁 lib/src/events/
├── position_change_event.dart - Position change notifications
└── physics_event_bus.dart - Physics event system

📁 lib/src/debug/
└── physics_monitor.dart - Accumulation monitoring

📁 docs/02_Technical_Design/TDD/
├── SystemIntegration.TDD.md - Integration guidelines
├── CollisionSystem.TDD.md - Collision system spec
├── InputSystem.TDD.md - Input system spec
└── EntityComponent.TDD.md - Component specifications

📁 docs/04_Project_Management/
├── PhysicsSystem-Analysis-Report.md - Analysis results
├── Refactor-Impact-Assessment.md - Impact analysis
└── Physics-Refactor-Implementation-Plan.md - Implementation plan
```

### **Test Files to Create/Update** (25+ Test Files)

```
📁 test/systems/
├── physics_coordinator_test.dart - Interface testing
├── movement_request_test.dart - Request system testing
├── physics_position_ownership_test.dart - Position ownership validation
├── movement_system_refactor_test.dart - Movement system testing
└── physics_state_reset_test.dart - State reset validation

📁 test/integration/
├── movement_physics_coordination_test.dart - Cross-system testing
├── position_update_integration_test.dart - Position sync testing
├── player_respawn_physics_test.dart - Respawn state testing
└── contact_cleanup_integration_test.dart - Contact management testing

📁 test/regression/
├── physics_degradation_prevention_test.dart - Degradation fix validation
├── movement_feel_preservation_test.dart - Movement feel testing
└── physics_accumulation_prevention_test.dart - Accumulation prevention

📁 test/performance/
├── position_update_performance_test.dart - Position update benchmarks
├── movement_request_performance_test.dart - Request system performance
└── accumulation_prevention_performance_test.dart - Prevention overhead

📁 test/stress/
└── long_running_physics_stability_test.dart - Extended runtime testing
```

---

## 🎯 Implementation Priority Order

### **Phase 1 Priority** (Complete Documentation Foundation)

1. **PHY-1.2**: Update SystemArchitecture.TDD.md
2. **PHY-1.3**: Create SystemIntegration.TDD.md
3. **PHY-1.4**: Update all dependent TDD documents
4. **PHY-1.5**: Create detailed implementation plan

### **Phase 2 Priority** (Core System Refactor)

1. **PHY-2.1**: Physics system analysis (critical for understanding)
2. **PHY-2.2**: IPhysicsCoordinator interface (foundation for requests)
3. **PHY-2.3**: MovementRequest system (request infrastructure)
4. **PHY-2.4**: Physics position ownership (core fix)
5. **PHY-2.5**: State reset procedures (degradation prevention)
6. **PHY-2.6**: Movement system refactor (integration)
7. **PHY-2.7**: Accumulation prevention (long-term stability)

### **Phase 3 Priority** (Integration & Validation)

1. **PHY-3.1**: Player controller updates
2. Comprehensive testing and validation
3. Performance optimization and monitoring

---

## 🚨 Critical Success Checkpoints

### **Checkpoint 1: Documentation Complete**

- [ ] All TDD documents created and updated
- [ ] Implementation plan approved by team
- [ ] Development environment prepared

### **Checkpoint 2: Interface Layer Complete**

- [ ] IPhysicsCoordinator interface implemented
- [ ] MovementRequest system functional
- [ ] Unit tests passing for all interfaces

### **Checkpoint 3: Core Refactor Complete**

- [ ] Physics system owns all position updates
- [ ] Movement system uses request-based model
- [ ] State reset procedures prevent accumulation
- [ ] Integration tests passing

### **Checkpoint 4: Player Integration Complete**

- [ ] Player controller refactored successfully
- [ ] Respawn procedures include state reset
- [ ] Movement feel preserved
- [ ] Regression tests confirm degradation fix

### **Final Validation: Physics Degradation Resolved**

- [ ] Extended gameplay testing (10+ minutes) shows no slowdown
- [ ] Physics values remain stable over time
- [ ] Movement responsiveness maintained
- [ ] No accumulation of friction or contact forces
- [ ] State reset completely clears all accumulated values

---

_This mapping document serves as the definitive implementation guide for resolving the physics degradation issue. Each task is precisely mapped to specific code locations, ensuring focused and effective development effort._

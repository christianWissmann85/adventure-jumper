# System Integration Guidelines - Technical Design Document

## 1. Overview

This document defines the comprehensive integration guidelines for the Adventure Jumper physics-movement system refactor. It establishes formal protocols, procedures, and patterns to ensure seamless communication between systems while preventing the physics degradation issues identified in the critical report.

> **Related Documents:**
>
> - [SystemArchitecture.TDD.md](SystemArchitecture.TDD.md) - Core architectural patterns
> - [PhysicsSystem.TDD.md](PhysicsSystem.TDD.md) - Physics system specification
> - [MovementSystem.TDD.md](MovementSystem.TDD.md) - Movement system integration
> - [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) - Refactor strategy
> - [Critical Report: Physics Movement System Degradation](../../07_Reports/Critical_Report_Physics_Movement_System_Degradation.md) - Root cause analysis

### Purpose

- Define request/response protocols for safe cross-system communication
- Establish state synchronization procedures preventing accumulation issues
- Specify error handling patterns for robust system integration
- Set performance requirements ensuring 60fps gameplay stability

### Scope

- Physics-Movement system coordination protocols
- State management and synchronization procedures
- Error detection, recovery, and logging patterns
- Performance monitoring and optimization guidelines
- Integration validation and testing procedures

## 2. Request/Response Protocols

### 2.1 MovementRequest Data Structure

```dart
// Primary data structure for movement coordination
class MovementRequest {
  final int entityId;
  final Vector2 direction;
  final double speed;
  final MovementType type;
  final double timestamp;
  final int frameNumber;
  final RequestPriority priority;

  MovementRequest({
    required this.entityId,
    required this.direction,
    required this.speed,
    required this.type,
    this.priority = RequestPriority.normal,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch.toDouble(),
       frameNumber = GameTime.currentFrame;

  // Validation ensures request integrity
  bool validate() {
    return entityId >= 0 &&
           speed >= 0.0 &&
           speed <= MovementConstants.MAX_SPEED &&
           direction.isFinite &&
           _isValidMovementType();
  }

  bool _isValidMovementType() {
    return type != MovementType.invalid &&
           type != MovementType.unknown;
  }
}

// Movement request types
enum MovementType {
  walk,
  run,
  jump,
  dash,
  stop,
  impulse,
  teleport,  // For respawn/level transitions only
  invalid,
  unknown
}

// Request priority for processing order
enum RequestPriority {
  critical,  // Respawn, teleport
  high,      // Jump, dash
  normal,    // Walk, run
  low        // Stop, idle
}
```

### 2.2 PhysicsResponse Data Structure

```dart
// Response structure for physics system feedback
class PhysicsResponse {
  final int entityId;
  final Vector2 actualVelocity;
  final Vector2 actualPosition;
  final bool grounded;
  final bool movementBlocked;
  final List<CollisionInfo> activeCollisions;
  final PhysicsState currentState;
  final double timestamp;
  final ResponseStatus status;

  PhysicsResponse({
    required this.entityId,
    required this.actualVelocity,
    required this.actualPosition,
    required this.grounded,
    required this.movementBlocked,
    required this.activeCollisions,
    required this.currentState,
    required this.status,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
}

// Response status codes
enum ResponseStatus {
  success,
  partialSuccess,  // Movement partially applied due to collision
  blocked,         // Movement completely blocked
  error,           // Processing error occurred
  timeout          // Request processing timeout
}
```

### 2.3 Request Processing Pipeline

```dart
// Request processing flow within PhysicsSystem
class PhysicsRequestProcessor {
  final Queue<MovementRequest> _requestQueue = Queue<MovementRequest>();
  final Map<int, PhysicsResponse> _lastResponses = <int, PhysicsResponse>{};

  // Process movement requests in priority order
  void processMovementRequests(double deltaTime) {
    // Sort by priority and timestamp
    final List<MovementRequest> sortedRequests = _sortRequestsByPriority();

    for (final MovementRequest request in sortedRequests) {
      if (!request.validate()) {
        _handleInvalidRequest(request);
        continue;
      }

      final PhysicsResponse response = _processRequest(request, deltaTime);
      _lastResponses[request.entityId] = response;

      // Notify relevant systems of response
      _notifyMovementSystem(response);
      _notifyCollisionSystem(response);
    }

    _requestQueue.clear();
  }

  List<MovementRequest> _sortRequestsByPriority() {
    final List<MovementRequest> requests = _requestQueue.toList();
    requests.sort((a, b) {
      // First by priority
      final int priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Then by timestamp for same priority
      return a.timestamp.compareTo(b.timestamp);
    });
    return requests;
  }
}
```

## 3. State Synchronization Procedures

### 3.1 Component Update Sequence

```dart
// Strict update sequence to prevent state desynchronization
class SystemUpdateOrchestrator {
  // Critical: Systems must update in this exact order
  static const List<SystemUpdateStep> UPDATE_SEQUENCE = [
    SystemUpdateStep.inputCapture,     // Frame: N
    SystemUpdateStep.movementRequest,  // Frame: N
    SystemUpdateStep.physicsProcess,   // Frame: N
    SystemUpdateStep.collisionDetect,  // Frame: N
    SystemUpdateStep.stateSync,        // Frame: N
    SystemUpdateStep.animation,        // Frame: N
    SystemUpdateStep.audio,            // Frame: N
    SystemUpdateStep.render,           // Frame: N
  ];

  void executeUpdateSequence(double deltaTime) {
    final FrameContext frameContext = FrameContext.current;

    for (final SystemUpdateStep step in UPDATE_SEQUENCE) {
      final Stopwatch stepTimer = Stopwatch()..start();

      try {
        _executeStep(step, deltaTime, frameContext);
      } catch (Exception e) {
        _handleStepError(step, e, frameContext);
      } finally {
        stepTimer.stop();
        _recordStepTiming(step, stepTimer.elapsed);
      }
    }

    _validateFrameConsistency(frameContext);
  }
}
```

### 3.2 Transform Synchronization

```dart
// Ensure position/velocity consistency across systems
class TransformSynchronizer {
  // Synchronize transform components after physics update
  void synchronizeTransforms(List<Entity> entities) {
    for (final Entity entity in entities) {
      final PhysicsComponent? physics = entity.getComponent<PhysicsComponent>();
      final TransformComponent? transform = entity.getComponent<TransformComponent>();

      if (physics == null || transform == null) continue;

      // Physics system is authoritative for position
      if (!_positionsMatch(physics.position, transform.position)) {
        transform.position = physics.position.clone();
        _logTransformSync(entity.id, 'position', physics.position);
      }

      // Validate velocity consistency
      if (!_velocitiesMatch(physics.velocity, transform.velocity)) {
        transform.velocity = physics.velocity.clone();
        _logTransformSync(entity.id, 'velocity', physics.velocity);
      }
    }
  }

  bool _positionsMatch(Vector2 a, Vector2 b) {
    return (a - b).length < TransformConstants.POSITION_TOLERANCE;
  }

  bool _velocitiesMatch(Vector2 a, Vector2 b) {
    return (a - b).length < TransformConstants.VELOCITY_TOLERANCE;
  }
}
```

### 3.3 Physics State Consistency

```dart
// Prevent physics accumulation and maintain state integrity
class PhysicsStateManager {
  // Validate and correct physics state each frame
  void validatePhysicsState(PhysicsComponent physics) {
    // Check for accumulation
    if (_detectAccumulation(physics)) {
      _preventAccumulation(physics);
      _logAccumulationPrevention(physics.entityId);
    }

    // Validate bounds
    if (!_withinBounds(physics)) {
      _correctBounds(physics);
      _logBoundsCorrection(physics.entityId);
    }

    // Check for NaN/infinite values
    if (!_isValidState(physics)) {
      _resetToSafeState(physics);
      _logStateReset(physics.entityId);
    }
  }

  bool _detectAccumulation(PhysicsComponent physics) {
    return physics.velocity.length > PhysicsConstants.MAX_SAFE_VELOCITY ||
           physics.accumulatedForces.length > PhysicsConstants.MAX_SAFE_FORCE;
  }

  void _preventAccumulation(PhysicsComponent physics) {
    physics.velocity = physics.velocity.clamped(PhysicsConstants.MAX_SAFE_VELOCITY);
    physics.accumulatedForces = physics.accumulatedForces.clamped(PhysicsConstants.MAX_SAFE_FORCE);

    // Apply damping to prevent buildup
    physics.velocity *= PhysicsConstants.ACCUMULATION_DAMPING;
    physics.accumulatedForces *= PhysicsConstants.FORCE_DECAY;
  }
}
```

## 4. Error Handling Patterns

### 4.1 Invalid State Detection

```dart
// Comprehensive error detection for system integration
class SystemIntegrationValidator {
  // Detect various integration error conditions
  ValidationResult validateSystemIntegration() {
    final List<IntegrationError> errors = <IntegrationError>[];

    // Check physics-movement coordination
    errors.addAll(_validatePhysicsMovementCoordination());

    // Check state synchronization
    errors.addAll(_validateStateSynchronization());

    // Check timing requirements
    errors.addAll(_validateTimingRequirements());

    // Check memory usage
    errors.addAll(_validateMemoryUsage());

    return ValidationResult(errors);
  }

  List<IntegrationError> _validatePhysicsMovementCoordination() {
    final List<IntegrationError> errors = <IntegrationError>[];

    // Check for direct position modifications outside PhysicsSystem
    if (_detectDirectPositionModification()) {
      errors.add(IntegrationError.positionOwnershipViolation);
    }

    // Check for movement requests bypassing coordination
    if (_detectUncoordinatedMovement()) {
      errors.add(IntegrationError.uncoordinatedMovement);
    }

    // Check for accumulation patterns
    if (_detectAccumulationPatterns()) {
      errors.add(IntegrationError.accumulationDetected);
    }

    return errors;
  }
}

// Integration error types
enum IntegrationError {
  positionOwnershipViolation,
  uncoordinatedMovement,
  accumulationDetected,
  stateSynchronizationFailure,
  timingRequirementViolation,
  memoryLimitExceeded,
  requestProcessingTimeout,
  invalidPhysicsState
}
```

### 4.2 Recovery Mechanisms

```dart
// Automated recovery procedures for integration failures
class IntegrationRecoveryManager {
  // Execute recovery based on error type
  void executeRecovery(IntegrationError error, int entityId) {
    switch (error) {
      case IntegrationError.positionOwnershipViolation:
        _recoverPositionOwnership(entityId);
        break;
      case IntegrationError.accumulationDetected:
        _recoverFromAccumulation(entityId);
        break;
      case IntegrationError.stateSynchronizationFailure:
        _recoverStateSynchronization(entityId);
        break;
      case IntegrationError.invalidPhysicsState:
        _recoverPhysicsState(entityId);
        break;
      default:
        _executeGenericRecovery(entityId);
    }
  }

  void _recoverFromAccumulation(int entityId) {
    final PhysicsComponent? physics = _getPhysicsComponent(entityId);
    if (physics == null) return;

    // Reset accumulated values
    physics.velocity = Vector2.zero();
    physics.accumulatedForces = Vector2.zero();

    // Clear pending requests
    _physicsSystem.clearEntityRequests(entityId);

    // Log recovery action
    _logger.warning('Recovered from accumulation for entity $entityId');
  }

  void _recoverPositionOwnership(int entityId) {
    // Force position authority back to PhysicsSystem
    final Vector2? authorativePosition = _physicsSystem.getPosition(entityId);
    if (authorativePosition != null) {
      _transformSystem.setPosition(entityId, authorativePosition);
    }

    _logger.warning('Recovered position ownership for entity $entityId');
  }
}
```

### 4.3 Debug Logging Standards

```dart
// Standardized logging for integration debugging
class IntegrationLogger {
  // Log levels for different integration events
  static const LogLevel COORDINATION_LEVEL = LogLevel.debug;
  static const LogLevel STATE_SYNC_LEVEL = LogLevel.debug;
  static const LogLevel ERROR_LEVEL = LogLevel.warning;
  static const LogLevel RECOVERY_LEVEL = LogLevel.info;

  // Log movement request processing
  void logMovementRequest(MovementRequest request) {
    if (_logger.isLoggable(COORDINATION_LEVEL)) {
      _logger.log(COORDINATION_LEVEL,
        'MovementRequest: entity=${request.entityId}, '
        'direction=${request.direction}, speed=${request.speed}, '
        'type=${request.type}, frame=${request.frameNumber}');
    }
  }

  // Log physics response
  void logPhysicsResponse(PhysicsResponse response) {
    if (_logger.isLoggable(COORDINATION_LEVEL)) {
      _logger.log(COORDINATION_LEVEL,
        'PhysicsResponse: entity=${response.entityId}, '
        'velocity=${response.actualVelocity}, '
        'position=${response.actualPosition}, '
        'grounded=${response.grounded}, status=${response.status}');
    }
  }

  // Log state synchronization
  void logStateSynchronization(int entityId, String component, dynamic value) {
    if (_logger.isLoggable(STATE_SYNC_LEVEL)) {
      _logger.log(STATE_SYNC_LEVEL,
        'StateSync: entity=$entityId, component=$component, value=$value');
    }
  }

  // Log integration errors
  void logIntegrationError(IntegrationError error, int entityId, String details) {
    _logger.log(ERROR_LEVEL,
      'IntegrationError: $error for entity $entityId - $details');
  }

  // Log recovery actions
  void logRecoveryAction(String action, int entityId, String result) {
    _logger.log(RECOVERY_LEVEL,
      'Recovery: $action for entity $entityId - $result');
  }
}
```

## 5. Performance Requirements

### 5.1 Frame Time Budgets

```dart
// Performance budgets for each system integration phase
class PerformanceBudgets {
  // Target: 16.67ms total frame time (60 FPS)
  static const Duration TOTAL_FRAME_BUDGET = Duration(microseconds: 16667);

  // Per-system budgets (microseconds)
  static const Map<String, int> SYSTEM_BUDGETS = {
    'input_processing': 500,        // 0.5ms
    'movement_requests': 800,       // 0.8ms
    'physics_processing': 4000,     // 4.0ms
    'collision_detection': 3000,    // 3.0ms
    'state_synchronization': 500,   // 0.5ms
    'animation_updates': 2000,      // 2.0ms
    'audio_processing': 1000,       // 1.0ms
    'rendering': 4000,              // 4.0ms
    'overhead_buffer': 867,         // 0.867ms buffer
  };

  // Memory allocation budgets per frame
  static const int MAX_ALLOCATIONS_PER_FRAME = 100;  // Object instances
  static const int MAX_MEMORY_PER_FRAME = 1024 * 16; // 16KB

  // Request processing limits
  static const int MAX_MOVEMENT_REQUESTS_PER_FRAME = 50;
  static const int MAX_PHYSICS_RESPONSES_PER_FRAME = 50;
}
```

### 5.2 Memory Allocation Limits

```dart
// Monitor and enforce memory allocation limits
class MemoryMonitor {
  int _currentFrameAllocations = 0;
  int _currentFrameMemory = 0;

  // Track allocations during integration processing
  void trackAllocation(Type objectType, int sizeBytes) {
    _currentFrameAllocations++;
    _currentFrameMemory += sizeBytes;

    if (_currentFrameAllocations > PerformanceBudgets.MAX_ALLOCATIONS_PER_FRAME) {
      _logger.warning('Exceeded allocation limit: $_currentFrameAllocations objects');
    }

    if (_currentFrameMemory > PerformanceBudgets.MAX_MEMORY_PER_FRAME) {
      _logger.warning('Exceeded memory limit: $_currentFrameMemory bytes');
    }
  }

  // Reset counters at frame start
  void resetFrameCounters() {
    _currentFrameAllocations = 0;
    _currentFrameMemory = 0;
  }

  // Generate memory usage report
  MemoryReport generateReport() {
    return MemoryReport(
      allocations: _currentFrameAllocations,
      memoryUsed: _currentFrameMemory,
      allocationBudget: PerformanceBudgets.MAX_ALLOCATIONS_PER_FRAME,
      memoryBudget: PerformanceBudgets.MAX_MEMORY_PER_FRAME,
    );
  }
}
```

### 5.3 Update Frequency Targets

```dart
// Frequency requirements for different integration components
class UpdateFrequencyTargets {
  // Core system update frequencies (Hz)
  static const double INPUT_FREQUENCY = 120.0;      // High precision input
  static const double PHYSICS_FREQUENCY = 60.0;     // Game frame rate
  static const double COLLISION_FREQUENCY = 60.0;   // Match physics
  static const double ANIMATION_FREQUENCY = 60.0;   // Visual smoothness
  static const double AUDIO_FREQUENCY = 60.0;       // Audio responsiveness

  // State synchronization frequencies
  static const double TRANSFORM_SYNC_FREQUENCY = 60.0;  // Every frame
  static const double STATE_VALIDATION_FREQUENCY = 30.0; // Twice per second

  // Performance monitoring frequencies
  static const double PERFORMANCE_MONITORING_FREQUENCY = 1.0;  // Once per second
  static const double MEMORY_MONITORING_FREQUENCY = 10.0;      // 10 times per second
}
```

## 6. Integration Validation & Testing

### 6.1 Validation Procedures

```dart
// Comprehensive validation of integration correctness
class IntegrationValidator {
  // Run all validation checks
  ValidationReport runFullValidation() {
    final List<ValidationResult> results = <ValidationResult>[];

    // System coordination validation
    results.add(_validateSystemCoordination());

    // State consistency validation
    results.add(_validateStateConsistency());

    // Performance validation
    results.add(_validatePerformance());

    // Memory usage validation
    results.add(_validateMemoryUsage());

    return ValidationReport(results);
  }

  ValidationResult _validateSystemCoordination() {
    final List<String> issues = <String>[];

    // Check request-response timing
    if (!_checkRequestResponseTiming()) {
      issues.add('Request-response timing exceeds limits');
    }

    // Check system execution order
    if (!_checkSystemExecutionOrder()) {
      issues.add('System execution order violated');
    }

    // Check position ownership
    if (!_checkPositionOwnership()) {
      issues.add('Position ownership violations detected');
    }

    return ValidationResult('SystemCoordination', issues);
  }
}
```

### 6.2 Automated Testing Patterns

```dart
// Automated tests for integration patterns
class IntegrationTests {
  // Test movement request processing
  void testMovementRequestProcessing() {
    final MovementRequest request = MovementRequest(
      entityId: 1,
      direction: Vector2(1, 0),
      speed: 100.0,
      type: MovementType.run,
    );

    // Submit request
    _movementSystem.requestMovement(request);

    // Process one frame
    _physicsSystem.update(0.016);

    // Validate response
    final PhysicsResponse? response = _physicsSystem.getLastResponse(1);
    expect(response, isNotNull);
    expect(response!.status, equals(ResponseStatus.success));
    expect(response.actualVelocity.x, greaterThan(0));
  }

  // Test accumulation prevention
  void testAccumulationPrevention() {
    final int entityId = 1;

    // Apply excessive forces
    for (int i = 0; i < 100; i++) {
      _physicsSystem.requestImpulse(entityId, Vector2(1000, 0));
      _physicsSystem.update(0.016);
    }

    // Validate velocity is clamped
    final Vector2 velocity = _physicsSystem.getVelocity(entityId);
    expect(velocity.length, lessThanOrEqualTo(PhysicsConstants.MAX_SAFE_VELOCITY));
  }

  // Test state synchronization
  void testStateSynchronization() {
    final int entityId = 1;
    final Vector2 expectedPosition = Vector2(100, 200);

    // Set position through physics system
    _physicsSystem.setPositionOverride(entityId, expectedPosition);
    _physicsSystem.update(0.016);

    // Validate transform sync
    final Vector2 transformPosition = _transformSystem.getPosition(entityId);
    expect((transformPosition - expectedPosition).length,
           lessThan(TransformConstants.POSITION_TOLERANCE));
  }
}
```

## 7. Implementation Checklist

### 7.1 Integration Setup Checklist

- [ ] **IPhysicsCoordinator Interface**: Implemented in PhysicsSystem
- [ ] **MovementRequest System**: Created and integrated with MovementSystem
- [ ] **Request Processing Pipeline**: Implemented with priority handling
- [ ] **State Synchronization**: TransformSynchronizer implemented
- [ ] **Error Detection**: IntegrationValidator implemented
- [ ] **Recovery Mechanisms**: IntegrationRecoveryManager implemented
- [ ] **Performance Monitoring**: MemoryMonitor and timing implemented
- [ ] **Logging Standards**: IntegrationLogger implemented
- [ ] **Validation Tests**: Automated integration tests created

### 7.2 Performance Verification Checklist

- [ ] **Frame Budget Compliance**: All systems within time budgets
- [ ] **Memory Limit Compliance**: Allocations within frame limits
- [ ] **Update Frequency**: All systems meeting frequency targets
- [ ] **Request Processing**: Within single-frame processing requirement
- [ ] **State Consistency**: No accumulation or desynchronization
- [ ] **Error Recovery**: Recovery procedures tested and functional

### 7.3 Documentation Checklist

- [ ] **API Documentation**: All interfaces fully documented
- [ ] **Integration Patterns**: Request-response patterns documented
- [ ] **Error Handling**: Error types and recovery procedures documented
- [ ] **Performance Requirements**: Budgets and targets documented
- [ ] **Testing Procedures**: Validation and testing patterns documented
- [ ] **Implementation Examples**: Code examples for all patterns

## 8. Related Documents

- See [SystemArchitecture.TDD.md](SystemArchitecture.TDD.md) for core architectural foundation
- See [PhysicsSystem.TDD.md](PhysicsSystem.TDD.md) for physics system implementation details
- See [MovementSystem.TDD.md](MovementSystem.TDD.md) for movement system coordination
- See [Physics-Movement Refactor Task Tracker](../../04_Project_Management/Physics-movement-refactor-task-tracker.md) for implementation progress
- See [Critical Report: Physics Movement System Degradation](../../07_Reports/Critical_Report_Physics_Movement_System_Degradation.md) for issue background

# Input System - Technical Design Document

## 1. Overview

Defines the input processing system with primary focus on **Movement Integration & Request Generation**. This system operates at the highest priority (Priority: 100) in the execution order to capture player input and translate it into MovementRequest objects for seamless coordination with the MovementSystem and PhysicsSystem through the established request-response protocols.

> **Related Documents:**
>
> - [MovementSystem TDD](MovementSystem.TDD.md) - Movement request processing and coordination
> - [PhysicsSystem TDD](PhysicsSystem.TDD.md) - Physics system specification and coordination
> - [SystemIntegration TDD](SystemIntegration.TDD.md) - Request-response protocols and coordination patterns
> - [SystemArchitecture TDD](SystemArchitecture.TDD.md) - System execution order and priorities
> - [PlayerCharacter TDD](PlayerCharacter.TDD.md) - Character input integration and ability triggers
> - [CollisionSystem TDD](CollisionSystem.TDD.md) - Input validation against collision constraints
> - [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) - Refactor strategy
> - [Critical Report: Physics Movement System Degradation](../../07_Reports/Critical_Report_Physics_Movement_System_Degradation.md) - Root cause analysis

### Purpose

- **Primary**: Capture and process player input with <2 frame latency for responsive gameplay
- Translate raw input events into structured MovementRequest objects
- Implement input buffering system supporting complex movement sequences and combos
- Validate input sequences and prevent invalid or conflicting movement requests
- Coordinate with MovementSystem through IMovementHandler interface
- Support both keyboard and gamepad input with consistent timing and response

### Scope

- Real-time input capture and processing optimized for 60fps gameplay
- Input buffering system for combo sequences and movement chaining
- Movement request generation with validation and prioritization
- Input lag mitigation strategies ensuring <33ms total input-to-visual response
- Integration with movement coordination protocols preventing physics conflicts
- Error handling for input processing failures and fallback mechanisms

### System Integration Focus

This TDD specifically supports the **Physics-Movement System Refactor** through:

- **Request Generation**: All movement input converted to formal MovementRequest objects
- **Timing Coordination**: Input processing at Priority 100 ensures proper execution sequence
- **Buffering Support**: Input buffering enables complex movement combinations without conflicts
- **Validation Integration**: Input validation prevents invalid movement requests reaching physics
- **Performance Optimization**: Input processing within <2ms of 16.67ms frame budget

## 2. Class Design

### Core Input Classes

```dart
// Main input system component - first in execution order (Priority: 100)
class InputSystem extends BaseFlameSystem implements IMovementHandler {
  late final InputCapture _inputCapture;
  late final InputBuffer _inputBuffer;
  late final MovementRequestGenerator _requestGenerator;
  late final InputValidator _validator;
  late final IMovementCoordinator _movementCoordinator;

  // High-priority input processing (Priority: 100)
  @override
  void update(double dt) {
    // 1. Capture raw input events
    // 2. Process buffered input sequences
    // 3. Generate movement requests
    // 4. Validate and submit requests
  }
}

// Multi-platform input capture with consistent timing
class InputCapture {
  late final KeyboardHandler _keyboard;
  late final GamepadHandler _gamepad;
  late final TouchHandler _touch;

  // Unified input event capture
  List<RawInputEvent> captureInputEvents();
  InputState getCurrentInputState();
  bool isInputActive(InputAction action);
}

// Input buffering for complex sequences and combos
class InputBuffer {
  final Queue<BufferedInput> _buffer = Queue();
  final Map<InputSequenceType, SequenceDetector> _sequenceDetectors = {};

  // Buffering and sequence detection
  void bufferInput(RawInputEvent event);
  List<InputSequence> detectSequences();
  void processBuffer(double dt);
  void clearExpiredInputs();
}

// Movement request generation from input events
class MovementRequestGenerator {
  late final IMovementCoordinator _movementCoordinator;
  final Map<InputAction, MovementRequestFactory> _requestFactories = {};

  // Request generation pipeline
  List<MovementRequest> generateRequests(List<InputSequence> sequences);
  MovementRequest createMovementRequest(InputAction action, InputState state);
  void prioritizeRequests(List<MovementRequest> requests);
}

// Input validation preventing invalid movement combinations
class InputValidator {
  late final ICollisionNotifier _collisionNotifier;
  late final ICharacterPhysicsCoordinator _physicsCoordinator;
  late final IMovementCoordinator _movementCoordinator;

  // Input validation against game state
  Future<bool> validateMovementInput(InputAction action, int entityId);
  Future<bool> validateInputSequence(InputSequence sequence, int entityId);
  List<ValidationError> getValidationErrors();
}
```

### Key Responsibilities

- **InputSystem**: Main coordination and high-priority input processing
- **InputCapture**: Cross-platform input event capture with consistent timing
- **InputBuffer**: Input buffering and sequence detection for complex movements
- **MovementRequestGenerator**: Translation of input to MovementRequest objects
- **InputValidator**: Input validation against physics and collision constraints

## 3. Data Structures

### Input Event Structures

```dart
// Raw input event from hardware
class RawInputEvent {
  final InputType type;
  final InputAction action;
  final InputEventType eventType;  // press, release, hold
  final double intensity;          // for analog inputs (0.0 - 1.0)
  final Vector2 direction;         // for directional inputs
  final double timestamp;
  final int frameNumber;
  final DeviceType deviceType;     // keyboard, gamepad, touch

  RawInputEvent({
    required this.type,
    required this.action,
    required this.eventType,
    this.intensity = 1.0,
    this.direction = Vector2.zero(),
    required this.deviceType,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch.toDouble(),
       frameNumber = Time.currentFrame;
}

// Current state of all input actions
class InputState {
  final Map<InputAction, bool> _actionStates = {};
  final Map<InputAction, double> _actionIntensities = {};
  final Map<InputAction, double> _actionDurations = {};
  final Vector2 movementDirection;
  final double timestamp;

  // Input state queries
  bool isPressed(InputAction action);
  bool isHeld(InputAction action);
  bool wasJustPressed(InputAction action);
  bool wasJustReleased(InputAction action);
  double getIntensity(InputAction action);
  double getHoldDuration(InputAction action);
}

// Input action enumeration for movement and abilities
enum InputAction {
  // Movement actions
  moveLeft,
  moveRight,
  moveUp,
  moveDown,
  jump,
  dash,

  // Ability actions
  primaryAbility,    // Strike
  secondaryAbility,  // Pulse
  specialAbility1,   // World-specific ability
  specialAbility2,   // World-specific ability

  // System actions
  pause,
  interact,
  menu,
}

enum InputEventType {
  press,      // Initial button press
  release,    // Button release
  hold,       // Continued button hold
  repeat,     // Key repeat event
}

enum DeviceType {
  keyboard,
  gamepad,
  touch,
}
```

### Input Buffering and Sequences

```dart
// Buffered input with timing information
class BufferedInput {
  final RawInputEvent event;
  final double bufferTime;
  final bool isConsumed;
  final int priority;

  BufferedInput({
    required this.event,
    required this.bufferTime,
    this.isConsumed = false,
    this.priority = 0,
  });

  // Expiration checking for buffer cleanup
  bool get isExpired => (DateTime.now().millisecondsSinceEpoch - event.timestamp) > bufferTime;
}

// Input sequence for complex movement combinations
class InputSequence {
  final InputSequenceType type;
  final List<RawInputEvent> events;
  final double sequenceStartTime;
  final double sequenceDuration;
  final MovementRequestType requestType;
  final RequestPriority priority;

  InputSequence({
    required this.type,
    required this.events,
    required this.sequenceStartTime,
    required this.requestType,
    this.priority = RequestPriority.normal,
  }) : sequenceDuration = events.isNotEmpty
         ? events.last.timestamp - events.first.timestamp
         : 0.0;
}

// Input sequence type classification
enum InputSequenceType {
  singleAction,        // Single input action
  directionalHold,     // Sustained directional input
  dashSequence,        // Dash input with direction
  jumpSequence,        // Jump with optional direction
  abilityCombo,        // Ability combination sequence
  rapidInput,          // Rapid repeated input
  chargedAction,       // Hold-and-release action
}

// Movement request factory for input-to-request conversion
class MovementRequestFactory {
  final InputAction inputAction;
  final MovementRequestType requestType;
  final RequestPriority priority;

  // Request generation from input
  MovementRequest createRequest(int entityId, InputState inputState, InputSequence? sequence);
  bool validateInputRequirements(InputState inputState);
  Vector2 calculateMovementDirection(InputState inputState);
  double calculateMovementSpeed(InputState inputState);
}
```

### Input Configuration

```dart
// Input mapping configuration for different control schemes
class InputMapping {
  final Map<KeyCode, InputAction> keyboardMapping = {};
  final Map<GamepadButton, InputAction> gamepadMapping = {};
  final Map<TouchGesture, InputAction> touchMapping = {};

  // Configuration methods
  void mapKeyboardInput(KeyCode key, InputAction action);
  void mapGamepadInput(GamepadButton button, InputAction action);
  void mapTouchGesture(TouchGesture gesture, InputAction action);
  InputAction? getActionForKey(KeyCode key);
  InputAction? getActionForButton(GamepadButton button);
}

// Input sensitivity and timing configuration
class InputConfig {
  // Timing settings
  final double inputBufferTime;        // 150ms default
  final double comboWindowTime;        // 300ms default
  final double holdThreshold;          // 100ms to register hold
  final double repeatDelay;            // 500ms before key repeat
  final double repeatRate;             // 50ms between repeats

  // Sensitivity settings
  final double analogDeadzone;         // 0.1 default
  final double analogSensitivity;      // 1.0 default
  final double touchSensitivity;       // 1.0 default

  // Response settings
  final bool enableInputPrediction;    // true for competitive feel
  final bool enableInputBuffer;        // true for forgiving input
  final bool enableComboDetection;     // true for advanced moves

  const InputConfig({
    this.inputBufferTime = 150.0,
    this.comboWindowTime = 300.0,
    this.holdThreshold = 100.0,
    this.repeatDelay = 500.0,
    this.repeatRate = 50.0,
    this.analogDeadzone = 0.1,
    this.analogSensitivity = 1.0,
    this.touchSensitivity = 1.0,
    this.enableInputPrediction = true,
    this.enableInputBuffer = true,
    this.enableComboDetection = true,
  });
}
```

## 4. Algorithms

### Input Processing Pipeline

```dart
// High-performance input processing (Priority: 100, first in frame)
class InputProcessingAlgorithm {

  List<MovementRequest> processInputFrame(double dt) {
    // 1. Capture input events (< 0.5ms budget)
    final rawEvents = _inputCapture.captureInputEvents();
    final inputState = _inputCapture.getCurrentInputState();

    // 2. Buffer and sequence detection (< 0.5ms budget)
    for (final event in rawEvents) {
      _inputBuffer.bufferInput(event);
    }
    final sequences = _inputBuffer.detectSequences();

    // 3. Generate movement requests (< 0.5ms budget)
    final requests = _requestGenerator.generateRequests(sequences);

    // 4. Validate requests (< 0.5ms budget)
    final validatedRequests = <MovementRequest>[];
    for (final request in requests) {
      if (await _validator.validateMovementInput(request.action, request.entityId)) {
        validatedRequests.add(request);
      }
    }

    // 5. Submit to movement system (< 0.1ms budget)
    for (final request in validatedRequests) {
      _movementCoordinator.submitMovementRequest(request);
    }

    // 6. Cleanup expired buffer entries
    _inputBuffer.clearExpiredInputs();

    return validatedRequests;
  }
}
```

### Input Buffering Algorithm

```dart
// Input buffering with sequence detection for complex movements
class InputBufferingAlgorithm {

  void bufferInput(RawInputEvent event) {
    // 1. Add to buffer with timestamp
    final bufferedInput = BufferedInput(
      event: event,
      bufferTime: _config.inputBufferTime,
      priority: _calculateInputPriority(event),
    );
    _buffer.add(bufferedInput);

    // 2. Maintain buffer size limits
    while (_buffer.length > MAX_BUFFER_SIZE) {
      _buffer.removeFirst();
    }
  }

  List<InputSequence> detectSequences() {
    final sequences = <InputSequence>[];

    // 1. Single action detection
    for (final input in _buffer.where((i) => !i.isConsumed)) {
      if (_isSingleActionComplete(input)) {
        sequences.add(_createSingleActionSequence(input));
      }
    }

    // 2. Combo sequence detection
    final comboSequences = _detectComboSequences();
    sequences.addAll(comboSequences);

    // 3. Rapid input detection (for accumulation prevention)
    final rapidSequences = _detectRapidInputSequences();
    sequences.addAll(rapidSequences);

    // 4. Mark consumed inputs
    for (final sequence in sequences) {
      _markSequenceAsConsumed(sequence);
    }

    return sequences;
  }

  List<InputSequence> _detectComboSequences() {
    final sequences = <InputSequence>[];

    // Dash sequence: Direction + Dash within combo window
    final dashSequence = _detectDashSequence();
    if (dashSequence != null) sequences.add(dashSequence);

    // Jump sequence: Jump + optional direction
    final jumpSequence = _detectJumpSequence();
    if (jumpSequence != null) sequences.add(jumpSequence);

    // Ability combos: Multiple abilities in sequence
    final abilitySequences = _detectAbilitySequences();
    sequences.addAll(abilitySequences);

    return sequences;
  }
}
```

### Movement Request Generation Algorithm

```dart
// Movement request generation from input sequences
class MovementRequestGenerationAlgorithm {

  List<MovementRequest> generateRequests(List<InputSequence> sequences) {
    final requests = <MovementRequest>[];

    // 1. Sort sequences by priority and timing
    sequences.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      return a.sequenceStartTime.compareTo(b.sequenceStartTime);
    });

    // 2. Generate requests for each sequence
    for (final sequence in sequences) {
      final request = _generateRequestForSequence(sequence);
      if (request != null) {
        requests.add(request);
      }
    }

    // 3. Handle conflicting requests
    final resolvedRequests = _resolveRequestConflicts(requests);

    return resolvedRequests;
  }

  MovementRequest? _generateRequestForSequence(InputSequence sequence) {
    switch (sequence.type) {
      case InputSequenceType.directionalHold:
        return _createDirectionalMovementRequest(sequence);

      case InputSequenceType.dashSequence:
        return _createDashRequest(sequence);

      case InputSequenceType.jumpSequence:
        return _createJumpRequest(sequence);

      case InputSequenceType.rapidInput:
        return _createRapidInputRequest(sequence);

      case InputSequenceType.chargedAction:
        return _createChargedActionRequest(sequence);

      default:
        return _createSingleActionRequest(sequence);
    }
  }
}
```

## 5. API/Interfaces

### Movement Handler Interface

```dart
// Primary interface for input-movement coordination
abstract class IMovementHandler {
  // Movement request submission
  Future<bool> submitMovementRequest(MovementRequest request);
  Future<bool> submitMovementSequence(List<MovementRequest> requests);

  // Input validation queries
  Future<bool> canProcessInput(InputAction action, int entityId);
  Future<bool> canProcessSequence(InputSequence sequence, int entityId);

  // Input state coordination
  Future<void> notifyInputProcessed(MovementRequest request);
  Future<void> notifyInputFailed(MovementRequest request, String reason);

  // Buffer management
  void clearInputBuffer(int entityId);
  void setInputBufferEnabled(bool enabled);

  // Error handling
  void onInputProcessingError(InputError error);
}

// Movement coordination interface for request submission
abstract class IMovementCoordinator {
  // Request submission to movement system
  Future<bool> submitMovementRequest(MovementRequest request);
  Future<List<MovementResponse>> submitBatchRequests(List<MovementRequest> requests);

  // Movement state queries for input validation
  Future<bool> canMove(int entityId);
  Future<bool> canJump(int entityId);
  Future<bool> canDash(int entityId);
  Future<MovementState> getMovementState(int entityId);

  // Movement capability queries
  Future<List<InputAction>> getAvailableActions(int entityId);
  Future<bool> isActionBlocked(InputAction action, int entityId);

  // Accumulation prevention
  void preventAccumulation(int entityId);

  // Error notification
  void onMovementRequestFailed(MovementRequest request, String reason);
}

// Physics coordination interface for capability queries
abstract class ICharacterPhysicsCoordinator {
  // Physics state queries for input validation
  Future<bool> isGrounded(int entityId);
  Future<bool> isJumping(int entityId);
  Future<bool> isFalling(int entityId);
  Future<Vector2> getVelocity(int entityId);
  Future<Vector2> getPosition(int entityId);

  // Movement capability validation
  Future<bool> canPerformJump(int entityId);
  Future<bool> canPerformDash(int entityId);
  Future<double> getMaxMovementSpeed(int entityId);

  // State synchronization
  Future<PhysicsState> getPhysicsState(int entityId);
  void notifyInputProcessing(int entityId);
}

// Collision notification interface for movement validation
abstract class ICollisionNotifier {
  // Movement validation against collision constraints
  Future<bool> isMovementBlocked(int entityId, Vector2 direction);
  Future<bool> isPositionValid(int entityId, Vector2 position);
  Future<List<CollisionInfo>> predictCollisions(int entityId, Vector2 movement);

  // Ground state validation for jump inputs
  Future<bool> isEntityGrounded(int entityId);
  Future<GroundInfo> getGroundInfo(int entityId);

  // Collision event notification
  void notifyInputValidation(int entityId, InputAction action);
}
```

### Input Configuration Interface

```dart
// Interface for input system configuration and customization
abstract class IInputConfiguration {
  // Input mapping management
  void setKeyMapping(KeyCode key, InputAction action);
  void setGamepadMapping(GamepadButton button, InputAction action);
  void setTouchMapping(TouchGesture gesture, InputAction action);

  // Timing configuration
  void setInputBufferTime(double milliseconds);
  void setComboWindowTime(double milliseconds);
  void setHoldThreshold(double milliseconds);

  // Sensitivity configuration
  void setAnalogSensitivity(double sensitivity);
  void setAnalogDeadzone(double deadzone);
  void setTouchSensitivity(double sensitivity);

  // Feature toggles
  void setInputBufferEnabled(bool enabled);
  void setComboDetectionEnabled(bool enabled);
  void setInputPredictionEnabled(bool enabled);

  // Configuration persistence
  void saveConfiguration();
  void loadConfiguration();
  void resetToDefaults();
}

// Input event listener interface for dependent systems
abstract class IInputEventListener {
  void onInputPressed(InputAction action, int entityId);
  void onInputReleased(InputAction action, int entityId);
  void onInputSequenceDetected(InputSequence sequence, int entityId);
  void onMovementRequestGenerated(MovementRequest request);
}
```

### Input Validation Interface

```dart
// Interface for input validation against game state
abstract class IInputValidator {
  // Movement validation
  Future<bool> validateMovementInput(InputAction action, int entityId);
  Future<bool> validateInputSequence(InputSequence sequence, int entityId);
  Future<bool> validateRequestGeneration(MovementRequest request);

  // Constraint checking
  Future<bool> isMovementBlocked(int entityId, Vector2 direction);
  Future<bool> isAbilityAvailable(InputAction action, int entityId);
  Future<bool> isInputTimingValid(InputSequence sequence);

  // Error reporting
  List<ValidationError> getValidationErrors();
  String getValidationErrorMessage(ValidationError error);

  // Validation configuration
  void setValidationEnabled(bool enabled);
  void setStrictValidation(bool strict);
}
```

## 6. Dependencies

### System Dependencies

- **Movement System**: For movement request submission via IMovementCoordinator (Priority: 90)
- **Physics System**: For movement capability queries via IPhysicsCoordinator (Priority: 80)
- **Collision System**: For movement validation via ICollisionQuery (Priority: 70)
- **Player Character**: For entity-specific input processing and ability triggers
- **Audio System**: For input feedback sound effects (Priority: 20)
- **UI System**: For input configuration and control customization

### Physics-Movement Integration Dependencies

- **IMovementCoordinator**: Primary interface for movement request submission and coordination
- **ICharacterPhysicsCoordinator**: Interface for physics state queries (grounded, jumping capabilities)
- **ICollisionNotifier**: Interface for collision state validation before movement requests
- **MovementRequest Protocol**: All input converted to structured MovementRequest objects
- **Request-Response Pattern**: Async request submission with validation and error handling
- **Error Recovery**: Input processing failures coordinated with movement system error recovery
- **Timing Coordination**: Input processing at Priority 100 ensuring proper execution sequence
- **State Synchronization**: Input validation synchronized with physics and collision state
- **Accumulation Prevention**: Input buffering patterns prevent rapid input physics accumulation

### Component Dependencies

- Flame input handlers for keyboard, gamepad, and touch input capture
- Platform-specific input APIs for low-latency input capture
- Game loop integration for consistent input processing timing
- SystemIntegration.TDD.md patterns for cross-system communication

## 7. File Structure

```
lib/
  src/
    systems/
      input/
        input_system.dart                   # Main input system (Priority: 100)
        input_capture.dart                  # Multi-platform input capture
        input_buffer.dart                   # Input buffering and sequence detection
        movement_request_generator.dart     # Input-to-request conversion
        input_validator.dart                # Input validation against game state
      input_processing/
        keyboard_handler.dart               # Keyboard input processing
        gamepad_handler.dart                # Gamepad input processing
        touch_handler.dart                  # Touch input processing
        sequence_detector.dart              # Input sequence detection algorithms      interfaces/
        movement_handler.dart               # IMovementHandler interface
        movement_coordinator.dart           # IMovementCoordinator interface
        character_physics_coordinator.dart  # ICharacterPhysicsCoordinator interface
        collision_notifier.dart             # ICollisionNotifier interface
        input_configuration.dart            # IInputConfiguration interface
        input_validator.dart                # IInputValidator interface
    data/
      input_events.dart                     # Input event data structures
      input_sequences.dart                  # Input sequence data structures
      input_config.dart                     # Input configuration data
    config/
      input_mappings.dart                   # Default input mapping configurations
      control_schemes.dart                  # Predefined control schemes
```

## 8. Performance Considerations

### Optimization Strategies

- **Minimal Processing Time**: Input processing within 2ms of 16.67ms frame budget
- **Event Batching**: Input events batched and processed at frame boundaries
- **Buffer Size Limits**: Input buffer limited to prevent memory bloat
- **Sequence Caching**: Frequently detected sequences cached for performance
- **Validation Caching**: Input validation results cached for repeated queries

### Memory Management

- **Event Object Pooling**: Reuse RawInputEvent and InputSequence objects
- **Buffer Cleanup**: Automatic cleanup of expired buffer entries
- **Configuration Caching**: Input mappings cached in memory for fast lookup
- **Garbage Collection Optimization**: Minimal allocations during input processing

### Low-Latency Optimizations

- **Direct Hardware Access**: Platform-specific APIs for minimal input latency
- **Frame-Perfect Timing**: Input processing aligned with frame boundaries
- **Prediction Integration**: Optional input prediction for competitive gameplay feel
- **Bypass Buffers**: Direct request generation for simple inputs when buffering disabled

## 9. Testing Strategy

### Unit Tests

- Input event capture accuracy across all supported devices
- Input buffering and sequence detection with various timing scenarios
- Movement request generation correctness for all input combinations
- Input validation logic against various game states
- Configuration management and persistence functionality

### Integration Tests

- InputSystem integration with MovementSystem via IMovementCoordinator
- Input validation coordination with PhysicsSystem and CollisionSystem
- Multi-platform input consistency testing (keyboard, gamepad, touch)
- Performance testing: input processing within frame budget
- Error handling coordination with movement system failures

### Input Response Tests

- Input-to-visual latency measurement (<33ms total response time)
- Complex input sequence processing (combos, rapid inputs, charged actions)
- Input buffer stress testing with rapid input sequences
- Platform-specific input handling validation
- Input configuration and customization functionality

## 10. Implementation Notes

### Movement Request Generation Patterns

**Simple Movement Request:**

```dart
// Example: Basic directional movement input processing
class DirectionalInputProcessor {
  final IMovementCoordinator _movementCoordinator;

  Future<void> processDirectionalInput(InputState inputState, int entityId) async {
    // 1. Calculate movement direction from input state
    final direction = Vector2(
      inputState.isPressed(InputAction.moveRight) ? 1.0 :
      inputState.isPressed(InputAction.moveLeft) ? -1.0 : 0.0,
      inputState.isPressed(InputAction.moveUp) ? -1.0 :
      inputState.isPressed(InputAction.moveDown) ? 1.0 : 0.0,
    ).normalized();

    // 2. Skip if no movement input
    if (direction.isZero()) return;

    // 3. Generate movement request
    final request = MovementRequest(
      entityId: entityId,
      direction: direction,
      speed: PLAYER_MOVE_SPEED,
      type: MovementType.walk,
      priority: RequestPriority.player,
      timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );

    // 4. Submit to movement system
    final success = await _movementCoordinator.submitMovementRequest(request);
    if (!success) {
      // Handle request failure (e.g., movement blocked)
      _handleMovementRequestFailed(request);
    }
  }
}
```

**Complex Sequence Processing:**

```dart
// Example: Dash sequence with direction and timing validation
class DashSequenceProcessor {
  final IMovementCoordinator _movementCoordinator;
  final IInputValidator _validator;

  Future<MovementRequest?> processDashSequence(InputSequence sequence, int entityId) async {
    // 1. Validate dash sequence timing
    if (!await _validator.validateInputSequence(sequence, entityId)) {
      return null;
    }

    // 2. Extract direction from sequence events
    final dashEvent = sequence.events.firstWhere((e) => e.action == InputAction.dash);
    final directionEvents = sequence.events.where((e) =>
      e.action == InputAction.moveLeft ||
      e.action == InputAction.moveRight ||
      e.action == InputAction.moveUp ||
      e.action == InputAction.moveDown
    );

    // 3. Calculate dash direction
    Vector2 dashDirection = Vector2.zero();
    for (final event in directionEvents) {
      switch (event.action) {
        case InputAction.moveLeft:
          dashDirection.x = -1.0;
          break;
        case InputAction.moveRight:
          dashDirection.x = 1.0;
          break;
        case InputAction.moveUp:
          dashDirection.y = -1.0;
          break;
        case InputAction.moveDown:
          dashDirection.y = 1.0;
          break;
      }
    }

    // 4. Default to facing direction if no directional input
    if (dashDirection.isZero()) {
      dashDirection = await _getPlayerFacingDirection(entityId);
    }

    // 5. Generate dash request
    final dashRequest = MovementRequest(
      entityId: entityId,
      direction: dashDirection.normalized(),
      speed: PLAYER_DASH_SPEED,
      type: MovementType.dash,
      priority: RequestPriority.player,
      timestamp: dashEvent.timestamp,
    );

    return dashRequest;
  }
}
```

**Input Validation Integration:**

```dart
// Example: Input validation preventing invalid movement requests
class InputValidationProcessor {
  final ICollisionNotifier _collisionNotifier;
  final ICharacterPhysicsCoordinator _physicsCoordinator;
  final IMovementCoordinator _movementCoordinator;

  Future<bool> validateMovementInput(InputAction action, int entityId) async {
    switch (action) {
      case InputAction.jump:
        // Validate jump capability (grounded state)
        return await _physicsCoordinator.isGrounded(entityId);

      case InputAction.dash:
        // Validate dash availability (cooldown, ability unlocked)
        final canDash = await _movementCoordinator.canDash(entityId);
        return canDash;

      case InputAction.moveLeft:
      case InputAction.moveRight:
        // Validate movement not blocked by collision
        final direction = action == InputAction.moveLeft ? Vector2(-1, 0) : Vector2(1, 0);
        return !await _collisionNotifier.isMovementBlocked(entityId, direction);

      default:
        return true; // Default to allowing input
    }
  }

  Future<bool> validateInputSequence(InputSequence sequence, int entityId) async {
    // 1. Validate timing requirements
    if (sequence.sequenceDuration > MAX_SEQUENCE_DURATION) {
      return false;
    }

    // 2. Validate individual actions in sequence
    for (final event in sequence.events) {
      if (!await validateMovementInput(event.action, entityId)) {
        return false;
      }
    }

    // 3. Validate sequence-specific requirements
    switch (sequence.type) {
      case InputSequenceType.dashSequence:
        return await _validateDashSequence(sequence, entityId);
      case InputSequenceType.jumpSequence:
        return await _validateJumpSequence(sequence, entityId);
      default:
        return true;
    }
  }
}
```

**Input Buffering with Accumulation Prevention:**

```dart
// Example: Input buffering preventing physics accumulation
class InputBufferManager {
  final Queue<BufferedInput> _buffer = Queue();
  final Map<int, double> _lastInputTimes = {};

  void bufferInput(RawInputEvent event, int entityId) {
    final currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    final lastInputTime = _lastInputTimes[entityId] ?? 0;

    // 1. Detect rapid input sequences (< 50ms between inputs)
    final timeDelta = currentTime - lastInputTime;
    final isRapidInput = timeDelta < 50.0;

    // 2. Create buffered input with rapid input flag
    final bufferedInput = BufferedInput(
      event: event,
      bufferTime: isRapidInput ? RAPID_INPUT_BUFFER_TIME : NORMAL_BUFFER_TIME,
      priority: isRapidInput ? 1 : 0, // Higher priority for rapid inputs
    );

    // 3. Add to buffer
    _buffer.add(bufferedInput);
    _lastInputTimes[entityId] = currentTime;

    // 4. If rapid input detected, mark for accumulation prevention
    if (isRapidInput) {
      _markForAccumulationPrevention(entityId);
    }

    // 5. Maintain buffer size limits
    while (_buffer.length > MAX_BUFFER_SIZE) {
      _buffer.removeFirst();
    }
  }

  void _markForAccumulationPrevention(int entityId) {
    // Notify movement system to prevent physics accumulation
    _movementCoordinator.preventAccumulation(entityId);
  }
}
```

**Error Handling and Recovery:**

```dart
// Example: Input processing error handling with recovery
class InputErrorHandler {
  final IMovementCoordinator _movementCoordinator;

  void handleInputProcessingError(InputError error) {
    switch (error.type) {
      case InputErrorType.invalidSequence:
        // Clear buffer and reset input state
        _inputBuffer.clearBuffer();
        _logInputError(error);
        break;

      case InputErrorType.movementRequestFailed:
        // Retry with fallback movement parameters
        _retryMovementRequest(error.failedRequest);
        break;

      case InputErrorType.validationTimeout:
        // Skip validation and allow input with warning
        _submitRequestWithoutValidation(error.request);
        _logValidationTimeout(error);
        break;

      case InputErrorType.systemUnavailable:
        // Buffer input for retry when system becomes available
        _bufferForRetry(error.request);
        break;
    }
  }

  Future<void> _retryMovementRequest(MovementRequest originalRequest) async {
    // Create fallback request with reduced parameters
    final fallbackRequest = originalRequest.copyWith(
      speed: originalRequest.speed * 0.5, // Reduce speed
      priority: RequestPriority.normal,    // Lower priority
    );

    final success = await _movementCoordinator.submitMovementRequest(fallbackRequest);
    if (!success) {
      // Final fallback: emergency movement
      await _submitEmergencyMovement(originalRequest.entityId);
    }
  }
}
```

### System Execution Timing

**Frame Processing Order (Priority: 100 - First in execution):**

```
Frame Start
    ↓
1. INPUT SYSTEM (Priority: 100) - Capture and process input, generate movement requests
2. Movement System (Priority: 90) - Process movement requests
3. Physics System (Priority: 80) - Update positions and physics
4. Collision System (Priority: 70) - Detect collisions, update grounded state
5. AI/Combat Systems (Priority: 60-40) - Game logic
6. Animation System (Priority: 30) - Update animations
7. Audio System (Priority: 20) - Input feedback sounds
8. Render System (Priority: 10) - Visual rendering
Frame End
```

### Integration Validation

- ✅ **Request Generation**: All input converted to structured MovementRequest objects
- ✅ **Timing Coordination**: Input processing at Priority 100 ensures proper sequence
- ✅ **Validation Integration**: Input validated against physics/collision state via ICharacterPhysicsCoordinator and ICollisionNotifier
- ✅ **Buffer Management**: Input buffering prevents accumulation and supports combos
- ✅ **Error Recovery**: Input errors coordinated with movement system error handling
- ✅ **Interface Compliance**: Implements IMovementHandler for movement coordination
- ✅ **State Synchronization**: Physics and collision state queries ensure valid input processing
- ✅ **Accumulation Prevention**: Rapid input detection prevents physics force accumulation
- ✅ **Request-Response Pattern**: Async request submission with proper error handling

## 11. Future Considerations

### Expandability

- **Advanced Input Devices**: Support for specialized gaming peripherals
- **Gesture Recognition**: Complex touch gesture recognition for mobile platforms
- **Voice Input**: Voice command integration for accessibility
- **Haptic Feedback**: Advanced haptic feedback integration for supported devices

### Performance Enhancements

- **Predictive Input**: Machine learning-based input prediction for competitive gameplay
- **Adaptive Buffering**: Dynamic buffer sizing based on gameplay context
- **Multi-threaded Processing**: Parallel input processing for complex scenarios
- **Hardware Integration**: Direct integration with gaming hardware APIs

### Accessibility Features

- **Customizable Controls**: Full control remapping and accessibility options
- **Input Assistance**: Input assistance for players with motor impairments
- **Visual Feedback**: Visual indicators for input state and feedback
- **Alternative Input Methods**: Support for alternative input devices and methods

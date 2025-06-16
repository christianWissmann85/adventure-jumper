import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/gestures.dart'; // Add pointer events
import 'package:flutter/services.dart';

import '../components/input_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';
import 'interfaces/movement_coordinator.dart';
import 'interfaces/movement_handler.dart';
import 'interfaces/movement_request.dart';

// Export pointer events for easy use
export 'package:flutter/gestures.dart'
    show
        PointerEvent,
        PointerDownEvent,
        PointerMoveEvent,
        PointerUpEvent,
        PointerCancelEvent;

/// Input actions for movement and abilities
enum InputAction {
  // Movement actions
  moveLeft,
  moveRight,
  moveUp,
  moveDown,
  jump,
  dash,

  // Ability actions
  primaryAbility,
  secondaryAbility,
  specialAbility1,
  specialAbility2,

  // System actions
  pause,
  interact,
  menu,
}

/// Buffered input event with timing information
class BufferedInput {
  final InputAction action;
  final bool isPressed;
  final double timestamp;
  final int entityId;
  bool isConsumed;
  final double bufferTime;

  BufferedInput({
    required this.action,
    required this.isPressed,
    required this.timestamp,
    required this.entityId,
    this.isConsumed = false,
    this.bufferTime = 150.0, // 150ms default buffer
  });

  /// Check if this buffered input has expired
  bool get isExpired {
    final currentTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    return (currentTime - timestamp) > bufferTime;
  }
}

/// Input sequence for complex movement combinations
class InputSequence {
  final List<BufferedInput> events;
  final double sequenceStartTime;
  final double sequenceDuration;

  InputSequence({
    required this.events,
    required this.sequenceStartTime,
  }) : sequenceDuration = events.isNotEmpty
            ? events.last.timestamp - events.first.timestamp
            : 0.0;
}

/// System that manages input processing and routing to entities
/// Handles keyboard, touch, and gamepad input and distributes to entities with input components
///
/// ARCHITECTURE:
/// -------------
/// InputSystem is the bridge between user interactions and game entities.
/// It integrates with other systems in the following ways:
/// - Processes raw input events from multiple device types (keyboard, touch, gamepad)
/// - Routes input to entities with InputComponent
/// - Maintains input state for consistent behavior across frames
/// - Provides virtual controller support for touch-based platforms
/// - **NEW**: Implements IMovementHandler interface for coordination with MovementSystem
/// - **NEW**: Generates MovementRequest objects instead of direct movement calls
/// - **NEW**: Includes input buffering system for responsive gameplay
///
/// PERFORMANCE CONSIDERATIONS:
/// ---------------------------
/// - Input events are processed once and distributed efficiently
/// - Focused entity approach prevents unnecessary input processing
/// - Input buffering provides responsive controls across varying frame rates
/// - <2 frame input lag target for competitive gameplay
///
/// CONFIGURATION OPTIONS:
/// ---------------------
/// - Enable/disable different input methods (keyboard, touch, gamepad)
/// - Virtual controller positioning and sensitivity
/// - Input mapping for different control schemes
/// - Feature flag support for gradual rollout
///
/// USAGE EXAMPLES:
/// --------------
/// ```dart
/// // Set player as focused entity for direct input
/// inputSystem.setFocusedEntity(player);
///
/// // Enable virtual controller for mobile
/// inputSystem.setVirtualControllerActive(true);
///
/// // Check if a key is currently pressed
/// bool isJumping = inputSystem.isKeyPressed(LogicalKeyboardKey.space);
/// ```
class InputSystem extends BaseFlameSystem implements IMovementHandler {
  InputSystem();

  bool _useKeyboard = true;
  bool _useTouch = true;
  bool _useGamepad = false;

  // Movement coordination (will be injected later)
  IMovementCoordinator? _movementCoordinator;

  // Input state tracking
  final Map<LogicalKeyboardKey, bool> _keyStates = <LogicalKeyboardKey, bool>{};
  final Map<int, Vector2> _touchPositions = <int, Vector2>{};
  // Movement key tracking for left/right movement
  final Map<String, bool> _movementKeys = <String, bool>{
    'move_left': false,
    'move_right': false,
    'jump': false,
  };

  // Jump input tracking for enhanced responsiveness
  bool _jumpPressed = false;
  bool _jumpPressedThisFrame = false;

  // Virtual controller (for touch/mobile)
  bool _virtualControllerActive = false;
  // Used for virtual controller position tracking
  final Map<String, Vector2> _virtualControllerPositions = <String, Vector2>{};
  final Map<String, bool> _virtualControllerPressed = <String, bool>{};

  // Focus entity (e.g., player) that receives direct input
  Entity? _focusedEntity;

  // Input buffering
  final Queue<BufferedInput> _inputBuffer = Queue<BufferedInput>();
  bool _inputBufferEnabled = true;
  double _lastInputTime = 0.0;

  @override
  void update(double dt) {
    if (!isActive) return;

    // Reset frame-based jump tracking
    _jumpPressedThisFrame = false;

    // Process input for focused entity first (usually the player)
    if (_focusedEntity != null && _focusedEntity!.isActive) {
      processEntityInput(_focusedEntity!);
    }

    // Process buffered inputs for all entities
    _processBufferedInputs(dt);

    super.update(dt);
  }

  /// Process buffered inputs for all entities
  void _processBufferedInputs(double dt) {
    final double currentTime = _lastInputTime + dt;
    while (_inputBuffer.isNotEmpty) {
      final BufferedInput bufferedInput = _inputBuffer.first;
      if (bufferedInput.isExpired) {
        _inputBuffer.removeFirst(); // Remove expired input
      } else {
        // Process the buffered input
        _processInputAction(bufferedInput.action, bufferedInput.isPressed);
        break; // Only process one input per frame for consistency
      }
    }
    _lastInputTime = currentTime;
  }

  /// Process a single input action
  void _processInputAction(InputAction action, bool isPressed) {
    // Find entities interested in this input action
    final Iterable<Entity> entities = _findEntitiesByInputAction(action);
    for (Entity entity in entities) {
      // Generate movement request using action mapping
      final MovementRequest? request =
          _generateMovementRequest(entity, action, isPressed);
      if (request != null) {
        // Submit the request through IMovementHandler interface
        submitMovementRequest(request);
      }
    }
  }

  /// Generate MovementRequest from InputAction with proper action mapping
  MovementRequest? _generateMovementRequest(
    Entity entity,
    InputAction action,
    bool isPressed,
  ) {
    // Convert entity ID from String to int (simple hash for now)
    final int entityId = entity.id.hashCode;

    // Only generate requests for key press, not release (except for stop actions)
    if (!isPressed &&
        action != InputAction.moveLeft &&
        action != InputAction.moveRight) {
      return null;
    }

    // Map InputAction to MovementType and direction
    switch (action) {
      case InputAction.moveLeft:
        return MovementRequest(
          entityId: entityId,
          type: isPressed ? MovementType.walk : MovementType.stop,
          direction: Vector2(-1, 0),
          magnitude: isPressed ? 200.0 : 0.0, // Standard walk speed
        );

      case InputAction.moveRight:
        return MovementRequest(
          entityId: entityId,
          type: isPressed ? MovementType.walk : MovementType.stop,
          direction: Vector2(1, 0),
          magnitude: isPressed ? 200.0 : 0.0, // Standard walk speed
        );

      case InputAction.jump:
        if (isPressed) {
          return MovementRequest(
            entityId: entityId,
            type: MovementType.jump,
            direction: Vector2(0, -1),
            magnitude: 400.0, // Jump force
            priority: MovementPriority.high,
          );
        }
        break;

      case InputAction.dash:
        if (isPressed) {
          // Get current movement direction for dash
          final direction = _getCurrentMovementDirection();
          return MovementRequest(
            entityId: entityId,
            type: MovementType.dash,
            direction: direction,
            magnitude: 600.0, // Dash speed
            priority: MovementPriority.high,
          );
        }
        break;

      default:
        // Non-movement actions handled separately
        break;
    }

    return null;
  }

  /// Get current movement direction based on input state
  Vector2 _getCurrentMovementDirection() {
    double x = 0.0;
    if (_movementKeys['move_left'] == true) x -= 1.0;
    if (_movementKeys['move_right'] == true) x += 1.0;

    // Default to right if no direction is pressed
    if (x == 0.0) x = 1.0;

    return Vector2(x, 0).normalized();
  }

  /// Find entities interested in a specific input action
  Iterable<Entity> _findEntitiesByInputAction(InputAction action) {
    // For now, focus on the active entity
    if (_focusedEntity != null && _focusedEntity!.isActive) {
      return [_focusedEntity!];
    }
    return [];
  }

  @override
  void processEntity(Entity entity, double dt) {
    if (entity == _focusedEntity) {
      return; // Skip focused entity, already processed
    }

    processEntityInput(entity);
  }

  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity is the focused entity or has an input component
    return entity == _focusedEntity ||
        entity.children.whereType<InputComponent>().isNotEmpty;
  }

  /// Process input for a specific entity
  void processEntityInput(Entity entity) {
    // Find input component on the entity
    final Iterable<InputComponent> inputComponents =
        entity.children.whereType<InputComponent>();
    if (inputComponents.isEmpty) return;

    final InputComponent inputComponent = inputComponents.first;

    // Update input component with current movement states
    _updateEntityMovementInput(inputComponent);
  }

  /// Update entity's input component with current movement key states
  void _updateEntityMovementInput(InputComponent inputComponent) {
    // Update movement actions based on current key states
    inputComponent.setActionState(
      'move_left',
      _movementKeys['move_left'] ?? false,
    );
    inputComponent.setActionState(
      'move_right',
      _movementKeys['move_right'] ?? false,
    );

    // Use enhanced jump tracking for better responsiveness
    inputComponent.setActionState('jump', _jumpPressedThisFrame);
  }

  /// Handle raw key events from Flutter
  void handleKeyEvent(KeyEvent event) {
    if (!isActive || !_useKeyboard) return;

    final LogicalKeyboardKey key = event.logicalKey;
    final bool isKeyDown = event is KeyDownEvent;

    // Update key state
    _keyStates[key] = isKeyDown;

    // Update movement key tracking based on keyboard input
    _updateMovementKeysFromInput(key, isKeyDown);

    // Forward to focused entity
    if (_focusedEntity != null) {
      final Iterable<InputComponent> inputComponents =
          _focusedEntity!.children.whereType<InputComponent>();
      if (inputComponents.isNotEmpty) {
        inputComponents.first.handleKeyEvent(event);
      }
    }
  }

  /// Update movement key states from keyboard input
  void _updateMovementKeysFromInput(LogicalKeyboardKey key, bool isPressed) {
    switch (key) {
      // Left movement keys (Arrow Left, A)
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        _movementKeys['move_left'] = isPressed;
        break;

      // Right movement keys (Arrow Right, D)
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        _movementKeys['move_right'] = isPressed;
        break;

      // Jump keys (Arrow Up, W, Space)
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
      case LogicalKeyboardKey.space:
        _movementKeys['jump'] = isPressed;

        // Enhanced jump input tracking
        if (isPressed && !_jumpPressed) {
          _jumpPressedThisFrame = true;
        }
        _jumpPressed = isPressed;
        break;
    }
  }

  /// Handle pointer events (for touch controls)
  void handlePointerEvent(PointerEvent event) {
    if (!isActive || !_useTouch) return;

    // Handle touch input
    if (event is PointerDownEvent) {
      _touchPositions[event.pointer] =
          Vector2(event.position.dx, event.position.dy);
    } else if (event is PointerMoveEvent) {
      _touchPositions[event.pointer] =
          Vector2(event.position.dx, event.position.dy);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _touchPositions.remove(event.pointer);
    }

    // Process virtual controller if active
    if (_virtualControllerActive) {
      _processVirtualController(event);
    }
  }

  /// Process virtual controller interactions
  void _processVirtualController(PointerEvent event) {
    // Implementation placeholder for touch controls in future sprint
    // This would handle touch interactions with virtual controller elements
    // For example:
    // - D-pad/joystick for movement
    // - Action buttons
    // - Menu buttons

    // Then update _virtualControllerPressed state and notify entities
  }

  /// Helper method for backward compatibility
  @override
  void registerEntity(Entity entity) {
    addEntity(entity);
  }

  /// Helper method for backward compatibility
  @override
  void unregisterEntity(Entity entity) {
    removeEntity(entity);
  }

  /// Set the focused entity (usually the player)
  void setFocusedEntity(Entity entity) {
    _focusedEntity = entity;
    addEntity(entity); // Ensure it's registered
  }

  /// Enable or disable the virtual controller
  void setVirtualControllerActive(bool active) {
    _virtualControllerActive = active;
  }

  /// Clear all input states
  void clearInputStates() {
    _keyStates.clear();
    _touchPositions.clear();
    _virtualControllerPressed.clear();
    _movementKeys.updateAll((key, value) => false);
    _jumpPressed = false;
    _jumpPressedThisFrame = false;
  }

  /// Get current movement key state
  bool isMovementKeyPressed(String action) => _movementKeys[action] ?? false;

  /// Set system active state
  @override
  void setActive(bool active) {
    isActive = active;
    if (!isActive) {
      clearInputStates();
    }
  }

  /// Enable/disable input devices
  void setInputDevices({bool? keyboard, bool? touch, bool? gamepad}) {
    if (keyboard != null) _useKeyboard = keyboard;
    if (touch != null) _useTouch = touch;
    if (gamepad != null) _useGamepad = gamepad;
  }

  // Getters
  Entity? get focusedEntity => _focusedEntity;
  bool get isKeyboardEnabled => _useKeyboard;
  bool get isTouchEnabled => _useTouch;
  bool get isGamepadEnabled => _useGamepad;
  bool isKeyPressed(LogicalKeyboardKey key) => _keyStates[key] ?? false;
  bool get isVirtualControllerActive => _virtualControllerActive;

  @override
  void initialize() {
    // Initialize input system
  }

  @override
  void dispose() {
    super.dispose(); // Call base class implementation
    _keyStates.clear();
    _touchPositions.clear();
    _virtualControllerPositions.clear();
    _virtualControllerPressed.clear();
    _movementKeys.clear();
  }

  @override
  void onEntityAdded(Entity entity) {
    // Additional setup when entity is added to system
  }
  @override
  void onEntityRemoved(Entity entity) {
    if (_focusedEntity == entity) {
      _focusedEntity = null;
    }
  }

  // ============================================================================
  // IMovementHandler Implementation
  // ============================================================================

  @override
  Future<bool> submitMovementRequest(MovementRequest request) async {
    try {
      // If movement coordinator is available, forward the request
      if (_movementCoordinator != null) {
        final response =
            await _movementCoordinator!.submitMovementRequest(request);
        return response.wasSuccessful;
      }

      // Fallback: Apply movement directly to InputComponent for backward compatibility
      _applyMovementRequestToEntity(request);
      return true;
    } catch (e) {
      onInputProcessingError('Failed to submit movement request: $e');
      return false;
    }
  }

  @override
  Future<bool> submitMovementSequence(List<MovementRequest> requests) async {
    bool allSuccessful = true;
    for (final request in requests) {
      final success = await submitMovementRequest(request);
      if (!success) allSuccessful = false;
    }
    return allSuccessful;
  }

  @override
  Future<bool> canProcessInput(int entityId) async {
    // Check if entity exists and input processing is enabled
    final entity = _findEntityById(entityId);
    return entity != null && isActive && _inputBufferEnabled;
  }

  @override
  Future<bool> canProcessMovementType(
    int entityId,
    MovementType movementType,
  ) async {
    final entity = _findEntityById(entityId);
    if (entity == null) return false;

    // Basic validation - more complex validation would involve physics state
    switch (movementType) {
      case MovementType.walk:
        return true; // Walking generally always allowed
      case MovementType.jump:
        return true; // Jump capability would be validated by physics system
      case MovementType.dash:
        return true; // Dash availability would be validated by movement system
      case MovementType.stop:
        return true; // Stopping always allowed
      case MovementType.impulse:
        return true; // Impulse handled by physics system
    }
  }

  @override
  Future<void> notifyInputProcessed(MovementRequest request) async {
    // Log successful input processing
    print(
      'Input processed successfully: ${request.type} for entity ${request.entityId}',
    );
  }

  @override
  Future<void> notifyInputFailed(MovementRequest request, String reason) async {
    // Log failed input processing
    print(
      'Input processing failed: ${request.type} for entity ${request.entityId} - $reason',
    );
  }

  @override
  void clearInputBuffer(int entityId) {
    // Remove all buffered inputs for the specified entity
    _inputBuffer.removeWhere((input) => input.entityId == entityId);
  }

  @override
  void setInputBufferEnabled(bool enabled) {
    _inputBufferEnabled = enabled;
    if (!enabled) {
      // Clear buffer when disabled
      _inputBuffer.clear();
    }
  }

  @override
  void onInputProcessingError(String error) {
    print('Input processing error: $error');
    // In a production system, this would integrate with error reporting
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Find entity by ID (convert int back to string for lookup)
  Entity? _findEntityById(int entityId) {
    // For now, check if it matches the focused entity
    if (_focusedEntity != null && _focusedEntity!.id.hashCode == entityId) {
      return _focusedEntity;
    }
    return null;
  }

  /// Apply movement request directly to entity InputComponent (fallback)
  void _applyMovementRequestToEntity(MovementRequest request) {
    final entity = _findEntityById(request.entityId);
    if (entity == null) return;

    final inputComponents = entity.children.whereType<InputComponent>();
    if (inputComponents.isEmpty) return;

    final inputComponent = inputComponents.first;

    // Convert MovementRequest back to input actions for backward compatibility
    switch (request.type) {
      case MovementType.walk:
        if (request.direction.x > 0) {
          inputComponent.setActionState('move_right', request.magnitude > 0);
        } else if (request.direction.x < 0) {
          inputComponent.setActionState('move_left', request.magnitude > 0);
        }
        break;
      case MovementType.jump:
        inputComponent.setActionState('jump', request.magnitude > 0);
        break;
      case MovementType.stop:
        inputComponent.setActionState('move_left', false);
        inputComponent.setActionState('move_right', false);
        break;
      default:
        // Other movement types handled by movement system
        break;
    }
  }

  /// Set movement coordinator for dependency injection
  void setMovementCoordinator(IMovementCoordinator coordinator) {
    _movementCoordinator = coordinator;
  }
}

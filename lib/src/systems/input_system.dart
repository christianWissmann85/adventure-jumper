import 'package:flame/components.dart';
import 'package:flutter/gestures.dart'; // Add pointer events
import 'package:flutter/services.dart';

import '../components/input_component.dart';
import '../entities/entity.dart';
import 'base_flame_system.dart';

// Export pointer events for easy use
export 'package:flutter/gestures.dart'
    show
        PointerEvent,
        PointerDownEvent,
        PointerMoveEvent,
        PointerUpEvent,
        PointerCancelEvent;

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
///
/// PERFORMANCE CONSIDERATIONS:
/// ---------------------------
/// - Input events are processed once and distributed efficiently
/// - Focused entity approach prevents unnecessary input processing
/// - Input buffering provides responsive controls across varying frame rates
///
/// CONFIGURATION OPTIONS:
/// ---------------------
/// - Enable/disable different input methods (keyboard, touch, gamepad)
/// - Virtual controller positioning and sensitivity
/// - Input mapping for different control schemes
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
class InputSystem extends BaseFlameSystem {
  InputSystem();

  bool _useKeyboard = true;
  bool _useTouch = true;
  bool _useGamepad = false;

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
  @override
  void update(double dt) {
    if (!isActive) return;

    // Reset frame-based jump tracking
    _jumpPressedThisFrame = false;

    // Process input for focused entity first (usually the player)
    if (_focusedEntity != null && _focusedEntity!.isActive) {
      processEntityInput(_focusedEntity!);
    }

    super.update(dt);
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
}

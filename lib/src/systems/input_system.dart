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
class InputSystem extends BaseFlameSystem {
  InputSystem();

  bool _useKeyboard = true;
  bool _useTouch = true;
  bool _useGamepad = false;

  int _priority = 0;
  @override
  int get priority => _priority;
  @override
  set priority(int value) => _priority = value;

  // Input state tracking
  final Map<LogicalKeyboardKey, bool> _keyStates = <LogicalKeyboardKey, bool>{};
  final Map<int, Vector2> _touchPositions = <int, Vector2>{};

  // Movement key tracking for left/right movement
  final Map<String, bool> _movementKeys = <String, bool>{
    'move_left': false,
    'move_right': false,
    'jump': false,
  };

  // Virtual controller (for touch/mobile)
  bool _virtualControllerActive = false;
  // Used for virtual controller position tracking
  final Map<String, Vector2> _virtualControllerPositions = <String, Vector2>{};
  final Map<String, bool> _virtualControllerPressed = <String, bool>{};

  // Focus entity (e.g., player) that receives direct input
  Entity? _focusedEntity;

  @override
  void update(double dt) {
    if (!_isActive) return;

    // Process input for focused entity first (usually the player)
    if (_focusedEntity != null && _focusedEntity!.isActive) {
      processEntityInput(_focusedEntity!);
    }

    // Process input for other entities
    for (final Entity entity in _entities) {
      if (entity == _focusedEntity) {
        continue; // Skip focused entity, already processed
      }
      if (!entity.isActive) continue;

      processEntityInput(entity);
    }
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
        'move_left', _movementKeys['move_left'] ?? false);
    inputComponent.setActionState(
        'move_right', _movementKeys['move_right'] ?? false);
    inputComponent.setActionState('jump', _movementKeys['jump'] ?? false);
  }

  /// Handle raw key events from Flutter
  void handleKeyEvent(KeyEvent event) {
    if (!_isActive || !_useKeyboard) return;

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
        break;
    }
  }

  /// Handle pointer events (for touch controls)
  void handlePointerEvent(PointerEvent event) {
    if (!_isActive || !_useTouch) return;

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

  /// Register an entity with this system
  void registerEntity(Entity entity) {
    if (!_entities.contains(entity)) {
      _entities.add(entity);
    }
  }

  /// Unregister an entity from this system
  void unregisterEntity(Entity entity) {
    _entities.remove(entity);
    if (_focusedEntity == entity) {
      _focusedEntity = null;
    }
  }

  /// Set the focused entity (usually the player)
  void setFocusedEntity(Entity entity) {
    _focusedEntity = entity;
    registerEntity(entity); // Ensure it's registered
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
  }

  /// Get current movement key state
  bool isMovementKeyPressed(String action) => _movementKeys[action] ?? false;

  /// Set system active state
  void setActive(bool active) {
    _isActive = active;
    if (!_isActive) {
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
  int get entityCount => _entities.length;
  Entity? get focusedEntity => _focusedEntity;
  bool get isKeyboardEnabled => _useKeyboard;
  bool get isTouchEnabled => _useTouch;
  bool get isGamepadEnabled => _useGamepad;
  bool isKeyPressed(LogicalKeyboardKey key) => _keyStates[key] ?? false;
  bool get isVirtualControllerActive => _virtualControllerActive;

  // System interface implementation
  @override
  void initialize() {
    // Initialize input system
  }

  @override
  void dispose() {
    _entities.clear();
    _keyStates.clear();
    _touchPositions.clear();
    _virtualControllerPositions.clear();
    _virtualControllerPressed.clear();
    _movementKeys.clear();
  }

  @override
  void addEntity(Entity entity) {
    if (!_entities.contains(entity)) {
      _entities.add(entity);
    }
  }

  @override
  void removeEntity(Entity entity) {
    _entities.remove(entity);
    if (_focusedEntity == entity) {
      _focusedEntity = null;
    }
  }
}

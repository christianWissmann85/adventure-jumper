import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'input_modes.dart';

/// Component that handles input state tracking for entities
/// Manages key states, virtual controllers, and input buffering
class InputComponent extends Component {
  InputComponent({
    InputMode? inputMode,
    InputSource? inputSource,
    InputBufferingMode? bufferingMode,
  }) {
    if (inputMode != null) {
      _inputMode = inputMode;
      _isActive = inputMode == InputMode.active;
    }

    if (inputSource != null) {
      _inputSource = inputSource;
      _useKeyboard = inputSource == InputSource.keyboard || inputSource == InputSource.both;
      _useVirtualController = inputSource == InputSource.virtualController || inputSource == InputSource.both;
    }

    if (bufferingMode != null) {
      _bufferingMode = bufferingMode;
      _enableInputBuffering = bufferingMode == InputBufferingMode.enabled;
    }
  } // Input state tracking
  InputMode _inputMode = InputMode.active;
  InputSource _inputSource = InputSource.keyboard;
  InputBufferingMode _bufferingMode = InputBufferingMode.enabled;
  // Internal state tracking - primary API uses enums
  bool _isActive = true; // Whether input processing is enabled
  bool _useKeyboard = true; // Whether keyboard input is accepted
  bool _useVirtualController = false; // Whether touch controls are accepted
  bool _enableInputBuffering = true; // Whether input buffer timing is active
  // Getters for new enum-based API
  InputMode get inputMode => _inputMode;
  InputSource get inputSource => _inputSource;
  InputBufferingMode get bufferingMode => _bufferingMode;

  // Keyboard state
  final Map<LogicalKeyboardKey, bool> _keyStates = <LogicalKeyboardKey, bool>{};
  final Map<String, bool> _actionStates = <String,
      bool>{}; // Virtual controller state (touch controls)  // These fields will be used in future virtual controller implementation
  // TODO(input): Implement touch controls in Sprint 4.
  // Keep marked as unused with _ prefix until implementation
  // ignore: unused_field
  bool _virtualLeftPressed = false;
  // ignore: unused_field
  bool _virtualRightPressed = false;
  // ignore: unused_field
  bool _virtualJumpPressed = false;
  // ignore: unused_field
  bool _virtualActionPressed = false;

  // Input buffer for delayed actions (useful for tight timing windows)
  final Map<String, double> _inputBuffer = <String, double>{};
  final double _inputBufferTime = 0.15; // Buffer window in seconds

  // Action mapping
  final Map<LogicalKeyboardKey, String> _keyActionMap = <LogicalKeyboardKey, String>{
    LogicalKeyboardKey.arrowLeft: 'move_left',
    LogicalKeyboardKey.arrowRight: 'move_right',
    LogicalKeyboardKey.arrowUp: 'jump',
    LogicalKeyboardKey.arrowDown: 'duck',
    LogicalKeyboardKey.keyA: 'move_left',
    LogicalKeyboardKey.keyD: 'move_right',
    LogicalKeyboardKey.keyW: 'jump',
    LogicalKeyboardKey.keyS: 'duck',
    LogicalKeyboardKey.space: 'jump',
    LogicalKeyboardKey.keyZ: 'action1',
    LogicalKeyboardKey.keyX: 'action2',
    LogicalKeyboardKey.keyC: 'action3',
    LogicalKeyboardKey.escape: 'pause',
  }; // Callbacks
  void Function(String actionName, bool actionValue)? onActionChanged;

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    // Update input buffer timers and clear expired ones
    if (_enableInputBuffering) {
      final List<String> expiredBuffers = <String>[];

      for (final String action in _inputBuffer.keys) {
        _inputBuffer[action] = _inputBuffer[action]! - dt;
        if (_inputBuffer[action]! <= 0) {
          expiredBuffers.add(action);
        }
      }

      for (final String action in expiredBuffers) {
        _inputBuffer.remove(action);
      }
    }
  }

  /// Process a key event
  void handleKeyEvent(KeyEvent event) {
    if (!_isActive || !_useKeyboard) return;

    final LogicalKeyboardKey key = event.logicalKey;
    final bool isKeyDown = event is KeyDownEvent;

    // Update key state
    _keyStates[key] = isKeyDown;

    // Map to action if defined
    if (_keyActionMap.containsKey(key)) {
      final String action = _keyActionMap[key]!;
      setActionState(action, isKeyDown);
    }
  }

  /// Set virtual controller button state
  void setVirtualButtonState(String button, bool isPressed) {
    if (!_isActive || !_useVirtualController) return;

    switch (button) {
      case 'left':
        _virtualLeftPressed = isPressed;
        setActionState('move_left', isPressed);
        break;
      case 'right':
        _virtualRightPressed = isPressed;
        setActionState('move_right', isPressed);
        break;
      case 'jump':
        _virtualJumpPressed = isPressed;
        setActionState('jump', isPressed);
        break;
      case 'action':
        _virtualActionPressed = isPressed;
        setActionState('action1', isPressed);
        break;
      default:
        // Handle other virtual buttons
        setActionState(button, isPressed);
        break;
    }
  }

  /// Set action state and trigger callbacks
  void setActionState(String action, bool state) {
    final bool previousState = _actionStates[action] ?? false;

    // Only process if state actually changed
    if (previousState != state) {
      _actionStates[action] = state;

      // Add to input buffer if new press
      if (state && _enableInputBuffering) {
        _inputBuffer[action] = _inputBufferTime;
      }

      // Trigger callback
      if (onActionChanged != null) {
        onActionChanged!(action, state);
      }
    }
  }

  /// Check if an action is currently active
  bool isActionActive(String action) {
    return _actionStates[action] ?? false;
  }

  /// Check if an action was recently pressed (within buffer window)
  bool isActionBuffered(String action) {
    return _inputBuffer.containsKey(action);
  }

  /// Clear the input buffer for a specific action
  void consumeBufferedAction(String action) {
    _inputBuffer.remove(action);
  }

  /// Clear all input states
  void clearAllInputs() {
    _keyStates.clear();
    _actionStates.clear();
    _inputBuffer.clear();
    _virtualLeftPressed = false;
    _virtualRightPressed = false;
    _virtualJumpPressed = false;
    _virtualActionPressed = false;
  }

  /// Set the input mode (active or inactive)
  void setInputMode(InputMode mode) {
    _inputMode = mode;
    _isActive = mode == InputMode.active;
  }

  /// Set the input source (keyboard, virtual controller, both, or none)
  void setInputSource(InputSource source) {
    _inputSource = source;
    switch (source) {
      case InputSource.keyboard:
        _useKeyboard = true;
        _useVirtualController = false;
        break;
      case InputSource.virtualController:
        _useKeyboard = false;
        _useVirtualController = true;
        break;
      case InputSource.both:
        _useKeyboard = true;
        _useVirtualController = true;
        break;
      case InputSource.none:
        _useKeyboard = false;
        _useVirtualController = false;
        break;
    }
  }

  /// Set the input buffering mode
  void setBufferingMode(InputBufferingMode mode) {
    _bufferingMode = mode;
    _enableInputBuffering = mode == InputBufferingMode.enabled;
  }

  /// Set active state
  void setActive(bool active) {
    if (_isActive != active) {
      _isActive = active;

      if (!_isActive) {
        // Clear all inputs when deactivating
        clearAllInputs();
      }
    }
  }

  /// Remap a key to an action
  void remapKey(LogicalKeyboardKey key, String action) {
    _keyActionMap[key] = action;
  }

  // Getters
  bool get isActive => _isActive;
  Map<String, bool> get actionStates => Map<String, bool>.unmodifiable(_actionStates);
}

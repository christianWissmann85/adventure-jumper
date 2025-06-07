import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../systems/interfaces/movement_request.dart';
import '../systems/interfaces/physics_state.dart';
import '../utils/logger.dart';
import 'input_modes.dart';
import 'interfaces/input_integration.dart';

/// PHY-3.1.4: Enhanced InputComponent with movement request generation
///
/// Component that handles input state tracking for entities
/// Manages key states, virtual controllers, and input buffering
///
/// Key enhancements:
/// - Movement request generation and input validation with physics state
/// - Accumulation prevention for rapid input sequences
/// - Integration with MovementRequest structures and validation
/// - Physics state synchronization for input validation
class InputComponent extends Component implements IInputIntegration {
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
      _useKeyboard = inputSource == InputSource.keyboard ||
          inputSource == InputSource.both;
      _useVirtualController = inputSource == InputSource.virtualController ||
          inputSource == InputSource.both;
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

  // PHY-3.1.4: Physics integration and accumulation prevention
  PhysicsState? _lastPhysicsState;
  MovementCapabilities _currentCapabilities =
      MovementCapabilities.defaultPlayer();
  final Map<String, double> _lastInputTime = <String, double>{};
  final Map<String, int> _inputFrequency = <String, int>{};
  bool _isGrounded = false;

  // Input frequency limits (actions per second)
  static const double _maxInputFrequency = 10.0; // Max 10 inputs per second
  static const double _inputCooldown = 0.1; // 100ms between same inputs

  // Logger for input events
  static final _logger = GameLogger.getLogger('InputComponent');

  // Action mapping
  final Map<LogicalKeyboardKey, String> _keyActionMap =
      <LogicalKeyboardKey, String>{
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
    LogicalKeyboardKey.shift: 'dash',
    LogicalKeyboardKey.keyE: 'interact',
  }; // Callbacks
  void Function(String actionName, bool actionValue)? onActionChanged;

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    // Update time tracking for individual actions
    final actionsToUpdate = _lastInputTime.keys.toList();
    for (final action in actionsToUpdate) {
      _lastInputTime[action] = (_lastInputTime[action] ?? 0.0) + dt;
    }

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

    // PHY-3.1.4: Update input timing for accumulation prevention
    final List<String> expiredInputs = <String>[];
    for (final entry in _lastInputTime.entries) {
      _lastInputTime[entry.key] = entry.value + dt;
      // Clear old input frequency tracking after 1 second
      if (_lastInputTime[entry.key]! > 1.0) {
        expiredInputs.add(entry.key);
      }
    }

    for (final action in expiredInputs) {
      _lastInputTime.remove(action);
      _inputFrequency.remove(action);
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
      // PHY-3.1.4: Check input frequency for accumulation prevention
      if (state) {
        final lastTime = _lastInputTime[action] ?? _inputCooldown;
        final frequency = _inputFrequency[action] ?? 0;

        if (lastTime < _inputCooldown || frequency > _maxInputFrequency) {
          _logger.fine('Input frequency exceeded for action: $action');
          return;
        }
      }

      _actionStates[action] = state;

      // Add to input buffer if new press
      if (state && _enableInputBuffering) {
        _inputBuffer[action] = _inputBufferTime;
      }

      // PHY-3.1.4: Track input timing
      if (state) {
        _lastInputTime[action] = 0.0;
        _inputFrequency[action] = (_inputFrequency[action] ?? 0) + 1;
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
  Map<String, bool> get actionStates =>
      Map<String, bool>.unmodifiable(_actionStates);

  // ============================================================================
  // PHY-3.1.4: IInputIntegration Implementation
  // ============================================================================

  @override
  Future<MovementRequest?> generateMovementRequest() async {
    if (!_isActive) return null;

    // Check for movement input
    final direction = await getMovementDirection();
    final isJumping = await isJumpRequested();
    final isDashing = await isDashRequested();

    // No input, no request
    if (direction.isZero() && !isJumping && !isDashing) {
      return null;
    }

    // Validate input against physics state
    if (_lastPhysicsState != null) {
      if (isJumping && !await validateInputAction('jump', _lastPhysicsState!)) {
        // Can't jump, but might still be able to move
        if (direction.isZero()) return null;
      }
    }

    // Create movement request
    final requestType = isJumping
        ? MovementType.jump
        : isDashing
            ? MovementType.dash
            : MovementType.walk;

    return MovementRequest(
      entityId: parent?.hashCode ?? 0,
      type: requestType,
      direction: direction,
      magnitude: _currentCapabilities.maxSpeed,
    );
  }

  @override
  Future<bool> validateInputAction(
      String action, PhysicsState physicsState,) async {
    switch (action) {
      case 'jump':
        // Can jump if grounded or have jumps remaining
        return physicsState.isGrounded ||
            _currentCapabilities.jumpsRemaining > 0;

      case 'move_left':
      case 'move_right':
        // Can always attempt to move (physics will handle blocking)
        return _currentCapabilities.canMove;

      case 'dash':
        // Can dash if capability available and not on cooldown
        return _currentCapabilities.canDash &&
            (_lastInputTime['dash'] ?? _inputCooldown) >= _inputCooldown;

      default:
        return true;
    }
  }

  @override
  Future<bool> hasActiveMovementInput() async {
    return isActionActive('move_left') ||
        isActionActive('move_right') ||
        isActionActive('jump') ||
        isActionActive('dash');
  }

  @override
  Future<Vector2> getMovementDirection() async {
    double x = 0;

    if (isActionActive('move_left')) x -= 1;
    if (isActionActive('move_right')) x += 1;

    // Vertical movement for climbing/swimming (future feature)
    double y = 0;
    if (_currentCapabilities.canClimb) {
      if (isActionActive('move_up')) y -= 1;
      if (isActionActive('move_down')) y += 1;
    }

    return Vector2(x, y);
  }

  @override
  Future<bool> isJumpRequested() async {
    return isActionActive('jump') || isActionBuffered('jump');
  }

  @override
  Future<bool> isDashRequested() async {
    return isActionActive('dash') || isActionBuffered('dash');
  }

  @override
  Future<List<String>> getActiveSpecialActions() async {
    final specialActions = <String>[];

    if (isActionActive('action1')) specialActions.add('action1');
    if (isActionActive('action2')) specialActions.add('action2');
    if (isActionActive('action3')) specialActions.add('action3');

    return specialActions;
  }

  @override
  Future<bool> canPerformAction(
      String action, MovementCapabilities capabilities,) async {
    switch (action) {
      case 'jump':
        return capabilities.canJump;
      case 'dash':
        return capabilities.canDash;
      case 'move_left':
      case 'move_right':
        return capabilities.canMove;
      default:
        return true;
    }
  }

  @override
  Future<bool> hasInputConflicts() async {
    // Check for opposing movement inputs
    final leftRight =
        isActionActive('move_left') && isActionActive('move_right');
    final upDown = isActionActive('move_up') && isActionActive('move_down');

    return leftRight || upDown;
  }

  @override
  Future<Map<String, bool>> resolveInputConflicts() async {
    final resolved = Map<String, bool>.from(_actionStates);

    // Resolve left/right conflict - favor most recent
    if (isActionActive('move_left') && isActionActive('move_right')) {
      final leftTime = _lastInputTime['move_left'] ?? double.infinity;
      final rightTime = _lastInputTime['move_right'] ?? double.infinity;

      if (leftTime < rightTime) {
        resolved['move_right'] = false;
      } else {
        resolved['move_left'] = false;
      }
    }

    return resolved;
  }

  @override
  Future<void> clearInputAccumulation() async {
    _inputBuffer.clear();
    _lastInputTime.clear();
    _inputFrequency.clear();
  }

  @override
  Future<bool> isInputFrequencyValid(String action) async {
    final lastTime = _lastInputTime[action] ?? _inputCooldown;
    final frequency = _inputFrequency[action] ?? 0;

    // Check cooldown
    if (lastTime < _inputCooldown) {
      return false;
    }

    // Check frequency limit
    if (frequency > _maxInputFrequency) {
      return false;
    }

    return true;
  }

  @override
  Future<double> getTimeSinceLastInput(String action) async {
    return _lastInputTime[action] ?? double.infinity;
  }

  @override
  Future<void> syncWithPhysics(PhysicsState physicsState) async {
    _lastPhysicsState = physicsState;

    // Update grounded state
    if (_isGrounded != physicsState.isGrounded) {
      onGroundedStateChanged(physicsState.isGrounded);
    }

    // Update capabilities based on physics state
    if (physicsState.isGrounded) {
      _currentCapabilities = _currentCapabilities.withGroundedState();
    } else {
      // Calculate jumps used (simplified - would need proper jump tracking)
      final jumpsUsed =
          _currentCapabilities.maxJumps - _currentCapabilities.jumpsRemaining;
      _currentCapabilities = _currentCapabilities.withAirborneState(jumpsUsed);
    }
  }

  @override
  void onPhysicsStateChanged(PhysicsState newState) {
    _logger.fine(
        'Physics state changed - grounded: ${newState.isGrounded}, velocity: ${newState.velocity}',);

    // Clear jump buffer if landing
    if (newState.isGrounded && !_isGrounded) {
      consumeBufferedAction('jump');
    }
  }

  @override
  void onGroundedStateChanged(bool isGrounded) {
    _isGrounded = isGrounded;
    _logger.fine('Grounded state changed: $isGrounded');

    // Reset jump count when landing
    if (isGrounded) {
      _currentCapabilities = _currentCapabilities.withGroundedState();
    }
  }
}

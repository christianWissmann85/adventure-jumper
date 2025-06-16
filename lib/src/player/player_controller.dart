import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../events/player_events.dart';
import '../game/game_config.dart';
import '../systems/interfaces/movement_coordinator.dart';
import '../systems/interfaces/physics_coordinator.dart';
import '../systems/interfaces/player_movement_request.dart';
import '../systems/interfaces/respawn_state.dart';
import 'player.dart';

/// Jump state for state machine (T2.3.2)
enum JumpState {
  grounded, // Player is on the ground
  jumping, // Player is ascending (jump button held or recently pressed)
  falling, // Player is descending
  landing // Player just landed (brief state for landing effects)
}

/// PHY-3.2.1: PlayerController using coordination interfaces
///
/// Controls player character based on input using request-based movement
/// through IMovementCoordinator and IPhysicsCoordinator interfaces.
/// No direct physics property modifications allowed.
class PlayerController extends Component {
  PlayerController(
    this.player, {
    IMovementCoordinator? movementCoordinator,
    IPhysicsCoordinator? physicsCoordinator,
  })  : _movementCoordinator = movementCoordinator,
        _physicsCoordinator = physicsCoordinator;

  final Player player;

  // Coordination interfaces (PHY-3.2.1)
  IMovementCoordinator? _movementCoordinator;
  IPhysicsCoordinator? _physicsCoordinator;

  // Input state
  bool _moveLeft = false;
  bool _moveRight = false;
  bool _jump = false;

  double _inputSmoothTimer = 0.0;
  bool _hasInputThisFrame = false;

  // Jump state machine
  JumpState _jumpState = JumpState.grounded;
  bool _jumpInputHeld = false;
  double _jumpHoldTime = 0.0;
  double _jumpBufferTimer = 0.0;
  double _landingTimer = 0.0;
  double _jumpCooldownTimer = 0.0;
  double _coyoteTimer = 0.0;

  // Edge detection state tracking
  // Legacy variables for compatibility
  bool _isJumping = false;
  bool _canJump = true;

  // Respawn system variables
  final double _fallThreshold = 1200.0;
  Vector2? _lastSafePosition;
  double _safePositionUpdateTimer = 0.0;
  static const double _safePositionUpdateInterval = 0.5;

  // PHY-3.2.3: State management for movement requests
  PlayerAction _lastPlayerAction = PlayerAction.idle;
  DateTime? _lastRequestTime;
  final Duration _inputSequenceWindow = const Duration(milliseconds: 50);
  int _rapidInputCounter = 0;
  DateTime? _rapidInputStartTime;
  static const int _rapidInputThreshold = 5; // 5 inputs in rapid succession
  static const Duration _rapidInputWindow = Duration(milliseconds: 200);

  @override
  Future<void> onLoad() async {
    try {
      developer.log(
        'PlayerController.onLoad() called',
        name: 'PlayerController.onLoad',
      );

      // Get entity ID for coordination
      _entityId = player.hashCode;

      // Initialize respawn system
      _lastSafePosition = player.position.clone();

      developer.log(
        'PlayerController.onLoad() completed',
        name: 'PlayerController.onLoad',
      );
    } catch (e, stackTrace) {
      developer.log(
        'ERROR in PlayerController.onLoad(): $e',
        name: 'PlayerController.onLoad',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Cache entity ID for requests
  late final int _entityId;

  @override
  void update(double dt) {
    super.update(dt);

    // Schedule async updates to run after this frame
    // This avoids async issues in the synchronous update method
    Future.microtask(() async {
      // Update jump state machine
      await _updateJumpStateMachine(dt);

      // Update timers
      await _updateTimers(dt);

      // Update respawn system
      await _updateRespawnSystem(dt);

      // Update movement smoothing
      await _updateMovementSmoothing(dt);

      // Update edge detection state
      await _updateEdgeDetection();
    });

    // Reset input tracking for this frame
    _hasInputThisFrame = false;

    // Process movement inputs - schedule as microtasks
    if (_moveLeft) {
      developer.log(
        'Processing _moveLeft input in update()',
        name: 'PlayerController.update',
      );
      Future.microtask(() => _movePlayerLeft(dt));
      _hasInputThisFrame = true;
    } else if (_moveRight) {
      developer.log(
        'Processing _moveRight input in update()',
        name: 'PlayerController.update',
      );
      Future.microtask(() => _movePlayerRight(dt));
      _hasInputThisFrame = true;
    } else {
      // Stop horizontal movement when no keys are pressed
      Future.microtask(() => _stopHorizontalMovement());
    }

    // Handle jump input with variable height
    if (_jump) {
      Future.microtask(() => _handleJumpInput());
      _jump = false; // Consume jump input
    }
  }

  /// Handle input action changes from InputComponent
  void handleInputAction(String actionName, bool actionValue) {
    developer.log(
      'handleInputAction called: $actionName = $actionValue',
      name: 'PlayerController.handleInputAction',
    );

    switch (actionName) {
      case 'move_left':
        _moveLeft = actionValue;
        break;
      case 'move_right':
        _moveRight = actionValue;
        break;
      case 'jump':
        if (!actionValue && _jumpInputHeld && _jumpState == JumpState.jumping) {
          // Jump button released - apply cut-off for variable height
          _applyJumpCutOff();
        }
        _jumpInputHeld = actionValue;
        if (actionValue && !_jump) {
          _jump = true;
        }
        break;
      default:
        break;
    }
  }

  /// PHY-3.2.1: Handle movement to the left using movement coordinator
  /// PHY-3.2.3: Enhanced with retry mechanism for failed requests
  void _movePlayerLeft(double dt) async {
    if (_movementCoordinator == null) {
      developer.log(
        'Movement coordinator not available - cannot move left',
        name: 'PlayerController._movePlayerLeft',
      );
      return;
    }

    // Determine appropriate movement parameters
    final bool isInAir = await _isPlayerInAir();
    double maxSpeed = isInAir
        ? GameConfig.maxAirSpeed
        : GameConfig.maxWalkSpeed;

    // Check for direction change boost
    // final currentVelocity = await _getCurrentVelocity(); // This was only used to set unused 'acceleration'
    // if (currentVelocity.x > 0) { // This was only used to set unused 'acceleration'
    //   // acceleration = isInAir // This was only used to set unused 'acceleration'
    //   //     ? GameConfig.airTurnAroundSpeed // This was only used to set unused 'acceleration'
    //   //     : GameConfig.playerAcceleration * 1.5; // This was only used to set unused 'acceleration'
    // } // This was only used to set unused 'acceleration'

    // PHY-3.2.3: Create movement request with retry capability
    final isInputSequence = _detectInputSequence();
    final request = PlayerMovementRequest.playerWalk(
      entityId: _entityId,
      direction: Vector2(-1, 0), // Left direction
      speed: maxSpeed,
      previousAction: _lastPlayerAction,
      isInputSequence: isInputSequence,
      previousRequestTime: _lastRequestTime,
    );

    // Update tracking
    _lastRequestTime = request.timestamp;
    _lastPlayerAction = PlayerAction.walk;

    // PHY-3.2.3: Check if rapid input requires accumulation prevention
    if (request.isRapidInput ||
        (_rapidInputCounter > _rapidInputThreshold / 2)) {
      developer.log(
        'Movement request has rapid input flag, may need accumulation prevention',
        name: 'PlayerController._movePlayerLeft',
      );
    }

    // PHY-3.2.1: Submit movement request instead of direct velocity modification
    var response = await _movementCoordinator!.handleMovementInput(
      _entityId,
      request.direction,
      request.magnitude,
    );

    // PHY-3.2.3: Retry with fallback speed if failed
    if (!response.wasSuccessful && request.retryCount < 2) {
      developer.log(
        'Left movement request failed: ${response.constraintReason}, retrying with reduced speed',
        name: 'PlayerController._movePlayerLeft',
      );

      final retryRequest = request.createRetryRequest(
        additionalErrorContext: {
          'originalFailure': response.constraintReason ?? 'Unknown',
          'attemptTime': DateTime.now().toIso8601String(),
        },
      );

      response = await _movementCoordinator!.handleMovementInput(
        retryRequest.entityId,
        retryRequest.direction,
        retryRequest.retrySpeed, // Use fallback speed
      );

      if (!response.wasSuccessful) {
        developer.log(
          'Retry failed: ${response.constraintReason}',
          name: 'PlayerController._movePlayerLeft',
        );
        // PHY-3.2.3: Emergency fallback maintains basic movement
        await _emergencyMovementFallback(Vector2(-1, 0));
      }
    } else if (response.wasSuccessful) {
      developer.log(
        'Player accelerating left${isInAir ? ' (air)' : ''} (applied velocity: ${response.actualVelocity.x.toStringAsFixed(1)})',
        name: 'PlayerController._movePlayerLeft',
      );
    }
  }

  /// PHY-3.2.1: Handle movement to the right using movement coordinator
  /// PHY-3.2.3: Enhanced with retry mechanism for failed requests
  void _movePlayerRight(double dt) async {
    if (_movementCoordinator == null) {
      developer.log(
        'Movement coordinator not available - cannot move right',
        name: 'PlayerController._movePlayerRight',
      );
      return;
    }

    // Determine appropriate movement parameters
    final bool isInAir = await _isPlayerInAir();
    double maxSpeed = isInAir
        ? GameConfig.maxAirSpeed
        : GameConfig.maxWalkSpeed;

    // Check for direction change boost
    // final currentVelocity = await _getCurrentVelocity(); // This was only used to set unused 'acceleration'
    // if (currentVelocity.x < 0) { // This was only used to set unused 'acceleration'
    //   // acceleration = isInAir // This was only used to set unused 'acceleration'
    //   //     ? GameConfig.airTurnAroundSpeed // This was only used to set unused 'acceleration'
    //   //     : GameConfig.playerAcceleration * 1.5; // This was only used to set unused 'acceleration'
    // } // This was only used to set unused 'acceleration'

    // PHY-3.2.3: Create movement request with retry capability
    final isInputSequence = _detectInputSequence();
    final request = PlayerMovementRequest.playerWalk(
      entityId: _entityId,
      direction: Vector2(1, 0), // Right direction
      speed: maxSpeed,
      previousAction: _lastPlayerAction,
      isInputSequence: isInputSequence,
      previousRequestTime: _lastRequestTime,
    );

    // Update tracking
    _lastRequestTime = request.timestamp;
    _lastPlayerAction = PlayerAction.walk;

    // PHY-3.2.3: Check if rapid input requires accumulation prevention
    if (request.isRapidInput ||
        (_rapidInputCounter > _rapidInputThreshold / 2)) {
      developer.log(
        'Movement request has rapid input flag, may need accumulation prevention',
        name: 'PlayerController._movePlayerRight',
      );
    }

    // PHY-3.2.1: Submit movement request instead of direct velocity modification
    var response = await _movementCoordinator!.handleMovementInput(
      _entityId,
      request.direction,
      request.magnitude,
    );

    // PHY-3.2.3: Retry with fallback speed if failed
    if (!response.wasSuccessful && request.retryCount < 2) {
      developer.log(
        'Right movement request failed: ${response.constraintReason}, retrying with reduced speed',
        name: 'PlayerController._movePlayerRight',
      );

      final retryRequest = request.createRetryRequest(
        additionalErrorContext: {
          'originalFailure': response.constraintReason ?? 'Unknown',
          'attemptTime': DateTime.now().toIso8601String(),
        },
      );

      response = await _movementCoordinator!.handleMovementInput(
        retryRequest.entityId,
        retryRequest.direction,
        retryRequest.retrySpeed, // Use fallback speed
      );

      if (!response.wasSuccessful) {
        developer.log(
          'Retry failed: ${response.constraintReason}',
          name: 'PlayerController._movePlayerRight',
        );
        // PHY-3.2.3: Emergency fallback maintains basic movement
        await _emergencyMovementFallback(Vector2(1, 0));
      }
    } else if (response.wasSuccessful) {
      developer.log(
        'Player accelerating right${isInAir ? ' (air)' : ''} (applied velocity: ${response.actualVelocity.x.toStringAsFixed(1)})',
        name: 'PlayerController._movePlayerRight',
      );
    }
  }

  /// Update jump state machine
  Future<void> _updateJumpStateMachine(double dt) async {
    final bool isCurrentlyOnGround = await _isPlayerOnGround();
    final double currentVelocityY = (await _getCurrentVelocity()).y;

    switch (_jumpState) {
      case JumpState.grounded:
        if (!isCurrentlyOnGround && currentVelocityY < 0) {
          _jumpState = JumpState.jumping;
        } else if (!isCurrentlyOnGround && currentVelocityY > 0) {
          _jumpState = JumpState.falling;
          _coyoteTimer = GameConfig.jumpCoyoteTime;
          _fireLeftGroundEvent('fall');
        } else if (!isCurrentlyOnGround && currentVelocityY == 0) {
          _jumpState = JumpState.falling;
          _coyoteTimer = 0.0;
        }
        break;

      case JumpState.jumping:
        if (_jumpInputHeld && _jumpHoldTime < GameConfig.jumpHoldMaxTime) {
          _jumpHoldTime += dt;
          // Apply additional upward force while holding jump
          await _applyJumpHoldForce(dt);
        }

        if (currentVelocityY >= 0 || !_jumpInputHeld) {
          _jumpState = JumpState.falling;
        }
        break;

      case JumpState.falling:
        if (isCurrentlyOnGround) {
          _jumpState = JumpState.landing;
          _landingTimer = 0.1;
          _fireLandingEvent();

          if (_jumpBufferTimer > 0 && await _canPerformJump()) {
            await _performJump();
            _jumpBufferTimer = 0.0;
          }
        }
        break;

      case JumpState.landing:
        _landingTimer -= dt;
        if (_landingTimer <= 0) {
          _jumpState = JumpState.grounded;

          if (_jumpBufferTimer > 0 && await _canPerformJump()) {
            await _performJump();
            _jumpBufferTimer = 0.0;
          }
        }
        break;
    }

    // Update legacy variables for compatibility
    _isJumping = _jumpState == JumpState.jumping;
    _canJump =
        _jumpCooldownTimer <= 0 && (isCurrentlyOnGround || _coyoteTimer > 0);
  }

  /// Update various timers
  Future<void> _updateTimers(double dt) async {
    if (_jumpCooldownTimer > 0) {
      _jumpCooldownTimer -= dt;
    }

    final bool isOnGround = await _isPlayerOnGround();
    if (_coyoteTimer > 0 && !isOnGround) {
      _coyoteTimer -= dt;
    } else if (isOnGround) {
      _coyoteTimer = GameConfig.jumpCoyoteTime;
    }

    if (_jumpBufferTimer > 0) {
      _jumpBufferTimer -= dt;
    }
  }

  /// Update movement smoothing
  Future<void> _updateMovementSmoothing(double dt) async {
    if (_movementCoordinator == null) return;

    if (_hasInputThisFrame) {
      _inputSmoothTimer = GameConfig.inputSmoothingTime;
    } else if (_inputSmoothTimer > 0) {
      _inputSmoothTimer -= dt;
    }

    // PHY-3.2.1: Use movement coordinator for smoothing instead of direct velocity access
    if (!_hasInputThisFrame && _inputSmoothTimer <= 0) {
      final currentVel = (await _getCurrentVelocity()).x;

      if (currentVel.abs() > GameConfig.minMovementThreshold) {
        // Request gradual deceleration through movement coordinator
        final response = await _movementCoordinator!.handleStopInput(_entityId);

        if (!response.wasSuccessful) {
          developer.log(
            'Failed to apply movement smoothing: ${response.constraintReason}',
            name: 'PlayerController._updateMovementSmoothing',
          );
        }
      }
    }
  }

  /// Handle jump input
  void _handleJumpInput() async {
    _jumpBufferTimer = GameConfig.jumpBufferTime;

    if (await _canPerformJump()) {
      await _performJump();
    }
  }

  /// PHY-3.2.1: Perform jump using movement coordinator
  /// PHY-3.2.3: Enhanced with retry mechanism
  Future<void> _performJump() async {
    if (_movementCoordinator == null) {
      developer.log(
        'Movement coordinator not available - cannot jump',
        name: 'PlayerController._performJump',
      );
      return;
    }

    final bool isCoyoteJump = !(await _isPlayerOnGround()) && _coyoteTimer > 0;

    // Retain horizontal momentum
    final currentHorizontalSpeed = (await _getCurrentVelocity()).x;
    final retainedSpeed = currentHorizontalSpeed * GameConfig.airSpeedRetention;

    // PHY-3.2.3: Create jump request with retry capability
    final request = PlayerMovementRequest.playerJump(
      entityId: _entityId,
      force: GameConfig.jumpForce.abs(),
      previousAction: _lastPlayerAction,
      isInputSequence: _detectInputSequence(),
      variableHeight: true,
    );

    // Update tracking
    _lastRequestTime = request.timestamp;
    _lastPlayerAction = PlayerAction.jump;

    // PHY-3.2.1: Use movement coordinator for jump instead of direct velocity modification
    var response = await _movementCoordinator!.handleJumpInput(
      _entityId,
      request.magnitude,
      variableHeight: true,
    );

    if (!response.wasSuccessful && request.retryCount < 1) {
      developer.log(
        'Jump request failed: ${response.constraintReason}, retrying with reduced force',
        name: 'PlayerController._performJump',
      );

      // PHY-3.2.3: Retry with reduced jump force
      final retryRequest = request.createRetryRequest(
        customFallbackMultiplier: 0.8, // 80% of original force
        additionalErrorContext: {
          'originalFailure': response.constraintReason ?? 'Unknown',
          'isCoyoteJump': isCoyoteJump,
        },
      );

      response = await _movementCoordinator!.handleJumpInput(
        retryRequest.entityId,
        retryRequest.retrySpeed,
        variableHeight: true,
      );
    }

    if (response.wasSuccessful) {
      // Update state
      _jumpState = JumpState.jumping;
      _jumpHoldTime = 0.0;
      _jumpCooldownTimer = GameConfig.jumpCooldown;
      _coyoteTimer = 0.0;

      _fireJumpEvent(isCoyoteJump);

      developer.log(
        'Player jumping (force: ${request.magnitude}, retained horizontal: ${retainedSpeed.toStringAsFixed(1)})',
        name: 'PlayerController._performJump',
      );
    } else {
      developer.log(
        'Jump request failed after retry: ${response.constraintReason}',
        name: 'PlayerController._performJump',
      );
    }
  }

  /// Apply additional jump force while holding button
  Future<void> _applyJumpHoldForce(double dt) async {
    if (_physicsCoordinator == null) return;

    final holdForce = GameConfig.jumpHoldForce * dt;

    // PHY-3.2.1: Use physics coordinator to apply upward force
    await _physicsCoordinator!.requestJump(
      _entityId,
      holdForce,
    );
  }

  /// Apply jump cut-off for variable height
  void _applyJumpCutOff() async {
    if (_physicsCoordinator == null) return;

    final currentVel = await _getCurrentVelocity();

    // Only apply cut-off if moving upward
    if (currentVel.y < 0) {
      // PHY-3.2.1: Request velocity modification through physics coordinator
      // final newVelY = currentVel.y * GameConfig.jumpCutOffMultiplier; // Value not used

      // This is a special case where we need to modify vertical velocity
      // We'll use a stop request with custom velocity adjustment
      await _physicsCoordinator!.requestStop(_entityId);

      developer.log(
        'Jump cut-off applied',
        name: 'PlayerController._applyJumpCutOff',
      );
    }
  }

  /// Stop horizontal movement
  void _stopHorizontalMovement() async {
    if (_movementCoordinator == null) return;

    // PHY-3.2.1: Use movement coordinator to handle deceleration
    final response = await _movementCoordinator!.handleStopInput(_entityId);

    if (!response.wasSuccessful) {
      developer.log(
        'Failed to stop movement: ${response.constraintReason}',
        name: 'PlayerController._stopHorizontalMovement',
      );
    }
  }

  /// Update edge detection
  Future<void> _updateEdgeDetection() async {
    if (_physicsCoordinator == null) return;

    // final state = await _physicsCoordinator!.getPhysicsState(_entityId); // Value not used

    // Edge detection logic would go here based on physics state
    // For now, we'll keep the existing event firing logic
  }

  /// Update respawn system
  Future<void> _updateRespawnSystem(double dt) async {
    _safePositionUpdateTimer += dt;

    final position = await _getPlayerPosition();

    if (position.y > _fallThreshold) {
      await _respawnPlayer();
      return;
    }

    final isOnGround = await _isPlayerOnGround();
    if (isOnGround && _safePositionUpdateTimer >= _safePositionUpdateInterval) {
      _lastSafePosition = position.clone();
      _safePositionUpdateTimer = 0.0;
    }
  }

  /// Respawn player
  /// PHY-3.2.3: Enhanced with proper RespawnState
  Future<void> _respawnPlayer() async {
    _lastSafePosition ??= Vector2(100, 300);

    // PHY-3.2.3: Create respawn state with accumulation reset
    final respawnState = RespawnState.outOfBounds(
      lastSafePosition: _lastSafePosition!,
      metadata: {
        'fallPosition': (await _getPlayerPosition()).toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'reason': 'fell_out_of_bounds',
      },
    );

    // PHY-3.2.1: Use physics coordinator to reset position
    if (_physicsCoordinator != null) {
      // The physics system should accept RespawnState for proper reset
      await _physicsCoordinator!.resetPhysicsState(_entityId);

      // PHY-3.2.3: Ensure accumulation prevention after respawn
      await _physicsCoordinator!.clearAccumulatedForces(_entityId);

      // Note: Position update would be handled by physics system
      // once it's updated to accept RespawnState parameter
    }

    // Clear request history to prevent rapid input detection after respawn
    _lastRequestTime = null;
    _lastPlayerAction = PlayerAction.idle;

    resetInputState();
    _fireRespawnEvent();

    developer.log(
      'Player respawned with state: $respawnState',
      name: 'PlayerController._respawnPlayer',
    );
  }

  /// Reset input state
  void resetInputState() async {
    _moveLeft = false;
    _moveRight = false;
    _jump = false;
    _jumpInputHeld = false;
    _jumpState = JumpState.grounded;
    _jumpHoldTime = 0.0;
    _jumpBufferTimer = 0.0;
    _landingTimer = 0.0;
    _jumpCooldownTimer = 0.0;
    _coyoteTimer = 0.0;
    _inputSmoothTimer = 0.0;
    _hasInputThisFrame = false;
    _isJumping = false;
    _canJump = true;

    // PHY-3.2.3: Reset rapid input tracking
    _rapidInputCounter = 0;
    _rapidInputStartTime = null;
    _lastRequestTime = null;
    _lastPlayerAction = PlayerAction.idle;

    // PHY-3.2.1: Clear velocity through physics coordinator
    if (_physicsCoordinator != null) {
      await _physicsCoordinator!.clearAccumulatedForces(_entityId);
    }
  }

  // Helper methods using coordination interfaces

  Future<bool> _isPlayerOnGround() async {
    if (_physicsCoordinator != null) {
      return await _physicsCoordinator!.isGrounded(_entityId);
    }
    // Fallback for testing
    return player.physics?.isOnGround ?? false;
  }

  Future<bool> _isPlayerInAir() async {
    return !(await _isPlayerOnGround());
  }

  Future<Vector2> _getCurrentVelocity() async {
    if (_physicsCoordinator != null) {
      return await _physicsCoordinator!.getVelocity(_entityId);
    }
    // Fallback for testing
    return player.physics?.velocity ?? Vector2.zero();
  }

  Future<Vector2> _getPlayerPosition() async {
    if (_physicsCoordinator != null) {
      return await _physicsCoordinator!.getPosition(_entityId);
    }
    // Fallback for testing
    return player.position.clone();
  }

  Future<bool> _canPerformJump() async {
    if (_jumpCooldownTimer > 0) return false;

    if (_movementCoordinator != null) {
      return await _movementCoordinator!.canJump(_entityId);
    }

    // Fallback
    final isOnGround = await _isPlayerOnGround();
    return isOnGround || _coyoteTimer > 0;
  }

  /// Public jump attempt method
  Future<bool> attemptJump() async {
    if (await _canPerformJump()) {
      await _performJump();
      return true;
    }
    return false;
  }

  /// Check if jump is possible
  Future<bool> canPerformJump() async {
    return await _canPerformJump();
  }

  // Event firing methods (unchanged)

  void _fireLandingEvent() async {
    final velocity = await _getCurrentVelocity();
    final position = await _getPlayerPosition();

    final event = PlayerLandedEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      landingVelocity: velocity,
      landingPosition: position,
      groundNormal: Vector2(0, -1),
      impactForce: velocity.y.abs(),
      platformType: null,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  void _fireLeftGroundEvent(String reason) async {
    final position = await _getPlayerPosition();
    final velocity = await _getCurrentVelocity();

    final event = PlayerLeftGroundEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      leavePosition: position,
      leaveVelocity: velocity,
      leaveReason: reason,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  void _fireJumpEvent(bool isCoyoteJump) async {
    final position = await _getPlayerPosition();
    final isOnGround = await _isPlayerOnGround();

    final event = PlayerJumpedEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      jumpPosition: position,
      jumpForce: GameConfig.jumpForce.abs(),
      isFromGround: isOnGround,
      isCoyoteJump: isCoyoteJump,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  void _fireRespawnEvent() {
    developer.log('Player respawned to position: $_lastSafePosition');
  }

  // Getters for external systems
  bool get isMovingLeft => _moveLeft;
  bool get isMovingRight => _moveRight;
  bool get isJumping => _jumpInputHeld || _isJumping;
  bool get canJump => _canJump;
  double get jumpCooldownRemaining => _jumpCooldownTimer;
  double get coyoteTimeRemaining => _coyoteTimer;
  JumpState get jumpState => _jumpState;
  bool get jumpInputHeld => _jumpInputHeld;
  double get jumpHoldTime => _jumpHoldTime;
  double get jumpBufferTimeRemaining => _jumpBufferTimer;
  bool get isGrounded => _jumpState == JumpState.grounded;
  bool get isFalling => _jumpState == JumpState.falling;
  bool get isLanding => _jumpState == JumpState.landing;

  // Set coordination interfaces
  void setMovementCoordinator(IMovementCoordinator coordinator) {
    _movementCoordinator = coordinator;
  }

  void setPhysicsCoordinator(IPhysicsCoordinator coordinator) {
    _physicsCoordinator = coordinator;
  }

  // PHY-3.2.3: Helper methods for state management

  /// Detect if current input is part of a rapid sequence
  /// PHY-3.2.3: Enhanced to track rapid input for accumulation prevention
  bool _detectInputSequence() {
    if (_lastRequestTime == null) return false;

    final now = DateTime.now();
    final timeSinceLast = now.difference(_lastRequestTime!);
    final isSequence = timeSinceLast < _inputSequenceWindow;

    // PHY-3.2.3: Track rapid input patterns
    if (isSequence) {
      if (_rapidInputStartTime == null ||
          now.difference(_rapidInputStartTime!) > _rapidInputWindow) {
        // Start new rapid input tracking window
        _rapidInputStartTime = now;
        _rapidInputCounter = 1;
      } else {
        _rapidInputCounter++;

        // Check if we've exceeded rapid input threshold
        if (_rapidInputCounter >= _rapidInputThreshold) {
          _triggerAccumulationPrevention();
        }
      }
    } else {
      // Reset rapid input tracking if gap is too large
      _rapidInputCounter = 0;
      _rapidInputStartTime = null;
    }

    return isSequence;
  }

  /// PHY-3.2.3: Trigger accumulation prevention when rapid input detected
  void _triggerAccumulationPrevention() {
    developer.log(
      'Rapid input detected: $_rapidInputCounter inputs in ${DateTime.now().difference(_rapidInputStartTime!).inMilliseconds}ms',
      name: 'PlayerController._triggerAccumulationPrevention',
    );

    // Request accumulation prevention through physics coordinator
    if (_physicsCoordinator != null) {
      Future.microtask(() async {
        await _physicsCoordinator!.clearAccumulatedForces(_entityId);

        // Also clear any accumulated input state
        _inputSmoothTimer = 0.0;

        // Reset rapid input counter after prevention
        _rapidInputCounter = 0;
        _rapidInputStartTime = null;
      });
    }
  }

  /// PHY-3.2.3: Emergency fallback for movement failures
  Future<void> _emergencyMovementFallback(Vector2 direction) async {
    // Log the emergency fallback
    developer.log(
      'Emergency movement fallback triggered for direction: $direction',
      name: 'PlayerController._emergencyMovementFallback',
    );

    // Maintain basic movement by using minimal physics coordinator requests
    if (_physicsCoordinator != null) {
      // Use very low speed to ensure movement isn't completely blocked
      final emergencySpeed = GameConfig.maxWalkSpeed * 0.3;
      await _physicsCoordinator!.requestMovement(
        _entityId,
        direction,
        emergencySpeed,
      );
    }
  }
}

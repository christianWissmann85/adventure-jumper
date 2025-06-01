// No math import needed

import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../events/player_events.dart';
import '../game/game_config.dart';
import 'player.dart';

/// Jump state for state machine (T2.3.2)
enum JumpState {
  grounded, // Player is on the ground
  jumping, // Player is ascending (jump button held or recently pressed)
  falling, // Player is descending
  landing // Player just landed (brief state for landing effects)
}

/// Controls player character based on input
/// Handles input processing, movement commands, and action triggers
///
/// Will be properly integrated with the game in Sprint 2
class PlayerController extends Component {
  PlayerController(this.player);
  final Player player;
  bool _moveLeft = false;
  bool _moveRight = false;
  bool _jump = false;
  double _lastDeltaTime =
      0.016; // Track delta time for deceleration calculations

  // T2.13.4: Movement smoothing variables
  double _targetVelocityX = 0.0; // Target horizontal velocity for smoothing
  double _inputSmoothTimer = 0.0; // Timer for input smoothing
  bool _hasInputThisFrame = false; // Track if we have input this frame

  // T2.3.2: Enhanced jump state machine
  JumpState _jumpState = JumpState.grounded;
  bool _jumpInputHeld = false;
  double _jumpHoldTime = 0.0;
  double _jumpBufferTimer = 0.0;
  double _landingTimer = 0.0;
  double _jumpCooldownTimer = 0.0;
  double _coyoteTimer = 0.0;

  // T2.6.3: Edge detection state tracking
  bool _wasNearLeftEdge = false;
  bool _wasNearRightEdge = false;
  // Legacy variables for compatibility (will be removed)
  bool _isJumping = false;
  bool _canJump = true;

  // Respawn system variables
  final double _fallThreshold =
      1200.0; // Y position threshold for falling off the world
  Vector2? _lastSafePosition; // Last known safe position for respawn
  double _safePositionUpdateTimer = 0.0; // Timer to update safe position
  static const double _safePositionUpdateInterval =
      0.5; // Update safe position every 0.5 seconds  @override
  @override
  Future<void> onLoad() async {
    try {
      developer.log(
        'PlayerController.onLoad() called',
        name: 'PlayerController.onLoad',
      );
      // Initialize respawn system
      _lastSafePosition = player.position.clone();
      // Implementation needed: Initialize input handling
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

  @override
  void update(double dt) {
    super.update(dt);

    developer.log(
      'PlayerController.update() called - dt: $dt',
      name: 'PlayerController.update',
    );

    // Track delta time for deceleration calculations
    _lastDeltaTime = dt;

    // T2.3.2: Update jump state machine
    _updateJumpStateMachine(dt); // T2.3.4: Update timers
    _updateTimers(dt);

    // Update respawn system
    _updateRespawnSystem(dt);

    // T2.13.4: Update movement smoothing
    _updateMovementSmoothing(dt);

    // T2.6.3: Update edge detection state
    _updateEdgeDetection();

    // Reset input tracking for this frame
    _hasInputThisFrame = false; // Process movement inputs
    if (_moveLeft) {
      developer.log(
        'Processing _moveLeft input in update()',
        name: 'PlayerController.update',
      );
      _movePlayerLeft(dt);
      _hasInputThisFrame = true;
    } else if (_moveRight) {
      developer.log(
        'Processing _moveRight input in update()',
        name: 'PlayerController.update',
      );
      _movePlayerRight(dt);
      _hasInputThisFrame = true;
    } else {
      // Stop horizontal movement when no keys are pressed
      _stopHorizontalMovement();
    }

    // T2.3.4: Handle jump input with variable height
    if (_jump) {
      _handleJumpInput();
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
        developer.log(
          'Set _moveLeft = $actionValue',
          name: 'PlayerController.handleInputAction',
        );
        break;
      case 'move_right':
        _moveRight = actionValue;
        developer.log(
          'Set _moveRight = $actionValue',
          name: 'PlayerController.handleInputAction',
        );
        break;
      case 'jump':
        // T2.3.4: Track jump button state for variable height
        if (!actionValue && _jumpInputHeld && _jumpState == JumpState.jumping) {
          // Jump button released - apply cut-off for variable height
          _applyJumpCutOff();
        }
        _jumpInputHeld = actionValue;
        // Trigger jump on press, not release
        if (actionValue && !_jump) {
          _jump = true;
        }
        developer.log(
          'Set jump input: _jumpInputHeld = $_jumpInputHeld, _jump = $_jump',
          name: 'PlayerController.handleInputAction',
        );
        break;
      default:
        // Handle other actions in future sprints
        break;
    }
  }

  /// Handle movement to the left - T2.13.2: Enhanced with acceleration & T2.13.3: Air control
  void _movePlayerLeft(double dt) {
    if (player.physics == null) return;

    // Determine if we're in air and get appropriate parameters
    final bool isInAir = !player.physics!.isOnGround;
    double acceleration = isInAir
        ? GameConfig.airAcceleration * GameConfig.airControlMultiplier
        : GameConfig.playerAcceleration;
    double maxSpeed =
        isInAir ? GameConfig.maxAirSpeed : GameConfig.maxWalkSpeed;

    // T2.13.3: Enhanced control - boost acceleration for direction changes
    if (player.physics!.velocity.x > 0) {
      // Changing direction - apply turnaround boost (both air and ground)
      acceleration = isInAir
          ? GameConfig.airTurnAroundSpeed
          : GameConfig.playerAcceleration *
              1.5; // 1.5x boost for ground turnaround
    }

    // Apply leftward acceleration
    player.physics!.velocity.x -= acceleration * dt;

    // Clamp to maximum speed
    if (player.physics!.velocity.x < -maxSpeed) {
      player.physics!.velocity.x = -maxSpeed;
    }

    // Debug feedback
    developer.log(
      'Player accelerating left${isInAir ? ' (air)' : ''} (velocity: ${player.physics!.velocity.x.toStringAsFixed(1)})',
      name: 'PlayerController._movePlayerLeft',
    );
  }

  /// Handle movement to the right - T2.13.2: Enhanced with acceleration & T2.13.3: Air control
  void _movePlayerRight(double dt) {
    developer.log(
      '_movePlayerRight called with dt: $dt',
      name: 'PlayerController._movePlayerRight',
    );

    if (player.physics == null) {
      developer.log(
        'CRITICAL: player.physics is NULL! Cannot move player.',
        name: 'PlayerController._movePlayerRight',
      );
      return;
    }

    developer.log(
      'player.physics is available, proceeding with movement',
      name: 'PlayerController._movePlayerRight',
    );

    // Determine if we're in air and get appropriate parameters
    final bool isInAir = !player.physics!.isOnGround;
    double acceleration = isInAir
        ? GameConfig.airAcceleration * GameConfig.airControlMultiplier
        : GameConfig.playerAcceleration;
    double maxSpeed =
        isInAir ? GameConfig.maxAirSpeed : GameConfig.maxWalkSpeed;

    // T2.13.3: Enhanced control - boost acceleration for direction changes
    if (player.physics!.velocity.x < 0) {
      // Changing direction - apply turnaround boost (both air and ground)
      acceleration = isInAir
          ? GameConfig.airTurnAroundSpeed
          : GameConfig.playerAcceleration *
              1.5; // 1.5x boost for ground turnaround
    }

    // Apply rightward acceleration
    player.physics!.velocity.x += acceleration * dt;

    // Clamp to maximum speed
    if (player.physics!.velocity.x > maxSpeed) {
      player.physics!.velocity.x = maxSpeed;
    }

    // Debug feedback
    developer.log(
      'Player accelerating right${isInAir ? ' (air)' : ''} (velocity: ${player.physics!.velocity.x.toStringAsFixed(1)})',
      name: 'PlayerController._movePlayerRight',
    );
  }

  /// T2.3.2: Update jump state machine
  void _updateJumpStateMachine(double dt) {
    if (player.physics == null) return;
    final bool isCurrentlyOnGround = player.physics!.isOnGround;
    final double currentVelocityY = player.physics!.velocity.y;

    switch (_jumpState) {
      case JumpState.grounded:
        if (!isCurrentlyOnGround && currentVelocityY < 0) {
          // Started jumping
          _jumpState = JumpState.jumping;
        } else if (!isCurrentlyOnGround && currentVelocityY > 0) {
          // Started falling (e.g., walked off a ledge)
          _jumpState = JumpState.falling;
          _coyoteTimer = GameConfig.jumpCoyoteTime;
          // T2.5.3: Fire left ground event
          _fireLeftGroundEvent('fall');
        } else if (!isCurrentlyOnGround && currentVelocityY == 0) {
          // Player was manually placed in air (testing scenario)
          // Transition to falling but don't give coyote time
          _jumpState = JumpState.falling;
          _coyoteTimer = 0.0; // No coyote time for manual placement
        }
        break;

      case JumpState.jumping:
        // T2.3.4: Handle variable jump height
        if (_jumpInputHeld && _jumpHoldTime < GameConfig.jumpHoldMaxTime) {
          _jumpHoldTime += dt;
          // Apply additional upward force while holding jump
          final double holdForce = GameConfig.jumpHoldForce * dt;
          player.physics!.velocity.y += holdForce;
        }

        // Check if we should transition to falling
        if (currentVelocityY >= 0 || !_jumpInputHeld) {
          _jumpState = JumpState.falling;
        }
        break;
      case JumpState.falling:
        if (isCurrentlyOnGround) {
          _jumpState = JumpState.landing;
          _landingTimer = 0.1; // Brief landing state
          // T2.5.3: Fire landing event with enhanced data
          _fireLandingEvent();

          // Check for buffered jumps immediately when landing
          if (_jumpBufferTimer > 0 && _canPerformJump()) {
            _performJump();
            _jumpBufferTimer = 0.0; // Consume the buffer
          }
        }
        break;
      case JumpState.landing:
        _landingTimer -= dt;
        if (_landingTimer <= 0) {
          _jumpState = JumpState.grounded;

          // Check for buffered jumps when landing is complete
          if (_jumpBufferTimer > 0 && _canPerformJump()) {
            _performJump();
            _jumpBufferTimer = 0.0; // Consume the buffer
          }
        }
        break;
    }

    // Update legacy variables for compatibility
    _isJumping = _jumpState == JumpState.jumping;
    _canJump =
        _jumpCooldownTimer <= 0 && (isCurrentlyOnGround || _coyoteTimer > 0);
  }

  /// T2.3.4: Update various timers
  void _updateTimers(double dt) {
    // Update jump cooldown timer
    if (_jumpCooldownTimer > 0) {
      _jumpCooldownTimer -= dt;
    } // Update coyote timer
    if (_coyoteTimer > 0 &&
        player.physics != null &&
        !player.physics!.isOnGround) {
      _coyoteTimer -= dt;
    } else if (player.physics != null && player.physics!.isOnGround) {
      _coyoteTimer = GameConfig.jumpCoyoteTime;
    }

    // Update jump buffer timer
    if (_jumpBufferTimer > 0) {
      _jumpBufferTimer -= dt;
    }
  }

  /// T2.13.4: Update movement smoothing for fluid motion
  void _updateMovementSmoothing(double dt) {
    if (player.physics == null) return;

    // Update input smoothing timer
    if (_hasInputThisFrame) {
      _inputSmoothTimer = GameConfig.inputSmoothingTime;
    } else if (_inputSmoothTimer > 0) {
      _inputSmoothTimer -= dt;
    }

    // Apply velocity smoothing using interpolation
    final double currentVel = player.physics!.velocity.x;
    final double smoothingFactor = GameConfig.velocitySmoothingFactor;

    // Smooth velocity transitions when no input is present
    if (!_hasInputThisFrame && _inputSmoothTimer <= 0) {
      // Apply smoothing to reduce jitter when stopping
      if (currentVel.abs() > GameConfig.minMovementThreshold) {
        final double smoothedVel =
            currentVel * (1.0 - smoothingFactor * dt * 60); // 60fps normalized
        player.physics!.velocity.x = smoothedVel;
      } else {
        // Below threshold, snap to zero
        player.physics!.velocity.x = 0.0;
      }
    }
  }

  /// T2.3.1 & T2.3.4: Handle jump input with variable height
  void _handleJumpInput() {
    // Add to jump buffer
    _jumpBufferTimer = GameConfig.jumpBufferTime;

    // Try to perform jump
    if (_canPerformJump()) {
      _performJump();
    }
  }

  /// T2.3.1: Apply jump force to player PhysicsComponent - T2.13.3: Enhanced with air speed retention
  void _performJump() {
    if (player.physics == null) return;

    final bool isCoyoteJump = !player.physics!.isOnGround && _coyoteTimer > 0;

    // T2.13.3: Retain horizontal momentum when jumping
    final double currentHorizontalSpeed = player.physics!.velocity.x;
    final double retainedSpeed =
        currentHorizontalSpeed * GameConfig.airSpeedRetention;

    // Apply initial jump force using GameConfig values
    player.physics!.velocity.y = GameConfig.jumpForce;

    // T2.13.3: Apply retained horizontal speed for fluid movement
    player.physics!.velocity.x = retainedSpeed;

    // Update state
    _jumpState = JumpState.jumping;
    _jumpHoldTime = 0.0;
    _jumpCooldownTimer = GameConfig.jumpCooldown;
    _coyoteTimer = 0.0; // Reset coyote time when jumping

    // T2.5.3: Fire jump event
    _fireJumpEvent(isCoyoteJump); // Debug feedback
    developer.log(
      'Player jumping (velocity: ${player.physics!.velocity.y}, horizontal retained: ${retainedSpeed.toStringAsFixed(1)})',
      name: 'PlayerController._performJump',
    );
  }

  /// T2.5.3: Fire landing event with enhanced data
  void _fireLandingEvent() {
    if (player.physics == null) return;

    final Vector2 landingVelocity = player.physics!.velocity.clone();
    final Vector2 landingPosition = player.position.clone();
    final Vector2? groundNormal = player.physics!.lastCollisionNormal;
    final double impactForce = landingVelocity.y.abs();
    final String? platformType = player.physics!.lastPlatformType;

    final PlayerLandedEvent event = PlayerLandedEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      landingVelocity: landingVelocity,
      landingPosition: landingPosition,
      groundNormal: groundNormal ?? Vector2(0, -1), // Default upward normal
      impactForce: impactForce,
      platformType: platformType,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  /// T2.5.3: Fire left ground event
  void _fireLeftGroundEvent(String reason) {
    if (player.physics == null) return;

    final PlayerLeftGroundEvent event = PlayerLeftGroundEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      leavePosition: player.position.clone(),
      leaveVelocity: player.physics!.velocity.clone(),
      leaveReason: reason,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  /// T2.5.3: Fire jump event
  void _fireJumpEvent(bool isCoyoteJump) {
    if (player.physics == null) return;

    final PlayerJumpedEvent event = PlayerJumpedEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      jumpPosition: player.position.clone(),
      jumpForce: GameConfig.jumpForce.abs(),
      isFromGround: player.physics!.isOnGround,
      isCoyoteJump: isCoyoteJump,
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  /// T2.3.4: Apply jump cut-off for variable jump height
  void _applyJumpCutOff() {
    if (player.physics == null) return;

    // Only apply cut-off if we're moving upward
    if (player.physics!.velocity.y < 0) {
      // Reduce upward velocity by the cut-off multiplier
      player.physics!.velocity.y *= GameConfig.jumpCutOffMultiplier;

      // Ensure we don't go below minimum jump height
      if (player.physics!.velocity.y > GameConfig.minJumpHeight) {
        player.physics!.velocity.y = GameConfig.minJumpHeight;
      } // Debug feedback
      developer.log(
        'Jump cut-off applied (new velocity: ${player.physics!.velocity.y})',
        name: 'PlayerController._handleJumpCutOff',
      );
    }
  }

  /// Check if player can perform a jump
  bool _canPerformJump() {
    if (player.physics == null) return false;

    // Check cooldown
    if (_jumpCooldownTimer > 0) return false;

    // Check if on ground or within coyote time
    return player.physics!.isOnGround || _coyoteTimer > 0;
  }

  /// T2.3.1: Public method to attempt a jump (for external calls)
  /// Returns true if jump was executed, false otherwise
  bool attemptJump() {
    if (_canPerformJump()) {
      _performJump();
      return true;
    }
    return false;
  }

  /// T2.3.1: Public method to check if jump is possible
  bool canPerformJump() {
    return _canPerformJump();
  }

  /// Stop horizontal movement - T2.13.2: Enhanced with deceleration
  void _stopHorizontalMovement() {
    if (player.physics == null) return;

    // Apply deceleration based on air/ground state
    final double deceleration = player.physics!.isOnGround
        ? GameConfig.playerDeceleration
        : GameConfig.airDeceleration;

    // Apply deceleration in opposite direction of current velocity
    if (player.physics!.velocity.x > 0) {
      // Moving right, decelerate left
      player.physics!.velocity.x -= deceleration * _lastDeltaTime;
      if (player.physics!.velocity.x < 0) {
        player.physics!.velocity.x = 0; // Stop at zero
      }
    } else if (player.physics!.velocity.x < 0) {
      // Moving left, decelerate right
      player.physics!.velocity.x += deceleration * _lastDeltaTime;
      if (player.physics!.velocity.x > 0) {
        player.physics!.velocity.x = 0; // Stop at zero
      }
    }

    // Clamp very small values to zero to prevent floating point drift
    // Increased threshold to handle test precision requirements
    if (player.physics!.velocity.x.abs() < 0.01) {
      player.physics!.velocity.x = 0.0;
    }
  }

  /// Reset input state
  void resetInputState() {
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

    // T2.13.4: Reset smoothing variables
    _targetVelocityX = 0.0;
    _inputSmoothTimer = 0.0;
    _hasInputThisFrame = false;

    // Legacy variables
    _isJumping = false;
    _canJump = true;

    // Clear any physics velocity to ensure clean state
    if (player.physics != null) {
      player.physics!.velocity.setZero();
    }
  }

  /// Get current movement state for debugging and external systems
  bool get isMovingLeft => _moveLeft;
  bool get isMovingRight => _moveRight;
  bool get isJumping => _jumpInputHeld || _isJumping;
  bool get canJump => _canJump;
  double get jumpCooldownRemaining => _jumpCooldownTimer;
  double get coyoteTimeRemaining => _coyoteTimer;

  // T2.3.2: New state machine getters
  JumpState get jumpState => _jumpState;
  bool get jumpInputHeld => _jumpInputHeld;
  double get jumpHoldTime => _jumpHoldTime;
  double get jumpBufferTimeRemaining => _jumpBufferTimer;
  bool get isGrounded => _jumpState == JumpState.grounded;
  bool get isFalling => _jumpState == JumpState.falling;
  bool get isLanding => _jumpState == JumpState.landing;
  // T2.6.3: Edge detection getters
  bool get isNearLeftEdge => player.physics?.isNearLeftEdge ?? false;
  bool get isNearRightEdge => player.physics?.isNearRightEdge ?? false;
  bool get isNearAnyEdge => isNearLeftEdge || isNearRightEdge;

  /// T2.6.3: Update edge detection state and fire events
  void _updateEdgeDetection() {
    if (player.physics == null) return;

    final bool isNearLeftEdge = player.physics!.isNearLeftEdge;
    final bool isNearRightEdge = player.physics!.isNearRightEdge;

    // Check for newly detected edges
    if (isNearLeftEdge && !_wasNearLeftEdge) {
      _fireNearEdgeEvent('left');
    }
    if (isNearRightEdge && !_wasNearRightEdge) {
      _fireNearEdgeEvent('right');
    }

    // Check for leaving edges
    if (!isNearLeftEdge && _wasNearLeftEdge) {
      _fireLeftEdgeEvent('left');
    }
    if (!isNearRightEdge && _wasNearRightEdge) {
      _fireLeftEdgeEvent('right');
    }

    // Update previous state
    _wasNearLeftEdge = isNearLeftEdge;
    _wasNearRightEdge = isNearRightEdge;
  }

  /// T2.6.3: Fire near edge event
  void _fireNearEdgeEvent(String side) {
    if (player.physics == null) return;

    final Vector2? edgePosition = side == 'left'
        ? player.physics!.leftEdgePosition
        : player.physics!.rightEdgePosition;

    final double edgeDistance = side == 'left'
        ? player.physics!.leftEdgeDistance
        : player.physics!.rightEdgeDistance;

    if (edgePosition == null) return;

    final PlayerNearEdgeEvent event = PlayerNearEdgeEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      edgePosition: edgePosition,
      edgeDistance: edgeDistance,
      edgeSide: side,
      playerPosition: player.position.clone(),
    );

    PlayerEventBus.instance.fireEvent(event);
  }

  /// T2.6.3: Fire left edge event
  void _fireLeftEdgeEvent(String side) {
    if (player.physics == null) return;

    final Vector2? previousPosition = side == 'left'
        ? player.physics!.leftEdgePosition
        : player.physics!.rightEdgePosition;

    if (previousPosition == null) return;

    final PlayerLeftEdgeEvent event = PlayerLeftEdgeEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      previousEdgePosition: previousPosition.clone(),
      edgeSide: side,
      playerPosition: player.position.clone(),
    );
    PlayerEventBus.instance.fireEvent(event);
  }

  /// Update respawn system - check for falls and update safe position
  void _updateRespawnSystem(double dt) {
    if (player.physics == null) return;

    // Update safe position timer
    _safePositionUpdateTimer += dt;

    // Check if player has fallen off the world
    if (player.position.y > _fallThreshold) {
      _respawnPlayer();
      return;
    }

    // Update safe position if player is on ground and enough time has passed
    if (player.physics!.isOnGround &&
        _safePositionUpdateTimer >= _safePositionUpdateInterval) {
      _lastSafePosition = player.position.clone();
      _safePositionUpdateTimer = 0.0;
    }
  }

  /// Respawn the player to the last safe position
  void _respawnPlayer() {
    _lastSafePosition ??= Vector2(100, 300); // Reset player position
    player.position = _lastSafePosition!.clone();

    // Reset physics velocity and state
    if (player.physics != null) {
      player.physics!.setVelocity(Vector2.zero());
      // Set player on ground at respawn position for consistent state
      player.physics!.setOnGround(true);
    }

    // CRITICAL FIX: Reset all input state to prevent stuck movement after respawn
    resetInputState();

    // Fire respawn event
    _fireRespawnEvent();
  }

  /// Fire respawn event for other systems to react
  void _fireRespawnEvent() {
    // This can be expanded to fire a custom respawn event if needed
    developer.log('Player respawned to position: $_lastSafePosition');
  }
}

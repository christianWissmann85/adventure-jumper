// No math import needed

import 'dart:developer' as developer;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

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
class PlayerController extends Component with KeyboardHandler {
  PlayerController(this.player);
  final Player player;
  bool _moveLeft = false;
  bool _moveRight = false;
  bool _jump = false;
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

  @override
  Future<void> onLoad() async {
    // Implementation needed: Initialize input handling
  }
  @override
  void update(double dt) {
    super.update(dt);

    // T2.3.2: Update jump state machine
    _updateJumpStateMachine(dt);

    // T2.3.4: Update timers
    _updateTimers(dt);
    // T2.6.3: Update edge detection state
    _updateEdgeDetection();

    // Process movement inputs
    if (_moveLeft) {
      _movePlayerLeft(dt);
    } else if (_moveRight) {
      _movePlayerRight(dt);
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
    switch (actionName) {
      case 'move_left':
        _moveLeft = actionValue;
        break;
      case 'move_right':
        _moveRight = actionValue;
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
        break;
      default:
        // Handle other actions in future sprints
        break;
    }
  }

  /// Handle movement to the left
  void _movePlayerLeft(double dt) {
    // Apply leftward movement via physics component
    if (player.physics != null) {
      // Set horizontal velocity for left movement
      const double moveSpeed = 200.0; // pixels per second
      player.physics!.velocity.x = -moveSpeed;
    } // For now, also provide visual debug feedback
    developer.log(
      'Player moving left (velocity: ${player.physics?.velocity.x ?? 0})',
      name: 'PlayerController._movePlayerLeft',
    );
  }

  /// Handle movement to the right
  void _movePlayerRight(double dt) {
    // Apply rightward movement via physics component
    if (player.physics != null) {
      // Set horizontal velocity for right movement
      const double moveSpeed = 200.0; // pixels per second
      player.physics!.velocity.x = moveSpeed;
    } // For now, also provide visual debug feedback
    developer.log(
      'Player moving right (velocity: ${player.physics?.velocity.x ?? 0})',
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
        }
        break;

      case JumpState.landing:
        _landingTimer -= dt;
        if (_landingTimer <= 0) {
          _jumpState = JumpState.grounded;
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
    }

    // Update coyote timer
    if (_coyoteTimer > 0 && !player.physics!.isOnGround) {
      _coyoteTimer -= dt;
    } else if (player.physics!.isOnGround) {
      _coyoteTimer = GameConfig.jumpCoyoteTime;
    }

    // Update jump buffer timer
    if (_jumpBufferTimer > 0) {
      _jumpBufferTimer -= dt;
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

  /// T2.3.1: Apply jump force to player PhysicsComponent
  void _performJump() {
    if (player.physics == null) return;

    final bool isCoyoteJump = !player.physics!.isOnGround && _coyoteTimer > 0;

    // Apply initial jump force using GameConfig values
    player.physics!.velocity.y = GameConfig.jumpForce;

    // Update state
    _jumpState = JumpState.jumping;
    _jumpHoldTime = 0.0;
    _jumpCooldownTimer = GameConfig.jumpCooldown;
    _coyoteTimer = 0.0; // Reset coyote time when jumping

    // T2.5.3: Fire jump event
    _fireJumpEvent(isCoyoteJump); // Debug feedback
    developer.log(
      'Player jumping (velocity: ${player.physics!.velocity.y})',
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

  /// Stop horizontal movement
  void _stopHorizontalMovement() {
    // Stop horizontal movement by setting velocity to 0
    if (player.physics != null) {
      player.physics!.velocity.x = 0.0;
    }
  }

  // Input handling methods
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Direct keyboard handling - this is supplementary to InputComponent
    // InputComponent handles the primary input processing
    return false;
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
    // Legacy variables
    _isJumping = false;
    _canJump = true;
  }

  /// Get current movement state for debugging and external systems
  bool get isMovingLeft => _moveLeft;
  bool get isMovingRight => _moveRight;
  bool get isJumping => _isJumping;
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
}

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'player.dart';

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

  @override
  Future<void> onLoad() async {
    // Implementation needed: Initialize input handling
  }
  @override
  void update(double dt) {
    super.update(dt);

    // Process movement inputs
    if (_moveLeft) {
      _movePlayerLeft(dt);
    } else if (_moveRight) {
      _movePlayerRight(dt);
    } else {
      // Stop horizontal movement when no keys are pressed
      _stopHorizontalMovement();
    }

    if (_jump) {
      _performJump();
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
        // Only trigger jump on press, not release
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
    }

    // For now, also provide visual debug feedback
    print('Player moving left (velocity: ${player.physics?.velocity.x ?? 0})');
  }

  /// Handle movement to the right
  void _movePlayerRight(double dt) {
    // Apply rightward movement via physics component
    if (player.physics != null) {
      // Set horizontal velocity for right movement
      const double moveSpeed = 200.0; // pixels per second
      player.physics!.velocity.x = moveSpeed;
    }

    // For now, also provide visual debug feedback
    print('Player moving right (velocity: ${player.physics?.velocity.x ?? 0})');
  }

  /// Handle jump action
  void _performJump() {
    // Apply jump force via physics component
    if (player.physics != null) {
      // Set vertical velocity for jump (negative Y is up in Flame)
      const double jumpForce = -400.0; // pixels per second
      player.physics!.velocity.y = jumpForce;
    }

    // For now, also provide visual debug feedback
    print('Player jumping (velocity: ${player.physics?.velocity.y ?? 0})');
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
  }

  /// Get current movement state for debugging and external systems
  bool get isMovingLeft => _moveLeft;
  bool get isMovingRight => _moveRight;
  bool get isJumping => _jump;
}

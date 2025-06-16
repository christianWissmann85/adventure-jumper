import 'package:flame/components.dart';

import '../../systems/interfaces/movement_request.dart';
import '../../systems/interfaces/physics_state.dart';

/// PHY-3.1.4: Interface for input component integration
///
/// This interface defines the contract for input components that need to
/// integrate with the movement and physics systems through the coordination
/// patterns established in the Physics-Movement refactor.
///
/// Key responsibilities:
/// - Movement request generation from input actions
/// - Input validation with physics state
/// - Accumulation prevention for rapid input sequences
/// - Integration with MovementRequest structures
abstract class IInputIntegration {
  // Movement request generation
  /// Generate movement request from current input state
  Future<MovementRequest?> generateMovementRequest();

  /// Validate input action against physics state
  Future<bool> validateInputAction(String action, PhysicsState physicsState);

  /// Check if movement input is currently active
  Future<bool> hasActiveMovementInput();

  // Input state queries
  /// Get current movement direction from input
  Future<Vector2> getMovementDirection();

  /// Check if jump input is active or buffered
  Future<bool> isJumpRequested();

  /// Check if dash input is active
  Future<bool> isDashRequested();

  /// Get active special actions
  Future<List<String>> getActiveSpecialActions();

  // Input validation
  /// Validate input against movement capabilities
  Future<bool> canPerformAction(
      String action, MovementCapabilities capabilities,);

  /// Check for input conflicts (e.g., left+right pressed)
  Future<bool> hasInputConflicts();

  /// Resolve input conflicts and return valid input state
  Future<Map<String, bool>> resolveInputConflicts();

  // Accumulation prevention
  /// Clear accumulated input buffers
  Future<void> clearInputAccumulation();

  /// Check if input is within valid frequency limits
  Future<bool> isInputFrequencyValid(String action);

  /// Get time since last input action
  Future<double> getTimeSinceLastInput(String action);

  // Physics coordination
  /// Update input validation state based on physics
  Future<void> syncWithPhysics(PhysicsState physicsState);

  /// Handle physics state change notifications
  void onPhysicsStateChanged(PhysicsState newState);

  /// Handle grounded state change
  void onGroundedStateChanged(bool isGrounded);
}

/// Movement capabilities for input validation
class MovementCapabilities {
  final bool canMove;
  final bool canJump;
  final bool canDoubleJump;
  final bool canDash;
  final bool canWallJump;
  final bool canClimb;
  final double maxSpeed;
  final double jumpHeight;
  final double dashDistance;
  final int maxJumps;
  final int jumpsRemaining;

  const MovementCapabilities({
    this.canMove = true,
    this.canJump = true,
    this.canDoubleJump = false,
    this.canDash = false,
    this.canWallJump = false,
    this.canClimb = false,
    this.maxSpeed = 200.0,
    this.jumpHeight = 300.0,
    this.dashDistance = 100.0,
    this.maxJumps = 1,
    this.jumpsRemaining = 1,
  });

  /// Create default player capabilities
  factory MovementCapabilities.defaultPlayer() {
    return const MovementCapabilities(
      canMove: true,
      canJump: true,
      canDoubleJump: true,
      canDash: true,
      canWallJump: true,
      maxSpeed: 250.0,
      jumpHeight: 350.0,
      dashDistance: 150.0,
      maxJumps: 2,
      jumpsRemaining: 2,
    );
  }

  /// Create capabilities for grounded state
  MovementCapabilities withGroundedState() {
    return MovementCapabilities(
      canMove: canMove,
      canJump: canJump,
      canDoubleJump: canDoubleJump,
      canDash: canDash,
      canWallJump: false, // Can't wall jump when grounded
      canClimb: canClimb,
      maxSpeed: maxSpeed,
      jumpHeight: jumpHeight,
      dashDistance: dashDistance,
      maxJumps: maxJumps,
      jumpsRemaining: maxJumps, // Reset jumps when grounded
    );
  }

  /// Create capabilities for airborne state
  MovementCapabilities withAirborneState(int jumpsUsed) {
    return MovementCapabilities(
      canMove: canMove,
      canJump: jumpsRemaining > 0,
      canDoubleJump: canDoubleJump && jumpsRemaining > 0,
      canDash: canDash,
      canWallJump: canWallJump,
      canClimb: false, // Can't climb in air
      maxSpeed: maxSpeed * 0.8, // Reduced air control
      jumpHeight: jumpHeight * 0.8, // Reduced jump height in air
      dashDistance: dashDistance,
      maxJumps: maxJumps,
      jumpsRemaining: maxJumps - jumpsUsed,
    );
  }
}

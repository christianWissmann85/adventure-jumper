import 'package:flame/components.dart';

import 'collision_notifier.dart'; // Added for SurfaceMaterial
import 'movement_response.dart';
import 'physics_state.dart';

/// Primary coordination interface for physics-movement system communication.
///
/// This interface establishes the foundation for the Physics-Movement System Refactor
/// effort (PHY-2.1.1), providing clean separation of concerns between systems
/// while enabling coordinated physics simulation.
///
/// **Position Update Ownership**: Only PhysicsSystem implementations may modify
/// entity positions. All other systems must use request-based coordination.
///
/// **Design Principles:**
/// - Request-based movement control (no direct position manipulation)
/// - Physics system owns all position updates during processing
/// - Clear state query methods for system coordination
/// - Accumulation prevention through proper state management
///
/// **System Integration Pattern:**
/// ```dart
/// // Other systems request movement through coordinator
/// await physicsCoordinator.requestMovement(entityId, direction, speed);
///
/// // Query physics state for decision making
/// if (await physicsCoordinator.isGrounded(entityId)) {
///   await physicsCoordinator.requestJump(entityId, jumpForce);
/// }
/// ```
abstract class IPhysicsCoordinator {
  // ============================================================================
  // Movement Request Methods
  // ============================================================================

  /// Request entity movement in a specific direction with given speed.
  ///
  /// This is the primary method for translating movement input into physics
  /// actions. The physics system will process this request and apply appropriate
  /// velocity changes while respecting collision constraints.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier (must be valid physics entity)
  /// - [direction]: Normalized movement direction vector
  /// - [speed]: Movement speed in pixels per second
  ///
  /// **Returns:** MovementResponse indicating success/failure and actual applied values
  ///
  /// **Validation:**
  /// - Entity must exist and have physics component
  /// - Direction vector must be finite and normalized
  /// - Speed must be non-negative and within system limits
  ///
  /// **Example:**
  /// ```dart
  /// final response = await coordinator.requestMovement(
  ///   playerId,
  ///   Vector2(1, 0), // Right direction
  ///   200.0          // 200 pixels/second
  /// );
  /// if (response.wasSuccessful) {
  ///   // Movement applied successfully
  /// }
  /// ```
  Future<MovementResponse> requestMovement(
    int entityId,
    Vector2 direction,
    double speed,
  );

  /// Request entity jump with specified force.
  ///
  /// Applies an instantaneous upward force to the entity, typically used for
  /// jump mechanics. The physics system will validate that the entity is in
  /// a valid jumping state (usually grounded) before applying the force.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  /// - [force]: Jump force magnitude (positive values for upward jumps)
  ///
  /// **Returns:** MovementResponse with jump application results
  ///
  /// **Validation:**
  /// - Entity must be in valid jumping state (typically grounded)
  /// - Force must be within configured jump force limits
  /// - Entity must have physics component with jump capability
  Future<MovementResponse> requestJump(int entityId, double force);

  /// Request entity to stop all movement.
  ///
  /// Immediately reduces entity velocity to zero, typically used when
  /// movement input is released or when an entity should come to an
  /// immediate halt (e.g., hitting a wall, game pause).
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  ///
  /// **Implementation Note:** This may apply friction/damping rather than
  /// instant velocity zeroing for more natural movement feel.
  Future<void> requestStop(int entityId);

  /// Apply an instantaneous impulse force to entity.
  ///
  /// Used for physics effects like knockback, explosions, wind effects, or
  /// other instantaneous force applications that don't fit the standard
  /// movement patterns.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  /// - [impulse]: Force vector to apply (direction and magnitude)
  ///
  /// **Validation:**
  /// - Impulse vector must be finite
  /// - Magnitude must be within system-defined limits
  /// - Entity must have physics component capable of impulse response
  Future<void> requestImpulse(int entityId, Vector2 impulse);

  // ============================================================================
  // State Query Methods (Read-Only Access)
  // ============================================================================

  /// Check if entity is currently in contact with ground.
  ///
  /// Critical for movement systems to determine valid actions (jumping,
  /// air control, etc.). Uses physics system's collision detection to
  /// provide accurate grounded state.
  ///
  /// **Returns:** true if entity has ground contact, false otherwise
  ///
  /// **Usage:**
  /// ```dart
  /// if (await coordinator.isGrounded(playerId)) {
  ///   // Enable jumping, apply ground friction, etc.
  /// }
  /// ```
  Future<bool> isGrounded(int entityId);

  /// Get current entity velocity vector.
  ///
  /// Provides read-only access to entity's current velocity for other systems
  /// to make informed decisions (animation selection, audio feedback, etc.).
  ///
  /// **Returns:** Current velocity vector in pixels per second
  Future<Vector2> getVelocity(int entityId);

  /// Get current entity position.
  ///
  /// **IMPORTANT:** This is READ-ONLY access. Other systems must never
  /// modify the returned position directly. Use request methods for position changes.
  ///
  /// **Returns:** Current entity position in world coordinates
  Future<Vector2> getPosition(int entityId);

  /// Check if entity has collision contact below (ground or platform).
  ///
  /// More specific than isGrounded(), this checks for any downward collision
  /// contact which may be used for platform detection, fall damage calculation, etc.
  ///
  /// **Returns:** true if entity has downward collision contact
  Future<bool> hasCollisionBelow(int entityId);

  /// Get comprehensive physics state for entity.
  ///
  /// Provides complete physics state information for systems that need
  /// detailed physics information for decision making.
  ///
  /// **Returns:** PhysicsState object with comprehensive entity physics data
  Future<PhysicsState> getPhysicsState(int entityId);

  /// Get the material of the surface the entity is currently grounded on.
  ///
  /// Returns [SurfaceMaterial.none] or throws an error if the entity is not grounded
  /// or if the surface material cannot be determined.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  ///
  /// **Returns:** The [SurfaceMaterial] of the ground contact.
  Future<SurfaceMaterial> getCurrentGroundSurfaceMaterial(int entityId);

  // ============================================================================
  // State Management Methods
  // ============================================================================

  /// Reset entity physics state to clean defaults.
  ///
  /// **CRITICAL FOR BUG RESOLUTION**: This method addresses the physics
  /// degradation issues by clearing accumulated forces, resetting physics
  /// properties to defaults, and ensuring clean state.
  ///
  /// **Usage Scenarios:**
  /// - Player respawn after death
  /// - Level transitions
  /// - Teleportation/warping
  /// - Debug state reset
  /// - Recovery from physics corruption
  ///
  /// **State Reset Includes:**
  /// - Velocity reset to Vector2.zero()
  /// - Acceleration reset to Vector2.zero()
  /// - Clear accumulated forces and contact points
  /// - Reset friction/damping to defaults
  /// - Clear collision state and grounded status
  /// - Reset any physics accumulation counters
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  ///
  /// **Example:**
  /// ```dart
  /// // Player respawn - critical for preventing movement degradation
  /// await coordinator.resetPhysicsState(playerId);
  /// await coordinator.setPositionOverride(playerId, spawnPoint);
  /// ```
  Future<void> resetPhysicsState(int entityId);

  /// Clear accumulated forces that may cause physics degradation.
  ///
  /// **ACCUMULATION PREVENTION**: Specifically addresses the progressive
  /// slowdown issue by clearing any forces, friction, or other physics
  /// values that may accumulate over time and cause degradation.
  ///
  /// **Called In:**
  /// - Rapid input sequences (prevent input accumulation)
  /// - Periodic maintenance (prevent long-term accumulation)
  /// - Error recovery scenarios
  /// - Performance optimization routines
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  Future<void> clearAccumulatedForces(int entityId);

  /// Override entity position directly (for respawn/teleport ONLY).
  ///
  /// **RESTRICTED USE**: This is the ONLY method that allows direct position
  /// modification outside of normal physics processing. Should be used exclusively
  /// for teleportation, respawn, level transitions, or other special cases where
  /// normal physics movement is inappropriate.
  ///
  /// **Important:**
  /// - Bypasses normal collision detection
  /// - Should be followed by physics state validation
  /// - May require additional state cleanup
  /// - Use sparingly to maintain physics system integrity
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity identifier
  /// - [position]: New position in world coordinates
  ///
  /// **Example:**
  /// ```dart
  /// // Player respawn at checkpoint
  /// await coordinator.setPositionOverride(playerId, checkpointPosition);
  /// await coordinator.resetPhysicsState(playerId); // Clean state after override
  /// ```
  Future<void> setPositionOverride(int entityId, Vector2 position);

  /// Validate entity physics state consistency.
  ///
  /// Performs comprehensive validation of entity physics state to detect
  /// corruption, accumulation, or inconsistencies that could lead to the
  /// movement degradation issues.
  ///
  /// **Validation Checks:**
  /// - Position/velocity finite and within bounds
  /// - Physics component state consistency
  /// - Transform synchronization with physics
  /// - Accumulation level monitoring
  /// - Contact point cleanup validation
  ///
  /// **Returns:** true if state is valid and consistent
  ///
  /// **Usage:**
  /// ```dart
  /// if (!await coordinator.validateStateConsistency(entityId)) {
  ///   // Trigger error recovery or state reset
  ///   await coordinator.resetPhysicsState(entityId);
  /// }
  /// ```
  Future<bool> validateStateConsistency(int entityId);

  // ============================================================================
  // Feature Flag Integration
  // ============================================================================

  /// Enable or disable physics refactor interface features.
  ///
  /// **Feature Flag**: physics_refactor_interfaces_enabled
  ///
  /// During the refactor transition period, this allows graceful migration
  /// between old and new coordination patterns. When enabled, the new
  /// request-based coordination is active. When disabled, falls back to
  /// legacy patterns.
  ///
  /// **Parameters:**
  /// - [enabled]: true to enable new coordination, false for legacy mode
  void setInterfaceEnabled(bool enabled);

  /// Check if physics refactor interfaces are currently enabled.
  ///
  /// **Returns:** true if new coordination patterns are active
  bool get isInterfaceEnabled;
}

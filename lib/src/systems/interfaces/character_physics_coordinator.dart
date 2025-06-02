import 'package:flame/components.dart';

import '../../utils/math_utils.dart';
import 'movement_request.dart';
import 'movement_response.dart';
import 'physics_state.dart';

/// Character-specific physics coordination interface for player and character controllers.
///
/// This interface extends the base physics coordination with character-specific
/// functionality for the Physics-Movement System Refactor effort (PHY-2.1.1).
/// Provides enhanced movement capabilities, state management, and error recovery
/// specifically tailored for character entities.
///
/// **Character-Specific Features:**
/// - Player movement request processing with validation
/// - Character ability system integration
/// - Enhanced state queries for character controllers
/// - Respawn and teleportation state management
/// - Character-specific accumulation prevention
///
/// **Design Principles:**
/// - Character-centric request processing
/// - Enhanced capability validation
/// - Integrated error recovery for character actions
/// - Respawn state management with accumulation reset
///
/// **System Integration Pattern:**
/// ```dart
/// // Character controller requests movement
/// final response = await characterPhysics.requestMovement(playerRequest);
///
/// // Query character-specific capabilities
/// if (await characterPhysics.canPerformJump(playerId)) {
///   await characterPhysics.requestJump(playerId, jumpForce);
/// }
/// ```
abstract class ICharacterPhysicsCoordinator {
  // ============================================================================
  // Character Movement Requests
  // ============================================================================

  /// Request character movement with validation.
  ///
  /// Enhanced movement request processing with character-specific validation
  /// and capability checking. Supports player movement requests with action
  /// classification and input sequence detection.
  ///
  /// **Parameters:**
  /// - [request]: Character movement request with enhanced validation
  ///
  /// **Returns:** MovementResponse with character-specific feedback
  ///
  /// **Validation:**
  /// - Character movement capabilities
  /// - Input sequence accumulation prevention
  /// - Action-specific constraints (walk, run, dash)
  /// - Character state requirements
  ///
  /// **Example:**
  /// ```dart
  /// final request = PlayerMovementRequest(
  ///   entityId: playerId,
  ///   direction: Vector2(1, 0),
  ///   speed: 250.0,
  ///   type: MovementType.walk,
  ///   action: PlayerAction.walk,
  /// );
  /// final response = await coordinator.requestMovement(request);
  /// ```
  Future<MovementResponse> requestMovement(MovementRequest request);

  /// Request character jump with variable height.
  ///
  /// Character-specific jump processing with support for variable jump height,
  /// coyote time, and multi-jump capabilities where applicable.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  /// - [force]: Jump force magnitude
  /// - [variableHeight]: Enable variable height based on input duration
  ///
  /// **Returns:** MovementResponse with jump execution results
  ///
  /// **Character Features:**
  /// - Coyote time support for forgiving jump timing
  /// - Variable height based on input duration
  /// - Multi-jump capability validation
  /// - Jump combo detection and handling
  Future<MovementResponse> requestJump(
    int entityId,
    double force, {
    bool variableHeight = true,
  });

  /// Request character dash movement.
  ///
  /// Character-specific dash processing with direction validation,
  /// cooldown management, and energy cost calculation.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  /// - [direction]: Dash direction vector
  /// - [dashSpeed]: Dash speed magnitude
  ///
  /// **Returns:** MovementResponse with dash execution results
  ///
  /// **Dash Features:**
  /// - Direction validation and normalization
  /// - Dash cooldown enforcement
  /// - Energy cost calculation and validation
  /// - Air dash capability checking
  Future<MovementResponse> requestDash(
    int entityId,
    Vector2 direction,
    double dashSpeed,
  );

  // ============================================================================
  // Character State Queries
  // ============================================================================

  /// Check if character is grounded.
  ///
  /// Enhanced grounded state checking with coyote time support and
  /// ground surface information for character controllers.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character is grounded or within coyote time
  ///
  /// **Grounded Conditions:**
  /// - Character is in contact with ground surface
  /// - Within coyote time after leaving ground
  /// - Ground surface is valid for character interaction
  Future<bool> isGrounded(int entityId);

  /// Check if character is jumping.
  ///
  /// Detects active jump state for character movement validation
  /// and animation coordination.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character is in jumping state
  Future<bool> isJumping(int entityId);

  /// Check if character is falling.
  ///
  /// Detects falling state for character animation and collision
  /// processing coordination.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character is in falling state
  Future<bool> isFalling(int entityId);

  /// Get character velocity.
  ///
  /// Retrieves current character velocity for movement calculation
  /// and state determination.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** Current character velocity vector
  Future<Vector2> getVelocity(int entityId);

  /// Get character position.
  ///
  /// Retrieves current character position for coordinate calculations
  /// and distance measurements.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** Current character position
  Future<Vector2> getPosition(int entityId);

  /// Get active character collisions.
  ///
  /// Retrieves list of active collisions for character interaction
  /// processing and state validation.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** List of active collision information
  Future<List<CollisionInfo>> getActiveCollisions(int entityId);

  /// Get character physics state.
  ///
  /// Comprehensive physics state information for character debugging
  /// and advanced state management.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** Complete physics state snapshot
  Future<PhysicsState> getPhysicsState(int entityId);

  // ============================================================================
  // Character Capability Validation
  // ============================================================================

  /// Check if character can perform jump.
  ///
  /// Enhanced jump capability validation with character-specific
  /// requirements and multi-jump support.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character can currently jump
  ///
  /// **Jump Requirements:**
  /// - Character is grounded or within coyote time
  /// - No active jump cooldown
  /// - Character has jump ability
  /// - Energy requirements met (if applicable)
  Future<bool> canPerformJump(int entityId);

  /// Check if character can perform dash.
  ///
  /// Dash capability validation with cooldown, energy, and state
  /// requirement checking.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character can currently dash
  ///
  /// **Dash Requirements:**
  /// - Dash cooldown expired
  /// - Sufficient energy available
  /// - Character has dash ability
  /// - Valid movement state for dash
  Future<bool> canPerformDash(int entityId);

  /// Get maximum movement speed for character.
  ///
  /// Retrieves character's maximum movement speed based on current
  /// state, abilities, and any active modifiers.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** Maximum movement speed in pixels per second
  Future<double> getMaxMovementSpeed(int entityId);

  /// Get character movement capabilities.
  ///
  /// Comprehensive list of movement capabilities available to the
  /// character based on current state and abilities.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** Map of movement types to capability status
  Future<Map<MovementType, bool>> getMovementCapabilities(int entityId);

  // ============================================================================
  // Character State Management
  // ============================================================================

  /// Reset character physics state.
  ///
  /// Enhanced physics state reset with character-specific considerations
  /// for respawn, teleportation, and state corruption recovery.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  /// - [respawnState]: Respawn state configuration (optional)
  ///
  /// **Reset Actions:**
  /// - Clear accumulated forces and velocities
  /// - Reset position to respawn point (if provided)
  /// - Clear movement history and constraints
  /// - Reset character-specific state flags
  /// - Apply accumulation prevention
  Future<void> resetPhysicsState(int entityId, [RespawnState? respawnState]);

  /// Prevent character accumulation.
  ///
  /// Character-specific accumulation prevention called during rapid
  /// input sequences or when accumulation is detected.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Prevention Actions:**
  /// - Clamp character velocity to safe ranges
  /// - Apply character-specific damping
  /// - Reset problematic physics values
  /// - Clear input sequence history
  void preventAccumulation(int entityId);

  /// Validate character physics integrity.
  ///
  /// Comprehensive validation of character physics state for debugging
  /// and error detection.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity identifier
  ///
  /// **Returns:** True if character physics state is valid
  ///
  /// **Validation Checks:**
  /// - Physics values within valid ranges
  /// - State consistency between components
  /// - No accumulation detected
  /// - Character capabilities properly configured
  Future<bool> validatePhysicsIntegrity(int entityId);

  // ============================================================================
  // Character Error Handling
  // ============================================================================

  /// Handle failed movement request.
  ///
  /// Character-specific error handling for failed movement requests
  /// with recovery procedures and fallback options.
  ///
  /// **Parameters:**
  /// - [request]: Failed movement request
  /// - [reason]: Failure reason description
  ///
  /// **Recovery Actions:**
  /// - Log error with character context
  /// - Attempt fallback movement options
  /// - Notify character controller of failure
  /// - Apply corrective actions if possible
  void onMovementRequestFailed(MovementRequest request, String reason);

  /// Handle character physics error.
  ///
  /// Character-specific physics error handling with state recovery
  /// and stability maintenance procedures.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity that encountered error
  /// - [error]: Physics error information
  /// - [context]: Additional error context
  ///
  /// **Error Recovery:**
  /// - Assess error severity and impact
  /// - Apply appropriate recovery procedures
  /// - Maintain character controller functionality
  /// - Log error for debugging analysis
  void onPhysicsError(
    int entityId,
    String error,
    Map<String, dynamic>? context,
  );

  // ============================================================================
  // Character Event Notifications
  // ============================================================================

  /// Notify input processing start.
  ///
  /// Called when character input processing begins. Used for coordination
  /// with input validation and accumulation prevention.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity processing input
  /// - [inputType]: Type of input being processed
  void notifyInputProcessing(int entityId, String inputType);

  /// Notify state change.
  ///
  /// Called when character state changes occur. Enables coordination
  /// with character controllers and dependent systems.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity with state change
  /// - [oldState]: Previous character state
  /// - [newState]: New character state
  void notifyStateChange(int entityId, String oldState, String newState);

  /// Notify ability usage.
  ///
  /// Called when character abilities are used. Coordinates with ability
  /// system and tracks ability-related physics effects.
  ///
  /// **Parameters:**
  /// - [entityId]: Character entity using ability
  /// - [abilityType]: Type of ability being used
  /// - [cooldownTime]: Ability cooldown duration
  void notifyAbilityUsage(
    int entityId,
    String abilityType,
    double cooldownTime,
  );
}

/// Respawn state configuration for character physics reset.
///
/// Provides configuration for character respawn procedures, including
/// position, velocity, and state reset parameters.
class RespawnState {
  /// Respawn position coordinates
  final Vector2 spawnPosition;

  /// Initial velocity after respawn
  final Vector2 spawnVelocity;

  /// Whether to reset physics accumulation
  final bool resetPhysicsAccumulation;

  /// Whether to clear movement history
  final bool clearMovementHistory;

  /// Whether to reset character abilities
  final bool resetAbilities;

  /// Respawn invulnerability duration
  final double invulnerabilityDuration;

  /// Character state to apply after respawn
  final String? respawnState;

  /// Additional respawn configuration
  final Map<String, dynamic> additionalConfig;
  RespawnState({
    required this.spawnPosition,
    Vector2? spawnVelocity,
    this.resetPhysicsAccumulation = true,
    this.clearMovementHistory = true,
    this.resetAbilities = false,
    this.invulnerabilityDuration = 1.0,
    this.respawnState,
    this.additionalConfig = const {},
  }) : spawnVelocity = spawnVelocity ?? Vector2.zero();

  /// Create default respawn state
  factory RespawnState.defaultRespawn(Vector2 position) {
    return RespawnState(
      spawnPosition: position,
      spawnVelocity: Vector2.zero(),
      resetPhysicsAccumulation: true,
      clearMovementHistory: true,
      resetAbilities: false,
      invulnerabilityDuration: 1.0,
      respawnState: 'spawning',
    );
  }

  /// Create teleport state (no ability reset)
  factory RespawnState.teleport(Vector2 position) {
    return RespawnState(
      spawnPosition: position,
      spawnVelocity: Vector2.zero(),
      resetPhysicsAccumulation: true,
      clearMovementHistory: false,
      resetAbilities: false,
      invulnerabilityDuration: 0.0,
      respawnState: 'teleporting',
    );
  }

  /// Create emergency reset state (full reset)
  factory RespawnState.emergencyReset(Vector2 position) {
    return RespawnState(
      spawnPosition: position,
      spawnVelocity: Vector2.zero(),
      resetPhysicsAccumulation: true,
      clearMovementHistory: true,
      resetAbilities: true,
      invulnerabilityDuration: 2.0,
      respawnState: 'emergency_reset',
    );
  }

  /// Check if respawn state is valid
  bool get isValid {
    return MathUtils.isVector2Finite(spawnPosition) &&
        MathUtils.isVector2Finite(spawnVelocity) &&
        invulnerabilityDuration >= 0 &&
        invulnerabilityDuration < 10.0; // Reasonable maximum
  }

  /// Get respawn configuration as map
  Map<String, dynamic> toConfigMap() {
    return {
      'spawnPosition': {'x': spawnPosition.x, 'y': spawnPosition.y},
      'spawnVelocity': {'x': spawnVelocity.x, 'y': spawnVelocity.y},
      'resetPhysicsAccumulation': resetPhysicsAccumulation,
      'clearMovementHistory': clearMovementHistory,
      'resetAbilities': resetAbilities,
      'invulnerabilityDuration': invulnerabilityDuration,
      'respawnState': respawnState,
      'additionalConfig': additionalConfig,
    };
  }

  @override
  String toString() {
    return 'RespawnState(position: $spawnPosition, velocity: $spawnVelocity, '
        'resetAccumulation: $resetPhysicsAccumulation, state: $respawnState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RespawnState &&
        other.spawnPosition == spawnPosition &&
        other.spawnVelocity == spawnVelocity &&
        other.resetPhysicsAccumulation == resetPhysicsAccumulation &&
        other.clearMovementHistory == clearMovementHistory &&
        other.resetAbilities == resetAbilities &&
        other.invulnerabilityDuration == invulnerabilityDuration &&
        other.respawnState == respawnState;
  }

  @override
  int get hashCode {
    return Object.hash(
      spawnPosition,
      spawnVelocity,
      resetPhysicsAccumulation,
      clearMovementHistory,
      resetAbilities,
      invulnerabilityDuration,
      respawnState,
    );
  }
}

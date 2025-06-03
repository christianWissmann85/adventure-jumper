import 'package:flame/components.dart';
import 'movement_request.dart';

/// Player-specific actions that can be performed.
///
/// These actions represent the high-level player intentions that may
/// result in movement requests to the physics system.
enum PlayerAction {
  /// No action, player is idle
  idle,
  
  /// Walking movement at normal speed
  walk,
  
  /// Running movement at increased speed
  run,
  
  /// Jumping action
  jump,
  
  /// Dash/sprint movement
  dash,
  
  /// Crouching movement
  crouch,
  
  /// Climbing on walls/ladders
  climb,
  
  /// Attack action (may affect movement)
  attack,
  
  /// Interaction with objects/NPCs
  interact,
  
  /// Wall sliding
  wallSlide,
  
  /// Air dash
  airDash,
}

/// Player-specific movement request with enhanced state management.
///
/// Extends the base MovementRequest with player-specific properties for
/// input sequence tracking, accumulation prevention, and combo support.
///
/// **PHY-3.2.2 Requirements:**
/// - Track rapid input sequences for accumulation prevention
/// - Support player action state management
/// - Enable combo movement chaining
/// - Provide error recovery metadata
///
/// **Usage Example:**
/// ```dart
/// final request = PlayerMovementRequest(
///   entityId: playerId,
///   action: PlayerAction.jump,
///   type: MovementType.jump,
///   direction: Vector2(0, -1),
///   magnitude: jumpForce,
///   isInputSequence: timeSinceLastInput < 50,
/// );
/// ```
class PlayerMovementRequest extends MovementRequest {
  /// The player action associated with this movement
  final PlayerAction action;
  
  /// Whether this is part of a rapid input sequence
  final bool isInputSequence;
  
  /// Time when the current input sequence started
  final DateTime? inputStartTime;
  
  /// Number of inputs in the current sequence
  final int inputSequenceCount;
  
  /// Previous action for combo detection
  final PlayerAction? previousAction;
  
  /// Time window for combo actions (milliseconds)
  final int comboWindow;
  
  /// Whether this is a combo movement
  final bool isComboMove;
  
  /// Number of retry attempts for this request
  final int retryCount;
  
  /// Fallback speed for retry attempts (percentage of original)
  final double fallbackSpeedMultiplier;
  
  /// Flag indicating if accumulation prevention is needed
  final bool requiresAccumulationPrevention;
  
  /// Time of the previous request for frequency calculation
  final DateTime? previousRequestTime;
  
  /// Error context for tracking failures
  final Map<String, dynamic>? errorContext;
  
  /// Create a new player movement request.
  PlayerMovementRequest({
    required super.entityId,
    required this.action,
    required super.type,
    required super.direction,
    required super.magnitude,
    this.isInputSequence = false,
    this.inputStartTime,
    this.inputSequenceCount = 1,
    this.previousAction,
    this.comboWindow = 300, // 300ms default combo window
    this.isComboMove = false,
    this.retryCount = 0,
    this.fallbackSpeedMultiplier = 0.75,
    this.requiresAccumulationPrevention = false,
    this.previousRequestTime,
    this.errorContext,
    super.priority,
    super.requestId,
    Map<String, dynamic>? constraints,
  }) : super(
          constraints: _mergeConstraints(constraints, action),
        );
  
  /// Merge custom constraints with action-specific defaults.
  static Map<String, dynamic> _mergeConstraints(
    Map<String, dynamic>? customConstraints,
    PlayerAction action,
  ) {
    final defaultConstraints = <String, dynamic>{};
    
    // Add action-specific constraints
    switch (action) {
      case PlayerAction.walk:
        defaultConstraints['maxSpeed'] = 200.0;
        defaultConstraints['acceleration'] = 800.0;
        break;
      case PlayerAction.run:
        defaultConstraints['maxSpeed'] = 350.0;
        defaultConstraints['acceleration'] = 1200.0;
        break;
      case PlayerAction.jump:
        defaultConstraints['maxJumpHeight'] = 120.0;
        defaultConstraints['variableHeight'] = true;
        break;
      case PlayerAction.dash:
        defaultConstraints['dashDistance'] = 150.0;
        defaultConstraints['dashDuration'] = 0.2;
        break;
      case PlayerAction.crouch:
        defaultConstraints['speedMultiplier'] = 0.5;
        defaultConstraints['heightMultiplier'] = 0.5;
        break;
      default:
        break;
    }
    
    // Merge with custom constraints
    if (customConstraints != null) {
      defaultConstraints.addAll(customConstraints);
    }
    
    return defaultConstraints;
  }
  
  /// Factory for player walk movement.
  factory PlayerMovementRequest.playerWalk({
    required int entityId,
    required Vector2 direction,
    required double speed,
    PlayerAction? previousAction,
    bool isInputSequence = false,
    DateTime? previousRequestTime,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return PlayerMovementRequest(
      entityId: entityId,
      action: PlayerAction.walk,
      type: MovementType.walk,
      direction: direction,
      magnitude: speed,
      previousAction: previousAction,
      isInputSequence: isInputSequence,
      previousRequestTime: previousRequestTime,
      priority: priority,
      requestId: requestId,
    );
  }
  
  /// Factory for player jump movement.
  factory PlayerMovementRequest.playerJump({
    required int entityId,
    required double force,
    PlayerAction? previousAction,
    bool isInputSequence = false,
    bool variableHeight = true,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return PlayerMovementRequest(
      entityId: entityId,
      action: PlayerAction.jump,
      type: MovementType.jump,
      direction: Vector2(0, -1),
      magnitude: force,
      previousAction: previousAction,
      isInputSequence: isInputSequence,
      priority: priority,
      requestId: requestId,
      constraints: {'variableHeight': variableHeight},
    );
  }
  
  /// Factory for player dash movement.
  factory PlayerMovementRequest.playerDash({
    required int entityId,
    required Vector2 direction,
    required double distance,
    PlayerAction? previousAction,
    bool isAirDash = false,
    MovementPriority priority = MovementPriority.high,
    String? requestId,
  }) {
    return PlayerMovementRequest(
      entityId: entityId,
      action: isAirDash ? PlayerAction.airDash : PlayerAction.dash,
      type: MovementType.dash,
      direction: direction,
      magnitude: distance,
      previousAction: previousAction,
      isComboMove: previousAction != null,
      priority: priority,
      requestId: requestId,
    );
  }
  
  /// Calculate request frequency based on previous request time.
  double get requestFrequency {
    if (previousRequestTime == null) return 0.0;
    
    final timeDelta = timestamp.difference(previousRequestTime!).inMilliseconds;
    if (timeDelta == 0) return 0.0;
    
    return 1000.0 / timeDelta; // Requests per second
  }
  
  /// Check if request frequency indicates rapid input.
  bool get isRapidInput {
    return requestFrequency > 20.0; // More than 20 requests per second
  }
  
  /// Get the appropriate speed for retry attempts.
  double get retrySpeed {
    return magnitude * fallbackSpeedMultiplier;
  }
  
  /// Enhanced validation including player-specific checks.
  @override
  bool get isValid {
    // Base validation
    if (!super.isValid) return false;
    
    // Player-specific validation
    if (inputSequenceCount < 0) return false;
    if (retryCount < 0) return false;
    if (fallbackSpeedMultiplier <= 0 || fallbackSpeedMultiplier > 1) return false;
    
    // Action-specific validation
    switch (action) {
      case PlayerAction.jump:
        // Can't jump while crouching
        if (previousAction == PlayerAction.crouch) return false;
        break;
      case PlayerAction.dash:
      case PlayerAction.airDash:
        // Dash requires significant direction
        if (direction.length < 0.5) return false;
        break;
      default:
        break;
    }
    
    return true;
  }
  
  /// Create a retry request with reduced speed and incremented retry count.
  PlayerMovementRequest createRetryRequest({
    double? customFallbackMultiplier,
    Map<String, dynamic>? additionalErrorContext,
  }) {
    final newErrorContext = Map<String, dynamic>.from(errorContext ?? {});
    if (additionalErrorContext != null) {
      newErrorContext.addAll(additionalErrorContext);
    }
    newErrorContext['retryAttempt'] = retryCount + 1;
    newErrorContext['originalSpeed'] = magnitude;
    
    return PlayerMovementRequest(
      entityId: entityId,
      action: action,
      type: type,
      direction: direction,
      magnitude: magnitude * (customFallbackMultiplier ?? fallbackSpeedMultiplier),
      isInputSequence: isInputSequence,
      inputStartTime: inputStartTime,
      inputSequenceCount: inputSequenceCount,
      previousAction: previousAction,
      comboWindow: comboWindow,
      isComboMove: isComboMove,
      retryCount: retryCount + 1,
      fallbackSpeedMultiplier: fallbackSpeedMultiplier,
      requiresAccumulationPrevention: requiresAccumulationPrevention,
      previousRequestTime: timestamp, // Current request becomes previous
      errorContext: newErrorContext,
      priority: priority,
      requestId: requestId,
      constraints: constraints,
    );
  }
  
  @override
  PlayerMovementRequest copyWith({
    int? entityId,
    PlayerAction? action,
    MovementType? type,
    Vector2? direction,
    double? magnitude,
    bool? isInputSequence,
    DateTime? inputStartTime,
    int? inputSequenceCount,
    PlayerAction? previousAction,
    int? comboWindow,
    bool? isComboMove,
    int? retryCount,
    double? fallbackSpeedMultiplier,
    bool? requiresAccumulationPrevention,
    DateTime? previousRequestTime,
    Map<String, dynamic>? errorContext,
    MovementPriority? priority,
    String? requestId,
    Map<String, dynamic>? constraints,
  }) {
    return PlayerMovementRequest(
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      magnitude: magnitude ?? this.magnitude,
      isInputSequence: isInputSequence ?? this.isInputSequence,
      inputStartTime: inputStartTime ?? this.inputStartTime,
      inputSequenceCount: inputSequenceCount ?? this.inputSequenceCount,
      previousAction: previousAction ?? this.previousAction,
      comboWindow: comboWindow ?? this.comboWindow,
      isComboMove: isComboMove ?? this.isComboMove,
      retryCount: retryCount ?? this.retryCount,
      fallbackSpeedMultiplier: fallbackSpeedMultiplier ?? this.fallbackSpeedMultiplier,
      requiresAccumulationPrevention: requiresAccumulationPrevention ?? this.requiresAccumulationPrevention,
      previousRequestTime: previousRequestTime ?? this.previousRequestTime,
      errorContext: errorContext ?? this.errorContext,
      priority: priority ?? this.priority,
      requestId: requestId ?? this.requestId,
      constraints: constraints ?? this.constraints,
    );
  }
  
  @override
  String toString() {
    return 'PlayerMovementRequest('
        'entityId: $entityId, '
        'action: $action, '
        'type: $type, '
        'direction: $direction, '
        'magnitude: $magnitude, '
        'isInputSequence: $isInputSequence, '
        'isComboMove: $isComboMove, '
        'retryCount: $retryCount, '
        'frequency: ${requestFrequency.toStringAsFixed(1)}Hz'
        ')';
  }
}
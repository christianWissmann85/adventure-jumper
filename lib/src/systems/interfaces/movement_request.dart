import 'package:flame/components.dart';

/// Request types for movement coordination between systems.
///
/// These enums define the specific types of movement operations that can be
/// requested through the physics coordination system.
enum MovementType {
  /// Standard walking/running movement
  walk,

  /// Jumping movement (includes variable height jumps)
  jump,

  /// Dash/sprint movement with higher speed
  dash,

  /// Immediate stop command
  stop,

  /// Instantaneous force application (knockback, explosions, etc.)
  impulse,
}

/// Priority levels for movement request processing.
///
/// Defines the order in which movement requests should be processed when
/// multiple requests are queued for the same entity.
enum MovementPriority {
  /// Low priority - ambient/background movement
  low,

  /// Normal priority - standard player input
  normal,

  /// High priority - important gameplay movement
  high,

  /// Critical priority - emergency stops, safety overrides
  critical,
}

/// Structured movement request for physics system coordination.
///
/// This class encapsulates all information needed for the physics system
/// to process movement requests from other systems, following the
/// request-response coordination pattern defined in the Physics-Movement
/// System Refactor.
///
/// **Design Principles:**
/// - Immutable request data for thread safety
/// - Comprehensive validation before processing
/// - Clear request lifecycle tracking
/// - Support for batching and priority processing
///
/// **Usage Example:**
/// ```dart
/// final request = MovementRequest(
///   entityId: playerId,
///   type: MovementType.walk,
///   direction: Vector2(1, 0),
///   speed: 200.0,
///   priority: MovementPriority.normal,
/// );
///
/// if (request.isValid) {
///   final response = await physicsCoordinator.processRequest(request);
/// }
/// ```
class MovementRequest {
  /// Target entity identifier
  final int entityId;

  /// Type of movement being requested
  final MovementType type;

  /// Movement direction vector (should be normalized for directional movement)
  final Vector2 direction;

  /// Movement speed/magnitude
  /// - For walk/dash: speed in pixels per second
  /// - For jump: force magnitude
  /// - For impulse: force magnitude
  final double magnitude;

  /// Request processing priority
  final MovementPriority priority;

  /// Timestamp when request was created
  final DateTime timestamp;

  /// Optional request identifier for tracking
  final String? requestId;

  /// Optional validation constraints
  final Map<String, dynamic>? constraints;

  /// Create a new movement request.
  ///
  /// **Parameters:**
  /// - [entityId]: Target entity (must have physics component)
  /// - [type]: Type of movement operation
  /// - [direction]: Direction vector (auto-normalized if length > 1)
  /// - [magnitude]: Speed/force magnitude (must be non-negative)
  /// - [priority]: Processing priority (defaults to normal)
  /// - [requestId]: Optional tracking identifier
  /// - [constraints]: Optional validation constraints
  MovementRequest({
    required this.entityId,
    required this.type,
    required this.direction,
    required this.magnitude,
    this.priority = MovementPriority.normal,
    this.requestId,
    this.constraints,
  }) : timestamp = DateTime.now();

  /// Create a walking movement request.
  ///
  /// Convenience constructor for the most common movement type.
  factory MovementRequest.walk({
    required int entityId,
    required Vector2 direction,
    required double speed,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return MovementRequest(
      entityId: entityId,
      type: MovementType.walk,
      direction: direction,
      magnitude: speed,
      priority: priority,
      requestId: requestId,
    );
  }

  /// Create a movement request.
  ///
  /// Alias for MovementRequest.walk for backward compatibility.
  factory MovementRequest.movement({
    required int entityId,
    required Vector2 direction,
    required double speed,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return MovementRequest.walk(
      entityId: entityId,
      direction: direction,
      speed: speed,
      priority: priority,
      requestId: requestId,
    );
  }

  /// Create a jump movement request.
  ///
  /// Convenience constructor for jump actions.
  factory MovementRequest.jump({
    required int entityId,
    required double force,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return MovementRequest(
      entityId: entityId,
      type: MovementType.jump,
      direction: Vector2(0, -1), // Upward direction
      magnitude: force,
      priority: priority,
      requestId: requestId,
    );
  }

  /// Create a stop movement request.
  ///
  /// Convenience constructor for immediate stop commands.
  factory MovementRequest.stop({
    required int entityId,
    MovementPriority priority = MovementPriority.normal,
    String? requestId,
  }) {
    return MovementRequest(
      entityId: entityId,
      type: MovementType.stop,
      direction: Vector2.zero(),
      magnitude: 0.0,
      priority: priority,
      requestId: requestId,
    );
  }

  /// Create an impulse movement request.
  ///
  /// Convenience constructor for force applications.
  factory MovementRequest.impulse({
    required int entityId,
    required Vector2 force,
    MovementPriority priority = MovementPriority.high,
    String? requestId,
  }) {
    return MovementRequest(
      entityId: entityId,
      type: MovementType.impulse,
      direction: force.normalized(),
      magnitude: force.length,
      priority: priority,
      requestId: requestId,
    );
  }

  /// Validate request data for processing.
  ///
  /// Performs comprehensive validation to ensure the request can be safely
  /// processed by the physics system.
  ///
  /// **Validation Checks:**
  /// - Entity ID is valid (non-negative)
  /// - Direction vector is finite and not NaN
  /// - Magnitude is finite, non-negative, and within reasonable bounds
  /// - Movement type specific validations
  ///
  /// **Returns:** true if request is valid for processing
  bool get isValid {
    // Basic validation
    if (entityId < 0) return false;
    if (!direction.x.isFinite || !direction.y.isFinite) return false;
    if (!magnitude.isFinite || magnitude < 0) return false;

    // Type-specific validation
    switch (type) {
      case MovementType.walk:
      case MovementType.dash:
        // Directional movement should have non-zero direction
        return direction.length > 0.001;

      case MovementType.jump:
        // Jump force should be positive
        return magnitude > 0;

      case MovementType.stop:
        // Stop requests are always valid if basic checks pass
        return true;

      case MovementType.impulse:
        // Impulse should have non-zero magnitude
        return magnitude > 0.001;
    }
  }

  /// Get normalized direction vector.
  ///
  /// **Returns:** Direction vector normalized to unit length, or zero vector
  /// if original direction has zero length.
  Vector2 get normalizedDirection {
    if (direction.length < 0.001) return Vector2.zero();
    return direction.normalized();
  }

  /// Get request age in milliseconds.
  ///
  /// **Returns:** Time elapsed since request creation in milliseconds
  int get ageInMilliseconds {
    return DateTime.now().difference(timestamp).inMilliseconds;
  }

  /// Check if request has expired based on age.
  ///
  /// Requests older than the specified timeout should be discarded to
  /// prevent processing stale movement commands.
  ///
  /// **Parameters:**
  /// - [timeoutMs]: Timeout threshold in milliseconds (default: 100ms)
  ///
  /// **Returns:** true if request has exceeded timeout
  bool isExpired([int timeoutMs = 100]) {
    return ageInMilliseconds > timeoutMs;
  }

  /// Create a copy of this request with modified parameters.
  ///
  /// Useful for request transformation or retry operations.
  MovementRequest copyWith({
    int? entityId,
    MovementType? type,
    Vector2? direction,
    double? magnitude,
    MovementPriority? priority,
    String? requestId,
    Map<String, dynamic>? constraints,
  }) {
    return MovementRequest(
      entityId: entityId ?? this.entityId,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      magnitude: magnitude ?? this.magnitude,
      priority: priority ?? this.priority,
      requestId: requestId ?? this.requestId,
      constraints: constraints ?? this.constraints,
    );
  }

  /// Compare requests for priority sorting.
  ///
  /// Higher priority requests should be processed first. If priorities are
  /// equal, earlier timestamps take precedence.
  ///
  /// **Returns:** Negative if this request has higher priority, positive if lower
  int compareTo(MovementRequest other) {
    // Compare by priority first
    final priorityComparison = priority.index.compareTo(other.priority.index);
    if (priorityComparison != 0) {
      return -priorityComparison; // Reverse for higher priority first
    }

    // If same priority, compare by timestamp (earlier first)
    return timestamp.compareTo(other.timestamp);
  }

  @override
  String toString() {
    return 'MovementRequest('
        'entityId: $entityId, '
        'type: $type, '
        'direction: $direction, '
        'magnitude: $magnitude, '
        'priority: $priority, '
        'age: ${ageInMilliseconds}ms'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovementRequest &&
        other.entityId == entityId &&
        other.type == type &&
        other.direction == direction &&
        other.magnitude == magnitude &&
        other.priority == priority &&
        other.requestId == requestId;
  }

  @override
  int get hashCode {
    return Object.hash(
      entityId,
      type,
      direction,
      magnitude,
      priority,
      requestId,
    );
  }
}

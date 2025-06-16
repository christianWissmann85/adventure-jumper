import 'package:flame/components.dart';

import 'movement_request.dart';

/// Response status codes for movement request processing.
///
/// These codes provide detailed feedback about how the physics system
/// processed a movement request, enabling proper error handling and
/// system coordination.
enum MovementResponseStatus {
  /// Request processed successfully with full application
  success,

  /// Request processed but with modifications (e.g., collision constraints)
  partialSuccess,

  /// Request blocked by physics constraints (e.g., wall collision)
  blocked,

  /// Request failed due to invalid entity or physics state
  failed,

  /// Request expired before processing
  expired,

  /// Request rejected due to system limitations or conflicts
  rejected,
}

/// Detailed response information for movement request processing.
///
/// This class provides comprehensive feedback about how the physics system
/// processed a movement request, including actual applied values, constraints
/// encountered, and any modifications made during processing.
///
/// **Design Principles:**
/// - Complete transparency of physics processing results
/// - Detailed constraint and collision information
/// - Performance metrics for optimization
/// - Error information for debugging and recovery
///
/// **Usage Example:**
/// ```dart
/// final response = await physicsCoordinator.requestMovement(
///   playerId, Vector2(1, 0), 200.0
/// );
///
/// if (response.wasSuccessful) {
///   // Update UI, audio, animations based on actual movement
///   print('Applied velocity: ${response.actualVelocity}');
/// } else {
///   // Handle constraint or error conditions
///   print('Movement blocked: ${response.constraintReason}');
/// }
/// ```
class MovementResponse {
  /// Original request that generated this response
  final MovementRequest originalRequest;

  /// Processing status result
  final MovementResponseStatus status;

  /// Actual velocity applied by physics system
  final Vector2 actualVelocity;

  /// Actual position after movement processing
  final Vector2 actualPosition;

  /// Whether the entity is grounded after this movement
  final bool isGrounded;

  /// List of active collisions during movement processing
  final List<String> activeCollisions;

  /// Timestamp when processing completed
  final DateTime processedAt;

  /// Processing time in microseconds
  final int processingTimeMicros;

  /// Reason for constraint or failure (if applicable)
  final String? constraintReason;

  /// Additional debug information
  final Map<String, dynamic>? debugInfo;

  /// Create a movement response.
  ///
  /// **Parameters:**
  /// - [originalRequest]: The request that generated this response
  /// - [status]: Processing status result
  /// - [actualVelocity]: Velocity actually applied by physics
  /// - [actualPosition]: Position after movement processing
  /// - [isGrounded]: Grounded state after movement
  /// - [activeCollisions]: List of collision identifiers
  /// - [processingTimeMicros]: Processing time in microseconds
  /// - [constraintReason]: Reason for constraint/failure (optional)
  /// - [debugInfo]: Additional debug information (optional)
  MovementResponse({
    required this.originalRequest,
    required this.status,
    required this.actualVelocity,
    required this.actualPosition,
    required this.isGrounded,
    required this.activeCollisions,
    required this.processingTimeMicros,
    this.constraintReason,
    this.debugInfo,
  }) : processedAt = DateTime.now();

  /// Create a successful response.
  ///
  /// Convenience constructor for successful movement processing.
  factory MovementResponse.success({
    required MovementRequest request,
    required Vector2 actualVelocity,
    required Vector2 actualPosition,
    required bool isGrounded,
    List<String> activeCollisions = const [],
    int processingTimeMicros = 0,
    Map<String, dynamic>? debugInfo,
  }) {
    return MovementResponse(
      originalRequest: request,
      status: MovementResponseStatus.success,
      actualVelocity: actualVelocity,
      actualPosition: actualPosition,
      isGrounded: isGrounded,
      activeCollisions: activeCollisions,
      processingTimeMicros: processingTimeMicros,
      debugInfo: debugInfo,
    );
  }

  /// Create a partial success response.
  ///
  /// Used when movement was applied but modified due to constraints.
  factory MovementResponse.partialSuccess({
    required MovementRequest request,
    required Vector2 actualVelocity,
    required Vector2 actualPosition,
    required bool isGrounded,
    required String constraintReason,
    List<String> activeCollisions = const [],
    int processingTimeMicros = 0,
    Map<String, dynamic>? debugInfo,
  }) {
    return MovementResponse(
      originalRequest: request,
      status: MovementResponseStatus.partialSuccess,
      actualVelocity: actualVelocity,
      actualPosition: actualPosition,
      isGrounded: isGrounded,
      activeCollisions: activeCollisions,
      processingTimeMicros: processingTimeMicros,
      constraintReason: constraintReason,
      debugInfo: debugInfo,
    );
  }

  /// Create a blocked response.
  ///
  /// Used when movement was completely prevented by constraints.
  factory MovementResponse.blocked({
    required MovementRequest request,
    required Vector2 currentPosition,
    required bool isGrounded,
    required String reason,
    List<String> activeCollisions = const [],
    int processingTimeMicros = 0,
    Map<String, dynamic>? debugInfo,
  }) {
    return MovementResponse(
      originalRequest: request,
      status: MovementResponseStatus.blocked,
      actualVelocity: Vector2.zero(),
      actualPosition: currentPosition,
      isGrounded: isGrounded,
      activeCollisions: activeCollisions,
      processingTimeMicros: processingTimeMicros,
      constraintReason: reason,
      debugInfo: debugInfo,
    );
  }

  /// Create a failed response.
  ///
  /// Used when request processing failed due to errors.
  factory MovementResponse.failed({
    required MovementRequest request,
    required String reason,
    Vector2? currentPosition,
    bool isGrounded = false,
    int processingTimeMicros = 0,
    Map<String, dynamic>? debugInfo,
  }) {
    return MovementResponse(
      originalRequest: request,
      status: MovementResponseStatus.failed,
      actualVelocity: Vector2.zero(),
      actualPosition: currentPosition ?? Vector2.zero(),
      isGrounded: isGrounded,
      activeCollisions: const [],
      processingTimeMicros: processingTimeMicros,
      constraintReason: reason,
      debugInfo: debugInfo,
    );
  }

  /// Check if the movement was successfully applied.
  ///
  /// **Returns:** true for success or partialSuccess status
  bool get wasSuccessful {
    return status == MovementResponseStatus.success ||
        status == MovementResponseStatus.partialSuccess;
  }

  /// Check if the movement was completely blocked.
  ///
  /// **Returns:** true if movement was prevented by constraints
  bool get wasBlocked {
    return status == MovementResponseStatus.blocked;
  }

  /// Check if the request failed due to errors.
  ///
  /// **Returns:** true if processing failed or request was rejected
  bool get hasFailed {
    return status == MovementResponseStatus.failed ||
        status == MovementResponseStatus.rejected ||
        status == MovementResponseStatus.expired;
  }

  /// Get the difference between requested and actual velocity.
  ///
  /// This helps identify how much the physics system modified the
  /// requested movement due to constraints or collisions.
  ///
  /// **Returns:** Vector representing velocity modification
  Vector2 get velocityDelta {
    final requestedVelocity =
        originalRequest.normalizedDirection * originalRequest.magnitude;
    return actualVelocity - requestedVelocity;
  }

  /// Get the magnitude of velocity modification.
  ///
  /// **Returns:** How much the velocity was changed from requested
  double get velocityModification {
    return velocityDelta.length;
  }

  /// Check if the response indicates collision occurred.
  ///
  /// **Returns:** true if any collisions were detected during processing
  bool get hasCollisions {
    return activeCollisions.isNotEmpty;
  }

  /// Get response age in milliseconds.
  ///
  /// **Returns:** Time elapsed since response was created
  int get ageInMilliseconds {
    return DateTime.now().difference(processedAt).inMilliseconds;
  }

  /// Get processing time in milliseconds.
  ///
  /// **Returns:** Time taken to process the request in milliseconds
  double get processingTimeMs {
    return processingTimeMicros / 1000.0;
  }

  /// Check if processing was performant.
  ///
  /// **Parameters:**
  /// - [thresholdMs]: Performance threshold in milliseconds (default: 2ms)
  ///
  /// **Returns:** true if processing time was under threshold
  bool isPerformant([double thresholdMs = 2.0]) {
    return processingTimeMs <= thresholdMs;
  }

  /// Get detailed status description.
  ///
  /// **Returns:** Human-readable description of the response status
  String get statusDescription {
    switch (status) {
      case MovementResponseStatus.success:
        return 'Movement applied successfully';
      case MovementResponseStatus.partialSuccess:
        return 'Movement partially applied: ${constraintReason ?? 'constrained'}';
      case MovementResponseStatus.blocked:
        return 'Movement blocked: ${constraintReason ?? 'collision'}';
      case MovementResponseStatus.failed:
        return 'Movement failed: ${constraintReason ?? 'error'}';
      case MovementResponseStatus.expired:
        return 'Movement request expired';
      case MovementResponseStatus.rejected:
        return 'Movement request rejected: ${constraintReason ?? 'system limit'}';
    }
  }

  /// Create a copy of this response with modified parameters.
  ///
  /// Useful for response transformation or debugging.
  MovementResponse copyWith({
    MovementRequest? originalRequest,
    MovementResponseStatus? status,
    Vector2? actualVelocity,
    Vector2? actualPosition,
    bool? isGrounded,
    List<String>? activeCollisions,
    int? processingTimeMicros,
    String? constraintReason,
    Map<String, dynamic>? debugInfo,
  }) {
    return MovementResponse(
      originalRequest: originalRequest ?? this.originalRequest,
      status: status ?? this.status,
      actualVelocity: actualVelocity ?? this.actualVelocity,
      actualPosition: actualPosition ?? this.actualPosition,
      isGrounded: isGrounded ?? this.isGrounded,
      activeCollisions: activeCollisions ?? this.activeCollisions,
      processingTimeMicros: processingTimeMicros ?? this.processingTimeMicros,
      constraintReason: constraintReason ?? this.constraintReason,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }

  @override
  String toString() {
    return 'MovementResponse('
        'status: $status, '
        'velocity: $actualVelocity, '
        'position: $actualPosition, '
        'grounded: $isGrounded, '
        'collisions: ${activeCollisions.length}, '
        'processingTime: ${processingTimeMs.toStringAsFixed(2)}ms'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovementResponse &&
        other.originalRequest == originalRequest &&
        other.status == status &&
        other.actualVelocity == actualVelocity &&
        other.actualPosition == actualPosition &&
        other.isGrounded == isGrounded &&
        other.processingTimeMicros == processingTimeMicros;
  }

  @override
  int get hashCode {
    return Object.hash(
      originalRequest,
      status,
      actualVelocity,
      actualPosition,
      isGrounded,
      processingTimeMicros,
    );
  }
}

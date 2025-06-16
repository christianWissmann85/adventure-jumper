import 'package:flame/components.dart';

/// PHY-3.2.3: Respawn state for physics system reset.
///
/// Contains all necessary data for resetting an entity's physics state
/// during respawn operations. This ensures complete physics reset
/// including clearing any accumulated forces that could cause
/// physics degradation.
///
/// **Usage Example:**
/// ```dart
/// final respawnState = RespawnState(
///   spawnPosition: Vector2(100, 300),
///   spawnVelocity: Vector2.zero(),
///   resetPhysicsAccumulation: true,
/// );
/// await physicsCoordinator.resetPhysicsState(entityId, respawnState);
/// ```
class RespawnState {
  /// The position to respawn the entity at
  final Vector2 spawnPosition;
  
  /// The initial velocity after respawn (usually zero)
  final Vector2 spawnVelocity;
  
  /// Whether to reset all physics accumulation
  /// This is critical for preventing physics degradation
  final bool resetPhysicsAccumulation;
  
  /// Optional respawn reason for debugging
  final String? respawnReason;
  
  /// Timestamp of the respawn
  final DateTime timestamp;
  
  /// Additional metadata for respawn tracking
  final Map<String, dynamic>? metadata;
  
  /// Whether this is a safe respawn (vs death respawn)
  final bool isSafeRespawn;
  
  /// Create a new respawn state.
  const RespawnState({
    required this.spawnPosition,
    required this.spawnVelocity,
    required this.resetPhysicsAccumulation,
    this.respawnReason,
    DateTime? timestamp,
    this.metadata,
    this.isSafeRespawn = true,
  }) : timestamp = timestamp ?? const _CurrentDateTime();
  
  /// Factory for death respawn with full reset.
  factory RespawnState.deathRespawn({
    required Vector2 spawnPosition,
    String? deathReason,
    Map<String, dynamic>? metadata,
  }) {
    return RespawnState(
      spawnPosition: spawnPosition,
      spawnVelocity: Vector2.zero(),
      resetPhysicsAccumulation: true, // Always reset on death
      respawnReason: deathReason ?? 'death',
      isSafeRespawn: false,
      metadata: metadata,
    );
  }
  
  /// Factory for checkpoint respawn.
  factory RespawnState.checkpointRespawn({
    required Vector2 checkpointPosition,
    bool resetVelocity = true,
    Map<String, dynamic>? metadata,
  }) {
    return RespawnState(
      spawnPosition: checkpointPosition,
      spawnVelocity: resetVelocity ? Vector2.zero() : Vector2.zero(), // Could preserve velocity
      resetPhysicsAccumulation: true, // Reset to prevent accumulation
      respawnReason: 'checkpoint',
      isSafeRespawn: true,
      metadata: metadata,
    );
  }
  
  /// Factory for out-of-bounds respawn.
  factory RespawnState.outOfBounds({
    required Vector2 lastSafePosition,
    Map<String, dynamic>? metadata,
  }) {
    return RespawnState(
      spawnPosition: lastSafePosition,
      spawnVelocity: Vector2.zero(),
      resetPhysicsAccumulation: true, // Critical for bounds respawn
      respawnReason: 'out_of_bounds',
      isSafeRespawn: true,
      metadata: metadata,
    );
  }
  
  /// Create a copy with modified values.
  RespawnState copyWith({
    Vector2? spawnPosition,
    Vector2? spawnVelocity,
    bool? resetPhysicsAccumulation,
    String? respawnReason,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isSafeRespawn,
  }) {
    return RespawnState(
      spawnPosition: spawnPosition ?? this.spawnPosition,
      spawnVelocity: spawnVelocity ?? this.spawnVelocity,
      resetPhysicsAccumulation: resetPhysicsAccumulation ?? this.resetPhysicsAccumulation,
      respawnReason: respawnReason ?? this.respawnReason,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isSafeRespawn: isSafeRespawn ?? this.isSafeRespawn,
    );
  }
  
  @override
  String toString() {
    return 'RespawnState('
        'position: $spawnPosition, '
        'velocity: $spawnVelocity, '
        'resetAccumulation: $resetPhysicsAccumulation, '
        'reason: $respawnReason, '
        'safe: $isSafeRespawn'
        ')';
  }
}

/// Helper class for const datetime creation.
class _CurrentDateTime implements DateTime {
  const _CurrentDateTime();
  
  @override
  DateTime add(Duration duration) => DateTime.now().add(duration);
  
  @override
  DateTime subtract(Duration duration) => DateTime.now().subtract(duration);
  
  @override
  Duration difference(DateTime other) => DateTime.now().difference(other);
  
  @override
  int compareTo(DateTime other) => DateTime.now().compareTo(other);
  
  @override
  bool isAfter(DateTime other) => DateTime.now().isAfter(other);
  
  @override
  bool isBefore(DateTime other) => DateTime.now().isBefore(other);
  
  @override
  bool isAtSameMomentAs(DateTime other) => DateTime.now().isAtSameMomentAs(other);
  
  @override
  String toIso8601String() => DateTime.now().toIso8601String();
  
  @override
  String toString() => DateTime.now().toString();
  
  @override
  DateTime toLocal() => DateTime.now().toLocal();
  
  @override
  DateTime toUtc() => DateTime.now().toUtc();
  
  @override
  int get year => DateTime.now().year;
  
  @override
  int get month => DateTime.now().month;
  
  @override
  int get day => DateTime.now().day;
  
  @override
  int get hour => DateTime.now().hour;
  
  @override
  int get minute => DateTime.now().minute;
  
  @override
  int get second => DateTime.now().second;
  
  @override
  int get millisecond => DateTime.now().millisecond;
  
  @override
  int get microsecond => DateTime.now().microsecond;
  
  @override
  int get weekday => DateTime.now().weekday;
  
  @override
  int get millisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;
  
  @override
  int get microsecondsSinceEpoch => DateTime.now().microsecondsSinceEpoch;
  
  @override
  String get timeZoneName => DateTime.now().timeZoneName;
  
  @override
  Duration get timeZoneOffset => DateTime.now().timeZoneOffset;
  
  @override
  bool get isUtc => DateTime.now().isUtc;
}
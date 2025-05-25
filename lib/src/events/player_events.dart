import 'package:flame/components.dart';

import '../utils/logger.dart';

/// Player event types for the event system
enum PlayerEventType {
  landed,
  leftGround,
  jumped,
  nearEdge,
  leftEdge,
  takeDamage,
  heal,
  collectItem,
  reachCheckpoint,
}

/// Base class for player events
abstract class PlayerEvent {
  const PlayerEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });

  final PlayerEventType type;
  final double timestamp;
  final Map<String, dynamic>? data;
}

/// Event fired when player lands on ground
class PlayerLandedEvent extends PlayerEvent {
  const PlayerLandedEvent({
    required super.timestamp,
    required this.landingVelocity,
    required this.landingPosition,
    required this.groundNormal,
    this.impactForce,
    this.platformType,
  }) : super(type: PlayerEventType.landed);

  final Vector2 landingVelocity;
  final Vector2 landingPosition;
  final Vector2 groundNormal;
  final double? impactForce;
  final String? platformType;

  @override
  Map<String, dynamic>? get data => {
        'landingVelocity': landingVelocity,
        'landingPosition': landingPosition,
        'groundNormal': groundNormal,
        'impactForce': impactForce,
        'platformType': platformType,
      };
}

/// Event fired when player leaves ground
class PlayerLeftGroundEvent extends PlayerEvent {
  const PlayerLeftGroundEvent({
    required super.timestamp,
    required this.leavePosition,
    required this.leaveVelocity,
    required this.leaveReason,
  }) : super(type: PlayerEventType.leftGround);

  final Vector2 leavePosition;
  final Vector2 leaveVelocity;
  final String leaveReason; // 'jump', 'fall', 'pushed'

  @override
  Map<String, dynamic>? get data => {
        'leavePosition': leavePosition,
        'leaveVelocity': leaveVelocity,
        'leaveReason': leaveReason,
      };
}

/// Event fired when player performs a jump
class PlayerJumpedEvent extends PlayerEvent {
  const PlayerJumpedEvent({
    required super.timestamp,
    required this.jumpPosition,
    required this.jumpForce,
    required this.isFromGround,
    this.isCoyoteJump = false,
  }) : super(type: PlayerEventType.jumped);

  final Vector2 jumpPosition;
  final double jumpForce;
  final bool isFromGround;
  final bool isCoyoteJump;

  @override
  Map<String, dynamic>? get data => {
        'jumpPosition': jumpPosition,
        'jumpForce': jumpForce,
        'isFromGround': isFromGround,
        'isCoyoteJump': isCoyoteJump,
      };
}

/// Event fired when player approaches a platform edge
class PlayerNearEdgeEvent extends PlayerEvent {
  const PlayerNearEdgeEvent({
    required super.timestamp,
    required this.edgePosition,
    required this.edgeDistance,
    required this.edgeSide,
    required this.playerPosition,
  }) : super(type: PlayerEventType.nearEdge);

  final Vector2 edgePosition;
  final double edgeDistance;
  final String edgeSide; // 'left', 'right', 'both'
  final Vector2 playerPosition;

  @override
  Map<String, dynamic>? get data => {
        'edgePosition': edgePosition,
        'edgeDistance': edgeDistance,
        'edgeSide': edgeSide,
        'playerPosition': playerPosition,
      };
}

/// Event fired when player moves away from a platform edge
class PlayerLeftEdgeEvent extends PlayerEvent {
  const PlayerLeftEdgeEvent({
    required super.timestamp,
    required this.previousEdgePosition,
    required this.edgeSide,
    required this.playerPosition,
  }) : super(type: PlayerEventType.leftEdge);

  final Vector2 previousEdgePosition;
  final String edgeSide; // 'left', 'right', 'both'
  final Vector2 playerPosition;

  @override
  Map<String, dynamic>? get data => {
        'previousEdgePosition': previousEdgePosition,
        'edgeSide': edgeSide,
        'playerPosition': playerPosition,
      };
}

/// Simple event bus for player events
class PlayerEventBus {
  PlayerEventBus._();
  static final PlayerEventBus _instance = PlayerEventBus._();
  static PlayerEventBus get instance => _instance;

  final List<void Function(PlayerEvent)> _listeners = [];
  final List<PlayerEvent> _eventHistory = [];
  static const int maxEventHistory = 100;

  /// Add an event listener
  void addListener(void Function(PlayerEvent) listener) {
    _listeners.add(listener);
  }

  /// Remove an event listener
  void removeListener(void Function(PlayerEvent) listener) {
    _listeners.remove(listener);
  }

  /// Fire an event to all listeners
  void fireEvent(PlayerEvent event) {
    // Add to event history
    _eventHistory.add(event);
    if (_eventHistory.length > maxEventHistory) {
      _eventHistory.removeAt(0);
    }

    // Notify all listeners
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        // Log error but continue with other listeners
        logger.severe('Error in event listener', e);
      }
    }
  }

  /// Get recent events of a specific type
  List<PlayerEvent> getRecentEvents(PlayerEventType type, {int count = 10}) {
    return _eventHistory
        .where((event) => event.type == type)
        .toList()
        .reversed
        .take(count)
        .toList();
  }

  /// Clear all listeners (useful for testing)
  void clearListeners() {
    _listeners.clear();
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
  }
}

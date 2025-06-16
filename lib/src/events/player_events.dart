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
  statChanged,
  levelUp,
  aetherChanged,
  healthChanged,
  energyChanged,
  experienceGained,
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

/// Event fired when player stats change
class PlayerStatChangedEvent extends PlayerEvent {
  const PlayerStatChangedEvent({
    required super.timestamp,
    required this.statType,
    required this.oldValue,
    required this.newValue,
    required this.maxValue,
    this.changeReason,
  }) : super(type: PlayerEventType.statChanged);

  final String statType; // 'health', 'energy', 'aether', 'experience'
  final double oldValue;
  final double newValue;
  final double maxValue;
  final String?
      changeReason; // 'damage', 'heal', 'collect', 'ability_use', etc.

  @override
  Map<String, dynamic>? get data => {
        'statType': statType,
        'oldValue': oldValue,
        'newValue': newValue,
        'maxValue': maxValue,
        'changeReason': changeReason,
      };
}

/// Event fired when player levels up
class PlayerLevelUpEvent extends PlayerEvent {
  const PlayerLevelUpEvent({
    required super.timestamp,
    required this.oldLevel,
    required this.newLevel,
    required this.healthIncrease,
    required this.energyIncrease,
  }) : super(type: PlayerEventType.levelUp);

  final int oldLevel;
  final int newLevel;
  final double healthIncrease;
  final double energyIncrease;

  @override
  Map<String, dynamic>? get data => {
        'oldLevel': oldLevel,
        'newLevel': newLevel,
        'healthIncrease': healthIncrease,
        'energyIncrease': energyIncrease,
      };
}

/// Event fired when Aether value changes
class PlayerAetherChangedEvent extends PlayerEvent {
  const PlayerAetherChangedEvent({
    required super.timestamp,
    required this.oldAmount,
    required this.newAmount,
    required this.maxAmount,
    required this.changeAmount,
    this.changeReason,
  }) : super(type: PlayerEventType.aetherChanged);

  final int oldAmount;
  final int newAmount;
  final int maxAmount;
  final int changeAmount;
  final String? changeReason;

  @override
  Map<String, dynamic>? get data => {
        'oldAmount': oldAmount,
        'newAmount': newAmount,
        'maxAmount': maxAmount,
        'changeAmount': changeAmount,
        'changeReason': changeReason,
      };
}

/// Event fired when health changes
class PlayerHealthChangedEvent extends PlayerEvent {
  const PlayerHealthChangedEvent({
    required super.timestamp,
    required this.oldHealth,
    required this.newHealth,
    required this.maxHealth,
    required this.changeAmount,
    this.changeReason,
  }) : super(type: PlayerEventType.healthChanged);

  final double oldHealth;
  final double newHealth;
  final double maxHealth;
  final double changeAmount;
  final String? changeReason;

  @override
  Map<String, dynamic>? get data => {
        'oldHealth': oldHealth,
        'newHealth': newHealth,
        'maxHealth': maxHealth,
        'changeAmount': changeAmount,
        'changeReason': changeReason,
      };
}

/// Event fired when energy changes
class PlayerEnergyChangedEvent extends PlayerEvent {
  const PlayerEnergyChangedEvent({
    required super.timestamp,
    required this.oldEnergy,
    required this.newEnergy,
    required this.maxEnergy,
    required this.changeAmount,
    this.changeReason,
  }) : super(type: PlayerEventType.energyChanged);

  final double oldEnergy;
  final double newEnergy;
  final double maxEnergy;
  final double changeAmount;
  final String? changeReason;

  @override
  Map<String, dynamic>? get data => {
        'oldEnergy': oldEnergy,
        'newEnergy': newEnergy,
        'maxEnergy': maxEnergy,
        'changeAmount': changeAmount,
        'changeReason': changeReason,
      };
}

/// Event fired when experience is gained
class PlayerExperienceGainedEvent extends PlayerEvent {
  const PlayerExperienceGainedEvent({
    required super.timestamp,
    required this.oldExperience,
    required this.newExperience,
    required this.experienceGained,
    required this.experienceToNextLevel,
    this.source,
  }) : super(type: PlayerEventType.experienceGained);

  final int oldExperience;
  final int newExperience;
  final int experienceGained;
  final int experienceToNextLevel;
  final String? source; // 'combat', 'exploration', 'quest', etc.

  @override
  Map<String, dynamic>? get data => {
        'oldExperience': oldExperience,
        'newExperience': newExperience,
        'experienceGained': experienceGained,
        'experienceToNextLevel': experienceToNextLevel,
        'source': source,
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

// filepath: c:\Users\User\source\repos\Cascade\adventure-jumper\lib\src\systems\aether_system.dart
import 'package:flame/components.dart';

import '../components/aether_component.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import '../player/player_stats.dart';
import 'base_system.dart';

/// System that manages Aether mechanics processing
/// Handles Aether abilities, energy flow, and environmental Aether effects
class AetherSystem extends BaseSystem {
  AetherSystem();

  // Configuration
  double _globalAetherMultiplier = 1;

  // Aether effects
  final List<AetherEffect> _activeEffects = <AetherEffect>[];
  // Player reference
  Player? _playerEntity;

  // Aether operation requests
  final List<AetherRequest> _pendingRequests = <AetherRequest>[];

  // Environmental Aether settings
  double _environmentalAetherLevel = 0; // 0.0-1.0 scale
  bool _environmentalAetherActive = false;

  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has an aether component
    return entity.children.whereType<AetherComponent>().isNotEmpty;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Find Aether component on entity
    final Iterable<AetherComponent> aetherComponents =
        entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return;

    final AetherComponent aetherComponent = aetherComponents
        .first; // T2.9.1: Read regeneration parameters from AetherComponent
    // These will be used for advanced regeneration logic in future sprints
    // final double currentRegenRate = aetherComponent.aetherRegenRate;

    // TODO: Apply global Aether multiplier to regeneration (Sprint 6)
    // final double effectiveRegenRate = currentRegenRate * _globalAetherMultiplier;

    // TODO: Apply environmental Aether effects if active (Sprint 6)
    // if (_environmentalAetherActive && _environmentalAetherLevel > 0.2) {
    //   final double aetherRegenBonus = 1.0 + (_environmentalAetherLevel * 0.5);
    //   // Apply environmental bonus to regeneration rate
    // }

    // Read PlayerStats if this is the player entity (T2.9.1)
    if (entity is Player) {
      final PlayerStats? playerStats =
          entity.children.whereType<PlayerStats>().isNotEmpty
              ? entity.children.whereType<PlayerStats>().first
              : null;

      if (playerStats != null) {
        // Read Aether parameters from PlayerStats
        final int playerCurrentAether = playerStats.currentAether;
        final int playerMaxAether = playerStats.maxAether;

        // Sync AetherComponent with PlayerStats if values differ
        if ((aetherComponent.currentAether.round() != playerCurrentAether) ||
            (aetherComponent.maxAether.round() != playerMaxAether)) {
          // Update AetherComponent to match PlayerStats
          aetherComponent.setMaxAether(playerMaxAether.toDouble());
          if (aetherComponent.currentAether.round() != playerCurrentAether) {
            final double difference =
                playerCurrentAether - aetherComponent.currentAether;
            if (difference > 0) {
              aetherComponent.addAether(difference);
            } else if (difference < 0) {
              aetherComponent.consumeAether(-difference);
            }
          }
        }
      }
    }

    // Process any pending Aether requests for this entity (T2.9.2)
    _processPendingRequestsForEntity(entity);
  }

  @override
  void processSystem(double dt) {
    // Update active Aether effects
    _updateAetherEffects(dt);

    // Update environmental Aether
    if (_environmentalAetherActive) {
      _updateEnvironmentalAether(dt);
    }
  }

  /// Update all active Aether effects
  void _updateAetherEffects(double dt) {
    // Process all active effects
    final List<AetherEffect> expiredEffects = <AetherEffect>[];

    for (final AetherEffect effect in _activeEffects) {
      effect.update(dt);

      if (effect.isExpired) {
        expiredEffects.add(effect);
      }
    }

    // Remove expired effects
    for (final AetherEffect expired in expiredEffects) {
      _activeEffects.remove(expired);
    }
  }

  /// Update environmental Aether effects
  void _updateEnvironmentalAether(double dt) {
    // This would handle global Aether effects like:
    // - Aether storms
    // - Environmental interactions
    // - Background Aether visuals
    // - Aether-sensitive game mechanics
  }

  /// Create and register a new Aether effect
  AetherEffect createAetherEffect({
    required Vector2 position,
    required double radius,
    required double duration,
    double? damage,
    String? effectType,
    Entity? source,
  }) {
    final AetherEffect effect = AetherEffect(
      position: position,
      radius: radius,
      duration: duration,
      damage: damage ?? 0.0,
      effectType: effectType ?? 'generic',
      source: source,
    );

    _activeEffects.add(effect);
    return effect;
  }

  /// Helper method for backward compatibility
  @override
  void registerEntity(Entity entity) {
    addEntity(entity);
  }

  /// Helper method for backward compatibility
  @override
  void unregisterEntity(Entity entity) {
    removeEntity(entity);
  }

  /// Set global Aether multiplier
  void setAetherMultiplier(double multiplier) {
    _globalAetherMultiplier = multiplier;
  }

  /// Set environmental Aether level
  void setEnvironmentalAether(double level, {bool? active}) {
    _environmentalAetherLevel = level.clamp(0.0, 1.0);

    if (active != null) {
      _environmentalAetherActive = active;
    }
  }

  /// Clear all Aether effects
  void clearEffects() {
    _activeEffects.clear();
  }

  // Getters
  double get aetherMultiplier => _globalAetherMultiplier;
  double get environmentalAetherLevel => _environmentalAetherLevel;
  bool get environmentalAetherActive => _environmentalAetherActive;
  int get activeEffectsCount => _activeEffects.length;

  @override
  void initialize() {
    // Initialize any resources needed by the aether system
  }

  @override
  void onEntityAdded(Entity entity) {
    // Track player entity
    if (entity is Player && _playerEntity == null) {
      _playerEntity = entity;
    }
  }

  @override
  void onEntityRemoved(Entity entity) {
    if (entity == _playerEntity) {
      _playerEntity = null;
    }
  }

  /// Process pending Aether requests for a specific entity (T2.9.2)
  void _processPendingRequestsForEntity(Entity entity) {
    final List<AetherRequest> entityRequests =
        _pendingRequests.where((request) => request.entity == entity).toList();

    // Process each request for this entity
    for (final AetherRequest request in entityRequests) {
      _processAetherRequest(request);
    }

    // Remove processed requests
    _pendingRequests.removeWhere((request) => request.entity == entity);
  }

  /// Process a single Aether request (T2.9.2)
  void _processAetherRequest(AetherRequest request) {
    // Find AetherComponent on the entity
    final Iterable<AetherComponent> aetherComponents =
        request.entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return;

    final AetherComponent aetherComponent = aetherComponents.first;

    // Handle different operations
    switch (request.operation) {
      case AetherOperation.add:
        aetherComponent.addAether(request.amount);
        break;
      case AetherOperation.consume:
        aetherComponent.consumeAether(request.amount);
        break;
      case AetherOperation.setMax:
        aetherComponent.setMaxAether(request.amount);
        break;
      case AetherOperation.setRegenRate:
        aetherComponent.setAetherRegenRate(request.amount);
        break;
    }

    // T2.9.4: Broadcast system event
    _broadcastAetherEvent(request);
  }

  /// Broadcast Aether system events (T2.9.4)
  void _broadcastAetherEvent(AetherRequest request) {
    // For now, we'll log the system operation
    // In the future, we could create a dedicated SystemEventBus
    // or extend PlayerEventBus to handle general system events
    print(
      'AetherSystem operation: ${request.operation} amount:${request.amount} reason:${request.reason}',
    );

    // TODO: Implement proper system event broadcasting in future Sprint
    // This could be used by UI systems, audio systems, etc.
    // Example: _systemEventBus.fireEvent(AetherSystemEvent(...));
  }

  // T2.9.2: Public methods for external systems to request Aether modifications

  /// Request to add Aether to an entity
  void requestAddAether(Entity entity, double amount, {String? reason}) {
    final AetherRequest request = AetherRequest(
      entity: entity,
      operation: AetherOperation.add,
      amount: amount,
      reason: reason ?? 'system_request',
    );
    _pendingRequests.add(request);
  }

  /// Request to consume Aether from an entity
  void requestConsumeAether(Entity entity, double amount, {String? reason}) {
    final AetherRequest request = AetherRequest(
      entity: entity,
      operation: AetherOperation.consume,
      amount: amount,
      reason: reason ?? 'system_request',
    );
    _pendingRequests.add(request);
  }

  /// Request to modify Aether capacity (T2.9.3)
  void requestSetMaxAether(Entity entity, double maxAmount, {String? reason}) {
    final AetherRequest request = AetherRequest(
      entity: entity,
      operation: AetherOperation.setMax,
      amount: maxAmount,
      reason: reason ?? 'capacity_modification',
    );
    _pendingRequests.add(request);
  }

  /// Request to modify Aether regeneration rate (T2.9.3)
  void requestSetRegenRate(Entity entity, double regenRate, {String? reason}) {
    final AetherRequest request = AetherRequest(
      entity: entity,
      operation: AetherOperation.setRegenRate,
      amount: regenRate,
      reason: reason ?? 'regen_modification',
    );
    _pendingRequests.add(request);
  }

  /// Check if an entity can consume a specific amount of Aether
  bool canConsumeAether(Entity entity, double amount) {
    final Iterable<AetherComponent> aetherComponents =
        entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return false;

    final AetherComponent aetherComponent = aetherComponents.first;
    return aetherComponent.currentAether >= amount;
  }

  /// Get current Aether amount for an entity
  double getCurrentAether(Entity entity) {
    final Iterable<AetherComponent> aetherComponents =
        entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return 0.0;

    return aetherComponents.first.currentAether;
  }

  /// Get maximum Aether amount for an entity
  double getMaxAether(Entity entity) {
    final Iterable<AetherComponent> aetherComponents =
        entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return 0.0;

    return aetherComponents.first.maxAether;
  }
}

/// Class representing an active Aether effect in the world
class AetherEffect {
  AetherEffect({
    required this.position,
    required this.radius,
    required this.duration,
    required this.effectType,
    this.damage = 0.0,
    this.source,
  });

  Vector2 position;
  double radius;
  double duration;
  double damage;
  double currentTime = 0;
  bool _isExpired = false;
  final String effectType;
  final Entity? source;

  /// Update the effect
  void update(double dt) {
    currentTime += dt;

    if (currentTime >= duration) {
      _isExpired = true;
    }
  }

  /// Get current scale factor (for visual effects)
  double get scaleFactor {
    // For pulsing/growing/shrinking effects
    if (duration <= 0) return 1;

    return 1.0 + (currentTime / duration);
  }

  /// Check if effect is expired
  bool get isExpired => _isExpired;

  /// Manually expire the effect
  void expire() {
    _isExpired = true;
  }

  /// Get effect progress (0.0-1.0)
  double get progress =>
      duration <= 0 ? 1.0 : (currentTime / duration).clamp(0.0, 1.0);
}

/// Class representing a request to modify Aether values
class AetherRequest {
  AetherRequest({
    required this.entity,
    required this.operation,
    required this.amount,
    this.reason,
  });

  final Entity entity;
  final AetherOperation operation;
  final double amount;
  final String? reason;
}

/// Enumeration of Aether operations
enum AetherOperation {
  add,
  consume,
  setMax,
  setRegenRate,
}

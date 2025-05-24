import 'package:flame/components.dart';

import '../components/aether_component.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import 'system.dart';

/// System that manages Aether mechanics processing
/// Handles Aether abilities, energy flow, and environmental Aether effects
class AetherSystem extends System {
  AetherSystem();

  // Entities processed by this system
  final List<Entity> _entities = <Entity>[];

  // Configuration
  double _globalAetherMultiplier = 1;

  // Aether effects
  final List<AetherEffect> _activeEffects = <AetherEffect>[];

  // Player reference
  Player? _playerEntity;

  // Environmental Aether settings
  double _environmentalAetherLevel = 0; // 0.0-1.0 scale
  bool _environmentalAetherActive = false;

  @override
  void update(double dt) {
    if (!isActive) return;

    // Process Aether for each entity
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;

      processEntityAether(entity, dt);
    }

    // Update active Aether effects
    _updateAetherEffects(dt);

    // Update environmental Aether
    if (_environmentalAetherActive) {
      _updateEnvironmentalAether(dt);
    }
  }

  /// Process Aether mechanics for a single entity
  void processEntityAether(Entity entity, double dt) {
    // Find Aether component on entity
    final Iterable<AetherComponent> aetherComponents =
        entity.children.whereType<AetherComponent>();
    if (aetherComponents.isEmpty) return;

    // Will be used in Sprint 3 when implementing environmental Aether effects
    // ignore: unused_local_variable
    final AetherComponent aetherComponent = aetherComponents.first;

    // Apply environmental Aether effects if active
    if (_environmentalAetherActive && _environmentalAetherLevel > 0.2) {
      // Environmental Aether can affect entity properties
      // For example, faster Aether regeneration in high-Aether areas
      // Will be used in Sprint 3 when implementing environmental Aether effects
      // ignore: unused_local_variable
      final double aetherRegenBonus = 1.0 + (_environmentalAetherLevel * 0.5);
      // This would need to be implemented in AetherComponent
      // Will be implemented in Sprint 3
      // aetherComponent.applyEnvironmentalBonus(aetherRegenBonus);
    }

    // Aether component handles most of its own update logic internally
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

  /// Register an entity with this system
  void registerEntity(Entity entity) {
    if (!_entities.contains(entity)) {
      _entities.add(entity);
    } // Track player entity
    if (entity is Player && _playerEntity == null) {
      _playerEntity = entity;
    }
  }

  /// Unregister an entity from this system
  void unregisterEntity(Entity entity) {
    _entities.remove(entity);

    if (entity == _playerEntity) {
      _playerEntity = null;
    }
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

  /// Clear all entities
  void clearEntities() {
    _entities.clear();
    _playerEntity = null;
  }

  /// Clear all Aether effects
  void clearEffects() {
    _activeEffects.clear();
  }

  // Getters
  int get entityCount => _entities.length;
  double get aetherMultiplier => _globalAetherMultiplier;
  double get environmentalAetherLevel => _environmentalAetherLevel;
  bool get environmentalAetherActive => _environmentalAetherActive;
  int get activeEffectsCount => _activeEffects.length;

  @override
  void initialize() {
    // Initialize any resources needed by the aether system
  }

  @override
  void dispose() {
    _entities.clear();
    _activeEffects.clear();
    _playerEntity = null;
  }

  @override
  void addEntity(Entity entity) {
    registerEntity(entity);
  }

  @override
  void removeEntity(Entity entity) {
    unregisterEntity(entity);
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

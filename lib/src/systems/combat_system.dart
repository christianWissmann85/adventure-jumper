// filepath: c:\Users\User\source\repos\Cascade\adventure-jumper\lib\src\systems\combat_system.dart
import 'package:flame/components.dart';

import '../components/health_component.dart';
import '../entities/enemy.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import 'base_system.dart';

/// System that manages combat interactions between entities
/// Handles damage calculation, hit detection, and combat effects
///
/// ARCHITECTURE:
/// -------------
/// CombatSystem manages all combat-related interactions between game entities.
/// It integrates with other systems in the following ways:
/// - Processes entities with HealthComponent
/// - Receives collision events from PhysicsSystem for hit detection
/// - Interfaces with AnimationSystem for combat visual effects
/// - Communicates with AudioSystem for combat sounds
///
/// PERFORMANCE CONSIDERATIONS:
/// ---------------------------
/// - Combat calculations are event-based rather than per-frame for efficiency
/// - Uses targeted entity processing to avoid scanning all entities
/// - Combat log size is constrained to prevent memory growth
///
/// CONFIGURATION OPTIONS:
/// ---------------------
/// - Global damage multiplier for difficulty scaling
/// - Combat logging toggle for debugging and analytics
/// - Damage type configurations for different gameplay mechanics
///
/// USAGE EXAMPLES:
/// --------------
/// ```dart
/// // Process damage between entities
/// combatSystem.processDamage(
///   attacker, 
///   target, 
///   10.0, 
///   damageType: 'fire',
/// );
///
/// // Check if an entity is alive
/// bool isAlive = combatSystem.isEntityAlive(entity);
/// ```
class CombatSystem extends BaseSystem {
  CombatSystem();

  // Configuration
  final double _globalDamageMultiplier = 1;

  // Combat logging
  bool _enableCombatLog = false;
  final List<CombatEvent> _combatLog = <CombatEvent>[];
  final int _maxCombatLogEntries = 100;

  // Player reference
  Player? _playerEntity;

  @override
  bool canProcessEntity(Entity entity) {
    // A combat entity should have a health component or be able to deal damage
    return entity.children.whereType<HealthComponent>().isNotEmpty ||
        entity is Player ||
        entity is Enemy;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Combat system mainly responds to events rather than per-frame updates
    // Most combat logic is triggered by collisions or explicit attack commands
  }

  /// Handle a damage event between two entities
  void processDamage(
    Entity source,
    Entity target,
    double baseDamage, {
    String? damageType,
    bool isCritical = false,
  }) {
    // Find health component on target
    final Iterable<HealthComponent> healthComponents =
        target.children.whereType<HealthComponent>();
    if (healthComponents.isEmpty) return;

    final HealthComponent healthComponent = healthComponents.first;

    // Calculate final damage
    double finalDamage = baseDamage * _globalDamageMultiplier;

    // Apply critical multiplier if applicable
    if (isCritical) {
      finalDamage *= 2.0; // Critical hits do double damage by default
    }

    // Apply damage to target
    healthComponent.takeDamage(finalDamage);

    // Log combat event
    if (_enableCombatLog) {
      _logCombatEvent(
        CombatEvent(
          source: source,
          target: target,
          damage: finalDamage,
          damageType: damageType ?? 'normal',
          isCritical: isCritical,
          isKill: healthComponent.isDead,
        ),
      );
    }
  }

  /// Process an attack from an entity in a direction
  void processAttack(
    Entity attacker,
    Vector2 direction,
    double range,
    double damage, {
    String? attackType,
  }) {
    // Find entities within attack range
    final List<Entity> potentialTargets =
        _findEntitiesInRange(attacker, direction, range);

    // Filter targets based on team/faction (no friendly fire)
    final List<Entity> validTargets =
        _filterValidTargets(attacker, potentialTargets);

    // Apply damage to all valid targets
    for (final Entity target in validTargets) {
      processDamage(attacker, target, damage, damageType: attackType);
    }
  }

  /// Find entities within an attack range and direction
  List<Entity> _findEntitiesInRange(
    Entity attacker,
    Vector2 direction,
    double range,
  ) {
    final List<Entity> inRangeEntities = <Entity>[];

    // Calculate attack position (in front of attacker)
    final Vector2 attackerPos = attacker.position.clone();
    final Vector2 attackPos = attackerPos + (direction * range / 2);

    // Check distance to each entity
    for (final Entity entity in entities) {
      if (entity == attacker || !entity.isActive) continue;

      // Check if entity is within range
      final double distance = entity.position.distanceTo(attackPos);
      if (distance <= range / 2) {
        inRangeEntities.add(entity);
      }
    }

    return inRangeEntities;
  }

  /// Filter valid targets for an attacker
  List<Entity> _filterValidTargets(
    Entity attacker,
    List<Entity> potentialTargets,
  ) {
    final List<Entity> validTargets = <Entity>[];

    for (final Entity target in potentialTargets) {
      // Check if valid target based on type
      if (attacker is Player && target is Enemy) {
        // Player can attack enemies
        validTargets.add(target);
      } else if (attacker is Enemy && target is Player) {
        // Enemies can attack player
        validTargets.add(target);
      }
      // Add more cases as needed (PvP, faction checks, etc.)
    }

    return validTargets;
  }

  /// Log a combat event
  void _logCombatEvent(CombatEvent event) {
    _combatLog.add(event);

    // Keep log size under control
    if (_combatLog.length > _maxCombatLogEntries) {
      _combatLog.removeAt(0); // Remove oldest entry
    }
  }

  /// Enable or disable combat logging
  void setCombatLogEnabled(bool enabled) {
    _enableCombatLog = enabled;
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

  /// Clear combat log
  void clearCombatLog() {
    _combatLog.clear();
  }

  // Getters
  double get damageMultiplier => _globalDamageMultiplier;
  List<CombatEvent> get combatLog => List.unmodifiable(_combatLog);
  bool get combatLogEnabled => _enableCombatLog;

  @override
  void initialize() {
    // Initialize combat system
  }

  @override
  void onEntityAdded(Entity entity) {
    // Track player entity for special handling
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
}

/// Class to store combat event data for logging and UI feedback
class CombatEvent {
  CombatEvent({
    required this.source,
    required this.target,
    required this.damage,
    required this.damageType,
    this.isCritical = false,
    this.isKill = false,
  });
  final Entity source;
  final Entity target;
  final double damage;
  final String damageType;
  final bool isCritical;
  final bool isKill;
  final DateTime timestamp = DateTime.now();
}

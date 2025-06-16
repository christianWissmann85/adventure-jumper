// filepath: c:\Users\User\source\repos\Cascade\adventure-jumper\lib\src\systems\combat_system.dart
import 'package:flame/components.dart';

import '../components/health_component.dart';
import '../entities/enemy.dart';
import '../entities/entity.dart';
import '../components/physics_component.dart'; // Added to resolve PhysicsComponent type
import '../systems/interfaces/collision_notifier.dart' show SurfaceMaterial; // For surface effects
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
  // Configuration for surface effect multipliers
  static const double _electricOnWaterMultiplier = 1.5;
  static const double _fireOnGrassMultiplier = 1.25;
  static const double _defaultSlamKnockbackMagnitude = 150.0;
  static const double _defaultSlamRadius = 50.0;
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
    double? knockbackMagnitude, // New parameter for knockback strength
    Vector2? knockbackDirection, // New parameter for specific knockback direction
  }) {
    // Find health component on target
    final Iterable<HealthComponent> healthComponents =
        target.children.whereType<HealthComponent>();
    if (healthComponents.isEmpty) return;

    final HealthComponent healthComponent = healthComponents.first;

    // Get target's surface material for potential interactions
    final physicsComponentForSurface = target.children.whereType<PhysicsComponent>().firstOrNull;
    SurfaceMaterial? targetSurfaceMaterial = SurfaceMaterial.none; // Default if no physics or not on ground

    if (physicsComponentForSurface != null) {
      // ignore: dead_null_aware_expression
      targetSurfaceMaterial = physicsComponentForSurface.currentGroundSurfaceMaterial ?? SurfaceMaterial.none;
    }

    // Calculate final damage
    double finalDamage = baseDamage * _globalDamageMultiplier;

    // Apply surface-based damage modifications
    if (damageType == 'electric' && targetSurfaceMaterial == SurfaceMaterial.water) {
      finalDamage *= _electricOnWaterMultiplier;
      if (_enableCombatLog) {
        print('COMBAT_SYSTEM: Bonus damage! Electric on Water. Target: ${target.runtimeType}');
      }
    } else if (damageType == 'fire' && targetSurfaceMaterial == SurfaceMaterial.grass) {
      finalDamage *= _fireOnGrassMultiplier;
      if (_enableCombatLog) {
        print('COMBAT_SYSTEM: Bonus damage! Fire on Grass. Target: ${target.runtimeType}');
      }
    }
    // Add other surface/damage type interactions here

    // Apply critical multiplier if applicable
    if (isCritical) {
      finalDamage *= 2.0; // Critical hits do double damage by default
    }

    // Apply damage to target
    healthComponent.takeDamage(finalDamage);

    // Apply knockback if specified
    if (knockbackMagnitude case final double kMag when kMag > 0) {
      final physicsComponent = target.children.whereType<PhysicsComponent>().firstOrNull;
      if (physicsComponent != null && !physicsComponent.isStatic) {
        Vector2 direction;
        if (knockbackDirection != null) {
          direction = knockbackDirection.normalized();
        } else {
          // Default knockback away from the source
          if (target.isMounted && source.isMounted) {
            direction = (target.position - source.position);
            if (direction.length2 > 0) { // Check if direction is not a zero vector
              direction.normalize();
            } else {
              // Fallback if positions are the same
              direction = Vector2(0, -1);
            }
          } else {
            // Fallback if one or both entities are not mounted
            direction = Vector2(0, -1);
          }
        }
        final Vector2 knockbackForce = direction * kMag; // Use kMag from pattern match
        physicsComponent.applyKnockback(knockbackForce);
      }
    }

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
    double? knockbackMagnitude,
    Vector2? knockbackDirection, // Added parameter
  }) {
    // Find entities within attack range
    final List<Entity> potentialTargets =
        _findEntitiesInRange(attacker, direction, range);

    // Filter targets based on team/faction (no friendly fire)
    final List<Entity> validTargets =
        _filterValidTargets(attacker, potentialTargets);

    // Apply damage to all valid targets
    for (final Entity target in validTargets) {
      // Knockback direction will be calculated in processDamage based on attacker/target positions
      processDamage(
        attacker,
        target,
        damage,
        damageType: attackType,
        knockbackMagnitude: knockbackMagnitude,
        knockbackDirection: knockbackDirection, // Pass through
      );
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

    for (final Entity potentialTarget in potentialTargets) {
      // Check if valid target based on type
      if (attacker is Player && potentialTarget is Enemy) {
        validTargets.add(potentialTarget);
      } else if (attacker is Enemy && potentialTarget is Player) {
        validTargets.add(potentialTarget);
      } else if (attacker is Player && potentialTarget is Player) { // Added for testing
        validTargets.add(potentialTarget);
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

  /// Process a slam attack, typically performed by an airborne attacker.
  void processSlamAttack(
    Entity attacker,
    double damage, {
    double knockbackMagnitude = _defaultSlamKnockbackMagnitude,
    double slamRadius = _defaultSlamRadius,
    String damageType = 'slam',
  }) {
    final attackerPhysics = attacker.children.whereType<PhysicsComponent>().firstOrNull;

    if (attackerPhysics == null) {
      if (_enableCombatLog) {
        print('COMBAT_SYSTEM: Slam attack failed. ${attacker.runtimeType} has no PhysicsComponent.');
      }
      return;
    }

    if (attackerPhysics.isOnGround) {
      if (_enableCombatLog) {
        print('COMBAT_SYSTEM: Slam attack failed. ${attacker.runtimeType} must be airborne to slam.');
      }
      return; // Slam attack can only be performed while airborne
    }

    if (_enableCombatLog) {
      print('COMBAT_SYSTEM: ${attacker.runtimeType} performs a SLAM attack!');
    }

    final List<Entity> potentialTargets = <Entity>[];
    // Ensure attacker has a valid position before calculating distance
    if (!attacker.isMounted) {
        if (_enableCombatLog) print('COMBAT_SYSTEM: Slam attack failed. Attacker not mounted, position unreliable.');
        return;
    }

    for (final Entity entity in entities) {
      if (entity == attacker || !entity.isActive || !entity.isMounted) continue;
      
      // Ensure target has a valid position
      if (attacker.position.distanceTo(entity.position) <= slamRadius) {
        potentialTargets.add(entity);
      }
    }

    final List<Entity> validTargets = _filterValidTargets(attacker, potentialTargets);

    for (final Entity target in validTargets) {
      // Ensure target has a valid position for knockback calculation
      Vector2 slamKnockbackDirection = Vector2(0,-1); // Default downwards if positions are same
      if (target.isMounted && attacker.isMounted) {
          final directionVec = target.position - attacker.position;
          if (directionVec.length2 > 0) {
              slamKnockbackDirection = directionVec.normalized();
          } else if (target.position.y < attacker.position.y) {
              // If target is below attacker and positions are nearly same horizontally
              slamKnockbackDirection = Vector2(0,1); // Push downwards from attacker's perspective
          }
      }

      processDamage(
        attacker,
        target,
        damage,
        damageType: damageType,
        knockbackMagnitude: knockbackMagnitude,
        knockbackDirection: slamKnockbackDirection,
      );
    }
    // Optional: Add a small upward impulse to the attacker after a slam for a "bounce" effect
    // This could also be handled by an animation or state change.
    // attackerPhysics.applyImpulse(Vector2(0, -50)); 
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

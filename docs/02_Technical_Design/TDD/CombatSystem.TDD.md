# Combat System - Technical Design Document

## 1. Overview

Defines the implementation of the combat system including attack mechanics, hit detection, damage calculations, status effects, and enemy interaction patterns.

*For game design specifications, see [Combat System Design](../../01_Game_Design/Mechanics/CombatSystem_Design.md).*

### Purpose
- Implement responsive and satisfying combat mechanics
- Handle hit detection and damage calculations
- Manage combat state transitions and timing
- Integrate melee and ranged attack systems
- Support parrying, dodging, and defensive mechanics

### Scope
- Attack execution and timing
- Hit detection algorithms
- Damage calculation and application
- Status effect system
- Combat animation integration
- Enemy combat interaction

## 2. Class Design

### Core Combat Classes

```dart
// Main combat system manager
class CombatSystem extends BaseSystem {
  // Attack registration and processing
  // Hit detection coordination
  // Damage application
  // Combat state management
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has health component or is combat-capable
    return entity.children.whereType<HealthComponent>().isNotEmpty ||
           entity is Player ||
           entity is Enemy;
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Combat is mainly event-driven rather than per-frame processing
    // Most combat logic is triggered by collisions or explicit attack commands
  }
}

// Attack definition and execution
class AttackController {
  // Attack data and properties
  // Execution timing
  // Hit box management
  // Animation synchronization
}

// Hit detection and collision
class HitDetection {
  // Collision shape management
  // Hit registration
  // Multi-hit prevention
  // Damage zone calculation
}
```

### Key Responsibilities
- **CombatSystem**: Orchestrates all combat interactions and state
- **AttackController**: Manages individual attack execution and properties
- **HitDetection**: Handles precise collision detection for combat

## 3. Data Structures

### Attack Data
```dart
class AttackData {
  final String id;
  final AttackType type;  // Melee, Ranged, AetherAbility
  final double baseDamage;
  final double knockback;
  final List<StatusEffect> statusEffects;
  final double staminaCost;
  final double aetherCost;
  final double cooldown;
  final HitboxData hitbox;
  final AnimationData animation;
}

enum AttackType {
  light,
  heavy,
  special,
  ranged,
  aether
}

class HitboxData {
  final Vector2 size;
  final Vector2 offset;
  final HitboxShape shape;
  final List<HitboxFrame> frames;  // For multi-frame hitboxes
}

class HitboxFrame {
  final int frameStart;
  final int frameDuration;
  final Vector2 offset;  // Relative to base offset
  final Vector2 size;    // Can be different per frame
}
```

### Damage System
```dart
class DamageInfo {
  final double rawDamage;
  final DamageType type;
  final Entity source;
  final List<StatusEffect> statusEffects;
  final Vector2 direction;  // For knockback
  final double knockbackForce;
}

enum DamageType {
  physical,
  aether,
  fire,
  ice,
  shock,
  void
}

class DamageResult {
  final double actualDamage;
  final bool wasBlocked;
  final bool wasCritical;
  final List<StatusEffect> appliedEffects;
}
```

## 4. Algorithms

### Hit Detection

The combat system uses a multi-phase approach to hit detection:

1. **Broad Phase**
   - Spatial partitioning using quadtree
   - Filter potential collisions by attack range

2. **Narrow Phase**
   - Precise hitbox collision testing
   - Frame-by-frame active hitbox checks

```dart
bool detectHit(Entity attacker, Entity target, AttackData attack, int currentFrame) {
  // Skip if target is invulnerable or attack is in cooldown
  if (target.hasComponent<InvulnerableComponent>() || !isHitboxActiveOnFrame(attack, currentFrame)) {
    return false;
  }
  
  // Get current hitbox data
  var hitbox = getActiveHitboxForFrame(attack, currentFrame);
  
  // Transform hitbox by attacker's position and facing direction
  var worldHitbox = transformHitboxToWorldSpace(hitbox, attacker);
  
  // Check collision with target's hurtbox
  return intersects(worldHitbox, target.getComponent<HurtboxComponent>().shape);
}
```

### Damage Calculation

```dart
DamageResult calculateDamage(Entity target, DamageInfo info) {
  // Get target's defense stats
  var defense = target.getComponent<DefenseComponent>();
  
  // Base damage reduction
  double reduction = calculateReduction(defense.value, info.type);
  double actualDamage = max(info.rawDamage * (1 - reduction), 0);
  
  // Critical hit
  bool critical = false;
  if (Random().nextDouble() < info.source.getComponent<AttackComponent>().criticalChance) {
    critical = true;
    actualDamage *= 1.5;  // Critical multiplier
  }
  
  // Check for block
  bool blocked = false;
  if (target.hasComponent<BlockComponent>() && isAttackBlockable(info, target)) {
    blocked = true;
    actualDamage *= 0.2;  // Block reduces damage by 80%
  }
  
  // Apply damage resistance from effects
  for (var effect in target.getComponent<StatusEffectComponent>().activeEffects) {
    if (effect is DamageResistanceEffect && effect.damageType == info.type) {
      actualDamage *= (1 - effect.resistanceAmount);
    }
  }
  
  // Calculate which effects are successfully applied
  var appliedEffects = calculateEffectApplication(target, info.statusEffects);
  
  return DamageResult(
    actualDamage: actualDamage,
    wasCritical: critical,
    wasBlocked: blocked,
    appliedEffects: appliedEffects
  );
}
```

## 5. API/Interfaces

### Combat System Interface

```dart
abstract class CombatInterface {
  // Attack execution
  Future<void> executeAttack(Entity source, String attackId);
  
  // Damage application
  DamageResult applyDamage(Entity target, DamageInfo damage);
  
  // Status effect management
  void applyStatusEffect(Entity target, StatusEffect effect);
  void removeStatusEffect(Entity target, String effectId);
  
  // Combat state queries
  bool isEntityAttacking(Entity entity);
  bool canEntityAttack(Entity entity);
  bool isEntityInvulnerable(Entity entity);
}
```

## 6. Dependencies

This system depends on:
- **Physics System** - For collision detection fundamentals
- **Animation System** - To sync attacks with visual representation
- **Input System** - For player attack commands
- **Entity System** - To access component data
- **Aether System** - For special attacks and ability costs

## 7. File Structure

```
lib/
  game/
    combat/
      combat_system.dart          // Main system implementation
      attack_controller.dart      // Attack execution logic
      hit_detection.dart          // Hit detection algorithms
      damage_calculator.dart      // Damage calculation
      status_effect/
        status_effect.dart        // Base class for effects
        damage_over_time.dart     // DoT implementation
        buff_debuff.dart          // Stat modification effects
      components/
        attack_component.dart     // Attack properties
        defense_component.dart    // Defense properties
        hitbox_component.dart     // Hitbox definition
        hurtbox_component.dart    // Vulnerability areas
      data/
        attack_data.dart          // Attack definitions
        damage_types.dart         // Damage type enums
```

## 8. Performance Considerations

### Optimization Techniques
- **Spatial Partitioning** - Quadtrees for broad-phase collision detection
- **Hitbox Pooling** - Reuse hitbox objects to reduce GC pressure
- **Prioritized Processing** - Focus hit detection on relevant entities only
- **Inactive Entity Skipping** - Don't process entities outside active range

### Memory Usage
- Reuse common hitbox shapes
- Pool damage and hit result objects
- Limit max simultaneous attacks processed

## 9. Testing Strategy

### Unit Tests
- Test damage calculation with various defense values
- Verify hitbox collision in different orientations
- Validate status effect application rules

### Integration Tests
- Test combat flow between different entity types
- Verify audio and visual feedback synchronization
- Test performance under many simultaneous combat interactions

### Play Testing
- Measure attack responsiveness (frames between input and effect)
- Evaluate hit detection accuracy
- Test edge cases like simultaneous attacks

## Related Design Documents

- See [Combat System Design](../../01_Game_Design/Mechanics/CombatSystem_Design.md) for gameplay design requirements
- See [Animation System TDD](AnimationSystem.TDD.md) for animation integration details

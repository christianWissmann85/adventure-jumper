import 'package:flame/components.dart';
import 'entity.dart';
import '../components/ai_component.dart';
import '../components/health_component.dart';
import '../components/physics_component.dart';

/// Base class for enemy entities
/// Handles common enemy behaviors, AI, and combat interactions
abstract class Enemy extends Entity {
  Enemy({
    required super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
    String? type,
    double? attackDamage,
    double? attackRange,
    double? detectionRange,
    bool? isBoss,
  }) : super(
          type: type ?? 'enemy',
        ) {
    if (attackDamage != null) _attackDamage = attackDamage;
    if (attackRange != null) _attackRange = attackRange;
    if (detectionRange != null) _detectionRange = detectionRange;
    if (isBoss != null) _isBoss = isBoss;
  }
  // Enemy-specific components
  late HealthComponent health;
  late AIComponent ai;

  // Enemy properties
  double _attackDamage = 10;
  double _attackRange = 50;
  double _detectionRange = 200;
  bool _isBoss = false;

  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

    // Add enemy-specific components
    health = HealthComponent();
    ai = AIComponent();
    physics = PhysicsComponent();

    add(health);
    add(ai);
    add(physics!);

    // Initialize enemy-specific properties
    await setupEnemy();
  }

  @override
  void updateEntity(double dt) {
    super.updateEntity(dt);

    // Enemy-specific update logic
    updateEnemy(dt);
  }

  /// Custom enemy setup (to be implemented by subclasses)
  Future<void> setupEnemy() async {
    // Override in subclasses
  }

  /// Custom enemy update logic (to be implemented by subclasses)
  void updateEnemy(double dt) {
    // Override in subclasses
  }

  /// Attack logic (to be implemented by subclasses)
  void attack() {
    // Override in subclasses
  }

  /// Take damage when hit
  void takeDamage(double amount) {
    health.takeDamage(amount);
    // Implementation needed: Visual feedback, sound effects, etc.

    if (health.isDead) {
      die();
    }
  }

  /// Handle enemy death
  void die() {
    // Implementation needed: Death animation, sound effects, etc.
    removeFromParent();
  }

  /// Check if player is within detection range
  bool isPlayerDetected(Vector2 playerPosition) {
    final double distance = position.distanceTo(playerPosition);
    return distance <= _detectionRange;
  }

  /// Check if player is within attack range
  bool canAttackPlayer(Vector2 playerPosition) {
    final double distance = position.distanceTo(playerPosition);
    return distance <= _attackRange;
  }

  // Getters
  double get attackDamage => _attackDamage;
  double get attackRange => _attackRange;
  double get detectionRange => _detectionRange;
  bool get isBoss => _isBoss;
  bool get isDead => health.isDead;
}

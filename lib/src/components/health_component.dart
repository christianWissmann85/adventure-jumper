import 'package:flame/components.dart';

/// Component that handles health and damage for entities
/// Manages health points, damage effects, and death handling
class HealthComponent extends Component {
  HealthComponent({
    double? maxHealth,
    double? currentHealth,
    double? regenerationRate,
    bool? isInvulnerable,
    double? invulnerabilityTime,
  }) {
    if (maxHealth != null) _maxHealth = maxHealth;
    if (currentHealth != null) _currentHealth = currentHealth;
    if (regenerationRate != null) this.regenerationRate = regenerationRate;
    if (isInvulnerable != null) _isInvulnerable = isInvulnerable;
    if (invulnerabilityTime != null) _invulnerabilityTime = invulnerabilityTime;
  }

  // Health properties
  double _maxHealth = 100;
  double _currentHealth = 100;
  double regenerationRate = 0;
  bool _isDead = false;
  // Invulnerability (for damage immunity frames)
  bool _isInvulnerable = false;
  double _invulnerabilityTime = 1;
  double _invulnerabilityTimer =
      0; // Events - explicit void return type to avoid inference issues
  void Function(double damage)? onTakeDamage;
  void Function(double amount)? onHeal;
  void Function()? onDeath;

  @override
  void onMount() {
    super.onMount();

    // Initialize health to max if not set
    if (_currentHealth <= 0) {
      _currentHealth = _maxHealth;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update invulnerability timer
    if (_isInvulnerable) {
      _invulnerabilityTimer -= dt;

      if (_invulnerabilityTimer <= 0) {
        _isInvulnerable = false;
      }
    }

    // Apply health regeneration
    if (regenerationRate > 0 &&
        _currentHealth > 0 &&
        _currentHealth < _maxHealth) {
      heal(regenerationRate * dt);
    }
  }

  /// Take damage and reduce health
  void takeDamage(double amount) {
    if (_isInvulnerable || _isDead || amount <= 0) return;

    // Apply damage
    _currentHealth -= amount;

    // Clamp health value
    _currentHealth = _currentHealth.clamp(0, _maxHealth);

    // Trigger damage event
    if (onTakeDamage != null) {
      onTakeDamage!(amount);
    }

    // Start invulnerability period
    _isInvulnerable = true;
    _invulnerabilityTimer = _invulnerabilityTime;

    // Check for death
    if (_currentHealth <= 0) {
      _die();
    }
  }

  /// Heal and increase health
  void heal(double amount) {
    if (_isDead || amount <= 0) return;

    // Apply healing
    _currentHealth += amount;

    // Clamp health value
    _currentHealth = _currentHealth.clamp(0, _maxHealth);

    // Trigger heal event
    if (onHeal != null) {
      onHeal!(amount);
    }
  }

  /// Set health to a specific value
  void setHealth(double value) {
    _currentHealth = value.clamp(0, _maxHealth);

    // Check for death
    if (_currentHealth <= 0) {
      _die();
    }
  }

  /// Set max health and optionally scale current health
  void setMaxHealth(double value, {bool scaleCurrentHealth = false}) {
    final double healthPct = _currentHealth / _maxHealth;
    _maxHealth = value;

    if (scaleCurrentHealth) {
      _currentHealth = _maxHealth * healthPct;
    } else {
      _currentHealth = _currentHealth.clamp(0, _maxHealth);
    }
  }

  /// Handle death
  void _die() {
    if (_isDead) return;

    _isDead = true;
    _currentHealth = 0;

    // Trigger death event
    if (onDeath != null) {
      onDeath!();
    }
  }

  /// Revive entity
  void revive({double? healthPercentage}) {
    if (!_isDead) return;

    _isDead = false;

    // Set health to percentage of max or full
    double newHealth = _maxHealth;
    if (healthPercentage != null) {
      newHealth = _maxHealth * (healthPercentage / 100.0);
    }

    _currentHealth = newHealth.clamp(1, _maxHealth);
  }

  /// Make entity temporarily invulnerable
  void makeInvulnerable(double duration) {
    _isInvulnerable = true;
    _invulnerabilityTimer = duration;
  }

  // Getters and setters
  double get maxHealth => _maxHealth;
  double get currentHealth => _currentHealth;
  double get healthPercentage => _currentHealth / _maxHealth * 100;
  bool get isDead => _isDead;
  bool get isInvulnerable => _isInvulnerable;
}

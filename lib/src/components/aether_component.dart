import 'package:flame/components.dart';

/// Component that handles Aether energy and abilities
/// Manages Aether reserves, ability usage, cooldowns, and effects
class AetherComponent extends Component {
  AetherComponent({
    double? maxAether,
    double? currentAether,
    double? aetherRegenRate,
    bool? isActive,
    List<String>? unlockedAbilities,
  }) {
    if (maxAether != null) _maxAether = maxAether;
    if (currentAether != null) _currentAether = currentAether;
    if (aetherRegenRate != null) _aetherRegenRate = aetherRegenRate;
    if (isActive != null) _isActive = isActive;
    if (unlockedAbilities != null) _unlockedAbilities = unlockedAbilities;
  }

  // Aether properties
  double _maxAether = 100;
  double _currentAether = 100;
  double _aetherRegenRate = 5; // Aether points per second
  bool _isActive = true;

  // Ability states
  List<String> _unlockedAbilities = <String>[];
  final Map<String, bool> _abilityActive = <String, bool>{};
  final Map<String, double> _abilityCooldowns = <String, double>{};
  final Map<String, double> _abilityCooldownTimers = <String, double>{};
  final Map<String, double> _abilityDurations = <String, double>{};
  final Map<String, double> _abilityDurationTimers = <String, double>{};
  final Map<String, double> _abilityCosts = <String, double>{};

  // Default ability configuration
  final Map<String, double> _defaultAbilityCosts = <String, double>{
    'dash': 20.0,
    'double_jump': 15.0,
    'wall_cling': 5.0,
    'aether_blast': 35.0,
    'aether_shield': 40.0,
  };

  final Map<String, double> _defaultAbilityCooldowns = <String, double>{
    'dash': 3.0,
    'double_jump': 1.0,
    'wall_cling': 0.5,
    'aether_blast': 5.0,
    'aether_shield': 8.0,
  };

  final Map<String, double> _defaultAbilityDurations = <String, double>{
    'dash': 0.3,
    'double_jump': 0.1,
    'wall_cling': 2.0,
    'aether_blast': 0.5,
    'aether_shield': 4.0,
  };

  @override
  void onMount() {
    super.onMount();

    // Initialize with default values if not set
    if (_currentAether <= 0) {
      _currentAether = _maxAether;
    }

    // Initialize all ability states
    for (final String ability in _defaultAbilityCosts.keys) {
      _abilityActive[ability] = false;
      _abilityCooldownTimers[ability] = 0;
      _abilityDurationTimers[ability] = 0;
      _abilityCosts[ability] = _defaultAbilityCosts[ability] ?? 0;
      _abilityCooldowns[ability] = _defaultAbilityCooldowns[ability] ?? 0;
      _abilityDurations[ability] = _defaultAbilityDurations[ability] ?? 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    // Regenerate Aether over time
    if (_currentAether < _maxAether) {
      _currentAether += _aetherRegenRate * dt;
      if (_currentAether > _maxAether) {
        _currentAether = _maxAether;
      }
    }

    // Update ability cooldowns and durations
    _updateAbilityTimers(dt);
  }

  /// Update all ability timers
  void _updateAbilityTimers(double dt) {
    // Update cooldown timers
    for (final String ability in _abilityCooldownTimers.keys) {
      if (_abilityCooldownTimers[ability]! > 0) {
        _abilityCooldownTimers[ability] = _abilityCooldownTimers[ability]! - dt;
        if (_abilityCooldownTimers[ability]! <= 0) {
          _abilityCooldownTimers[ability] = 0;
        }
      }
    }

    // Update duration timers for active abilities
    for (final String ability in _abilityActive.keys) {
      if (_abilityActive[ability] == true) {
        _abilityDurationTimers[ability] = _abilityDurationTimers[ability]! - dt;
        if (_abilityDurationTimers[ability]! <= 0) {
          // Ability duration expired
          _abilityActive[ability] = false;
          _abilityDurationTimers[ability] = 0;
          _onAbilityEnd(ability);
        }
      }
    }
  }

  /// Activate an ability if available
  bool activateAbility(String abilityName) {
    // Check if ability is unlocked
    if (!hasAbility(abilityName)) {
      return false;
    }

    // Check if ability is on cooldown
    if (isAbilityOnCooldown(abilityName)) {
      return false;
    }

    // Check if we have enough Aether
    final double cost = _abilityCosts[abilityName] ?? 0;
    if (_currentAether < cost) {
      return false;
    }

    // Consume Aether
    _currentAether -= cost;

    // Activate ability
    _abilityActive[abilityName] = true;
    _abilityDurationTimers[abilityName] = _abilityDurations[abilityName] ?? 0;

    // Start cooldown
    _abilityCooldownTimers[abilityName] = _abilityCooldowns[abilityName] ?? 0;

    // Trigger ability start effect
    _onAbilityStart(abilityName);

    return true;
  }

  /// Handle ability activation
  void _onAbilityStart(String abilityName) {
    // Override in subclasses or set callbacks
  }

  /// Handle ability deactivation
  void _onAbilityEnd(String abilityName) {
    // Override in subclasses or set callbacks
  }

  /// Unlock a new ability
  void unlockAbility(String abilityName) {
    if (!_unlockedAbilities.contains(abilityName)) {
      _unlockedAbilities.add(abilityName);
    }
  }

  /// Set the cost for an ability
  void setAbilityCost(String abilityName, double cost) {
    _abilityCosts[abilityName] = cost;
  }

  /// Set the cooldown for an ability
  void setAbilityCooldown(String abilityName, double cooldown) {
    _abilityCooldowns[abilityName] = cooldown;
  }

  /// Set the duration for an ability
  void setAbilityDuration(String abilityName, double duration) {
    _abilityDurations[abilityName] = duration;
  }

  /// Add Aether energy
  void addAether(double amount) {
    if (amount <= 0) return;

    _currentAether += amount;
    if (_currentAether > _maxAether) {
      _currentAether = _maxAether;
    }
  }

  /// Consume Aether energy
  bool consumeAether(double amount) {
    if (amount <= 0) return true;

    if (_currentAether >= amount) {
      _currentAether -= amount;
      return true;
    }

    return false;
  }

  /// Set maximum Aether capacity
  void setMaxAether(double max, {bool scaleCurrentAether = false}) {
    final double percentage = _currentAether / _maxAether;
    _maxAether = max;

    if (scaleCurrentAether) {
      _currentAether = _maxAether * percentage;
    } else {
      if (_currentAether > _maxAether) {
        _currentAether = _maxAether;
      }
    }
  }

  /// Check if an ability is unlocked
  bool hasAbility(String abilityName) {
    return _unlockedAbilities.contains(abilityName);
  }

  /// Check if an ability is currently active
  bool isAbilityActive(String abilityName) {
    return _abilityActive[abilityName] ?? false;
  }

  /// Check if an ability is on cooldown
  bool isAbilityOnCooldown(String abilityName) {
    return (_abilityCooldownTimers[abilityName] ?? 0) > 0;
  }

  /// Get ability cooldown percentage remaining (0.0-1.0)
  double getAbilityCooldownPercent(String abilityName) {
    final double maxCooldown = _abilityCooldowns[abilityName] ?? 1;
    final double currentCooldown = _abilityCooldownTimers[abilityName] ?? 0;

    if (maxCooldown <= 0) return 0;
    return currentCooldown / maxCooldown;
  }

  /// Get ability duration percentage remaining (0.0-1.0)
  double getAbilityDurationPercent(String abilityName) {
    final double maxDuration = _abilityDurations[abilityName] ?? 1;
    final double currentDuration = _abilityDurationTimers[abilityName] ?? 0;

    if (maxDuration <= 0) return 0;
    return currentDuration / maxDuration;
  }

  // Getters
  double get maxAether => _maxAether;
  double get currentAether => _currentAether;
  double get aetherPercentage => _currentAether / _maxAether * 100;
  List<String> get unlockedAbilities => List<String>.unmodifiable(_unlockedAbilities);
  Map<String, bool> get abilityStates => Map<String, bool>.unmodifiable(_abilityActive);
}

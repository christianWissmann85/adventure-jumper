import 'package:flame/components.dart';

import '../events/player_events.dart';

/// Player statistics and progression
/// Handles health, energy, Aether resources, and progression metrics
class PlayerStats extends Component {
  // Basic stats with validation
  double _maxHealth = 100;
  double _currentHealth = 100;
  double _maxEnergy = 100;
  double _currentEnergy = 100;

  // Aether resource tracking with current/maximum values
  int _maxAether = 100;
  int _currentAether = 100;
  int _aetherShards =
      0; // Collectible Aether shards (different from current Aether)

  // Progression stats
  int _level = 1;
  int _experience = 0;
  int _experienceToNextLevel = 100;

  // Ability unlocks with proper tracking
  bool _doubleJumpUnlocked = false;
  bool _dashUnlocked = false;
  bool _wallJumpUnlocked = false;

  // Event system reference
  final PlayerEventBus _eventBus = PlayerEventBus.instance;
  @override
  Future<void> onLoad() async {
    // Initialize default values and validate bounds
    _validateAndClampStats();

    // Load saved player stats if available (placeholder for future save system)
    // TODO: Implement save/load system integration
  }

  /// Handle taking damage with event system integration
  void takeDamage(double amount) {
    if (amount < 0) return; // Prevent negative damage

    final double oldHealth = _currentHealth;
    _currentHealth = (_currentHealth - amount).clamp(0, _maxHealth);

    // Fire health changed event
    _fireHealthChangedEvent(oldHealth, _currentHealth, -amount, 'damage');

    // Fire general stat changed event
    _fireStatChangedEvent(
      'health',
      oldHealth,
      _currentHealth,
      _maxHealth,
      'damage',
    );
  }

  /// Handle healing with validation and events
  void heal(double amount) {
    if (amount < 0) return; // Prevent negative healing

    final double oldHealth = _currentHealth;
    _currentHealth = (_currentHealth + amount).clamp(0, _maxHealth);

    // Fire health changed event
    _fireHealthChangedEvent(oldHealth, _currentHealth, amount, 'heal');

    // Fire general stat changed event
    _fireStatChangedEvent(
      'health',
      oldHealth,
      _currentHealth,
      _maxHealth,
      'heal',
    );
  }

  /// Use energy for abilities with proper validation
  bool useEnergy(double amount) {
    if (amount < 0 || _currentEnergy < amount) return false;

    final double oldEnergy = _currentEnergy;
    _currentEnergy = (_currentEnergy - amount).clamp(0, _maxEnergy);

    // Fire energy changed event
    _fireEnergyChangedEvent(oldEnergy, _currentEnergy, -amount, 'ability_use');

    // Fire general stat changed event
    _fireStatChangedEvent(
      'energy',
      oldEnergy,
      _currentEnergy,
      _maxEnergy,
      'ability_use',
    );

    return true;
  }

  /// Restore energy with validation and events
  void restoreEnergy(double amount) {
    if (amount < 0) return; // Prevent negative restoration

    final double oldEnergy = _currentEnergy;
    _currentEnergy = (_currentEnergy + amount).clamp(0, _maxEnergy);

    // Fire energy changed event
    _fireEnergyChangedEvent(oldEnergy, _currentEnergy, amount, 'restoration');

    // Fire general stat changed event
    _fireStatChangedEvent(
      'energy',
      oldEnergy,
      _currentEnergy,
      _maxEnergy,
      'restoration',
    );
  }

  /// Use Aether for abilities with proper validation
  bool useAether(int amount) {
    if (amount < 0 || _currentAether < amount) return false;

    final int oldAether = _currentAether;
    _currentAether = (_currentAether - amount).clamp(0, _maxAether);

    // Fire Aether changed event
    _fireAetherChangedEvent(oldAether, _currentAether, -amount, 'ability_use');

    return true;
  }

  /// Restore Aether with validation and events
  void restoreAether(int amount) {
    if (amount < 0) return; // Prevent negative restoration

    final int oldAether = _currentAether;
    _currentAether = (_currentAether + amount).clamp(0, _maxAether);

    // Fire Aether changed event
    _fireAetherChangedEvent(oldAether, _currentAether, amount, 'restoration');
  }

  /// Collect Aether shards with validation and ability unlock checks
  void collectAetherShard(int amount) {
    if (amount < 0) return; // Prevent negative collection

    _aetherShards += amount;

    // Also add to current Aether (shards can be converted to usable Aether)
    final int oldAether = _currentAether;
    _currentAether = (_currentAether + amount).clamp(0, _maxAether);

    // Fire Aether changed event
    _fireAetherChangedEvent(oldAether, _currentAether, amount, 'collect_shard');

    // Check for ability unlocks based on total shards collected
    _checkAbilityUnlocks();
  }

  /// Gain experience points with level up handling
  void gainExperience(int amount) {
    if (amount < 0) return; // Prevent negative experience

    final int oldExperience = _experience;
    _experience += amount;

    // Fire experience gained event
    _fireExperienceGainedEvent(oldExperience, _experience, amount);

    // Check for level ups
    while (_experience >= _experienceToNextLevel) {
      levelUp();
    }
  }

  /// Level up character with stat increases and events
  void levelUp() {
    final int oldLevel = _level;
    _level += 1;
    _experience -= _experienceToNextLevel;
    _experienceToNextLevel = (_experienceToNextLevel * 1.2).toInt();

    // Calculate stat increases
    const double healthIncrease = 10;
    const double energyIncrease = 5;
    const int aetherIncrease = 5;

    // Increase stats on level up
    _maxHealth += healthIncrease;
    _currentHealth = _maxHealth; // Full heal on level up
    _maxEnergy += energyIncrease;
    _currentEnergy = _maxEnergy; // Full energy on level up
    _maxAether += aetherIncrease;
    _currentAether = _maxAether; // Full Aether on level up

    // Fire level up event
    _fireLevelUpEvent(oldLevel, _level, healthIncrease, energyIncrease);

    // Check for ability unlocks
    _checkAbilityUnlocks();
  }

  /// Set maximum health with validation
  void setMaxHealth(double maxHealth) {
    if (maxHealth < 1) return; // Minimum health of 1

    final double percentage = _currentHealth / _maxHealth;
    _maxHealth = maxHealth;
    _currentHealth = (_maxHealth * percentage).clamp(0, _maxHealth);
  }

  /// Set maximum energy with validation
  void setMaxEnergy(double maxEnergy) {
    if (maxEnergy < 1) return; // Minimum energy of 1

    final double percentage = _currentEnergy / _maxEnergy;
    _maxEnergy = maxEnergy;
    _currentEnergy = (_maxEnergy * percentage).clamp(0, _maxEnergy);
  }

  /// Set maximum Aether with validation
  void setMaxAether(int maxAether) {
    if (maxAether < 1) return; // Minimum Aether of 1

    final double percentage = _currentAether / _maxAether;
    _maxAether = maxAether;
    _currentAether = (_maxAether * percentage).clamp(0, _maxAether).toInt();
  }

  /// Check and unlock abilities based on progress
  void _checkAbilityUnlocks() {
    // Unlock abilities based on level and Aether shards collected
    if (_level >= 2 && _aetherShards >= 10 && !_doubleJumpUnlocked) {
      _doubleJumpUnlocked = true;
      // TODO: Fire ability unlock event when implemented
    }

    if (_level >= 3 && _aetherShards >= 25 && !_dashUnlocked) {
      _dashUnlocked = true;
      // TODO: Fire ability unlock event when implemented
    }

    if (_level >= 5 && _aetherShards >= 50 && !_wallJumpUnlocked) {
      _wallJumpUnlocked = true;
      // TODO: Fire ability unlock event when implemented
    }
  }

  /// Validate and clamp all stats to proper bounds
  void _validateAndClampStats() {
    // Ensure current values don't exceed maximums
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
    _currentEnergy = _currentEnergy.clamp(0, _maxEnergy);
    _currentAether = _currentAether.clamp(0, _maxAether);

    // Ensure minimums
    _maxHealth = _maxHealth.clamp(1, double.infinity);
    _maxEnergy = _maxEnergy.clamp(1, double.infinity);
    _maxAether = _maxAether.clamp(1, 999999); // Reasonable max for int

    // Ensure non-negative values
    _aetherShards = _aetherShards.clamp(0, 999999);
    _level = _level.clamp(1, 100); // Level cap
    _experience = _experience.clamp(0, 999999999);
    _experienceToNextLevel = _experienceToNextLevel.clamp(1, 999999999);
  }

  /// Fire health changed event
  void _fireHealthChangedEvent(
    double oldHealth,
    double newHealth,
    double changeAmount,
    String reason,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerHealthChangedEvent(
      timestamp: timestamp,
      oldHealth: oldHealth,
      newHealth: newHealth,
      maxHealth: _maxHealth,
      changeAmount: changeAmount,
      changeReason: reason,
    );
    _eventBus.fireEvent(event);
  }

  /// Fire energy changed event
  void _fireEnergyChangedEvent(
    double oldEnergy,
    double newEnergy,
    double changeAmount,
    String reason,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerEnergyChangedEvent(
      timestamp: timestamp,
      oldEnergy: oldEnergy,
      newEnergy: newEnergy,
      maxEnergy: _maxEnergy,
      changeAmount: changeAmount,
      changeReason: reason,
    );
    _eventBus.fireEvent(event);
  }

  /// Fire Aether changed event
  void _fireAetherChangedEvent(
    int oldAether,
    int newAether,
    int changeAmount,
    String reason,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerAetherChangedEvent(
      timestamp: timestamp,
      oldAmount: oldAether,
      newAmount: newAether,
      maxAmount: _maxAether,
      changeAmount: changeAmount,
      changeReason: reason,
    );
    _eventBus.fireEvent(event);
  }

  /// Fire general stat changed event
  void _fireStatChangedEvent(
    String statType,
    double oldValue,
    double newValue,
    double maxValue,
    String reason,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerStatChangedEvent(
      timestamp: timestamp,
      statType: statType,
      oldValue: oldValue,
      newValue: newValue,
      maxValue: maxValue,
      changeReason: reason,
    );
    _eventBus.fireEvent(event);
  }

  /// Fire level up event
  void _fireLevelUpEvent(
    int oldLevel,
    int newLevel,
    double healthIncrease,
    double energyIncrease,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerLevelUpEvent(
      timestamp: timestamp,
      oldLevel: oldLevel,
      newLevel: newLevel,
      healthIncrease: healthIncrease,
      energyIncrease: energyIncrease,
    );
    _eventBus.fireEvent(event);
  }

  /// Fire experience gained event
  void _fireExperienceGainedEvent(
    int oldExperience,
    int newExperience,
    int experienceGained,
  ) {
    final double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
    final event = PlayerExperienceGainedEvent(
      timestamp: timestamp,
      oldExperience: oldExperience,
      newExperience: newExperience,
      experienceGained: experienceGained,
      experienceToNextLevel: _experienceToNextLevel,
    );
    _eventBus.fireEvent(event);
  }

  // Getters for basic stats
  double get currentHealth => _currentHealth;
  double get maxHealth => _maxHealth;
  double get currentEnergy => _currentEnergy;
  double get maxEnergy => _maxEnergy;
  double get healthPercentage => _currentHealth / _maxHealth;
  double get energyPercentage => _currentEnergy / _maxEnergy;
  bool get isAlive => _currentHealth > 0;

  // Getters for Aether resource system
  int get currentAether => _currentAether;
  int get maxAether => _maxAether;
  int get aetherShards => _aetherShards;
  double get aetherPercentage => _currentAether / _maxAether;
  bool get hasAether => _currentAether > 0;
  bool get isAetherFull => _currentAether >= _maxAether;

  // Getters for progression
  int get level => _level;
  int get experience => _experience;
  int get experienceToNextLevel => _experienceToNextLevel;
  double get experienceProgress => _experience / _experienceToNextLevel;

  // Ability unlock getters
  bool get canDoubleJump => _doubleJumpUnlocked;
  bool get canDash => _dashUnlocked;
  bool get canWallJump => _wallJumpUnlocked;

  // Utility methods for stat checking
  bool canUseAether(int amount) => _currentAether >= amount;
  bool canUseEnergy(double amount) => _currentEnergy >= amount;
  bool isHealthLow() => _currentHealth / _maxHealth < 0.25;
  bool isEnergyLow() => _currentEnergy / _maxEnergy < 0.25;
  bool isAetherLow() => _currentAether / _maxAether < 0.25;
}

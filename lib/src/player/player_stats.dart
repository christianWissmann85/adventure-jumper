import 'package:flame/components.dart';

/// Player statistics and progression
/// Handles health, energy, Aether resources, and progression metrics
class PlayerStats extends Component {
  // Basic stats
  double _maxHealth = 100;
  double _currentHealth = 100;
  double _maxEnergy = 100;
  double _currentEnergy = 100;

  // Resource tracking
  int _aetherShards = 0;

  // Progression stats
  int _level = 1;
  int _experience = 0;
  int _experienceToNextLevel = 100;

  // Ability unlocks
  final bool _doubleJumpUnlocked = false;
  final bool _dashUnlocked = false;
  final bool _wallJumpUnlocked = false;

  @override
  Future<void> onLoad() async {
    // Implementation needed: Load saved player stats if available
    // Implementation needed: Initialize default values
  }

  /// Handle taking damage
  void takeDamage(double amount) {
    _currentHealth = (_currentHealth - amount).clamp(0, _maxHealth);
    // Implementation needed: Trigger events for UI updates
  }

  /// Handle healing
  void heal(double amount) {
    _currentHealth = (_currentHealth + amount).clamp(0, _maxHealth);
    // Implementation needed: Trigger events for UI updates
  }

  /// Use energy for abilities
  bool useEnergy(double amount) {
    if (_currentEnergy < amount) return false;

    _currentEnergy = (_currentEnergy - amount).clamp(0, _maxEnergy);
    // Implementation needed: Trigger events for UI updates
    return true;
  }

  /// Restore energy
  void restoreEnergy(double amount) {
    _currentEnergy = (_currentEnergy + amount).clamp(0, _maxEnergy);
    // Implementation needed: Trigger events for UI updates
  }

  /// Collect Aether shards
  void collectAetherShard(int amount) {
    _aetherShards += amount;
    // Implementation needed: Trigger events for UI updates
    // Implementation needed: Check for ability unlocks
  }

  /// Gain experience points
  void gainExperience(int amount) {
    _experience += amount;

    while (_experience >= _experienceToNextLevel) {
      levelUp();
    }
  }

  /// Level up character
  void levelUp() {
    _level += 1;
    _experience -= _experienceToNextLevel;
    _experienceToNextLevel = (_experienceToNextLevel * 1.2).toInt();

    // Increase stats on level up
    _maxHealth += 10;
    _currentHealth = _maxHealth;
    _maxEnergy += 5;
    _currentEnergy = _maxEnergy;

    // Implementation needed: Trigger level up events
  }

  // Getters
  double get healthPercentage => _currentHealth / _maxHealth;
  double get energyPercentage => _currentEnergy / _maxEnergy;
  int get aetherShards => _aetherShards;
  int get level => _level;
  int get experience => _experience;
  int get experienceToNextLevel => _experienceToNextLevel;
  bool get isAlive => _currentHealth > 0;

  // Ability unlock getters
  bool get canDoubleJump => _doubleJumpUnlocked;
  bool get canDash => _dashUnlocked;
  bool get canWallJump => _wallJumpUnlocked;
}

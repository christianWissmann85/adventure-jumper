# Aether System - Technical Design Document

## 1. Overview

Defines the implementation of the Aether energy system that powers all abilities in Adventure Jumper, including energy management, regeneration, consumption, and upgrade mechanics.

*For game design specifications, see [Aether System Design](../../01_Game_Design/Mechanics/AetherSystem_Design.md).*

### Purpose
- Manage Aether energy as the core resource for all abilities
- Implement energy regeneration and consumption mechanics
- Handle Aether-based progression and upgrades
- Integrate with all ability systems throughout the game

### Scope
- Energy pool management and calculations
- Regeneration algorithms and timing
- Consumption tracking for abilities
- Upgrade system for Aether capacity and efficiency
- Visual and audio feedback for energy states

## 2. Class Design

### Core Aether Classes

```dart
// Main Aether energy management system
class AetherSystem extends BaseSystem {
  // Current energy levels
  // Regeneration logic
  // Consumption tracking
  // Upgrade management
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has an aether component
    return entity.children.whereType<AetherComponent>().isNotEmpty;
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Process aether component logic
    // Handle regeneration and energy updates
  }
  
  @override
  void processSystem(double dt) {
    // Update environmental aether effects
    // Process active aether abilities
  }
}

// Aether pool data structure
class AetherPool {
  // Current energy amount
  // Maximum capacity
  // Regeneration rate
  // Efficiency modifiers
}

// Aether upgrade manager
class AetherUpgradeSystem {
  // Upgrade definitions
  // Progress tracking
  // Cost calculations
  // Effect applications
}
```

### Key Responsibilities
- **AetherSystem**: Central energy management and calculations
- **AetherPool**: Data container for energy state and properties
- **AetherUpgradeSystem**: Progression and enhancement mechanics

## 3. Data Structures

### Aether State
```dart
class AetherState {
  double currentEnergy;        // Current energy amount (0-100)
  double maxEnergy;           // Maximum energy capacity
  double regenRate;           // Energy per second regeneration
  double regenDelay;          // Delay before regeneration starts
  bool isRegenerating;        // Current regeneration state
  DateTime lastUsageTime;     // When energy was last consumed
}
```

### Aether Consumption
```dart
class AetherConsumption {
  String abilityId;          // Which ability consumed energy
  double amount;             // Amount of energy consumed
  DateTime timestamp;        // When consumption occurred
  bool wasSuccessful;        // Whether consumption succeeded
}
```

### Aether Upgrades
```dart
class AetherUpgrade {
  String upgradeId;          // Unique upgrade identifier
  String name;               // Display name
  String description;        // Upgrade description
  double capacityBonus;      // Additional max energy
  double regenBonus;         // Additional regeneration rate
  double efficiencyBonus;    // Reduced consumption multiplier
  int cost;                  // Upgrade cost (in crystals/materials)
  bool isUnlocked;          // Whether upgrade is available
}
```

## 4. Algorithms

### Energy Regeneration
```
If (time_since_last_usage > regeneration_delay):
  current_energy = min(max_energy, current_energy + (regen_rate * delta_time))
```

### Consumption Validation
```
bool CanConsumeEnergy(double amount):
  return current_energy >= amount

bool ConsumeEnergy(double amount):
  if (CanConsumeEnergy(amount)):
    current_energy -= amount
    last_usage_time = current_time
    return true
  return false
```

### Efficiency Calculations
```
double GetEffectiveCost(double base_cost):
  return base_cost * (1.0 - total_efficiency_bonus)
```

## 5. API/Interfaces

### Aether System Interface
```dart
interface IAetherSystem {
  double getCurrentEnergy();
  double getMaxEnergy();
  bool canConsumeEnergy(double amount);
  bool consumeEnergy(double amount, String abilityId);
  void addEnergy(double amount);
  void upgradeCapacity(double bonus);
  void upgradeRegeneration(double bonus);
}

interface IAetherListener {
  void onEnergyChanged(double currentEnergy, double maxEnergy);
  void onEnergyDepleted();
  void onEnergyRestored();
}
```

### Upgrade System Interface
```dart
interface IAetherUpgradeSystem {
  List<AetherUpgrade> getAvailableUpgrades();
  bool canAffordUpgrade(String upgradeId);
  bool purchaseUpgrade(String upgradeId);
  double getTotalCapacityBonus();
  double getTotalRegenBonus();
  double getTotalEfficiencyBonus();
}
```

## 6. Dependencies

### System Dependencies
- **Player Character**: For ability activation and energy consumption
- **Combat System**: For attack abilities that consume energy
- **UI System**: For energy bar display and upgrade interface
- **Save System**: For persistent upgrade progress
- **Audio System**: For energy-related sound effects

### Component Dependencies
- Ability systems for consumption calculations
- Visual effects for energy depletion feedback
- Achievement system for upgrade milestones

## 7. File Structure

```
lib/
  game/
    systems/
      aether/
        aether_system.dart           # Main energy management
        aether_pool.dart            # Energy data structure
        aether_upgrades.dart        # Upgrade system
        aether_calculator.dart      # Energy calculations
        aether_events.dart          # Energy-related events
    components/
      aether/
        aether_component.dart       # Component for entities with energy
        aether_consumer.dart        # Mixin for energy consumption
        aether_visualizer.dart      # Visual feedback component
    data/
      aether/
        upgrade_definitions.dart    # Upgrade data definitions
        ability_costs.dart         # Energy costs for abilities
```

## 8. Performance Considerations

### Optimization Strategies
- Cache efficiency calculations to avoid repeated computation
- Batch energy updates during frame processing
- Use efficient data structures for upgrade lookups
- Minimize allocation during energy operations

### Memory Management
- Reuse consumption tracking objects
- Efficient event notification system
- Lazy loading of upgrade definitions

## 9. Testing Strategy

### Unit Tests
- Energy consumption and regeneration accuracy
- Upgrade calculation correctness
- Edge cases (zero energy, maximum energy)
- Efficiency bonus stacking

### Integration Tests
- Integration with ability systems
- UI synchronization with energy changes
- Save/load of upgrade progress
- Performance under heavy usage

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Basic energy pool and consumption
2. **Phase 2**: Regeneration mechanics and timing
3. **Phase 3**: Upgrade system foundation
4. **Phase 4**: Visual feedback and UI integration
5. **Phase 5**: Advanced upgrades and balancing

### Energy Balance Guidelines
- **Base Energy**: 100 units maximum
- **Jump Cost**: 15 units
- **Dash Cost**: 25 units
- **Strike Cost**: 20 units
- **Pulse Cost**: 30 units
- **Regeneration**: 20 units per second (after 2-second delay)

## 11. Future Considerations

### Expandability
- Multiple energy types (different colors/elements)
- Temporary energy bonuses from items/areas
- Energy sharing between players (multiplayer)
- Environmental energy sources and drains

### Advanced Features
- Energy burst abilities (high cost, high reward)
- Energy-based puzzle mechanics
- Dynamic energy costs based on world/situation
- Energy efficiency based on player skill/timing

# Time Manipulation - Technical Design Document

## 1. Overview

Defines the implementation of time manipulation mechanics for the Celestial Archive world, including temporal puzzles, time-based abilities, and environmental time effects.

*For world design specifications, see [Celestial Archive](../../01_Game_Design/Worlds/04-celestial-archive.md).*

### Purpose
- Implement time manipulation as a core gameplay mechanic
- Create engaging temporal puzzles and challenges
- Handle complex time state management and synchronization
- Integrate time effects with existing game systems

### Scope
- Time manipulation abilities and controls
- Temporal object state management
- Time-based puzzle mechanics
- Environmental time effects
- Performance optimization for time calculations

## 2. Class Design

### Core Time Manipulation Classes

```dart
// Main time manipulation system
class TimeManipulationSystem extends GameSystem {
  // Global time state management
  // Temporal effect coordination
  // Time zone management
  // Performance optimization
}

// Time-affected entity component
class TemporalComponent extends GameComponent {
  // Object time state
  // Temporal behavior definitions
  // State interpolation
  // Effect application
}

// Time manipulation abilities
class TimeAbilities {
  // Time slow/acceleration
  // Temporal rewind
  // Time freeze zones
  // Temporal sight
}
```

### Supporting Classes

```dart
// Time zone area effects
class TimeZone extends GameComponent {
  // Zone boundaries and effects
  // Time modification parameters
  // Entry/exit triggers
  // Visual feedback
}

// Temporal state manager
class TemporalState {
  // Historical state storage
  // State interpolation
  // Memory management
  // Rollback capabilities
}

// Time puzzle controller
class TimePuzzle extends GameComponent {
  // Puzzle logic and rules
  // Solution validation
  // Progress tracking
  // Hint system
}
```

## 3. Data Structures

### Time State
```dart
class TimeState {
  double timeScale;          // Current time multiplier (0.0 - 2.0)
  bool isFrozen;            // Whether time is completely stopped
  DateTime realTime;        // Real-world time reference
  double gameTime;          // Accumulated game time
  Map<String, double> zoneTimeScales; // Time scales per zone
  List<TemporalSnapshot> history; // State history for rewind
}
```

### Temporal Snapshot
```dart
class TemporalSnapshot {
  DateTime timestamp;        // When snapshot was taken
  Vector2 position;         // Entity position
  Vector2 velocity;         // Entity velocity
  double rotation;          // Entity rotation
  Map<String, dynamic> customState; // Entity-specific data
  String animationState;    // Animation frame/state
}
```

### Time Zone Data
```dart
class TimeZoneData {
  String zoneId;            // Unique zone identifier
  Rectangle bounds;         // Zone area boundaries
  double timeScale;         // Time multiplier in zone
  TimeZoneType type;        // Slow, Fast, Freeze, Rewind
  bool affectsPlayer;       // Whether player is affected
  bool affectsEnemies;      // Whether enemies are affected
  bool affectsProjectiles;  // Whether projectiles are affected
  double fadeDistance;      // Transition smoothing distance
}
```

### Time Ability Data
```dart
class TimeAbilityData {
  String abilityId;         // Unique ability identifier
  double duration;          // Effect duration in seconds
  double timeScale;         // Time modification amount
  double radius;            // Area of effect radius
  double aetherCost;        // Energy cost to activate
  double cooldown;          // Cooldown time after use
  bool requiresTarget;      // Whether ability needs a target
  List<String> affectedTags; // Which entity types are affected
}
```

## 4. Algorithms

### Time State Update
```
function updateTimeState(deltaTime):
  realDeltaTime = deltaTime
  
  for each entity in temporalEntities:
    localTimeScale = calculateLocalTimeScale(entity.position)
    entityDeltaTime = realDeltaTime * localTimeScale
    
    if entity.hasTemporalComponent():
      entity.updateWithTimeScale(entityDeltaTime, localTimeScale)
    
    if entity.recordsHistory():
      recordSnapshot(entity, currentTime)
```

### Time Zone Calculation
```
function calculateLocalTimeScale(position):
  baseTimeScale = globalTimeScale
  
  for each timeZone in activeTimeZones:
    if timeZone.contains(position):
      distance = timeZone.getDistanceFromCenter(position)
      influence = calculateInfluence(distance, timeZone.fadeDistance)
      baseTimeScale *= lerp(1.0, timeZone.timeScale, influence)
  
  return clamp(baseTimeScale, MIN_TIME_SCALE, MAX_TIME_SCALE)
```

### Temporal Rewind
```
function rewindToTime(targetTime):
  for each entity in rewindableEntities:
    snapshots = entity.getTemporalHistory()
    targetSnapshot = findClosestSnapshot(snapshots, targetTime)
    
    if targetSnapshot != null:
      entity.restoreFromSnapshot(targetSnapshot)
      
      // Interpolate if needed for smooth rewind
      nextSnapshot = findNextSnapshot(snapshots, targetTime)
      if nextSnapshot != null:
        interpolationFactor = calculateInterpolation(targetTime, targetSnapshot, nextSnapshot)
        entity.interpolateState(targetSnapshot, nextSnapshot, interpolationFactor)
```

### State Interpolation
```
function interpolateTemporalState(fromState, toState, factor):
  interpolatedState = new TemporalSnapshot()
  interpolatedState.position = lerp(fromState.position, toState.position, factor)
  interpolatedState.velocity = lerp(fromState.velocity, toState.velocity, factor)
  interpolatedState.rotation = lerpAngle(fromState.rotation, toState.rotation, factor)
  
  // Custom interpolation for entity-specific data
  for key in fromState.customState.keys:
    if key in toState.customState:
      interpolatedState.customState[key] = interpolateValue(
        fromState.customState[key], 
        toState.customState[key], 
        factor
      )
  
  return interpolatedState
```

## 5. API/Interfaces

### Time Manipulation Interface
```dart
interface ITimeManipulation {
  void setGlobalTimeScale(double scale);
  double getGlobalTimeScale();
  void freezeTime(double duration);
  void createTimeZone(TimeZoneData zoneData);
  void removeTimeZone(String zoneId);
  bool activateTimeAbility(String abilityId, Vector2 position);
}

interface ITemporalEntity {
  void updateWithTimeScale(double deltaTime, double timeScale);
  void recordSnapshot(DateTime timestamp);
  void restoreFromSnapshot(TemporalSnapshot snapshot);
  List<TemporalSnapshot> getTemporalHistory();
  void clearTemporalHistory();
}
```

### Time Zone Interface
```dart
interface ITimeZone {
  bool contains(Vector2 position);
  double getInfluenceAt(Vector2 position);
  double getTimeScaleAt(Vector2 position);
  void setTimeScale(double scale);
  void activate();
  void deactivate();
}

interface ITimePuzzle {
  bool isSolved();
  void checkSolution();
  void resetPuzzle();
  double getCompletionPercentage();
  void provideHint();
}
```

## 6. Dependencies

### System Dependencies
- **Physics System**: For time-affected physics calculations
- **Animation System**: For time-scaled animation playback
- **Audio System**: For time-affected audio pitch and timing
- **Particle System**: For time-affected visual effects
- **Aether System**: For time ability energy costs

### Component Dependencies
- Player character for time ability activation
- Enemy AI for time-affected behavior
- Environmental objects for temporal interaction

## 7. File Structure

```
lib/
  game/
    systems/
      time/
        time_manipulation_system.dart # Main time system
        temporal_component.dart      # Time-affected entities
        time_abilities.dart         # Time manipulation abilities
        time_zones.dart            # Area-based time effects
        temporal_state.dart        # State management and history
    components/
      time/
        time_zone.dart             # Time zone area component
        temporal_entity.dart       # Entity with time capabilities
        time_puzzle.dart          # Temporal puzzle mechanics
        rewind_trail.dart         # Visual rewind feedback
    puzzles/
      time/
        clock_tower_puzzle.dart    # Specific puzzle implementations
        temporal_switch_puzzle.dart
        time_crystal_puzzle.dart
    data/
      time/
        time_ability_data.dart     # Ability definitions
        time_zone_data.dart       # Zone configuration data
        puzzle_definitions.dart    # Puzzle setup data
```

## 8. Performance Considerations

### Optimization Strategies
- Limit temporal history storage to essential snapshots
- Use spatial partitioning for time zone calculations
- Batch time scale updates for multiple entities
- Implement level-of-detail for distant temporal effects

### Memory Management
- Automatic cleanup of old temporal snapshots
- Efficient storage of state history
- Lazy loading of puzzle configurations
- Object pooling for temporary time effects

## 9. Testing Strategy

### Unit Tests
- Time scale calculation accuracy
- Temporal snapshot interpolation
- Time zone boundary detection
- State restoration correctness

### Integration Tests
- Time effects on physics simulation
- Audio synchronization with time changes
- Visual effect timing accuracy
- Puzzle solution validation

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Basic time scale modification and zones
2. **Phase 2**: Temporal state recording and rewind
3. **Phase 3**: Time-based puzzles and challenges
4. **Phase 4**: Advanced abilities and visual effects
5. **Phase 5**: Performance optimization and polish

### Time Manipulation Design Principles
- **Clarity**: Clear visual indicators for time effects
- **Consistency**: Predictable rules for time interaction
- **Challenge**: Meaningful puzzles that require temporal thinking
- **Performance**: Smooth gameplay even with complex time effects

## 11. Future Considerations

### Expandability
- Multiple time streams with different flow rates
- Temporal echoes (ghostly replays of past actions)
- Time-based multiplayer mechanics
- Procedural temporal puzzle generation

### Advanced Features
- Causal loop mechanics (actions affecting past)
- Time dilation based on velocity (relativity effects)
- Temporal anomalies and paradox resolution
- Time-based narrative branching

## Related Design Documents

- See [Celestial Archive](../../01_Game_Design/Worlds/04-celestial-archive.md) for world design and time-based puzzles
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for integration with main mechanics
- See [Time Keepers](../../01_Game_Design/Characters/03-enemies.md#chrono-guardians) for time-based enemy designs

# Gravity System - Technical Design Document

## 1. Overview

Defines the implementation of gravity manipulation mechanics for Void's Edge world, including gravity field manipulation, spatial orientation changes, and physics modifications for the final act of Adventure Jumper.

*For world design specifications, see [Void's Edge](../../01_Game_Design/Worlds/05-voids-edge.md).*

### Purpose
- Implement gravity manipulation as a unique final-world mechanic
- Create engaging spatial puzzles and navigation challenges
- Handle complex physics modifications and orientation changes
- Integrate gravity effects with existing movement and combat systems

### Scope
- Gravity field modification and direction changes
- Spatial orientation and camera handling
- Physics system integration and overrides
- Gravity-based puzzles and environmental challenges
- Performance optimization for complex physics calculations

## 2. Class Design

### Core Gravity System Classes

```dart
// Main gravity manipulation system
class GravitySystem extends BaseSystem {
  // Global gravity state management
  // Gravity field coordination
  // Physics system integration
  // Performance optimization
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has gravity-affected components
    return entity.children.whereType<GravityAffected>().isNotEmpty ||
           entity.children.whereType<PhysicsComponent>().isNotEmpty;
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Apply appropriate gravity to entity based on fields and global settings
    // Update entity orientation based on gravity direction
    // Handle physics modifications and transitions
  }
  
  @override
  void processSystem(double dt) {
    // Update global gravity state
    // Process gravity field interactions
    // Handle camera orientation adjustments
  }
}

// Gravity field component
class GravityField extends GameComponent {
  // Field boundaries and properties
  // Gravity direction and strength
  // Affected entity tracking
  // Transition smoothing
}

// Gravity manipulation abilities
class GravityAbilities {
  // Gravity shift abilities
  // Localized gravity wells
  // Anti-gravity zones
  // Gravity anchors
}
```

### Supporting Classes

```dart
// Gravity-affected entity component
class GravityAffected extends GameComponent {
  // Entity gravity state
  // Orientation tracking
  // Physics overrides
  // Visual feedback
}

// Gravity transition controller
class GravityTransition {
  // Smooth gravity changes
  // Orientation interpolation
  // Physics state management
  // Camera coordination
}

// Gravity puzzle mechanics
class GravityPuzzle extends GameComponent {
  // Puzzle logic and rules
  // Solution validation
  // State management
  // Hint system
}
```

## 3. Data Structures

### Gravity State
```dart
class GravityState {
  Vector2 globalGravityDirection;  // World gravity direction (normalized)
  double globalGravityStrength;   // Global gravity force magnitude
  Map<String, GravityFieldData> activeFields; // Active gravity fields
  bool isTransitioning;           // Whether gravity is currently changing
  double transitionProgress;      // Current transition completion (0-1)
  Vector2 targetGravityDirection; // Target gravity for transitions
}
```

### Gravity Field Data
```dart
class GravityFieldData {
  String fieldId;             // Unique field identifier
  Vector2 center;            // Field center position
  double radius;             // Field influence radius
  Vector2 gravityDirection;  // Gravity direction in field
  double gravityStrength;    // Gravity strength multiplier
  GravityFieldType type;     // Point, Directional, Radial, Null
  double falloffDistance;    // Distance over which field weakens
  bool affectsPlayer;        // Whether field affects player
  bool affectsEnemies;       // Whether field affects enemies
  bool affectsObjects;       // Whether field affects physics objects
}
```

### Gravity Ability Data
```dart
class GravityAbilityData {
  String abilityId;          // Unique ability identifier
  double duration;           // Effect duration in seconds
  Vector2 gravityDirection;  // New gravity direction
  double gravityStrength;    // Gravity strength modifier
  double radius;             // Area of effect radius
  double aetherCost;         // Energy cost to activate
  double cooldown;           // Cooldown time after use
  bool isGlobal;            // Whether ability affects entire level
  List<String> affectedTags; // Which entity types are affected
}
```

### Entity Gravity State
```dart
class EntityGravityState {
  Vector2 currentGravity;    // Current gravity affecting entity
  Vector2 velocity;          // Current velocity
  bool isGrounded;          // Whether entity is on a surface
  Vector2 surfaceNormal;     // Normal of surface entity is on
  double orientation;        // Entity's current orientation
  bool canReorient;         // Whether entity can change orientation
  DateTime lastGravityChange; // When gravity last changed for entity
}
```

## 4. Algorithms

### Gravity Field Calculation
```
function calculateGravityAtPosition(position):
  totalGravity = globalGravity
  
  for each gravityField in activeFields:
    distance = calculateDistance(position, gravityField.center)
    
    if distance <= gravityField.radius:
      influence = calculateInfluence(distance, gravityField.radius, gravityField.falloffDistance)
      fieldGravity = calculateFieldGravity(gravityField, position)
      
      // Combine gravity forces based on field type
      switch gravityField.type:
        case ADDITIVE:
          totalGravity += fieldGravity * influence
        case OVERRIDE:
          totalGravity = lerp(totalGravity, fieldGravity, influence)
        case RADIAL:
          radialForce = calculateRadialGravity(gravityField, position)
          totalGravity += radialForce * influence
  
  return totalGravity
```

### Gravity Transition
```
function transitionGravity(fromDirection, toDirection, duration):
  transitionTimer = 0
  
  while transitionTimer < duration:
    progress = easeInOutCubic(transitionTimer / duration)
    currentGravity = slerp(fromDirection, toDirection, progress)
    
    // Update all affected entities
    for each entity in gravityAffectedEntities:
      entity.setGravity(currentGravity)
      
      // Handle orientation changes for entities that can reorient
      if entity.canReorient():
        targetOrientation = calculateOrientationFromGravity(currentGravity)
        entity.smoothOrientationTo(targetOrientation)
    
    // Update camera if needed
    if cameraFollowsGravity:
      updateCameraOrientation(currentGravity)
    
    transitionTimer += deltaTime
  
  // Finalize transition
  setGlobalGravity(toDirection)
```

### Surface Alignment
```
function alignToSurface(entity, surfaceNormal, gravityDirection):
  // Calculate desired up direction based on gravity
  desiredUp = -normalize(gravityDirection)
  
  // Calculate rotation needed to align with surface
  currentUp = entity.getUpVector()
  rotationAxis = cross(currentUp, desiredUp)
  rotationAngle = acos(dot(currentUp, desiredUp))
  
  // Apply rotation smoothly
  if rotationAngle > ALIGNMENT_THRESHOLD:
    maxRotationSpeed = entity.getMaxRotationSpeed()
    actualRotationAngle = min(rotationAngle, maxRotationSpeed * deltaTime)
    
    rotation = createRotation(rotationAxis, actualRotationAngle)
    entity.applyRotation(rotation)
    
    return false  // Still rotating
  
  return true  // Alignment complete
```

### Gravity Well Physics
```
function calculateGravityWellForce(wellPosition, entityPosition, wellStrength, wellRadius):
  toWell = wellPosition - entityPosition
  distance = length(toWell)
  
  if distance > wellRadius:
    return Vector2.zero()  // Outside well influence
  
  if distance < MIN_WELL_DISTANCE:
    distance = MIN_WELL_DISTANCE  // Prevent division by zero
  
  // Calculate force using inverse square law (modified for gameplay)
  forceMagnitude = wellStrength / (distance * distance)
  forceDirection = normalize(toWell)
  
  // Apply distance falloff for smooth edges
  falloffFactor = 1.0 - (distance / wellRadius)
  falloffFactor = smoothstep(0.0, 1.0, falloffFactor)
  
  return forceDirection * forceMagnitude * falloffFactor
```

## 5. API/Interfaces

### Gravity System Interface
```dart
interface IGravitySystem {
  void setGlobalGravity(Vector2 direction, double strength);
  Vector2 getGlobalGravity();
  void createGravityField(GravityFieldData fieldData);
  void removeGravityField(String fieldId);
  Vector2 calculateGravityAt(Vector2 position);
  bool activateGravityAbility(String abilityId, Vector2 position);
}

interface IGravityAffected {
  void setGravity(Vector2 gravityDirection, double strength);
  Vector2 getCurrentGravity();
  bool canReorient();
  void updateGravityPhysics(double deltaTime);
  void onGravityChanged(Vector2 newGravity);
}
```

### Gravity Field Interface
```dart
interface IGravityField {
  Vector2 calculateGravityAt(Vector2 position);
  bool isPositionInField(Vector2 position);
  double getInfluenceAt(Vector2 position);
  void setFieldStrength(double strength);
  void activate();
  void deactivate();
}

interface IGravityPuzzle {
  bool isSolved();
  void checkSolution();
  void resetPuzzle();
  double getCompletionPercentage();
  void provideHint();
}
```

## 6. Dependencies

### System Dependencies
- **Physics System**: For gravity force application and collision detection
- **Camera System**: For orientation changes and smooth transitions
- **Animation System**: For gravity-affected animations and orientation
- **Audio System**: For gravity shift sound effects
- **Aether System**: For gravity ability energy costs

### Component Dependencies
- Player character for gravity ability activation
- Level geometry for surface detection and alignment
- Enemy AI for gravity-affected behavior modifications

## 7. File Structure

```
lib/
  game/
    systems/
      gravity/
        gravity_system.dart          # Main gravity management
        gravity_field.dart          # Gravity field implementation
        gravity_abilities.dart      # Gravity manipulation abilities
        gravity_transition.dart     # Smooth gravity changes
        gravity_physics.dart        # Physics integration
    components/
      gravity/
        gravity_affected.dart       # Gravity-affected entities
        gravity_anchor.dart        # Fixed orientation objects
        gravity_puzzle.dart        # Gravity-based puzzles
        gravity_visualizer.dart    # Visual feedback for gravity
    puzzles/
      gravity/
        orientation_chamber.dart    # Specific puzzle implementations
        gravity_maze.dart
        floating_platforms.dart
    data/
      gravity/
        gravity_ability_data.dart   # Ability definitions
        gravity_field_data.dart    # Field configuration data
        puzzle_definitions.dart    # Puzzle setup data
```

## 8. Performance Considerations

### Optimization Strategies
- Spatial partitioning for gravity field calculations
- Level-of-detail processing based on distance from player
- Cached gravity calculations for static positions
- Efficient physics integration with Flame engine

### Memory Management
- Object pooling for gravity effect objects
- Efficient storage of gravity field data
- Lazy loading of puzzle configurations
- Automatic cleanup of temporary gravity effects

## 9. Testing Strategy

### Unit Tests
- Gravity field calculation accuracy
- Transition smoothness and timing
- Surface alignment correctness
- Physics integration stability

### Integration Tests
- Gravity effects on player movement
- Camera behavior during gravity changes
- Enemy AI adaptation to gravity changes
- Performance under complex gravity scenarios

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Basic gravity direction changes and physics integration
2. **Phase 2**: Gravity fields and localized effects
3. **Phase 3**: Smooth transitions and camera handling
4. **Phase 4**: Gravity-based puzzles and challenges
5. **Phase 5**: Performance optimization and visual polish

### Gravity Design Principles
- **Intuitive Control**: Clear visual feedback for gravity direction
- **Smooth Transitions**: No jarring changes in gravity
- **Spatial Awareness**: Clear indicators of gravity field boundaries
- **Challenge Progression**: Gradual introduction of complex gravity mechanics

## 11. Future Considerations

### Expandability
- 3D gravity manipulation (full spatial freedom)
- Momentum-based gravity effects
- Gravity-based combat mechanics
- Procedural gravity puzzle generation

### Advanced Features
- Gravity painting (player-controlled gravity fields)
- Temporal gravity (gravity changes over time)
- Cooperative gravity puzzles (multiplayer)
- Gravity-based movement abilities (gravity surfing)

## Related Design Documents

- See [Void's Edge](../../01_Game_Design/Worlds/05-voids-edge.md) for world design and gravity-based puzzles
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for integration with main mechanics
- See [World Connections](../../01_Game_Design/Worlds/00-World-Connections.md) for transitions to altered gravity areas
- See [Reality Shifters](../../01_Game_Design/Characters/03-enemies.md) for gravity-manipulating enemies

# Player Character - Technical Design Document

## 1. Overview

Defines the implementation of Kael, the main player character, with primary focus on **Fluid & Expressive Movement** that enables player creativity and skill expression. This system prioritizes responsive controls, smooth transitions, and movement-integrated abilities that support engaging gameplay flow.

> **Design & Technical References:**
>
> - [Character Design: Kael](../../01_Game_Design/Characters/01-main-character.md) - Design specifications and abilities
> - [Game Design: Mechanics](../../01_Game_Design/GDD.md) - Core gameplay mechanics
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Design pillars and validation criteria
> - [Sprint Plan](../../04_Project_Management/AgileSprintPlan.md) - Implementation timeline and priorities
> - [System Architecture](../Architecture.md) - Component integration within system architecture
> - [Asset Pipeline](../AssetPipeline.md) - Character asset and animation pipeline
> - [Audio System TDD](AudioSystem.TDD.md) - Character movement audio integration
> - [UI System TDD](UISystem.TDD.md) - Character state UI feedback

### Purpose

- **Primary**: Deliver fluid and expressive movement that feels responsive and empowering
- Implement responsive character movement with <4 frame input response (optimal for 60fps gameplay)
- Enable creative movement combinations supporting multiple approach strategies
- Integrate movement seamlessly with combat abilities (no interruptions)
- Support progressive mastery through increasingly complex movement options
- Handle character state transitions with smooth, readable animations

### Scope

- Character controller physics optimized for 60fps gameplay feel
- Core ability system (Jump, Dash, Strike, Pulse) with movement integration
- Animation state machine prioritizing fluidity over realism
- Character progression supporting skill expression growth
- Input handling with buffering for combo responsiveness
- Movement-combat integration ensuring abilities enhance rather than interrupt flow

### Design Cohesion Focus: Fluid & Expressive Movement

This TDD specifically supports the **Fluid & Expressive Movement** design pillar through:

- **Responsiveness**: <4-frame input response for optimal gameplay feel (67ms at 60fps)
- **Flow Integration**: Movement abilities that work together seamlessly
- **Player Expression**: Multiple movement approaches for any situation
- **Progressive Complexity**: Movement options that grow with player skill
- **Combat Integration**: Combat abilities that enhance movement rather than interrupt it

## 2. Class Design

### Core Character Classes

```dart
// Main player character component
class KaelCharacter extends GameComponent with HasKeyboardHandlerComponents {
  // Movement and physics
  // Ability management
  // Animation controller
  // State machine
}

// Character movement controller
class CharacterMovement {
  // Velocity and acceleration
  // Ground detection
  // Wall interaction
  // Physics integration
}

// Ability system manager
class AbilitySystem {
  // Ability definitions
  // Cooldown management
  // Aether cost calculations
  // Upgrade tracking
}
```

### Key Responsibilities

- **KaelCharacter**: Main character coordination and high-level behavior
- **CharacterMovement**: Physics-based movement and collision handling
- **AbilitySystem**: Management of all character abilities and their states

## 3. Data Structures

### Character State

```dart
class CharacterState {
  Vector2 position;
  Vector2 velocity;
  bool isGrounded;
  bool isWallSliding;
  CharacterAction currentAction;
  double aetherEnergy;
  Map<String, AbilityData> abilities;
}
```

### Ability Data

```dart
class AbilityData {
  String abilityId;
  double cooldownTime;
  double aetherCost;
  int upgradeLevel;
  bool isUnlocked;
  Map<String, dynamic> parameters;
}
```

## 4. Algorithms

### Movement Physics

- Platformer-style physics with momentum
- Coyote time for forgiving jump mechanics
- Variable jump height based on input duration
- Wall sliding and wall jumping mechanics

### Ability Execution

- State-based ability activation
- Cooldown and resource management
- Animation synchronization with ability effects
- Input buffering for responsive controls

## 5. API/Interfaces

### Character Controller Interface

```dart
interface ICharacterController {
  void moveHorizontal(double direction);
  void jump();
  void dash(Vector2 direction);
  void useAbility(String abilityId);
}

interface ICharacterState {
  bool canMove();
  bool canJump();
  bool canDash();
  bool canUseAbility(String abilityId);
}
```

### Ability System Interface

```dart
interface IAbilitySystem {
  bool executeAbility(String abilityId);
  void upgradeAbility(String abilityId);
  double getCooldownRemaining(String abilityId);
}
```

## 6. Dependencies

### System Dependencies

- **Physics System**: For movement and collision detection
- **Aether System**: For energy management and ability costs
- **Input System**: For player control handling
- **Animation System**: For character visual feedback
- **Audio System**: For movement and ability sound effects

### Component Dependencies

- Level geometry for collision detection
- Enemy systems for combat interactions
- UI system for ability cooldown display

## 7. File Structure

```
lib/
  game/
    characters/
      kael/
        kael_character.dart          # Main character component
        character_movement.dart      # Movement controller
        ability_system.dart          # Ability management
        character_animations.dart    # Animation controller
        character_state.dart         # State management
      player/
        player_input.dart           # Input handling
        player_controller.dart      # High-level player logic
    abilities/
      base_ability.dart            # Base ability class
      jump_ability.dart           # Jump implementation
      dash_ability.dart           # Dash implementation
      strike_ability.dart         # Strike implementation
      pulse_ability.dart          # Pulse implementation
```

## 8. Performance Considerations

### Optimization Strategies

- Efficient collision detection with spatial partitioning
- Animation state caching to reduce lookups
- Input prediction for responsive controls
- Ability effect pooling for visual effects

### Memory Management

- Reuse ability effect objects
- Efficient state machine implementation
- Minimal allocation during movement updates

## 9. Testing Strategy

### Unit Tests

- Movement physics accuracy
- Ability cooldown calculations
- State transition correctness
- Input response timing

### Integration Tests

- Character-environment interaction
- Ability system integration with combat
- Animation synchronization with actions

## 10. Implementation Notes

### Sprint-Aligned Development Phases

**Sprint 1: Movement Foundation**

- Basic character controller with responsive horizontal movement
- Jump mechanics with variable height and coyote time
- Ground detection and basic physics integration
- Input buffering system for combo preparation
- _Validation_: <4-frame input response (67ms at 60fps), smooth movement transitions

**Sprint 2-3: Fluid Movement System**

- Dash ability with directional control and momentum preservation
- Wall sliding and wall jumping mechanics
- Movement state machine with seamless transitions
- Basic animation integration prioritizing responsiveness
- _Validation_: Movement abilities work together without interruption

**Sprint 4-6: Combat-Movement Integration**

- Strike ability that enhances rather than interrupts movement
- Pulse ability with movement-based targeting
- Ability combo system supporting creative play
- Combat actions that maintain movement flow
- _Validation_: Combat abilities feel like movement extensions

**Sprint 7+: Progressive Mastery Features**

- Advanced movement combinations and techniques
- Upgrade system that expands movement expression
- World-specific abilities that build on core movement
- Movement mastery challenges and skill expression metrics
- _Validation_: Increasing complexity feels natural and rewarding

### Design Cohesion Validation Checkpoints

**Fluid & Expressive Movement Metrics:**

- **Input Responsiveness**: <4 frame lag for all movement actions (67ms at 60fps)
- **Transition Smoothness**: No jarring stops between movement abilities
- **Creative Expression**: Multiple viable movement approaches for navigation
- **Combat Integration**: No movement interruptions during combat abilities
- **Progressive Feel**: Each upgrade feels meaningfully more expressive

**Player Experience Validation:**

- Movement feels immediately satisfying even for new players
- Advanced players can express skill through movement creativity
- Combat enhances movement flow rather than interrupting it
- Learning curve feels natural and rewarding
- All abilities work together harmoniously

### Control Mapping (Optimized for Flow)

- **WASD/Arrow Keys**: Movement (immediate response)
- **Space**: Jump (variable height, buffered input)
- **Shift**: Dash (directional, momentum-preserving)
- **Left Click**: Strike (movement-integrated combat)
- **Right Click**: Pulse (movement-based targeting)
- **Q/E**: Special abilities (world-specific, movement-enhancing)

## 11. Future Considerations

### Expandability

- New ability types for different worlds
- Character customization options
- Multiple character support
- Advanced movement mechanics (wall running, etc.)

### Accessibility

- Customizable control schemes
- Visual indicators for ability states
- Audio cues for important actions
- Difficulty scaling options

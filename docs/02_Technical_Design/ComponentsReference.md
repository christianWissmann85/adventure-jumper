# Adventure Jumper - Components Reference
*Last Updated: January 2025*

This document outlines the core components used in Adventure Jumper's Entity-Component-System architecture, organized by the 11-module structure defined in Sprint 1 scaffolding. Each component supports our Design Cohesion principles and has a defined sprint delivery timeline.

> **Related Documents:**
> - [Architecture](Architecture.md) - System architecture overview and module structure
> - [Documentation Sync Plan](DocumentationSyncPlan.md) - Sprint alignment approach
> - [Design Cohesion Guide](../04_Project_Management/DesignCohesionGuide.md) - Design principles
> - [Agile Sprint Plan](../04_Project_Management/AgileSprintPlan.md) - Sprint details

## Component Organization by Module

### Game Module Components (Sprint 1)
**Design Cohesion Focus: Core System Coordination**

#### 1. Game State Component
- **Purpose**: Manages overall game state and transitions
- **Properties**:
  - `GameStateType currentState` (Playing, Paused, Loading, etc.)
  - `GameStateType previousState`
  - `double stateTransitionTime`
  - `Map<String, dynamic> stateData`
- **Systems**: GameSystem, UISystem
- **Sprint Delivery**: Sprint 1 - Foundation
- **Design Validation**: Supports seamless transitions enhancing player immersion

#### 2. Camera Target Component  
- **Purpose**: Defines entities that can be camera targets
- **Properties**:
  - `Vector2 offset` - Camera offset from entity
  - `double followSpeed` - Camera follow responsiveness
  - `bool isActive` - Whether this target is currently active
  - `CameraBounds? bounds` - Optional boundary constraints
- **Systems**: CameraSystem, RenderSystem
- **Sprint Delivery**: Sprint 1 - Foundation
- **Design Validation**: Enables smooth camera movement supporting fluid gameplay

### Player Module Components (Sprint 1-2)
**Design Cohesion Focus: Fluid & Expressive Movement**

#### 3. Player Controller Component
- **Purpose**: Core player movement and input handling
- **Properties**:
  - `double moveSpeed` - Base movement speed
  - `double jumpForce` - Jump strength
  - `double dashDistance` - Dash ability range
  - `bool isGrounded` - Ground contact state
  - `int airJumpsRemaining` - Available air jumps
  - `Map<String, bool> abilityStates` - Ability availability
- **Systems**: InputSystem, MovementSystem, PhysicsSystem
- **Sprint Delivery**: Sprint 1 - Basic movement, Sprint 2 - Advanced abilities
- **Design Validation**: Prioritizes input responsiveness and skill expression
  - `double jumpForce`
  - `double maxSpeed`
  - `double accelerationFactor`
  - `double frictionFactor`
  - `int airJumpsAllowed`
  - `bool isGrounded`
  - `Function(double)? onLand`
- **Systems**: InputSystem, PhysicsSystem, AISystem
- **Technical Implementation**: Handles player and AI-controlled movement

#### 4. Player Stats Component
- **Purpose**: Tracks player progression and current status
- **Properties**:
  - `double currentHealth` - Current health points
  - `double maxHealth` - Maximum health capacity
  - `double currentAether` - Current Aether energy
  - `double maxAether` - Maximum Aether capacity
  - `int experiencePoints` - Total experience gained
  - `Map<String, int> abilityUpgrades` - Upgrade levels per ability
- **Systems**: AetherSystem, ProgressionSystem, UISystem
- **Sprint Delivery**: Sprint 1 - Basic stats, Sprint 3 - Progression system
- **Design Validation**: Supports progressive mastery through clear advancement

### Entity Module Components (Sprint 1-3)
**Design Cohesion Focus: Dynamic Interactions & World Building**

#### 5. Transform Component
- **Purpose**: Core spatial properties for all entities
- **Properties**:
  - `Vector2 position` - World position
  - `double rotation` - Rotation angle in radians
  - `Vector2 scale` - Scale multiplier
  - `int zIndex` - Render layer ordering
  - `bool isDirty` - Optimization flag for transform changes
- **Systems**: RenderSystem, PhysicsSystem, CollisionSystem
- **Sprint Delivery**: Sprint 1 - Foundation
- **Design Validation**: Enables precise control for skilled gameplay

#### 6. Entity Identity Component
- **Purpose**: Defines entity type and behavior category
- **Properties**:
  - `EntityType entityType` - Entity classification
  - `String entityId` - Unique identifier
  - `String displayName` - Human-readable name
  - `bool isInteractable` - Whether player can interact
  - `Map<String, dynamic> metadata` - Type-specific data
- **Systems**: EntitySystem, SaveSystem, UISystem
- **Sprint Delivery**: Sprint 1 - Foundation
- **Design Validation**: Supports clear player understanding of world elements

### Components Module Base Components (Sprint 1-2)
**Design Cohesion Focus: System Integration & Performance**

#### 7. Physics Component
- **Purpose**: Physics properties and collision behavior
- **Properties**:
  - `Vector2 velocity` - Current velocity
  - `Vector2 acceleration` - Applied acceleration
  - `double mass` - Entity mass for physics calculations
  - `double friction` - Surface friction coefficient
  - `CollisionShape collisionShape` - Collision geometry
  - `bool isKinematic` - Whether affected by physics
- **Systems**: PhysicsSystem, MovementSystem, CollisionSystem
- **Sprint Delivery**: Sprint 1 - Basic physics, Sprint 2 - Advanced interactions
- **Design Validation**: Optimized for gameplay feel over realistic simulation

#### 8. Animation Component
- **Purpose**: Sprite animation control and state management
- **Properties**:
  - `AnimationController controller` - Animation state machine
  - `String currentAnimation` - Currently playing animation
  - `double playbackSpeed` - Animation speed multiplier
  - `bool isLooping` - Whether animation loops
  - `Map<String, AnimationClip> animations` - Available animations
- **Systems**: AnimationSystem, RenderSystem
- **Sprint Delivery**: Sprint 1 - Basic animations, Sprint 2 - State transitions
- **Design Validation**: Provides clear visual feedback for all player actions

### Systems Module Components (Sprint 2-4)
**Design Cohesion Focus: Responsive Gameplay Systems**

#### 9. Aether Component
- **Purpose**: Manages Aether energy for abilities
- **Properties**:
  - `double currentAether` - Current energy amount
  - `double maxAether` - Maximum energy capacity
  - `double regenRate` - Energy regeneration per second
  - `double drainRate` - Active ability consumption rate
  - `bool isRegenerating` - Whether currently regenerating
  - `Map<String, double> abilityCosts` - Energy costs per ability
- **Systems**: AetherSystem, AbilitySystem, UISystem
- **Sprint Delivery**: Sprint 2 - Basic system, Sprint 4 - Advanced management
- **Design Validation**: Enables strategic ability use and progressive mastery

#### 10. Combat Component
- **Purpose**: Handles combat interactions and damage
- **Properties**:
  - `double attackDamage` - Base damage output
  - `double attackSpeed` - Attack frequency
  - `double attackRange` - Attack reach distance
  - `bool isAttacking` - Current attack state
  - `List<DamageType> resistances` - Damage type resistances
  - `CombatState combatState` - Current combat status
- **Systems**: CombatSystem, AnimationSystem, AudioSystem
- **Sprint Delivery**: Sprint 3 - Basic combat, Sprint 5 - Advanced techniques
- **Design Validation**: Integrates seamlessly with movement for fluid combat

### Audio Module Components (Sprint 2-3)
**Design Cohesion Focus: Immersive Feedback**

#### 11. Audio Source Component
- **Purpose**: 3D positioned audio effects
- **Properties**:
  - `Vector2 position` - Audio source position
  - `double volume` - Volume level (0-1)
  - `double pitch` - Pitch modification
  - `double maxDistance` - Maximum audible distance
  - `bool isLooping` - Whether audio loops
  - `AudioClip audioClip` - Audio asset reference
- **Systems**: AudioSystem, SpatialAudioSystem
- **Sprint Delivery**: Sprint 2 - Basic audio, Sprint 3 - Spatial effects
- **Design Validation**: Enhances world immersion and provides clear action feedback

## Sprint Delivery Timeline Summary

### Sprint 1 (Foundation): 
- Transform, Game State, Camera Target, Basic Player Controller, Entity Identity

### Sprint 2 (Core Systems):
- Player Stats, Animation, Audio Source, Basic Physics, Basic Aether

### Sprint 3 (Combat & World):
- Combat Component, Advanced Physics, Spatial Audio, World Interaction

### Sprint 4+ (Polish & Advanced):
- Advanced Aether management, Complex interactions, Performance optimizations

*For complete sprint details, see [Agile Sprint Plan](../04_Project_Management/AgileSprintPlan.md)*

## Design Cohesion Integration

Each component is designed to support our core Design Pillars:

**Fluid & Expressive Movement**: All movement-related components prioritize responsiveness and skill expression
**Engaging & Dynamic Combat**: Combat components integrate with movement for seamless action
**Progressive Mastery**: Upgrade and progression components support natural complexity growth

## Related Technical Documents

- [SystemArchitecture.TDD](TDD/SystemArchitecture.TDD.md) - Component system implementation
- [PlayerCharacter.TDD](TDD/PlayerCharacter.TDD.md) - Player-specific components
- [CombatSystem.TDD](TDD/CombatSystem.TDD.md) - Combat component details
- [AetherSystem.TDD](TDD/AetherSystem.TDD.md) - Energy system implementation

# Adventure Jumper - Systems Reference
*Last Updated: May 2025*

This document outlines the core systems used in Adventure Jumper's Entity-Component-System architecture. The systems in Adventure Jumper process entities based on their components and provide the game's logic and behaviors.

> **Related Documents:**
> - [Architecture](Architecture.md) - System architecture overview and module structure
> - [Components Reference](ComponentsReference.md) - Component details and organization
> - [Design Cohesion Guide](../04_Project_Management/DesignCohesionGuide.md) - Design principles

## System Base Classes

### BaseSystem

**Purpose:** Standard implementation of the System interface that provides common functionality for entity registration and management.

**Key Features:**
- Entity registration with filtering capabilities
- Entity iteration and processing per frame
- System lifecycle management (initialize, update, dispose)
- Active state control for pausing processing

**Implementation Details:**
- Maintains a list of entities that can be processed by the system
- Uses `canProcessEntity(Entity entity)` to determine if an entity should be processed
- Processes entities with `processEntity(Entity entity, double dt)`
- Provides system-wide processing with `processSystem(double dt)`
- Provides callback hooks with `onEntityAdded(Entity entity)` and `onEntityRemoved(Entity entity)`

**Design Validation:** Reduces code duplication and standardizes entity processing across all systems

### BaseFlameSystem

**Purpose:** Extends Flame's Component class while implementing the System interface.

**Key Features:**
- Same entity management as BaseSystem
- Integration with Flame's component lifecycle
- Direct integration with Flame's game loop
- Proper rendering order through Flame's component hierarchy

**Implementation Details:**
- Extends `Component` from Flame
- Implements the `System` interface
- Overrides the Component `update` method to process entities
- Maintains compatibility with both ECS and Flame's component architecture

**Design Validation:** Enables seamless integration between ECS processing and Flame's rendering system

## Core Game Systems

### 1. RenderSystem (extends BaseSystem)

**Purpose:** Manages the visual representation of entities.

**Entity Requirements:**
- Requires a SpriteComponent or similar visual component

**Key Functions:**
- Manages rendering layers and priorities
- Handles visual effects and animations
- Controls visibility based on camera frustum

**Design Validation:** Ensures consistent and high-quality visuals that support the game's aesthetic

### 2. PhysicsSystem (extends BaseFlameSystem)

**Purpose:** Handles physics simulation and collision detection.

**Entity Requirements:**
- Requires a PhysicsComponent with mass, velocity, etc.

**Key Functions:**
- Simulates physics forces including gravity
- Detects and resolves collisions
- Applies restitution and friction

**Design Validation:** Creates predictable and satisfying physics that enhance gameplay feel

### 3. MovementSystem (extends BaseFlameSystem)

**Purpose:** Processes entity movement based on input or AI directives.

**Entity Requirements:**
- Requires a MovementComponent with speed, direction, etc.

**Key Functions:**
- Translates input into movement vectors
- Handles character controller logic
- Manages movement states (walking, running, jumping)

**Design Validation:** Creates fluid and responsive movement that feels natural and satisfying

### 4. InputSystem (extends BaseFlameSystem)

**Purpose:** Processes user input and routes to entities.

**Entity Requirements:**
- Requires an InputComponent, or is the focused entity

**Key Functions:**
- Handles keyboard, touch, and gamepad input
- Maps raw input to game actions
- Routes input to appropriate entities
- Supports virtual controller for mobile

**Design Validation:** Ensures responsive controls that maintain the feeling of player agency

### 5. AISystem (extends BaseSystem)

**Purpose:** Controls behavior of non-player entities.

**Entity Requirements:**
- Requires an AIComponent with behavior parameters

**Key Functions:**
- Manages enemy behavior states
- Handles pathfinding and target tracking
- Controls decision-making for NPCs

**Design Validation:** Creates intelligent and dynamic opponents that provide appropriate challenge

### 6. CombatSystem (extends BaseSystem)

**Purpose:** Manages combat interactions between entities.

**Entity Requirements:**
- Requires a HealthComponent or is a combat-capable entity

**Key Functions:**
- Calculates damage and effects
- Manages attack hitboxes and collision
- Handles health and status effects
- Logs combat events for UI feedback

**Design Validation:** Provides engaging combat that integrates with the movement system

### 7. AetherSystem (extends BaseSystem)

**Purpose:** Manages Aether energy and special abilities.

**Entity Requirements:**
- Requires an AetherComponent

**Key Functions:**
- Tracks Aether energy levels
- Manages ability cooldowns and effects
- Controls environmental Aether interactions
- Creates and manages Aether effects

**Design Validation:** Supports the progression of player mastery through ability management

### 8. AnimationSystem (extends BaseSystem)

**Purpose:** Processes sprite animations.

**Entity Requirements:**
- Requires an AnimationComponent

**Key Functions:**
- Updates animation frames
- Manages animation state transitions
- Controls animation speed and effects

**Design Validation:** Ensures smooth visual feedback that enhances gameplay feel

### 9. AudioSystem (extends BaseSystem)

**Purpose:** Handles sound effects and music.

**Entity Requirements:**
- Requires an AudioComponent for spatial audio

**Key Functions:**
- Plays and manages sound effects
- Controls music playback and transitions
- Handles spatial audio positioning
- Manages volume and audio settings

**Design Validation:** Creates an immersive audio experience that complements the gameplay

### 10. DialogueSystem (extends BaseSystem)

**Purpose:** Manages in-game dialogue and text.

**Entity Requirements:**
- Requires a DialogueComponent

**Key Functions:**
- Controls dialogue progression
- Manages conversation trees
- Handles text display and formatting

**Design Validation:** Supports narrative immersion and character development

## System Interaction Flow

Systems interact in a specific order to ensure proper game functionality:

1. **Input Processing**: InputSystem processes raw input first
2. **AI Decision Making**: AISystem determines NPC behaviors
3. **Movement & Physics**: MovementSystem and PhysicsSystem update positions
4. **Game Logic**: CombatSystem, AetherSystem process gameplay effects
5. **Visual & Feedback**: AnimationSystem, RenderSystem, AudioSystem provide feedback

This processing order ensures that player input is handled immediately, followed by game logic, and finally feedback systems, creating a responsive and coherent game experience.

## Related Technical Documents

- [SystemArchitecture.TDD](TDD/SystemArchitecture.TDD.md) - System architecture implementation
- [PlayerCharacter.TDD](TDD/PlayerCharacter.TDD.md) - Player-specific systems
- [CombatSystem.TDD](TDD/CombatSystem.TDD.md) - Combat system details
- [AetherSystem.TDD](TDD/AetherSystem.TDD.md) - Energy system implementation

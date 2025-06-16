# Core Gameplay Loop
*Last Updated: May 23, 2025*

This document defines the fundamental gameplay loop of Adventure Jumper, outlining how players interact with the game world and progress through the experience. The core loop creates a satisfying rhythm of exploration, challenge, and reward.

> **Related Documents:**
> - [System Architecture TDD](../../02_Technical_Design/TDD/SystemArchitecture.TDD.md) - Technical implementation details
> - [Character Design](../Characters/01-main-character.md) - Player character abilities and progression
> - [World Design](../Worlds/) - Environmental contexts and challenges

## Primary Gameplay Loop

### 1. Exploration & Discovery
- **Movement & Traversal**
  - Fluid platforming mechanics (jump, dash, wall-run)
  - World-specific movement abilities (vine-swinging, heat-gliding, etc.)
  - Environmental interaction points
  - *Technical implementation: [PlayerCharacter.TDD](../../02_Technical_Design/TDD/PlayerCharacter.TDD.md)*

- **World Navigation**
  - Open-ended level design with multiple paths
  - Hidden areas and secrets
  - Visual cues and landmarks for orientation
  - *World examples: [Luminara](../Worlds/01-luminara-hub.md), [Verdant Canopy](../Worlds/02-verdant-canopy.md), [Forge Peaks](../Worlds/03-forge-peaks.md)*

### 2. Challenge & Combat
- **Encounters**
  - Dynamic enemy placement
  - Environmental hazards
  - Puzzle elements
  - *Enemy details: [Enemies of Aetheris](../Characters/03-enemies.md)*

- **Combat System**
  - Light/Heavy attack combos
  - Dodge/parry mechanics
  - Special abilities tied to Aether energy
  - *Technical implementation: [CombatSystem.TDD](../../02_Technical_Design/TDD/CombatSystem.TDD.md)*

### 3. Progression & Rewards
- **Character Growth**
  - Ability upgrades and new movement options
  - Combat skill improvements
  - Stat enhancements (health, Aether capacity)
  - *Character details: [Kael - The Hero](../Characters/01-main-character.md#progression)*

- **Collection & Discovery**
  - Lore fragments and world-building elements
  - Cosmetic unlocks
  - Completion tracking (percentage, achievements)
  - *Lore background: [World of Aetheris](../Lore/01-world-overview.md)*

## Secondary Loops

### Resource Management Loop
1. **Collection**: Gather Aether fragments throughout the world
2. **Expenditure**: Use Aether for special abilities and traversal
3. **Strategy**: Make decisions about when/where to use limited resources
4. **Replenishment**: Find ways to restore Aether through exploration/combat
   - *Technical implementation: [AetherSystem.TDD](../../02_Technical_Design/TDD/AetherSystem.TDD.md)*

### Metroidvania Progression Loop
1. **Encounter Obstacle**: Come across an inaccessible area or challenge
2. **Set Goal**: Mark location mentally (or on map) for future return
3. **Obtain New Ability**: Gain a new power through story progression or exploration
4. **Return & Overcome**: Use new abilities to access previously impossible areas
5. **Reward**: Discover new content, story elements, or upgrades
   - *World connections: [World Connections](../Worlds/00-World-Connections.md#progression-flow)*

### Death & Respawn Loop
1. **Defeat**: Player is defeated by enemies or environmental hazards
2. **Penalty**: Lose collected resources since last checkpoint
3. **Learning**: Understand what went wrong
4. **Respawn**: Return to last checkpoint with gained knowledge
5. **Retry**: Approach the challenge with new strategy
   - *Technical implementation: [SaveSystem.TDD](../../02_Technical_Design/TDD/SaveSystem.TDD.md)*

## Moment-to-Moment Gameplay

### Core Combat Interactions
- Fast-paced, skill-based combat requiring timing and positioning
- Combination of melee, ranged, and ability-based attacks
- Reactive enemies that adapt to player strategies
- Environmental elements that can be used in combat
- *Technical details: [CombatSystem.TDD](../../02_Technical_Design/TDD/CombatSystem.TDD.md)*

### Platforming & Movement
- Precise controls for intricate platforming sequences
- Risk/reward shortcuts requiring advanced techniques
- Movement abilities that interact with world-specific elements
- *Technical details: [GravitySystem.TDD](../../02_Technical_Design/TDD/GravitySystem.TDD.md)*

### Puzzle Solving
- Environmental puzzles based on Aether manipulation
- Observational challenges requiring world interaction
- Time-based challenges using Kael's abilities
- *Technical details: [TimeManipulation.TDD](../../02_Technical_Design/TDD/TimeManipulation.TDD.md)*

## Player Experience Goals
- Foster a sense of mastery through skill-based gameplay
- Create moments of wonder through environmental storytelling
- Balance challenge and progression to maintain engagement
- Reward exploration with meaningful discoveries
- *UI/UX considerations: [UI/UX Design](../UI_UX_Design/README.md)*

## Related Documents
- [Combat System Design](CombatSystem_Design.md)
- [Aether System Design](AetherSystem_Design.md)
- [World Connections](../Worlds/00-World-Connections.md)
- [PlayerCharacter.TDD](../../02_Technical_Design/TDD/PlayerCharacter.TDD.md)

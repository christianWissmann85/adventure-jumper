# The Forge Peaks

*This document describes the Forge Peaks world in Adventure Jumper. For connections to other worlds, see [World Connections](00-World-Connections.md). For technical implementation, see [LevelManagement.TDD](../../02_Technical_Design/TDD/LevelManagement.TDD.md).*

## Overview
A chain of volcanic islands where the air shimmers with heat and the ground trembles with constant eruptions. Home to the Stoneborn dwarves and their massive forges, these floating mountains are rich in rare minerals and ancient technology.

## Visual Theme
- **Primary Colors**: Oranges, reds, and blacks with glowing magma highlights
- **Architecture**: Carved stone and metal, massive forges, piston-driven elevators
- **Lighting**: Glowing lava flows, industrial lighting, sparks from forges
- **Atmosphere**: Haze from forges, falling ash, heat distortion

## Key Locations

### 1. Emberhold Citadel
- **Purpose**: Dwarven capital and industrial center
- **Features**:
  - The Great Forge (massive central foundry)
  - The Gearworks (clockwork district)
  - The Vault (treasury and armory)
- **Key NPCs**: Master Smiths, [Rook "Gearsprocket" Tinker](../Characters/02-allies.md#2-rook-gearsprocket-tinker)
- **Enemies**: [The Forge Guardian](../Characters/03-enemies.md#1-the-forge-guardian), [The Mechanist](../Characters/03-enemies.md#1-the-mechanist)

### 2. The Crucible
- **Purpose**: Volatile mining region
- **Features**:
  - Floating magma lakes
  - Crystal formations
  - Ancient mining equipment
- **Key NPCs**: Crystal Miners, Lava Surfers
- **Enemies**: Magma Elementals, Obsidian Golems

### 3. The Scorch
- **Purpose**: Abandoned industrial wasteland
- **Features**:
  - Broken machinery
  - Toxic vents
  - Hidden research facilities
- **Key NPCs**: Scavengers, Exiled Inventors
- **Enemies**: [Corrupted Drones](../Characters/03-enemies.md#2-corrupted-drones), Malfunctioning Automatons

## Gameplay Elements

### Platforming Challenges
1. **Moving Platforms**
   - Piston-driven lifts
   - Rotating gears
   - Collapsing walkways
   - *Technical implementation: [LevelManagement.TDD](../../02_Technical_Design/TDD/LevelManagement.TDD.md)*

2. **Heat Management**
   - Heat gauge fills in hot areas
   - Cooling stations provide relief
   - Special heat-resistant gear available
   - *Related mechanic: [Core Gameplay Loop](../Mechanics/CoreGameplayLoop.md#resource-management-loop)*

3. **Steam Vents**
   - Launch to great heights
   - Timing-based puzzles
   - Can be redirected with Aether tools
   - *Technical implementation: [GravitySystem.TDD](../../02_Technical_Design/TDD/GravitySystem.TDD.md)*

### Puzzles
1. **Steam Pipe Networks**
   - Redirect steam to power mechanisms
   - Adjust pressure for different effects
   - Timing puzzles with multiple valves

2. **Forge Puzzles**
   - Combine metals with different properties
   - Heat management during crafting
   - Create tools needed for progression

3. **Ancient Dwarven Mechanisms**
   - Decipher runic controls
   - Align gears and cogs
   - Restore power to ancient machines

### Unique Mechanics
- **Heat Surfing**: Ride heat currents for fast traversal
- **Metal Manipulation**: Magnetically control metal objects
- **Forge Crafting**: Create special tools and weapons

## Story Elements

### Narrative Arc
- Discover the source of the corruption affecting the forges
- Aid Rook in recovering lost dwarven technology
- Confront The Mechanist who threatens to destabilize the Forge Peaks
- *Main story connection: [Story Outline](../Narrative/00-story-outline.md)*

### Collectibles
- Ancient dwarven blueprints
- Crystal core samples
- Mechanist's journal pages

### Lore Elements
- History of Stoneborn craftsmanship
- Records of the Great Machinery War
- Theories on Aether-metal interaction
- *World lore: [World Overview](../Lore/01-world-overview.md)*

## Technical Considerations
- Heat distortion visual effects
- Physics for moving platforms and machinery
- Particle systems for forge environments
- *Technical implementation: [LevelManagement.TDD](../../02_Technical_Design/TDD/LevelManagement.TDD.md)*

## Related Documents
- [World Connections](00-World-Connections.md)
- [Luminara Hub](01-luminara-hub.md)
- [Puzzle & Mechanics](06-puzzles-mechanics.md)
- [Rook "Gearsprocket" Character](../Characters/02-allies.md#2-rook-gearsprocket-tinker)

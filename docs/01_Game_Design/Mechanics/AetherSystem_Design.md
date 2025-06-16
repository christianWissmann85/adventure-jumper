# Aether System Design

*This document details the Aether energy system that powers all abilities in Adventure Jumper. For technical implementation details, see [Aether System TDD](../../02_Technical_Design/TDD/AetherSystem.TDD.md).*

## Overview

The Aether system is the core resource mechanic in Adventure Jumper, providing power for both movement and combat abilities. It represents the mystical energy that permeates the world of Aetheris and that Jumpers can harness.

## Core Design Principles

1. **Resource Management** - Players must strategically manage their Aether reserves
2. **Risk vs. Reward** - More powerful abilities consume more Aether
3. **Dynamic Regeneration** - Aether regenerates based on player actions and environment
4. **Progression System** - Aether capacity and efficiency improve throughout the game
5. **Visual Feedback** - Clear representation of Aether levels through UI and character visuals

## Aether Mechanics

### Energy Management

- **Base Pool**: Players begin with a limited Aether capacity
- **Consumption**: Abilities consume varying amounts of Aether
- **Regeneration**: Aether slowly regenerates over time
- **Boosts**: Certain actions accelerate regeneration
  - Combat combos
  - Environmental interactions
  - Collection of Aether fragments
  - Special locations (Aether Wells)

### Collection Methods

1. **Aether Fragments**: Small pickups scattered throughout the world
2. **Aether Wells**: Fixed locations that fully restore Aether
3. **Combat Absorption**: Gain Aether by defeating enemies
4. **Passive Regeneration**: Slow natural recovery

### Aether States

1. **Full**: Maximum capacity, abilities function optimally
2. **Moderate**: Normal operation, standard regeneration
3. **Low**: Visual warnings, some abilities limited
4. **Depleted**: Temporary inability to use Aether abilities

## Ability Integration

### Movement Abilities

| Ability | Aether Cost | Effect | Unlock Requirement |
|---------|-------------|--------|-------------------|
| Aether Jump | Low | Double jump with height boost | Tutorial completion |
| Aether Dash | Medium | Rapid horizontal movement | Luminara exploration |
| Aether Glide | Continuous | Slow descent with horizontal control | Verdant Canopy artifact |
| Aether Grapple | Medium | Hook and pull toward specific points | Forge Peaks upgrade |
| Aether Teleport | High | Short-range teleportation | Celestial Archive upgrade |

### Combat Abilities

| Ability | Aether Cost | Effect | Unlock Requirement |
|---------|-------------|--------|-------------------|
| Aether Strike | Medium | Charged attack with area damage | Tutorial completion |
| Aether Shield | High | Temporary damage barrier | Luminara trial |
| Aether Burst | Very High | Explosive area effect | Forge Peaks artifact |
| Aether Blade | Continuous | Enhanced weapon damage | Celestial Archive trial |
| Aether Storm | Max | Ultimate ability, massive damage | Void's Edge artifact |

*For detailed combat implementation, see [Combat System Design](CombatSystem_Design.md).*

## Progression System

### Capacity Upgrades

- **Aether Vessels**: Collectible items that permanently increase maximum capacity
- **Aether Attunement**: Skill tree upgrades that expand capacity
- **Shrine Blessings**: Quest rewards that boost capacity

### Efficiency Upgrades

- **Regeneration Rate**: Faster natural Aether recovery
- **Consumption Reduction**: Abilities cost less Aether
- **Overflow Capacity**: Temporary extra capacity

### Mastery Abilities

- **Aether Conversion**: Convert health to Aether in emergencies
- **Aether Siphon**: Steal Aether from certain enemies
- **Aether Resonance**: Chain Aether effects between targets

## World Integration

### Aether Pools

Special locations in each world contain concentrated Aether energy:

- **Luminara**: Crystal Spire - Primary Aether Well
- **Verdant Canopy**: Ancient Grove - Natural Aether springs
- **Forge Peaks**: Molten Core - Aether-infused magma
- **Celestial Archive**: Star Chamber - Cosmic Aether concentration
- **Void's Edge**: Fracture Points - Unstable Aether leaks

### Environmental Interactions

1. **Aether Currents**: Navigate through flowing Aether streams
2. **Aether Crystals**: Destructible objects that release Aether
3. **Aether Locks**: Environmental puzzles requiring specific Aether types
4. **Aether Corruption**: Areas where Aether is tainted and dangerous

## Visual and Audio Design

### Visual Representation

- **Player Character**: Glowing veins/tattoos that intensify with Aether levels
- **Environment**: Particles and flows showing Aether concentration
- **UI Element**: [Aether gauge](../UI_UX_Design/HUD_Layouts.md#aether-energy) in player HUD

### Audio Design

- **Charging**: Rising tone as Aether builds
- **Release**: Satisfying burst when Aether is used
- **Low Warning**: Subtle alert when Aether is critically low
- **Regeneration**: Gentle hum during accelerated regeneration

## Balance Considerations

- Aether cost balances power of abilities
- Regeneration rate prevents ability spamming
- Strategic placement of Aether Wells creates exploration incentives
- Difficulty scaling adjusts Aether requirements throughout the game

## Technical Implementation Notes

For details on the technical implementation of the Aether system:

- [Aether System TDD](../../02_Technical_Design/TDD/AetherSystem.TDD.md) - Technical architecture
- [Player Character TDD](../../02_Technical_Design/TDD/PlayerCharacter.TDD.md) - Character integration
- [UI System TDD](../../02_Technical_Design/TDD/UISystem.TDD.md) - Visual representation
- [HUD Layouts](../UI_UX_Design/HUD_Layouts.md) - Interface display

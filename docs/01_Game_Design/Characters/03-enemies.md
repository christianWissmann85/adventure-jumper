# Enemies of Aetheris
*Last Updated: May 23, 2025*

This document details the hostile entities encountered throughout Adventure Jumper, categorized by type and threat level. Each entry includes appearance, behavior patterns, and combat abilities.

> **Related Documents:**
> - [Main Character](01-main-character.md) - Protagonist abilities and combat skills
> - [World Connections](../Worlds/00-World-Connections.md) - Enemy distribution across worlds
> - [EnemyAI.TDD](../../02_Technical_Design/TDD/EnemyAI.TDD.md) - Technical implementation details

## Minor Enemies

### 1. Void Crawlers
- **Description**: Basic foot soldiers of the Voidborn
- **Appearance**:
  - Humanoid shadows with glowing red eyes
  - Form shifts and wavers
  - Claws made of solidified darkness
- **Behavior**:
  - Attack in groups
  - Can phase through walls
  - Weak to Aether-based attacks
- **Abilities**:
  - Shadow Strike: Quick melee attack
  - Phase Shift: Briefly becomes intangible
  - Dark Howl: Stuns nearby players
- **Locations**: Common in [Void's Edge](../Worlds/05-voids-edge.md), rare in other realms

### 2. Corrupted Drones
- **Description**: Mechanical constructs overtaken by Void energy
- **Appearance**:
  - Rusted metal frames with glowing purple cracks
  - Floating spherical cores
  - Jagged, broken edges
- **Behavior**:
  - Hover erratically
  - Explode when destroyed
  - Swarm in large numbers
- **Abilities**:
  - Energy Bolt: Fires a slow-moving projectile
  - Overload: Charges up before exploding
  - Shield Link: Can connect to other drones for protection
- **Locations**: Common in [Forge Peaks](../Worlds/03-forge-peaks.md), especially The Scorch area

### 3. Aether Wraiths
- **Description**: Twisted spirits of fallen Jumpers
- **Appearance**:
  - Translucent, ghostly figures
  - Tattered Jumper cloaks
  - Faces obscured by shifting mists
- **Behavior**:
  - Haunt ancient battlefields
  - Drawn to Aether-rich locations
  - Whisper fragments of their past lives
- **Abilities**:
  - Soul Siphon: Drains Aether energy
  - Phantom Strike: Teleports behind the player
  - Echoing Wail: Disorients and confuses
- **Locations**: Found throughout all realms, often near [Aether pools](../../02_Technical_Design/TDD/AetherSystem.TDD.md)

## Mini-Bosses

### 1. The Forge Guardian
- **Description**: Ancient stone construct infused with liquid metal
- **Appearance**:
  - Massive humanoid made of volcanic rock
  - Joints flow with molten metal
  - Runes carved into its surface glow when attacking
- **Behavior**:
  - Guards the entrance to The Great Forge
  - Slow but devastatingly powerful
  - Heat increases as battle progresses
- **Abilities**:
  - Magma Slam: Area-of-effect ground attack
  - Heat Wave: Temperature rises, damaging over time
  - Volcanic Shield: Temporary invulnerability
- **Locations**: [Forge Peaks](../Worlds/03-forge-peaks.md), Emberhold Citadel

### 2. Archivist Spectre
- **Description**: A corrupted Curator driven mad by forbidden knowledge
- **Appearance**:
  - Elongated figure wrapped in ghostly scrolls
  - Multiple arms holding ancient tomes
  - Words constantly flow across its form
- **Behavior**:
  - Summons book constructs to fight for it
  - Recites prophecies during combat
  - Creates illusions and false platforms
- **Abilities**:
  - Knowledge Torrent: Barrage of pages
  - Reality Shift: Changes environment temporarily
  - Memory Drain: Disables one of Kael's abilities temporarily
- **Locations**: [Celestial Archive](../Worlds/04-celestial-archive.md), Chronology Wing

### 3. The Hollow King
- **Description**: Former ruler of a fallen kingdom, now a vessel for the Void
- **Appearance**:
  - Tall, regal figure with a crown of shadows
  - Armor cracked and leaking darkness
  - Empty void where face should be
- **Behavior**:
  - Fights with corrupted royal weapons
  - Summons shadow knights
  - Recites broken memories of his kingdom
- **Abilities**:
  - Sovereign Slash: Wide-range sword attack
  - Royal Decree: Commands shadow knights to charge
  - Void Consumption: Drains health to restore his own
- **Locations**: [Void's Edge](../Worlds/05-voids-edge.md), The Fracture Point

## Main Bosses

### 1. The Mechanist
- **Description**: Brilliant but mad inventor who has fused with his creations
- **Appearance**:
  - Half-human, half-machine
  - Multiple mechanical arms with different tools
  - Steam-powered exoskeleton
- **Boss Arena**: The heart of Emberhold's Great Forge
- **Fight Phases**:
  1. **Construction Phase**: Builds weapons and minions
  2. **Assault Phase**: Direct attacks with mechanical appendages
  3. **Desperation Phase**: Merges with giant mech suit
- **Narrative Significance**: Represents the danger of progress without wisdom
- **Relationship to Story**: Was once [Rook's](02-allies.md#2-rook-gearsprocket-tinker) mentor before madness consumed him

### 2. The Living Codex
- **Description**: A sentient collection of all forbidden knowledge
- **Appearance**:
  - Constantly shifting form made of pages and bindings
  - Eyes appear on pages throughout its body
  - Ink flows like blood through its form
- **Boss Arena**: Reality-warping space in the Archive's depths
- **Fight Phases**:
  1. **Knowledge Phase**: Tests Kael with puzzles and riddles
  2. **Corruption Phase**: Attacks with forbidden magic
  3. **Revelation Phase**: Reveals a terrible truth about Aetheris
- **Narrative Significance**: Guards the secret of the Great Fracture
- **Relationship to Story**: Contains the history that [Elder Nyssa](02-allies.md#4-elder-nyssa) has hidden from Kael

## Implementation Details

### Technical Reference
The enemy systems are implemented through:
- [Enemy AI System](../../02_Technical_Design/TDD/EnemyAI.TDD.md) - Combat behaviors and patterns
- [Combat System](../../02_Technical_Design/TDD/CombatSystem.TDD.md) - Enemy attack mechanics
- [Difficulty Scaling](../../02_Technical_Design/TDD/DifficultySystem.TDD.md) - Enemy progression across game areas

### Narrative Integration
Enemies are integrated into the story through:
- [Main Story Arc](../Narrative/00-story-outline.md) - Enemy relevance to narrative
- [World Connections](../Worlds/00-World-Connections.md) - Enemy distribution across realms

### Design Guidelines
For consistent enemy design, refer to:
- [Art Style Guide](../../05_Style_Guides/ArtStyle.md) - Visual design standards for enemies
- [Enemy Animation Guidelines](../../05_Style_Guides/AnimationStyle.md) - Movement and attack animation standards

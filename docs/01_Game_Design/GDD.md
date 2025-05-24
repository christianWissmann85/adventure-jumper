# Adventure Jumper - Game Design Document (GDD)
*Last Updated: May 23, 2025*

## Table of Contents
1. [Game Overview](#game-overview)
2. [Core Experience](#core-experience)
3. [Game World](#game-world)
4. [Gameplay](#gameplay)
5. [Progression](#progression)
6. [Technical Specifications](#technical-specifications)
7. [Development Roadmap](#development-roadmap)
8. [Appendices](#appendices)

## Game Overview

### Project Information
> **Project Status**: 🟢 Active Development  
> **Current Version**: 0.1.0  
> **Lead Developer**: Cascade  
> **Document Owner**: Chris

### Concept Statement
Adventure Jumper is a 2.5D action-platformer with Metroidvania elements, set in the fractured world of Aetheris. Players control Kael, a newly awakened Jumper, as they explore floating islands, uncover ancient secrets, and master Aether-based abilities to prevent the complete collapse of reality.

### Target Audience
- **Primary**: Players aged 14-35 who enjoy action-platformers and exploration games
- **Secondary**: Fans of narrative-driven experiences and Metroidvania-style progression
- **Platforms**: PC, Nintendo Switch, PlayStation 5, Xbox Series X|S
- **ESRB Rating**: T for Teen (Fantasy Violence, Mild Language, Suggestive Themes)

### Key Features
1. **Fluid Movement System**: Intuitive controls for precise platforming and combat
2. **Dynamic Combat**: Fast-paced battles combining melee, ranged, and Aether abilities
3. **Expansive World**: Five unique biomes, each with distinct mechanics and challenges
4. **Deep Progression**: Unlockable abilities that open new areas and gameplay options
5. **Engaging Narrative**: A rich story about identity, sacrifice, and the nature of reality

## Core Experience

### Player Experience Goals
- **Empowerment**: Mastery of movement and combat mechanics
- **Discovery**: Rewarding exploration and world-building
- **Challenge**: Increasing difficulty with fair but demanding gameplay
- **Immersion**: A living, breathing world that reacts to the player's actions

### Unique Selling Points
- **Aether System**: Dynamic energy management that powers both movement and combat
- **World Shaping**: Player choices affect the environment and story outcomes
- **Time Manipulation**: Unique time-based mechanics that affect puzzles and combat

## Game World

### Setting
Aetheris, a world shattered by a cataclysmic event, now exists as floating islands suspended in an endless sky. The remnants of ancient civilizations dot the landscape, while the mysterious Aether energy flows through everything.

### Key Locations
1. **[Luminara](Worlds/01-luminara-hub.md)** - The central hub city (Tutorial & Prologue)
2. **[Verdant Canopy](Worlds/02-verdant-canopy.md)** - Ancient forest realm (Act 1)
3. **[Forge Peaks](Worlds/03-forge-peaks.md)** - Volcanic industrial wasteland (Act 2)
4. **[Celestial Archive](Worlds/04-celestial-archive.md)** - Reality-bending library (Act 3)
5. **[Void's Edge](Worlds/05-voids-edge.md)** - The crumbling border of reality (Act 4)

> **Detailed Documentation:**
> - [World: World Connections](Worlds/00-World-Connections.md) - Overview of all worlds
> - [World: All Environments](Worlds/) - Detailed world design documents
> - [Character: Kael](Characters/01-main-character.md) - Protagonist details
> - [Characters: Allies](Characters/02-allies.md) - Supporting characters
> - [Characters: Enemies](Characters/03-enemies.md) - Antagonists and challenges
> - [Narrative: Complete Story](Narrative/00-story-outline.md) - Full narrative arc

### Lore & Story
The rich history of Aetheris and the Great Fracture provides context for the player's journey. The overarching narrative involves uncovering the truth behind the world's shattering and preventing its total collapse.

*For complete narrative and lore documentation, see [Narrative Design](Narrative/) and [Lore Overview](Lore/)*

## Gameplay

### Core Gameplay Loop
1. **Explore** new areas and discover secrets
2. **Fight** enemies using melee, ranged, and Aether abilities
3. **Solve** environmental puzzles to progress
4. **Collect** resources and upgrades
5. **Unlock** new abilities that open previously inaccessible areas
6. **Master** advanced techniques to overcome greater challenges

*For detailed gameplay mechanics, see [Core Gameplay Loop](./Mechanics/CoreGameplayLoop.md)*

### Game Systems
The game features interconnected systems for combat, movement, and Aether manipulation that work together to create engaging gameplay.

*For detailed mechanics documentation, see [Mechanics](./Mechanics/)*  
*For technical implementation, see [Technical Design Documents](../02_Technical_Design/TDD/)*

### Puzzles & Challenges
Each world features unique environmental puzzles that leverage both the player's abilities and the region's mechanics.

*For puzzle details, see [Puzzles & Mechanics](Worlds/06-puzzles-mechanics.md)*

## Progression

### Character & World Development
Players unlock new abilities and access to previously inaccessible areas as they progress through the story and master their skills.

*For detailed progression systems, see [Character Development](Characters/) and [World Progression](Worlds/00-World-Connections.md)*

## Technical Specifications

### System Requirements
- Minimum and recommended specifications for each platform
- Performance targets and optimization goals

*For complete technical specifications, see [Technical Design Documentation](../02_Technical_Design/README.md)*

## UI/UX Design

### User Interface
The game features a minimalist, diegetic UI that integrates seamlessly with the world.

*For UI/UX details, see [UI/UX Design Documents](UI_UX_Design/README.md)*  
*For technical implementation, see [UI System TDD](../02_Technical_Design/TDD/UISystem.TDD.md)*

## Art & Audio Direction

### Visual Style
Adventure Jumper features a vibrant, stylized aesthetic that balances realism with readability.

*For art direction details, see [Art Style Guide](../05_Style_Guides/ArtStyle.md)*

### Audio Design
The game's soundscape uses dynamic music and spatial audio to enhance immersion.

*For audio design details, see [Audio Style Guide](../05_Style_Guides/AudioStyle.md)*  
*For technical implementation, see [Audio System TDD](../02_Technical_Design/TDD/AudioSystem.TDD.md)*

## Development

### Current Sprint: Foundation (Weeks 1-3)
**Goal:** Establish core game mechanics and basic architecture

#### Key Deliverables:
- [ ] Player movement and physics
- [ ] Basic collision detection
- [ ] Simple level loading
- [ ] Camera following
- [ ] Basic game loop implementation

#### Progress Tracking:
- **Code Quality**: 🟡 In progress
- **Art Assets**: 🟢 On track
- **Audio**: 🟠 Not started
- **Documentation**: 🟡 In progress
- **Performance**: 🟢 Meeting targets

### Development Timeline
1. **Phase 1: Foundation** (Weeks 1-3)
   - Core mechanics
   - Basic level structure
   - Essential systems

2. **Phase 2: Gameplay** (Weeks 4-7)
   - Enemies and AI
   - Power-ups
   - Level design

3. **Phase 3: Polish** (Weeks 8-10)
   - Visual effects
   - Audio implementation
   - UI/UX refinement

4. **Phase 4: Release** (Weeks 11-12)
   - Testing and bug fixing
   - Performance optimization
   - Launch preparation

*For complete development roadmap, see [Project Roadmap](../04_Project_Management/Roadmap.md)*

## Related Documentation

### Project Management
- [Task Tracking](../04_Project_Management/TaskTracking.md) - Central task board
- [Development Roadmap](../04_Project_Management/Roadmap.md) - Timeline
- [Testing Strategy](../03_Development_Process/TestingStrategy.md) - QA approach

### Technical Specifications
- [Technical Architecture](../02_Technical_Design/Architecture.md)
- [System Design Documents](../02_Technical_Design/TDD/)

### Style Guides
- [Art Style Guide](../05_Style_Guides/ArtStyle.md)
- [Audio Style Guide](../05_Style_Guides/AudioStyle.md)
- [UI/UX Style Guide](../05_Style_Guides/UI_UX_Style.md)

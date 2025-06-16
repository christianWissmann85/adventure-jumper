# Combat System Design

*This document details the combat mechanics and systems in Adventure Jumper. For technical implementation details, see [Combat System TDD](../../02_Technical_Design/TDD/CombatSystem.TDD.md).*

## Core Combat Philosophy

Adventure Jumper's combat system balances fluid movement with strategic decision-making. It focuses on:

1. **Momentum-Based Combat** - Movement and positioning affect attack power and options
2. **Aerial Superiority** - Rewarding players for maintaining airtime during combat
3. **Aether Integration** - Using the world's magical energy to enhance combat abilities
4. **Progressive Mastery** - Simple to learn, difficult to master, with techniques that build upon one another
5. **Rhythmic Engagement** - Combat with a sense of flow and timing rather than button mashing

## Combat Mechanics

### Basic Actions

- **Light Attack** - Quick strikes with minimal recovery time
- **Heavy Attack** - Powerful but slower attacks with more recovery
- **Aerial Attack** - Special attacks only available while airborne
- **Dash/Dodge** - Quick evasive maneuver with brief invincibility frames
- **Block/Parry** - Defensive action that can lead to counterattack opportunities

### Combo System

The combo system tracks consecutive hits and rewards players with:

- **Damage Multipliers** - Increasing damage with higher combo counts
- **Aether Generation** - Building energy for special moves
- **Finisher Opportunities** - Special moves that unlock at combo thresholds

*The HUD displays combo information through the [Combo Counter](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md#combo-counter).*

### Aether Abilities

Combat is enhanced through Aether-infused special abilities:

- **Aether Strike** - Charged attack with area effect
- **Aether Shield** - Temporary protective barrier
- **Aether Dash** - Enhanced movement with longer invincibility
- **Aether Burst** - Energy explosion affecting nearby enemies

*Aether levels are tracked through the [Aether Energy display](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md#aether-energy) in the HUD.*

## Enemy Combat Design

### Enemy Categories

- **Standard Enemies** - Basic foes with predictable attack patterns
- **Elite Enemies** - Stronger variants with enhanced abilities
- **Mini-Bosses** - Unique enemies with custom mechanics
- **World Bosses** - Major encounters with multiple phases and special mechanics

*For specific enemy designs, see the [Enemies documentation](../Characters/03-enemies.md).*

### Enemy Behaviors

Enemy combat behaviors follow these principles:

- **Telegraphed Attacks** - Clear wind-up animations for major attacks
- **Vulnerability Windows** - Strategic openings after specific actions
- **Adaptive Difficulty** - Enemies respond to player strategies
- **Environmental Integration** - Enemies utilize their surroundings

## Combat Progression

### Skill Unlocks

Combat abilities unlock progressively through:

- **Core Progression** - Fundamental abilities unlocked through story advancement
- **Optional Discoveries** - Hidden techniques found through exploration
- **Mastery Challenges** - Advanced skills unlocked by demonstrating proficiency

### Upgrade Paths

Players can enhance combat abilities through:

- **Aether Attunement** - Enhancing Aether-based combat abilities
- **Physical Training** - Improving basic combat stats and techniques
- **Specialized Styles** - Focusing on specific combat approaches

## World-Specific Combat Elements

Each world introduces unique combat elements:

- **Luminara** - Basic combat training with tutorial elements
- **Verdant Canopy** - Environmental hazards and swinging combat mechanics
- **Forge Peaks** - Heat management and metal-based enemies
- **Celestial Archive** - Gravity manipulation affecting combat
- **Void's Edge** - Reality distortions creating combat puzzles

## Combat Feedback Systems

### Visual Feedback

- **Hit Effects** - Particles and animations on successful strikes
- **Enemy Reactions** - Stagger and recoil animations
- **Environmental Impacts** - Destructible elements and surface reactions
- **Damage Numbers** - Optional visual indicators of damage dealt

*These visual elements are displayed through the [HUD damage indicators](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md#damage-numbers).*

### Audio Feedback

- **Impact Sounds** - Varied by weapon, enemy type, and surface
- **Combat Voice Lines** - Character reactions to battle events
- **Musical Integration** - Dynamic music that responds to combat intensity
- **Positional Audio** - 3D audio cues for off-screen threats

## Combat Accessibility

- **Difficulty Options** - Multiple settings affecting enemy health, damage, and timing windows
- **Assist Features** - Optional targeting assistance and timing helpers
- **Practice Mode** - Safe environment to learn combat techniques
- **Visual Alternatives** - Options for screen shake, flash effects, and motion

## Technical Implementation Notes

For detailed technical implementation of the combat system:

- [Combat System TDD](../../02_Technical_Design/TDD/CombatSystem.TDD.md) - Technical architecture
- [Player Character TDD](../../02_Technical_Design/TDD/PlayerCharacter.TDD.md) - Character combat capabilities
- [Enemy AI TDD](../../02_Technical_Design/TDD/EnemyAI.TDD.md) - Enemy combat behaviors
- [HUD Layouts](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md) - Combat interface elements

# HUD Layouts

*This document details the in-game Heads-Up Display (HUD) elements for Adventure Jumper. For technical implementation details, see [UI System TDD](../../02_Technical_Design/TDD/UISystem.TDD.md). For visual style guidelines, see [UI/UX Style Guide](../../05_Style_Guides/UI_UX_Style.md).*

## HUD Design Overview

The Adventure Jumper HUD follows our [design philosophy](DesignPhilosophy.md) of minimalism, diegetic integration, and responsive feedback. Core gameplay information is presented through unobtrusive elements that adapt based on the player's current situation.

### Key Design Principles

1. **Contextual Visibility** - HUD elements fade in/out based on relevance
2. **Spatial Awareness** - Placement avoids obscuring critical gameplay areas
3. **Thematic Integration** - HUD elements reflect the current world's aesthetic
4. **Scalable Information** - Details expand when relevant and contract when not needed

## Core HUD Elements

### Health System

**Location:** Top-left corner  
**Default State:** Three heart containers with fill level  
**Active State:** Hearts pulse when damaged, flash when healing

#### Visual Variations
- **Standard Hearts**: Basic health visualization
- **Enhanced Hearts**: After health upgrades, with golden borders
- **Critical State**: Hearts pulse red when health is low (<25%)

#### Technical Implementation
*For health system logic, see [Health System TDD](../../02_Technical_Design/TDD/HealthSystem.TDD.md).*

### Aether Energy

**Location:** Top-left corner, below health  
**Default State:** Semi-circular gauge with glow effect  
**Active State:** Particles emit when charging/discharging

#### Visual Variations
- **Charged**: Bright cyan glow at maximum capacity
- **Depleting**: Pulsating effect when actively using Aether abilities
- **Recharging**: Flowing particle effect when regenerating
- **Empty**: Dimmed with "cracked" visual effect

#### Technical Implementation
*For Aether mechanics, see [Aether System TDD](../../02_Technical_Design/TDD/AetherSystem.TDD.md).*

### Ability Quick Reference

**Location:** Bottom-right corner  
**Default State:** Small icons showing equipped abilities and bindings  
**Active State:** Highlighted when usable, dimmed when on cooldown

#### Visual Variations
- **Available**: Standard icon with button prompt
- **Selected**: Highlighted with glow effect
- **Cooldown**: Circular progress indicator showing recharge time
- **Unavailable**: Grayed out when conditions aren't met (e.g., insufficient Aether)

#### Technical Implementation
*For ability system details, see [Ability System TDD](../../02_Technical_Design/TDD/AbilitySystem.TDD.md).*

### Contextual Actions

**Location:** Bottom-center  
**Default State:** Hidden  
**Active State:** Appears when interactive objects are in range

#### Visual Variations
- **Basic Interaction**: Simple button prompt with icon
- **Complex Interaction**: Expanded prompt with brief description
- **Timed Interaction**: Circular progress indicator around prompt
- **Locked Interaction**: Prompt with lock icon and requirements

#### Technical Implementation
*For interaction system details, see [Interaction System TDD](../../02_Technical_Design/TDD/InteractionSystem.TDD.md).*

### Minimap

**Location:** Top-right corner  
**Default State:** Small circular map showing immediate surroundings  
**Active State:** Can be expanded temporarily with directional input

#### Visual Variations
- **Standard View**: Local area with player in center
- **Expanded View**: Larger area shown when prompted
- **Location Ping**: Pulse effect for nearby points of interest
- **Objective Marker**: Animated arrow pointing to current objective

#### Technical Implementation
*For minimap system details, see [Map System TDD](../../02_Technical_Design/TDD/MapSystem.TDD.md).*

## Combat-Specific HUD Elements

### Enemy Health Indicators

**Location:** Above enemy characters  
**Default State:** Appears when enemy is engaged  
**Active State:** Depletes with damage, disappears when defeated

#### Visual Variations
- **Standard Enemy**: Simple bar
- **Elite Enemy**: Bar with decorated frame and armor indicator
- **Boss Enemy**: Complex multi-segment bar with phase indicators

### Combo Counter

**Location:** Mid-right side  
**Default State:** Hidden  
**Active State:** Appears during combat, shows current combo count and grade

#### Visual Variations
- **Building**: Incrementing number with small particle effects
- **Sustained**: Steady glow effect
- **Expiring**: Flashing when combo timer is low
- **Broken**: Shatter effect when combo ends

### Damage Numbers

**Location:** Near point of impact  
**Default State:** Hidden  
**Active State:** Pops up with each hit, varies in size based on damage amount

#### Visual Variations
- **Normal Damage**: White numbers
- **Critical Hit**: Larger yellow numbers with burst effect
- **Elemental Damage**: Color-coded based on element type
- **Healing**: Green numbers with soft glow

## Traversal-Specific HUD Elements

### Stamina Meter

**Location:** Bottom-center, above action prompts  
**Default State:** Hidden  
**Active State:** Appears when climbing, dashing, or gliding

#### Visual Variations
- **Charging**: Fill effect when regenerating
- **Depleting**: Decreasing with continuous use
- **Critical**: Flashing when nearly empty

### Height Indicator

**Location:** Right edge of screen  
**Default State:** Hidden  
**Active State:** Appears during significant vertical traversal or falling

#### Visual Variations
- **Safe Height**: Blue indicator
- **Warning Height**: Yellow indicator when fall damage possible
- **Danger Height**: Red indicator when fall damage certain

## Notification Elements

### Quest Updates

**Location:** Top-center  
**Default State:** Hidden  
**Active State:** Slides in when quest status changes, disappears after delay

#### Visual Variations
- **New Quest**: Gold highlight with "+" icon
- **Progress Update**: Standard notification
- **Quest Complete**: Celebratory animation with reward display

### Achievement Notifications

**Location:** Bottom-center, above action prompts  
**Default State:** Hidden  
**Active State:** Slides in when achievement unlocked, disappears after delay

#### Visual Variations
- **Standard Achievement**: Trophy icon with name
- **Rare Achievement**: Special visual effects and sound
- **Secret Achievement**: Mystery icon until unlocked

### Item Collection

**Location:** Mid-right side  
**Default State:** Hidden  
**Active State:** Appears briefly when items are collected

#### Visual Variations
- **Common Item**: Simple icon and name
- **Rare Item**: Icon with rarity border and sparkle effect
- **Key Item**: Special highlight effect and persistent indicator

## World-Specific UI Themes

Each world in Adventure Jumper features custom HUD styling that reflects the environment's unique aesthetic while maintaining functional consistency.

### Luminara Hub

**Color Scheme**: Blue and gold  
**Visual Style**: Elegant, light-infused elements with subtle glow  
**Unique Feature**: Aether gauge has sun-like radiance

### Verdant Canopy

**Color Scheme**: Greens and browns  
**Visual Style**: Organic, vine-like frames with leaf motifs  
**Unique Feature**: Growing plant elements in loading indicators

### Forge Peaks

**Color Scheme**: Reds and oranges  
**Visual Style**: Metallic frames with heat distortion effects  
**Unique Feature**: Health icons appear as molten containers

### Celestial Archive

**Color Scheme**: Purples and silver  
**Visual Style**: Constellation-like patterns and star motifs  
**Unique Feature**: Ability icons connect with star-map lines

### Void's Edge

**Color Scheme**: Black and neon cyan  
**Visual Style**: Glitching, unstable frames with distortion  
**Unique Feature**: Random visual artifacts and corruption effects

## HUD Customization Options

Players can customize their HUD experience through the Options menu:

- **HUD Opacity**: Adjust overall transparency
- **HUD Scale**: Change the size of all elements
- **HUD Position**: Adjust screen placement (edge/corner offsets)
- **HUD Layout Presets**: Select from standard configurations
- **Element Toggling**: Enable/disable individual elements
- **Colorblind Modes**: Alternative color schemes for accessibility

## Technical Implementation Notes

The HUD system is designed to be highly efficient with minimal performance impact:

- **Single Draw Call**: Most elements batched into one render pass
- **Adaptive Detail**: LOD system reduces complexity in high-action scenes
- **Memory Efficient**: Shared texture atlases for all HUD elements
- **CPU-Light**: Animation handled via shader effects where possible

*For detailed technical implementation, see [HUD Rendering](../../02_Technical_Design/TDD/UISystem.TDD.md#hud-rendering) in the UI System TDD.*

## Related Documents
- [Design Philosophy](DesignPhilosophy.md) - Core UI/UX principles
- [Menus and Layouts](Menus_Layouts.md) - Menu screen organization
- [UI System TDD](../../02_Technical_Design/TDD/UISystem.TDD.md) - Technical implementation details
- [Combat System Design](../Mechanics/CombatSystem_Design.md) - Combat HUD integration
- [Traversal Mechanics](../Mechanics/TraversalMechanics.md) - Movement-related HUD elements

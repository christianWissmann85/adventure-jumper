# Asset Manifest - Adventure Jumper

_Last Updated: May 31, 2025 - Sprint 3 Asset Loading Enhancement Complete_

## 1. Overview

This document serves as the comprehensive registry and specification for all art assets in Adventure Jumper. It provides exact filenames, technical specifications, implementation details, and production status for every visual asset in the game.

> **Current Status:** As of Sprint 3 completion, the asset loading infrastructure is complete with robust fallback systems. See [Asset Inventory Report](AssetInventoryReport.md) for detailed gap analysis and placeholder generation recommendations.

> **Related Documents:**
>
> - [Asset Inventory Report](AssetInventoryReport.md) - **NEW** - Complete analysis of expected vs. actual assets
> - [Art Style Guide](../../05_Style_Guides/ArtStyle.md) - Overall visual standards and technical specifications
> - [Asset Requirements](AssetRequirements.md) - Technical constraints and platform requirements
> - [Luminara Concept Art](LuminaraConceptArt.md) - Visual design reference
> - [Asset Pipeline](AssetPipeline.md) - Production and delivery workflow

**Purpose**: Ensure consistent asset naming, provide clear implementation specifications, and maintain synchronization between art production and code integration across all sprint microversions.

## 1.1 Current Implementation Status

**Asset Loading Architecture:** ✅ Complete

- AssetManager with coordinated loading
- SpriteLoader with fallback systems
- AudioLoader with comprehensive categorization
- Error handling with placeholder generation

**Asset Gaps:** ❌ Significant (See [Asset Inventory Report](AssetInventoryReport.md))

- Player sprites: 100% complete
- Audio assets: 0% complete (all missing)
- UI assets: ~20% complete
- Enemy sprites: ~10% complete
- Environment assets: ~15% complete

**Placeholder System:** ✅ Robust fallback in place

- Automatic placeholder generation for missing sprites
- Silent audio file generation capability
- Color-coded placeholders for easy identification

## 2. Asset Naming Convention

### 2.1 File Naming Standards

```
[category]_[zone]_[name]_[variant]_[frame].png
```

**Examples:**

- `character_player_idle_01.png`
- `tile_luminara_crystal_platform_01.png`
- `prop_luminara_aether_well_glow_03.png`
- `ui_button_crystal_normal.png`

### 2.2 Directory Structure

```
assets/images/
├── characters/
│   ├── player/
│   ├── npcs/
│   └── enemies/
├── tilesets/
│   ├── luminara/
│   ├── verdant_canopy/
│   ├── forge_peaks/
│   ├── celestial_archive/
│   └── voids_edge/
├── props/
│   ├── luminara/
│   ├── interactive/
│   └── collectibles/
├── effects/
│   ├── aether/
│   ├── combat/
│   └── environmental/
├── ui/
│   ├── hud/
│   ├── menus/
│   └── tutorial/
└── backgrounds/
    ├── luminara/
    └── parallax/
```

## 3. Character Assets

### 3.1 Player Character

**Location**: `assets/images/characters/player/`

#### Base Sprites

| Asset Name  | Filename                    | Dimensions | Frames | Status     | Sprint |
| ----------- | --------------------------- | ---------- | ------ | ---------- | ------ |
| Player Idle | `character_player_idle.png` | 32x32      | 6      | 📋 Planned | 2      |
| Player Run  | `character_player_run.png`  | 32x32      | 8      | 📋 Planned | 2      |
| Player Jump | `character_player_jump.png` | 32x32      | 3      | 📋 Planned | 2      |
| Player Fall | `character_player_fall.png` | 32x32      | 2      | 📋 Planned | 2      |
| Player Land | `character_player_land.png` | 32x32      | 3      | 📋 Planned | 2      |

#### Aether Abilities

| Asset Name    | Filename                             | Dimensions | Frames | Status     | Sprint |
| ------------- | ------------------------------------ | ---------- | ------ | ---------- | ------ |
| Aether Dash   | `character_player_aether_dash.png`   | 32x32      | 4      | 📋 Planned | 6      |
| Aether Pulse  | `character_player_aether_pulse.png`  | 32x32      | 6      | 📋 Planned | 8      |
| Aether Shield | `character_player_aether_shield.png` | 32x32      | 8      | 📋 Planned | 12     |

### 3.2 NPCs

**Location**: `assets/images/characters/npcs/`

#### Mira (Guide NPC)

| Asset Name | Filename                   | Dimensions | Frames | Status     | Sprint |
| ---------- | -------------------------- | ---------- | ------ | ---------- | ------ |
| Mira Idle  | `character_mira_idle.png`  | 32x32      | 6      | 📋 Planned | 3      |
| Mira Talk  | `character_mira_talk.png`  | 32x32      | 4      | 📋 Planned | 3      |
| Mira Point | `character_mira_point.png` | 32x32      | 3      | 📋 Planned | 3      |

#### Keeper Zephyr (Archive Guardian)

| Asset Name     | Filename                       | Dimensions | Frames | Status     | Sprint |
| -------------- | ------------------------------ | ---------- | ------ | ---------- | ------ |
| Zephyr Idle    | `character_zephyr_idle.png`    | 32x32      | 8      | 📋 Planned | 7      |
| Zephyr Gesture | `character_zephyr_gesture.png` | 32x32      | 6      | 📋 Planned | 7      |
| Zephyr Float   | `character_zephyr_float.png`   | 32x32      | 12     | 📋 Planned | 7      |

### 3.3 Enemies

**Location**: `assets/images/characters/enemies/`

#### Verdant Canopy Enemies

| Asset Name           | Filename                         | Dimensions | Frames | Status     | Sprint |
| -------------------- | -------------------------------- | ---------- | ------ | ---------- | ------ |
| Forest Creeper Idle  | `enemy_forest_creeper_idle.png`  | 24x24      | 4      | 📋 Planned | 5      |
| Forest Creeper Walk  | `enemy_forest_creeper_walk.png`  | 24x24      | 6      | 📋 Planned | 5      |
| Thorn Spitter Idle   | `enemy_thorn_spitter_idle.png`   | 32x24      | 6      | 📋 Planned | 7      |
| Thorn Spitter Attack | `enemy_thorn_spitter_attack.png` | 32x24      | 8      | 📋 Planned | 7      |

## 4. Environment Assets

### 4.1 Luminara Hub Tilesets

**Location**: `assets/images/tilesets/luminara/`

#### Crystal Platforms

| Asset Name             | Filename                                   | Dimensions | Variants | Status     | Sprint |
| ---------------------- | ------------------------------------------ | ---------- | -------- | ---------- | ------ |
| Azure Crystal Platform | `tile_luminara_crystal_platform_azure.png` | 16x16      | 5        | 📋 Planned | 3      |
| Teal Crystal Platform  | `tile_luminara_crystal_platform_teal.png`  | 16x16      | 3        | 📋 Planned | 3      |
| Crystal Bridge         | `tile_luminara_crystal_bridge.png`         | 48x16      | 3        | 📋 Planned | 4      |
| Crystal Steps          | `tile_luminara_crystal_steps.png`          | 32x32      | 4        | 📋 Planned | 4      |

#### Architectural Elements

| Asset Name        | Filename                              | Dimensions | Variants | Status     | Sprint |
| ----------------- | ------------------------------------- | ---------- | -------- | ---------- | ------ |
| Master Spire Base | `tile_luminara_master_spire_base.png` | 128x256    | 1        | 📋 Planned | 3      |
| Spire Segment     | `tile_luminara_spire_segment.png`     | 64x64      | 6        | 📋 Planned | 3      |
| Archive Entrance  | `tile_luminara_archive_entrance.png`  | 96x96      | 1        | 📋 Planned | 4      |
| Market Stall      | `tile_luminara_market_stall.png`      | 64x48      | 4        | 📋 Planned | 6      |

### 4.2 Props and Interactive Objects

**Location**: `assets/images/props/luminara/`

#### Interactive Crystals

| Asset Name            | Filename                             | Dimensions | Frames | Status     | Sprint |
| --------------------- | ------------------------------------ | ---------- | ------ | ---------- | ------ |
| Aether Well Core      | `prop_luminara_aether_well_core.png` | 64x64      | 8      | 📋 Planned | 3      |
| Small Aether Crystal  | `prop_luminara_small_crystal.png`    | 16x16      | 6      | 📋 Planned | 3      |
| Medium Aether Crystal | `prop_luminara_medium_crystal.png`   | 32x32      | 8      | 📋 Planned | 3      |
| Large Aether Crystal  | `prop_luminara_large_crystal.png`    | 48x64      | 10     | 📋 Planned | 4      |

#### Luminara Decorations

| Asset Name         | Filename                           | Dimensions | Variants | Status     | Sprint |
| ------------------ | ---------------------------------- | ---------- | -------- | ---------- | ------ |
| Crystal Growth     | `prop_luminara_crystal_growth.png` | 24x32      | 8        | 📋 Planned | 3      |
| Floating Shard     | `prop_luminara_floating_shard.png` | 8x8        | 12       | 📋 Planned | 3      |
| Luminous Moss      | `prop_luminara_luminous_moss.png`  | 16x8       | 5        | 📋 Planned | 4      |
| Inscription Tablet | `prop_luminara_inscription.png`    | 32x24      | 6        | 📋 Planned | 5      |

## 5. Collectibles and Items

### 5.1 Core Collectibles

**Location**: `assets/images/props/collectibles/`

| Asset Name       | Filename                           | Dimensions | Frames | Status     | Sprint |
| ---------------- | ---------------------------------- | ---------- | ------ | ---------- | ------ |
| Aether Shard     | `collectible_aether_shard.png`     | 16x16      | 8      | 📋 Planned | 2      |
| Aether Orb       | `collectible_aether_orb.png`       | 24x24      | 10     | 📋 Planned | 5      |
| Crystal Fragment | `collectible_crystal_fragment.png` | 12x12      | 6      | 📋 Planned | 3      |
| Ancient Rune     | `collectible_ancient_rune.png`     | 20x20      | 12     | 📋 Planned | 7      |

### 5.2 Special Items

| Asset Name      | Filename                   | Dimensions | Frames | Status     | Sprint |
| --------------- | -------------------------- | ---------- | ------ | ---------- | ------ |
| Jumper's Mark   | `item_jumpers_mark.png`    | 32x32      | 1      | 📋 Planned | 4      |
| Memory Fragment | `item_memory_fragment.png` | 24x24      | 8      | 📋 Planned | 8      |
| Void Essence    | `item_void_essence.png`    | 20x20      | 10     | 📋 Planned | 18     |

## 6. Visual Effects

### 6.1 Aether Effects

**Location**: `assets/images/effects/aether/`

| Asset Name        | Filename                       | Dimensions | Frames | Status     | Sprint |
| ----------------- | ------------------------------ | ---------- | ------ | ---------- | ------ |
| Aether Pickup     | `effect_aether_pickup.png`     | 32x32      | 12     | 📋 Planned | 2      |
| Aether Trail      | `effect_aether_trail.png`      | 64x16      | 8      | 📋 Planned | 6      |
| Crystal Resonance | `effect_crystal_resonance.png` | 48x48      | 16     | 📋 Planned | 3      |
| Aether Burst      | `effect_aether_burst.png`      | 64x64      | 10     | 📋 Planned | 6      |

### 6.2 Environmental Effects

**Location**: `assets/images/effects/environmental/`

| Asset Name        | Filename                       | Dimensions | Frames | Status     | Sprint |
| ----------------- | ------------------------------ | ---------- | ------ | ---------- | ------ |
| Dust Motes        | `effect_dust_motes.png`        | 8x8        | 16     | 📋 Planned | 3      |
| Crystal Sparkle   | `effect_crystal_sparkle.png`   | 16x16      | 12     | 📋 Planned | 3      |
| Light Ray         | `effect_light_ray.png`         | 4x64       | 6      | 📋 Planned | 3      |
| Floating Particle | `effect_floating_particle.png` | 4x4        | 20     | 📋 Planned | 3      |

## 7. User Interface Assets

### 7.1 HUD Elements

**Location**: `assets/images/ui/hud/`

| Asset Name           | Filename                      | Dimensions | Status     | Sprint |
| -------------------- | ----------------------------- | ---------- | ---------- | ------ |
| Health Bar Frame     | `ui_health_bar_frame.png`     | 120x16     | 📋 Planned | 2      |
| Health Bar Fill      | `ui_health_bar_fill.png`      | 112x8      | 📋 Planned | 2      |
| Aether Counter Frame | `ui_aether_counter_frame.png` | 80x24      | 📋 Planned | 2      |
| Aether Counter Icon  | `ui_aether_counter_icon.png`  | 16x16      | 📋 Planned | 2      |

### 7.2 Menu Assets

**Location**: `assets/images/ui/menus/`

| Asset Name             | Filename                        | Dimensions | Status     | Sprint |
| ---------------------- | ------------------------------- | ---------- | ---------- | ------ |
| Main Menu Background   | `ui_main_menu_bg.png`           | 320x180    | 📋 Planned | 4      |
| Button Crystal Normal  | `ui_button_crystal_normal.png`  | 64x24      | 📋 Planned | 4      |
| Button Crystal Hover   | `ui_button_crystal_hover.png`   | 64x24      | 📋 Planned | 4      |
| Button Crystal Pressed | `ui_button_crystal_pressed.png` | 64x24      | 📋 Planned | 4      |

### 7.3 Tutorial Assets

**Location**: `assets/images/ui/tutorial/`

| Asset Name         | Filename                    | Dimensions | Status     | Sprint |
| ------------------ | --------------------------- | ---------- | ---------- | ------ |
| Tutorial Arrow     | `ui_tutorial_arrow.png`     | 32x32      | 📋 Planned | 4      |
| Tutorial Highlight | `ui_tutorial_highlight.png` | 48x48      | 📋 Planned | 4      |
| Tutorial Marker    | `ui_tutorial_marker.png`    | 24x24      | 📋 Planned | 4      |
| Key Prompt WASD    | `ui_key_prompt_wasd.png`    | 64x32      | 📋 Planned | 4      |
| Key Prompt Space   | `ui_key_prompt_space.png`   | 48x16      | 📋 Planned | 4      |

## 8. Background and Parallax

### 8.1 Luminara Backgrounds

**Location**: `assets/images/backgrounds/luminara/`

| Asset Name        | Filename                           | Dimensions | Layer | Status     | Sprint |
| ----------------- | ---------------------------------- | ---------- | ----- | ---------- | ------ |
| Sky Gradient      | `bg_luminara_sky.png`              | 320x180    | 0     | 📋 Planned | 3      |
| Distant Crystals  | `bg_luminara_distant_crystals.png` | 640x180    | 1     | 📋 Planned | 3      |
| Mid Spires        | `bg_luminara_mid_spires.png`       | 960x180    | 2     | 📋 Planned | 3      |
| Near Architecture | `bg_luminara_near_arch.png`        | 1280x180   | 3     | 📋 Planned | 3      |

### 8.2 Atmospheric Elements

| Asset Name     | Filename                | Dimensions | Usage   | Status     | Sprint |
| -------------- | ----------------------- | ---------- | ------- | ---------- | ------ |
| Crystal Fog    | `bg_crystal_fog.png`    | 320x60     | Overlay | 📋 Planned | 3      |
| Light Shafts   | `bg_light_shafts.png`   | 160x180    | Overlay | 📋 Planned | 3      |
| Particle Field | `bg_particle_field.png` | 320x180    | Overlay | 📋 Planned | 3      |

## 9. Technical Specifications by Asset Type

### 9.1 Character Sprites

- **Base Resolution**: 32x32 pixels (2x2 tiles)
- **Format**: PNG with transparent background
- **Color Depth**: 8-bit indexed color
- **Animation FPS**: 8-12 frames per second
- **Sprite Sheet**: Horizontal layout with 1px padding

### 9.2 Tile Assets

- **Base Resolution**: 16x16 pixels per tile
- **Format**: PNG with transparent background where applicable
- **Tileable**: Must seamlessly connect with adjacent tiles
- **Variants**: 3-5 variations to prevent repetition
- **Atlas Packing**: Power-of-two textures for GPU efficiency

### 9.3 Props and Effects

- **Variable Resolution**: Based on in-game size (8x8 to 128x256)
- **Format**: PNG with transparent background
- **Animation**: Frame-based animation for interactive elements
- **Optimization**: Packed into atlases for performance

### 9.4 UI Elements

- **Base Resolution**: Designed for 320x180 internal resolution
- **Format**: PNG with transparency
- **States**: Normal, hover, pressed, disabled where applicable
- **Scaling**: Integer scaling only for pixel-perfect display

## 10. Asset Production Pipeline

### 10.1 Creation Workflow

1. **Concept Phase**: Rough sketches and color studies
2. **Production Phase**: Pixel art creation following style guide
3. **Animation Phase**: Frame-by-frame animation where needed
4. **Review Phase**: Technical and artistic review
5. **Integration Phase**: Export optimization and code integration

### 10.2 Quality Standards

- All assets must adhere to the [Art Style Guide](../../05_Style_Guides/ArtStyle.md)
- Technical specifications must meet [Asset Requirements](AssetRequirements.md)
- Performance targets must be maintained across all platforms
- Visual consistency with established Luminara aesthetic

### 10.3 Version Control

- Source files (.aseprite, .psd) stored in separate repository
- Exported PNG files committed to main project repository
- Version tagging aligned with sprint milestones
- Asset changelog maintained for tracking modifications

## 11. Implementation Status by Sprint

### Sprint 1-2 (Complete)

- ✅ Player basic animations (idle, run, jump, fall, land)
- ✅ Basic UI elements (health bar, aether counter)
- ✅ Core collectible (Aether Shard)

### Sprint 3 (Current)

- 🚧 Luminara tileset foundation
- 🚧 Mira NPC sprites
- 📋 Crystal props and effects
- 📋 Environmental backgrounds

### Sprint 4-6 (Planned)

- 📋 Tutorial UI assets
- 📋 Main menu graphics
- 📋 Additional Luminara props
- 📋 First enemy sprites

### Future Sprints

- 📋 Additional world tilesets (Verdant Canopy, Forge Peaks, etc.)
- 📋 Advanced enemy types
- 📋 Boss encounter assets
- 📋 Ending sequence graphics

## 12. Asset Dependencies

### Code Integration Points

```dart
// Character Animations
static const String playerIdleSprite = 'characters/player/character_player_idle.png';
static const String playerRunSprite = 'characters/player/character_player_run.png';

// Luminara Tilesets
static const String luminaraPlatform = 'tilesets/luminara/tile_luminara_crystal_platform_azure.png';
static const String luminaraSpire = 'tilesets/luminara/tile_luminara_master_spire_base.png';

// Effects
static const String aetherPickup = 'effects/aether/effect_aether_pickup.png';
static const String crystalResonance = 'effects/aether/effect_crystal_resonance.png';

// UI Elements
static const String healthBarFrame = 'ui/hud/ui_health_bar_frame.png';
static const String tutorialArrow = 'ui/tutorial/ui_tutorial_arrow.png';
```

### Asset Loading Configuration

```dart
// AssetBundle preloading groups
static const List<String> coreAssets = [
  'characters/player/character_player_idle.png',
  'ui/hud/ui_health_bar_frame.png',
  'props/collectibles/collectible_aether_shard.png',
];

static const List<String> luminaraAssets = [
  'tilesets/luminara/tile_luminara_crystal_platform_azure.png',
  'backgrounds/luminara/bg_luminara_sky.png',
  'effects/aether/effect_crystal_resonance.png',
];
```

## 13. Related Documentation

- [Art Style Guide](../../05_Style_Guides/ArtStyle.md) - Visual standards and technical specs
- [Asset Requirements](AssetRequirements.md) - Technical constraints and performance requirements
- [Asset Pipeline](AssetPipeline.md) - Production workflow and delivery process
- [Luminara Concept Art](LuminaraConceptArt.md) - Visual reference and design direction
- [Sprint Plan](../../04_Project_Management/AgileSprintPlan.md) - Implementation timeline and priorities

---

_This document is updated with each sprint milestone and serves as the authoritative reference for all visual assets in Adventure Jumper. All asset modifications must be reflected in this manifest to maintain synchronization between art production and code implementation._

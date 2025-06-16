# Asset Pipeline - Adventure Jumper
*Last Updated: January 2025*

This document describes the asset pipeline for Adventure Jumper, detailing the asset creation, import, and management processes aligned with our sprint-based development approach and design cohesion principles.

> **Related Documents:**
> - [Architecture](Architecture.md) - System integration overview
> - [ComponentsReference](ComponentsReference.md) - Component usage of assets
> - [Design Cohesion Guide](../04_Project_Management/DesignCohesionGuide.md) - Design principles
> - [Agile Sprint Plan](../04_Project_Management/AgileSprintPlan.md) - Sprint timeline
> - [ArtStyle](../05_Style_Guides/ArtStyle.md) - Visual guidelines for assets

## 1. Sprint-Aligned Asset Delivery

The asset pipeline follows our sprint cadence to ensure timely delivery of assets that support our Design Cohesion principles.

### Sprint 1 Assets (Foundation)
- Core player character animations optimized for responsive feedback
- Basic environment tileset supporting fluid movement mechanics
- Essential UI elements for minimal gameplay HUD
- Foundational sound effects for movement feedback

### Sprint 2-3 Assets (Core Systems)
- Extended player animation set supporting movement fluidity
- Combat-related visual effects enhancing action feedback
- Initial world-specific environment assets
- Audio assets supporting movement and action feedback

### Sprint 4-6 Assets (Expanding Worlds)
- World-specific theming assets for distinct environments
- Advanced player ability animations
- Enemy character sets with clear visual language
- Dynamic audio sets for combat and environment

### Sprint 7+ Assets (Polish & Mastery)
- Visual flourishes for mastery moments
- Narrative-enhancing environment details
- Achievement celebration assets
- Final UI theming for each world

## 2. Design Cohesion Asset Principles

All assets must support our core Design Pillars:

### Fluid & Expressive Movement Assets
- Animation frames prioritize responsive feedback over visual complexity
- Visual effects enhance rather than obstruct movement clarity
- Environment assets designed to clearly communicate traversability
- Audio assets provide immediate movement feedback (<50ms latency)

### Engaging & Dynamic Combat Assets
- Combat animations maintain character silhouette readability
- Enemy designs clearly communicate attack patterns and vulnerabilities
- Visual effects scale with combat intensity without visual clutter
- Audio clearly distinguishes between different combat actions

### Progressive Mastery Assets
- Visual progression in character abilities and effects
- Environment details that evolve with player advancement
- UI elements that celebrate milestone achievements
- Audio cues that reinforce successful technique execution

## 3. Asset Directory Structure
```
assets/
├── images/
│   ├── characters/
│   │   ├── player/
│   │   │   ├── player_idle.png    # 64x64 sprite sheet (4 frames)
│   │   │   ├── player_run.png     # 64x128 sprite sheet (6 frames)
│   │   │   └── player_jump.png    # 64x64 single frame
│   │   └── enemies/
│   │       ├── slime_idle.png    # 48x32 sprite sheet (4 frames)
│   │       └── bat_fly.png       # 32x32 sprite sheet (4 frames)
│   ├── tilesets/
│   │   ├── forest/
│   │   │   └── tiles.png        # 512x512 tileset (16x16 tiles)
│   │   └── cave/
│   │       └── tiles.png        # 512x512 tileset (16x16 tiles)
│   ├── ui/
│   │   ├── buttons/
│   │   │   ├── play_button.png    # 200x80 button with states
│   │   │   └── settings_button.png # 40x40 icon with states
│   │   └── icons/
│   │       ├── heart.png        # 16x16 health indicator
│   │       ├── coin.png         # 16x16 collectible currency
│   │       ├── star.png         # 16x16 score/special collectible
│   │       ├── pause.png        # 16x16 pause button
│   │       ├── sound_on.png     # 16x16 sound enabled
│   │       └── sound_off.png    # 16x16 sound disabled
│   └── effects/
│       └── particles/
│           ├── dust.png         # 16x16 particle effect
│           ├── sparkle.png      # 16x16 particle effect
│           └── explosion.png    # 32x32 sprite sheet (6 frames)
├── audio/
│   ├── music/
│   │   ├── title_theme.mp3      # 3:30 looping track
│   │   ├── forest_theme.mp3     # 4:00 looping track
│   │   └── cave_theme.mp3       # 3:45 looping track
│   └── sfx/
│       ├── ui_click.wav         # UI interaction sound
│       ├── jump.wav             # Player jump
│       ├── land.wav             # Player landing
│       ├── collect.wav          # Item collection
│       └── hurt.wav             # Player damage
├── fonts/
│   ├── pixel_font.ttf           # Main UI font
│   └── title_font.ttf           # Game title font
└── levels/
    ├── level_1.json             # Level data file
    └── level_2.json             # Level data file
```

## 4. Asset Creation Guidelines

### 4.1 Graphical Assets
- **Sprites and Characters**:
  - Resolution: Base unit of 16px with character sprites at 64px height
  - Color Palette: 32-color restricted palette per theme (see [ArtStyle](../05_Style_Guides/ArtStyle.md))
  - Format: PNG with transparency
  - Animation: Frame-based sprite sheets with consistent frame sizes

- **Tilesets**:
  - Tile Size: 16x16 pixels for standard tiles
  - Sheet Size: 512x512 pixels (32x32 tiles per sheet)
  - Format: PNG with transparency
  - Special Tiles: Animated tiles use horizontal strip format (16x16 per frame)

- **UI Elements**:
  - Resolution: Base 16px grid, scaled as needed
  - Format: PNG with transparency
  - States: Buttons include normal, hover, pressed, and disabled states
  - Icons: 16x16 or 32x32 pixel art style

### 4.2 Audio Assets
- **Music**:
  - Format: MP3 (192kbps) for distribution, WAV for development
  - Length: 1-4 minutes with seamless looping points
  - Themes: Each world has a unique theme with variations

- **Sound Effects**:
  - Format: WAV (16-bit, 44.1kHz)
  - Length: Brief (typically <1 second)
  - Categories: UI, player actions, environment, enemy

### 4.3 Font Assets
- Only TrueType (.ttf) fonts with appropriate licensing
- Primary game font is pixel-based at 8px or 16px base size
- Include bold and italic variants if needed

## 5. Asset Import Pipeline

### 5.1 Import Workflow
1. Artists place raw assets in the designated shared repository
2. Technical artists process and optimize assets using the Asset Processor tool
3. Processed assets are committed to the game repository in appropriate directories
4. Assets are registered in the asset manifest files automatically during build

### 5.2 Asset Processor Tool
- Custom tool for batch processing assets according to project standards
- Features:
  - Image optimization (compression, atlas generation)
  - Sprite sheet validation and slicing
  - Audio normalization and format conversion
  - Automatic manifest generation

### 5.3 Asset Versioning
- Assets follow semantic versioning (major.minor.patch)
- Asset changes tracked in version control with appropriate tagging
- Breaking changes to assets must increment the major version

## 6. Runtime Asset Management

### 6.1 Asset Loading
- Flutter asset management system handles basic loading
- Custom AssetManager class provides:
  - Preloading of critical assets during loading screens
  - Dynamic loading of level-specific assets
  - Unloading of unused assets to manage memory
  - Asset caching to prevent redundant loads

### 6.2 Asset Caching Strategy
- **Tiered Caching System**:
  - Tier 1: Always in memory (player, UI, core game elements)
  - Tier 2: Loaded per level/world (level-specific elements)
  - Tier 3: On-demand loading (rare animations, cutscene assets)

### 6.3 Memory Management
- Memory budget per device category:
  - Low-end: 64MB for assets
  - Mid-range: 128MB for assets
  - High-end: 256MB for assets
- Automatic texture scaling based on device capabilities
- Runtime memory monitoring with adaptive quality adjustments

## 7. Technical Implementation

### 7.1 Asset Loading Code
```dart
// Example of asset loading with the AssetManager
Future<void> preloadWorldAssets(String worldId) async {
  final assetManager = AssetManager.instance;
  
  // Preload world-specific assets
  await assetManager.preloadBundle(
    category: AssetCategory.world,
    id: worldId,
    priority: LoadPriority.high,
  );
  
  // Preload character assets needed for this world
  await assetManager.preloadBundle(
    category: AssetCategory.characters,
    id: 'world_$worldId',
    priority: LoadPriority.medium,
  );
}
```

### 7.2 Sprite Animation System
```dart
// Example of using the animation system with loaded assets
void setupPlayerAnimations() {
  final player = PlayerEntity();
  final spriteComponent = player.getComponent<SpriteComponent>();
  
  spriteComponent.addAnimation(
    'idle',
    SpriteAnimation.fromFrames(
      frames: AssetManager.instance.getSpriteFrames('player_idle'),
      stepTime: 0.15,
    ),
  );
  
  spriteComponent.addAnimation(
    'run',
    SpriteAnimation.fromFrames(
      frames: AssetManager.instance.getSpriteFrames('player_run'),
      stepTime: 0.10,
    ),
  );
  
  spriteComponent.playAnimation('idle');
}
```

## 8. Integration with Development Workflow

### 8.1 Asset Request Process
1. Designer creates asset request with detailed specifications referencing [DesignCohesionGuide.md](../04_Project_Management/DesignCohesionGuide.md) principles
2. Request is prioritized in the art backlog according to [AgileSprintPlan.md](../04_Project_Management/AgileSprintPlan.md) timeline
3. Artist creates and submits assets for review, adhering to design cohesion principles
4. Technical artist validates assets against design cohesion requirements
5. Assets undergo Design Cohesion Validation:
   - Does the asset support the appropriate Design Pillar(s)?
   - Does it maintain visual/audio consistency with existing assets?
   - Does it clearly communicate its gameplay purpose?
   - Is it optimized for the current sprint's performance targets?
6. Asset is imported, processed, and made available to developers
7. Integration testing confirms asset functions as expected in gameplay

### 8.2 Asset Testing
- Automated tests verify:
  - Assets conform to required dimensions and formats
  - Animations have consistent frame sizes
  - Audio files meet quality and format requirements
  - All required assets for a level/world are present

### 8.3 Sprint Integration Workflow
- **Sprint Planning**:
  - Asset needs are identified based on sprint deliverables
  - Asset requests are prioritized with technical dependencies in mind
  - Art team allocates resources based on sprint requirements
  - Design cohesion principles from [DesignCohesionGuide.md](../04_Project_Management/DesignCohesionGuide.md) are reviewed

- **During Sprint**:
  - Weekly asset reviews ensure alignment with design cohesion principles
  - Blocking assets are flagged for expedited delivery
  - Implementation feedback may trigger asset revisions
  - Asset status is tracked in sprint board with design cohesion validation status

- **Sprint Review**:
  - Completed assets are demonstrated in gameplay context
  - Asset impact on gameplay feel is evaluated against design pillars
  - Performance metrics for asset loading and rendering are reviewed
  - Knowledge gained informs future sprint asset planning

- **Asset Delivery Calendar** (aligned with [AgileSprintPlan.md](../04_Project_Management/AgileSprintPlan.md)):
  | Sprint | Primary Asset Focus | Design Pillar Emphasis |
  |--------|---------------------|------------------------|
  | 1      | Core player & basic environment | Fluid Movement foundation |
  | 2-3    | Extended movement & initial combat | Movement + Combat integration |
  | 4-5    | World-specific theming & enemies | World diversity & Combat depth |
  | 6-7    | Advanced abilities & mastery feedback | Progressive Mastery |
  | 8+     | Polish, feedback enhancement & celebration | All pillars refinement |

### 8.4 Continuous Integration
- Asset validation runs on every pull request
- Build pipeline automatically generates asset manifests
- Performance metrics track asset loading times and memory usage

## 9. Tools and Resources

### 9.1 Recommended Tools
- **Sprite Creation**: Aseprite, Piskel
- **Image Editing**: Adobe Photoshop, GIMP
- **Audio Creation**: FL Studio, Audacity
- **Audio Processing**: FMOD, Audacity
- **Version Control**: Git LFS for binary assets

### 9.2 Internal Tools
- **Asset Processor**: Custom tool for preparing assets for game integration
- **Sprite Sheet Generator**: Automates sprite sheet creation from individual frames
- **Asset Validator**: Verifies assets meet project requirements

## 10. Future Improvements

- Investigate procedural asset generation for certain elements
- Implement dynamic texture atlasing for improved performance
- Create automated visual regression testing for assets
- Develop asset heat maps to identify usage patterns and optimization opportunities

## 11. Troubleshooting Common Issues

### 11.1 Missing Assets
- Check asset path in manifest files
- Verify asset exists in the correct directory
- Ensure asset is properly registered in `pubspec.yaml`

### 11.2 Performance Issues
- Reduce texture sizes for problem assets
- Verify efficient sprite sheet packing
- Check for memory leaks in asset loading/unloading

### 11.3 Visual Artifacts
- Confirm proper transparency settings
- Check for texture bleeding between atlas entries
- Verify mip-mapping settings for scaled assets

## 12. Related Documentation

- **Core References:**
  - [Architecture](Architecture.md) - System architecture integration
  - [Design Cohesion Guide](../04_Project_Management/DesignCohesionGuide.md) - Design pillars and validation criteria
  - [Agile Sprint Plan](../04_Project_Management/AgileSprintPlan.md) - Sprint delivery timeline
  - [ComponentsReference](ComponentsReference.md) - Asset usage by component

- **Implementation Details:**
  - [Asset System TDD](TDD/AssetSystem.TDD.md) - Technical implementation details
  - [Audio System TDD](TDD/AudioSystem.TDD.md) - Audio asset usage and management
  - [Player Character TDD](TDD/PlayerCharacter.TDD.md) - Player animation implementation
  - [UI System TDD](TDD/UISystem.TDD.md) - UI asset implementation

- **Style Guidelines:**
  - [Art Style Guide](../05_Style_Guides/ArtStyle.md) - Visual asset creation guidelines
  - [Audio Style Guide](../05_Style_Guides/AudioStyle.md) - Audio creation standards
  - [UI/UX Style Guide](../05_Style_Guides/UI_UX_Style.md) - UI asset standards
  - [Implementation Guide](../03_Development_Process/ImplementationGuide.md) - General implementation standards

# Art Style Guide

This document outlines the visual style and art standards for the Adventure Jumper project.

## Visual Direction

### Style Overview
Adventure Jumper uses a stylized 2.5D pixel art aesthetic that combines modern lighting and effects with pixel-perfect sprite work. The goal is to create a visually striking world that feels both nostalgic and contemporary.

### Key Visual Pillars
1. **Readable Gameplay**: Gameplay elements are always clearly distinguishable
2. **Atmospheric Lighting**: Dynamic lighting creates mood and draws attention
3. **Visual Storytelling**: Environmental details convey narrative without text
4. **Consistent Scale**: Maintain proper proportions across all game elements

## Technical Specifications

### Sprites
- **Resolution**: Base character sprites are 32x32 pixels (2x2 tiles)
- **Animation**: 8-12 frames per second for most animations
- **Outline**: 1px dark outline on important gameplay elements
- **Pivots**: Character pivots at the feet/bottom center

### Tiles
- **Base Size**: 16x16 pixels for standard tiles
- **Grid**: All environmental elements align to the grid
- **Variations**: 3-5 variations of common tiles to avoid repetition
- **Rules**: Follow proper tileset connection rules

### Color Palette
- **Global Palette**: Limited to 64 colors across the entire game
- **Zone Palettes**: Each zone uses a subset of 24-32 colors
- **Functional Colors**: Consistent color language for interactive elements
  - Aether energy: Cyan/light blue (#42E5F5)
  - Health: Red/pink (#FF4A6D)
  - Danger: Orange/yellow (#FFAA33)

### Resolution and Scaling
- **Internal Resolution**: 320x180 pixels (16:9)
- **Scaling**: Pixel-perfect scaling (integer multiples only)
- **UI Elements**: Designed for visibility at base resolution

## World-Specific Art Guidelines

### Luminara (Hub)
- **Color Scheme**: Warm whites, soft blues, golden accents
- **Architecture**: Circular designs, aether-infused stone
- **Lighting**: Soft ambient glow, gentle light rays
- **Unique Visual Elements**: Floating stone platforms, luminous crystal formations

### Verdant Canopy
- **Color Scheme**: Deep greens, moss browns, flower highlights
- **Architecture**: Organic shapes, living structures, root systems
- **Lighting**: Dappled light through canopy, bioluminescent elements
- **Unique Visual Elements**: Giant trees, hanging vines, oversized flora

### Forge Peaks
- **Color Scheme**: Dark reds, oranges, smoky grays
- **Architecture**: Angular industrial, pipes and machinery
- **Lighting**: Harsh shadows, glowing magma, steam effects
- **Unique Visual Elements**: Lava flows, steam vents, ancient machinery

### Celestial Archive
- **Color Scheme**: Deep purples, starlight blues, gold accents
- **Architecture**: Impossible geometry, floating structures
- **Lighting**: Ethereal glow, star-like points of light
- **Unique Visual Elements**: Reality tears, constellation patterns, floating books

### Void's Edge
- **Color Scheme**: Desaturated base with vibrant corruption
- **Architecture**: Fragmented reality, broken structures
- **Lighting**: High contrast, void darkness with bright highlights
- **Unique Visual Elements**: Reality distortion, corruption tendrils, shattered terrain

## Animation Guidelines

### Character Animation
- **Idle**: Subtle breathing motion (4-6 frames)
- **Run**: Fluid motion with slight squash and stretch (8 frames)
- **Jump**: Anticipation pose + airborne pose (2-3 frames)
- **Attack**: Quick, readable silhouettes with follow-through (4-5 frames per attack)
- **Hit/Damage**: Brief flash + recoil pose (2-3 frames)

### Environment Animation
- **Interactive Elements**: Subtle pulsing or movement to indicate interaction
- **Background**: Parallax scrolling with 3-5 depth layers
- **Ambient**: Small animations to bring the world to life (4-8 frame loops)
- **Weather Effects**: Particle-based with consistent directional movement

### Effects
- **Aether Effects**: Flowing, ethereal particles with light bloom
- **Impact Effects**: Short, punchy with clear directionality
- **Collectibles**: Gentle bobbing + sparkle/glow animation
- **UI Transitions**: Smooth, quick with minimal intrusion on gameplay

## Asset Naming and Organization

### File Naming Convention
- `character_[name]_[state]_[frame].png`
- `tile_[tileset]_[id].png`
- `prop_[zone]_[name].png`
- `effect_[type]_[variant].png`
- `ui_[element]_[state].png`

### Folder Structure
```
assets/
└── images/
    ├── characters/
    │   ├── player/
    │   └── enemies/
    ├── tilesets/
    │   ├── luminara/
    │   ├── verdant/
    │   └── ...
    ├── props/
    ├── effects/
    └── ui/
```

## Asset Delivery Specifications

### Sprite Sheets
- Character animations delivered as horizontal sprite sheets
- Consistent frame size within each sheet
- 1px padding between frames to prevent texture bleeding
- Transparent background (PNG format)

### Export Settings
- PNG format for all assets
- No compression for source files
- Optimized PNGs for build versions
- Proper power-of-two textures for effects/UI elements that require it

## Artistic Process

### Concept Phase
1. Rough sketches exploring multiple directions
2. Feedback and iteration on selected direction
3. Color studies and mood exploration
4. Final concept approval before pixel art production

### Production Phase
1. Block in base colors and shapes
2. Define key poses and silhouettes
3. Detail pass with shading and highlights
4. Animation and effects integration
5. Technical review for performance and readability

## Quality Control

### Art Review Checklist
- [ ] Adheres to color palette constraints
- [ ] Maintains consistent proportions and scale
- [ ] Readable at intended resolution
- [ ] Animation feels fluid and purposeful
- [ ] Visually harmonizes with surrounding elements
- [ ] Supports gameplay functionality clearly
- [ ] Optimized for performance (texture size, etc.)

## Related Documents

### External References
- [Style Reference Board](https://moodboard.link/adventure-jumper) (Internal link)
- [Animation Principles Guide](https://animation-guide.link) (Internal link)
- [Pixel Art Best Practices Document](https://pixel-guide.link) (Internal link)

### Project Documents
- [Asset Pipeline](../02_Technical_Design/AssetPipeline.md) - Technical workflow for art asset integration
- [Character Documents](../01_Game_Design/Characters/) - Character design specifications
- [World Documents](../01_Game_Design/Worlds/) - World design visual requirements
- [UI/UX Style Guide](UI_UX_Style.md) - User interface visual standards
- [Game Design Document](../01_Game_Design/GDD.md) - Overall game design context

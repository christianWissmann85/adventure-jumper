# Asset Requirements & Technical Specifications - Adventure Jumper

_Last Updated: January 2025_

## 1. Introduction

This document details the comprehensive technical specifications and requirements for all art assets created for "Adventure Jumper," with special focus on Luminara Hub's crystalline architecture and lighting systems. Adherence to these guidelines is crucial for maintaining visual consistency, optimizing performance, and ensuring seamless integration with our sprint-based development pipeline.

> **Related Documents:**
>
> - [Art Style Guide](ArtStyleGuide.md) - Visual and artistic specifications
> - [Asset Pipeline](AssetPipeline.md) - Delivery and integration processes
> - [Luminara Concept Art](LuminaraConceptArt.md) - Detailed visual concepts
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Core design principles

**Quality Standards**: All assets must support our Design Pillars of **Fluid & Expressive Movement**, **Engaging & Dynamic Combat**, and **Consistent & Vibrant Stylized Aesthetic** while meeting strict performance requirements for cross-platform deployment.

## 2. Platform-Specific Requirements

### 2.1 Target Platform Specifications

- **Primary Platforms**: Windows, macOS, Linux (via Flutter Desktop)
- **Secondary Platforms**: Web (Flutter Web), Mobile (iOS/Android - future consideration)
- **Minimum Hardware**: Intel i3/AMD Ryzen 3, 4GB RAM, Integrated Graphics
- **Target Hardware**: Intel i5/AMD Ryzen 5, 8GB RAM, Dedicated GPU (GTX 1050/RX 560 equivalent)
- **Maximum Hardware**: High-end gaming systems with RTX/RDNA graphics

### 2.2 Performance Targets

- **Frame Rate**: 60 FPS minimum on target hardware, 30 FPS minimum on minimum hardware
- **Memory Budget**: 512MB total for assets (256MB for textures, 128MB for geometry, 128MB for audio)
- **Loading Times**: <3 seconds for level transitions, <1 second for asset streaming
- **Battery Life**: 4+ hours on mobile devices (future consideration)

### 2.3 Resolution Support

- **Target Base Resolution**: 1920x1080 (1080p) as design reference
- **High DPI Support**: Provide 1x and 2x scale assets for UI elements and critical sprites
- **Aspect Ratio Support**: Primary 16:9, secondary 16:10, fallback 4:3
- **Scaling Strategy**: Integer scaling for pixel-perfect rendering where possible

## 3. Luminara-Specific Asset Requirements

### 3.1 Crystal Formation Specifications

#### Large Structural Crystals (Master Spire Components)

- **File Format**: `.fbx` or `.gltf` for 3D models, `.png` for textures
- **Polygon Budget**: 5,000-15,000 triangles for LOD 0, 1,000-3,000 for LOD 1
- **Texture Resolution**: 2048x2048 for diffuse/normal, 1024x1024 for detail maps
- **Material Complexity**: Maximum 4 texture inputs per material (diffuse, normal, emission, metallic/roughness)
- **UV Mapping**: Single UV channel, 0-1 space, minimal seams on visible faces
- **Pivot Points**: Bottom center of formation for proper placement

#### Medium Support Crystals (Bridges, Platforms)

- **File Format**: `.fbx` or `.gltf` for 3D models, `.png` for textures
- **Polygon Budget**: 1,000-5,000 triangles for LOD 0, 300-1,000 for LOD 1
- **Texture Resolution**: 1024x1024 for all maps, shared atlases where possible
- **Material Sharing**: Maximum 3 unique materials per crystal type
- **Collision Geometry**: Simplified collision meshes with <100 triangles
- **Modular Design**: Standardized connection points for seamless assembly

#### Small Detail Crystals (Decorative Elements)

- **File Format**: `.png` sprites for distant elements, `.fbx` for interactive crystals
- **Polygon Budget**: 100-1,000 triangles for 3D versions
- **Texture Resolution**: 512x512 maximum, prefer 256x256 for small elements
- **Instancing Ready**: Designed for efficient GPU instancing
- **Animation Support**: Simple rotation or pulsing effects only
- **Particle Integration**: Compatible with particle system attachment points

### 3.2 Architectural Element Specifications

#### Crystal Architecture Materials

- **Transparency Support**: Alpha blending for translucent crystals
- **Refraction Effects**: Simple screen-space refraction (no ray tracing)
- **Internal Lighting**: Emission maps for internal glow effects
- **Surface Details**: Normal maps for faceting without geometry complexity
- **Weathering Effects**: Vertex color channels for age and wear variation

#### Platform & Bridge Systems

- **Safety Standards**: All walkable surfaces must have clear visual boundaries
- **Navigation Clarity**: Color coding for different platform types (static, moving, temporary)
- **Interactive Feedback**: Visual response to player presence (brightening, particle effects)
- **Connection Points**: Standardized attachment systems for modular construction
- **Load Indication**: Visual systems showing platform capacity and stability

### 3.3 Lighting & Effects Requirements

#### Crystal Illumination Systems

- **Light Sources**: Maximum 8 dynamic lights per major scene area
- **Shadow Quality**: Medium quality shadows with 4-cascade system
- **Emission Textures**: HDR emission maps for crystal glow effects
- **Bloom Integration**: 20-30% bloom intensity on all light sources
- **Color Temperature**: Consistent color temperature system (2700K-7000K range)

#### Particle System Specifications

- **Aether Particles**: 100-200 active particles per scene maximum
- **Texture Size**: 64x64 or 128x128 for particle textures
- **Blend Modes**: Additive blending for glows, alpha blend for solid particles
- **Performance Budget**: <5ms frame time impact on target hardware
- **Culling Distance**: Automatic culling beyond 50-meter range

## 4. Advanced Luminara Technical Specifications

### 4.1 Crystal Material System

#### Material Layer Composition

- **Base Layer**: Diffuse color with transparency support (RGBA)
- **Normal Layer**: Surface faceting and micro-detail normal maps
- **Emission Layer**: Internal lighting and glow effects (HDR)
- **Properties Layer**: Metallic/Roughness/AO packed texture
- **Overlay Layer**: Weathering, dirt, and age effects (optional)

#### Crystal Material Parameters

- **Transparency Range**: 0.3-0.8 alpha for different crystal types
- **Refraction Index**: 1.4-1.8 simulated through screen-space distortion
- **Emission Intensity**: 0.5-2.0 HDR multiplier for internal glow
- **Roughness Values**: 0.1-0.4 for polished to weathered surfaces
- **Metallic Values**: 0.0-0.2 (crystals are non-metallic but may have metallic inclusions)

#### Performance Optimization

- **Shader Complexity**: Maximum 64 instruction count for crystal materials
- **Texture Memory**: 8MB budget per crystal material set
- **Draw Call Efficiency**: Maximum 4 materials per crystal formation
- **LOD Transitions**: Smooth material degradation at distance

### 4.2 Architectural Lighting Technical Requirements

#### Dynamic Lighting System

- **Point Lights**: 4-6 per major area for key crystal illumination
- **Spot Lights**: 2-3 for focused architectural highlighting
- **Area Lights**: 1-2 for ambient environmental illumination
- **Directional Lights**: 1 primary for overall scene lighting
- **Light Intensity**: 0.5-3.0 range with HDR support

#### Shadow Casting Requirements

- **Shadow Resolution**: 1024x1024 for primary lights, 512x512 for secondary
- **Cascade Count**: 4 cascades for directional shadow mapping
- **Shadow Distance**: 50-meter maximum range for performance
- **Soft Shadow**: 2-4 sample PCF for smooth shadow edges
- **Transparency Shadows**: Alpha-tested shadows for crystal formations

#### Volumetric Lighting Effects

- **God Ray Resolution**: 512x512 render target for volumetric effects
- **Scattering Samples**: 16-32 samples for quality/performance balance
- **Particle Integration**: Atmospheric particles respond to volumetric lighting
- **Performance Target**: <2ms additional frame time for volumetric effects

### 4.3 Animation & Effects Technical Specifications

#### Crystal Animation Systems

- **Rotation Speed**: 0.1-0.5 degrees per second for floating crystals
- **Pulse Rate**: 0.3-1.0 Hz frequency for breathing effects
- **Amplitude**: 10-30% intensity variation for glow pulsing
- **Phase Offset**: Staggered timing to avoid synchronization artifacts
- **Interactive Response**: 0.5-2.0 second response time to player proximity

#### Particle Effect Specifications

- **Spawn Rate**: 10-50 particles per second for ambient effects
- **Lifetime**: 3-8 seconds for atmospheric particles
- **Velocity**: 0.1-2.0 m/s for gentle floating movement
- **Size Variation**: 50-200% scale variation for natural appearance
- **Color Shifting**: Smooth HSV transitions for magical effects

#### Procedural Effect Generation

- **Noise Patterns**: Perlin noise for natural crystal growth simulation
- **Fractal Details**: 2-3 octaves for surface detail generation
- **Seed Values**: Consistent seeds for reproducible crystal formations
- **Variation Range**: 20-40% deviation from base patterns
- **Real-time Generation**: <10ms computation time for procedural elements

### 4.4 Audio Integration Requirements

#### Spatial Audio Specifications

- **3D Positioning**: Full 3D audio positioning for crystal resonance
- **Distance Attenuation**: Realistic falloff over 5-25 meter range
- **Occlusion Support**: Audio dampening behind large crystal formations
- **Reverb Zones**: Cathedral-like reverb in enclosed crystal chambers
- **Dynamic Range**: -40dB to 0dB range for crystal harmonics

#### Crystal Resonance Audio

- **Frequency Range**: 200Hz-2kHz for crystal harmonics
- **Harmonic Series**: Natural overtone relationships for realistic resonance
- **Trigger Threshold**: Player proximity within 3-meter radius
- **Fade Time**: 1-3 second smooth fade in/out for resonance
- **Polyphony**: Maximum 8 simultaneous crystal resonance sounds

### 4.5 Interactive Element Specifications

#### Player Interaction Feedback

- **Visual Response Time**: <100ms for immediate visual feedback
- **Audio Response Time**: <50ms for immediate audio feedback
- **Highlight Intensity**: 150-300% brightness increase for interactive elements
- **Color Shift**: Blue to gold transition for interaction indication
- **Animation Trigger**: Smooth 0.5-1.0 second transition animations

#### UI Integration Requirements

- **Interaction Prompts**: Floating UI elements with 90% opacity
- **Distance Threshold**: 2-meter range for interaction availability
- **Icon Resolution**: 64x64 pixels for interaction icons
- **Animation Loop**: 2-3 second subtle animation loops for attention
- **Accessibility**: High contrast options for vision-impaired players

## 5. Asset Production Workflow Specifications

### 5.1 Concept to Production Pipeline

#### Phase 1: Concept Development

- **Reference Gathering**: Minimum 10 real-world crystal formation references
- **Mood Studies**: 3-5 lighting and atmosphere variations
- **Technical Validation**: Early polygon count and performance estimates
- **Style Consistency**: Validation against established Art Style Guide
- **Stakeholder Approval**: Design director sign-off before production

#### Phase 2: 3D Modeling Requirements

- **Modeling Software**: Blender 3.0+ or Maya 2023+ for 3D assets
- **Topology Standards**: Quad-dominant topology for large surfaces
- **UV Mapping**: Single UV channel, 0-1 space, minimal distortion
- **Naming Conventions**: `luminara_crystal_[type]_[size]_[variation]`
- **Export Settings**: FBX 2020.3.4 with embedded media disabled

#### Phase 3: Texturing Specifications

- **Texturing Software**: Substance Painter 2023+ or equivalent
- **Texture Resolution**: Powers of 2 (256, 512, 1024, 2048)
- **Channel Packing**: RGB normal maps, packed material properties
- **HDR Support**: 16-bit emission maps for proper bloom
- **Quality Validation**: Visual review at target resolution

#### Phase 4: Integration Testing

- **Performance Profiling**: Frame rate testing on minimum hardware
- **Visual Validation**: In-game screenshot comparison to concept
- **Interactive Testing**: Player interaction and feedback systems
- **Audio Integration**: Sound effect synchronization testing
- **Platform Testing**: Validation across Windows, macOS, Linux

### 5.2 Quality Assurance Standards

#### Visual Quality Checklist

- [ ] Maintains consistent art style with existing Luminara assets
- [ ] Crystal formations follow established geometric principles
- [ ] Lighting responds correctly to dynamic light sources
- [ ] Materials exhibit proper transparency and refraction
- [ ] Weathering and age effects appear natural and consistent
- [ ] Color palette adheres to established Luminara specifications
- [ ] Scale relationships correct relative to player character
- [ ] Visual clarity maintained at all intended viewing distances

#### Technical Quality Checklist

- [ ] Polygon count within established budgets for asset type
- [ ] UV mapping efficient with minimal texture waste
- [ ] Materials use appropriate number of texture channels
- [ ] LOD transitions smooth and visually acceptable
- [ ] Collision geometry simplified and performance-optimized
- [ ] Animation systems function correctly with game engine
- [ ] Audio integration synchronized with visual effects
- [ ] Cross-platform compatibility verified

#### Performance Validation

- [ ] Frame rate impact <5% on target hardware configuration
- [ ] Memory usage within allocated budget for asset category
- [ ] Loading time <2 seconds for individual asset
- [ ] Draw call efficiency optimized through material sharing
- [ ] Culling systems function correctly at various distances
- [ ] Level-of-detail transitions imperceptible during gameplay
- [ ] Particle effects maintain performance targets
- [ ] Audio systems respect polyphony and processing limits

### 5.3 Asset Delivery Requirements

#### File Organization Standards

```
luminara_assets/
├── concepts/
│   ├── luminara_spire_concept_v01.png
│   ├── luminara_plaza_concept_v02.png
│   └── lighting_studies/
├── models/
│   ├── luminara_master_spire_lod0.fbx
│   ├── luminara_master_spire_lod1.fbx
│   └── collision/
├── textures/
│   ├── crystal_azure_2k/
│   ├── crystal_teal_1k/
│   └── shared_materials/
├── animations/
│   ├── crystal_pulse_gentle.fbx
│   └── platform_movement.fbx
└── audio/
    ├── crystal_resonance_01.wav
    └── ambient_atmosphere.ogg
```

#### Version Control Requirements

- **Commit Frequency**: Daily commits for work-in-progress assets
- **Version Tags**: Semantic versioning for milestone releases
- **Branching Strategy**: Feature branches for major asset additions
- **Review Process**: Peer review required for assets affecting gameplay
- **Documentation**: Commit messages describing asset changes and improvements

#### Handoff Documentation

- **Asset Specifications**: Technical details and usage guidelines
- **Integration Notes**: Special requirements for engine implementation
- **Performance Data**: Benchmark results and optimization recommendations
- **Known Issues**: Any limitations or workarounds required
- **Future Enhancements**: Planned improvements and upgrade paths

## 6. Platform-Specific Optimizations

### 6.1 Windows Desktop Optimizations

- **GPU Utilization**: Leverage dedicated graphics cards for enhanced visual effects
- **Memory Management**: Utilize available system RAM for asset caching
- **Threading**: Multi-threaded asset loading and processing
- **HDR Support**: Full HDR pipeline for compatible displays
- **Ray Tracing**: Optional enhanced reflections for high-end hardware

### 6.2 macOS Desktop Considerations

- **Metal API**: Native Metal rendering for optimal performance
- **Retina Display**: High-DPI asset variants for sharp visual quality
- **Thermal Management**: Performance scaling based on thermal conditions
- **Energy Efficiency**: Optimized rendering for battery-powered devices
- **Color Management**: Wide color gamut support for P3 displays

### 6.3 Linux Desktop Support

- **Vulkan API**: Cross-distribution graphics API compatibility
- **Distribution Testing**: Validation across Ubuntu, Fedora, Arch
- **Package Dependencies**: Minimal external library requirements
- **Performance Scaling**: Adaptive quality based on available hardware
- **Open Source**: Preference for open-source asset creation tools

### 6.4 Future Web Platform Preparation

- **WebGL Compatibility**: Shader complexity limits for web deployment
- **Asset Compression**: Aggressive compression for fast web loading
- **Progressive Loading**: Streaming asset delivery for web browsers
- **Bandwidth Optimization**: Multiple quality tiers for different connections
- **Browser Testing**: Cross-browser compatibility validation

## 7. Luminara-Specific Asset Categories

### 7.1 Structural Architecture Assets

#### Master Spire Components

- **Base Foundation**: 15,000-20,000 triangles, 4K texture resolution
- **Mid Section**: 10,000-15,000 triangles, 2K texture resolution
- **Crown Formation**: 8,000-12,000 triangles, 2K texture resolution
- **Detail Elements**: 1,000-3,000 triangles each, 1K texture resolution
- **LOD Variants**: 75%, 50%, 25% triangle reduction for LOD 1-3

#### Platform Systems

- **Large Platforms**: 2,000-5,000 triangles, 1K-2K textures
- **Medium Platforms**: 1,000-2,000 triangles, 1K textures
- **Small Platforms**: 500-1,000 triangles, 512px textures
- **Bridge Elements**: 1,000-3,000 triangles, 1K textures
- **Safety Railings**: 200-500 triangles, shared 512px textures

### 7.2 Environmental Detail Assets

#### Crystal Formations

- **Large Crystals**: 1,000-3,000 triangles, 1K textures
- **Medium Crystals**: 500-1,000 triangles, 512px textures
- **Small Crystals**: 100-500 triangles, 256px textures
- **Crystal Clusters**: 2,000-5,000 triangles, 1K-2K textures
- **Sprite Variants**: 64px-256px for distant detail elements

#### Organic Elements

- **Luminous Moss**: Sprite-based, 32px-128px textures
- **Crystal Flowers**: 100-300 triangles, 256px textures
- **Vine Systems**: Spline-based generation, 128px-512px textures
- **Atmospheric Particles**: 16px-64px sprite textures
- **Bio-luminescent Effects**: Additive blend sprites

## 3. Sprite & Texture Requirements

- **Format:** `.png` (with transparency where needed).
- **Color Profile:** sRGB.
- **Resolution (General Environmental Tiles/Props):**
  - **Standard Tile Size:** e.g., 64x64 pixels or 128x128 pixels (to be finalized based on game scale and visual style). This will be the base unit for many environmental assets.
  - **Props/Decorations:** Sized appropriately relative to the player character and tile size. Aim for dimensions that are multiples of 2 or 4 for better packing in sprite sheets (e.g., 32x64, 128x256).
- **Resolution (Characters):**
  - **Player (Kael):** Approximate height of 128-192 pixels at 1x scale (to be refined based on in-game feel and camera zoom).
  - **NPCs (Mira, etc.):** Similar scale to the player, with variations based on character design.
  - **Enemies:** Varied, but scaled appropriately against the player.
- **Sprite Sheets:**
  - Use TexturePacker or similar tools for efficient packing.
  - Allow for 1-2 pixels of padding between sprites to prevent bleeding.
  - Export accompanying data file (JSON hash/array usually) that defines sprite frames and animations.
- **Transparency:** Use alpha channels for transparency. Avoid pure black or white for transparent areas unless specifically intended.
- **Power of Two:** While not a strict necessity for individual sprites in Flame, larger sprite sheets or repeating background textures should ideally have dimensions that are powers of two (e.g., 512x512, 1024x1024, 2048x1024) for optimal memory usage and compatibility.

## 4. Character Animation Requirements

- **Frame Rate:** Target 12-15 FPS for most character sprite animations (e.g., idle, run, jump). This can be adjusted for faster or slower actions.
- **Key Poses:** Ensure clear key poses for readability and impact.
- **Looping:** Animations intended to loop (idle, run) must loop seamlessly.
- **Essential Animations (Player - Kael):**
  - Idle (subtle breathing, Aether glow pulse)
  - Run
  - Jump (take-off, apex, falling)
  - Land (impact)
  - Hurt/Damage
  - Death
  - Basic Attack (if applicable in early sprints)
  - Aether Ability Cast (placeholder/generic)
- **Essential Animations (NPC - Mira):**
  - Idle (gentle sway, looking around)
  - Talking (variations for expressiveness)
  - Interaction Cue (e.g., looking at player, subtle gesture)
- **Sprite Pivots:** Define consistent pivot points for character sprites (usually bottom-center or logical center of mass) for smooth animation and placement.

## 5. UI Element Requirements

- **Format:** `.png`.
- **Resolution:** Design for 1080p, provide 1x and 2x assets.
- **9-Slice Scaling:** For buttons, panels, and other scalable UI elements, design them to be compatible with 9-slice scaling to maintain borders and corners correctly.
- **States:** Provide separate assets for different UI states (e.g., normal, hover, pressed, disabled) where necessary.
- **Font Integration:** UI designs should account for text legibility using the game's chosen fonts.
- **Clarity & Readability:** Prioritize clarity and readability over excessive ornamentation.

## 6. Environmental Asset Requirements

- **Tilemaps/Tilesets:**
  - Individual tiles should be seamless when tiled together.
  - Organize tilesets logically (e.g., ground, walls, platforms, decorations).
- **Parallax Backgrounds:**
  - Provide separate layers as `.png` files.
  - Ensure edges can scroll infinitely without visible seams if they are looping backgrounds.
  - Consider resolution carefully to balance detail and performance (e.g., a background layer might be 1920x1080, while a further one might be smaller and tiled).
- **Props & Decorations:**
  - Ensure consistent lighting and perspective with the overall scene style.
  - Pivot points should be logical for placement (usually bottom-center).

## 7. Effects (FX) Requirements

- **Format:** `.png` sprite sheets.
- **Animations:** Similar to character animations, ensure clear keyframes and smooth looping if applicable.
- **Examples:** Jump dust, landing impact, Aether shimmer, item pickup glow, hit sparks.
- **Additive Blending:** Some effects (glows, sparks) might benefit from additive blending; design with this in mind (e.g., dark backgrounds in the sprite).

## 8. Audio Asset Requirements

- **General:**
  - **Sample Rate:** 44.1kHz or 48kHz.
  - **Bit Depth:** 16-bit or 24-bit for source WAVs.
  - **Channels:** Mono for most SFX, Stereo for music and ambient soundscapes.
  - **Loudness:** Normalize audio to a consistent level (e.g., -16 LUFS for SFX, -14 LUFS for music) to avoid large volume discrepancies. Use a limiter to prevent clipping.
- **Sound Effects (SFX):**
  - **Export Format:** `.wav` or `.ogg` (prefer `.wav` for very short, frequently played sounds if `.ogg` decoding overhead is an issue; otherwise `.ogg` for better compression).
  - **Looping:** SFX intended to loop (e.g., a sustained magical effect) must be seamless.
  - **Variations:** Provide 2-3 variations for common sounds (e.g., footsteps, impacts) to reduce repetitiveness.
- **Music:**
  - **Export Format:** `.ogg` (Vorbis quality 6-8 typically a good balance).
  - **Looping:** Music tracks designed to loop must have clean loop points.
  - **Intro/Outro:** Provide separate intro/outro sections if music needs to fade in/out dynamically or have a distinct start/end.
- **Ambient Sounds:**
  - **Export Format:** `.ogg`.
  - **Looping:** Must be seamless for continuous background atmosphere.

## 9. Font Requirements

- **Format:** `.ttf` or `.otf`.
- **Legibility:** Choose fonts that are clear and readable at various sizes, especially for UI text and dialogue.
- **Character Set:** Ensure the font includes all necessary characters (e.g., special symbols, accented characters if localization is planned).

This document will be updated as asset needs become more specific during development.

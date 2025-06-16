# Art Style Guide - Luminara & Aetheris

_Last Updated: January 2025_

## 1. Overview

This document defines the overarching art style for "Adventure Jumper," focusing on the world of Aetheris and the central hub of Luminara. The goal is to create a visually cohesive, vibrant, and memorable stylized aesthetic that aligns with the game's core design pillars.

> **Related Documents:**
>
> - [Asset Pipeline](AssetPipeline.md) - Technical asset delivery processes
> - [Asset Requirements](AssetRequirements.md) - Technical specifications and constraints
> - [Luminara Concept Art](LuminaraConceptArt.md) - Detailed visual concepts
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Core design principles

**Core Inspirations:**

- Crystalline structures, bioluminescent flora/fauna, ancient ruins with advanced technology
- Games like Ori and the Blind Forest (lighting, atmosphere), Hollow Knight (world detail, character design), and Transistor (color palette, UI)
- Natural crystal formations, Art Nouveau architecture, and ethereal lighting phenomena

## 2. Visual Pillars

### 2.1 Luminous & Crystalline

Aetheris is a world infused with Aether energy, manifesting as glowing crystals, ethereal light, and shimmering surfaces. Luminara, in particular, should feel like a city carved from and grown within giant, glowing crystals.

**Technical Implementation:**

- Crystal surfaces use refractive properties with internal light scattering
- Aether energy creates volumetric lighting with particle systems
- Multiple light sources create complex, beautiful shadow patterns
- Reflective and translucent materials dominate the architectural palette

### 2.2 Ancient & Mysterious

The world is fractured and ancient. Ruins, overgrown structures, and forgotten technology should hint at a deep history and lost civilization.

**Technical Implementation:**

- Weathering and age effects on all surfaces
- Organic overgrowth interweaving with crystalline structures
- Technology that appears both advanced and dormant
- Visual storytelling through environmental details

### 2.3 Vibrant & Contrasting

While mysterious, the world should not be drab. Use a rich color palette with strong contrasts, especially between the glowing Aether elements and the darker, shadowed areas.

**Technical Implementation:**

- High dynamic range lighting with bloom effects
- Strong value contrasts between light and shadow areas
- Saturated accent colors against neutral base tones
- Color temperature variations to create depth and interest

### 2.4 Stylized Realism

Aim for a look that is detailed and believable within its own fantastical context, but not photorealistic. Characters and environments should have a distinct, slightly exaggerated style.

**Technical Implementation:**

- Simplified but consistent lighting models
- Exaggerated proportions for readability and character
- Texture work that suggests detail without overwhelming complexity
- Clear silhouettes and readable forms at game resolution

## 3. Luminara-Specific Color Palette

### 3.1 Primary Aether Colors

- **Aether Blue Core**: `#00BFFF` (DeepSkyBlue) - Primary crystal glow, magical effects
- **Crystal Cyan**: `#40E0D0` (Turquoise) - Common crystal formations, ambient lighting
- **Luminous Teal**: `#20B2AA` (LightSeaGreen) - Mid-tone crystal refractions
- **Energy Azure**: `#87CEEB` (SkyBlue) - Soft ambient glows, particle effects

### 3.2 Secondary Aether Colors

- **Radiant Purple**: `#9370DB` (MediumPurple) - Rarer Aether manifestations, ancient tech
- **Energy Gold**: `#FFD700` (Gold) - Highlights, powerful Aether sources, interactive elements
- **Mystic Violet**: `#8A2BE2` (BlueViolet) - Deep crystal cores, shadow reflections
- **Ethereal Lavender**: `#E6E6FA` (Lavender) - Soft particle effects, crystal highlights

### 3.3 Environmental Support Colors

- **Ancient Stone**: `#708090` (SlateGray) - Base architecture, non-crystalline structures
- **Shadow Indigo**: `#483D8B` (DarkSlateBlue) - Deep shadows, cavern areas
- **Weathered Platinum**: `#C0C0C0` (Silver) - Aged crystal surfaces, reflective highlights
- **Moss Emerald**: `#228B22` (ForestGreen) - Organic overgrowth (used sparingly)

### 3.4 Accent & Detail Colors

- **Warm Amber**: `#FFBF00` (Amber) - Interactive elements, quest items
- **Coral Pink**: `#FF7F50` (Coral) - Warning elements, danger indicators
- **Pearl White**: `#F8F8FF` (GhostWhite) - Pure light sources, special effects
- **Deep Void**: `#191970` (MidnightBlue) - Deepest shadows, negative space

## 4. Crystalline Architecture Specifications

### 4.1 Primary Crystal Types

#### Structural Crystals (Large Architecture)

- **Geometry**: Hexagonal prisms, rhombohedral clusters, massive geodes
- **Surface**: Faceted with 6-12 major faces, creating complex light reflections
- **Scale**: 2-20 meters in height, forming building foundations and walls
- **Materials**: Translucent to semi-opaque, internal light sources visible
- **Color**: Primarily Azure to Teal range with Golden highlights at connection points

#### Support Crystals (Medium Elements)

- **Geometry**: Elongated hexagonal columns, crystal bridges
- **Surface**: Smooth faces with internal fracture patterns
- **Scale**: 0.5-3 meters, connecting platforms and creating pathways
- **Materials**: Semi-transparent with visible internal energy flows
- **Color**: Cyan to Purple gradient based on energy intensity

#### Detail Crystals (Small Decorative)

- **Geometry**: Perfect quartz formations, cluster arrangements
- **Surface**: Sharp, angular cuts creating prismatic effects
- **Scale**: 5cm-50cm, decorative and functional lighting
- **Materials**: Highly refractive, acting as natural light sources
- **Color**: Full spectrum based on function (Blue=information, Gold=interaction, Purple=mystery)

### 4.2 Architectural Integration Principles

#### Organic Growth Patterns

- Crystals appear to have grown naturally from seed points
- Irregular but harmonious placement following geological principles
- Integration with ancient stone foundations suggests symbiotic growth
- Natural weathering and age effects on crystal surfaces

#### Functional Integration

- Crystal formations serve architectural purposes (support, lighting, power)
- Energy conduits visible as glowing veins within crystal structures
- Interactive elements clearly distinguished through brighter illumination
- Pathway guidance through strategic crystal placement and lighting

#### Vertical Design Philosophy

- Emphasis on height and ascending pathways reflecting gameplay
- Multiple levels connected by crystal bridges and floating platforms
- Clear visual hierarchy from base (stone) to peak (pure crystal)
- Dramatic verticality creating sense of awe and scale

## 5. Advanced Lighting System Specifications

### 5.1 Primary Light Sources

#### Aether Crystal Illumination

- **Intensity**: Soft to medium, never harsh or glaring
- **Color Temperature**: Cool blues (5000K-7000K) with warm gold accents (2700K-3000K)
- **Behavior**: Gentle pulsing (1-2 second cycles), reactive to player proximity
- **Range**: 3-8 meter illumination radius with soft falloff
- **Effects**: Volumetric rays, subtle particle emission, surface reflections

#### Architectural Accent Lighting

- **Intensity**: Low to medium, providing ambient fill light
- **Color Temperature**: Warm whites (3000K-4000K) for comfort areas
- **Behavior**: Steady with occasional gentle fluctuations
- **Range**: Wide area illumination for navigation and atmosphere
- **Effects**: Soft glow on crystalline surfaces, indirect bounced lighting

#### Interactive Element Lighting

- **Intensity**: Medium to high for clear visibility
- **Color Temperature**: Golden yellows (2500K-3000K) for interactables
- **Behavior**: Subtle pulsing or shimmer to indicate interactivity
- **Range**: Focused lighting drawing attention
- **Effects**: Enhanced contrast, clear visual separation from environment

### 5.2 Dynamic Lighting Behaviors

#### Time-of-Day Variations

- **Dawn**: Soft purple-blue ambient with golden highlights
- **Day**: Bright azure primary lighting with silver accents
- **Dusk**: Deep blue ambient with increased golden warmth
- **Night**: Minimal ambient, crystal lighting becomes primary source

#### Player-Responsive Lighting

- **Proximity Activation**: Crystals brighten as player approaches (2-meter trigger radius)
- **Path Illumination**: Subtle lighting chain reactions along travel routes
- **Aether Resonance**: Player's aether abilities create temporary lighting enhancement
- **Memory Lighting**: Previously visited areas maintain slight luminance increase

#### Narrative Lighting States

- **Neutral**: Standard illumination patterns as described above
- **Mystery/Discovery**: Reduced ambient, focused dramatic lighting
- **Celebration/Achievement**: Increased brightness, golden color shift, particle effects
- **Tension/Danger**: Cooler temperatures, flickering patterns, contrast enhancement

## 6. Material & Texture Specifications

### 6.1 Crystal Materials

#### Primary Crystal Surfaces

- **Base Texture**: Smooth with subtle internal fracture patterns
- **Reflection**: 60-80% reflectivity with environmental mapping
- **Refraction**: Index of 1.5-1.8 creating realistic light bending
- **Transparency**: 40-70% opacity allowing internal lighting visibility
- **Surface Details**: Micro-faceting for light scattering, age wear patterns

#### Aged Crystal Surfaces

- **Base Texture**: Weathered with surface etching and minor chips
- **Reflection**: 40-60% reflectivity with scattered highlights
- **Refraction**: Slightly reduced clarity from surface imperfections
- **Transparency**: 30-50% opacity with internal clouding effects
- **Surface Details**: Moss growth, sediment deposits, structural stress marks

### 6.2 Support Materials

#### Ancient Stone Foundations

- **Texture**: Carved granite with tool marks and architectural details
- **Color**: Warm gray (`#A9A9A9`) to cool gray (`#708090`) variations
- **Weathering**: Significant age effects, erosion patterns, plant growth
- **Integration**: Seamless blending with crystal formations
- **Details**: Carved glyphs, decorative reliefs, structural reinforcements

#### Metallic Accents

- **Material**: Tarnished copper, aged bronze, corroded silver
- **Application**: Structural supports, decorative elements, ancient technology
- **Patina**: Natural aging effects appropriate to crystal environment
- **Function**: Aether conductivity suggested through design integration

## 7. Particle & Effects Systems

### 7.1 Ambient Aether Particles

- **Density**: Sparse (5-10 particles per cubic meter of visible space)
- **Size**: 1-3 pixels at base resolution, with size variation
- **Movement**: Slow drift with gentle swirling patterns
- **Color**: Soft cyan (`#E0FFFF`) with occasional golden (`#FFD700`) variants
- **Behavior**: Attracted to crystal surfaces, increased density near major formations
- **Lifetime**: 8-15 seconds with soft fade in/out

### 7.2 Crystal Resonance Effects

- **Trigger**: Player proximity, interaction, or story moments
- **Visual**: Ripples of light across crystal surfaces
- **Color**: Matching the triggering crystal's base color with increased intensity
- **Speed**: Moderate propagation (2-3 meters per second)
- **Duration**: 2-4 seconds with smooth falloff
- **Sound**: Synchronized with audio resonance effects

### 7.3 Environmental Atmosphere

- **Mist**: Subtle volumetric fog with light scattering properties
- **Dust Motes**: Occasional floating particles in light beams
- **Energy Wisps**: Rare, larger particles following energy flow patterns
- **Bloom Effects**: Soft glow around all light sources with 20-30% intensity
- **God Rays**: Volumetric lighting through crystal formations and architectural openings

## 8. Character Design Integration

### 8.1 Player Character (Kael) in Luminara Context

- **Lighting Response**: Character receives appropriate crystal lighting on all surfaces
- **Aether Integration**: Visible aether energy patterns on character during abilities
- **Scale Relationship**: Character proportions clearly readable against crystal architecture
- **Color Harmony**: Character palette complements but doesn't clash with environmental colors

### 8.2 NPC Integration

- **Mira (Archivist)**: Softer lighting in library areas, scholarly color palette
- **Rook (Tinker)**: Workshop lighting with warmer tones, metallic accents
- **Citizens**: Varied lighting responses based on location and narrative role

## 9. Technical Performance Guidelines

### 9.1 Optimization Targets

- **Lighting Sources**: Maximum 8-12 dynamic lights per scene
- **Particle Systems**: Target 100-200 active particles maximum
- **Material Complexity**: 2-3 texture layers per crystal material
- **Reflection Quality**: Real-time reflections for primary crystals only
- **Shadow Quality**: Medium quality shadows with 2-meter maximum range

### 9.2 Scalability Settings

- **Low**: Single bounce lighting, reduced particle count, simplified materials
- **Medium**: Standard settings as specified above
- **High**: Enhanced bloom, additional particle layers, improved reflection quality
- **Ultra**: Maximum visual fidelity with all effects enabled

## 10. Asset Creation Workflow

### 10.1 Concept Phase

1. **Reference Gathering**: Real crystal formations, architectural precedents
2. **Mood Studies**: Lighting and atmosphere exploration
3. **Color Tests**: Palette validation in various lighting conditions
4. **Scale Studies**: Proportion verification against character

### 10.2 Production Phase

1. **Blockout**: Basic geometry and lighting setup
2. **Primary Detail**: Crystal formation and architectural elements
3. **Secondary Detail**: Weathering, organic integration, small elements
4. **Lighting Pass**: Full illumination setup and particle integration
5. **Polish Pass**: Final effects, optimization, and quality validation

### 10.3 Quality Validation

- **Design Cohesion**: Adherence to established design pillars
- **Technical Performance**: Frame rate and memory usage validation
- **Readability**: Gameplay clarity at target resolution
- **Aesthetic Impact**: Visual appeal and atmospheric effectiveness

## 11. Implementation Guidelines

### 11.1 Modular Design Principles

- **Crystal Components**: Reusable crystal formations with consistent connection points
- **Architectural Elements**: Standardized platform, bridge, and structural components
- **Lighting Rigs**: Preset lighting configurations for different area types
- **Material Variants**: Base materials with customizable parameters for variety

### 11.2 Version Control and Iteration

- **Asset Versioning**: Clear version tracking for all visual elements
- **Feedback Integration**: Systematic collection and implementation of visual feedback
- **Performance Monitoring**: Regular assessment of visual impact on frame rate
- **Style Consistency**: Regular review against established style guidelines

This guide serves as the foundation for all visual development in Luminara and establishes the technical and artistic standards for crystal architecture, lighting systems, and atmospheric effects that will create the memorable, cohesive experience outlined in our Design Cohesion Guide.

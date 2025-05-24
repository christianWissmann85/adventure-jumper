# Audio Style Guide

This document outlines the audio design standards and guidelines for the Adventure Jumper project.

## Audio Direction

### Sound Identity
Adventure Jumper's audio combines retro game music sensibilities with modern production techniques. The soundscape emphasizes atmospheric world-building while providing clear gameplay feedback through distinct sound effects.

### Audio Pillars
1. **Responsive Feedback**: Sound effects provide clear, immediate response to player actions
2. **World Immersion**: Environmental audio brings each zone to life
3. **Emotional Progression**: Music enhances the narrative and emotional journey
4. **Aether Identity**: Consistent sonic representation of the game's core Aether energy

## Technical Specifications

### General Audio
- **Sample Rate**: 44.1 kHz
- **Bit Depth**: 16-bit
- **Channels**: Stereo (music), Mono or stereo (SFX)
- **Format**: WAV (development), OGG Vorbis (final game)

### Music
- **Looping**: Seamless loops with natural transition points
- **Duration**: 2-4 minutes per track
- **Layering**: Multiple stems (4-6) for dynamic mixing
- **Implementation**: Dynamic layering based on game state/intensity

### Sound Effects
- **Length**: Typically 0.5-2.0 seconds
- **Variation**: 2-4 variations per common sound
- **Dynamics**: Normalized with appropriate headroom
- **Category System**: Organized by function (UI, player, environment, etc.)

## Music Guidelines

### Musical Style
- **Base Style**: Modern chiptune with orchestral elements
- **Instrumentation**: 8-bit synthesis, modern synths, subtle orchestral elements
- **Harmonic Language**: Major scales for hub areas, modal scales for different zones
- **Tempo Range**: 80-140 BPM depending on zone and intensity

### Zone-Specific Music

#### Luminara (Hub)
- **Key**: D Major
- **Tempo**: 92 BPM
- **Mood**: Welcoming, mysterious, hopeful
- **Prominent Instruments**: Bell-like synths, soft pads, gentle arpeggios
- **Dynamic Range**: Moderate, allowing for quiet moments

#### Verdant Canopy
- **Key**: G Mixolydian
- **Tempo**: 108 BPM
- **Mood**: Organic, alive, mysterious
- **Prominent Instruments**: Woodwind-like synths, organic percussion, ambient texture
- **Dynamic Range**: Wide, from quiet ambient sections to full exploration themes

#### Forge Peaks
- **Key**: C Phrygian
- **Tempo**: 126 BPM
- **Mood**: Industrial, dangerous, intense
- **Prominent Instruments**: Heavy percussion, distorted bass, metallic hits
- **Dynamic Range**: Generally high intensity with brief respites

#### Celestial Archive
- **Key**: A Lydian
- **Tempo**: 88 BPM
- **Mood**: Otherworldly, contemplative, vast
- **Prominent Instruments**: Ethereal pads, distant choirs, crystalline arpeggios
- **Dynamic Range**: Wide, emphasizing space and atmosphere

#### Void's Edge
- **Key**: Shifting between E minor and atonal
- **Tempo**: Varies (80-140 BPM) with unstable time signatures
- **Mood**: Unsettling, disorienting, climactic
- **Prominent Instruments**: Glitched sounds, distorted elements, powerful bass
- **Dynamic Range**: Extreme, from near silence to overwhelming intensity

### Interactive Music System

- **Layering**: Base, rhythm, melody, tension, and ambient tracks per zone
- **Transition Points**: Defined musical phrases for clean transitions
- **Intensity Levels**: 3-4 intensity levels per zone theme
- **Vertical Mixing**: Real-time adjustment of stems based on gameplay state

## Sound Effect Guidelines

### Player Character

#### Movement
- **Footsteps**: Light, quick sounds varying by surface
- **Jump**: Short upward swoosh with slight "effort" sound
- **Land**: Impact sound based on height and surface
- **Wall Slide**: Continuous friction sound, slightly granular
- **Dash**: Quick whoosh with slight Aether "sparkle"

#### Combat/Abilities
- **Basic Attack**: Sharp, quick impact with slight whoosh
- **Charged Attack**: Build-up sound + more powerful impact
- **Special Ability**: Distinct Aether "activation" sound + ability-specific effect
- **Take Damage**: Short vocal "hurt" sound + impact
- **Death**: More dramatic falling sound + brief sad musical motif

### Environment

#### Interactive Elements
- **Collectible**: Bright, pleasant sound (distinct by type)
- **Door/Gate**: Mechanical movement appropriate to material
- **Platform**: Subtle mechanical or magical sound based on type
- **Lever/Switch**: Distinctive "click" with mechanical follow-through

#### Zone-Specific
- **Luminara**: Gentle wind, distant chimes, ethereal whispers
- **Verdant Canopy**: Rustling leaves, animal calls, creaking wood
- **Forge Peaks**: Steam vents, distant machinery, rumbling
- **Celestial Archive**: Pages turning, magical hums, reality shifts
- **Void's Edge**: Wind through voids, distant whispers, reality cracking

### UI Sounds
- **Button Select**: Quick, subtle click
- **Button Confirm**: Positive, slightly musical confirmation
- **Menu Open/Close**: Smooth whoosh with slight musical element
- **Error**: Short, distinctive "negative" sound
- **Achievement/Milestone**: Celebratory musical flourish

## Asset Naming and Organization

### File Naming Convention
- `mus_[zone]_[variant].ogg` - Music files
- `sfx_player_[action].wav` - Player sound effects
- `sfx_enemy_[type]_[action].wav` - Enemy sound effects
- `sfx_env_[zone]_[source].wav` - Environmental sounds
- `sfx_ui_[element]_[state].wav` - UI sounds
- `amb_[zone]_[variant].wav` - Ambient loops

### Folder Structure
```
assets/
└── audio/
    ├── music/
    │   ├── luminara/
    │   ├── verdant/
    │   └── ...
    ├── sfx/
    │   ├── player/
    │   ├── enemies/
    │   ├── environment/
    │   └── ui/
    └── ambience/
        ├── luminara/
        ├── verdant/
        └── ...
```

## Implementation Guidelines

### General Practices
- Avoid abrupt starts and cuts in sounds
- Use appropriate fades for music transitions (typically 1-3 seconds)
- Implement 3D positional audio for environment and enemy sounds
- Use audio pooling for frequently played sounds

### Mixing Guidelines
- **Overall Mix**: -14 LUFS integrated loudness target
- **Music**: -18 LUFS, ducking slightly during key gameplay moments
- **SFX**: Peak around -6 dB with sufficient headroom
- **Voice/Important Sounds**: Prioritized in mix

### Volume Categories
- Master Volume
- Music Volume
- SFX Volume
- Ambient Volume
- UI Volume

### Performance Considerations
- Limit concurrent sounds (max 16-24 simultaneous sounds)
- Use sound priority system for high-intensity moments
- Lower quality settings for mobile/lower-end devices
- Stream longer audio files, load shorter ones into memory

## Asset Delivery Specifications

### Music
- OGG format, 128-160kbps
- Stems provided separately for dynamic mixing
- Loops marked with cue points
- Variations labeled clearly

### Sound Effects
- WAV format, 16-bit/44.1kHz
- Processed and normalized
- Trimmed to remove unnecessary silence
- Metadata includes category and description

## Quality Control

### Audio Review Checklist
- [ ] Sounds are consistent with overall game aesthetic
- [ ] No clipping or technical issues
- [ ] Appropriate volume relative to other sounds
- [ ] Correctly looping where applicable
- [ ] Positional audio working correctly for 3D sounds
- [ ] Variations sufficient to avoid repetition fatigue
- [ ] Music transitions occur smoothly
- [ ] All sound categories properly balanced

## Related Documents

### External References
- [Audio Design Document](https://audio-design.link) (Internal link)
- [Zone Music References](https://music-reference.link) (Internal link)
- [Sound Effect Library](https://sfx-library.link) (Internal link)

### Project Documents
- [Audio System TDD](../02_Technical_Design/TDD/AudioSystem.TDD.md) - Technical implementation of audio systems
- [World Documents](../01_Game_Design/Worlds/) - World-specific audio requirements
- [Implementation Guide](../03_Development_Process/ImplementationGuide.md) - Implementation standards for audio integration

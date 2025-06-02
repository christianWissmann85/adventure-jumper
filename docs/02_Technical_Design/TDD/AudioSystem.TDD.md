# Audio System - Technical Design Document

## 1. Overview

Defines the implementation of the audio system for Adventure Jumper, focusing on responsive audio feedback that enhances **Fluid & Expressive Movement**, supports **Engaging & Dynamic Combat**, and provides clear progression feedback for **Progressive Mastery**. The audio system prioritizes immediate player feedback and immersive world-building.

> **Related Documents:**
>
> - [AudioStyle Guide](../../05_Style_Guides/AudioStyle.md) - Audio style guidelines and standards
> - [SystemIntegration TDD](SystemIntegration.TDD.md) - Cross-system communication protocols and coordination patterns
> - [PhysicsSystem TDD](PhysicsSystem.TDD.md) - Physics state queries for movement audio feedback
> - [MovementSystem TDD](MovementSystem.TDD.md) - Movement coordination for audio synchronization
> - [PlayerCharacter TDD](PlayerCharacter.TDD.md) - Integration with player movement audio
> - [Physics-Movement Refactor Action Plan](../../action-plan-physics-movement-refactor.md) - Refactor strategy
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Design pillars and validation criteria
> - [Agile Sprint Plan](../../04_Project_Management/AgileSprintPlan.md) - Implementation timeline
> - [System Architecture](../Architecture.md) - Audio system integration with overall architecture
> - [Asset Pipeline](../AssetPipeline.md) - Audio asset creation and management workflow
> - [UI System TDD](UISystem.TDD.md) - UI sound feedback integration

### Purpose

- **Primary**: Provide immediate, responsive audio feedback supporting Design Pillars
- Create immersive audio that enhances rather than distracts from gameplay flow
- Implement responsive sound effects with minimal latency for player actions
- Support clear audio communication for combat feedback and environmental cues
- Manage dynamic music transitions that match gameplay intensity and progression
- Handle spatial audio that aids navigation and situational awareness
- Support world-specific audio themes that reinforce distinct world identities

### Scope

- Music playback with dynamic transitions matching gameplay flow
- Sound effect management prioritizing responsiveness and clarity
- Spatial audio implementation supporting exploration and combat awareness
- Dynamic audio mixing that adapts to gameplay intensity
- World-specific audio theming enhancing immersion
- Performance optimization ensuring no audio-related frame drops
- Accessibility options for diverse player needs

### Design Cohesion Focus Areas

This audio system specifically supports all three Design Pillars:

**Fluid & Expressive Movement:**

- Immediate audio feedback for movement actions (<50ms latency)
- Movement-integrated sound design that flows with player actions
- Audio cues that support movement rhythm and timing

**Engaging & Dynamic Combat:**

- Clear audio distinction between different combat actions and outcomes
- Spatial audio for situational awareness in combat
- Dynamic music intensity matching combat engagement level

**Progressive Mastery:**

- Audio progression that matches skill development
- Clear feedback for successful technique execution
- Celebration audio for achievement and progression moments

## 2. Class Design

### Core Audio Classes

```dart
// Main audio system manager
class AudioSystem extends BaseSystem {
  // Music management
  // Sound effect coordination
  // Audio mixing
  // Audio state tracking

  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has an audio component
    return entity.children.whereType<AudioComponent>().isNotEmpty;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Update spatial audio for entities with audio components
    final audioComponents = entity.children.whereType<AudioComponent>();
    for (final audio in audioComponents) {
      // Update listener position and sound properties
      audio.updateListenerPosition(_listenerPosition);
    }
  }
}

// Music management
class MusicManager {
  // Track playback
  // Transitions and crossfading
  // Dynamic layering
  // Theme management
}

// Sound effect manager
class SoundEffectManager {
  // Effect playback
  // Effect pooling
  // Spatial audio
  // Priority management
}
```

### Supporting Classes

```dart
// Audio theme controller
class AudioTheme {
  // Theme assets
  // Sound parameters
  // Environmental settings
  // Ambient sound management
}

// Audio source component
class AudioSource extends GameComponent {
  // Spatial positioning
  // Attenuation settings
  // Priority and volume
  // Sound triggering
}

// Audio listener
class AudioListener extends GameComponent {
  // Player-attached listener
  // Orientation tracking
  // Environmental detection
  // Distance calculation
}
```

## 3. Data Structures

### Audio Configuration

```dart
class AudioConfig {
  double masterVolume;       // Master volume (0-1)
  double musicVolume;        // Music volume (0-1)
  double sfxVolume;          // Sound effects volume (0-1)
  double voiceVolume;        // Voice/dialogue volume (0-1)
  bool enableSpatialAudio;   // Spatial audio toggle
  bool enableDynamicMixing;  // Dynamic audio mixing toggle
  int maxSimultaneousSounds; // Maximum concurrent sounds
  bool reduceBackground;     // Reduce background sounds
  bool muteWhenUnfocused;    // Mute when game loses focus
}
```

### Music Track Data

```dart
class MusicTrackData {
  String trackId;           // Unique track identifier
  String assetPath;         // Track asset path
  double volume;           // Default volume (0-1)
  bool loops;              // Whether track should loop
  double introTime;        // Intro section duration
  double loopStartTime;    // Loop start timestamp
  double loopEndTime;      // Loop end timestamp
  double bpm;              // Beats per minute
  int timeSignature;       // Time signature
  Map<String, dynamic> layers; // Dynamic layers for track
  Map<String, double> transitionPoints; // Good transition points
}
```

### Sound Effect Data

```dart
class SoundEffectData {
  String effectId;          // Unique effect identifier
  String assetPath;         // Effect asset path
  List<String> variations;  // Alternative asset paths
  double baseVolume;        // Base volume level (0-1)
  double pitchVariation;    // Random pitch variation
  bool enableSpatial;       // Whether sound is spatial
  double minDistance;       // Minimum attenuation distance
  double maxDistance;       // Maximum audible distance
  int priority;            // Playback priority (higher = more important)
  double cooldown;         // Minimum time between plays
  String category;         // Effect category for mixing
}
```

### Audio Theme Data

```dart
class AudioThemeData {
  String themeId;           // Unique theme identifier
  String mainTrackId;       // Primary music track
  String combatTrackId;     // Combat music track
  String tensionTrackId;    // Tension/danger music track
  List<String> ambientSounds; // Looping ambient sounds
  List<String> randomSounds; // Random ambient effects
  Map<String, double> roomParameters; // Reverb/echo settings
  Map<String, double> eqSettings; // Equalizer settings
  Map<String, String> soundOverrides; // World-specific sound replacements
  double transitionTime;    // Theme transition time
}
```

## 4. Algorithms

### Dynamic Audio Mixing

```
function updateAudioMixing():
  // Base mix levels
  musicVolume = config.musicVolume * config.masterVolume
  sfxVolume = config.sfxVolume * config.masterVolume

  // Analyze game state
  playerHealth = getPlayerHealthPercentage()
  combatIntensity = getCombatIntensityLevel()
  environmentDensity = getEnvironmentalSoundDensity()

  // Adjust music based on state
  if isInCombat():
    // Fade in combat track
    fadeToTrack(currentAudioTheme.combatTrackId, COMBAT_TRANSITION_TIME)

    // Emphasize combat track based on intensity
    setMusicParameter("combatIntensity", combatIntensity)

    // Duck environmental sounds during intense combat
    if combatIntensity > HIGH_INTENSITY_THRESHOLD:
      environmentalVolumeMod = 1.0 - (combatIntensity * 0.5)
  else if isDangerNearby():
    // Transition to tension track
    fadeToTrack(currentAudioTheme.tensionTrackId, TENSION_TRANSITION_TIME)
  else:
    // Normal exploration music
    fadeToTrack(currentAudioTheme.mainTrackId, DEFAULT_TRANSITION_TIME)

  // Health-based audio adjustments
  if playerHealth < LOW_HEALTH_THRESHOLD:
    // Apply low health audio filter
    setLowPassFilter(LOW_HEALTH_FILTER_AMOUNT)

    // Emphasize heartbeat effect
    heartbeatVolume = (1.0 - (playerHealth / LOW_HEALTH_THRESHOLD)) * MAX_HEARTBEAT_VOLUME
    setEffectVolume("heartbeat", heartbeatVolume)

    // Reduce background sound volume
    environmentalVolumeMod *= playerHealth / LOW_HEALTH_THRESHOLD
  else:
    // Normal audio filtering
    clearAudioFilters()
    setEffectVolume("heartbeat", 0)

  // Apply environmental volume modifier
  setChannelVolume("environmental", config.sfxVolume * environmentalVolumeMod)
```

### Spatial Audio Calculation

```
function calculateSpatialAudio(audioSource, audioListener):
  // Skip calculation if spatial audio disabled
  if not config.enableSpatialAudio:
    return { volume: audioSource.baseVolume, pan: 0.0 }

  // Calculate distance
  distance = calculateDistance(audioSource.position, audioListener.position)

  // Apply distance attenuation
  if distance <= audioSource.minDistance:
    volume = audioSource.baseVolume
  else if distance >= audioSource.maxDistance:
    volume = 0.0
  else:
    // Calculate attenuation factor
    distanceFactor = (distance - audioSource.minDistance) / (audioSource.maxDistance - audioSource.minDistance)
    volume = audioSource.baseVolume * (1.0 - distanceFactor)

  // Calculate stereo panning
  toSource = normalize(audioSource.position - audioListener.position)
  listenerRight = audioListener.getOrientationRight()

  // Dot product to determine left/right positioning
  pan = dot(toSource, listenerRight)

  // Calculate occlusion if enabled
  if audioSource.checkOcclusion:
    occlusion = calculateOcclusion(audioSource.position, audioListener.position)
    volume *= (1.0 - occlusion)

  return { volume: volume, pan: pan }
```

### Music Transitions

```
function crossfadeToTrack(targetTrackId, duration):
  // If track is already playing, do nothing
  if currentTrackId == targetTrackId:
    return

  // Find good transition point if possible
  currentTrack = getMusicTrack(currentTrackId)
  currentPosition = getCurrentPlaybackPosition()
  transitionPoint = findNearestTransitionPoint(currentTrack, currentPosition)

  if transitionPoint - currentPosition < MAX_TRANSITION_WAIT:
    // Wait until good transition point
    wait(transitionPoint - currentPosition)

  // Start new track at low volume
  targetTrack = getMusicTrack(targetTrackId)
  targetStartPoint = findBestEntryPoint(targetTrack)

  // Start target track
  play(targetTrack, targetStartPoint, 0.0)

  // Begin crossfade
  startTime = getCurrentTime()

  while (getCurrentTime() - startTime < duration):
    progress = (getCurrentTime() - startTime) / duration
    smoothProgress = easeInOutCubic(progress)

    setTrackVolume(currentTrackId, 1.0 - smoothProgress)
    setTrackVolume(targetTrackId, smoothProgress)

    yield()

  // Finalize transition
  stop(currentTrackId)
  setTrackVolume(targetTrackId, 1.0)
  currentTrackId = targetTrackId
```

## 5. API/Interfaces

### Audio System Interface

```dart
interface IAudioSystem {
  void playMusic(String trackId);
  void playSoundEffect(String effectId, {double volume, double pitch, bool loop});
  void playSpatialSound(String effectId, Vector2 position);
  void stopSound(String instanceId);
  void setAudioTheme(String themeId);
  void pauseAudio(bool pause);
  void setMasterVolume(double volume);
  void setMusicVolume(double volume);
  void setSfxVolume(double volume);
}

interface IAudioListener {
  void setPosition(Vector2 position);
  void setOrientation(Vector2 forward, Vector2 up);
  Vector2 getPosition();
  Vector2 getOrientation();
}
```

### Audio Source Interface

```dart
interface IAudioSource {
  String play(String effectId);
  void stop();
  void setPitch(double pitch);
  void setVolume(double volume);
  void setPosition(Vector2 position);
  bool isPlaying();
}

interface IMusicManager {
  void playTrack(String trackId);
  void fadeToTrack(String trackId, double duration);
  void stopMusic();
  void setMusicParameter(String parameter, double value);
  String getCurrentTrack();
  double getTrackPosition();
}
```

## 6. Dependencies

### System Dependencies

- **Player Character**: For player position and state via ICharacterPhysicsCoordinator
- **Physics System**: For movement audio feedback via IPhysicsCoordinator (Priority: 80)
- **Movement System**: For movement state queries via IMovementCoordinator (Priority: 90)
- **Collision System**: For collision audio events via ICollisionNotifier (Priority: 70)
- **Level Management**: For world environment detection
- **Combat System**: For combat intensity tracking and audio coordination
- **Settings System**: For audio configuration and user preferences
- **Event System**: For triggering audio events and cross-system notifications

### Physics-Movement Integration Dependencies

- **IPhysicsCoordinator**: Interface for physics state queries supporting movement audio feedback
- **IMovementCoordinator**: Interface for movement state coordination and audio synchronization
- **ICollisionNotifier**: Interface for collision event audio feedback
- **Audio Timing Coordination**: Audio system operates at Priority 20 ensuring proper execution sequence
- **State Synchronization**: Audio feedback synchronized with physics and movement state changes
- **Performance Coordination**: Audio processing optimized to not interfere with physics/movement timing

### Technical Dependencies

- Audio playback library (platform-specific)
- Audio file loading and decoding
- Audio mixing and DSP effects
- File system access for audio assets

## 7. File Structure

```
lib/
  game/
    systems/
      audio/
        audio_system.dart           # Main audio system
        music_manager.dart          # Music handling
        sound_effect_manager.dart   # Sound effects
        audio_theme.dart            # Theme management
        audio_mixer.dart            # Dynamic mixing
        audio_config.dart           # Configuration
    components/
      audio/
        audio_source.dart           # Audio source component
        audio_listener.dart         # Audio listener component
        ambient_sound_zone.dart     # Ambient sound areas
        music_trigger.dart          # Music change triggers
    data/
      audio/
        music_data.dart             # Music track definitions
        sound_effect_data.dart      # Sound effect definitions
        audio_theme_data.dart       # Theme definitions
        audio_events.dart           # Event-sound mappings
assets/
  audio/
    music/                          # Music tracks
      luminara/                     # World-specific music
      verdant/
      forge/
      archive/
      void/
    sfx/                           # Sound effects
      player/                      # Player-related sounds
      enemies/                     # Enemy sounds
      environment/                 # Environmental sounds
      ui/                         # UI sounds
    ambient/                       # Ambient loops
    voice/                        # Voice clips
```

## 8. Performance Considerations

### Optimization Strategies

- Sound effect pooling and reuse
- Sound prioritization and culling
- Distance-based sound activation
- Dynamic sample rate adjustment
- Streaming for large music files

### Memory Management

- Efficient audio buffer management
- Unloading unused sound assets
- Shared sound data across instances
- Progressive loading of audio themes

## 9. Testing Strategy

### Unit Tests

- Sound effect playback timing and response latency (<50ms target)
- Music transitions and layering smoothness verification
- Audio parameter calculations and distance attenuation
- Configuration loading and accessibility options

### Integration Tests

- Spatial audio positioning accuracy and player awareness support
- Music-gameplay state synchronization and emotion enhancement
- Performance under many sound sources with prioritization
- Memory usage during world transitions and asset streaming

### Design Cohesion Testing

- **Movement Support Tests**: Verify audio enhances movement flow
- **Combat Feedback Tests**: Confirm clear combat audio distinctions
- **Progressive Audio Tests**: Check audio evolution matches progression
- **Accessibility Verification**: Ensure audio provides essential gameplay information in multiple ways

## 10. Implementation Notes

### Sprint-Aligned Development Phases

**Sprint 1-2: Audio Foundation**

- Basic sound playback system with immediate feedback for player actions
- Simple music playback with static tracks
- Core audio asset loading and performance optimization
- Initial sound effect library for player movement
- _Validation_: <50ms audio latency for all player actions

**Sprint 3-4: Responsive Audio System**

- Spatial audio implementation supporting player awareness
- Basic dynamic music transitions between game states
- Sound effect pooling for performance optimization
- Complete movement and combat audio feedback
- _Validation_: Audio enhances rather than interrupts gameplay flow

**Sprint 5-6: Dynamic Audio Experience**

- Advanced dynamic mixing based on gameplay state
- Combat intensity-driven music system
- Environmental sound systems for world immersion
- Audio accessibility options implementation
- _Validation_: Audio clearly communicates gameplay information

**Sprint 7+: World-Specific Audio Identity**

- Distinct audio themes for each world with seamless transitions
- Advanced adaptive music system with layering
- Audio-driven gameplay feedback enhancement
- Final audio performance optimizations
- _Validation_: Each world has distinctive, cohesive audio identity

### Design Cohesion Validation Metrics

**Audio Responsiveness Metrics:**

- **Movement Feedback Latency**: <50ms for all player actions
- **Combat Audio Clarity**: 100% distinguishable combat sounds
- **Music Transition Smoothness**: No jarring transitions during gameplay
- **Audio Priority System**: Critical gameplay audio never obscured

**Player Experience Validation:**

- Audio enhances sense of fluid movement
- Combat actions receive clear, immediate audio feedback
- Audio changes signal progression and mastery moments
- Sound design supports rather than distracts from gameplay focus

### Audio Design Principles Supporting Cohesion

- **Responsive Feedback**: Immediate audio response to support fluid gameplay
- **Clear Communication**: Distinct sounds for different gameplay states
- **Progressive Identity**: Audio that evolves with player progression
- **Emotional Support**: Music that enhances narrative and emotional moments
- **Cohesive Worldbuilding**: Sound design that strengthens world identity

## 11. Future Considerations

### Expandability

- Interactive music system with instrument layers
- Procedural audio generation
- Voice acting integration
- User audio customization

### Advanced Features

- Acoustic simulation based on environment
- Advanced DSP effects for special areas
- Mood-based adaptive music system
- Audio-driven gameplay elements

## Related Design Documents

- See [Audio Style Guide](../../05_Style_Guides/AudioStyle.md) for audio design standards
- See [Worlds Documentation](../../01_Game_Design/Worlds/README.md) for world-specific soundscapes
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for audio feedback integration
- See [UI/UX Design Philosophy](../../01_Game_Design/UI_UX_Design/DesignPhilosophy.md) for UI sound guidelines

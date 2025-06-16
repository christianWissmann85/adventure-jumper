import 'package:adventure_jumper/src/systems/interfaces/collision_notifier.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:flame/components.dart'; // Ensure Vector2 is available
import 'package:flame_audio/flame_audio.dart';

import '../components/audio_component.dart';
import '../entities/entity.dart';
import '../utils/logger.dart';
import 'base_system.dart';

/// System that manages sound triggering and audio management
/// Handles music, sound effects, spatial audio, and volume control
///
/// ARCHITECTURE:
/// -------------
/// AudioSystem manages all audio playback and processing in the game.
/// It integrates with other systems in the following ways:
/// - Processes entities with AudioComponent
/// - Handles spatial audio relative to listener position (typically camera/player)
/// - Provides volume controls for different audio categories
/// - Manages audio resource loading and memory usage
///
/// PERFORMANCE CONSIDERATIONS:
/// ---------------------------
/// - Audio playback is optimized by distance-based culling for spatial sounds
/// - Uses preloading to avoid runtime loading hitches
/// - Monitors sound channel counts to prevent audio overload
///
/// USAGE EXAMPLES:
/// --------------
/// ```dart
/// // Play a sound effect
/// audioSystem.playSfx('jump_sound.mp3');
///
/// // Play music with crossfade
/// audioSystem.playMusic('level_theme.mp3', crossFade: true);
///
/// // Play spatial sound at entity position
/// audioSystem.playSpatialSfx('footstep.mp3', entity.position);
/// ```
class AudioSystem extends BaseSystem implements ICollisionEventListener {
  final ICollisionNotifier collisionNotifier;
  final IPhysicsCoordinator physicsCoordinator;

  /// Feature flag to enable/disable physics-integrated audio.
  /// This should ideally be managed by a central configuration system.
  bool audioPhysicsIntegrationEnabled = false; // Default to false as per typical feature flag behavior

  // Cache for entity grounded states to detect landing events accurately.
  // Key: entityId, Value: isGrounded
  // Note: This cache needs a strategy for cleanup when entities are removed
  // to prevent memory leaks. For now, it's a simple map.
  final Map<int, bool> _entityGroundedState = {};
  // Cooldown management for footstep sounds (entityId -> remainingCooldownTime)
  final Map<int, double> _entityFootstepCooldowns = {};
  static const double _footstepBaseCooldown = 0.35; // Seconds between footstep sounds

  // Map surface materials to specific impact sound files/identifiers.
  static final Map<SurfaceMaterial, String> _surfaceImpactSounds = {
    SurfaceMaterial.none: 'sounds/impact_generic.wav', // Default or silent for 'none'
    SurfaceMaterial.stone: 'sounds/impact_stone.wav',
    SurfaceMaterial.ice: 'sounds/impact_ice.wav',
    SurfaceMaterial.rubber: 'sounds/impact_rubber.wav',
    SurfaceMaterial.metal: 'sounds/impact_metal.wav',
    SurfaceMaterial.wood: 'sounds/impact_wood.wav',
    SurfaceMaterial.grass: 'sounds/impact_grass.wav',
    SurfaceMaterial.water: 'sounds/impact_water.wav',
    SurfaceMaterial.sand: 'sounds/impact_sand.wav',
    SurfaceMaterial.mud: 'sounds/impact_mud.wav',
  };

  // Map surface materials to specific landing sound files.
  static final Map<SurfaceMaterial, String> _surfaceLandingSounds = {
    SurfaceMaterial.none: 'sounds/land_generic.wav',
    SurfaceMaterial.stone: 'sounds/land_stone.wav',
    SurfaceMaterial.ice: 'sounds/land_ice.wav',
    SurfaceMaterial.rubber: 'sounds/land_rubber.wav',
    SurfaceMaterial.metal: 'sounds/land_metal.wav',
    SurfaceMaterial.wood: 'sounds/land_wood.wav',
    SurfaceMaterial.grass: 'sounds/land_grass.wav',
    SurfaceMaterial.water: 'sounds/land_water.wav',
    SurfaceMaterial.sand: 'sounds/land_sand.wav',
    SurfaceMaterial.mud: 'sounds/land_mud.wav',
  };

  // Map surface materials to specific footstep sound files.
  static final Map<SurfaceMaterial, String> _surfaceFootstepSounds = {
    SurfaceMaterial.none: 'sounds/footstep_generic.wav',
    SurfaceMaterial.stone: 'sounds/footstep_stone.wav',
    SurfaceMaterial.ice: 'sounds/footstep_ice.wav',
    SurfaceMaterial.rubber: 'sounds/footstep_rubber.wav',
    SurfaceMaterial.metal: 'sounds/footstep_metal.wav',
    SurfaceMaterial.wood: 'sounds/footstep_wood.wav',
    SurfaceMaterial.grass: 'sounds/footstep_grass.wav',
    SurfaceMaterial.water: 'sounds/footstep_water.wav', // Might be more of a splash
    SurfaceMaterial.sand: 'sounds/footstep_sand.wav',
    SurfaceMaterial.mud: 'sounds/footstep_mud.wav',
  };

  AudioSystem({
    required this.collisionNotifier,
    required this.physicsCoordinator,
  }) : super();

  // Configuration
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  // Volume settings (0.0-1.0)
  double _masterVolume = 1;
  double _musicVolume = 0.8;
  double _sfxVolume = 1;
  // Audio state tracking
  String _currentMusicTrack = '';
  // Will be used in Sprint 3 for individual sound effect volume control
  // ignore: unused_field
  final Map<String, double> _soundVolumes = <String, double>{};

  // Listener position (usually camera or player)
  Vector2 _listenerPosition = Vector2.zero();

  // Audio caching
  final Map<String, bool> _preloadedSounds = <String, bool>{};

  // Audio categories
  static const String categoryMusic = 'music';
  static const String categorySfx = 'sfx';
  static const String categoryUi = 'ui';
  static const String categoryAmbient = 'ambient';
  static const String categoryVoice = 'voice'; // Initialize audio engine
  Future<void> initAudioEngine() async {
    // This is just a placeholder - would use actual audio engine in real implementation
  }
  @override
  void initialize() {
    super.initialize();
    if (audioPhysicsIntegrationEnabled) {
      collisionNotifier.addCollisionListener(this);
      logger.info('AudioSystem subscribed to collision events.');
    }
  }

  @override
  void dispose() {
    if (audioPhysicsIntegrationEnabled) {
      collisionNotifier.removeCollisionListener(this);
      logger.info('AudioSystem unsubscribed from collision events.');
    }
    _entityGroundedState.clear();
    _entityFootstepCooldowns.clear();
    super.dispose();
  }

  @override
  bool canProcessEntity(Entity entity) {
    // Process entities with audio components
    return entity.children.whereType<AudioComponent>().isNotEmpty;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Update spatial audio for this entity
    final Iterable<AudioComponent> audioComponents =
        entity.children.whereType<AudioComponent>();
    for (final AudioComponent audio in audioComponents) {
      // Update listener position for spatial audio
      audio.updateListenerPosition(_listenerPosition);
    }
  }

  @override
  Future<void> processSystem(double dt) async {
    if (!audioPhysicsIntegrationEnabled || !_isSoundEnabled) return;

    // Update footstep cooldowns
    final List<int> entitiesToRemoveFromCooldown = [];
    _entityFootstepCooldowns.forEach((entityId, cooldown) {
      final newCooldown = cooldown - dt;
      if (newCooldown <= 0) {
        entitiesToRemoveFromCooldown.add(entityId);
      } else {
        _entityFootstepCooldowns[entityId] = newCooldown;
      }
    });
    for (final entityId in entitiesToRemoveFromCooldown) {
      _entityFootstepCooldowns.remove(entityId);
    }

    // Iterate over entities that are currently grounded and potentially moving
    // We use the _entityGroundedState cache as a primary filter for efficiency,
    // then confirm with physicsCoordinator and check velocity.
    for (final entry in _entityGroundedState.entries) {
      final entityId = entry.key;
      final isGroundedCached = entry.value;

      if (!isGroundedCached) continue; // Skip if not grounded based on our cache
      if (_entityFootstepCooldowns.containsKey(entityId)) continue; // Skip if cooldown active

      try {
        // Verify with physics system and get velocity
        final isActuallyGrounded = await physicsCoordinator.isGrounded(entityId);
        if (!isActuallyGrounded) {
          _entityGroundedState[entityId] = false; // Correct our cache
          continue;
        }

        final velocity = await physicsCoordinator.getVelocity(entityId);
        // Check if moving horizontally (velocity.x.abs() > threshold) or significantly vertically (e.g. sliding)
        // Using a small threshold to avoid sounds when standing still or very minor movements.
        // This threshold might need tuning.
        if (velocity.length2 > 0.1) { // length2 is squared length, cheaper than length
          final position = await physicsCoordinator.getPosition(entityId);
          
          // Get current surface material - assuming method exists on physicsCoordinator
          SurfaceMaterial surfaceMaterial = SurfaceMaterial.none;
          try {
            surfaceMaterial = await physicsCoordinator.getCurrentGroundSurfaceMaterial(entityId);
          } catch (e) {
            logger.warning('Could not get surface material for entity $entityId for footsteps: $e. Defaulting to generic footstep sound.');
          }

          String soundId = _surfaceFootstepSounds[surfaceMaterial] 
              ?? _surfaceFootstepSounds[SurfaceMaterial.none] 
              ?? 'sounds/footstep_generic.wav'; // Final fallback

          // Modulate footstep volume/cooldown by speed? For now, fixed.
          playSpatialSfx(soundId, position, volume: 0.7); // Example volume
          _entityFootstepCooldowns[entityId] = _footstepBaseCooldown;
          logger.finest('Played footstep sound $soundId for entity $entityId on ${surfaceMaterial.name} at $position');
        }
      } catch (e) {
        logger.warning('Error processing footsteps for entity $entityId: $e');
        // Potentially remove entity from _entityGroundedState or handle error appropriately
      }
    }
    // System-wide audio processing can be added here if needed
  }

  // --- ICollisionEventListener Implementation ---

  @override
  Future<void> onCollisionStart(CollisionInfo collision) async {
    if (!audioPhysicsIntegrationEnabled) return;

    // Determine a representative position for the collision sound
    final soundPosition = collision.contactPoint;

    // Example: Play a generic impact sound, potentially scaled by impact velocity
    double impactVolume = 0.8; // Default volume
    // Assuming impactVelocity is non-nullable based on lint error
    final speed = collision.impactVelocity.length;
    // Example scaling: full volume for speeds > 300, scaled down for lower speeds
    impactVolume = (speed / 300.0).clamp(0.2, 1.0);

    // Get the surface material. Assuming surface and material are non-nullable based on previous context.
    final material = collision.surface.material;

    // Look up the sound in our map, use a generic sound if not found or material is 'none'.
    String soundId = _surfaceImpactSounds[material] 
        ?? _surfaceImpactSounds[SurfaceMaterial.none] 
        ?? 'sounds/impact_generic.wav'; // Final fallback if 'none' isn't in map

    playSpatialSfx(soundId, soundPosition, volume: impactVolume);
    logger.finer('Collision started: entity ${collision.entityA} with ${collision.entityB}. Material: ${material.name}. Played $soundId at $soundPosition');
  }

  @override
  Future<void> onCollisionEnd(CollisionInfo collision) async {
    if (!audioPhysicsIntegrationEnabled) return;
    // Potentially stop continuous sounds (e.g., scraping) or play a separation sound.
    logger.finer('Collision ended: entity ${collision.entityA} with ${collision.entityB}');
  }

  @override
  Future<void> onGroundStateChanged(int entityId, bool isGrounded, Vector2 groundNormal) async {
    if (!audioPhysicsIntegrationEnabled) return;

    final bool wasGrounded = _entityGroundedState[entityId] ?? false; 
    // Assume entities might not start in the map, default previous state to false if not found for landing logic.
    // Or, if entities are expected to start grounded, this initial value might need to be true.

    if (isGrounded && !wasGrounded) {
      try {
        final position = await physicsCoordinator.getPosition(entityId);
        // TODO: Query physicsCoordinator for impact velocity to modulate landing sound volume.
        // For now, using a default volume.
        final double landingVolume = 0.9;

        // Get the surface material the entity landed on.
        // This assumes IPhysicsCoordinator has a method like getCurrentGroundSurfaceMaterial.
        // If not, this part will need adjustment or a fallback to generic sound.
        SurfaceMaterial surfaceMaterial = SurfaceMaterial.none;
        try {
          surfaceMaterial = await physicsCoordinator.getCurrentGroundSurfaceMaterial(entityId);
        } catch (e) {
          logger.warning('Could not get surface material for entity $entityId: $e. Defaulting to generic landing sound.');
        }

        String soundId = _surfaceLandingSounds[surfaceMaterial] 
            ?? _surfaceLandingSounds[SurfaceMaterial.none] 
            ?? 'sounds/land_generic.wav'; // Final fallback

        playSpatialSfx(soundId, position, volume: landingVolume);
        logger.info('Entity $entityId landed on ${surfaceMaterial.name}. Played $soundId at $position');
      } catch (e) {
        logger.warning('Could not get position for entity $entityId to play land sound: $e');
      }
    }
    _entityGroundedState[entityId] = isGrounded;
  }

  @override
  Future<void> onSurfaceChanged(int entityId, CollisionSurface? newSurface) async {
    if (!audioPhysicsIntegrationEnabled) return;
    // This event can be used to change continuous sounds like footsteps based on the new surface material.
    // Example: if (isMoving) { updateFootstepSound(newSurface.material); }
    logger.info('Entity $entityId changed surface to: ${newSurface?.material}');
  }

  // --- Public Methods for Specific Physics Actions ---

  /// Plays a jump sound for the given entity.
  /// Fetches the entity's position using the [physicsCoordinator].
  /// Typically called by the system that successfully processes a jump request (e.g., PlayerController).
  Future<void> playJumpSound(int entityId, {double volume = 0.9}) async {
    if (!audioPhysicsIntegrationEnabled || !_isSoundEnabled) return;

    try {
      final position = await physicsCoordinator.getPosition(entityId);
      playSpatialSfx('sounds/jump_generic.wav', position, volume: volume);
      logger.finer('Played jump sound for entity $entityId at $position (volume: $volume)');
    } catch (e) {
      logger.warning('Could not get position for entity $entityId to play jump sound: $e');
    }
  }


  /// Play a sound effect
  void playSfx(String soundId, {double? volume, bool? loop}) {
    if (!isActive || !_isSoundEnabled) return;
    if (soundId.isEmpty) return;

    // Calculate final volume
    final double finalVolume = (volume ?? 1.0) * _sfxVolume * _masterVolume;

    if (finalVolume <= 0.01) return;

    // Play through Flame Audio or other audio engine
    try {
      if (loop == true) {
        FlameAudio.loopLongAudio(soundId, volume: finalVolume);
      } else {
        FlameAudio.play(soundId, volume: finalVolume);
      }
    } catch (e) {
      // Handle audio errors
      logger.severe('Error playing sound $soundId', e);
    }
  }

  /// Play a sound effect at a specific position (spatial audio)
  void playSpatialSfx(
    String soundId,
    Vector2 position, {
    double? range,
    double? volume,
  }) {
    if (!isActive || !_isSoundEnabled) return;
    if (soundId.isEmpty) return;

    // Calculate distance to listener
    final double distance = position.distanceTo(_listenerPosition);

    // Calculate distance-based volume
    final double maxRange = range ?? 1000.0;
    double distanceVolume = 1;

    if (distance > maxRange) {
      distanceVolume = 0.0;
    } else {
      // Linear falloff with distance
      distanceVolume = 1.0 - (distance / maxRange);
    }

    // Calculate final volume
    final double finalVolume =
        distanceVolume * (volume ?? 1.0) * _sfxVolume * _masterVolume;

    if (finalVolume <= 0.01) return;

    // Play the sound
    playSfx(soundId, volume: finalVolume);
  }

  /// Play music track
  void playMusic(
    String trackId, {
    double? volume,
    bool crossFade = false,
    double crossFadeDuration = 2.0,
  }) {
    if (!isActive || !_isMusicEnabled) return;
    if (trackId.isEmpty) return;

    // Skip if already playing this track
    if (_currentMusicTrack == trackId) return;

    // Calculate final volume
    final double finalVolume = (volume ?? 1.0) * _musicVolume * _masterVolume;

    // Stop current music
    if (_currentMusicTrack.isNotEmpty) {
      if (crossFade) {
        // Crossfade implementation would go here
        // This would gradually reduce current track volume while increasing new track volume
      } else {
        stopMusic();
      }
    }

    // Play the music
    try {
      FlameAudio.bgm.play(trackId, volume: finalVolume);
      _currentMusicTrack = trackId;
    } catch (e) {
      // Handle audio errors
      logger.severe('Error playing music $trackId', e);
    }
  }

  /// Stop music playback
  void stopMusic({double? fadeOutDuration}) {
    if (_currentMusicTrack.isEmpty) return;

    try {
      if (fadeOutDuration != null && fadeOutDuration > 0) {
        // Fadeout implementation would go here
        // This would gradually reduce volume before stopping
      } else {
        FlameAudio.bgm.stop();
      }
      _currentMusicTrack = '';
    } catch (e) {
      // Handle audio errors
      logger.severe('Error stopping music', e);
    }
  }

  /// Pause all audio
  void pauseAll() {
    try {
      // Pause background music
      if (_currentMusicTrack.isNotEmpty) {
        FlameAudio.bgm.pause();
      }

      // Would also pause other audio channels
    } catch (e) {
      // Handle audio errors
      logger.severe('Error pausing audio', e);
    }
  }

  /// Resume all audio
  void resumeAll() {
    try {
      // Resume background music
      if (_currentMusicTrack.isNotEmpty) {
        FlameAudio.bgm.resume();
      }

      // Would also resume other audio channels
    } catch (e) {
      // Handle audio errors
      logger.severe('Error resuming audio', e);
    }
  }

  /// Preload a sound for later use
  Future<void> preloadSound(String soundId) async {
    if (_preloadedSounds.containsKey(soundId)) return;
    try {
      await FlameAudio.audioCache.load(soundId);
      _preloadedSounds[soundId] = true;
    } catch (e) {
      logger.severe('Error preloading sound $soundId', e);
      _preloadedSounds[soundId] = false;
    }
  }

  /// Preload multiple sounds
  Future<void> preloadSounds(List<String> soundIds) async {
    for (final String soundId in soundIds) {
      await preloadSound(soundId);
    }
  }

  /// Set master volume
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);

    // Update currently playing audio with new volume
    _updatePlayingVolumes();
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);

    // Update currently playing music volume
    if (_currentMusicTrack.isNotEmpty) {
      final double finalVolume = _musicVolume * _masterVolume;
      try {
        FlameAudio.bgm.audioPlayer.setVolume(finalVolume);
      } catch (e) {
        // Handle audio errors
        logger.severe('Error setting music volume', e);
      }
    }
  }

  /// Set sound effects volume
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    // SFX volume will apply to new sound effects
  }

  /// Enable/disable music
  void setMusicEnabled(bool enabled) {
    if (_isMusicEnabled == enabled) return;

    _isMusicEnabled = enabled;

    if (!_isMusicEnabled && _currentMusicTrack.isNotEmpty) {
      // Stop music if disabling
      stopMusic();
    }
  }

  /// Enable/disable sound effects
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    // Sound state will apply to new sound effects
  }

  /// Update volumes for all playing audio
  void _updatePlayingVolumes() {
    // Update music volume
    if (_currentMusicTrack.isNotEmpty) {
      final double finalVolume = _musicVolume * _masterVolume;
      try {
        FlameAudio.bgm.audioPlayer.setVolume(finalVolume);
      } catch (e) {
        // Handle audio errors
      }
    }

    // Other audio types would be updated here
  }

  /// Backward compatibility method for legacy code
  /// @deprecated Use addEntity instead
  @override
  void registerEntity(Entity entity) {
    addEntity(entity);
  }

  /// Backward compatibility method for legacy code
  /// @deprecated Use removeEntity instead
  @override
  void unregisterEntity(Entity entity) {
    removeEntity(entity);
  }

  /// Update listener position for spatial audio
  void updateListenerPosition(Vector2 position) {
    _listenerPosition = position.clone();
  }

  /// Override setActive to handle audio state
  @override
  void setActive(bool active) {
    // Call the parent implementation
    super.setActive(active);

    // Add custom audio handling
    if (!isActive) {
      pauseAll();
    } else {
      resumeAll();
    }
  }

  // No need to override clearEntities as BaseSystem already provides it

  // No need for entityCount getter as BaseSystem already provides it
  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;
  String get currentMusicTrack => _currentMusicTrack;
}

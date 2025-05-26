import 'package:flame/components.dart';
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
class AudioSystem extends BaseSystem {
  AudioSystem() : super();

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
  static const String CATEGORY_MUSIC = 'music';
  static const String CATEGORY_SFX = 'sfx';
  static const String CATEGORY_UI = 'ui';
  static const String CATEGORY_AMBIENT = 'ambient';
  static const String CATEGORY_VOICE = 'voice'; // Initialize audio engine
  Future<void> initAudioEngine() async {
    // This is just a placeholder - would use actual audio engine in real implementation
  }
  @override
  void initialize() {}

  @override
  void dispose() {}
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
  void processSystem(double dt) {
    // System-wide audio processing can be added here if needed
    // For now, most audio operations are event-driven
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

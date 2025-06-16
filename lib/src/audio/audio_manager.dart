import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import 'audio_cache.dart';
import 'music_track.dart';
import 'sound_effect.dart';
import 'spatial_audio.dart';

/// Central audio system management
/// Coordinates all audio playback, caching, and spatial audio processing
class AudioManager {
  AudioManager({
    this.masterVolume = 1.0,
    this.musicVolume = 0.8,
    this.sfxVolume = 1.0,
    this.spatialAudioEnabled = true,
  });

  // Volume settings
  double masterVolume;
  double musicVolume;
  double sfxVolume;
  bool spatialAudioEnabled;

  // Audio subsystems
  late final AudioCacheManager _audioCache;
  late final SpatialAudioManager _spatialAudio;

  // Current audio state
  MusicTrack? _currentMusic;
  final Map<String, SoundEffect> _activeSounds = <String, SoundEffect>{};
  bool _isInitialized = false;
  bool _isMuted = false;

  // Audio pools for performance
  final Map<String, List<SoundEffect>> _soundPools =
      <String, List<SoundEffect>>{};

  /// Initialize the audio manager and all subsystems
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize audio cache
      _audioCache = AudioCacheManager();
      await _audioCache.initialize();

      // Initialize spatial audio
      _spatialAudio = SpatialAudioManager(enabled: spatialAudioEnabled);
      await _spatialAudio.initialize();

      // Preload common audio assets
      await _preloadCommonSounds();

      _isInitialized = true;
      debugPrint('AudioManager initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize AudioManager: $e');
      rethrow;
    }
  }

  /// Dispose of all audio resources
  void dispose() {
    if (!_isInitialized) return;

    // Stop all active sounds
    stopAllSounds();
    stopMusic();

    // Dispose subsystems
    _audioCache.dispose();
    _spatialAudio.dispose();

    // Clear collections
    _activeSounds.clear();
    _soundPools.clear();

    _isInitialized = false;
  }

  /// Play a sound effect by name
  Future<SoundEffect?> playSoundEffect(
    String soundName, {
    double volume = 1.0,
    bool loop = false,
    double pitch = 1.0,
    Vector2? position,
  }) async {
    if (!_isInitialized || _isMuted) return null;

    try {
      // Get sound from pool or create new one
      final SoundEffect? sound = await _getSoundFromPool(soundName);
      if (sound == null) return null;

      // Configure sound properties
      final double effectiveVolume = volume * sfxVolume * masterVolume;

      // Play with spatial audio if position provided and enabled
      if (position != null && spatialAudioEnabled) {
        await _spatialAudio.playSoundAtPosition(
          sound,
          position,
          volume: effectiveVolume,
          loop: loop,
          pitch: pitch,
        );
      } else {
        await sound.play(
          volume: effectiveVolume,
          loop: loop,
          pitch: pitch,
        );
      }

      // Track active sound
      _activeSounds[sound.id] = sound;

      return sound;
    } catch (e) {
      debugPrint('Failed to play sound effect $soundName: $e');
      return null;
    }
  }

  /// Play background music
  Future<void> playMusic(
    String musicName, {
    double volume = 1.0,
    bool loop = true,
    bool fadeIn = false,
    Duration fadeDuration = const Duration(seconds: 2),
  }) async {
    if (!_isInitialized) return;

    try {
      // Stop current music if playing
      if (_currentMusic != null) {
        await stopMusic(fadeOut: fadeIn, fadeDuration: fadeDuration);
      }

      // Load and play new music
      final MusicTrack? musicTrack =
          await _audioCache.loadMusicTrack(musicName);
      if (musicTrack == null) return;

      final double effectiveVolume = volume * musicVolume * masterVolume;

      await musicTrack.play(
        volume: effectiveVolume,
        loop: loop,
        fadeIn: fadeIn,
        fadeDuration: fadeDuration,
      );

      _currentMusic = musicTrack;
    } catch (e) {
      debugPrint('Failed to play music $musicName: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic({
    bool fadeOut = false,
    Duration fadeDuration = const Duration(seconds: 2),
  }) async {
    if (_currentMusic == null) return;

    try {
      await _currentMusic!.stop(
        fadeOut: fadeOut,
        fadeDuration: fadeDuration,
      );
      _currentMusic = null;
    } catch (e) {
      debugPrint('Failed to stop music: $e');
    }
  }

  /// Stop a specific sound effect
  void stopSoundEffect(String soundId) {
    final SoundEffect? sound = _activeSounds[soundId];
    if (sound != null) {
      sound.stop();
      _activeSounds.remove(soundId);
      _returnSoundToPool(sound);
    }
  }

  /// Stop all active sound effects
  void stopAllSounds() {
    for (final SoundEffect sound in _activeSounds.values) {
      sound.stop();
      _returnSoundToPool(sound);
    }
    _activeSounds.clear();
  }

  /// Set master volume (affects all audio)
  void setMasterVolume(double volume) {
    masterVolume = volume.clamp(0.0, 1.0);
    _updateAllVolumes();
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    musicVolume = volume.clamp(0.0, 1.0);
    _currentMusic?.setVolume(musicVolume * masterVolume);
  }

  /// Set sound effects volume
  void setSfxVolume(double volume) {
    sfxVolume = volume.clamp(0.0, 1.0);
    _updateSoundEffectsVolume();
  }

  /// Mute/unmute all audio
  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _pauseAllAudio();
    } else {
      _resumeAllAudio();
    }
  }

  /// Toggle spatial audio on/off
  void setSpatialAudioEnabled(bool enabled) {
    spatialAudioEnabled = enabled;
    _spatialAudio.setEnabled(enabled);
  }

  /// Update listener position for spatial audio
  void updateListenerPosition(Vector2 position, double rotation) {
    if (spatialAudioEnabled) {
      _spatialAudio.updateListenerPosition(position, rotation);
    }
  }

  /// Preload essential sound effects for better performance
  Future<void> _preloadCommonSounds() async {
    const List<String> commonSounds = <String>[
      'jump',
      'land',
      'collect',
      'hurt',
      'button_click',
      'footstep',
    ];

    for (final String soundName in commonSounds) {
      try {
        await _audioCache.preloadSoundEffect(soundName);

        // Create initial pool for this sound
        _soundPools[soundName] = <SoundEffect>[];
      } catch (e) {
        debugPrint('Failed to preload sound $soundName: $e');
      }
    }
  }

  /// Get a sound from the pool or create a new one
  Future<SoundEffect?> _getSoundFromPool(String soundName) async {
    final List<SoundEffect>? pool = _soundPools[soundName];

    // Try to reuse from pool first
    if (pool != null && pool.isNotEmpty) {
      return pool.removeLast();
    }

    // Create new sound effect
    return _audioCache.loadSoundEffect(soundName);
  }

  /// Return a sound to its pool for reuse
  void _returnSoundToPool(SoundEffect sound) {
    final List<SoundEffect>? pool = _soundPools[sound.name];
    if (pool != null && pool.length < 5) {
      // Limit pool size
      sound.reset(); // Reset sound state
      pool.add(sound);
    } else {
      sound.dispose(); // Dispose if pool is full
    }
  }

  /// Update volumes for all active audio
  void _updateAllVolumes() {
    _currentMusic?.setVolume(musicVolume * masterVolume);
    _updateSoundEffectsVolume();
  }

  /// Update volume for all active sound effects
  void _updateSoundEffectsVolume() {
    for (final SoundEffect sound in _activeSounds.values) {
      sound.setVolume(sound.baseVolume * sfxVolume * masterVolume);
    }
  }

  /// Pause all audio (for muting)
  void _pauseAllAudio() {
    _currentMusic?.pause();
    for (final SoundEffect sound in _activeSounds.values) {
      sound.pause();
    }
  }

  /// Resume all audio (for unmuting)
  void _resumeAllAudio() {
    _currentMusic?.resume();
    for (final SoundEffect sound in _activeSounds.values) {
      sound.resume();
    }
  }

  // Getters for current state
  bool get isInitialized => _isInitialized;
  bool get isMuted => _isMuted;
  bool get isMusicPlaying => _currentMusic?.isPlaying ?? false;
  String? get currentMusicName => _currentMusic?.name;
  int get activeSoundCount => _activeSounds.length;
}

/// Extension for Vector2 to support audio positioning
extension Vector2Audio on Vector2 {
  /// Convert to spatial audio coordinates
  Map<String, double> toAudioPosition() {
    return <String, double>{
      'x': x,
      'y': y,
    };
  }
}

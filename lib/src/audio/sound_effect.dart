import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Individual sound effect handling
/// Manages playback, state, and properties of individual sound effects
class SoundEffect {
  SoundEffect({
    required this.name,
    required this.filePath,
    this.baseVolume = 1.0,
    this.basePitch = 1.0,
    this.maxInstances = 5,
  }) : id = _generateId();

  // Logger for this class
  static final Logger _logger = Logger('SoundEffect');

  // Identity and source
  final String id;
  final String name;
  final String filePath;

  // Audio properties
  final double baseVolume;
  final double basePitch;
  final int maxInstances;

  // Playback state
  bool _isLoaded = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLooping = false;
  double _currentVolume = 1;
  double _currentPitch = 1;

  // Internal audio player reference
  AudioPlayer? _audioPlayer;
  Timer? _fadeTimer;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Event callbacks
  VoidCallback? onComplete;
  VoidCallback? onStart;
  VoidCallback? onStop;

  static int _idCounter = 0;
  static String _generateId() => 'sfx_${++_idCounter}';

  /// Load the sound effect from file
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      // Pre-cache the audio file
      await FlameAudio.audioCache.load(filePath);
      _isLoaded = true;
      _logger.fine('Sound effect loaded: $name');
    } catch (e) {
      _logger.warning('Failed to load sound effect $name: $e');
      rethrow;
    }
  }

  /// Play the sound effect
  Future<void> play({
    double volume = 1.0,
    double pitch = 1.0,
    bool loop = false,
    bool fadeIn = false,
    Duration fadeDuration = const Duration(milliseconds: 500),
  }) async {
    if (!_isLoaded) {
      await load();
    }

    try {
      // Stop current playback if active
      if (_isPlaying) {
        await stop();
      }

      // Set playback properties
      _currentVolume = volume * baseVolume;
      _currentPitch = pitch * basePitch;
      _isLooping = loop;

      // Create new audio player instance
      _audioPlayer = await FlameAudio.play(
        filePath,
        volume: fadeIn ? 0.0 : _currentVolume,
      );

      if (_audioPlayer != null) {
        // Set up state tracking
        _setupPlayerStateListener();

        // Handle fade-in if requested
        if (fadeIn) {
          await _fadeIn(fadeDuration);
        }

        // Handle looping
        if (loop) {
          // Note: Looping implementation may need platform-specific handling
          _setupLooping();
        }

        _isPlaying = true;
        _isPaused = false;
        onStart?.call();
      }
    } catch (e) {
      _logger.warning('Failed to play sound effect $name: $e');
      rethrow;
    }
  }

  /// Stop the sound effect
  Future<void> stop({
    bool fadeOut = false,
    Duration fadeDuration = const Duration(milliseconds: 250),
  }) async {
    if (!_isPlaying) return;

    try {
      if (fadeOut) {
        await _fadeOut(fadeDuration);
      }

      await _audioPlayer?.stop();
      _cleanup();
      onStop?.call();
    } catch (e) {
      _logger.warning('Failed to stop sound effect $name: $e');
    }
  }

  /// Pause the sound effect
  void pause() {
    if (_isPlaying && !_isPaused) {
      _audioPlayer?.pause();
      _isPaused = true;
    }
  }

  /// Resume the sound effect
  void resume() {
    if (_isPlaying && _isPaused) {
      _audioPlayer?.resume();
      _isPaused = false;
    }
  }

  /// Set volume during playback
  void setVolume(double volume) {
    _currentVolume = volume * baseVolume;
    _audioPlayer?.setVolume(_currentVolume);
  }

  /// Set pitch during playback
  void setPitch(double pitch) {
    _currentPitch = pitch * basePitch;
    // Note: Pitch control may need platform-specific implementation
    _audioPlayer?.setPlaybackRate(_currentPitch);
  }

  /// Reset sound effect state for reuse
  void reset() {
    if (_isPlaying) {
      stop();
    }
    _cleanup();
  }

  /// Dispose of all resources
  void dispose() {
    reset();
    onComplete = null;
    onStart = null;
    onStop = null;
  }

  /// Set up player state listener for completion tracking
  void _setupPlayerStateListener() {
    _playerStateSubscription =
        _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        if (_isLooping) {
          // Restart for looping
          _restartLoop();
        } else {
          // Handle completion
          _isPlaying = false;
          _isPaused = false;
          onComplete?.call();
          _cleanup();
        }
      }
    });
  }

  /// Set up looping mechanism
  void _setupLooping() {
    // This is a simplified approach - may need refinement based on platform
    _audioPlayer?.onPlayerComplete.listen((_) {
      if (_isLooping && _isPlaying) {
        _restartLoop();
      }
    });
  }

  /// Restart the sound for looping
  Future<void> _restartLoop() async {
    try {
      await _audioPlayer?.seek(Duration.zero);
      await _audioPlayer?.resume();
    } catch (e) {
      _logger.warning('Failed to restart loop for $name: $e');
    }
  }

  /// Fade in the sound effect
  Future<void> _fadeIn(Duration duration) async {
    const int steps = 20;
    final double stepDuration = duration.inMilliseconds / steps;
    final double volumeStep = _currentVolume / steps;

    _fadeTimer = Timer.periodic(
      Duration(milliseconds: stepDuration.round()),
      (Timer timer) {
        final double newVolume = volumeStep * (timer.tick + 1);
        _audioPlayer?.setVolume(newVolume.clamp(0.0, _currentVolume));

        if (timer.tick >= steps) {
          timer.cancel();
          _fadeTimer = null;
        }
      },
    );
  }

  /// Fade out the sound effect
  Future<void> _fadeOut(Duration duration) async {
    const int steps = 20;
    final double stepDuration = duration.inMilliseconds / steps;
    final double volumeStep = _currentVolume / steps;

    final Completer<void> completer = Completer<void>();

    _fadeTimer = Timer.periodic(
      Duration(milliseconds: stepDuration.round()),
      (Timer timer) {
        final double newVolume = _currentVolume - (volumeStep * timer.tick);
        _audioPlayer?.setVolume(newVolume.clamp(0.0, _currentVolume));

        if (timer.tick >= steps) {
          timer.cancel();
          _fadeTimer = null;
          completer.complete();
        }
      },
    );

    return completer.future;
  }

  /// Clean up resources
  void _cleanup() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _isPaused = false;
  }

  // Getters for current state
  bool get isLoaded => _isLoaded;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLooping => _isLooping;
  double get currentVolume => _currentVolume;
  double get currentPitch => _currentPitch;
  Duration? get currentPosition {
    // In newer audioplayers, position is not directly available on AudioPlayer
    // It needs to be tracked through streams or other methods
    return null;
  }

  Duration? get duration {
    // In newer audioplayers, duration is not directly available on AudioPlayer
    // It needs to be tracked when the audio loads or through onDurationChanged stream
    return null;
  }
}

/// Configuration for batch sound effect operations
class SoundEffectConfig {
  const SoundEffectConfig({
    this.volume = 1.0,
    this.pitch = 1.0,
    this.loop = false,
    this.fadeIn = false,
    this.fadeOut = false,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  final double volume;
  final double pitch;
  final bool loop;
  final bool fadeIn;
  final bool fadeOut;
  final Duration fadeDuration;
  final Duration delay;
}

/// Batch management for multiple sound effects
class SoundEffectBatch {
  SoundEffectBatch(this.name);

  final String name;
  final List<SoundEffect> _sounds = <SoundEffect>[];
  bool _isPlaying = false;

  /// Add a sound effect to the batch
  void addSound(SoundEffect sound) {
    _sounds.add(sound);
  }

  /// Play all sounds in the batch
  Future<void> playAll({
    SoundEffectConfig config = const SoundEffectConfig(),
    bool simultaneous = true,
  }) async {
    if (_isPlaying) return;

    _isPlaying = true;

    if (simultaneous) {
      // Play all sounds at once
      await Future.wait(
        _sounds.map((SoundEffect sound) => _playWithConfig(sound, config)),
      );
    } else {
      // Play sounds sequentially
      for (final SoundEffect sound in _sounds) {
        await _playWithConfig(sound, config);
        if (config.delay > Duration.zero) {
          await Future<void>.delayed(config.delay);
        }
      }
    }

    _isPlaying = false;
  }

  /// Stop all sounds in the batch
  Future<void> stopAll({bool fadeOut = false}) async {
    await Future.wait(
      _sounds.map((SoundEffect sound) => sound.stop(fadeOut: fadeOut)),
    );
    _isPlaying = false;
  }

  /// Play a single sound with configuration
  Future<void> _playWithConfig(
    SoundEffect sound,
    SoundEffectConfig config,
  ) async {
    await sound.play(
      volume: config.volume,
      pitch: config.pitch,
      loop: config.loop,
      fadeIn: config.fadeIn,
      fadeDuration: config.fadeDuration,
    );
  }

  /// Clear all sounds from the batch
  void clear() {
    _sounds.clear();
    _isPlaying = false;
  }

  // Getters
  bool get isPlaying => _isPlaying;
  int get soundCount => _sounds.length;
  List<SoundEffect> get sounds => List<SoundEffect>.unmodifiable(_sounds);
}

import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../utils/error_handler.dart';
import '../utils/exceptions.dart';

/// Background music management
/// Handles streaming music playback, looping, crossfading, and dynamic music systems
class MusicTrack {
  MusicTrack({
    required this.name,
    required this.filePath,
    this.baseVolume = 1.0,
    this.loopStart,
    this.loopEnd,
    this.bpm,
    this.key,
    this.mood,
  }) : id = _generateId();

  // Logger for this class
  static final Logger _logger = Logger('MusicTrack');

  // Identity and metadata
  final String id;
  final String name;
  final String filePath;
  final double baseVolume;
  final Duration? loopStart;
  final Duration? loopEnd;
  final double? bpm;
  final String? key;
  final String? mood;

  // Playback state
  bool _isLoaded = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLooping = false;
  double _currentVolume = 1;
  Duration _currentPosition = Duration.zero;

  // Internal audio player
  AudioPlayer? _audioPlayer;
  Timer? _fadeTimer;
  Timer? _loopTimer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  // Crossfade support
  bool _isCrossfading = false;

  // Event callbacks
  VoidCallback? onStart;
  VoidCallback? onStop;
  VoidCallback? onLoop;
  VoidCallback? onFadeComplete;

  static int _idCounter = 0;
  static String _generateId() => 'music_${++_idCounter}';

  /// Load the music track
  Future<void> load() async {
    if (_isLoaded) return;

    await ErrorHandler.handleAudioError(
      () async {
        await FlameAudio.audioCache.load(filePath);
        _isLoaded = true;
        ErrorHandler.logInfo(
          'Music track loaded: $name',
          context: 'MusicTrack',
        );
      },
      filePath,
      'load',
      context: 'MusicTrack.load',
    );
  }

  /// Play the music track
  Future<void> play({
    double volume = 1.0,
    bool loop = true,
    bool fadeIn = false,
    Duration fadeDuration = const Duration(seconds: 2),
    Duration? startPosition,
  }) async {
    if (!_isLoaded) {
      await load();
    }

    try {
      // Stop current playback if active
      if (_isPlaying) {
        await stop();
      }

      _currentVolume = volume * baseVolume;
      _isLooping = loop;

      // Create audio player
      _audioPlayer = await FlameAudio.playLongAudio(
        filePath,
        volume: fadeIn ? 0.0 : _currentVolume,
      );

      if (_audioPlayer != null) {
        // Set up listeners
        _setupPlayerListeners();

        // Seek to start position if specified
        if (startPosition != null) {
          await _audioPlayer!.seek(startPosition);
        }

        // Handle fade-in
        if (fadeIn) {
          await _fadeIn(fadeDuration);
        }

        // Set up looping if enabled
        if (loop) {
          _setupLooping();
        }
        _isPlaying = true;
        _isPaused = false;
        onStart?.call();
      }
    } on AudioException catch (e) {
      ErrorHandler.logError(
        'Audio system error playing music track: $name',
        error: e,
        context: 'MusicTrack.play',
      );
      rethrow;
    } catch (e, stackTrace) {
      final AudioPlaybackException exception =
          AudioPlaybackException(filePath, 'play', context: e.toString());
      ErrorHandler.logError(
        'Failed to play music track $name',
        error: exception,
        stackTrace: stackTrace,
        context: 'MusicTrack.play',
      );
      throw exception;
    }
  }

  /// Stop the music track
  Future<void> stop({
    bool fadeOut = false,
    Duration fadeDuration = const Duration(seconds: 2),
  }) async {
    if (!_isPlaying) return;

    try {
      if (fadeOut) {
        await _fadeOut(fadeDuration);
      }
      await _audioPlayer?.stop();
      _cleanup();
      onStop?.call();
    } on AudioException catch (e) {
      ErrorHandler.logWarning(
        'Audio system error stopping music track: $name',
        error: e,
        context: 'MusicTrack.stop',
      );
    } catch (e) {
      final AudioPlaybackException exception =
          AudioPlaybackException(filePath, 'stop', context: e.toString());
      ErrorHandler.logWarning(
        'Failed to stop music track $name',
        error: exception,
        context: 'MusicTrack.stop',
      );
    }
  }

  /// Pause the music track
  Future<void> pause({
    bool fadeOut = false,
    Duration fadeDuration = const Duration(seconds: 1),
  }) async {
    if (!_isPlaying || _isPaused) return;

    try {
      if (fadeOut) {
        await _fadeOut(fadeDuration);
      }

      await _audioPlayer?.pause();
      _isPaused = true;
    } catch (e) {
      _logger.warning('Failed to pause music track $name: $e');
    }
  }

  /// Resume the music track
  Future<void> resume({
    bool fadeIn = false,
    Duration fadeDuration = const Duration(seconds: 1),
  }) async {
    if (!_isPlaying || !_isPaused) return;

    try {
      if (fadeIn) {
        await _audioPlayer?.setVolume(0);
      }

      await _audioPlayer?.resume();
      _isPaused = false;

      if (fadeIn) {
        await _fadeIn(fadeDuration);
      }
    } catch (e) {
      _logger.warning('Failed to resume music track $name: $e');
    }
  }

  /// Set volume during playback
  void setVolume(double volume) {
    _currentVolume = volume * baseVolume;
    _audioPlayer?.setVolume(_currentVolume);
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer?.seek(position);
    _currentPosition = position;
  }

  /// Crossfade to another music track
  Future<void> crossfadeTo(
    MusicTrack targetTrack, {
    Duration duration = const Duration(seconds: 3),
    bool stopCurrentAfterFade = true,
  }) async {
    if (_isCrossfading) return;
    _isCrossfading = true;

    try {
      // Start the target track at 0 volume
      await targetTrack.play(volume: 0);

      // Perform crossfade
      await _performCrossfade(targetTrack, duration);

      // Stop current track if requested
      if (stopCurrentAfterFade) {
        await stop();
      }

      onFadeComplete?.call();
    } catch (e) {
      _logger
          .warning('Failed to crossfade from $name to ${targetTrack.name}: $e');
    } finally {
      _isCrossfading = false;
    }
  }

  /// Set up player event listeners
  void _setupPlayerListeners() {
    // Position tracking
    _positionSubscription =
        _audioPlayer?.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
      _checkLoopPoint();
    });

    // Player state tracking
    _playerStateSubscription =
        _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed && _isLooping) {
        _handleLoopCompletion();
      }
    });
  }

  /// Set up looping mechanism
  void _setupLooping() {
    if (loopStart != null && loopEnd != null) {
      // Custom loop points
      _setupCustomLooping();
    } else {
      // Simple full-track looping
      _audioPlayer?.setReleaseMode(ReleaseMode.loop);
    }
  }

  /// Set up custom loop points
  void _setupCustomLooping() {
    // This would need more sophisticated implementation
    // For now, we'll use a simplified approach
    _loopTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _checkLoopPoint();
    });
  }

  /// Check if we need to loop based on custom loop points
  void _checkLoopPoint() {
    if (!_isLooping || loopEnd == null || loopStart == null) return;

    if (_currentPosition >= loopEnd!) {
      _audioPlayer?.seek(loopStart!);
      onLoop?.call();
    }
  }

  /// Handle loop completion for full-track loops
  void _handleLoopCompletion() {
    onLoop?.call();
    // Player will automatically restart due to ReleaseMode.loop
  }

  /// Fade in the music track
  Future<void> _fadeIn(Duration duration) async {
    const int steps = 30;
    final double stepDuration = duration.inMilliseconds / steps;
    final double volumeStep = _currentVolume / steps;

    final Completer<void> completer = Completer<void>();

    _fadeTimer = Timer.periodic(
      Duration(milliseconds: stepDuration.round()),
      (Timer timer) {
        final double newVolume = volumeStep * timer.tick;
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

  /// Fade out the music track
  Future<void> _fadeOut(Duration duration) async {
    const int steps = 30;
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

  /// Perform crossfade between two tracks
  Future<void> _performCrossfade(
    MusicTrack targetTrack,
    Duration duration,
  ) async {
    const int steps = 30;
    final double stepDuration = duration.inMilliseconds / steps;

    final Completer<void> completer = Completer<void>();

    Timer.periodic(
      Duration(milliseconds: stepDuration.round()),
      (Timer timer) {
        final double progress = timer.tick / steps;

        // Fade out current track
        final double currentVolume = _currentVolume * (1.0 - progress);
        _audioPlayer?.setVolume(currentVolume);

        // Fade in target track
        final double targetVolume = targetTrack._currentVolume * progress;
        targetTrack._audioPlayer?.setVolume(targetVolume);

        if (timer.tick >= steps) {
          timer.cancel();
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
    _loopTimer?.cancel();
    _loopTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _isPaused = false;
    _currentPosition = Duration.zero;
  }

  /// Dispose of all resources
  void dispose() {
    stop();
    onStart = null;
    onStop = null;
    onLoop = null;
    onFadeComplete = null;
  }

  // Getters for current state
  bool get isLoaded => _isLoaded;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLooping => _isLooping;
  bool get isCrossfading => _isCrossfading;
  double get currentVolume => _currentVolume;
  Duration get currentPosition => _currentPosition;
  Duration? get duration {
    // In newer audioplayers, duration is not directly available on AudioPlayer
    // It needs to be tracked when the audio loads or through onDurationChanged stream
    // For now, return null as duration tracking would need to be implemented separately
    return null;
  }

  double get playbackProgress {
    final Duration? dur = duration;
    if (dur == null || dur.inMilliseconds == 0) return 0;
    return _currentPosition.inMilliseconds / dur.inMilliseconds;
  }
}

/// Dynamic music system for adaptive audio
class DynamicMusicSystem {
  DynamicMusicSystem({required this.baseName});

  final String baseName;
  final Map<String, MusicTrack> _layers = <String, MusicTrack>{};
  final Map<String, double> _layerVolumes = <String, double>{};
  bool _isActive = false;

  /// Add a music layer (e.g., 'drums', 'melody', 'ambient')
  void addLayer(String layerName, MusicTrack track) {
    _layers[layerName] = track;
    _layerVolumes[layerName] = 1.0;
  }

  /// Start the dynamic music system
  Future<void> start({Map<String, double>? initialVolumes}) async {
    if (_isActive) return;

    // Set initial volumes if provided
    if (initialVolumes != null) {
      _layerVolumes.addAll(initialVolumes);
    }

    // Start all layers
    for (final MapEntry<String, MusicTrack> entry in _layers.entries) {
      final String layerName = entry.key;
      final MusicTrack track = entry.value;
      final double volume = _layerVolumes[layerName] ?? 1.0;

      await track.play(volume: volume);
    }

    _isActive = true;
  }

  /// Stop the dynamic music system
  Future<void> stop({bool fadeOut = true}) async {
    if (!_isActive) return;

    await Future.wait(
      _layers.values.map((MusicTrack track) => track.stop(fadeOut: fadeOut)),
    );
    _isActive = false;
  }

  /// Set volume for a specific layer
  void setLayerVolume(String layerName, double volume) {
    _layerVolumes[layerName] = volume;
    _layers[layerName]?.setVolume(volume);
  }

  /// Smoothly transition layer volumes
  Future<void> transitionToState(
    Map<String, double> targetVolumes, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    final Map<String, double> initialVolumes =
        Map<String, double>.from(_layerVolumes);
    const int steps = 30;
    final double stepDuration = duration.inMilliseconds / steps;

    for (int i = 0; i <= steps; i++) {
      final double progress = i / steps;

      for (final String layerName in targetVolumes.keys) {
        final double initialVolume = initialVolumes[layerName] ?? 0.0;
        final double targetVolume = targetVolumes[layerName] ?? 0.0;
        final double currentVolume =
            initialVolume + (targetVolume - initialVolume) * progress;

        setLayerVolume(layerName, currentVolume);
      }
      if (i < steps) {
        await Future<void>.delayed(
          Duration(milliseconds: stepDuration.round()),
        );
      }
    }
  }

  /// Mute/unmute specific layers
  void muteLayer(String layerName) => setLayerVolume(layerName, 0);
  void unmuteLayer(String layerName) => setLayerVolume(layerName, 1);

  // Getters
  bool get isActive => _isActive;
  List<String> get layerNames => _layers.keys.toList();
  double getLayerVolume(String layerName) => _layerVolumes[layerName] ?? 0.0;
}

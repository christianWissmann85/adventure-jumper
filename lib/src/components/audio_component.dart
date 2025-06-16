import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:logging/logging.dart';

/// Component that handles audio triggers and spatial sound for entities
/// Manages sound effect activation based on entity state and events
class AudioComponent extends Component {
  static final _logger = Logger('AudioComponent');

  AudioComponent({
    bool? isActive,
    double? maxDistance,
    double? volume,
    bool? is3D,
    Map<String, List<String>>? soundMappings,
  }) {
    if (isActive != null) this.isActive = isActive;
    if (maxDistance != null) _maxDistance = maxDistance;
    if (volume != null) _volume = volume;
    if (is3D != null) _is3D = is3D;
    if (soundMappings != null) _soundMappings = soundMappings;
  }

  // Audio properties
  bool isActive = true;
  double _volume = 1;
  bool _is3D = true;
  double _maxDistance = 1000; // Maximum distance for audio falloff
  final double _minDistance = 50; // Distance within which volume is at maximum

  // Sound effect mappings (event name -> list of possible sound files)
  Map<String, List<String>> _soundMappings = <String, List<String>>{};

  // Recent sounds to prevent repetition
  final List<String> _recentSounds = <String>[];
  final int _maxRecentSounds = 5;

  // Random number generator for variation
  final math.Random _random = math.Random();

  // Timing for auto sounds (like footsteps)
  final Map<String, double> _soundTimers = <String, double>{};
  final Map<String, double> _soundIntervals = <String, double>{};
  // Position of the listener (usually the player/camera)
  Vector2 _listenerPosition = Vector2.zero();

  // References to AudioSystem and sound player
  // Will be implemented in Sprint 3 when audio system is completed
  // ignore: unused_field
  late final dynamic _audioSystem;

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    // Update sound timers for periodic sounds (like footsteps)
    final List<String> triggeredSounds = <String>[];

    for (final String soundType in _soundTimers.keys) {
      _soundTimers[soundType] = _soundTimers[soundType]! - dt;

      if (_soundTimers[soundType]! <= 0) {
        // Reset timer
        _soundTimers[soundType] = _soundIntervals[soundType] ?? 1.0;

        // Add to triggered sounds
        triggeredSounds.add(soundType);
      }
    }

    // Play any auto-triggered sounds
    for (final String soundType in triggeredSounds) {
      playSound(soundType);
    }
  }

  /// Set up a recurring sound at specified intervals
  void setupRecurringSound(String soundType, double interval) {
    if (interval <= 0) return;

    _soundIntervals[soundType] = interval;
    _soundTimers[soundType] = interval;
  }

  /// Stop a recurring sound
  void stopRecurringSound(String soundType) {
    _soundTimers.remove(soundType);
    _soundIntervals.remove(soundType);
  }

  /// Add sound mapping for an event
  void addSoundMapping(String eventName, List<String> soundFileNames) {
    _soundMappings[eventName] = List<String>.from(soundFileNames);
  }

  /// Play a sound of the specified type
  void playSound(
    String soundType, {
    double? volumeMultiplier,
    bool? force = false,
  }) {
    if (!isActive) return;
    if (_soundMappings[soundType] == null ||
        _soundMappings[soundType]!.isEmpty) {
      return;
    }

    // Get entity position (if available)
    Vector2 position = Vector2.zero();
    if (parent is PositionComponent) {
      position = (parent as PositionComponent).position.clone();
    }

    // Calculate final volume based on distance if 3D audio
    double finalVolume = _volume;
    if (_is3D) {
      finalVolume = _calculateSpatialVolume(position);
    }

    // Apply optional volume multiplier
    if (volumeMultiplier != null) {
      finalVolume *= volumeMultiplier;
    }

    // Don't play if too quiet
    if (finalVolume < 0.01 && force != true) return;

    // Select a sound file (with variation if multiple options exist)
    final String soundFileName = _selectSoundVariation(soundType);

    // Play the sound (would call into main audio system)
    _playSoundInternal(soundFileName, finalVolume);
  }

  /// Calculate volume based on distance from listener
  double _calculateSpatialVolume(Vector2 position) {
    final double distance = position.distanceTo(_listenerPosition);

    // Within minimum distance, full volume
    if (distance <= _minDistance) return _volume;

    // Beyond maximum distance, no sound
    if (distance >= _maxDistance) return 0;

    // Linear falloff between min and max distance
    final double distanceRange = _maxDistance - _minDistance;
    final double distanceFactor = (distance - _minDistance) / distanceRange;

    // Inverse distance falloff (1.0 at min distance, 0.0 at max distance)
    return _volume * (1.0 - distanceFactor);
  }

  /// Select a sound file with variation to avoid repetition
  String _selectSoundVariation(String soundType) {
    final List<String>? sounds = _soundMappings[soundType];
    if (sounds == null || sounds.isEmpty) return '';

    if (sounds.length == 1) return sounds[0];

    // Try to find a sound not recently played
    final List<String> availableSounds =
        sounds.where((String s) => !_recentSounds.contains(s)).toList();

    String selectedSound;
    if (availableSounds.isEmpty) {
      // All sounds are recent, just pick randomly
      selectedSound = sounds[_random.nextInt(sounds.length)];
    } else {
      // Pick from non-recent sounds
      selectedSound = availableSounds[_random.nextInt(availableSounds.length)];
    }

    // Add to recent sounds and maintain max size
    _recentSounds.add(selectedSound);
    if (_recentSounds.length > _maxRecentSounds) {
      _recentSounds.removeAt(0); // Remove oldest
    }

    return selectedSound;
  }

  /// Internal implementation to play a sound (would connect to audio system)
  void _playSoundInternal(String soundFile, double volume) {
    // This would call into the main audio system to actually play the sound
    // For now, it's a placeholder

    // Example of what this might do:
    // audioSystem.play(soundFile, volume);

    _logger.fine('Playing sound: $soundFile at volume $volume');
  }

  /// Update listener position (usually the player's position or camera)
  void updateListenerPosition(Vector2 position) {
    _listenerPosition = position.clone();
  }

  // Getters/Setters
  double get volume => _volume;
  set volume(double value) => _volume = value.clamp(0.0, 1.0);
}

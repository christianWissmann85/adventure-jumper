import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:logging/logging.dart';

import 'sound_effect.dart';

/// 3D positioned audio effects
/// Handles spatial audio processing including distance attenuation, panning, and environmental effects
class SpatialAudioManager {
  SpatialAudioManager({
    this.enabled = true,
    this.maxDistance = 1000.0,
    this.minDistance = 50.0,
    this.rolloffFactor = 1.0,
    this.dopplerFactor = 1.0,
    this.environmentalEffects = true,
  });

  // Logger for this class
  static final Logger _logger = Logger('SpatialAudioManager');

  // Configuration
  bool enabled;
  double maxDistance;
  double minDistance;
  double rolloffFactor;
  double dopplerFactor;
  bool environmentalEffects;

  // Listener state
  Vector2 _listenerPosition = Vector2.zero();
  double _listenerRotation = 0;
  Vector2 _listenerVelocity = Vector2.zero();

  // Active spatial sounds
  final Map<String, SpatialSound> _spatialSounds = <String, SpatialSound>{};

  // Environmental zones
  final List<AudioZone> _audioZones = <AudioZone>[];
  AudioZone? _currentZone;

  // Audio processing parameters
  static const double _speedOfSound = 343; // meters per second
  bool _isInitialized = false;

  /// Initialize the spatial audio manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set up default audio zones if needed
      _setupDefaultZones();
      _isInitialized = true;
      _logger.info('SpatialAudioManager initialized');
    } catch (e) {
      _logger.warning('Failed to initialize SpatialAudioManager: $e');
      rethrow;
    }
  }

  /// Dispose of spatial audio resources
  void dispose() {
    // Stop all spatial sounds
    for (final SpatialSound spatialSound in _spatialSounds.values) {
      spatialSound.dispose();
    }
    _spatialSounds.clear();
    _audioZones.clear();
    _isInitialized = false;
  }

  /// Play a sound at a specific world position
  Future<SpatialSound?> playSoundAtPosition(
    SoundEffect soundEffect,
    Vector2 position, {
    double volume = 1.0,
    bool loop = false,
    double pitch = 1.0,
    Vector2? velocity,
    String? spatialId,
  }) async {
    if (!enabled || !_isInitialized) {
      // Fall back to regular sound playback
      await soundEffect.play(volume: volume, loop: loop, pitch: pitch);
      return null;
    }

    try {
      // Create spatial sound wrapper
      final SpatialSound spatialSound = SpatialSound(
        soundEffect: soundEffect,
        position: position,
        velocity: velocity ?? Vector2.zero(),
        baseVolume: volume,
        basePitch: pitch,
        loop: loop,
        spatialId: spatialId ?? soundEffect.id,
      );

      // Calculate initial spatial parameters
      _updateSpatialSound(spatialSound);

      // Play the sound with spatial parameters
      await soundEffect.play(
        volume: spatialSound.effectiveVolume,
        loop: loop,
        pitch: spatialSound.effectivePitch,
      ); // Track the spatial sound
      _spatialSounds[spatialSound.spatialId] = spatialSound;

      return spatialSound;
    } catch (e) {
      _logger.warning('Failed to play spatial sound: $e');
      return null;
    }
  }

  /// Update listener position and orientation
  void updateListenerPosition(
    Vector2 position,
    double rotation, {
    Vector2? velocity,
  }) {
    _listenerPosition = position;
    _listenerRotation = rotation;
    _listenerVelocity = velocity ?? Vector2.zero();

    // Update current audio zone
    _updateCurrentZone();

    // Update all spatial sounds
    _updateAllSpatialSounds();
  }

  /// Update position of a spatial sound
  void updateSoundPosition(
    String spatialId,
    Vector2 position, {
    Vector2? velocity,
  }) {
    final SpatialSound? spatialSound = _spatialSounds[spatialId];
    if (spatialSound != null) {
      spatialSound.position = position;
      if (velocity != null) {
        spatialSound.velocity = velocity;
      }
      _updateSpatialSound(spatialSound);
    }
  }

  /// Stop a spatial sound
  void stopSpatialSound(String spatialId) {
    final SpatialSound? spatialSound = _spatialSounds.remove(spatialId);
    if (spatialSound != null) {
      spatialSound.soundEffect.stop();
      spatialSound.dispose();
    }
  }

  /// Add an environmental audio zone
  void addAudioZone(AudioZone zone) {
    _audioZones.add(zone);
  }

  /// Remove an environmental audio zone
  void removeAudioZone(AudioZone zone) {
    _audioZones.remove(zone);
    if (_currentZone == zone) {
      _currentZone = null;
      _updateCurrentZone();
    }
  }

  /// Enable or disable spatial audio
  void setEnabled(bool enabled) {
    this.enabled = enabled;

    if (!enabled) {
      // Reset all spatial sounds to normal playback
      for (final SpatialSound spatialSound in _spatialSounds.values) {
        spatialSound.soundEffect.setVolume(spatialSound.baseVolume);
        spatialSound.soundEffect.setPitch(spatialSound.basePitch);
      }
    } else {
      // Reapply spatial effects
      _updateAllSpatialSounds();
    }
  }

  /// Calculate distance attenuation
  double _calculateDistanceAttenuation(double distance) {
    if (distance <= minDistance) {
      return 1;
    } else if (distance >= maxDistance) {
      return 0;
    } else {
      // Inverse square law with rolloff factor
      final double normalizedDistance = (distance - minDistance) / (maxDistance - minDistance);
      return math.pow(1.0 - normalizedDistance, rolloffFactor).toDouble();
    }
  }

  /// Calculate stereo panning (-1.0 to 1.0)
  double _calculatePanning(Vector2 soundPosition) {
    // Calculate relative position to listener
    final Vector2 relativePosition = soundPosition - _listenerPosition;

    // Rotate relative to listener orientation
    final double cos = math.cos(_listenerRotation);
    final double sin = math.sin(_listenerRotation);
    final double rotatedX = relativePosition.x * cos - relativePosition.y * sin;

    // Convert to panning value
    final double distance = relativePosition.length;
    if (distance < 0.1) return 0; // Too close to determine direction

    return (rotatedX / distance).clamp(-1.0, 1.0);
  }

  /// Calculate Doppler effect on pitch
  double _calculateDopplerPitch(SpatialSound spatialSound) {
    if (dopplerFactor == 0.0) return spatialSound.basePitch;

    // Calculate relative velocity
    final Vector2 relativeVelocity = spatialSound.velocity - _listenerVelocity;
    final Vector2 soundDirection = (spatialSound.position - _listenerPosition).normalized();

    // Project velocity onto sound direction
    final double radialVelocity = relativeVelocity.dot(soundDirection);

    // Apply Doppler formula
    final double dopplerRatio = (_speedOfSound + radialVelocity) / _speedOfSound;
    return spatialSound.basePitch * dopplerRatio * dopplerFactor;
  }

  /// Apply environmental effects based on current zone
  SpatialAudioParameters _applyEnvironmentalEffects(
    SpatialAudioParameters params,
  ) {
    if (!environmentalEffects || _currentZone == null) return params;

    return SpatialAudioParameters(
      volume: params.volume * _currentZone!.volumeMultiplier,
      pitch: params.pitch * _currentZone!.pitchMultiplier,
      panning: params.panning,
      reverb: _currentZone!.reverbLevel,
      lowPassFilter: _currentZone!.lowPassFilter,
      highPassFilter: _currentZone!.highPassFilter,
    );
  }

  /// Update spatial parameters for a single sound
  void _updateSpatialSound(SpatialSound spatialSound) {
    if (!enabled) return;

    // Calculate distance and attenuation
    final double distance = _listenerPosition.distanceTo(spatialSound.position);
    final double attenuation = _calculateDistanceAttenuation(distance);

    // Calculate panning
    final double panning = _calculatePanning(spatialSound.position);

    // Calculate Doppler effect
    final double dopplerPitch = _calculateDopplerPitch(spatialSound);

    // Create base parameters
    SpatialAudioParameters params = SpatialAudioParameters(
      volume: spatialSound.baseVolume * attenuation,
      pitch: dopplerPitch,
      panning: panning,
    );

    // Apply environmental effects
    params = _applyEnvironmentalEffects(params);

    // Update sound effect
    spatialSound.effectiveVolume = params.volume;
    spatialSound.effectivePitch = params.pitch;
    spatialSound.effectivePanning = params.panning;

    // Apply to actual sound effect
    spatialSound.soundEffect.setVolume(params.volume);
    spatialSound.soundEffect.setPitch(params.pitch);

    // Note: Panning would need platform-specific implementation
    // For now, we'll simulate it with volume adjustments
    _applyPanning(spatialSound.soundEffect, params.panning);
  }

  /// Update all spatial sounds
  void _updateAllSpatialSounds() {
    for (final SpatialSound spatialSound in _spatialSounds.values) {
      _updateSpatialSound(spatialSound);
    }
  }

  /// Update current audio zone based on listener position
  void _updateCurrentZone() {
    AudioZone? newZone;

    for (final AudioZone zone in _audioZones) {
      if (zone.containsPoint(_listenerPosition)) {
        newZone = zone;
        break; // Use first matching zone
      }
    }

    if (newZone != _currentZone) {
      _currentZone = newZone;
      _updateAllSpatialSounds(); // Reapply environmental effects
    }
  }

  /// Apply panning effect (simplified stereo implementation)
  void _applyPanning(SoundEffect soundEffect, double panning) {
    // This is a simplified implementation
    // Real panning would require platform-specific audio processing

    // For now, we'll adjust volume based on panning
    // Left channel: reduced when panning right (positive)
    // Right channel: reduced when panning left (negative)

    final double leftVolume = panning > 0 ? (1.0 - panning * 0.5) : 1.0;
    final double rightVolume = panning < 0 ? (1.0 + panning * 0.5) : 1.0;

    // Average the channels for mono output
    final double monoVolume = (leftVolume + rightVolume) * 0.5;
    soundEffect.setVolume(soundEffect.currentVolume * monoVolume);
  }

  /// Set up default audio zones
  void _setupDefaultZones() {
    // Add a default "normal" zone that covers everything
    addAudioZone(AudioZone.normal());
  }

  // Getters
  bool get isInitialized => _isInitialized;
  Vector2 get listenerPosition => _listenerPosition;
  double get listenerRotation => _listenerRotation;
  int get activeSpatialSoundCount => _spatialSounds.length;
  AudioZone? get currentZone => _currentZone;
}

/// A spatial sound wrapper
class SpatialSound {
  SpatialSound({
    required this.soundEffect,
    required this.position,
    required this.velocity,
    required this.baseVolume,
    required this.basePitch,
    required this.loop,
    required this.spatialId,
  });

  final SoundEffect soundEffect;
  final String spatialId;

  Vector2 position;
  Vector2 velocity;
  final double baseVolume;
  final double basePitch;
  final bool loop;

  // Calculated spatial parameters
  double effectiveVolume = 1;
  double effectivePitch = 1;
  double effectivePanning = 0;

  void dispose() {
    // Clean up any spatial-specific resources
  }
}

/// Environmental audio zone
class AudioZone {
  AudioZone({
    required this.name,
    required this.bounds,
    this.volumeMultiplier = 1.0,
    this.pitchMultiplier = 1.0,
    this.reverbLevel = 0.0,
    this.lowPassFilter = 1.0,
    this.highPassFilter = 0.0,
    this.priority = 0,
  });

  /// Create a normal (default) audio zone
  factory AudioZone.normal() {
    return AudioZone(
      name: 'normal',
      bounds: <Vector2>[
        Vector2(-10000, -10000),
        Vector2(10000, -10000),
        Vector2(10000, 10000),
        Vector2(-10000, 10000),
      ],
    );
  }

  /// Create an indoor/cave audio zone with reverb
  factory AudioZone.indoor(List<Vector2> bounds) {
    return AudioZone(
      name: 'indoor',
      bounds: bounds,
      reverbLevel: 0.3,
      lowPassFilter: 0.8,
      priority: 1,
    );
  }

  /// Create an underwater audio zone
  factory AudioZone.underwater(List<Vector2> bounds) {
    return AudioZone(
      name: 'underwater',
      bounds: bounds,
      volumeMultiplier: 0.7,
      pitchMultiplier: 0.9,
      lowPassFilter: 0.5,
      priority: 2,
    );
  }

  final String name;
  final List<Vector2> bounds; // Polygon vertices
  final double volumeMultiplier;
  final double pitchMultiplier;
  final double reverbLevel;
  final double lowPassFilter;
  final double highPassFilter;
  final int priority;

  /// Check if a point is inside this zone
  bool containsPoint(Vector2 point) {
    // Point-in-polygon test using ray casting algorithm
    bool inside = false;
    int j = bounds.length - 1;

    for (int i = 0; i < bounds.length; i++) {
      if (((bounds[i].y > point.y) != (bounds[j].y > point.y)) &&
          (point.x <
              (bounds[j].x - bounds[i].x) * (point.y - bounds[i].y) / (bounds[j].y - bounds[i].y) + bounds[i].x)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }
}

/// Spatial audio processing parameters
class SpatialAudioParameters {
  const SpatialAudioParameters({
    required this.volume,
    required this.pitch,
    required this.panning,
    this.reverb = 0.0,
    this.lowPassFilter = 1.0,
    this.highPassFilter = 0.0,
  });

  final double volume;
  final double pitch;
  final double panning;
  final double reverb;
  final double lowPassFilter;
  final double highPassFilter;
}

/// Extension for Vector2 to add spatial audio utility methods
extension Vector2Spatial on Vector2 {
  /// Calculate 3D distance for spatial audio (treating Y as height)
  double spatialDistanceTo(Vector2 other, {double heightDifference = 0.0}) {
    final double horizontalDistance = distanceTo(other);
    return math.sqrt(
      horizontalDistance * horizontalDistance + heightDifference * heightDifference,
    );
  }

  /// Get normalized direction vector for spatial calculations
  Vector2 directionTo(Vector2 other) {
    final Vector2 direction = other - this;
    return direction.length > 0 ? direction.normalized() : Vector2.zero();
  }

  /// Calculate dot product with another vector
  double dot(Vector2 other) {
    return x * other.x + y * other.y;
  }
}

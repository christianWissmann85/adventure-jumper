import 'package:flame_audio/flame_audio.dart';

/// Ambient sound configuration for biomes
/// Manages background audio, atmospheric effects, and environmental sounds
class AmbientSound {
  const AmbientSound({
    required this.trackPath,
    this.volume = 0.5,
    this.loop = true,
    this.fadeInDuration = 2.0,
    this.fadeOutDuration = 2.0,
  });

  /// Create from JSON data
  factory AmbientSound.fromJson(Map<String, dynamic> json) => AmbientSound(
        trackPath: json['trackPath'] as String,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
        loop: json['loop'] as bool? ?? true,
        fadeInDuration: (json['fadeInDuration'] as num?)?.toDouble() ?? 2.0,
        fadeOutDuration: (json['fadeOutDuration'] as num?)?.toDouble() ?? 2.0,
      );

  final String trackPath;
  final double volume;
  final bool loop;
  final double fadeInDuration;
  final double fadeOutDuration;

  /// Load and prepare the ambient sound
  Future<void> load() async {
    await FlameAudio.audioCache.load(trackPath);
  }

  /// Start playing the ambient sound
  Future<void> play() async {
    await FlameAudio.loop(trackPath, volume: volume);
  }

  /// Stop playing the ambient sound
  Future<void> stop() async {
    await FlameAudio.audioCache.clearAll();
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() => <String, dynamic>{
        'trackPath': trackPath,
        'volume': volume,
        'loop': loop,
        'fadeInDuration': fadeInDuration,
        'fadeOutDuration': fadeOutDuration,
      };
}

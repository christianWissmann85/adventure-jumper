import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'music_track.dart';
import 'sound_effect.dart';

/// Audio asset caching system
/// Manages loading, caching, and memory management of audio assets
class AudioCacheManager {
  AudioCacheManager({
    this.maxCacheSize = 100 * 1024 * 1024, // 100MB default
    this.preloadCommonAssets = true,
  });

  final int maxCacheSize;
  final bool preloadCommonAssets;

  // Audio asset caches
  final Map<String, SoundEffect> _soundEffectCache = <String, SoundEffect>{};
  final Map<String, MusicTrack> _musicTrackCache = <String, MusicTrack>{};
  final Map<String, AudioAssetInfo> _assetInfoCache = <String, AudioAssetInfo>{};

  // Cache statistics
  int _currentCacheSize = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // Asset manifest
  Map<String, dynamic>? _audioManifest;
  bool _isInitialized = false;

  /// Initialize the audio cache manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load audio asset manifest
      await _loadAudioManifest();

      // Preload common assets if enabled
      if (preloadCommonAssets) {
        await _preloadCommonAssets();
      }

      _isInitialized = true;
      debugPrint('AudioCacheManager initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize AudioCacheManager: $e');
      rethrow;
    }
  }

  /// Load a sound effect from cache or file
  Future<SoundEffect?> loadSoundEffect(String name) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check cache first
    if (_soundEffectCache.containsKey(name)) {
      _cacheHits++;
      return _soundEffectCache[name];
    }

    _cacheMisses++;

    try {
      // Get asset info
      final AudioAssetInfo? assetInfo = await _getAssetInfo(name);
      if (assetInfo == null || assetInfo.type != AudioAssetType.soundEffect) {
        debugPrint('Sound effect not found or invalid type: $name');
        return null;
      }

      // Create and load sound effect
      final SoundEffect soundEffect = SoundEffect(
        name: name,
        filePath: assetInfo.filePath,
        baseVolume: assetInfo.volume,
        basePitch: assetInfo.pitch,
        maxInstances: assetInfo.maxInstances,
      );

      await soundEffect.load();

      // Add to cache if there's space
      if (_canAddToCache(assetInfo.fileSize)) {
        _soundEffectCache[name] = soundEffect;
        _currentCacheSize += assetInfo.fileSize;
      }

      return soundEffect;
    } catch (e) {
      debugPrint('Failed to load sound effect $name: $e');
      return null;
    }
  }

  /// Load a music track from cache or file
  Future<MusicTrack?> loadMusicTrack(String name) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check cache first
    if (_musicTrackCache.containsKey(name)) {
      _cacheHits++;
      return _musicTrackCache[name];
    }

    _cacheMisses++;

    try {
      // Get asset info
      final AudioAssetInfo? assetInfo = await _getAssetInfo(name);
      if (assetInfo == null || assetInfo.type != AudioAssetType.music) {
        debugPrint('Music track not found or invalid type: $name');
        return null;
      }

      // Create and load music track
      final MusicTrack musicTrack = MusicTrack(
        name: name,
        filePath: assetInfo.filePath,
        baseVolume: assetInfo.volume,
        loopStart: assetInfo.loopStart,
        loopEnd: assetInfo.loopEnd,
        bpm: assetInfo.bpm,
        key: assetInfo.key,
        mood: assetInfo.mood,
      );

      await musicTrack.load();

      // Music tracks are typically larger, so be more selective about caching
      if (_canAddToCache(assetInfo.fileSize) && assetInfo.fileSize < maxCacheSize ~/ 4) {
        _musicTrackCache[name] = musicTrack;
        _currentCacheSize += assetInfo.fileSize;
      }

      return musicTrack;
    } catch (e) {
      debugPrint('Failed to load music track $name: $e');
      return null;
    }
  }

  /// Preload a sound effect without returning it
  Future<void> preloadSoundEffect(String name) async {
    await loadSoundEffect(name);
  }

  /// Preload a music track without returning it
  Future<void> preloadMusicTrack(String name) async {
    await loadMusicTrack(name);
  }

  /// Preload multiple assets
  Future<void> preloadAssets(List<String> assetNames) async {
    final Iterable<Future<void>> futures = assetNames.map((String name) async {
      try {
        final AudioAssetInfo? assetInfo = await _getAssetInfo(name);
        if (assetInfo?.type == AudioAssetType.soundEffect) {
          await preloadSoundEffect(name);
        } else if (assetInfo?.type == AudioAssetType.music) {
          await preloadMusicTrack(name);
        }
      } catch (e) {
        debugPrint('Failed to preload asset $name: $e');
      }
    });

    await Future.wait(futures);
  }

  /// Clear specific asset from cache
  void removeFromCache(String name) {
    // Remove sound effect
    final SoundEffect? soundEffect = _soundEffectCache.remove(name);
    if (soundEffect != null) {
      soundEffect.dispose();
      final AudioAssetInfo? assetInfo = _assetInfoCache[name];
      if (assetInfo != null) {
        _currentCacheSize -= assetInfo.fileSize;
      }
    }

    // Remove music track
    final MusicTrack? musicTrack = _musicTrackCache.remove(name);
    if (musicTrack != null) {
      musicTrack.dispose();
      final AudioAssetInfo? assetInfo = _assetInfoCache[name];
      if (assetInfo != null) {
        _currentCacheSize -= assetInfo.fileSize;
      }
    }
  }

  /// Clear all cached assets
  void clearCache() {
    // Dispose all sound effects
    for (final SoundEffect soundEffect in _soundEffectCache.values) {
      soundEffect.dispose();
    }
    _soundEffectCache.clear();

    // Dispose all music tracks
    for (final MusicTrack musicTrack in _musicTrackCache.values) {
      musicTrack.dispose();
    }
    _musicTrackCache.clear();

    _currentCacheSize = 0;
  }

  /// Optimize cache by removing least recently used assets
  void optimizeCache() {
    // This is a simplified LRU implementation
    // In a production system, you'd want more sophisticated cache management

    if (_currentCacheSize <= maxCacheSize) return;

    final List<String> assetsToRemove = <String>[];
    int sizeToFree = _currentCacheSize - (maxCacheSize * 0.8).round();

    // Remove larger music tracks first
    for (final String name in _musicTrackCache.keys) {
      final AudioAssetInfo? assetInfo = _assetInfoCache[name];
      if (assetInfo != null && sizeToFree > 0) {
        assetsToRemove.add(name);
        sizeToFree -= assetInfo.fileSize;
      }
    }

    // Remove sound effects if needed
    if (sizeToFree > 0) {
      for (final String name in _soundEffectCache.keys) {
        final AudioAssetInfo? assetInfo = _assetInfoCache[name];
        if (assetInfo != null && sizeToFree > 0) {
          assetsToRemove.add(name);
          sizeToFree -= assetInfo.fileSize;
        }
      }
    }

    // Remove selected assets
    for (final String name in assetsToRemove) {
      removeFromCache(name);
    }

    debugPrint('Cache optimized: removed ${assetsToRemove.length} assets');
  }

  /// Dispose of all resources
  void dispose() {
    clearCache();
    _assetInfoCache.clear();
    _audioManifest = null;
    _isInitialized = false;
  }

  /// Load the audio asset manifest
  Future<void> _loadAudioManifest() async {
    try {
      final String manifestString = await rootBundle.loadString('assets/audio/audio_manifest.json');
      _audioManifest = json.decode(manifestString) as Map<String, dynamic>;

      // Cache asset info for quick access
      final Map<String, dynamic> assets = _audioManifest!['assets'] as Map<String, dynamic>? ?? <String, dynamic>{};
      for (final MapEntry<String, dynamic> entry in assets.entries) {
        final Map<String, dynamic> assetData = entry.value as Map<String, dynamic>;
        _assetInfoCache[entry.key] = AudioAssetInfo.fromJson(entry.key, assetData);
      }
    } catch (e) {
      debugPrint('Failed to load audio manifest: $e');
      // Create empty manifest as fallback
      _audioManifest = <String, dynamic>{'assets': <String, dynamic>{}};
    }
  }

  /// Get asset information
  Future<AudioAssetInfo?> _getAssetInfo(String name) async {
    // Check cache first
    if (_assetInfoCache.containsKey(name)) {
      return _assetInfoCache[name];
    }

    // Try to construct default asset info
    return _createDefaultAssetInfo(name);
  }

  /// Create default asset info for assets not in manifest
  AudioAssetInfo? _createDefaultAssetInfo(String name) {
    // Try to determine type and path from name
    if (name.contains('music') || name.contains('bgm') || name.contains('track')) {
      return AudioAssetInfo(
        name: name,
        filePath: 'audio/music/$name.ogg',
        type: AudioAssetType.music,
        fileSize: 1024 * 1024, // Estimate 1MB
        volume: 0.8,
      );
    } else {
      return AudioAssetInfo(
        name: name,
        filePath: 'audio/sfx/$name.wav',
        type: AudioAssetType.soundEffect,
        fileSize: 100 * 1024, // Estimate 100KB
        maxInstances: 5,
      );
    }
  }

  /// Preload commonly used assets
  Future<void> _preloadCommonAssets() async {
    const List<String> commonAssets = <String>[
      'jump',
      'land',
      'collect',
      'hurt',
      'button_click',
      'footstep',
      'ui_select',
      'ui_confirm',
    ];

    await preloadAssets(commonAssets);
  }

  /// Check if an asset can be added to cache
  bool _canAddToCache(int assetSize) {
    return (_currentCacheSize + assetSize) <= maxCacheSize;
  }

  // Getters for cache statistics
  bool get isInitialized => _isInitialized;
  int get currentCacheSize => _currentCacheSize;
  int get cachedSoundEffectCount => _soundEffectCache.length;
  int get cachedMusicTrackCount => _musicTrackCache.length;
  int get cacheHits => _cacheHits;
  int get cacheMisses => _cacheMisses;
  double get cacheHitRatio => _cacheHits + _cacheMisses > 0 ? _cacheHits / (_cacheHits + _cacheMisses) : 0.0;
  double get cacheUsagePercentage => maxCacheSize > 0 ? _currentCacheSize / maxCacheSize : 0.0;
}

/// Audio asset information
class AudioAssetInfo {
  const AudioAssetInfo({
    required this.name,
    required this.filePath,
    required this.type,
    required this.fileSize,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.maxInstances = 1,
    this.loopStart,
    this.loopEnd,
    this.bpm,
    this.key,
    this.mood,
    this.tags = const <String>[],
  });

  factory AudioAssetInfo.fromJson(String name, Map<String, dynamic> json) {
    return AudioAssetInfo(
      name: name,
      filePath: json['filePath'] as String,
      type: AudioAssetType.values.firstWhere(
        (AudioAssetType t) => t.toString().split('.').last == json['type'],
        orElse: () => AudioAssetType.soundEffect,
      ),
      fileSize: json['fileSize'] as int? ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      maxInstances: json['maxInstances'] as int? ?? 1,
      loopStart: json['loopStart'] != null ? Duration(milliseconds: json['loopStart'] as int) : null,
      loopEnd: json['loopEnd'] != null ? Duration(milliseconds: json['loopEnd'] as int) : null,
      bpm: (json['bpm'] as num?)?.toDouble(),
      key: json['key'] as String?,
      mood: json['mood'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }

  final String name;
  final String filePath;
  final AudioAssetType type;
  final int fileSize;
  final double volume;
  final double pitch;
  final int maxInstances;
  final Duration? loopStart;
  final Duration? loopEnd;
  final double? bpm;
  final String? key;
  final String? mood;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filePath': filePath,
      'type': type.toString().split('.').last,
      'fileSize': fileSize,
      'volume': volume,
      'pitch': pitch,
      'maxInstances': maxInstances,
      if (loopStart != null) 'loopStart': loopStart!.inMilliseconds,
      if (loopEnd != null) 'loopEnd': loopEnd!.inMilliseconds,
      if (bpm != null) 'bpm': bpm,
      if (key != null) 'key': key,
      if (mood != null) 'mood': mood,
      if (tags.isNotEmpty) 'tags': tags,
    };
  }
}

/// Audio asset types
enum AudioAssetType {
  soundEffect,
  music,
  ambience,
  voice,
}

/// Cache configuration for different asset types
class CacheConfig {
  const CacheConfig({
    this.maxSoundEffects = 50,
    this.maxMusicTracks = 5,
    this.maxTotalSize = 100 * 1024 * 1024, // 100MB
    this.preloadCommon = true,
    this.aggressiveOptimization = false,
  });

  final int maxSoundEffects;
  final int maxMusicTracks;
  final int maxTotalSize;
  final bool preloadCommon;
  final bool aggressiveOptimization;
}

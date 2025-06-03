import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as flutter_services;

import '../utils/error_handler.dart';
import '../utils/exceptions.dart';
import 'animation_loader.dart';
import 'audio_loader.dart';
import 'level_data_loader.dart';
import 'sprite_loader.dart';

/// Central asset loading and caching
/// Coordinates all asset loading operations and manages memory usage
class AssetManager {
  AssetManager({
    this.maxCacheSize = 200 * 1024 * 1024, // 200MB default
    this.preloadCriticalAssets = true,
    this.enableProgressReporting = true,
  });

  final int maxCacheSize;
  final bool preloadCriticalAssets;
  final bool enableProgressReporting;

  // Asset loaders
  late final SpriteLoader _spriteLoader;
  late final AnimationLoader _animationLoader;
  late final AudioLoader _audioLoader;
  late final LevelDataLoader _levelDataLoader;

  // Asset manifests
  Map<String, dynamic>? _assetManifest;
  final Map<String, AssetInfo> _assetRegistry = <String, AssetInfo>{};

  // Loading state
  bool _isInitialized = false;
  bool _isLoading = false;
  double _loadingProgress = 0;
  String _currentLoadingAsset = '';

  // Cache management
  int _currentCacheSize = 0;
  final Map<String, DateTime> _assetAccessTimes = <String, DateTime>{};

  // Event streams
  final StreamController<AssetLoadingEvent> _loadingEventController =
      StreamController<AssetLoadingEvent>.broadcast();

  /// Stream of asset loading events
  Stream<AssetLoadingEvent> get loadingEvents => _loadingEventController.stream;

  /// Initialize the asset manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize asset loaders
      _spriteLoader = SpriteLoader();
      _animationLoader = AnimationLoader();
      _audioLoader = AudioLoader();
      _levelDataLoader = LevelDataLoader();

      await Future.wait(<Future<void>>[
        _spriteLoader.initialize(),
        _animationLoader.initialize(),
        _audioLoader.initialize(),
        _levelDataLoader.initialize(),
      ]);

      // Load asset manifest
      await _loadAssetManifest();

      // Preload critical assets if enabled
      if (preloadCriticalAssets) {
        await _preloadCriticalAssets();
      }
      _isInitialized = true;
      _emitEvent(AssetLoadingEvent.completed('AssetManager initialization'));

      ErrorHandler.logInfo(
        'AssetManager initialized successfully',
        context: 'AssetManager',
      );
    } on flutter_services.PlatformException catch (e) {
      final AssetLoadingException exception = AssetLoadingException(
        'Platform error during AssetManager initialization',
        'AssetManager',
        'initialization',
        context: e.message,
        cause: e,
      );
      _emitEvent(
        AssetLoadingEvent.error(
          'AssetManager initialization',
          exception.toString(),
        ),
      );
      ErrorHandler.logCritical(
        'Platform error during AssetManager initialization',
        error: exception,
        context: 'AssetManager',
      );
      throw exception;
    } on FileSystemException catch (e) {
      final AssetLoadingException exception = AssetLoadingException(
        'File system error during AssetManager initialization',
        e.path ?? 'unknown',
        'initialization',
        context: e.message,
        cause: e,
      );
      _emitEvent(
        AssetLoadingEvent.error(
          'AssetManager initialization',
          exception.toString(),
        ),
      );
      ErrorHandler.logCritical(
        'File system error during AssetManager initialization',
        error: exception,
        context: 'AssetManager',
      );
      throw exception;
    } catch (e, stackTrace) {
      final AssetLoadingException exception = AssetLoadingException(
        'Unexpected error during AssetManager initialization',
        'AssetManager',
        'initialization',
        cause: e is Exception ? e : Exception(e.toString()),
      );
      _emitEvent(
        AssetLoadingEvent.error(
          'AssetManager initialization',
          exception.toString(),
        ),
      );
      ErrorHandler.logCritical(
        'Unexpected error during AssetManager initialization',
        error: exception,
        stackTrace: stackTrace,
        context: 'AssetManager',
      );
      throw exception;
    }
  }

  /// Load a sprite by name
  Future<Sprite?> loadSprite(String name) async {
    await _ensureInitialized();
    _recordAssetAccess(name);
    return _spriteLoader.loadSprite(name);
  }

  /// Load a sprite animation by name
  Future<SpriteAnimation?> loadAnimation(String name) async {
    await _ensureInitialized();
    _recordAssetAccess(name);
    return _animationLoader.loadAnimation(name);
  }

  /// Load audio asset by name
  Future<Source> loadAudio(String name) async {
    await _ensureInitialized();
    _recordAssetAccess(name);
    return _audioLoader.loadAudio(name);
  }

  /// Load level data by name
  Future<Map<String, dynamic>?> loadLevelData(String name) async {
    await _ensureInitialized();
    _recordAssetAccess(name);
    return _levelDataLoader.loadLevelData(name);
  }

  /// Preload a batch of assets
  Future<void> preloadAssets(List<String> assetNames) async {
    await _ensureInitialized();

    _isLoading = true;
    _loadingProgress = 0.0;
    _emitEvent(
      AssetLoadingEvent.started('Preloading ${assetNames.length} assets'),
    );

    try {
      for (int i = 0; i < assetNames.length; i++) {
        final String assetName = assetNames[i];
        _currentLoadingAsset = assetName;
        _loadingProgress = i / assetNames.length;

        _emitEvent(AssetLoadingEvent.progress(assetName, _loadingProgress));

        await _preloadAsset(assetName);
      }
      _loadingProgress = 1.0;
      _emitEvent(AssetLoadingEvent.completed('Preloading completed'));
      ErrorHandler.logInfo(
        'Asset preloading completed successfully',
        context: 'AssetManager',
      );
    } on AssetLoadingException catch (e) {
      _emitEvent(AssetLoadingEvent.error('Preloading failed', e.toString()));
      ErrorHandler.logError(
        'Asset preloading failed with known error type',
        error: e,
        context: 'AssetManager.preloadAssets',
      );
      rethrow;
    } on flutter_services.PlatformException catch (e) {
      final AssetLoadingException exception = AssetLoadingException(
        'Platform error during asset preloading',
        _currentLoadingAsset.isNotEmpty ? _currentLoadingAsset : 'unknown',
        'preload',
        context: e.message,
        cause: e,
      );
      _emitEvent(
        AssetLoadingEvent.error('Preloading failed', exception.toString()),
      );
      ErrorHandler.logError(
        'Platform error during asset preloading',
        error: exception,
        context: 'AssetManager.preloadAssets',
      );
      throw exception;
    } catch (e, stackTrace) {
      final AssetLoadingException exception = AssetLoadingException(
        'Unexpected error during asset preloading',
        _currentLoadingAsset.isNotEmpty ? _currentLoadingAsset : 'unknown',
        'preload',
        cause: e is Exception ? e : Exception(e.toString()),
      );
      _emitEvent(
        AssetLoadingEvent.error('Preloading failed', exception.toString()),
      );
      ErrorHandler.logError(
        'Unexpected error during asset preloading',
        error: exception,
        stackTrace: stackTrace,
        context: 'AssetManager.preloadAssets',
      );
      throw exception;
    } finally {
      _isLoading = false;
      _currentLoadingAsset = '';
    }
  }

  /// Preload assets for a specific level
  Future<void> preloadLevelAssets(String levelName) async {
    final List<String> levelAssets = await _getLevelAssetList(levelName);
    if (levelAssets.isNotEmpty) {
      await preloadAssets(levelAssets);
    }
  }

  /// Get asset information
  AssetInfo? getAssetInfo(String name) {
    return _assetRegistry[name];
  }

  /// Check if an asset is loaded
  bool isAssetLoaded(String name) {
    final AssetInfo? assetInfo = _assetRegistry[name];
    if (assetInfo == null) return false;
    switch (assetInfo.type) {
      case AssetType.sprite:
        return _spriteLoader.isLoaded(name);
      case AssetType.animation:
        return _animationLoader.isLoaded(name);
      case AssetType.audio:
        return _audioLoader.isLoaded(name);
      case AssetType.levelData:
        return _levelDataLoader.isLoaded(name);
      case AssetType.font:
      case AssetType.shader:
      case AssetType.unknown:
        return false;
    }
  }

  /// Unload specific asset to free memory
  void unloadAsset(String name) {
    final AssetInfo? assetInfo = _assetRegistry[name];
    if (assetInfo == null) return;

    switch (assetInfo.type) {
      case AssetType.sprite:
        _spriteLoader.unload(name);
        break;
      case AssetType.animation:
        _animationLoader.unload(name);
        break;
      case AssetType.audio:
        _audioLoader.unload(name);
        break;
      case AssetType.levelData:
        _levelDataLoader.unload(name);
        break;
      case AssetType.font:
      case AssetType.shader:
      case AssetType.unknown:
        // No specific unloading needed for these types
        break;
    }

    _assetAccessTimes.remove(name);
    _currentCacheSize -= assetInfo.estimatedSize;
  }

  /// Optimize cache by removing least recently used assets
  void optimizeCache() {
    if (_currentCacheSize <= maxCacheSize) return;

    final List<MapEntry<String, DateTime>> sortedAssets =
        _assetAccessTimes.entries.toList()
          ..sort(
            (MapEntry<String, DateTime> a, MapEntry<String, DateTime> b) =>
                a.value.compareTo(b.value),
          );

    int sizeToFree = _currentCacheSize - (maxCacheSize * 0.8).round();

    for (final MapEntry<String, DateTime> entry in sortedAssets) {
      if (sizeToFree <= 0) break;

      final AssetInfo? assetInfo = _assetRegistry[entry.key];
      if (assetInfo != null && !assetInfo.isCritical) {
        unloadAsset(entry.key);
        sizeToFree -= assetInfo.estimatedSize;
      }
    }

    debugPrint('Cache optimized: ${_currentCacheSize ~/ 1024}KB used');
  }

  /// Clear all cached assets
  void clearCache() {
    _spriteLoader.clearCache();
    _animationLoader.clearCache();
    _audioLoader.clearCache();
    _levelDataLoader.clearCache();

    _assetAccessTimes.clear();
    _currentCacheSize = 0;
  }

  /// Dispose of all resources
  void dispose() {
    clearCache();
    _loadingEventController.close();
    _isInitialized = false;
  }

  /// Load the main asset manifest
  Future<void> _loadAssetManifest() async {
    try {
      final String manifestString = await flutter_services.rootBundle
          .loadString('assets/asset_manifest.json');
      _assetManifest = json.decode(manifestString) as Map<String, dynamic>;

      // Parse asset registry
      final Map<String, dynamic> assets =
          _assetManifest!['assets'] as Map<String, dynamic>? ??
              <String, dynamic>{};
      for (final MapEntry<String, dynamic> entry in assets.entries) {
        final Map<String, dynamic> assetData =
            entry.value as Map<String, dynamic>;
        _assetRegistry[entry.key] = AssetInfo.fromJson(entry.key, assetData);
      }

      debugPrint('Loaded asset manifest with ${_assetRegistry.length} assets');
    } catch (e) {
      debugPrint('Failed to load asset manifest: $e');
      // Continue with empty manifest
      _assetManifest = <String, dynamic>{'assets': <String, dynamic>{}};
    }
  }

  /// Preload critical assets
  Future<void> _preloadCriticalAssets() async {
    final List<String> criticalAssets = _assetRegistry.entries
        .where((MapEntry<String, AssetInfo> entry) => entry.value.isCritical)
        .map((MapEntry<String, AssetInfo> entry) => entry.key)
        .toList();

    if (criticalAssets.isNotEmpty) {
      await preloadAssets(criticalAssets);
    }
  }

  /// Preload a single asset based on its type
  Future<void> _preloadAsset(String name) async {
    final AssetInfo? assetInfo = _assetRegistry[name];
    if (assetInfo == null) {
      debugPrint('Unknown asset: $name');
      return;
    }

    try {
      switch (assetInfo.type) {
        case AssetType.sprite:
          await loadSprite(name);
          break;
        case AssetType.animation:
          await loadAnimation(name);
          break;
        case AssetType.audio:
          await loadAudio(name);
          break;
        case AssetType.levelData:
          await loadLevelData(name);
          break;
        case AssetType.font:
        case AssetType.shader:
        case AssetType.unknown:
          // No specific preloading for these types yet
          break;
      }

      _currentCacheSize += assetInfo.estimatedSize;
    } catch (e) {
      debugPrint('Failed to preload asset $name: $e');
    }
  }

  /// Get list of assets required for a level
  Future<List<String>> _getLevelAssetList(String levelName) async {
    final Map<String, dynamic>? levelData = await loadLevelData(levelName);
    if (levelData == null) return <String>[];

    final List<String> assets =
        <String>[]; // Extract asset references from level data
    if (levelData.containsKey('sprites')) {
      final List<dynamic> sprites =
          levelData['sprites'] as List<dynamic>? ?? <dynamic>[];
      assets.addAll(sprites.cast<String>());
    }

    if (levelData.containsKey('animations')) {
      final List<dynamic> animations =
          levelData['animations'] as List<dynamic>? ?? <dynamic>[];
      assets.addAll(animations.cast<String>());
    }

    if (levelData.containsKey('audio')) {
      final List<dynamic> audio =
          levelData['audio'] as List<dynamic>? ?? <dynamic>[];
      assets.addAll(audio.cast<String>());
    }

    return assets;
  }

  /// Ensure the asset manager is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Record asset access for LRU cache management
  void _recordAssetAccess(String name) {
    _assetAccessTimes[name] = DateTime.now();
  }

  /// Emit a loading event
  void _emitEvent(AssetLoadingEvent event) {
    if (enableProgressReporting) {
      _loadingEventController.add(event);
    }
  }

  // Getters for current state
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  double get loadingProgress => _loadingProgress;
  String get currentLoadingAsset => _currentLoadingAsset;
  int get currentCacheSize => _currentCacheSize;
  int get assetCount => _assetRegistry.length;
  double get cacheUsagePercentage =>
      maxCacheSize > 0 ? _currentCacheSize / maxCacheSize : 0.0;
}

/// Asset information structure
class AssetInfo {
  const AssetInfo({
    required this.name,
    required this.path,
    required this.type,
    required this.estimatedSize,
    this.isCritical = false,
    this.tags = const <String>[],
    this.dependencies = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  factory AssetInfo.fromJson(String name, Map<String, dynamic> json) {
    return AssetInfo(
      name: name,
      path: json['path'] as String,
      type: AssetType.values.firstWhere(
        (AssetType t) => t.toString().split('.').last == json['type'],
        orElse: () => AssetType.unknown,
      ),
      estimatedSize: json['estimatedSize'] as int? ?? 0,
      isCritical: json['isCritical'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      dependencies: (json['dependencies'] as List<dynamic>?)?.cast<String>() ??
          <String>[],
      metadata:
          json['metadata'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  final String name;
  final String path;
  final AssetType type;
  final int estimatedSize;
  final bool isCritical;
  final List<String> tags;
  final List<String> dependencies;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'path': path,
      'type': type.toString().split('.').last,
      'estimatedSize': estimatedSize,
      'isCritical': isCritical,
      if (tags.isNotEmpty) 'tags': tags,
      if (dependencies.isNotEmpty) 'dependencies': dependencies,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }
}

/// Asset types
enum AssetType {
  sprite,
  animation,
  audio,
  levelData,
  font,
  shader,
  unknown,
}

/// Asset loading events
class AssetLoadingEvent {
  const AssetLoadingEvent({
    required this.type,
    required this.assetName,
    this.progress,
    this.error,
  });

  factory AssetLoadingEvent.started(String assetName) {
    return AssetLoadingEvent(
      type: AssetLoadingEventType.started,
      assetName: assetName,
    );
  }

  factory AssetLoadingEvent.progress(String assetName, double progress) {
    return AssetLoadingEvent(
      type: AssetLoadingEventType.progress,
      assetName: assetName,
      progress: progress,
    );
  }

  factory AssetLoadingEvent.completed(String assetName) {
    return AssetLoadingEvent(
      type: AssetLoadingEventType.completed,
      assetName: assetName,
      progress: 1,
    );
  }

  factory AssetLoadingEvent.error(String assetName, String error) {
    return AssetLoadingEvent(
      type: AssetLoadingEventType.error,
      assetName: assetName,
      error: error,
    );
  }

  final AssetLoadingEventType type;
  final String assetName;
  final double? progress;
  final String? error;
}

/// Asset loading event types
enum AssetLoadingEventType {
  started,
  progress,
  completed,
  error,
}

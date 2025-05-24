import 'dart:convert';

import 'package:flutter/services.dart';

import '../utils/error_handler.dart';
import '../utils/exceptions.dart';

/// Handles loading and parsing of level data files
class LevelDataLoader {
  factory LevelDataLoader() => _instance;
  LevelDataLoader._internal();
  static final LevelDataLoader _instance = LevelDataLoader._internal();

  final Map<String, LevelData> _levelCache = <String, LevelData>{};
  final Map<String, BiomeData> _biomeCache = <String, BiomeData>{};
  final Map<String, TilesetData> _tilesetCache = <String, TilesetData>{};

  bool _isInitialized = false;

  /// Initialize the level data loader
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _preloadLevelIndex();
    _isInitialized = true;
  }

  /// Load level data from JSON file
  Future<LevelData> loadLevel(String levelId) async {
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId]!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/levels/$levelId.json');

      try {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;

        final LevelData levelData = LevelData.fromJson(jsonData);
        _levelCache[levelId] = levelData;

        return levelData;
      } on FormatException catch (e) {
        // JSON parsing errors
        throw LevelDataCorruptedException(levelId, context: e.message);
      } on TypeError catch (e) {
        // Type casting errors
        throw LevelDataCorruptedException(
          levelId,
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // Platform errors when accessing assets
      throw AssetNotFoundException('assets/levels/$levelId.json', 'level_data');
    } catch (e) {
      throw LevelException(
        'Failed to load level data',
        levelId,
        'load',
        context: e.toString(),
      );
    }
  }

  /// Load biome configuration
  Future<BiomeData> loadBiome(String biomeId) async {
    if (_biomeCache.containsKey(biomeId)) {
      return _biomeCache[biomeId]!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/biomes/$biomeId.json');

      try {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;

        final BiomeData biomeData = BiomeData.fromJson(jsonData);
        _biomeCache[biomeId] = biomeData;

        return biomeData;
      } on FormatException catch (e) {
        // JSON parsing errors
        throw AssetCorruptedException(
          'assets/biomes/$biomeId.json',
          'biome_data',
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          'assets/biomes/$biomeId.json',
          'biome_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // Platform errors when accessing assets
      throw AssetNotFoundException('assets/biomes/$biomeId.json', 'biome_data');
    } catch (e) {
      throw AssetLoadingException(
        'Failed to load biome data',
        'assets/biomes/$biomeId.json',
        'biome_data',
        context: e.toString(),
      );
    }
  }

  /// Load tileset data for level construction
  Future<TilesetData> loadTileset(String tilesetId) async {
    if (_tilesetCache.containsKey(tilesetId)) {
      return _tilesetCache[tilesetId]!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/tilesets/$tilesetId.json');

      try {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;

        final TilesetData tilesetData = TilesetData.fromJson(jsonData);
        _tilesetCache[tilesetId] = tilesetData;

        return tilesetData;
      } on FormatException catch (e) {
        // JSON parsing errors
        throw AssetCorruptedException(
          'assets/tilesets/$tilesetId.json',
          'tileset_data',
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          'assets/tilesets/$tilesetId.json',
          'tileset_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // Platform errors when accessing assets
      throw AssetNotFoundException(
        'assets/tilesets/$tilesetId.json',
        'tileset_data',
      );
    } catch (e) {
      throw AssetLoadingException(
        'Failed to load tileset data',
        'assets/tilesets/$tilesetId.json',
        'tileset_data',
        context: e.toString(),
      );
    }
  }

  /// Load complete world data including all levels and biomes
  Future<WorldData> loadWorld(String worldId) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/worlds/$worldId.json');

      try {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;

        final WorldData worldData = WorldData.fromJson(jsonData);

        // Pre-load referenced levels and biomes
        for (final LevelReference levelRef in worldData.levelReferences) {
          try {
            await loadLevel(levelRef.levelId);
          } on LevelException catch (e) {
            // Log but continue loading other levels
            ErrorHandler.logWarning(
              'Could not pre-load level ${levelRef.levelId} for world $worldId',
              error: e,
              context: 'LevelDataLoader.loadWorld',
            );
          }
        }

        for (final String biomeId in worldData.biomeIds) {
          try {
            await loadBiome(biomeId);
          } on AssetLoadingException catch (e) {
            // Log but continue loading other biomes
            ErrorHandler.logWarning(
              'Could not pre-load biome $biomeId for world $worldId',
              error: e,
              context: 'LevelDataLoader.loadWorld',
            );
          }
        }

        return worldData;
      } on FormatException catch (e) {
        // JSON parsing errors
        throw JsonParseException(
          'Invalid world data format',
          'assets/worlds/$worldId.json',
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          'assets/worlds/$worldId.json',
          'world_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // Platform errors when accessing assets
      throw AssetNotFoundException('assets/worlds/$worldId.json', 'world_data');
    } catch (e) {
      throw AssetLoadingException(
        'Failed to load world data',
        'assets/worlds/$worldId.json',
        'world_data',
        context: e.toString(),
      );
    }
  }

  /// Load enemy spawn data for a level
  Future<List<EnemySpawnData>> loadEnemySpawns(String levelId) async {
    final String filePath = 'assets/spawns/${levelId}_enemies.json';

    try {
      final String jsonString = await rootBundle.loadString(filePath);

      try {
        final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
        return jsonData
            .map<EnemySpawnData>(
              (data) => EnemySpawnData.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      } on FormatException catch (e) {
        // JSON parsing errors
        throw JsonParseException(
          'Invalid enemy spawn data format',
          filePath,
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          filePath,
          'enemy_spawn_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // File doesn't exist - not an error, just return empty list
      ErrorHandler.logInfo(
        'No enemy spawn data found for level $levelId, using empty list',
        context: 'LevelDataLoader.loadEnemySpawns',
      );
      return <EnemySpawnData>[];
    } catch (e) {
      ErrorHandler.logWarning(
        'Error loading enemy spawns for $levelId, using empty list instead',
        error: e,
        context: 'LevelDataLoader.loadEnemySpawns',
      );
      return <EnemySpawnData>[];
    }
  }

  /// Load collectible placement data for a level
  Future<List<CollectibleData>> loadCollectibles(String levelId) async {
    final String filePath = 'assets/collectibles/${levelId}_items.json';

    try {
      final String jsonString = await rootBundle.loadString(filePath);
      try {
        final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
        return jsonData
            .map<CollectibleData>(
              (data) => CollectibleData.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      } on FormatException catch (e) {
        // JSON parsing errors
        throw JsonParseException(
          'Invalid collectible data format',
          filePath,
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          filePath,
          'collectible_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // File doesn't exist - not an error, just return empty list
      ErrorHandler.logInfo(
        'No collectible data found for level $levelId, using empty list',
        context: 'LevelDataLoader.loadCollectibles',
      );
      return <CollectibleData>[];
    } catch (e) {
      ErrorHandler.logWarning(
        'Error loading collectibles for $levelId, using empty list instead',
        error: e,
        context: 'LevelDataLoader.loadCollectibles',
      );
      return <CollectibleData>[];
    }
  }

  /// Load checkpoint data for a level
  Future<List<CheckpointData>> loadCheckpoints(String levelId) async {
    final String filePath = 'assets/checkpoints/${levelId}_checkpoints.json';

    try {
      final String jsonString = await rootBundle.loadString(filePath);
      try {
        final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
        return jsonData
            .map<CheckpointData>(
              (data) => CheckpointData.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      } on FormatException catch (e) {
        // JSON parsing errors
        throw JsonParseException(
          'Invalid checkpoint data format',
          filePath,
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          filePath,
          'checkpoint_data',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // File doesn't exist - not an error, just return empty list
      ErrorHandler.logInfo(
        'No checkpoint data found for level $levelId, using empty list',
        context: 'LevelDataLoader.loadCheckpoints',
      );
      return <CheckpointData>[];
    } catch (e) {
      ErrorHandler.logWarning(
        'Error loading checkpoints for $levelId, using empty list instead',
        error: e,
        context: 'LevelDataLoader.loadCheckpoints',
      );
      return <CheckpointData>[];
    }
  }

  /// Load level index that contains metadata about all available levels
  Future<LevelIndex> loadLevelIndex() async {
    const String filePath = 'assets/levels/index.json';

    try {
      final String jsonString = await rootBundle.loadString(filePath);

      try {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;

        return LevelIndex.fromJson(jsonData);
      } on FormatException catch (e) {
        // JSON parsing errors
        throw JsonParseException(
          'Invalid level index format',
          filePath,
          context: e.message,
        );
      } on TypeError catch (e) {
        // Type casting errors
        throw AssetCorruptedException(
          filePath,
          'level_index',
          context: 'Invalid data structure: $e',
        );
      }
    } on PlatformException {
      // Platform errors when accessing assets
      throw const AssetNotFoundException(filePath, 'level_index');
    } catch (e) {
      throw AssetLoadingException(
        'Failed to load level index',
        filePath,
        'level_index',
        context: e.toString(),
      );
    }
  }

  /// Validate level data integrity
  Future<bool> validateLevel(String levelId) async {
    try {
      final LevelData levelData = await loadLevel(levelId);

      // Check required fields
      if (levelData.id.isEmpty || levelData.tiles.isEmpty) {
        ErrorHandler.logWarning(
          'Level validation failed: empty ID or tiles array',
          context: 'LevelDataLoader.validateLevel($levelId)',
        );
        return false;
      }

      // Validate tile dimensions
      if (levelData.width <= 0 || levelData.height <= 0) {
        ErrorHandler.logWarning(
          'Level validation failed: invalid dimensions (width=${levelData.width}, height=${levelData.height})',
          context: 'LevelDataLoader.validateLevel($levelId)',
        );
        return false;
      }

      // Check that tile array matches dimensions
      if (levelData.tiles.length != levelData.width * levelData.height) {
        ErrorHandler.logWarning(
          'Level validation failed: tile count (${levelData.tiles.length}) does not match dimensions '
          '(${levelData.width}x${levelData.height} = ${levelData.width * levelData.height})',
          context: 'LevelDataLoader.validateLevel($levelId)',
        );
        return false;
      }

      // Validate spawn point exists
      if (levelData.spawnPoint.x < 0 || levelData.spawnPoint.y < 0) {
        ErrorHandler.logWarning(
          'Level validation failed: invalid spawn point (${levelData.spawnPoint.x}, ${levelData.spawnPoint.y})',
          context: 'LevelDataLoader.validateLevel($levelId)',
        );
        return false;
      }

      return true;
    } on LevelException catch (e) {
      ErrorHandler.logWarning(
        'Level validation failed: could not load level data',
        error: e,
        context: 'LevelDataLoader.validateLevel($levelId)',
      );
      return false;
    } on AssetLoadingException catch (e) {
      ErrorHandler.logWarning(
        'Level validation failed: asset loading error',
        error: e,
        context: 'LevelDataLoader.validateLevel($levelId)',
      );
      return false;
    } catch (e) {
      ErrorHandler.logWarning(
        'Level validation failed: unexpected error',
        error: e,
        context: 'LevelDataLoader.validateLevel($levelId)',
      );
      return false;
    }
  }

  /// Pre-load the level index
  Future<void> _preloadLevelIndex() async {
    try {
      await loadLevelIndex();
    } on AssetNotFoundException catch (e) {
      ErrorHandler.logWarning(
        'Level index file not found during preload',
        error: e,
        context: 'LevelDataLoader._preloadLevelIndex',
      );
    } on JsonParseException catch (e) {
      ErrorHandler.logWarning(
        'Level index file has invalid JSON format',
        error: e,
        context: 'LevelDataLoader._preloadLevelIndex',
      );
    } on AssetCorruptedException catch (e) {
      ErrorHandler.logWarning(
        'Level index file is corrupted or has invalid data structure',
        error: e,
        context: 'LevelDataLoader._preloadLevelIndex',
      );
    } on AssetLoadingException catch (e) {
      ErrorHandler.logWarning(
        'Failed to load level index during preload',
        error: e,
        context: 'LevelDataLoader._preloadLevelIndex',
      );
    } catch (e) {
      ErrorHandler.logWarning(
        'Unexpected error during level index preload',
        error: e,
        context: 'LevelDataLoader._preloadLevelIndex',
      );
    }
  }

  /// Get cached level data if available
  LevelData? getCachedLevel(String levelId) {
    return _levelCache[levelId];
  }

  /// Get cached biome data if available
  BiomeData? getCachedBiome(String biomeId) {
    return _biomeCache[biomeId];
  }

  /// Load level data by name
  Future<Map<String, dynamic>?> loadLevelData(String levelId) async {
    try {
      final LevelData level = await loadLevel(levelId);
      // Convert LevelData to Map<String, dynamic>
      return <String, dynamic>{
        'id': level.id,
        'name': level.name,
        'description': level.description,
        'width': level.width,
        'height': level.height,
        'tiles': level.tiles,
        'backgroundTiles': level.backgroundTiles,
        'foregroundTiles': level.foregroundTiles,
        'spawnPoint': <String, dynamic>{
          'x': level.spawnPoint.x,
          'y': level.spawnPoint.y,
        },
        'exitPoints': level.exitPoints
            .map(
              (ExitPoint exit) => <String, dynamic>{
                'x': exit.x,
                'y': exit.y,
                'targetLevel': exit.targetLevel,
              },
            )
            .toList(),
        'biomeId': level.biomeId,
        'tilesetId': level.tilesetId,
        'metadata': level.metadata,
      };
    } on LevelNotFoundException catch (e) {
      ErrorHandler.logError(
        'Failed to load level data: Level not found',
        error: e,
        context: 'LevelDataLoader.loadLevelData($levelId)',
      );
      return null;
    } on LevelDataCorruptedException catch (e) {
      ErrorHandler.logError(
        'Failed to load level data: Data corrupted',
        error: e,
        context: 'LevelDataLoader.loadLevelData($levelId)',
      );
      return null;
    } on LevelException catch (e) {
      ErrorHandler.logError(
        'Failed to load level data: Level exception',
        error: e,
        context: 'LevelDataLoader.loadLevelData($levelId)',
      );
      return null;
    } on AssetLoadingException catch (e) {
      ErrorHandler.logError(
        'Failed to load level data: Asset loading error',
        error: e,
        context: 'LevelDataLoader.loadLevelData($levelId)',
      );
      return null;
    } catch (e) {
      ErrorHandler.logError(
        'Failed to load level data: Unexpected error',
        error: e,
        context: 'LevelDataLoader.loadLevelData($levelId)',
      );
      return null;
    }
  }

  /// Check if level data is loaded in cache
  bool isLoaded(String levelId) {
    return _levelCache.containsKey(levelId);
  }

  /// Unload specific level from cache
  void unload(String levelId) {
    _levelCache.remove(levelId);
  }

  /// Clear specific level from cache
  void clearLevel(String levelId) {
    _levelCache.remove(levelId);
  }

  /// Clear all cached data
  void clearCache() {
    _levelCache.clear();
    _biomeCache.clear();
    _tilesetCache.clear();
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    return <String, dynamic>{
      'cached_levels': _levelCache.length,
      'cached_biomes': _biomeCache.length,
      'cached_tilesets': _tilesetCache.length,
    };
  }

  /// Dispose resources
  void dispose() {
    clearCache();
    _isInitialized = false;
  }
}

/// Level data structure loaded from JSON
class LevelData {
  const LevelData({
    required this.id,
    required this.name,
    required this.description,
    required this.width,
    required this.height,
    required this.tiles,
    required this.backgroundTiles,
    required this.foregroundTiles,
    required this.spawnPoint,
    required this.exitPoints,
    required this.biomeId,
    required this.tilesetId,
    required this.metadata,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      width: json['width'] as int,
      height: json['height'] as int,
      tiles: List<int>.from(json['tiles'] as List<dynamic>),
      backgroundTiles: List<int>.from(
        json['backgroundTiles'] as List<dynamic>? ?? <dynamic>[],
      ),
      foregroundTiles: List<int>.from(
        json['foregroundTiles'] as List<dynamic>? ?? <dynamic>[],
      ),
      spawnPoint: SpawnPoint.fromJson(json['spawnPoint'] as Map<String, dynamic>),
      exitPoints: (json['exitPoints'] as List<dynamic>?)
              ?.map<ExitPoint>(
                (e) => ExitPoint.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          <ExitPoint>[],
      biomeId: json['biomeId'] as String,
      tilesetId: json['tilesetId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
  final String id;
  final String name;
  final String description;
  final int width;
  final int height;
  final List<int> tiles;
  final List<int> backgroundTiles;
  final List<int> foregroundTiles;
  final SpawnPoint spawnPoint;
  final List<ExitPoint> exitPoints;
  final String biomeId;
  final String tilesetId;
  final Map<String, dynamic> metadata;
}

/// Biome data structure
class BiomeData {
  const BiomeData({
    required this.id,
    required this.name,
    required this.textures,
    required this.properties,
    required this.musicTracks,
    required this.ambientSounds,
  });

  factory BiomeData.fromJson(Map<String, dynamic> json) {
    return BiomeData(
      id: json['id'] as String,
      name: json['name'] as String,
      textures: Map<String, String>.from(json['textures'] as Map<dynamic, dynamic>),
      properties: Map<String, double>.from(json['properties'] as Map<dynamic, dynamic>),
      musicTracks: List<String>.from(
        json['musicTracks'] as List<dynamic>? ?? <dynamic>[],
      ),
      ambientSounds: List<String>.from(
        json['ambientSounds'] as List<dynamic>? ?? <dynamic>[],
      ),
    );
  }
  final String id;
  final String name;
  final Map<String, String> textures;
  final Map<String, double> properties;
  final List<String> musicTracks;
  final List<String> ambientSounds;
}

/// Tileset data structure
class TilesetData {
  const TilesetData({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.tileWidth,
    required this.tileHeight,
    required this.columns,
    required this.rows,
    required this.tileProperties,
  });

  factory TilesetData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> propertiesJson = json['tileProperties'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<int, TileProperties> tileProperties = <int, TileProperties>{};

    for (final MapEntry<String, dynamic> entry in propertiesJson.entries) {
      final int tileId = int.parse(entry.key);
      tileProperties[tileId] = TileProperties.fromJson(entry.value as Map<String, dynamic>);
    }

    return TilesetData(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      tileWidth: json['tileWidth'] as int,
      tileHeight: json['tileHeight'] as int,
      columns: json['columns'] as int,
      rows: json['rows'] as int,
      tileProperties: tileProperties,
    );
  }
  final String id;
  final String name;
  final String imagePath;
  final int tileWidth;
  final int tileHeight;
  final int columns;
  final int rows;
  final Map<int, TileProperties> tileProperties;
}

/// Properties for individual tiles
class TileProperties {
  const TileProperties({
    required this.solid,
    required this.platform,
    required this.hazard,
    required this.customProperties,
    this.animationFrames,
  });

  factory TileProperties.fromJson(Map<String, dynamic> json) {
    return TileProperties(
      solid: json['solid'] as bool? ?? false,
      platform: json['platform'] as bool? ?? false,
      hazard: json['hazard'] as bool? ?? false,
      animationFrames: json['animationFrames'] as String?,
      customProperties: json['customProperties'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
  final bool solid;
  final bool platform;
  final bool hazard;
  final String? animationFrames;
  final Map<String, dynamic> customProperties;
}

/// World data containing multiple levels
class WorldData {
  const WorldData({
    required this.id,
    required this.name,
    required this.levelReferences,
    required this.biomeIds,
    required this.globalProperties,
  });

  factory WorldData.fromJson(Map<String, dynamic> json) {
    return WorldData(
      id: json['id'] as String,
      name: json['name'] as String,
      levelReferences: (json['levels'] as List<dynamic>)
          .map<LevelReference>(
            (e) => LevelReference.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      biomeIds: List<String>.from(json['biomes'] as List<dynamic>),
      globalProperties: json['globalProperties'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
  final String id;
  final String name;
  final List<LevelReference> levelReferences;
  final List<String> biomeIds;
  final Map<String, dynamic> globalProperties;
}

/// Reference to a level within a world
class LevelReference {
  const LevelReference({
    required this.levelId,
    required this.order,
    required this.unlocked,
    required this.connections,
  });

  factory LevelReference.fromJson(Map<String, dynamic> json) {
    return LevelReference(
      levelId: json['levelId'] as String,
      order: json['order'] as int,
      unlocked: json['unlocked'] as bool? ?? false,
      connections: Map<String, String>.from(
        json['connections'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
      ),
    );
  }
  final String levelId;
  final int order;
  final bool unlocked;
  final Map<String, String> connections;
}

/// Enemy spawn data
class EnemySpawnData {
  const EnemySpawnData({
    required this.enemyType,
    required this.x,
    required this.y,
    required this.properties,
  });

  factory EnemySpawnData.fromJson(Map<String, dynamic> json) {
    return EnemySpawnData(
      enemyType: json['enemyType'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      properties: json['properties'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
  final String enemyType;
  final double x;
  final double y;
  final Map<String, dynamic> properties;
}

/// Collectible data
class CollectibleData {
  const CollectibleData({
    required this.itemType,
    required this.x,
    required this.y,
    required this.value,
    required this.respawns,
  });

  factory CollectibleData.fromJson(Map<String, dynamic> json) {
    return CollectibleData(
      itemType: json['itemType'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      value: json['value'] as int? ?? 1,
      respawns: json['respawns'] as bool? ?? false,
    );
  }
  final String itemType;
  final double x;
  final double y;
  final int value;
  final bool respawns;
}

/// Checkpoint data
class CheckpointData {
  const CheckpointData({
    required this.id,
    required this.x,
    required this.y,
    required this.active,
  });

  factory CheckpointData.fromJson(Map<String, dynamic> json) {
    return CheckpointData(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      active: json['active'] as bool? ?? false,
    );
  }
  final String id;
  final double x;
  final double y;
  final bool active;
}

/// Spawn point data
class SpawnPoint {
  const SpawnPoint({
    required this.x,
    required this.y,
    this.direction,
  });

  factory SpawnPoint.fromJson(Map<String, dynamic> json) {
    return SpawnPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      direction: json['direction'] as String?,
    );
  }
  final double x;
  final double y;
  final String? direction;
}

/// Exit point data
class ExitPoint {
  const ExitPoint({
    required this.x,
    required this.y,
    required this.targetLevel,
    this.targetSpawn,
  });

  factory ExitPoint.fromJson(Map<String, dynamic> json) {
    return ExitPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      targetLevel: json['targetLevel'] as String,
      targetSpawn: json['targetSpawn'] as String?,
    );
  }
  final double x;
  final double y;
  final String targetLevel;
  final String? targetSpawn;
}

/// Level index containing metadata about all levels
class LevelIndex {
  const LevelIndex({
    required this.levels,
    required this.version,
  });

  factory LevelIndex.fromJson(Map<String, dynamic> json) {
    return LevelIndex(
      levels: (json['levels'] as List<dynamic>)
          .map<LevelMetadata>(
            (e) => LevelMetadata.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      version: json['version'] as int,
    );
  }
  final List<LevelMetadata> levels;
  final int version;
}

/// Metadata for individual levels
class LevelMetadata {
  const LevelMetadata({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.tags,
    required this.isBonus,
  });

  factory LevelMetadata.fromJson(Map<String, dynamic> json) {
    return LevelMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? <dynamic>[]),
      isBonus: json['isBonus'] as bool? ?? false,
    );
  }
  final String id;
  final String name;
  final String difficulty;
  final List<String> tags;
  final bool isBonus;
}

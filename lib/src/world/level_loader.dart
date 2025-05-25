import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../utils/logger.dart';
import 'level.dart';

/// Level file parsing and loading utility
/// Handles loading level data from JSON and creating Level instances
class LevelLoader {
  factory LevelLoader() => _instance;
  LevelLoader._internal();
  // Singleton instance
  static final LevelLoader _instance = LevelLoader._internal();

  // Level cache for faster reloading
  final Map<String, Level> _levelCache = <String, Level>{};

  // Flag to control caching behavior
  bool enableCaching = true;

  /// Load a level by its ID
  Future<Level> loadLevel(String levelId) async {
    // Check cache first if enabled
    if (enableCaching && _levelCache.containsKey(levelId)) {
      logger.info('Loading level $levelId from cache');
      return _levelCache[levelId]!;
    }

    logger.info('Loading level $levelId from file');

    // Determine file path based on level ID
    final String filePath = _getLevelFilePath(levelId);
    try {
      // Load level JSON file
      final String jsonData = await rootBundle.loadString(filePath);
      final Level level = await _parseLevelData(jsonData);

      // Cache the level if caching is enabled
      if (enableCaching) {
        _levelCache[levelId] = level;
      }

      return level;
    } catch (e) {
      logger.severe('Error loading level $levelId', e);
      // Return a fallback empty level
      return _createEmptyLevel(levelId);
    }
  }

  /// Clear the level cache
  void clearCache() {
    _levelCache.clear();
    logger.fine('Level cache cleared');
  }

  /// Remove a specific level from the cache
  void removeLevelFromCache(String levelId) {
    _levelCache.remove(levelId);
  }

  /// Parse level JSON data into a Level instance
  Future<Level> _parseLevelData(String jsonData) async {
    final dynamic decoded = jsonDecode(jsonData);
    final Map<String, dynamic> data = decoded as Map<String, dynamic>;

    // Extract basic level info
    final String id = data['id'] as String;
    final String name = data['name'] as String;
    final double width = (data['width'] as num).toDouble();
    final double height = (data['height'] as num).toDouble();
    final double gravity = (data['gravity'] as num?)?.toDouble() ?? 9.8;

    // Extract environment settings
    final String? backgroundPath = data['backgroundPath'] as String?;
    final String? musicPath = data['musicPath'] as String?;
    final String? ambientSoundPath = data['ambientSoundPath'] as String?;
    final BiomeType biomeType = _parseBiomeType(data['biomeType'] as String?);

    // Create the level instance
    final Level level = Level(
      id: id,
      name: name,
      width: width,
      height: height,
      gravity: gravity,
      backgroundPath: backgroundPath,
      musicPath: musicPath,
      ambientSoundPath: ambientSoundPath,
      biomeType: biomeType,
    );

    // Process level elements (will be expanded in future sprints)
    await _processLevelElements(level, data);

    return level;
  }

  /// Process the various elements of a level
  Future<void> _processLevelElements(
    Level level,
    Map<String, dynamic> data,
  ) async {
    // Player spawn point
    if (data.containsKey('playerSpawn')) {
      final Map<String, dynamic> spawnData =
          data['playerSpawn'] as Map<String, dynamic>;
      level.playerSpawnPoint = Vector2(
        (spawnData['x'] as num).toDouble(),
        (spawnData['y'] as num).toDouble(),
      );
    } // Platforms
    if (data.containsKey('platforms')) {
      final List<dynamic> platformsData = data['platforms'] as List<dynamic>;
      // Platform creation will be implemented in Sprint 3
      for (final dynamic platformData in platformsData) {
        // ignore: unused_local_variable
        final Map<String, dynamic> platformInfo =
            platformData as Map<String, dynamic>;
        // Will process platform data in Sprint 3
      }
    }

    // Enemies
    if (data.containsKey('enemies')) {
      final List<dynamic> enemiesData = data['enemies'] as List<dynamic>;
      for (final dynamic enemyData in enemiesData) {
        // ignore: unused_local_variable
        final Map<String, dynamic> enemyInfo =
            enemyData as Map<String, dynamic>;
        // Enemy creation will be implemented in future sprints
      }
    }

    // Other entity types will be processed in future sprints
  }

  /// Convert a string to the corresponding BiomeType
  BiomeType _parseBiomeType(String? typeString) {
    if (typeString == null) return BiomeType.forest;

    switch (typeString.toLowerCase()) {
      case 'cave':
        return BiomeType.cave;
      case 'mountain':
        return BiomeType.mountain;
      case 'aetherrealm':
      case 'aether_realm':
      case 'aether':
        return BiomeType.aetherRealm;
      case 'ruins':
        return BiomeType.ruins;
      case 'settlement':
        return BiomeType.settlement;
      case 'forest':
      default:
        return BiomeType.forest;
    }
  }

  /// Get the file path for a level ID
  String _getLevelFilePath(String levelId) {
    return 'assets/levels/$levelId.json';
  }

  /// Create an empty level with the given ID (for fallback)
  Level _createEmptyLevel(String levelId) {
    return Level(
      id: levelId,
      name: 'Empty Level',
      width: 800,
      height: 600,
      gravity: 9.8,
    );
  }
}

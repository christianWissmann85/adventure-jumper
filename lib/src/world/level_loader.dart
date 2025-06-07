import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../utils/logger.dart';
import 'level.dart';

/// Level file parsing and loading utility
/// Handles loading level data from JSON and creating Level instances
class LevelLoader {
  factory LevelLoader({AssetBundle? assetBundle}) =>
      _instance.._assetBundle = assetBundle;
  LevelLoader._internal();
  // Singleton instance
  static final LevelLoader _instance = LevelLoader._internal();

  // Optional asset bundle for testing
  AssetBundle? _assetBundle;

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

    logger.info(
      'Loading level $levelId from file',
    ); // Determine file path based on level ID
    final String filePath = _getLevelFilePath(levelId);
    try {
      // Load level JSON file using custom asset bundle if provided, otherwise use rootBundle
      final AssetBundle bundle = _assetBundle ?? rootBundle;
      final String jsonData = await bundle.loadString(filePath);
      final Level level = await _parseLevelData(jsonData);

      // Cache the level if caching is enabled
      if (enableCaching) {
        _levelCache[levelId] = level;
      }
      return level;
    } catch (e, stackTrace) {
      logger.severe('Error loading level $levelId', e, stackTrace);
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
    final Map<String, dynamic> data = decoded as Map<String,
        dynamic>; // Check if properties are in a nested structure or at top level
    final Map<String, dynamic> properties = data.containsKey('properties')
        ? data['properties'] as Map<String, dynamic>
        : data;

    // Extract basic level info
    final String id = properties['id'] as String;
    final String name = properties['name'] as String;
    final double width = (properties['width'] as num).toDouble();
    final double height = (properties['height'] as num).toDouble();
    final double gravity = (properties['gravity'] as num?)?.toDouble() ??
        9.8; // Extract environment settings
    final String? backgroundPath = properties['backgroundPath'] as String?;
    final String? musicPath = properties['musicPath'] as String?;
    final String? ambientSoundPath = properties['ambientSoundPath'] as String?;
    final BiomeType biomeType =
        _parseBiomeType(properties['biomeType'] as String?);

    // Parse enhanced level data
    final LevelBounds? levelBounds = _parseLevelBounds(data['bounds']);
    final CameraBounds? cameraBounds = _parseCameraBounds(data['cameraBounds']);
    final LevelGeometry? geometry = _parseLevelGeometry(data['geometry']);
    final Map<String, SpawnPointData>? spawnPoints =
        _parseSpawnPoints(data['spawnPoints']);
    final EnvironmentalData environmentalData =
        _parseEnvironmentalData(data['environment']) ??
            _getDefaultEnvironmentalData();

    // Create the level instance with enhanced data
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
      levelBounds: levelBounds,
      cameraBounds: cameraBounds,
      geometry: geometry,
      spawnPoints: spawnPoints,
      environmentalData: environmentalData,
    );

    // Process level elements and load spawn definitions
    await _processLevelElements(level, data);

    return level;
  }

  /// Process the various elements of a level
  Future<void> _processLevelElements(
    Level level,
    Map<String, dynamic> data,
  ) async {
    // Load entity spawn definitions from level data
    await level.loadSpawnDefinitionsFromData(data);

    // Player spawn point (fallback if not in spawnPoints)
    if (data.containsKey('playerSpawn')) {
      final Map<String, dynamic> spawnData =
          data['playerSpawn'] as Map<String, dynamic>;
      level.playerSpawnPoint = Vector2(
        (spawnData['x'] as num).toDouble(),
        (spawnData['y'] as num).toDouble(),
      );
    }

    // Legacy platform support (will be replaced by entity spawn system)
    if (data.containsKey('platforms')) {
      final List<dynamic> platformsData = data['platforms'] as List<dynamic>;
      for (final dynamic platformData in platformsData) {
        final Map<String, dynamic> platformInfo =
            platformData as Map<String, dynamic>;

        // Convert legacy platform to spawn definition
        final EntitySpawnDefinition platformSpawn = EntitySpawnDefinition(
          id: platformInfo['id'] as String? ??
              'platform_${platformsData.indexOf(platformData)}',
          entityType: 'platform',
          x: (platformInfo['x'] as num).toDouble(),
          y: (platformInfo['y'] as num).toDouble(),
          properties: platformInfo,
        );

        level.addEntitySpawnDefinition(platformSpawn);
      }
    }

    // Legacy enemy support (will be replaced by entity spawn system)
    if (data.containsKey('enemies')) {
      final List<dynamic> enemiesData = data['enemies'] as List<dynamic>;
      for (final dynamic enemyData in enemiesData) {
        final Map<String, dynamic> enemyInfo =
            enemyData as Map<String, dynamic>;

        // Convert legacy enemy to spawn definition
        final EntitySpawnDefinition enemySpawn = EntitySpawnDefinition(
          id: enemyInfo['id'] as String? ??
              'enemy_${enemiesData.indexOf(enemyData)}',
          entityType: 'enemy',
          entitySubtype: enemyInfo['type'] as String?,
          x: (enemyInfo['x'] as num).toDouble(),
          y: (enemyInfo['y'] as num).toDouble(),
          properties: enemyInfo,
        );

        level.addEntitySpawnDefinition(enemySpawn);
      }
    }
  }

  /// Parse level bounds from JSON data
  LevelBounds? _parseLevelBounds(dynamic boundsData) {
    if (boundsData == null) return null;

    final Map<String, dynamic> bounds = boundsData as Map<String, dynamic>;
    return LevelBounds(
      left: (bounds['left'] as num?)?.toDouble() ?? 0,
      right: (bounds['right'] as num).toDouble(),
      top: (bounds['top'] as num?)?.toDouble() ?? 0,
      bottom: (bounds['bottom'] as num).toDouble(),
    );
  }

  /// Parse camera bounds from JSON data
  CameraBounds? _parseCameraBounds(dynamic cameraBoundsData) {
    if (cameraBoundsData == null) return null;

    final Map<String, dynamic> bounds =
        cameraBoundsData as Map<String, dynamic>;
    return CameraBounds(
      left: (bounds['left'] as num?)?.toDouble() ?? 0,
      right: (bounds['right'] as num).toDouble(),
      top: (bounds['top'] as num?)?.toDouble() ?? 0,
      bottom: (bounds['bottom'] as num).toDouble(),
    );
  }

  /// Parse level geometry from JSON data
  LevelGeometry? _parseLevelGeometry(dynamic geometryData) {
    if (geometryData == null) return null;

    final Map<String, dynamic> geometry = geometryData as Map<String, dynamic>;

    // Parse platforms
    final List<PlatformGeometry> platforms = <PlatformGeometry>[];
    if (geometry.containsKey('platforms')) {
      final List<dynamic> platformsData =
          geometry['platforms'] as List<dynamic>;
      for (final dynamic platformData in platformsData) {
        final Map<String, dynamic> platform = platformData as Map<String,
            dynamic>; // Handle both flat and nested position/size structures
        double x, y, width, height;

        if (platform.containsKey('position')) {
          // Nested structure: {"position": {"x": 1400, "y": 2200}}
          final Map<String, dynamic> position =
              platform['position'] as Map<String, dynamic>;
          x = (position['x'] as num).toDouble();
          y = (position['y'] as num).toDouble();
        } else {
          // Flat structure: {"x": 1400, "y": 2200}
          x = (platform['x'] as num).toDouble();
          y = (platform['y'] as num).toDouble();
        }

        if (platform.containsKey('size')) {
          // Nested structure: {"size": {"width": 400, "height": 64}}
          final Map<String, dynamic> size =
              platform['size'] as Map<String, dynamic>;
          width = (size['width'] as num).toDouble();
          height = (size['height'] as num).toDouble();
        } else {
          // Flat structure: {"width": 400, "height": 64}
          width = (platform['width'] as num).toDouble();
          height = (platform['height'] as num).toDouble();
        } // Create properties map if it doesn't exist
        final Map<String, dynamic> properties =
            platform['properties'] as Map<String, dynamic>? ??
                <String, dynamic>{};

        // Add material to properties if it exists in the platform data
        if (platform.containsKey('material')) {
          properties['material'] = platform['material'];
        }

        platforms.add(
          PlatformGeometry(
            id: platform['id'] as String,
            type: platform['type'] as String? ?? 'solid',
            x: x,
            y: y,
            width: width,
            height: height,
            properties: properties,
          ),
        );
      }
    }

    // Parse collision boundaries
    final List<CollisionBoundary> collisionBoundaries = <CollisionBoundary>[];
    if (geometry.containsKey('collisionBoundaries')) {
      final List<dynamic> boundariesData =
          geometry['collisionBoundaries'] as List<dynamic>;
      for (final dynamic boundaryData in boundariesData) {
        final Map<String, dynamic> boundary =
            boundaryData as Map<String, dynamic>;
        final List<dynamic> verticesData =
            boundary['vertices'] as List<dynamic>;
        final List<Vector2> vertices = verticesData.map((dynamic vertex) {
          final Map<String, dynamic> v = vertex as Map<String, dynamic>;
          return Vector2(
            (v['x'] as num).toDouble(),
            (v['y'] as num).toDouble(),
          );
        }).toList();

        collisionBoundaries.add(
          CollisionBoundary(
            id: boundary['id'] as String,
            vertices: vertices,
            type: _parseCollisionType(boundary['type'] as String?),
            properties: boundary['properties'] as Map<String, dynamic>? ??
                <String, dynamic>{},
          ),
        );
      }
    }

    // Parse trigger zones
    final List<TriggerZone> triggerZones = <TriggerZone>[];
    if (geometry.containsKey('triggerZones')) {
      final List<dynamic> zonesData = geometry['triggerZones'] as List<dynamic>;
      for (final dynamic zoneData in zonesData) {
        final Map<String, dynamic> zone = zoneData as Map<String, dynamic>;

        // Handle both flat and nested position/size structures (same as platforms)
        Vector2 position, size;

        if (zone.containsKey('position')) {
          // Nested structure: {"position": {"x": 100, "y": 200}}
          final Map<String, dynamic> posData =
              zone['position'] as Map<String, dynamic>;
          position = Vector2(
            (posData['x'] as num).toDouble(),
            (posData['y'] as num).toDouble(),
          );
        } else {
          // Flat structure: {"x": 100, "y": 200}
          position = Vector2(
            (zone['x'] as num).toDouble(),
            (zone['y'] as num).toDouble(),
          );
        }

        if (zone.containsKey('size')) {
          // Nested structure: {"size": {"width": 100, "height": 50}}
          final Map<String, dynamic> sizeData =
              zone['size'] as Map<String, dynamic>;
          size = Vector2(
            (sizeData['width'] as num).toDouble(),
            (sizeData['height'] as num).toDouble(),
          );
        } else {
          // Flat structure: {"width": 100, "height": 50}
          size = Vector2(
            (zone['width'] as num).toDouble(),
            (zone['height'] as num).toDouble(),
          );
        }

        triggerZones.add(
          TriggerZone(
            id: zone['id'] as String,
            type: zone['type'] as String,
            position: position,
            size: size,
            properties: zone['properties'] as Map<String, dynamic>? ??
                <String, dynamic>{},
          ),
        );
      }
    }

    return LevelGeometry(
      platforms: platforms,
      collisionBoundaries: collisionBoundaries,
      triggerZones: triggerZones,
    );
  }

  /// Parse spawn points from JSON data
  Map<String, SpawnPointData>? _parseSpawnPoints(dynamic spawnPointsData) {
    if (spawnPointsData == null) return null;

    final Map<String, dynamic> spawnPoints =
        spawnPointsData as Map<String, dynamic>;
    final Map<String, SpawnPointData> result = <String, SpawnPointData>{};
    for (final MapEntry<String, dynamic> entry in spawnPoints.entries) {
      final Map<String, dynamic> spawnData =
          entry.value as Map<String, dynamic>;
      result[entry.key] = SpawnPointData(
        id: entry.key,
        entityType: spawnData['entityType'] as String? ??
            entry.key, // Default to spawn point name if not specified
        x: (spawnData['x'] as num).toDouble(),
        y: (spawnData['y'] as num).toDouble(),
        direction: spawnData['direction'] as String?,
        properties: spawnData['properties'] as Map<String, dynamic>? ??
            <String, dynamic>{},
      );
    }

    return result;
  }

  /// Parse environmental data from JSON data
  EnvironmentalData? _parseEnvironmentalData(dynamic environmentData) {
    if (environmentData == null) return null;

    final Map<String, dynamic> environment =
        environmentData as Map<String, dynamic>;

    // Parse lighting data
    LightingData? lightingData;
    if (environment.containsKey('lighting')) {
      final Map<String, dynamic> lighting =
          environment['lighting'] as Map<String, dynamic>;

      // Parse light sources
      final List<LightSource> lightSources = <LightSource>[];
      if (lighting.containsKey('lightSources')) {
        final List<dynamic> sourcesData =
            lighting['lightSources'] as List<dynamic>;
        for (final dynamic sourceData in sourcesData) {
          final Map<String, dynamic> source =
              sourceData as Map<String, dynamic>;
          lightSources.add(
            LightSource(
              position: Vector2(
                (source['position']['x'] as num).toDouble(),
                (source['position']['y'] as num).toDouble(),
              ),
              color: Color(source['color'] as int),
              intensity: (source['intensity'] as num).toDouble(),
              radius: (source['radius'] as num).toDouble(),
            ),
          );
        }
      }

      lightingData = LightingData(
        ambientColor: Color(lighting['ambientColor'] as int? ?? 0xFF444444),
        ambientIntensity:
            (lighting['ambientIntensity'] as num?)?.toDouble() ?? 0.3,
        lightSources: lightSources,
      );
    } // Parse weather data
    WeatherData? weatherData;
    if (environment.containsKey('weather')) {
      final Map<String, dynamic> weather =
          environment['weather'] as Map<String, dynamic>;
      weatherData = WeatherData(
        type: weather['type'] as String? ?? 'clear',
        intensity: (weather['intensity'] as num?)?.toDouble() ?? 1.0,
        properties: weather['properties'] as Map<String, dynamic>? ??
            <String, dynamic>{},
      );
    }

    // Parse ambient effects
    final List<AmbientEffect> ambientEffects = <AmbientEffect>[];
    if (environment.containsKey('ambientEffects')) {
      final List<dynamic> effectsData =
          environment['ambientEffects'] as List<dynamic>;
      for (final dynamic effectData in effectsData) {
        final Map<String, dynamic> effect = effectData as Map<String, dynamic>;
        ambientEffects.add(
          AmbientEffect(
            type: effect['type'] as String,
            properties: effect['properties'] as Map<String, dynamic>? ??
                <String, dynamic>{},
          ),
        );
      }
    }

    // Parse background layers
    final List<BackgroundLayer> backgroundLayers = <BackgroundLayer>[];
    if (environment.containsKey('backgroundLayers')) {
      final List<dynamic> layersData =
          environment['backgroundLayers'] as List<dynamic>;
      for (final dynamic layerData in layersData) {
        final Map<String, dynamic> layer = layerData as Map<String, dynamic>;
        backgroundLayers.add(
          BackgroundLayer(
            imagePath: layer['imagePath'] as String,
            scrollFactor: (layer['scrollFactor'] as num?)?.toDouble() ?? 1.0,
            zIndex: layer['zIndex'] as int? ?? 0,
          ),
        );
      }
    }
    return EnvironmentalData(
      lighting: lightingData ??
          const LightingData(
            ambientColor: Color(0xFF444444),
            ambientIntensity: 0.3,
            lightSources: <LightSource>[],
          ),
      weather: weatherData ??
          const WeatherData(
            type: 'clear',
            intensity: 1.0,
            properties: <String, dynamic>{},
          ),
      ambientEffects: ambientEffects,
      backgroundLayers: backgroundLayers,
    );
  }

  /// Parse collision type from string
  BoundaryType _parseCollisionType(String? typeString) {
    if (typeString == null) return BoundaryType.wall;

    switch (typeString.toLowerCase()) {
      case 'wall':
        return BoundaryType.wall;
      case 'floor':
        return BoundaryType.floor;
      case 'ceiling':
        return BoundaryType.ceiling;
      case 'platform':
        return BoundaryType.platform;
      case 'kill_zone':
      case 'killzone':
        return BoundaryType.killZone;
      case 'trigger':
        return BoundaryType.trigger;
      case 'invisible':
        return BoundaryType.invisible;
      default:
        return BoundaryType.wall;
    }
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
      case 'luminara':
        return BiomeType.luminara;
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

  /// Get default environmental data when none is provided
  EnvironmentalData _getDefaultEnvironmentalData() {
    return const EnvironmentalData(
      lighting: LightingData(
        ambientColor: Color(0xFF444444),
        ambientIntensity: 0.3,
        lightSources: <LightSource>[],
      ),
      weather: WeatherData(
        type: 'clear',
        intensity: 1.0,
        properties: <String, dynamic>{},
      ),
      ambientEffects: <AmbientEffect>[],
      backgroundLayers: <BackgroundLayer>[],
    );
  }
}

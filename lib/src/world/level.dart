import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../entities/aether_shard.dart';
import '../entities/collectible.dart';
import '../entities/enemy.dart';
import '../entities/hazard.dart';
import '../entities/npc.dart';
import '../entities/platform.dart';
import '../player/player.dart';

/// Level data structure and management
/// Contains all data required to construct and maintain a game level
class Level extends Component {
  Level({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.gravity,
    this.backgroundPath,
    this.musicPath,
    this.ambientSoundPath,
    this.biomeType = BiomeType.forest,
    // Enhanced geometry support
    this.levelBounds,
    this.cameraBounds,
    this.geometry,
    this.spawnPoints,
    this.environmentalData,
  });

  // Basic level information
  final String id;
  final String name;
  final double width;
  final double height;
  final double gravity;

  // Environment settings
  final String? backgroundPath;
  final String? musicPath;
  final String? ambientSoundPath;
  final BiomeType biomeType;

  // Enhanced level geometry and boundaries
  final LevelBounds? levelBounds;
  final CameraBounds? cameraBounds;
  final LevelGeometry? geometry;
  final Map<String, SpawnPointData>? spawnPoints;
  final EnvironmentalData? environmentalData;

  // Level content
  Player? player;
  Vector2? playerSpawnPoint;

  // Entity collections
  final List<Platform> platforms = <Platform>[];
  final List<Enemy> enemies = <Enemy>[];
  final List<Collectible> collectibles = <Collectible>[];
  final List<Hazard> hazards = <Hazard>[];
  final List<NPC> npcs = <NPC>[];

  // Checkpoints and portals
  final List<Vector2> checkpoints = <Vector2>[];
  final List<LevelPortal> portals = <LevelPortal>[];

  // Enhanced spawn and boundary data
  final List<SpawnPointData> _entitySpawnPoints = <SpawnPointData>[];
  final List<BoundaryData> _levelBoundaries = <BoundaryData>[];

  // Enhanced entity spawn management
  final Map<String, EntitySpawnDefinition> _entitySpawnDefinitions =
      <String, EntitySpawnDefinition>{};
  final List<EntitySpawnGroup> _spawnGroups = <EntitySpawnGroup>[];

  // Level state tracking
  bool _isLoaded = false;
  bool _isActive = false;

  // Getters for geometry data
  List<SpawnPointData> get entitySpawnPoints =>
      List.unmodifiable(_entitySpawnPoints);
  List<BoundaryData> get levelBoundaries => List.unmodifiable(_levelBoundaries);

  /// Check if level is fully loaded
  @override
  bool get isLoaded => _isLoaded;

  /// Check if level is currently active
  bool get isActive => _isActive;

  /// Get level bounds for collision and camera constraints
  LevelBounds get effectiveLevelBounds =>
      levelBounds ??
      LevelBounds(
        left: 0,
        right: width,
        top: 0,
        bottom: height,
      );

  /// Get camera bounds for camera system
  CameraBounds get effectiveCameraBounds =>
      cameraBounds ??
      CameraBounds(
        left: 0,
        right: width,
        top: 0,
        bottom: height,
      );

  // Lifecycle methods
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load level resources
    await _loadResources();

    // Initialize level geometry
    await _initializeGeometry();

    // Validate level data
    await _validateLevelData();

    // Spawn all entities defined in the level
    await spawnAllEntities();

    _isLoaded = true;
  }

  @override
  void onMount() {
    super.onMount();
    _isActive = true;
  }

  @override
  void onRemove() {
    super.onRemove();
    _isActive = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive) return;

    // Level-specific update logic
    _updateLevelSystems(dt);
  }

  /// Load level resources
  Future<void> _loadResources() async {
    // Background loading
    if (backgroundPath != null) {
      // Background resource loading will be implemented in future sprints
    }

    // Audio resource loading
    if (musicPath != null || ambientSoundPath != null) {
      // Audio resource loading will be implemented in future sprints
    }

    // Environmental resource loading
    if (environmentalData != null) {
      await _loadEnvironmentalResources();
    }
  }

  /// Initialize level geometry and boundaries
  Future<void> _initializeGeometry() async {
    // Process geometry data if available
    if (geometry != null) {
      await _processLevelGeometry(geometry!);
    }

    // Setup boundaries
    _setupLevelBoundaries();

    // Initialize spawn points
    _initializeSpawnPoints();
  }

  /// Process level geometry data
  Future<void> _processLevelGeometry(LevelGeometry geometryData) async {
    // Process platform geometry
    for (final PlatformGeometry platformGeom in geometryData.platforms) {
      final Platform platform = await _createPlatformFromGeometry(platformGeom);
      addPlatform(platform);
    }

    // Process collision boundaries
    for (final CollisionBoundary boundary in geometryData.collisionBoundaries) {
      _levelBoundaries.add(BoundaryData.fromCollisionBoundary(boundary));
    }
  }

  /// Create platform from geometry data
  Future<Platform> _createPlatformFromGeometry(
    PlatformGeometry geometryData,
  ) async {
    return Platform(
      position: Vector2(geometryData.x, geometryData.y),
      size: Vector2(geometryData.width, geometryData.height),
      platformType: geometryData.type,
      isMoving: geometryData.movementData?.isMoving ?? false,
      moveStart: geometryData.movementData?.startPosition,
      moveEnd: geometryData.movementData?.endPosition,
      moveSpeed: geometryData.movementData?.speed,
      isBreakable: geometryData.properties['breakable'] as bool? ?? false,
      isOneWay: geometryData.properties['oneWay'] as bool? ?? false,
    );
  }

  /// Setup level boundaries for collision detection
  void _setupLevelBoundaries() {
    final LevelBounds bounds = effectiveLevelBounds;

    // Add boundary walls
    _levelBoundaries.addAll([
      BoundaryData(
        id: 'left_wall',
        type: BoundaryType.wall,
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(1, bounds.bottom - bounds.top),
      ),
      BoundaryData(
        id: 'right_wall',
        type: BoundaryType.wall,
        position: Vector2(bounds.right, bounds.top),
        size: Vector2(1, bounds.bottom - bounds.top),
      ),
      BoundaryData(
        id: 'top_wall',
        type: BoundaryType.ceiling,
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(bounds.right - bounds.left, 1),
      ),
      BoundaryData(
        id: 'bottom_wall',
        type: BoundaryType.floor,
        position: Vector2(bounds.left, bounds.bottom),
        size: Vector2(bounds.right - bounds.left, 1),
      ),
    ]);
  }

  /// Initialize spawn points for entities
  void _initializeSpawnPoints() {
    if (spawnPoints != null) {
      _entitySpawnPoints.addAll(spawnPoints!.values);
    }

    // Ensure player spawn point is set
    if (playerSpawnPoint == null &&
        spawnPoints?.containsKey('player') == true) {
      final SpawnPointData playerSpawn = spawnPoints!['player']!;
      playerSpawnPoint = Vector2(playerSpawn.x, playerSpawn.y);
    }
  }

  /// Load environmental resources
  Future<void> _loadEnvironmentalResources() async {
    // Environmental effects, lighting, and ambient systems
    // Will be implemented in future sprints
  }

  /// Update level systems
  void _updateLevelSystems(double dt) {
    // Level-specific system updates
    // Boundary checks, environmental effects, etc.
    // Will be expanded in future sprints
  }

  /// Validate level data integrity
  Future<bool> _validateLevelData() async {
    final List<String> validationErrors = <String>[];

    // Check basic dimensions
    if (width <= 0 || height <= 0) {
      validationErrors.add('Invalid level dimensions: ${width}x$height');
    }

    // Check player spawn point
    if (playerSpawnPoint == null) {
      validationErrors.add('No player spawn point defined');
    } else {
      final Vector2 spawn = playerSpawnPoint!;
      if (spawn.x < 0 || spawn.y < 0 || spawn.x > width || spawn.y > height) {
        validationErrors.add('Player spawn point outside level bounds: $spawn');
      }
    }

    // Check level bounds consistency
    final LevelBounds bounds = effectiveLevelBounds;
    if (bounds.left >= bounds.right || bounds.top >= bounds.bottom) {
      validationErrors.add('Invalid level bounds configuration');
    }

    // Check spawn points are within bounds
    for (final SpawnPointData spawnPoint in _entitySpawnPoints) {
      if (!_isPositionInBounds(Vector2(spawnPoint.x, spawnPoint.y))) {
        validationErrors
            .add('Spawn point ${spawnPoint.id} outside level bounds');
      }
    }
    if (validationErrors.isNotEmpty) {
      for (final String error in validationErrors) {
        // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
        print('Level validation error: $error');
      }
      return false;
    }

    return true;
  }

  /// Check if position is within level bounds
  bool _isPositionInBounds(Vector2 position) {
    final LevelBounds bounds = effectiveLevelBounds;
    return position.x >= bounds.left &&
        position.x <= bounds.right &&
        position.y >= bounds.top &&
        position.y <= bounds.bottom;
  }

  // Enhanced entity management methods

  /// Add a platform to the level with bounds checking
  void addPlatform(Platform platform) {
    if (_isPositionInBounds(platform.position)) {
      platforms.add(platform);
      add(platform);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print(
        'Warning: Platform at ${platform.position} is outside level bounds',
      );
    }
  }

  /// Add an enemy with spawn point validation
  void addEnemy(Enemy enemy) {
    if (_isPositionInBounds(enemy.position)) {
      enemies.add(enemy);
      add(enemy);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: Enemy at ${enemy.position} is outside level bounds');
    }
  }

  /// Add a collectible with position validation
  void addCollectible(Collectible collectible) {
    if (_isPositionInBounds(collectible.position)) {
      collectibles.add(collectible);
      add(collectible);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print(
        'Warning: Collectible at ${collectible.position} is outside level bounds',
      );
    }
  }

  /// Add a hazard with bounds checking
  void addHazard(Hazard hazard) {
    if (_isPositionInBounds(hazard.position)) {
      hazards.add(hazard);
      add(hazard);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: Hazard at ${hazard.position} is outside level bounds');
    }
  }

  /// Add an NPC with position validation
  void addNPC(NPC npc) {
    if (_isPositionInBounds(npc.position)) {
      npcs.add(npc);
      add(npc);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: NPC at ${npc.position} is outside level bounds');
    }
  }

  /// Set the player for this level with spawn point validation
  void setPlayer(Player newPlayer, Vector2 spawnPoint) {
    if (!_isPositionInBounds(spawnPoint)) {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: Player spawn point $spawnPoint is outside level bounds');
      // Use fallback spawn point or adjust to bounds
      spawnPoint = _getValidatedSpawnPoint(spawnPoint);
    }

    player = newPlayer;
    playerSpawnPoint = spawnPoint;

    // Position player at spawn point
    newPlayer.position = spawnPoint;

    add(newPlayer);
  }

  /// Get a validated spawn point within level bounds
  Vector2 _getValidatedSpawnPoint(Vector2 requestedSpawn) {
    final LevelBounds bounds = effectiveLevelBounds;
    return Vector2(
      requestedSpawn.x.clamp(bounds.left, bounds.right),
      requestedSpawn.y.clamp(bounds.top, bounds.bottom),
    );
  }

  /// Add a checkpoint with position validation
  void addCheckpoint(Vector2 position) {
    if (_isPositionInBounds(position)) {
      checkpoints.add(position);
      // Checkpoint component will be added in future sprints
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: Checkpoint at $position is outside level bounds');
    }
  }

  /// Add a portal with bounds checking
  void addPortal(LevelPortal portal) {
    if (_isPositionInBounds(portal.position)) {
      portals.add(portal);
      add(portal);
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: Portal at ${portal.position} is outside level bounds');
    }
  }

  /// Get spawn point by ID
  SpawnPointData? getSpawnPoint(String spawnId) {
    return spawnPoints?[spawnId];
  }

  /// Get all spawn points of a specific type
  List<SpawnPointData> getSpawnPointsByType(String entityType) {
    return _entitySpawnPoints
        .where((spawn) => spawn.entityType == entityType)
        .toList();
  }

  /// Get boundary data by ID
  BoundaryData? getBoundary(String boundaryId) {
    try {
      return _levelBoundaries
          .firstWhere((boundary) => boundary.id == boundaryId);
    } catch (e) {
      return null;
    }
  }

  /// Get all boundaries of a specific type
  List<BoundaryData> getBoundariesByType(BoundaryType type) {
    return _levelBoundaries.where((boundary) => boundary.type == type).toList();
  }

  /// Get all entity spawn definitions
  Map<String, EntitySpawnDefinition> get entitySpawnDefinitions =>
      Map.unmodifiable(_entitySpawnDefinitions);

  /// Get all spawn groups
  List<EntitySpawnGroup> get spawnGroups => List.unmodifiable(_spawnGroups);

  /// Clean up level resources when unloading
  void dispose() {
    _isActive = false;
    _isLoaded = false;

    // Clear collections
    platforms.clear();
    enemies.clear();
    collectibles.clear();
    hazards.clear();
    npcs.clear();
    checkpoints.clear();
    portals.clear();
    _entitySpawnPoints.clear();
    _levelBoundaries.clear();
    _entitySpawnDefinitions.clear();
    _spawnGroups.clear();

    // Resource cleanup implementation
  }

  /// Add entity spawn definition
  void addEntitySpawnDefinition(EntitySpawnDefinition definition) {
    if (_isPositionInBounds(Vector2(definition.x, definition.y))) {
      _entitySpawnDefinitions[definition.id] = definition;
    } else {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print(
        'Warning: Entity spawn ${definition.id} at (${definition.x}, ${definition.y}) is outside level bounds',
      );
    }
  }

  /// Add entity spawn group
  void addEntitySpawnGroup(EntitySpawnGroup group) {
    _spawnGroups.add(group);
  }

  /// Spawn entity from definition
  Future<void> spawnEntityFromDefinition(String definitionId) async {
    final EntitySpawnDefinition? definition =
        _entitySpawnDefinitions[definitionId];
    if (definition == null) {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: No spawn definition found for ID: $definitionId');
      return;
    }

    await _spawnEntity(definition);
  }

  /// Spawn entities from a group
  Future<void> spawnEntityGroup(String groupId) async {
    final EntitySpawnGroup? group =
        _spawnGroups.where((g) => g.id == groupId).firstOrNull;

    if (group == null) {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Warning: No spawn group found for ID: $groupId');
      return;
    }

    for (final String definitionId in group.entityDefinitionIds) {
      if (group.spawnDelay > 0) {
        await Future.delayed(
          Duration(milliseconds: (group.spawnDelay * 1000).round()),
        );
      }
      await spawnEntityFromDefinition(definitionId);
    }
  }

  /// Spawn all entities in the level
  Future<void> spawnAllEntities() async {
    for (final EntitySpawnDefinition definition
        in _entitySpawnDefinitions.values) {
      await _spawnEntity(definition);
    }
  }

  /// Spawn individual entity from definition
  Future<void> _spawnEntity(EntitySpawnDefinition definition) async {
    try {
      switch (definition.entityType.toLowerCase()) {
        case 'platform':
          await _spawnPlatform(definition);
          break;
        case 'enemy':
          await _spawnEnemy(definition);
          break;
        case 'collectible':
          await _spawnCollectible(definition);
          break;
        case 'hazard':
          await _spawnHazard(definition);
          break;
        case 'npc':
          await _spawnNPC(definition);
          break;
        case 'portal':
          await _spawnPortal(definition);
          break;
        case 'checkpoint':
          await _spawnCheckpoint(definition);
          break;
        default:
          // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
          print('Warning: Unknown entity type: ${definition.entityType}');
      }
    } catch (e) {
      // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
      print('Error spawning entity ${definition.id}: $e');
    }
  }

  /// Spawn platform from definition
  Future<void> _spawnPlatform(EntitySpawnDefinition definition) async {
    final Platform platform = Platform(
      position: Vector2(definition.x, definition.y),
      size: Vector2(
        definition.properties['width'] as double? ?? 64,
        definition.properties['height'] as double? ?? 16,
      ),
      platformType: definition.properties['type'] as String? ?? 'solid',
      isMoving: definition.properties['isMoving'] as bool? ?? false,
      moveSpeed: definition.properties['moveSpeed'] as double? ?? 50,
      isBreakable: definition.properties['breakable'] as bool? ?? false,
      isOneWay: definition.properties['oneWay'] as bool? ?? false,
    ); // Set movement data if moving platform
    if (definition.properties['isMoving'] == true) {
      final List<dynamic>? path =
          definition.properties['path'] as List<dynamic>?;
      if (path != null && path.length >= 2) {
        // Movement path will be set when Platform class is enhanced with movement support
        // For now, we acknowledge the path data exists
        // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
        print(
          'Platform ${definition.id} has movement path with ${path.length} waypoints',
        );
      }
    }

    addPlatform(platform);
  }

  /// Spawn enemy from definition
  Future<void> _spawnEnemy(EntitySpawnDefinition definition) async {
    // Enemy spawning will be implemented when Enemy class is enhanced
    // For now, we'll create a placeholder
    print(
      'Enemy spawn: ${definition.entitySubtype} at (${definition.x}, ${definition.y})',
    );
  }

  /// Spawn collectible from definition
  Future<void> _spawnCollectible(EntitySpawnDefinition definition) async {
    print(
      'Level._spawnCollectible() - Spawning ${definition.entityType}/${definition.entitySubtype} at (${definition.x}, ${definition.y})',
    );

    try {
      // Handle different collectible types
      switch (definition.entityType.toLowerCase()) {
        case 'aether_shard':
          await _spawnAetherShard(definition);
          break;
        case 'collectible':
          // Handle generic collectibles based on subtype
          if (definition.entitySubtype?.toLowerCase() == 'aether_shard') {
            await _spawnAetherShard(definition);
          } else {
            // Generic collectible spawning for other types
            print(
              'Generic collectible spawn: ${definition.entitySubtype} at (${definition.x}, ${definition.y})',
            );
          }
          break;
        default:
          print(
            'Unknown collectible type: ${definition.entityType}/${definition.entitySubtype}',
          );
      }
    } catch (e) {
      print('Error spawning collectible ${definition.id}: $e');
    }
  }

  /// Spawn AetherShard from definition
  Future<void> _spawnAetherShard(EntitySpawnDefinition definition) async {
    final Vector2 position = Vector2(definition.x, definition.y);

    // Get AetherShard value from properties
    final int aetherValue = definition.properties['value'] as int? ?? 5;

    // Get size from properties or use default
    final double size = definition.properties['size'] as double? ?? 16.0;

    print(
      'Level._spawnAetherShard() - Creating AetherShard with value $aetherValue at $position',
    );

    // Create the AetherShard
    final AetherShard aetherShard = AetherShard(
      position: position,
      aetherValue: aetherValue,
      size: Vector2.all(size),
      id: definition.id,
    );

    // Add to level and collectibles list
    add(aetherShard);
    collectibles.add(aetherShard);

    // Wait for it to load
    await aetherShard.loaded;

    print(
      'Level._spawnAetherShard() - AetherShard ${definition.id} spawned successfully',
    );
  }

  /// Spawn hazard from definition
  Future<void> _spawnHazard(EntitySpawnDefinition definition) async {
    // Hazard spawning will be implemented when Hazard class is enhanced
    // For now, we'll create a placeholder
    print(
      'Hazard spawn: ${definition.entitySubtype} at (${definition.x}, ${definition.y})',
    );
  }

  /// Spawn NPC from definition
  Future<void> _spawnNPC(EntitySpawnDefinition definition) async {
    // NPC spawning will be implemented when NPC class is enhanced
    // For now, we'll create a placeholder
    print(
      'NPC spawn: ${definition.entitySubtype} at (${definition.x}, ${definition.y})',
    );
  }

  /// Spawn portal from definition
  Future<void> _spawnPortal(EntitySpawnDefinition definition) async {
    final LevelPortal portal = LevelPortal(
      position: Vector2(definition.x, definition.y),
      size: Vector2(
        definition.properties['width'] as double? ?? 32,
        definition.properties['height'] as double? ?? 64,
      ),
      targetLevelId: definition.properties['targetLevel'] as String? ?? '',
      targetSpawnPoint: definition.properties['targetSpawn'] != null
          ? Vector2(
              definition.properties['targetSpawn']['x'] as double,
              definition.properties['targetSpawn']['y'] as double,
            )
          : null,
    );

    addPortal(portal);
  }

  /// Spawn checkpoint from definition
  Future<void> _spawnCheckpoint(EntitySpawnDefinition definition) async {
    final Vector2 checkpointPosition = Vector2(definition.x, definition.y);
    addCheckpoint(checkpointPosition);
  }

  /// Get spawn definition by ID
  EntitySpawnDefinition? getSpawnDefinition(String id) {
    return _entitySpawnDefinitions[id];
  }

  /// Get spawn definitions by entity type
  List<EntitySpawnDefinition> getSpawnDefinitionsByType(String entityType) {
    return _entitySpawnDefinitions.values
        .where(
          (def) => def.entityType.toLowerCase() == entityType.toLowerCase(),
        )
        .toList();
  }

  /// Get spawn definitions by entity subtype
  List<EntitySpawnDefinition> getSpawnDefinitionsBySubtype(
    String entitySubtype,
  ) {
    return _entitySpawnDefinitions.values
        .where(
          (def) =>
              def.entitySubtype?.toLowerCase() == entitySubtype.toLowerCase(),
        )
        .toList();
  }

  /// Remove spawn definition
  bool removeSpawnDefinition(String id) {
    return _entitySpawnDefinitions.remove(id) != null;
  }

  /// Clear all spawn definitions
  void clearSpawnDefinitions() {
    _entitySpawnDefinitions.clear();
    _spawnGroups.clear();
  }

  /// Load spawn definitions from level data
  Future<void> loadSpawnDefinitionsFromData(
    Map<String, dynamic> levelData,
  ) async {
    // Load entity spawn definitions (supports both array and map formats)
    if (levelData.containsKey('entitySpawnDefinitions')) {
      final dynamic spawnData = levelData['entitySpawnDefinitions'];
      Map<String, dynamic> spawnDefs;

      // Handle both array format and map format
      if (spawnData is List<dynamic>) {
        // Convert array format to map format
        spawnDefs = <String, dynamic>{};
        for (final dynamic item in spawnData) {
          if (item is Map<String, dynamic> && item.containsKey('id')) {
            final String id = item['id'] as String;
            spawnDefs[id] = item;
          }
        }
      } else if (spawnData is Map<String, dynamic>) {
        // Already in map format
        spawnDefs = spawnData;
      } else {
        // Invalid format, skip
        return;
      }

      for (final MapEntry<String, dynamic> entry in spawnDefs.entries) {
        final String id = entry.key;
        final Map<String, dynamic> definition =
            entry.value as Map<String, dynamic>;

        final EntitySpawnDefinition spawnDefinition = EntitySpawnDefinition(
          id: id,
          entityType: definition['entityType'] as String,
          entitySubtype: definition['entitySubtype'] as String?,
          x: (definition['x'] as num).toDouble(),
          y: (definition['y'] as num).toDouble(),
          properties: definition['properties'] as Map<String, dynamic>? ??
              <String, dynamic>{},
          spawnConditions:
              definition['spawnConditions'] as Map<String, dynamic>? ??
                  <String, dynamic>{},
        );

        addEntitySpawnDefinition(spawnDefinition);
      }
    }

    // Load entity spawn definitions (legacy format)
    if (levelData.containsKey('entities')) {
      final List<dynamic> entities = levelData['entities'] as List<dynamic>;
      for (final dynamic entityData in entities) {
        final Map<String, dynamic> entity = entityData as Map<String, dynamic>;

        final EntitySpawnDefinition definition = EntitySpawnDefinition(
          id: entity['id'] as String? ??
              '${entity['type']}_${entities.indexOf(entityData)}',
          entityType: entity['type'] as String,
          entitySubtype: entity['subtype'] as String?,
          x: (entity['position']['x'] as num).toDouble(),
          y: (entity['position']['y'] as num).toDouble(),
          properties: entity['properties'] as Map<String, dynamic>? ??
              <String, dynamic>{},
          spawnConditions: entity['spawnConditions'] as Map<String, dynamic>? ??
              <String, dynamic>{},
        );

        addEntitySpawnDefinition(definition);
      }
    }

    // Load spawn groups
    if (levelData.containsKey('spawnGroups')) {
      final List<dynamic> groups = levelData['spawnGroups'] as List<dynamic>;
      for (final dynamic groupData in groups) {
        final Map<String, dynamic> group = groupData as Map<String, dynamic>;

        final EntitySpawnGroup spawnGroup = EntitySpawnGroup(
          id: group['id'] as String,
          name: group['name'] as String? ?? group['id'] as String,
          entityDefinitionIds:
              List<String>.from(group['entities'] as List<dynamic>),
          spawnDelay: (group['spawnDelay'] as num?)?.toDouble() ?? 0.0,
          maxConcurrent: group['maxConcurrent'] as int? ?? -1,
          respawnEnabled: group['respawnEnabled'] as bool? ?? false,
          respawnDelay: (group['respawnDelay'] as num?)?.toDouble() ?? 30.0,
          spawnConditions: group['spawnConditions'] as Map<String, dynamic>? ??
              <String, dynamic>{},
        );

        addEntitySpawnGroup(spawnGroup);
      }
    }
  }
}

/// Portal to another level or area
class LevelPortal extends Component {
  LevelPortal({
    required this.position,
    required this.size,
    required this.targetLevelId,
    this.targetSpawnPoint,
  });

  final Vector2 position;
  final Vector2 size;
  final String targetLevelId;
  final Vector2? targetSpawnPoint;

  bool isActive = true;

  // Implementation will be expanded in future sprints
}

/// Biome types for level theming
enum BiomeType {
  forest,
  cave,
  mountain,
  aetherRealm,
  ruins,
  settlement,
  luminara,
}

/// Level bounds for collision detection and world constraints
class LevelBounds {
  const LevelBounds({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  Vector2 get center => Vector2((left + right) / 2, (top + bottom) / 2);

  bool contains(Vector2 position) {
    return position.x >= left &&
        position.x <= right &&
        position.y >= top &&
        position.y <= bottom;
  }

  bool overlaps(LevelBounds other) {
    return left < other.right &&
        right > other.left &&
        top < other.bottom &&
        bottom > other.top;
  }
}

/// Camera bounds for camera movement constraints
class CameraBounds {
  const CameraBounds({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  Vector2 get center => Vector2((left + right) / 2, (top + bottom) / 2);

  Vector2 constrainPosition(Vector2 position) {
    return Vector2(
      position.x.clamp(left, right),
      position.y.clamp(top, bottom),
    );
  }
}

/// Level geometry data structure
class LevelGeometry {
  const LevelGeometry({
    required this.platforms,
    required this.collisionBoundaries,
    required this.triggerZones,
  });

  final List<PlatformGeometry> platforms;
  final List<CollisionBoundary> collisionBoundaries;
  final List<TriggerZone> triggerZones;
}

/// Platform geometry definition
class PlatformGeometry {
  const PlatformGeometry({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.properties,
    this.movementData,
  });

  final String id;
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;
  final Map<String, dynamic> properties;
  final PlatformMovementData? movementData;
}

/// Platform movement data for moving platforms
class PlatformMovementData {
  const PlatformMovementData({
    required this.isMoving,
    required this.startPosition,
    required this.endPosition,
    required this.speed,
    this.waitTime,
    this.movementType,
  });

  final bool isMoving;
  final Vector2 startPosition;
  final Vector2 endPosition;
  final double speed;
  final double? waitTime;
  final String? movementType;
}

/// Collision boundary definition
class CollisionBoundary {
  const CollisionBoundary({
    required this.id,
    required this.type,
    required this.vertices,
    required this.properties,
  });

  final String id;
  final BoundaryType type;
  final List<Vector2> vertices;
  final Map<String, dynamic> properties;
}

/// Trigger zone for level events
class TriggerZone {
  const TriggerZone({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.properties,
  });

  final String id;
  final String type;
  final Vector2 position;
  final Vector2 size;
  final Map<String, dynamic> properties;
}

/// Spawn point data for entity placement
class SpawnPointData {
  const SpawnPointData({
    required this.id,
    required this.entityType,
    required this.x,
    required this.y,
    required this.properties,
    this.direction,
  });

  final String id;
  final String entityType;
  final double x;
  final double y;
  final String? direction;
  final Map<String, dynamic> properties;
}

/// Boundary data for level constraints
class BoundaryData {
  const BoundaryData({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.properties,
  });

  factory BoundaryData.fromCollisionBoundary(CollisionBoundary boundary) {
    // Calculate bounding box from vertices
    double minX = boundary.vertices.first.x;
    double maxX = boundary.vertices.first.x;
    double minY = boundary.vertices.first.y;
    double maxY = boundary.vertices.first.y;

    for (final Vector2 vertex in boundary.vertices) {
      minX = minX < vertex.x ? minX : vertex.x;
      maxX = maxX > vertex.x ? maxX : vertex.x;
      minY = minY < vertex.y ? minY : vertex.y;
      maxY = maxY > vertex.y ? maxY : vertex.y;
    }

    return BoundaryData(
      id: boundary.id,
      type: boundary.type,
      position: Vector2(minX, minY),
      size: Vector2(maxX - minX, maxY - minY),
      properties: boundary.properties,
    );
  }

  final String id;
  final BoundaryType type;
  final Vector2 position;
  final Vector2 size;
  final Map<String, dynamic>? properties;
}

/// Types of boundaries in the level
enum BoundaryType {
  wall,
  floor,
  ceiling,
  platform,
  killZone,
  trigger,
  invisible,
}

/// Environmental data for level theming and effects
class EnvironmentalData {
  const EnvironmentalData({
    required this.lighting,
    required this.weather,
    required this.ambientEffects,
    required this.backgroundLayers,
  });

  final LightingData lighting;
  final WeatherData weather;
  final List<AmbientEffect> ambientEffects;
  final List<BackgroundLayer> backgroundLayers;
}

/// Lighting configuration for the level
class LightingData {
  const LightingData({
    required this.ambientColor,
    required this.ambientIntensity,
    required this.lightSources,
  });

  final Color ambientColor;
  final double ambientIntensity;
  final List<LightSource> lightSources;
}

/// Weather effects for the level
class WeatherData {
  const WeatherData({
    required this.type,
    required this.intensity,
    required this.properties,
  });

  final String type;
  final double intensity;
  final Map<String, dynamic> properties;
}

/// Ambient effects like particles, animations
class AmbientEffect {
  const AmbientEffect({
    required this.type,
    required this.properties,
  });

  final String type;
  final Map<String, dynamic> properties;
}

/// Background layer for parallax scrolling
class BackgroundLayer {
  const BackgroundLayer({
    required this.imagePath,
    required this.scrollFactor,
    required this.zIndex,
  });

  final String imagePath;
  final double scrollFactor;
  final int zIndex;
}

/// Light source definition
class LightSource {
  const LightSource({
    required this.position,
    required this.color,
    required this.intensity,
    required this.radius,
  });

  final Vector2 position;
  final Color color;
  final double intensity;
  final double radius;
}

/// Entity spawn definition for level entity placement
class EntitySpawnDefinition {
  const EntitySpawnDefinition({
    required this.id,
    required this.entityType,
    required this.x,
    required this.y,
    this.entitySubtype,
    this.properties = const <String, dynamic>{},
    this.spawnConditions = const <String, dynamic>{},
  });

  final String id;
  final String entityType;
  final String? entitySubtype;
  final double x;
  final double y;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> spawnConditions;

  /// Check if spawn conditions are met
  bool canSpawn(Map<String, dynamic> gameState) {
    // Implement spawn condition checking logic
    // For now, return true for all spawns
    return true;
  }

  /// Create a copy with updated properties
  EntitySpawnDefinition copyWith({
    String? id,
    String? entityType,
    String? entitySubtype,
    double? x,
    double? y,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? spawnConditions,
  }) {
    return EntitySpawnDefinition(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entitySubtype: entitySubtype ?? this.entitySubtype,
      x: x ?? this.x,
      y: y ?? this.y,
      properties: properties ?? this.properties,
      spawnConditions: spawnConditions ?? this.spawnConditions,
    );
  }
}

/// Entity spawn group for coordinated spawning
class EntitySpawnGroup {
  const EntitySpawnGroup({
    required this.id,
    required this.name,
    required this.entityDefinitionIds,
    this.spawnDelay = 0.0,
    this.maxConcurrent = -1,
    this.respawnEnabled = false,
    this.respawnDelay = 30.0,
    this.spawnConditions = const <String, dynamic>{},
  });

  final String id;
  final String name;
  final List<String> entityDefinitionIds;
  final double spawnDelay;
  final int maxConcurrent; // -1 for unlimited
  final bool respawnEnabled;
  final double respawnDelay;
  final Map<String, dynamic> spawnConditions;

  /// Check if group can spawn
  bool canSpawn(Map<String, dynamic> gameState) {
    // Implement group spawn condition checking logic
    return true;
  }
}

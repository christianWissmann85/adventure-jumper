import 'package:flame/components.dart';

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

  // Level state tracking
  bool _isLoaded = false;
  bool _isActive = false;

  /// Check if level is fully loaded
  @override
  bool get isLoaded => _isLoaded;

  /// Check if level is currently active
  bool get isActive => _isActive;

  // Lifecycle methods

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load level resources
    await _loadResources();

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

    // Level-specific update logic (will be implemented in later sprints)
  }

  /// Load level resources (will be implemented in later sprints)
  Future<void> _loadResources() async {
    // Resource loading implementation
  }

  /// Add a platform to the level
  void addPlatform(Platform platform) {
    platforms.add(platform);
    add(platform);
  }

  /// Add an enemy to the level
  void addEnemy(Enemy enemy) {
    enemies.add(enemy);
    add(enemy);
  }

  /// Add a collectible to the level
  void addCollectible(Collectible collectible) {
    collectibles.add(collectible);
    add(collectible);
  }

  /// Add a hazard to the level
  void addHazard(Hazard hazard) {
    hazards.add(hazard);
    add(hazard);
  }

  /// Add an NPC to the level
  void addNPC(NPC npc) {
    npcs.add(npc);
    add(npc);
  }

  /// Set the player for this level
  void setPlayer(Player newPlayer, Vector2 spawnPoint) {
    player = newPlayer;
    playerSpawnPoint = spawnPoint;

    // Position player at spawn point
    newPlayer.position = spawnPoint;

    add(newPlayer);
  }

  /// Add a checkpoint to the level
  void addCheckpoint(Vector2 position) {
    checkpoints.add(position);
    // Checkpoint component will be added in future sprints
  }

  /// Add a portal to another level
  void addPortal(LevelPortal portal) {
    portals.add(portal);
    add(portal);
  }

  /// Clean up level resources when unloading
  void dispose() {
    _isActive = false;
    _isLoaded = false;

    // Resource cleanup implementation
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
}

import 'dart:ui';

import 'package:flame/components.dart';

import '../entities/platform.dart';
import '../player/player.dart';
import '../systems/physics_system.dart';
import '../world/level.dart';
import '../world/level_loader.dart';

/// Game world container and state management
/// Handles world loading, entity management, and level transitions
class GameWorld extends Component {
  Player? _player;
  // List to track all platforms in the world for system registration
  final List<Platform> _platforms = <Platform>[]; // Level management
  Level? _currentLevel;
  final LevelLoader _levelLoader = LevelLoader();
  String _currentLevelId = 'sprint2_test_level';
  @override
  Future<void> onLoad() async {
    print('🌍 [DEBUG] GameWorld.onLoad() - Starting world initialization');

    // Load the Sprint 2 test level instead of hardcoded setup
    print('🌍 [DEBUG] GameWorld.onLoad() - Loading Sprint 2 test level');
    await loadLevel(_currentLevelId);

    print('🌍 [DEBUG] GameWorld.onLoad() - World initialization complete');

    // TODO(world): Initialize world entities
    // TODO(world): Set up world systems
  }

  /// Get the player for external system integration
  Player? get player => _player;

  /// Load a specific level
  Future<void> loadLevel(String levelId) async {
    print('🌍 [DEBUG] GameWorld.loadLevel() - Loading level: $levelId');

    try {
      // Clear existing level content
      if (_currentLevel != null) {
        unloadLevel();
      }

      // Load the new level
      _currentLevel = await _levelLoader.loadLevel(levelId);
      _currentLevelId = levelId;

      // Add level to world
      add(_currentLevel!);

      // Set up player from level spawn point
      await _setupPlayerFromLevel();

      // Register platforms with our tracking list
      _updatePlatformsList();

      print('🌍 [DEBUG] GameWorld.loadLevel() - Level loaded successfully');
    } catch (e) {
      print(
        '🌍 [ERROR] GameWorld.loadLevel() - Failed to load level $levelId: $e',
      );
      // Fallback to hardcoded setup if level loading fails
      await _setupFallbackLevel();
    }
  }

  /// Set up player from level data
  Future<void> _setupPlayerFromLevel() async {
    if (_currentLevel == null) return;

    final Vector2 spawnPoint =
        _currentLevel!.playerSpawnPoint ?? Vector2(100, 300);

    print(
      '🌍 [DEBUG] GameWorld._setupPlayerFromLevel() - Creating player at $spawnPoint',
    );

    // Create player at level spawn point
    _player = Player(
      position: spawnPoint,
      size: Vector2(32, 48), // Player size
    );

    // Add player to the world
    add(_player!);

    // Wait for player to fully load
    await _player!.loaded;

    print(
      '🌍 [DEBUG] GameWorld._setupPlayerFromLevel() - Player setup complete',
    );
  }

  /// Update platforms list from current level
  void _updatePlatformsList() {
    _platforms.clear();
    if (_currentLevel != null) {
      _platforms.addAll(_currentLevel!.platforms);
    }
  }

  /// Fallback to hardcoded setup if level loading fails
  Future<void> _setupFallbackLevel() async {
    print(
      '🌍 [DEBUG] GameWorld._setupFallbackLevel() - Setting up fallback level',
    );

    // Create fallback player
    _player = Player(
      position: Vector2(100, 300),
      size: Vector2(32, 48),
    );
    add(_player!);
    await _player!.loaded;

    // Create basic fallback platforms
    final List<Platform> fallbackPlatforms = [
      Platform(
        position: Vector2(0, 450),
        size: Vector2(800, 50),
        platformType: 'solid',
      ),
      Platform(
        position: Vector2(200, 350),
        size: Vector2(150, 20),
        platformType: 'grass',
      ),
    ];

    for (final platform in fallbackPlatforms) {
      add(platform);
      await platform.loaded;
      _platforms.add(platform);
    }

    print(
      '🌍 [DEBUG] GameWorld._setupFallbackLevel() - Fallback level setup complete',
    );
  }

  /// Unload current level
  void unloadLevel() {
    if (_currentLevel != null) {
      _currentLevel!.removeFromParent();
      _currentLevel = null;
    }

    // Clear platforms list
    _platforms.clear();

    // Remove player if it exists
    if (_player != null) {
      _player!.removeFromParent();
      _player = null;
    }

    print('🌍 [DEBUG] GameWorld.unloadLevel() - Level unloaded');
  }

  /// Add entity to world
  void addEntity(Component entity) {
    add(entity);
  }

  /// Remove entity from world
  void removeEntity(Component entity) {
    entity.removeFromParent();
  }

  /// Register all platforms with physics system
  Future<void> registerPlatformsWithPhysics(PhysicsSystem physicsSystem) async {
    print(
      'PHASE 1 DEBUG: GameWorld.registerPlatformsWithPhysics() - Starting registration',
    );
    print('  Total platforms to register: ${_platforms.length}');
    print('  PhysicsSystem entity count before: ${physicsSystem.entityCount}');

    // CRITICAL FIX: Wait for all platforms to be fully loaded before registration
    print('  Waiting for all platforms to be fully loaded...');
    for (int i = 0; i < _platforms.length; i++) {
      final Platform platform = _platforms[i];
      print('    Waiting for platform $i to load...');
      await platform.loaded;
      print('    Platform $i loaded successfully');
    }
    print('  All platforms are now fully loaded');

    for (int i = 0; i < _platforms.length; i++) {
      final Platform platform = _platforms[i];
      print('  Registering platform $i:');
      print('    Platform type: ${platform.type}');
      print('    Platform ID: ${platform.id}');
      print('    Platform position: ${platform.position}');
      print('    Platform size: ${platform.size}');
      print('    Platform isActive: ${platform.isActive}');
      print('    Platform has physics: ${platform.physics != null}');

      // Check if physics system can process this entity
      final bool canProcess = physicsSystem.canProcessEntity(platform);
      print('    PhysicsSystem.canProcessEntity(): $canProcess');

      physicsSystem.addEntity(platform);
      print(
        '    Platform registered. PhysicsSystem entity count now: ${physicsSystem.entityCount}',
      );
    }

    print(
      'PHASE 1 DEBUG: GameWorld.registerPlatformsWithPhysics() - Registration completed',
    );
    print('  PhysicsSystem final entity count: ${physicsSystem.entityCount}');
  }

  /// Get all platforms for external system integration
  List<Platform> get platforms => _platforms;

  @override
  void render(Canvas canvas) {
    print(
      '🌍 [DEBUG] GameWorld.render() called - children: ${children.length}',
    );

    // Always call super.render to ensure child components are rendered
    super.render(canvas);

    print('🌍 [DEBUG] GameWorld.render() completed');
  }
}

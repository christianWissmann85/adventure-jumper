import 'package:flame/components.dart';

import '../entities/platform.dart';
import '../player/player.dart';
import '../systems/physics_system.dart';

/// Game world container and state management
/// Handles world loading, entity management, and level transitions
class GameWorld extends World {
  Player? _player;
  // List to track all platforms in the world for system registration
  final List<Platform> _platforms = <Platform>[];
  @override
  Future<void> onLoad() async {
    // Create and add a test player entity for Sprint 1
    await _setupTestPlayer();

    // Create and add test platforms for Sprint 1
    await _setupTestPlatforms();

    // TODO(world): Load initial level/world
    // TODO(world): Initialize world entities
    // TODO(world): Set up world systems
  }

  /// Set up a test player for Sprint 1 keyboard input testing
  Future<void> _setupTestPlayer() async {
    // Create player at a test position
    _player = Player(
      position: Vector2(100, 300), // Starting position
      size: Vector2(32, 48), // Player size
    );

    // Add player to the world
    add(_player!);

    // Wait for player to fully load
    await _player!.loaded;
  }

  /// Set up test platforms for Sprint 1 testing
  Future<void> _setupTestPlatforms() async {
    // Create a ground platform
    final Platform ground = Platform(
      position: Vector2(0, 450), // Ground level
      size: Vector2(800, 50), // Wide ground platform
      platformType: 'solid',
    );

    // Create some additional platforms for testing
    final Platform platform1 = Platform(
      position: Vector2(200, 350),
      size: Vector2(150, 20),
      platformType: 'grass',
    );

    final Platform platform2 = Platform(
      position: Vector2(450, 280),
      size: Vector2(100, 20),
      platformType: 'ice',
    );

    // Create a one-way platform for testing jump-through functionality
    final Platform oneWayPlatform = Platform(
      position: Vector2(300, 200),
      size: Vector2(120, 10), // Thinner than normal platforms
      platformType: 'grass',
      isOneWay: true, // Can be jumped through from below
    );

    // Add platforms to the world
    add(ground);
    add(platform1);
    add(platform2);
    add(oneWayPlatform);

    // Wait for platforms to load
    await ground.loaded;
    await platform1.loaded;
    await platform2.loaded;
    await oneWayPlatform.loaded;

    // Store platform references for later registration with physics system
    _platforms.add(ground);
    _platforms.add(platform1);
    _platforms.add(platform2);
    _platforms.add(oneWayPlatform);
  }

  /// Get the player for external system integration
  Player? get player => _player;

  /// Load a specific level
  Future<void> loadLevel(String levelId) async {
    // TODO(world): Implement level loading
  }

  /// Unload current level
  void unloadLevel() {
    // TODO(world): Implement level unloading
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
  void registerPlatformsWithPhysics(PhysicsSystem physicsSystem) {
    for (final Platform platform in _platforms) {
      physicsSystem.addEntity(platform);
    }
  }

  /// Get all platforms for external system integration
  List<Platform> get platforms => _platforms;
}

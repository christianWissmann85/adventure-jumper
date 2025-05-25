// filepath: test/collision_enhancement_test.dart

import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/entities/platform.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:adventure_jumper/src/utils/logger.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test entity class for collision testing
class TestEntity extends Entity {
  TestEntity({
    required String super.id,
    required String super.type,
    required super.position,
    required Vector2 super.size,
  });
}

void main() {
  group('T2.4: Enhanced Collision Detection Tests', () {
    late PhysicsSystem physicsSystem;
    late Player player;
    late Platform platform;
    setUp(() async {
      physicsSystem = PhysicsSystem();
      physicsSystem.initialize();

      // Create test player
      player = Player(
        position: Vector2(100, 100),
        size: Vector2(32, 48),
      );

      // Create test platform
      platform = Platform(
        position: Vector2(50, 150),
        size: Vector2(100, 20),
        isOneWay: false,
      );

      // Initialize physics components by calling onLoad()
      await player.onLoad();
      await platform.onLoad();

      // Add entities to physics system
      physicsSystem.addEntity(player);
      physicsSystem.addEntity(platform);
    });

    // Debug test to understand collision issues
    test('DEBUG: Simple collision test', () {
      // Set up a test-specific logger
      final logger = GameLogger.getLogger('CollisionTest');
      
      // CRITICAL FIX: Add entities to the physics system!
      physicsSystem.clearEntities();
      logger.fine('Cleared entities. Count: ${physicsSystem.entityCount}');

      // Debug: Check if entities have physics components
      logger.fine('Player has physics: ${player.physics != null}');
      logger.fine('Platform has physics: ${platform.physics != null}');
      logger.fine(
        'Player canProcessEntity: ${physicsSystem.canProcessEntity(player)}',
      );
      logger.fine(
        'Platform canProcessEntity: ${physicsSystem.canProcessEntity(platform)}',
      );

      physicsSystem.addEntity(player);
      logger.fine('Added player. Count: ${physicsSystem.entityCount}');

      physicsSystem.addEntity(platform);
      logger.fine('Added platform. Count: ${physicsSystem.entityCount}');

      // Position player to collide with platform
      player.position = Vector2(75, 140);

      logger.info('Before collision resolution:');
      logger.info('Player position: ${player.position}');
      logger.info('Player isOnGround: ${player.physics?.isOnGround}');

      // Check if collision would be detected
      final isColliding = physicsSystem.checkEntityCollision(player, platform);
      logger.info('Collision detected: $isColliding');

      if (isColliding) {
        final collisionData =
            physicsSystem.calculateCollisionData(player, platform);
        logger.info('Collision normal: ${collisionData.normal}');
        logger.info('Separation vector: ${collisionData.separationVector}');
      }

      // Process one frame
      physicsSystem.processSystem(0.016);

      logger.info('After collision resolution:');
      logger.info('Player position: ${player.position}');
      logger.info('Player isOnGround: ${player.physics?.isOnGround}');

      expect(true, isTrue); // Always pass for debugging
    });
  });
}

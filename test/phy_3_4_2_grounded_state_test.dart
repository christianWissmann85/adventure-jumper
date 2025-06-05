import 'package:adventure_jumper/src/entities/platform.dart';
import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/collision_system.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized for UI operations

  group('PHY-3.4.2: Grounded State Management Tests', () {
    late AdventureJumperGame game; // Use specific type for direct system access
    late CollisionSystem collisionSystem;
    late PhysicsSystem physicsSystem;
    late Player player;
    late Platform groundPlatform;

    setUp(() async {
      // Removed undefined constructor parameters
      game = AdventureJumperGame();

      // Initialize game systems
      await game.onLoad();

      // Get system references
      collisionSystem = game.collisionSystem;
      physicsSystem = game.physicsSystem;

      // Create test entities
      player = Player()
        ..position = Vector2(100, 100)
        ..size = Vector2(32, 48); // Ensure size is set for player

      groundPlatform = Platform(
        platformType: "solid", // Use String for platformType
        position: Vector2(50, 150),
        size: Vector2(200, 20),
      ); // ..setupEntity() is called by onLoad when added to game

      // Add entities to game and systems
      await game.add(player);
      await game.add(groundPlatform);

      // Add to systems
      physicsSystem.addEntity(player);
      physicsSystem.addEntity(groundPlatform);
      collisionSystem.addEntity(player);
      collisionSystem.addEntity(groundPlatform);
    });

    test('should initialize grounded state correctly', () async {
      final collisionComponent = player.collision;

      // Initial state should not be grounded
      final groundInfo = await collisionComponent.getGroundInfo();
      expect(groundInfo, isNull);
      expect(groundInfo?.isGrounded ?? false, isFalse);
    });

    test('should detect ground contact and set grounded state', () async {
      // Position player on ground
      player.position = Vector2(100, 130); // Just above ground platform
      // Simulate physics update to detect collision
      physicsSystem.update(1 / 60); // 16.67ms frame
      collisionSystem.update(1 / 60);

      final collisionComponent = player.collision;
      final groundInfo = await collisionComponent.getGroundInfo();

      // Should now be grounded
      expect(groundInfo?.isGrounded, isTrue);
      expect(groundInfo, isNotNull);
      expect(groundInfo!.coyoteTimeRemaining, greaterThan(0));
    });

    test('should maintain coyote time when leaving ground', () async {
      // First, establish ground contact
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final collisionComponent = player.collision;
      expect((await collisionComponent.getGroundInfo())?.isGrounded, isTrue);

      // Move player off ground
      player.position = Vector2(100, 50); // Well above ground

      // Update once - should still have coyote time
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final groundInfo = await collisionComponent.getGroundInfo();

      // Should still be considered grounded due to coyote time
      expect(groundInfo?.isGrounded, isTrue);
      expect(
        groundInfo!.coyoteTimeRemaining,
        lessThan(0.15),
      ); // Less than initial 150ms
      expect(
        groundInfo.coyoteTimeRemaining,
        greaterThan(0.1),
      ); // But still has time,
    });

    test('should expire coyote time after sufficient duration', () async {
      // First, establish ground contact
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final collisionComponent = player.collision;
      expect((await collisionComponent.getGroundInfo())?.isGrounded, isTrue);

      // Move player off ground
      player.position = Vector2(100, 50);

      // Simulate enough time for coyote time to expire (150ms + buffer)
      for (int i = 0; i < 12; i++) {
        // 12 frames at 60fps = 200ms
        physicsSystem.update(1 / 60);
        collisionSystem.update(1 / 60);
      }
      final groundInfo = await collisionComponent.getGroundInfo();

      // Should no longer be grounded
      expect(groundInfo?.isGrounded ?? false, isFalse);
      // Coyote time might not be null immediately but isGrounded should be false
    });

    test('should reset coyote time when returning to ground', () async {
      // Establish ground contact
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final collisionComponent = player.collision;
      expect((await collisionComponent.getGroundInfo())?.isGrounded, isTrue);

      // Leave ground briefly
      player.position = Vector2(100, 50);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);

      final groundInfoAfterLeaving = await collisionComponent.getGroundInfo();
      final reducedCoyoteTime = groundInfoAfterLeaving!.coyoteTimeRemaining;
      expect(reducedCoyoteTime, lessThan(0.15));

      // Return to ground
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final groundInfoAfterReturning = await collisionComponent.getGroundInfo();

      // Coyote time should be reset to full duration
      expect(
        groundInfoAfterReturning!.coyoteTimeRemaining,
        closeTo(0.15, 0.02),
      );
    });

    test('should validate ground normals correctly', () async {
      // Test with normal upward-pointing ground
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);
      final collisionComponent = player.collision;
      final groundInfo = await collisionComponent.getGroundInfo();
      expect(groundInfo?.isGrounded, isTrue);

      // Ground normal should be pointing upward
      expect(groundInfo!.groundNormal.y, lessThan(-0.5));
    });

    test('should track surface type correctly', () async {
      player.position = Vector2(100, 130);
      physicsSystem.update(1 / 60);
      collisionSystem.update(1 / 60);

      final collisionComponent = player.collision;
      final groundInfo = await collisionComponent.getGroundInfo();
      expect(groundInfo?.isGrounded, isTrue);
      expect(groundInfo!.groundSurface.material, isNotNull);
    });

    test('should handle multiple ground detection updates per frame', () async {
      // Position player on ground
      player.position = Vector2(100, 130);

      // Multiple rapid updates
      for (int i = 0; i < 5; i++) {
        physicsSystem.update(1 / 300); // 5 small updates
        collisionSystem.update(1 / 300);
      }
      final collisionComponent = player.collision;
      final groundInfo = await collisionComponent.getGroundInfo();
      expect(groundInfo?.isGrounded, isTrue);
      expect(groundInfo, isNotNull);
    });
  });
}

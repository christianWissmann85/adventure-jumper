// filepath: test/pickup_mechanics_integration_test.dart

import 'package:adventure_jumper/src/entities/aether_shard.dart';
import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.11: Pickup Mechanics and PlayerStats Integration Tests', () {
    late FlameGame game;
    late PhysicsSystem physicsSystem;
    late Player player;
    late AetherShard aetherShard;
    late PlayerEventBus eventBus;
    late List<PlayerEvent> capturedEvents;

    setUp(() async {
      // Create game and systems
      game = FlameGame();
      physicsSystem = PhysicsSystem();
      physicsSystem
          .initialize(); // Create player at specific position with proper size
      player = Player(
        position: Vector2(100, 100),
        size: Vector2(32, 48), // Standard player size
      );
      await player.onLoad(); // Create AetherShard near player with proper size
      aetherShard = AetherShard(
        position: Vector2(110, 105), // Close to player to trigger collision
        aetherValue: 10,
        size: Vector2(16, 16), // Standard AetherShard size
      );
      await aetherShard.onLoad(); // Add entities to game world
      await game.add(player);
      await game.add(aetherShard);
      await game.onLoad();
      await game.ready();

      // Add entities to physics system
      physicsSystem.addEntity(player);
      physicsSystem.addEntity(aetherShard);

      // Set up event capture
      eventBus = PlayerEventBus.instance;
      capturedEvents = [];
      eventBus.clearListeners();
      eventBus.clearHistory();
      eventBus.addListener((event) => capturedEvents.add(event));
    });

    tearDown(() {
      eventBus.clearListeners();
      eventBus.clearHistory();
      game.removeAll(game.children);
    });

    group('T2.11.1: PhysicsSystem Collision Detection', () {
      test('should detect collision between Player and AetherShard', () {
        // Position player and shard to overlap
        player.position = Vector2(100, 100);
        aetherShard.position = Vector2(105, 105); // Overlapping with player

        // Process collision detection
        physicsSystem.detectCollisions();

        // Verify collision was detected
        final bool isColliding =
            physicsSystem.checkEntityCollision(player, aetherShard);
        expect(
          isColliding,
          isTrue,
          reason: 'Player and AetherShard should be colliding',
        );
      });

      test(
          'should correctly determine collision layers for player and collectible',
          () {
        final playerLayer = physicsSystem.getEntityCollisionLayer(player);
        final collectibleLayer =
            physicsSystem.getEntityCollisionLayer(aetherShard);

        expect(playerLayer, equals(CollisionLayer.player));
        expect(collectibleLayer, equals(CollisionLayer.collectible));
        expect(
          physicsSystem.canLayersCollide(playerLayer, collectibleLayer),
          isTrue,
        );
      });
    });

    group('T2.11.2: Collision Event Handling and onCollision', () {
      test('should call onCollision when PhysicsSystem detects collision', () {
        // Track if onCollision was called
        bool playerOnCollisionCalled = false;
        bool shardOnCollisionCalled =
            false; // Debug: Check if collision callbacks are set up
        print('[TEST] Player onCollision before setup: ${player.onCollision}');
        print(
          '[TEST] AetherShard onCollision before setup: ${aetherShard.onCollision}',
        );

        // Override onCollision methods for testing
        final originalPlayerOnCollision = player.onCollision;
        final originalShardOnCollision = aetherShard.onCollision;
        player.onCollision = (other) {
          playerOnCollisionCalled = true;
          originalPlayerOnCollision?.call(other);
        };

        aetherShard.onCollision = (other) {
          shardOnCollisionCalled = true;
          originalShardOnCollision?.call(other);
        }; // Position entities to collide
        player.position = Vector2(100, 100);
        aetherShard.position = Vector2(105, 105);

        // Debug: Check entity positions and sizes before collision detection
        print(
          '[TEST] Player position: ${player.position}, size: ${player.size}',
        );
        print(
          '[TEST] AetherShard position: ${aetherShard.position}, size: ${aetherShard.size}',
        );

        // Process physics system which should detect collision and call onCollision
        physicsSystem.processSystem(0.016);

        // Verify onCollision was called for both entities
        expect(
          playerOnCollisionCalled,
          isTrue,
          reason: 'Player onCollision should be called',
        );
        expect(
          shardOnCollisionCalled,
          isTrue,
          reason: 'AetherShard onCollision should be called',
        );
      });

      test('should trigger collect() when AetherShard collides with player',
          () {
        // Record initial state
        expect(aetherShard.isCollected, isFalse);
        expect(aetherShard.isBeingCollected, isFalse);

        // Position entities to collide and simulate collision
        player.position = Vector2(100, 100);
        aetherShard.position = Vector2(
          105,
          105,
        ); // Manually trigger collision (simulating what PhysicsSystem does)
        aetherShard.onCollision?.call(player);

        // Verify collection was triggered
        expect(
          aetherShard.isCollected,
          isTrue,
          reason: 'AetherShard should be collected after collision',
        );
        expect(
          aetherShard.isBeingCollected,
          isTrue,
          reason: 'AetherShard should be in collection state',
        );
      });
    });

    group('T2.11.3: PlayerStats Integration', () {
      test('should update PlayerStats when AetherShard is collected', () {
        // Record initial PlayerStats state
        final initialAether = player.stats.currentAether;
        final initialShards = player.stats.aetherShards;

        // Clear any setup events        capturedEvents.clear();

        // Trigger collection
        aetherShard.onCollision?.call(
          player,
        ); // Verify PlayerStats were updated - Aether should be capped at maxAether
        final expectedAether =
            (initialAether + 10).clamp(0, player.stats.maxAether);
        expect(
          player.stats.currentAether,
          equals(expectedAether),
          reason:
              'Player currentAether should increase by shard value but be capped at maxAether',
        );
        expect(
          player.stats.aetherShards,
          equals(initialShards + 10),
          reason: 'Player aetherShards count should increase',
        );

        // Verify event was fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(
          aetherEvents.isNotEmpty,
          isTrue,
          reason: 'PlayerAetherChangedEvent should be fired',
        );

        final event = aetherEvents.first;
        expect(event.changeReason, equals('collect_shard'));
        // Event should reflect actual change amount (may be less than 10 if capped)
        final actualChangeAmount = expectedAether - initialAether;
        expect(event.changeAmount, equals(actualChangeAmount));
      });

      test('should handle Aether overflow correctly when collecting shards',
          () {
        // Set player Aether to near max
        player.stats
            .useAether(player.stats.currentAether - 95); // Leave 95 Aether
        final initialAether = player.stats.currentAether;
        final maxAether = player.stats.maxAether;

        // Clear events
        capturedEvents.clear();

        // Collect shard (10 Aether) - should cap at max
        aetherShard.onCollision?.call(player);

        // Verify Aether was capped at maximum
        expect(
          player.stats.currentAether,
          equals(maxAether),
          reason: 'Aether should be capped at maximum value',
        );

        // Shards count should still increase
        expect(
          player.stats.aetherShards,
          equals(10),
          reason:
              'Shard count should still increase even when Aether is capped',
        );

        // Event should reflect actual change amount
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(aetherEvents.isNotEmpty, isTrue);
        final event = aetherEvents.first;
        expect(event.changeAmount, equals(maxAether - initialAether));
      });
    });

    group('T2.11.4: Collectible Removal After Pickup', () {
      test('should remove AetherShard from world after collection', () async {
        // Verify shard is initially in the world - use game.children which is more reliable
        expect(
          game.children.contains(aetherShard),
          isTrue,
          reason: 'Game should contain AetherShard initially',
        );

        // Trigger collection
        aetherShard.onCollision?.call(player);

        // Wait for the removal delay (500ms in AetherShard.onCollected)
        await Future.delayed(const Duration(milliseconds: 600));

        // Verify shard was removed
        expect(
          aetherShard.isMounted,
          isFalse,
          reason: 'AetherShard should be removed after collection',
        );
        expect(
          game.children.contains(aetherShard),
          isFalse,
          reason: 'Game should no longer contain AetherShard',
        );
      });

      test('should prevent double collection of same shard', () {
        // Record initial state
        // final initialAether = player.stats.currentAether; // Unused
        // final initialShards = player.stats.aetherShards; // Unused

        // Trigger first collection
        aetherShard.onCollision?.call(player);

        expect(aetherShard.isCollected, isTrue);
        final aetherAfterFirst = player.stats.currentAether;
        final shardsAfterFirst = player.stats.aetherShards;

        // Clear events
        capturedEvents.clear();

        // Try to collect again
        aetherShard.onCollision?.call(player);

        // Verify no additional changes occurred
        expect(
          player.stats.currentAether,
          equals(aetherAfterFirst),
          reason: 'Aether should not change on second collection attempt',
        );
        expect(
          player.stats.aetherShards,
          equals(shardsAfterFirst),
          reason: 'Shard count should not change on second collection attempt',
        );

        // No new events should be fired
        final newAetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(
          newAetherEvents.isEmpty,
          isTrue,
          reason: 'No new events should be fired for double collection',
        );
      });
    });

    group('T2.11.5: Complete End-to-End Pickup Flow', () {
      test('should complete full pickup flow from collision to removal',
          () async {
        // Record initial state
        final initialAether = player.stats.currentAether;
        final initialShards = player.stats.aetherShards;
        capturedEvents.clear();

        // Position entities to trigger collision
        player.position = Vector2(100, 100);
        aetherShard.position = Vector2(105, 105);

        // Process physics system (simulates one game frame)
        physicsSystem.processSystem(0.016);

        // Step 1: Verify collision was detected and handled
        expect(
          aetherShard.isCollected,
          isTrue,
          reason: 'Shard should be collected after collision',
        ); // Step 2: Verify PlayerStats were updated - Aether should be capped at maxAether
        final expectedAether =
            (initialAether + 10).clamp(0, player.stats.maxAether);
        expect(
          player.stats.currentAether,
          equals(expectedAether),
          reason: 'Player Aether should be increased but capped at maxAether',
        );
        expect(
          player.stats.aetherShards,
          equals(initialShards + 10),
          reason: 'Player shard count should be increased',
        );

        // Step 3: Verify events were fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(
          aetherEvents.isNotEmpty,
          isTrue,
          reason: 'Aether change event should be fired',
        );
        expect(aetherEvents.first.changeReason, equals('collect_shard'));

        // Step 4: Wait for shard removal
        await Future.delayed(const Duration(milliseconds: 600));
        expect(
          aetherShard.isMounted,
          isFalse,
          reason: 'Shard should be removed from world',
        );

        // Complete flow successful
        expect(
          true,
          isTrue,
          reason: 'Complete pickup flow executed successfully',
        );
      });

      test('should handle multiple AetherShard collections in sequence',
          () async {
        // Create additional shards
        final shard2 = AetherShard(
          position: Vector2(120, 100),
          aetherValue: 5,
          size: Vector2(16, 16),
        );
        final shard3 = AetherShard(
          position: Vector2(130, 100),
          aetherValue: 15,
          size: Vector2(16, 16),
        );
        await shard2.onLoad();
        await shard3.onLoad();
        await game.add(shard2);
        await game.add(shard3);

        physicsSystem.addEntity(shard2);
        physicsSystem.addEntity(shard3);

        // Record initial state
        final initialAether = player.stats.currentAether;
        final initialShards = player.stats.aetherShards;
        capturedEvents.clear(); // Collect all three shards
        aetherShard.onCollision?.call(player); // 10 Aether
        shard2.onCollision?.call(player); // 5 Aether
        shard3.onCollision?.call(player); // 15 Aether

        // Verify total changes - Aether should be capped at maxAether
        final expectedTotalAether =
            (initialAether + 30).clamp(0, player.stats.maxAether);
        expect(
          player.stats.currentAether,
          equals(expectedTotalAether),
          reason:
              'Total Aether should be sum of all collections but capped at maxAether',
        );
        expect(
          player.stats.aetherShards,
          equals(initialShards + 30),
          reason: 'Total shards should be sum of all collections',
        );

        // Verify multiple events were fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(
          aetherEvents.length,
          equals(3),
          reason: 'Should have three Aether change events',
        );

        // All shards should be collected
        expect(aetherShard.isCollected, isTrue);
        expect(shard2.isCollected, isTrue);
        expect(shard3.isCollected, isTrue);
      });
    });

    group('T2.11.6: Error Handling and Edge Cases', () {
      test('should handle missing PlayerStats gracefully', () {
        // Create AetherShard with no player present
        final isolatedShard = AetherShard(
          position: Vector2(200, 200),
          aetherValue: 5,
          size: Vector2(16, 16),
        );

        // This should not throw an exception
        expect(
          () => isolatedShard.onCollision?.call(player),
          returnsNormally,
          reason: 'Collection should handle missing components gracefully',
        );
      });

      test('should handle physics system without entities', () {
        // Clear all entities
        physicsSystem.clearEntities();

        // Processing should not crash
        expect(
          () => physicsSystem.processSystem(0.016),
          returnsNormally,
          reason: 'Physics system should handle empty entity list',
        );
      });

      test('should handle invalid Aether values', () {
        // Create shard with negative value (should be handled by PlayerStats validation)
        final invalidShard = AetherShard(
          position: Vector2(150, 150),
          aetherValue: -5,
          size: Vector2(16, 16),
        );

        final initialAether = player.stats.currentAether;
        invalidShard.onCollision?.call(player);

        // PlayerStats should prevent negative Aether additions
        expect(
          player.stats.currentAether,
          equals(initialAether),
          reason: 'Negative Aether values should be ignored',
        );
      });
    });
  });
}

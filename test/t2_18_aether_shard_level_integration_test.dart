// filepath: test/t2_18_aether_shard_level_integration_test.dart

import 'package:adventure_jumper/src/entities/aether_shard.dart';
import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// T2.18: Integrate AetherShard spawning into level system
///
/// Comprehensive AetherShard integration testing covering:
/// - T2.18.1: Add AetherShard entity spawning to LevelLoader
/// - T2.18.2: Integrate AetherShard collision detection with Player
/// - T2.18.3: Test pickup mechanics in live environment
/// - T2.18.4: Verify PlayerStats integration works in real gameplay
///
/// This test enhances existing level test files to include proper AetherShard
/// integration testing covering spawning, interaction, picking up, and applying
/// aether to the character in a complete live gameplay scenario.

class FakeAssetBundle extends AssetBundle {
  final Map<String, String> _assets = {};

  void addAsset(String key, String content) {
    _assets[key] = content;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final String content = await loadString(key);
    final Uint8List bytes = Uint8List.fromList(content.codeUnits);
    return ByteData.sublistView(bytes);
  }

  @override
  void evict(String key) {}

  @override
  void clear() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T2.18: AetherShard Level Integration Tests', () {
    late LevelLoader levelLoader;
    late FakeAssetBundle fakeAssetBundle;
    late FlameGame game;
    late PhysicsSystem physicsSystem;
    late Player player;
    late PlayerEventBus eventBus;
    late List<PlayerEvent> capturedEvents;
    setUp(() async {
      // Create game and systems
      game = FlameGame();
      physicsSystem = PhysicsSystem();
      physicsSystem.initialize();

      // Create player for integration testing (but don't load it yet)
      player = Player(position: Vector2(100, 800));

      // Set up level loader
      fakeAssetBundle = FakeAssetBundle();
      levelLoader = LevelLoader(assetBundle: fakeAssetBundle);
      levelLoader.enableCaching = false;

      // Set up event capture system
      eventBus = PlayerEventBus.instance;
      capturedEvents = [];
      eventBus.clearListeners();
      eventBus.clearHistory();
      eventBus.addListener((event) => capturedEvents.add(event));

      // Add test level JSON with AetherShard definitions
      _addTestLevelJson(fakeAssetBundle);
    });

    tearDown(() {
      eventBus.clearListeners();
      eventBus.clearHistory();
      game.removeAll(game.children);
    });
    group('T2.18.1: AetherShard Entity Spawning to LevelLoader', () {
      testWidgets('should spawn AetherShards from level spawn definitions',
          (WidgetTester tester) async {
        // Load level with AetherShard spawn definitions
        final Level level = await levelLoader.loadLevel('test_aether_level');

        // Verify level loaded with entity spawn definitions
        expect(level.entitySpawnDefinitions.isNotEmpty, isTrue);

        // Count AetherShard spawn definitions
        final aetherShardDefs = level.entitySpawnDefinitions.values
            .where((def) => def.entityType == 'aether_shard')
            .toList();
        expect(
          aetherShardDefs.length,
          equals(6),
          reason: 'Should have 6 AetherShard spawn definitions',
        );

        // Add level to game world (simplified without full game setup)
        await game.add(level);
        await tester.pump();

        // Wait for spawning to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify AetherShards were spawned in the level
        final spawnedShards = level.children.whereType<AetherShard>().toList();
        expect(
          spawnedShards.length,
          equals(6),
          reason: 'Level should contain 6 spawned AetherShards',
        );

        // Verify each shard has correct properties from spawn definition
        for (final shard in spawnedShards) {
          expect(shard.aetherValue, greaterThan(0));
          expect(shard.position.x, greaterThanOrEqualTo(0));
          expect(shard.position.y, greaterThanOrEqualTo(0));
        }
      });

      testWidgets(
          'should spawn AetherShards with correct values from definitions',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();

        // Test that different shard types have correct values
        final enhancedShards =
            spawnedShards.where((shard) => shard.aetherValue >= 10).toList();
        final standardShards =
            spawnedShards.where((shard) => shard.aetherValue == 5).toList();

        expect(
          enhancedShards.length,
          equals(3),
          reason: 'Should have 3 enhanced shards (10+ aether)',
        );
        expect(
          standardShards.length,
          equals(3),
          reason: 'Should have 3 standard shards (5 aether)',
        );

        // Verify specific shard values match spawn definitions
        final shard4 = spawnedShards.firstWhere(
          (shard) => shard.position.x == 1025,
          orElse: () =>
              throw Exception('Shard 4 not found at expected position'),
        );
        expect(shard4.aetherValue, equals(10));

        final shard6 = spawnedShards.firstWhere(
          (shard) => shard.position.x == 1475,
          orElse: () =>
              throw Exception('Shard 6 not found at expected position'),
        );
        expect(shard6.aetherValue, equals(15));
      });

      testWidgets('should position AetherShards correctly in level space',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();

        // Verify shards are positioned according to spawn definitions
        final expectedPositions = [
          Vector2(200, 600), // aether_shard_1
          Vector2(525, 450), // aether_shard_2
          Vector2(775, 550), // aether_shard_3
          Vector2(1025, 500), // aether_shard_4
          Vector2(1250, 350), // aether_shard_5
          Vector2(1475, 250), // aether_shard_6
        ];

        expect(spawnedShards.length, equals(expectedPositions.length));

        // Check that each expected position has a shard
        for (final expectedPos in expectedPositions) {
          final shardAtPosition = spawnedShards.any(
            (shard) => (shard.position - expectedPos).length < 5,
          ); // Allow small tolerance
          expect(
            shardAtPosition,
            isTrue,
            reason: 'Should have shard at position $expectedPos',
          );
        }
      });
    });

    group('T2.18.2: AetherShard Collision Detection with Player', () {
      testWidgets(
          'should detect collision between player and level-spawned AetherShards',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        expect(spawnedShards.isNotEmpty, isTrue);

        // Add entities to physics system
        physicsSystem.addEntity(player);
        for (final shard in spawnedShards) {
          physicsSystem.addEntity(shard);
        }

        // Position player near first shard
        final firstShard = spawnedShards.first;
        player.position =
            Vector2(firstShard.position.x + 5, firstShard.position.y);

        // Process collision detection
        physicsSystem.detectCollisions();

        // Verify collision was detected
        final isColliding =
            physicsSystem.checkEntityCollision(player, firstShard);
        expect(
          isColliding,
          isTrue,
          reason: 'Player should collide with nearby AetherShard',
        );

        // Verify collision layers are correct
        final playerLayer = physicsSystem.getEntityCollisionLayer(player);
        final shardLayer = physicsSystem.getEntityCollisionLayer(firstShard);
        expect(playerLayer, equals(CollisionLayer.player));
        expect(shardLayer, equals(CollisionLayer.collectible));
        expect(physicsSystem.canLayersCollide(playerLayer, shardLayer), isTrue);
      });

      testWidgets(
          'should trigger onCollision when player contacts level AetherShards',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final testShard = spawnedShards.first;

        // Track collision callback
        bool onCollisionCalled = false;
        final originalOnCollision = testShard.onCollision;
        testShard.onCollision = (other) {
          onCollisionCalled = true;
          originalOnCollision?.call(other);
        };

        // Position player to collide with shard
        player.position = Vector2(testShard.position.x, testShard.position.y);

        physicsSystem.addEntity(player);
        physicsSystem.addEntity(testShard);

        // Process physics to trigger collision
        physicsSystem.processSystem(0.016);

        expect(
          onCollisionCalled,
          isTrue,
          reason: 'onCollision should be called when player contacts shard',
        );
      });
    });

    group('T2.18.3: Pickup Mechanics in Live Environment', () {
      testWidgets(
          'should collect level-spawned AetherShards and update PlayerStats',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final testShard =
            spawnedShards.firstWhere((shard) => shard.aetherValue == 5);

        // Record initial player stats
        final initialAether = player.stats.currentAether;
        final initialShards = player.stats.aetherShards;
        capturedEvents.clear();

        // Simulate collision and collection
        testShard.onCollision?.call(player);

        // Verify collection occurred
        expect(testShard.isCollected, isTrue);
        expect(testShard.isBeingCollected, isTrue);

        // Verify PlayerStats were updated
        final expectedAether =
            (initialAether + 5).clamp(0, player.stats.maxAether);
        expect(player.stats.currentAether, equals(expectedAether));
        expect(player.stats.aetherShards, equals(initialShards + 5));

        // Verify event was fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(aetherEvents.isNotEmpty, isTrue);
        expect(aetherEvents.first.changeReason, equals('collect_shard'));
      });

      testWidgets('should collect multiple level AetherShards in sequence',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();

        // Take first 3 shards for multi-collection test
        final testShards = spawnedShards.take(3).toList();
        final initialAether = player.stats.currentAether;
        final initialShardCount = player.stats.aetherShards;

        capturedEvents.clear();

        // Collect all test shards
        int totalExpectedAether = 0;
        for (final shard in testShards) {
          totalExpectedAether += shard.aetherValue;
          shard.onCollision?.call(player);
          expect(shard.isCollected, isTrue);
        }

        // Verify cumulative stats
        final expectedFinalAether = (initialAether + totalExpectedAether)
            .clamp(0, player.stats.maxAether);
        expect(player.stats.currentAether, equals(expectedFinalAether));
        expect(
          player.stats.aetherShards,
          equals(initialShardCount + totalExpectedAether),
        );

        // Verify multiple events were fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(aetherEvents.length, equals(testShards.length));
      });

      testWidgets(
          'should handle aether overflow when collecting high-value shards',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        // Get the highest value shard (15 aether)
        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final highValueShard = spawnedShards.firstWhere(
          (shard) => shard.aetherValue == 15,
        );

        // Set player aether to near max to test overflow
        player.stats
            .useAether(player.stats.currentAether - 95); // Leave 95 aether
        final initialAether = player.stats.currentAether;
        final maxAether = player.stats.maxAether;

        capturedEvents.clear();

        // Collect high-value shard
        highValueShard.onCollision?.call(player);

        // Verify aether was capped at maximum
        expect(player.stats.currentAether, equals(maxAether));

        // Shard count should still increase
        expect(player.stats.aetherShards, equals(15));

        // Event should reflect actual change amount
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(aetherEvents.isNotEmpty, isTrue);
        final actualChange = maxAether - initialAether;
        expect(aetherEvents.first.changeAmount, equals(actualChange));
      });

      testWidgets('should remove collected AetherShards from level',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final initialShardCount = spawnedShards.length;
        final testShard = spawnedShards.first;

        // Verify shard is initially in level
        expect(level.children.contains(testShard), isTrue);

        // Collect the shard
        testShard.onCollision?.call(player);

        // Wait for removal delay
        await Future.delayed(const Duration(milliseconds: 600));

        // Verify shard was removed from level
        expect(testShard.isMounted, isFalse);
        expect(level.children.contains(testShard), isFalse);

        // Verify remaining shard count decreased
        final remainingShards = level.children.whereType<AetherShard>().length;
        expect(remainingShards, equals(initialShardCount - 1));
      });
    });

    group('T2.18.4: PlayerStats Integration in Real Gameplay', () {
      testWidgets(
          'should integrate AetherShard collection with player progression',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();

        // Simulate a progression scenario
        // 1. Player starts with some experience
        player.stats.gainExperience(50);

        // 2. Collect some shards to build up aether and shard count
        final shardsToCollect = spawnedShards.take(4).toList();
        int totalAetherValue = 0;

        for (final shard in shardsToCollect) {
          totalAetherValue += shard.aetherValue;
          shard.onCollision?.call(player);
        }

        // 3. Verify progression integration
        expect(player.stats.aetherShards, equals(totalAetherValue));
        expect(player.stats.experience, equals(50));

        // 4. Gain more experience to level up
        player.stats.gainExperience(50); // Should trigger level up
        expect(player.stats.level, equals(2));

        // 5. Verify level up improved stats while maintaining shard collection
        expect(player.stats.maxHealth, equals(110));
        expect(player.stats.maxAether, equals(105));
        expect(player.stats.aetherShards, equals(totalAetherValue));
      });

      testWidgets('should handle ability unlocking through shard collection',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        // Progress player to level 2 for ability requirements
        player.stats.gainExperience(100);
        expect(player.stats.level, equals(2));
        expect(player.stats.canDoubleJump, isFalse); // No shards yet

        // Collect enough shards for double jump ability (requires 10 shards + level 2)
        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final targetShards =
            spawnedShards.take(2).toList(); // Should give 10+ shards total

        for (final shard in targetShards) {
          shard.onCollision?.call(player);
        }

        // Should have collected enough shards to unlock double jump
        expect(player.stats.aetherShards, greaterThanOrEqualTo(10));
        expect(player.stats.canDoubleJump, isTrue);
      });

      testWidgets(
          'should maintain stat consistency during live gameplay simulation',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();

        // Simulate complex gameplay scenario
        // 1. Take some damage
        player.takeDamage(30);
        expect(player.stats.currentHealth, equals(70));

        // 2. Use some energy for abilities
        player.stats.useEnergy(25);
        expect(player.stats.currentEnergy, equals(75));

        // 3. Use some aether for special abilities
        player.stats.useAether(20);
        expect(player.stats.currentAether, equals(80));

        // 4. Collect shards to restore aether
        final restorationShards = spawnedShards.take(3).toList();
        int collectedAether = 0;
        for (final shard in restorationShards) {
          collectedAether += shard.aetherValue;
          shard.onCollision?.call(player);
        }

        // 5. Verify final consistent state
        final expectedAether =
            (80 + collectedAether).clamp(0, player.stats.maxAether);
        expect(player.stats.currentAether, equals(expectedAether));
        expect(player.stats.currentHealth, equals(70)); // Should be unchanged
        expect(player.stats.currentEnergy, equals(75)); // Should be unchanged
        expect(player.stats.aetherShards, equals(collectedAether));

        // All percentages should be valid
        expect(player.stats.healthPercentage, inInclusiveRange(0.0, 1.0));
        expect(player.stats.energyPercentage, inInclusiveRange(0.0, 1.0));
        expect(player.stats.aetherPercentage, inInclusiveRange(0.0, 1.0));
      });

      testWidgets('should validate complete level clearing scenario',
          (WidgetTester tester) async {
        final Level level = await levelLoader.loadLevel('test_aether_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        final totalShards = spawnedShards.length;
        expect(totalShards, equals(6));

        // Calculate total aether value in level
        int totalAetherValue = 0;
        for (final shard in spawnedShards) {
          totalAetherValue += shard.aetherValue;
        }
        expect(totalAetherValue, equals(45)); // 5+5+5+10+5+15 = 45

        // Collect all shards in the level
        capturedEvents.clear();
        for (final shard in spawnedShards) {
          shard.onCollision?.call(player);
        }

        // Verify complete collection
        expect(player.stats.aetherShards, equals(45));
        final expectedFinalAether = (100 + 45).clamp(0, player.stats.maxAether);
        expect(player.stats.currentAether, equals(expectedFinalAether));

        // Verify all collection events were fired
        final aetherEvents =
            capturedEvents.whereType<PlayerAetherChangedEvent>();
        expect(aetherEvents.length, equals(6));

        // Verify all shards were marked as collected
        for (final shard in spawnedShards) {
          expect(shard.isCollected, isTrue);
        }

        // After removal delay, level should have no AetherShards
        await Future.delayed(const Duration(milliseconds: 700));
        final remainingShards = level.children.whereType<AetherShard>().length;
        expect(remainingShards, equals(0));
      });
    });

    group('T2.18: Error Handling and Edge Cases', () {
      testWidgets(
          'should handle level with no AetherShard definitions gracefully',
          (WidgetTester tester) async {
        // Add level with no AetherShards
        _addEmptyLevelJson(fakeAssetBundle);

        final Level level = await levelLoader.loadLevel('empty_level');
        await game.add(level);
        await game.onLoad();
        await game.ready();

        await Future.delayed(const Duration(milliseconds: 100));

        final spawnedShards = level.children.whereType<AetherShard>().toList();
        expect(spawnedShards.isEmpty, isTrue);
        expect(level.collectibles.isEmpty, isTrue);
      });

      testWidgets('should handle malformed AetherShard definitions gracefully',
          (WidgetTester tester) async {
        // Add level with malformed shard definitions
        _addMalformedLevelJson(fakeAssetBundle);

        // Should not throw during loading
        expect(
          () async {
            final Level level = await levelLoader.loadLevel('malformed_level');
            await game.add(level);
            await game.onLoad();
            await game.ready();
          },
          returnsNormally,
        );
      });

      testWidgets('should handle physics system without entities',
          (WidgetTester tester) async {
        // Clear all entities from physics system
        physicsSystem.clearEntities();

        // Should not crash during processing
        expect(() => physicsSystem.processSystem(0.016), returnsNormally);
      });
    });
  });
}

/// Add test level JSON with AetherShard spawn definitions
void _addTestLevelJson(FakeAssetBundle bundle) {
  const String testLevelJson = '''
{
  "metadata": {
    "version": "2.0",
    "name": "Test Aether Level",
    "author": "Test",
    "description": "Level for testing AetherShard integration"
  },
  "properties": {
    "id": "test_aether_level",
    "name": "Test Aether Level",
    "width": 1600,
    "height": 900,
    "gravity": 1200
  },
  "bounds": {
    "left": 0,
    "right": 1600,
    "top": 0,
    "bottom": 900
  },
  "cameraBounds": {
    "left": -50,
    "right": 1650,
    "top": -50,
    "bottom": 950
  },
  "geometry": {
    "platforms": [
      {
        "id": "main_ground",
        "type": "solid",
        "x": 0,
        "y": 800,
        "width": 1600,
        "height": 100,
        "properties": {}
      }
    ],
    "walls": [],
    "triggerZones": []
  },
  "spawnPoints": {
    "player_start": {
      "entityType": "player",
      "x": 100,
      "y": 750,
      "properties": {}
    }
  },
  "entitySpawnDefinitions": {
    "aether_shard_1": {
      "entityType": "aether_shard",
      "entitySubtype": "standard",
      "x": 200,
      "y": 600,
      "properties": {
        "value": 5
      }
    },
    "aether_shard_2": {
      "entityType": "aether_shard",
      "entitySubtype": "standard",
      "x": 525,
      "y": 450,
      "properties": {
        "value": 5
      }
    },
    "aether_shard_3": {
      "entityType": "aether_shard",
      "entitySubtype": "standard",
      "x": 775,
      "y": 550,
      "properties": {
        "value": 5
      }
    },
    "aether_shard_4": {
      "entityType": "aether_shard",
      "entitySubtype": "enhanced",
      "x": 1025,
      "y": 500,
      "properties": {
        "value": 10
      }
    },
    "aether_shard_5": {
      "entityType": "aether_shard",
      "entitySubtype": "standard",
      "x": 1250,
      "y": 350,
      "properties": {
        "value": 5
      }
    },
    "aether_shard_6": {
      "entityType": "aether_shard",
      "entitySubtype": "enhanced",
      "x": 1475,
      "y": 250,
      "properties": {
        "value": 15
      }
    }
  }
}
''';

  bundle.addAsset('assets/levels/test_aether_level.json', testLevelJson);
}

/// Add empty level JSON for edge case testing
void _addEmptyLevelJson(FakeAssetBundle bundle) {
  const String emptyLevelJson = '''
{
  "metadata": {
    "version": "2.0",
    "name": "Empty Level",
    "author": "Test"
  },
  "properties": {
    "id": "empty_level",
    "name": "Empty Level",
    "width": 800,
    "height": 600,
    "gravity": 1200
  },
  "bounds": {
    "left": 0,
    "right": 800,
    "top": 0,
    "bottom": 600
  },
  "cameraBounds": {
    "left": 0,
    "right": 800,
    "top": 0,
    "bottom": 600
  },
  "geometry": {
    "platforms": [],
    "walls": [],
    "triggerZones": []
  },
  "spawnPoints": {
    "player_start": {
      "entityType": "player",
      "x": 100,
      "y": 500,
      "properties": {}
    }
  },
  "entitySpawnDefinitions": {}
}
''';

  bundle.addAsset('assets/levels/empty_level.json', emptyLevelJson);
}

/// Add malformed level JSON for error handling testing
void _addMalformedLevelJson(FakeAssetBundle bundle) {
  const String malformedLevelJson = '''
{
  "metadata": {
    "version": "2.0",
    "name": "Malformed Level",
    "author": "Test"
  },
  "properties": {
    "id": "malformed_level",
    "name": "Malformed Level",
    "width": 800,
    "height": 600,
    "gravity": 1200
  },
  "bounds": {
    "left": 0,
    "right": 800,
    "top": 0,
    "bottom": 600
  },
  "cameraBounds": {
    "left": 0,
    "right": 800,
    "top": 0,
    "bottom": 600
  },
  "geometry": {
    "platforms": [],
    "walls": [],
    "triggerZones": []
  },
  "spawnPoints": {
    "player_start": {
      "entityType": "player",
      "x": 100,
      "y": 500,
      "properties": {}
    }
  },
  "entitySpawnDefinitions": {
    "bad_shard": {
      "entityType": "aether_shard",
      "x": "invalid",
      "y": null,
      "properties": {
        "value": "not_a_number"
      }
    }
  }
}
''';

  bundle.addAsset('assets/levels/malformed_level.json', malformedLevelJson);
}

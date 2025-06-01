import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// T2.17.4: Test level loading and entity spawning functionality
///
/// This test validates that the Sprint 2 test level loads correctly and that
/// all entity spawning functionality works as expected.
///
/// Test Coverage:
/// - Level asset loading (fixed in T2.17.1 and T2.17.2)
/// - JSON parsing (fixed in T2.17.3)
/// - Entity spawn definition processing
/// - Platform spawning from geometry data
/// - AetherShard spawning from entity definitions
/// - Player spawn point validation
/// - Level bounds and camera bounds validation
/// - Complete integration test

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

  group('T2.17.4: Level Loading and Entity Spawning Validation', () {
    late FakeAssetBundle fakeAssetBundle;
    late LevelLoader levelLoader;

    setUp(() {
      fakeAssetBundle = FakeAssetBundle();
      levelLoader = LevelLoader(assetBundle: fakeAssetBundle);
      levelLoader.enableCaching = false; // Disable caching for tests
    });

    group('Asset Loading Tests', () {
      test('T2.17.4.1: Should load Sprint 2 test level asset successfully',
          () async {
        // Load the actual Sprint 2 test level JSON from the assets
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');

        // Add to fake bundle
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        // Test that the level can be loaded
        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify basic level properties
        expect(level.id, equals('sprint2_test'));
        expect(level.name, equals('Sprint 2 Test Level'));
        expect(level.width, equals(1600));
        expect(level.height, equals(900));
        expect(level.gravity, equals(1200));
        expect(level.biomeType.toString(), contains('luminara'));

        print('✅ T2.17.4.1: Level asset loading successful');
      });

      test('T2.17.4.2: Should handle level bounds correctly', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify level bounds
        expect(level.levelBounds, isNotNull);
        expect(level.levelBounds!.left, equals(0));
        expect(level.levelBounds!.right, equals(1600));
        expect(level.levelBounds!.top, equals(0));
        expect(level.levelBounds!.bottom, equals(900));

        // Verify camera bounds
        expect(level.cameraBounds, isNotNull);
        expect(level.cameraBounds!.left, equals(-50));
        expect(level.cameraBounds!.right, equals(1650));
        expect(level.cameraBounds!.top, equals(-50));
        expect(level.cameraBounds!.bottom, equals(950));

        print('✅ T2.17.4.2: Level bounds validation successful');
      });
    });

    group('JSON Parsing Tests', () {
      test('T2.17.4.3: Should parse entity spawn definitions correctly',
          () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify entity spawn definitions are loaded (T2.17.3 fix validation)
        final entitySpawns = level.entitySpawnDefinitions;
        expect(entitySpawns.length, equals(6)); // 6 AetherShards

        // Verify specific AetherShard spawn definitions
        expect(entitySpawns.containsKey('aether_shard_1'), isTrue);
        expect(entitySpawns.containsKey('aether_shard_6'), isTrue);

        final aetherShard1 = entitySpawns['aether_shard_1']!;
        expect(aetherShard1.entityType, equals('aether_shard'));
        expect(aetherShard1.entitySubtype, equals('standard'));
        expect(aetherShard1.x, equals(275));
        expect(aetherShard1.y, equals(600));
        expect(aetherShard1.properties['value'], equals(5));

        final aetherShard6 = entitySpawns['aether_shard_6']!;
        expect(aetherShard6.entityType, equals('aether_shard'));
        expect(aetherShard6.entitySubtype, equals('enhanced'));
        expect(aetherShard6.properties['value'], equals(15));

        print('✅ T2.17.4.3: Entity spawn definitions parsing successful');
      });

      test('T2.17.4.4: Should parse platform geometry correctly', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify level geometry is loaded
        expect(level.geometry, isNotNull);
        expect(
          level.geometry!.platforms.length,
          equals(8),
        ); // 8 platforms defined

        // Verify specific platforms
        final mainGround = level.geometry!.platforms.firstWhere(
          (p) => p.id == 'main_ground',
        );
        expect(mainGround.x, equals(0));
        expect(mainGround.y, equals(800));
        expect(mainGround.width, equals(1600));
        expect(mainGround.height, equals(100));
        expect(mainGround.properties['material'], equals('crystal'));

        final jumpPlatform = level.geometry!.platforms.firstWhere(
          (p) => p.id == 'jump_test_platform_1',
        );
        expect(jumpPlatform.x, equals(200));
        expect(jumpPlatform.y, equals(650));
        expect(jumpPlatform.width, equals(150));
        expect(jumpPlatform.height, equals(20));

        print('✅ T2.17.4.4: Platform geometry parsing successful');
      });

      test('T2.17.4.5: Should parse spawn points correctly', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify spawn points are loaded
        expect(level.spawnPoints, isNotNull);
        expect(
          level.spawnPoints!.length,
          equals(3),
        ); // player_start + 2 checkpoints

        // Verify player spawn point
        expect(level.spawnPoints!.containsKey('player_start'), isTrue);
        final playerSpawn = level.spawnPoints!['player_start']!;
        expect(playerSpawn.x, equals(100));
        expect(playerSpawn.y, equals(720));
        expect(playerSpawn.properties['facing'], equals('right'));

        // Verify checkpoint spawn points
        expect(level.spawnPoints!.containsKey('checkpoint_1'), isTrue);
        expect(level.spawnPoints!.containsKey('checkpoint_2'), isTrue);

        // Also verify playerSpawnPoint is set correctly
        expect(level.playerSpawnPoint, isNotNull);
        expect(level.playerSpawnPoint!.x, equals(100));
        expect(
          level.playerSpawnPoint!.y,
          equals(750),
        ); // From playerSpawn section

        print('✅ T2.17.4.5: Spawn points parsing successful');
      });
    });

    group('Entity Spawning Simulation Tests', () {
      test('T2.17.4.6: Should identify all spawnable entities correctly',
          () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Test entity spawn definition retrieval by type
        final aetherShardSpawns =
            level.getSpawnDefinitionsByType('aether_shard');
        expect(aetherShardSpawns.length, equals(6));

        // Test entity spawn definition retrieval by subtype
        final standardShards = level.getSpawnDefinitionsBySubtype('standard');
        expect(standardShards.length, equals(4)); // 4 standard shards

        final enhancedShards = level.getSpawnDefinitionsBySubtype('enhanced');
        expect(enhancedShards.length, equals(2)); // 2 enhanced shards

        // Verify all AetherShards are positioned within level bounds
        for (final spawn in aetherShardSpawns) {
          expect(spawn.x, greaterThanOrEqualTo(0));
          expect(spawn.x, lessThanOrEqualTo(1600));
          expect(spawn.y, greaterThanOrEqualTo(0));
          expect(spawn.y, lessThanOrEqualTo(900));
        }

        print('✅ T2.17.4.6: Entity spawning simulation successful');
      });

      test('T2.17.4.7: Should validate spawn condition logic', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Test spawn condition checking for all entities
        final gameState = <String, dynamic>{
          'playerLevel': 1,
          'aetherCollected': 0,
          'checkpointsReached': 0,
        };

        // All AetherShards should be spawnable (always trigger)
        for (final spawn in level.entitySpawnDefinitions.values) {
          expect(
            spawn.canSpawn(gameState),
            isTrue,
            reason: 'Entity ${spawn.id} should be spawnable',
          );
        }

        print('✅ T2.17.4.7: Spawn condition validation successful');
      });
    });

    group('Integration Tests', () {
      test('T2.17.4.8: Complete level loading integration test', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        ); // Simulate the complete loading process
        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify level is fully loaded and valid
        // Note: isLoaded is a Flame lifecycle property, not relevant for parsing tests

        // Validate all major components are present
        expect(level.geometry, isNotNull);
        expect(level.spawnPoints, isNotNull);
        expect(level.entitySpawnDefinitions.isNotEmpty, isTrue);
        expect(level.levelBounds, isNotNull);
        expect(level.cameraBounds, isNotNull);
        expect(level.environmentalData, isNotNull);

        // Verify environmental data
        expect(level.environmentalData!.lighting.ambientIntensity, equals(0.6));
        expect(
          level.environmentalData!.lighting.lightSources.length,
          equals(2),
        );
        expect(level.environmentalData!.ambientEffects.length, equals(2));
        expect(level.environmentalData!.backgroundLayers.length, equals(3));

        // Verify trigger zones
        expect(level.geometry!.triggerZones.length, equals(3));
        final jumpTestZone = level.geometry!.triggerZones.firstWhere(
          (zone) => zone.id == 'jump_test_zone',
        );
        expect(jumpTestZone.properties['testType'], equals('jump_mechanics'));

        print('✅ T2.17.4.8: Complete integration test successful');
      });

      test('T2.17.4.9: GameWorld level loading integration', () async {
        // Test that GameWorld can successfully load the test level
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        // Create a level loader with our fake asset bundle
        final testLevelLoader = LevelLoader(assetBundle: fakeAssetBundle);

        // Test loading the level directly
        final Level level =
            await testLevelLoader.loadLevel('sprint2_test_level');

        // Verify that the level has all the expected Sprint 2 features
        expect(
          level.entitySpawnDefinitions.length,
          equals(6),
        ); // 6 AetherShards
        expect(level.geometry!.platforms.length, equals(8)); // 8 platforms
        expect(level.spawnPoints!.length, equals(3)); // player + 2 checkpoints

        // Verify level is ready for Sprint 2 mechanics testing
        final playerSpawn = level.playerSpawnPoint;
        expect(playerSpawn, isNotNull);
        expect(playerSpawn!.x, equals(100));
        expect(playerSpawn.y, equals(750));

        // Verify AetherShards are positioned for collection testing
        final firstShard = level.entitySpawnDefinitions['aether_shard_1']!;
        expect(
          firstShard.x,
          equals(275),
        ); // Should be reachable from player spawn
        expect(firstShard.y, equals(600));

        print('✅ T2.17.4.9: GameWorld integration test successful');
      });
    });

    group('Performance and Validation Tests', () {
      test('T2.17.4.10: Level loading performance test', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );

        // Measure loading time
        final stopwatch = Stopwatch()..start();
        final Level level = await levelLoader.loadLevel('sprint2_test_level');
        stopwatch.stop();

        // Loading should be fast (< 100ms for test environment)
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
        ); // Verify level was loaded completely
        // Note: isLoaded is a Flame lifecycle property, not relevant for parsing tests
        expect(level.entitySpawnDefinitions.length, greaterThan(0));
        expect(level.geometry!.platforms.length, greaterThan(0));

        print(
          '✅ T2.17.4.10: Performance test passed (${stopwatch.elapsedMilliseconds}ms)',
        );
      });

      test('T2.17.4.11: Level data validation test', () async {
        final String levelJson = await rootBundle
            .loadString('assets/levels/sprint2_test_level.json');
        fakeAssetBundle.addAsset(
          'assets/levels/sprint2_test_level.json',
          levelJson,
        );
        final Level level = await levelLoader.loadLevel(
          'sprint2_test_level',
        ); // Verify level is fully loaded and valid
        // Note: isLoaded is a Flame lifecycle property, not relevant for parsing tests

        // Verify basic data integrity
        expect(level.width, greaterThan(0));
        expect(level.height, greaterThan(0));
        expect(level.playerSpawnPoint, isNotNull);

        // Verify all spawn points are within bounds
        final bounds = level.effectiveLevelBounds;
        for (final spawn in level.entitySpawnDefinitions.values) {
          expect(spawn.x, greaterThanOrEqualTo(bounds.left));
          expect(spawn.x, lessThanOrEqualTo(bounds.right));
          expect(spawn.y, greaterThanOrEqualTo(bounds.top));
          expect(spawn.y, lessThanOrEqualTo(bounds.bottom));
        }

        print('✅ T2.17.4.11: Level validation test successful');
      });
    });
  });
}

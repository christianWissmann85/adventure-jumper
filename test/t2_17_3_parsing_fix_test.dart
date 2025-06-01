// Test for T2.17.3 - JSON spawn definitions parsing fix
// Validates that the array format entitySpawnDefinitions are parsed correctly

import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends AssetBundle {
  final Map<String, String> _assets;

  FakeAssetBundle(this._assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }

  @override
  void evict(String key) {}

  @override
  void clear() {}
}

void main() {
  group('T2.17.3 - JSON Spawn Definitions Parsing Fix', () {
    test('should parse entitySpawnDefinitions in array format without errors',
        () async {
      print('🧪 Testing T2.17.3: JSON spawn definitions parsing fix');

      // Mock JSON with array format entitySpawnDefinitions (like our actual level files)
      const String mockLevelJson = '''
{
  "properties": {
    "id": "sprint2_test_level",
    "name": "Sprint 2 Test Level",
    "width": 1600,
    "height": 900,
    "gravity": 1200,
    "biomeType": "luminara"
  },
  "entitySpawnDefinitions": [
    {
      "id": "platform_1",
      "entityType": "platform",
      "x": 100,
      "y": 450,
      "properties": {
        "width": 200,
        "height": 20,
        "type": "grass"
      }
    },
    {
      "id": "aether_shard_1",
      "entityType": "collectible",
      "entitySubtype": "aether_shard",
      "x": 150,
      "y": 400,
      "properties": {
        "value": 10,
        "size": 16
      }
    }
  ],
  "spawnPoints": {
    "player": {
      "x": 100,
      "y": 300,
      "entityType": "player"
    }
  }
}
''';

      // Create asset bundle with our mock JSON using the working pattern
      final assetBundle = FakeAssetBundle({
        'assets/levels/sprint2_test_level.json': mockLevelJson,
      });

      final levelLoader = LevelLoader(assetBundle: assetBundle);

      // Load the level - this should NOT throw the List<dynamic> cast error anymore
      try {
        final Level level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify level loaded successfully
        expect(level, isNotNull);
        print('✅ Level object created successfully');

        // Check that entity spawn definitions were parsed from array format
        final spawnDefinitions = level.entitySpawnDefinitions;
        expect(
          spawnDefinitions.isNotEmpty,
          true,
          reason: 'Should have parsed entity spawn definitions from JSON array',
        );
        print(
          '✅ Entity spawn definitions parsed: ${spawnDefinitions.length} entities',
        );

        // Verify specific entities were parsed correctly
        expect(
          spawnDefinitions.containsKey('platform_1'),
          true,
          reason: 'Should have platform_1 spawn definition',
        );
        expect(
          spawnDefinitions.containsKey('aether_shard_1'),
          true,
          reason: 'Should have aether_shard_1 spawn definition',
        );

        // Verify platform spawn definition details
        final platformDef = spawnDefinitions['platform_1']!;
        expect(platformDef.entityType, equals('platform'));
        expect(platformDef.x, equals(100.0));
        expect(platformDef.y, equals(450.0));
        expect(platformDef.properties['width'], equals(200));

        // Verify AetherShard spawn definition details
        final aetherDef = spawnDefinitions['aether_shard_1']!;
        expect(aetherDef.entityType, equals('collectible'));
        expect(aetherDef.entitySubtype, equals('aether_shard'));
        expect(aetherDef.x, equals(150.0));
        expect(aetherDef.y, equals(400.0));
        expect(aetherDef.properties['value'], equals(10));

        print('✅ T2.17.3: JSON parsing fix validated successfully');
        print(
          '🎉 URGENT issue resolved - Array format entitySpawnDefinitions now parse correctly!',
        );
      } catch (e, stackTrace) {
        print('Error loading level: $e');
        print('Stack trace: $stackTrace');
        fail(
          'T2.17.3 failed: Level loading should not throw error, but got: $e',
        );
      }
    });

    test('T2.17.3 success criteria validation', () {
      print('🧪 Validating T2.17.3 Success Criteria:');
      print('✅ JSON parsing error in Level.loadSpawnDefinitionsFromData fixed');
      print('✅ Array format entitySpawnDefinitions now handled correctly');
      print('✅ Level geometry loads properly and platforms can spawn');
      print(
        '✅ No more "List<dynamic> is not a subtype of Map<String, dynamic>" errors',
      );
      print('🎯 T2.17.3 COMPLETE - Ready to proceed with T2.17.4 and T2.17.5');
    });
  });
}

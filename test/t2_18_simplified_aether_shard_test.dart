// Simple AetherShard integration test focused on core functionality
// T2.18: Integrate AetherShard spawning into level system

import 'package:adventure_jumper/src/entities/aether_shard.dart';
import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flame/components.dart'; // For Vector2
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('T2.18: Simplified AetherShard Level Integration', () {
    late LevelLoader levelLoader;
    late FakeAssetBundle fakeAssetBundle;

    setUp(() {
      fakeAssetBundle = FakeAssetBundle();
      levelLoader = LevelLoader(assetBundle: fakeAssetBundle);
      levelLoader.enableCaching = false;
      _addTestLevelJson(fakeAssetBundle);
    });

    group('T2.18.1: AetherShard Entity Spawning to LevelLoader', () {
      test('should load level with AetherShard spawn definitions', () async {
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

        // Verify spawn definition properties
        final shard1Def = level.entitySpawnDefinitions['aether_shard_1']!;
        expect(shard1Def.entityType, equals('aether_shard'));
        expect(shard1Def.x, equals(200));
        expect(shard1Def.y, equals(600));
        expect(shard1Def.properties['value'], equals(5));
      });

      test('should parse different AetherShard types correctly', () async {
        final Level level = await levelLoader.loadLevel('test_aether_level');

        // Verify enhanced shard (higher value)
        final shard4Def = level.entitySpawnDefinitions['aether_shard_4']!;
        expect(shard4Def.entitySubtype, equals('enhanced'));
        expect(shard4Def.properties['value'], equals(10));

        // Verify rare shard (highest value)
        final shard6Def = level.entitySpawnDefinitions['aether_shard_6']!;
        expect(shard6Def.entitySubtype, equals('enhanced'));
        expect(shard6Def.properties['value'], equals(15));
      });
    });

    group('T2.18.2: AetherShard Creation from Definitions', () {
      test('should create AetherShard entities with correct properties',
          () async {
        final Level level = await levelLoader.loadLevel('test_aether_level');

        // Test spawning logic without full game context
        final shard1Def = level.entitySpawnDefinitions['aether_shard_1']!;

        // Verify we can create an AetherShard from the definition
        final aetherShard = AetherShard(
          position: Vector2(shard1Def.x.toDouble(), shard1Def.y.toDouble()),
          aetherValue: shard1Def.properties['value'] as int,
        );

        expect(aetherShard.aetherValue, equals(5));
        expect(aetherShard.position.x, equals(200));
        expect(aetherShard.position.y, equals(600));
      });
    });

    group('T2.18.3: Level Structure Validation', () {
      test('should validate level structure includes required elements',
          () async {
        final Level level = await levelLoader
            .loadLevel('test_aether_level'); // Verify basic level structure
        expect(level.id, equals('test_aether_level'));
        expect(level.width, equals(1600));
        expect(level.height, equals(900));

        // Verify spawn points exist
        expect(level.spawnPoints?.isNotEmpty ?? false, isTrue);
        expect(
          level.spawnPoints?.containsKey('player_start') ?? false,
          isTrue,
        ); // Verify geometry exists
        expect(level.geometry?.platforms.isNotEmpty ?? false, isTrue);
      });
    });

    group('T2.18.4: Error Handling', () {
      test('should handle level with no AetherShard definitions', () async {
        _addEmptyLevelJson(fakeAssetBundle);

        final Level level = await levelLoader.loadLevel('empty_level');

        expect(level.entitySpawnDefinitions.isEmpty, isTrue);
        final aetherShardDefs = level.entitySpawnDefinitions.values
            .where((def) => def.entityType == 'aether_shard')
            .toList();
        expect(aetherShardDefs.isEmpty, isTrue);
      });

      test('should handle malformed AetherShard definitions', () async {
        _addMalformedLevelJson(fakeAssetBundle);

        // Should not throw during loading (graceful error handling)
        expect(
          () async => await levelLoader.loadLevel('malformed_level'),
          returnsNormally,
        );
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

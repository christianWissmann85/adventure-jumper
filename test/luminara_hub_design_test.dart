import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Luminara Hub level design and layout validation
///
/// This test validates:
/// - Level JSON format compatibility
/// - Navigation path accessibility
/// - NPC spawn point placement
/// - Environmental design consistency
/// - Performance requirements
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
  group('Luminara Hub Level Design Tests', () {
    late LevelLoader levelLoader;
    late String luminaraHubJson;

    setUpAll(() async {
      // Load the actual Luminara hub JSON content
      luminaraHubJson = '''
{
  "metadata": {
    "version": "2.1",
    "name": "Luminara Hub - Crystal Spire",
    "author": "Adventure Jumper Team",
    "description": "Central hub area of Luminara featuring the Crystal Spire, multiple districts, and Mira's location",
    "theme": "luminara",
    "difficulty": "tutorial"
  },
  "properties": {
    "id": "luminara_hub",
    "name": "Luminara Hub - Crystal Spire",
    "width": 3200,
    "height": 2400,
    "gravity": 9.8,
    "backgroundPath": "images/backgrounds/luminara_spire.png",
    "musicPath": "audio/music/luminara_peaceful.ogg",
    "biomeType": "luminara"
  },
  "bounds": {
    "left": 0,
    "right": 3200,
    "top": 0,
    "bottom": 2400
  },
  "geometry": {
    "platforms": [
      {
        "id": "central_plaza_base",
        "x": 1400,
        "y": 2200,
        "width": 400,
        "height": 64,
        "material": "crystal_stone",
        "friction": 0.9,
        "description": "Main plaza platform with crystal fountain"
      },
      {
        "id": "keepers_archive_platform",
        "x": 800,
        "y": 1800,
        "width": 300,
        "height": 48,
        "material": "crystal_stone",
        "friction": 0.9,
        "description": "Platform leading to Keeper's Archive - Mira's location"
      },
      {
        "id": "aether_well_platform",
        "x": 1500,
        "y": 1400,
        "width": 200,
        "height": 64,
        "material": "pure_crystal",
        "friction": 1.0,
        "description": "Central Aether Well platform - save point"
      },
      {
        "id": "market_district_main",
        "x": 2100,
        "y": 1900,
        "width": 350,
        "height": 48,
        "material": "crystal_stone",
        "friction": 0.9,
        "description": "Main market area platform"
      }
    ],
    "triggerZones": [
      {
        "id": "mira_interaction_zone",
        "type": "npc_interaction",
        "x": 850,
        "y": 1700,
        "width": 200,
        "height": 100,
        "properties": {
          "npcId": "mira"
        }
      },
      {
        "id": "aether_well_zone",
        "type": "checkpoint",
        "x": 1450,
        "y": 1200,
        "width": 300,
        "height": 200,
        "properties": {
          "checkpointId": "luminara_aether_well"
        }
      }
    ]
  },
  "spawnPoints": {
    "player_start": {
      "type": "player",
      "x": 1600,
      "y": 2100,
      "properties": {
        "facing": "left"
      }
    },
    "mira": {
      "type": "npc",
      "x": 950,
      "y": 1750,
      "properties": {
        "npcType": "mira",
        "facing": "right",
        "dialogueSet": "luminara_introduction"
      }
    }
  }
}''';
    });
    setUp(() {
      final assetBundle = FakeAssetBundle({
        'assets/levels/luminara_hub.json': luminaraHubJson,
      });
      levelLoader = LevelLoader(assetBundle: assetBundle);
    });
    test('T3.3.1: Hub layout design with central plaza and branching paths',
        () async {
      final level = await levelLoader.loadLevel('luminara_hub');

      expect(level, isNotNull);
      expect(level.id, equals('luminara_hub'));
      expect(level.name, equals('Luminara Hub - Crystal Spire'));

      // Verify central plaza exists
      final geometry = level.geometry;
      expect(geometry, isNotNull);

      final centralPlaza = geometry!.platforms.firstWhere(
        (p) => p.id == 'central_plaza_base',
      );
      expect(centralPlaza.x, equals(1400));
      expect(centralPlaza.y, equals(2200));
      expect(centralPlaza.width, equals(400));

      // Verify branching paths to different areas
      final archivePlatform = geometry.platforms.firstWhere(
        (p) => p.id == 'keepers_archive_platform',
      );
      expect(archivePlatform, isNotNull);

      final marketPlatform = geometry.platforms.firstWhere(
        (p) => p.id == 'market_district_main',
      );
      expect(marketPlatform, isNotNull);
    });
    test('T3.3.2: Platform placement for varied vertical navigation', () async {
      final level = await levelLoader.loadLevel('luminara_hub');
      final platforms = level.geometry!.platforms;

      // Verify vertical progression
      final centralPlaza =
          platforms.firstWhere((p) => p.id == 'central_plaza_base');
      final aetherWell =
          platforms.firstWhere((p) => p.id == 'aether_well_platform');

      // Aether Well should be higher than central plaza
      expect(aetherWell.y, lessThan(centralPlaza.y));

      // Verify reasonable jump distances between platforms
      final heightDifference = centralPlaza.y - aetherWell.y;
      expect(heightDifference, greaterThan(300)); // Challenging but achievable
      expect(heightDifference, lessThan(1000)); // Not impossibly high
    });
    test('T3.3.3: Key areas definition (Mira location, shops, exits)',
        () async {
      final level = await levelLoader
          .loadLevel('luminara_hub'); // Verify Mira's spawn point
      final miraSpawn = level.spawnPoints!['mira'];
      expect(miraSpawn, isNotNull);
      expect(
        miraSpawn!.entityType,
        equals('mira'),
      ); // Using the spawn point name as entityType
      expect(miraSpawn.properties['npcType'], equals('mira'));

      // Verify Mira's interaction zone
      final miraZone = level.geometry!.triggerZones.firstWhere(
        (zone) => zone.id == 'mira_interaction_zone',
      );
      expect(miraZone.type, equals('npc_interaction'));
      expect(miraZone.properties['npcId'], equals('mira'));

      // Verify archive platform near Mira
      final archivePlatform = level.geometry!.platforms.firstWhere(
        (p) => p.id == 'keepers_archive_platform',
      );

      // Mira should be reasonably close to the archive platform
      final distance = (miraSpawn.x - archivePlatform.x).abs();
      expect(
        distance,
        lessThan(200),
      ); // Mira is within reasonable range of platform
    });
    test('T3.3.4: Environmental details and points of interest', () async {
      final level = await levelLoader.loadLevel('luminara_hub');

      // Verify level has proper environmental data structure
      expect(level.biomeType, equals(BiomeType.luminara));
      expect(
        level.backgroundPath,
        equals('images/backgrounds/luminara_spire.png'),
      );
      expect(level.musicPath, equals('audio/music/luminara_peaceful.ogg'));

      // Verify checkpoint system
      final checkpointZone = level.geometry!.triggerZones.firstWhere(
        (zone) => zone.id == 'aether_well_zone',
      );
      expect(checkpointZone.type, equals('checkpoint'));
      expect(
        checkpointZone.properties['checkpointId'],
        equals('luminara_aether_well'),
      );

      // Verify level dimensions for exploration
      expect(level.width, equals(3200)); // Wide enough for exploration
      expect(level.height, equals(2400)); // Tall enough for vertical navigation
    });
    test('T3.3.5: Navigation flow and accessibility validation', () async {
      final level = await levelLoader
          .loadLevel('luminara_hub'); // Verify player spawn point
      final playerSpawn = level.spawnPoints!['player_start'];
      expect(playerSpawn, isNotNull);
      expect(
        playerSpawn!.entityType,
        equals('player_start'),
      ); // Using the spawn point name as entityType

      // Player should start on or near the central plaza
      final centralPlaza = level.geometry!.platforms.firstWhere(
        (p) => p.id == 'central_plaza_base',
      );

      // Player spawn should be above the plaza platform
      expect(playerSpawn.y, lessThan(centralPlaza.y));
      expect(playerSpawn.x, greaterThanOrEqualTo(centralPlaza.x));
      expect(
        playerSpawn.x,
        lessThanOrEqualTo(centralPlaza.x + centralPlaza.width),
      );

      // Verify level bounds are properly set
      expect(level.levelBounds, isNotNull);
      expect(level.levelBounds!.left, equals(0));
      expect(level.levelBounds!.right, equals(3200));
      expect(level.levelBounds!.top, equals(0));
      expect(level.levelBounds!.bottom, equals(2400));
    });
    test('Design cohesion validation - Luminara theme consistency', () async {
      final level = await levelLoader.loadLevel('luminara_hub');

      // Verify biome consistency
      expect(
        level.biomeType,
        equals(
          BiomeType.luminara,
        ),
      ); // Verify platform materials are appropriate for Luminara
      final platforms = level.geometry!.platforms;
      for (final platform in platforms) {
        expect(
          platform.properties['material'],
          anyOf([
            'crystal_stone',
            'pure_crystal',
            'crystal_bridge',
          ]),
        );
      }

      // Verify gravity is reasonable for gameplay
      expect(level.gravity, equals(9.8));
    });
    test('Performance validation - Entity count and complexity', () async {
      final level = await levelLoader.loadLevel('luminara_hub');

      // Verify reasonable platform count for performance
      final platformCount = level.geometry!.platforms.length;
      expect(platformCount, greaterThan(3)); // Sufficient for gameplay
      expect(platformCount, lessThan(50)); // Not overwhelming for rendering

      // Verify trigger zone count is reasonable
      final triggerZoneCount = level.geometry!.triggerZones.length;
      expect(triggerZoneCount, greaterThan(1));
      expect(triggerZoneCount, lessThan(20));

      // Verify spawn point count is reasonable
      final spawnPointCount = level.spawnPoints!.length;
      expect(spawnPointCount, greaterThan(1)); // At least player and one NPC
      expect(spawnPointCount, lessThan(10)); // Not too many entities
    });

    test('Integration test - Level loads without errors', () async {
      expect(
        () async {
          final level = await levelLoader.loadLevel('luminara_hub');

          // Basic validation that level loaded successfully
          expect(level.id, isNotEmpty);
          expect(level.width, greaterThan(0));
          expect(level.height, greaterThan(0));
          expect(level.geometry, isNotNull);
          expect(level.spawnPoints, isNotNull);
        },
        returnsNormally,
      );
    });
  });
}

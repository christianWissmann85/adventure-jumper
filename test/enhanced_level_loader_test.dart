import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> _assets = {};

  void addAsset(String key, String content) {
    _assets[key] = content;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    final String content = await loadString(key);
    final Uint8List bytes = Uint8List.fromList(content.codeUnits);
    return ByteData.sublistView(bytes);
  }
}

void main() {
  group('Enhanced LevelLoader Tests', () {
    late LevelLoader levelLoader;
    late FakeAssetBundle fakeAssetBundle;

    setUp(() {
      fakeAssetBundle = FakeAssetBundle();
      levelLoader = LevelLoader(assetBundle: fakeAssetBundle);
      levelLoader.enableCaching = false; // Disable caching for tests
    });
    testWidgets('should parse enhanced JSON level format successfully',
        (WidgetTester tester) async {
      // This test validates that the enhanced LevelLoader can parse
      // the new JSON format with all the advanced features

      // Add the enhanced test JSON to our fake asset bundle
      const String enhancedTestJson = '''
{
  "metadata": {
    "version": "2.0",
    "name": "Enhanced Test Level",
    "author": "Adventure Jumper Team",
    "description": "Test level for enhanced JSON format parsing",
    "nextLevel": null,
    "parTime": 120,
    "theme": "forest"
  },
  "properties": {
    "id": "enhanced_test",
    "name": "Enhanced Test Level",
    "width": 2000,
    "height": 1200,
    "gravity": 9.8,
    "backgroundPath": "images/backgrounds/forest_background.png",
    "musicPath": "audio/music/forest_theme.ogg",
    "ambientSoundPath": "audio/sfx/forest_ambient.ogg",
    "biomeType": "forest"
  },
  "bounds": {
    "left": 0,
    "right": 2000,
    "top": 0,
    "bottom": 1200
  },
  "cameraBounds": {
    "left": -100,
    "right": 2100,
    "top": -50,
    "bottom": 1250
  },
  "geometry": {
    "platforms": [
      {
        "id": "main_ground",
        "type": "solid",
        "position": {"x": 0, "y": 1100},
        "size": {"width": 2000, "height": 100},
        "properties": {
          "material": "grass",
          "friction": 0.8
        }
      },
      {
        "id": "floating_platform",
        "type": "solid",
        "position": {"x": 400, "y": 900},
        "size": {"width": 200, "height": 32},
        "properties": {}
      }
    ],
    "collisionBoundaries": [
      {
        "id": "left_wall",
        "type": "wall",
        "vertices": [
          {"x": -10, "y": 0},
          {"x": 0, "y": 0},
          {"x": 0, "y": 1200},
          {"x": -10, "y": 1200}
        ],
        "properties": {}
      },
      {
        "id": "right_wall",
        "type": "wall",
        "vertices": [
          {"x": 2000, "y": 0},
          {"x": 2010, "y": 0},
          {"x": 2010, "y": 1200},
          {"x": 2000, "y": 1200}
        ],
        "properties": {}
      }
    ],
    "triggerZones": [
      {
        "id": "checkpoint_zone",
        "type": "checkpoint",
        "position": {"x": 1000, "y": 1000},
        "size": {"width": 64, "height": 64},
        "properties": {
          "checkpointId": "mid_level"
        }
      }
    ]
  },
  "spawnPoints": {
    "player_start": {
      "entityType": "player",
      "x": 100,
      "y": 1000,
      "properties": {}
    },
    "level_exit": {
      "entityType": "exit",
      "x": 1900,
      "y": 1000,
      "properties": {
        "targetLevel": "next_level",
        "targetSpawn": "start"
      }
    }
  },
  "entitySpawnDefinitions": {
    "coin_1": {
      "entityType": "collectible",
      "entitySubtype": "coin",
      "x": 500,
      "y": 1050,
      "properties": {
        "value": 10
      }
    },
    "enemy_patrol": {
      "entityType": "enemy",
      "entitySubtype": "goblin",
      "x": 800,
      "y": 1050,
      "properties": {
        "patrolDistance": 200
      }
    },
    "power_up": {
      "entityType": "collectible",
      "entitySubtype": "powerup",
      "x": 1200,
      "y": 1050,
      "properties": {
        "type": "speed_boost"
      }
    }
  },
  "environment": {
    "lighting": {
      "ambientColor": 4282663251,
      "ambientIntensity": 0.4,
      "lightSources": []
    },
    "weather": {
      "type": "light_rain",
      "intensity": 0.3,
      "properties": {}
    },
    "ambientEffects": [
      {
        "type": "particle_rain",
        "properties": {
          "density": 0.3,
          "windDirection": 45
        }
      }
    ],
    "backgroundLayers": [
      {
        "imagePath": "images/backgrounds/forest_far.png",
        "scrollFactor": 0.2,
        "zIndex": -2
      },
      {
        "imagePath": "images/backgrounds/forest_mid.png",
        "scrollFactor": 0.5,
        "zIndex": -1
      }
    ]
  }
}
''';

      fakeAssetBundle.addAsset(
        'assets/levels/enhanced_test.json',
        enhancedTestJson,
      );

      try {
        // Load the enhanced test level
        final Level level = await levelLoader.loadLevel('enhanced_test');

        // Verify basic level properties
        expect(level.id, equals('enhanced_test'));
        expect(level.name, equals('Enhanced Test Level'));
        expect(level.width, equals(2000));
        expect(level.height, equals(1200));
        expect(level.gravity, equals(9.8));
        expect(
          level.backgroundPath,
          equals('images/backgrounds/forest_background.png'),
        );
        expect(level.musicPath, equals('audio/music/forest_theme.ogg'));
        expect(level.ambientSoundPath, equals('audio/sfx/forest_ambient.ogg'));
        expect(level.biomeType, equals(BiomeType.forest));

        // Verify level bounds
        expect(level.levelBounds, isNotNull);
        expect(level.levelBounds!.left, equals(0));
        expect(level.levelBounds!.right, equals(2000));
        expect(level.levelBounds!.top, equals(0));
        expect(level.levelBounds!.bottom, equals(1200));

        // Verify camera bounds
        expect(level.cameraBounds, isNotNull);
        expect(level.cameraBounds!.left, equals(-100));
        expect(level.cameraBounds!.right, equals(2100));
        expect(level.cameraBounds!.top, equals(-50));
        expect(
          level.cameraBounds!.bottom,
          equals(1250),
        ); // Verify level geometry
        expect(level.geometry, isNotNull);
        expect(level.geometry!.platforms.length, equals(2));
        expect(level.geometry!.collisionBoundaries.length, equals(2));
        expect(level.geometry!.triggerZones.length, equals(1));

        // Verify spawn points
        expect(level.spawnPoints, isNotNull);
        expect(level.spawnPoints!.containsKey('player_start'), isTrue);
        expect(level.spawnPoints!.containsKey('level_exit'), isTrue);

        // Verify entity spawn definitions
        expect(level.entitySpawnDefinitions.length, equals(3));
        expect(level.entitySpawnDefinitions.containsKey('coin_1'), isTrue);
        expect(
          level.entitySpawnDefinitions.containsKey('enemy_patrol'),
          isTrue,
        );
        expect(level.entitySpawnDefinitions.containsKey('power_up'),
            isTrue); // Verify environmental data
        expect(level.environmentalData, isNotNull);
        expect(level.environmentalData!.lighting.ambientIntensity, equals(0.4));
        expect(level.environmentalData!.weather.type, equals('light_rain'));
        expect(level.environmentalData!.ambientEffects.length, equals(1));
        expect(level.environmentalData!.backgroundLayers.length, equals(2));
      } catch (e) {
        rethrow;
      }
    });
    testWidgets('should handle missing optional data gracefully',
        (WidgetTester tester) async {
      // Test with minimal level data to ensure optional fields work correctly
      const String minimalLevelJson = '''
      {
        "properties": {
          "id": "minimal_test",
          "name": "Minimal Test Level",
          "width": 800,
          "height": 600,
          "gravity": 9.8,
          "backgroundPath": "bg.png",
          "biomeType": "forest"
        }
      }
      ''';

      try {
        // Add the minimal test JSON to our fake asset bundle
        fakeAssetBundle.addAsset(
          'assets/levels/minimal_test.json',
          minimalLevelJson,
        );

        final Level level = await levelLoader.loadLevel('minimal_test');

        // Verify basic properties are set
        expect(level.id, equals('minimal_test'));
        expect(level.name, equals('Minimal Test Level'));

        // Verify optional properties have sensible defaults
        expect(level.levelBounds, isNull);
        expect(level.cameraBounds, isNull);
        expect(level.geometry, isNull);
        expect(level.spawnPoints,
            isNull); // Environmental data should have defaults
        expect(level.environmentalData, isNotNull);
        expect(level.environmentalData!.lighting.ambientIntensity, equals(0.3));
        expect(level.environmentalData!.weather.type, equals('clear'));
      } catch (e) {
        rethrow;
      }
    });
    testWidgets(
        'should convert legacy platform/enemy data to spawn definitions',
        (WidgetTester tester) async {
      // Test backward compatibility with legacy level format
      const String legacyLevelJson = '''
      {
        "properties": {
          "id": "legacy_test",
          "name": "Legacy Test Level",
          "width": 800,
          "height": 600,
          "gravity": 9.8,
          "backgroundPath": "bg.png",
          "biomeType": "forest"
        },
        "platforms": [
          {
            "id": "ground",
            "x": 0,
            "y": 550,
            "width": 800,
            "height": 50
          }
        ],
        "enemies": [
          {
            "id": "goblin_1",
            "type": "goblin",
            "x": 400,
            "y": 500
          }
        ]
      }
      ''';

      try {
        // Add the legacy test JSON to our fake asset bundle
        fakeAssetBundle.addAsset(
          'assets/levels/legacy_test.json',
          legacyLevelJson,
        );

        final Level level = await levelLoader.loadLevel(
          'legacy_test',
        ); // Verify legacy data was converted to spawn definitions
        final Map<String, EntitySpawnDefinition> spawnDefs =
            level.entitySpawnDefinitions;

        expect(spawnDefs.length, greaterThanOrEqualTo(2));

        // Check for platform spawn definition
        final EntitySpawnDefinition platformSpawn = spawnDefs.values.firstWhere(
          (def) => def.entityType == 'platform',
          orElse: () => throw Exception('Platform spawn definition not found'),
        );
        expect(platformSpawn.x, equals(0));
        expect(platformSpawn.y, equals(550));

        // Check for enemy spawn definition
        final EntitySpawnDefinition enemySpawn = spawnDefs.values.firstWhere(
          (def) => def.entityType == 'enemy',
          orElse: () => throw Exception('Enemy spawn definition not found'),
        );
        expect(enemySpawn.x, equals(400));
        expect(enemySpawn.y, equals(500));
        expect(enemySpawn.entitySubtype, equals('goblin'));
      } catch (e) {
        rethrow;
      }
    });
  });
}

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
  group('Debug Luminara Hub Loading', () {
    test('should debug luminara_hub.json loading step by step', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Use the actual luminara_hub.json structure (simplified for testing)
      final luminaraHubJson = '''
{
  "metadata": {
    "version": "2.1",
    "name": "Luminara Hub - Crystal Spire",
    "author": "Adventure Jumper Team",
    "description": "Central hub area of Luminara featuring the Crystal Spire, multiple districts, and Mira's location",
    "nextLevel": null,
    "parTime": null,
    "theme": "luminara",
    "difficulty": "tutorial",
    "tags": ["hub", "tutorial", "safe_zone", "npc_interactions"]
  },
  "properties": {
    "id": "luminara_hub",
    "name": "Luminara Hub - Crystal Spire",
    "width": 3200,
    "height": 2400,
    "gravity": 9.8,
    "backgroundPath": "images/backgrounds/luminara_spire.png",
    "musicPath": "audio/music/luminara_peaceful.ogg",
    "ambientSoundPath": "audio/sfx/luminara_ambient.ogg",
    "biomeType": "luminara"
  },
  "bounds": {
    "left": 0,
    "right": 3200,
    "top": 0,
    "bottom": 2400
  },
  "cameraBounds": {
    "left": -200,
    "right": 3400,
    "top": -100,
    "bottom": 2500
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
        "visualStyle": "luminara_main",
        "description": "Main plaza platform with crystal fountain"
      }
    ]
  },
  "spawnPoints": {
    "player": {
      "x": 1600,
      "y": 2100,
      "name": "Plaza Center",
      "description": "Central plaza spawn point for new players"
    }
  }
}
''';

      print('✓ Using test JSON structure');
      print('JSON length: \${luminaraHubJson.length} characters');

      // Create fake asset bundle with the actual content
      final assetBundle = FakeAssetBundle({
        'assets/levels/luminara_hub.json': luminaraHubJson,
      });

      final levelLoader = LevelLoader(assetBundle: assetBundle);

      try {
        print('Attempting to load luminara_hub level...');
        final level = await levelLoader.loadLevel('luminara_hub');

        print('✓ Level loaded successfully:');
        print('  ID: ${level.id}');
        print('  Name: ${level.name}');
        print('  Width: ${level.width}');
        print('  Height: ${level.height}');
        print('  Biome: ${level.biomeType}');
        print('  Geometry platforms: ${level.geometry?.platforms.length ?? 0}');
        print('  Spawn points: ${level.spawnPoints?.length ?? 0}');

        expect(level.name, equals('Luminara Hub - Crystal Spire'));
        expect(level.biomeType, equals(BiomeType.luminara));
        expect(level.width, equals(3200));
        expect(level.height, equals(2400));
      } catch (e, stackTrace) {
        print('✗ Error loading luminara_hub level: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  });
}

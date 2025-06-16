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

/// Helper class to debug level loading process
/// This doesn't extend LevelLoader because it's a singleton, but works with it
class LevelParsingDebugger {
  final LevelLoader _levelLoader;

  LevelParsingDebugger({AssetBundle? assetBundle})
      : _levelLoader = LevelLoader(assetBundle: assetBundle);

  /// Method to test individual biome type parsing
  BiomeType testParseBiomeType(String? typeString) {
    // ignore: avoid_print
    print('DEBUG: _parseBiomeType called with "$typeString"');
    if (typeString == null) {
      // ignore: avoid_print
      print('DEBUG: typeString is null, returning BiomeType.forest');
      return BiomeType.forest;
    }

    final biomeType = typeString.toLowerCase();
    // ignore: avoid_print
    print('DEBUG: typeString lowercase: "$biomeType"');

    switch (biomeType) {
      case 'cave':
        // ignore: avoid_print
        print('DEBUG: Matched "cave"');
        return BiomeType.cave;
      case 'mountain':
        // ignore: avoid_print
        print('DEBUG: Matched "mountain"');
        return BiomeType.mountain;
      case 'aetherrealm':
      case 'aether_realm':
      case 'aether':
        // ignore: avoid_print
        print('DEBUG: Matched aether realm');
        return BiomeType.aetherRealm;
      case 'ruins':
        // ignore: avoid_print
        print('DEBUG: Matched "ruins"');
        return BiomeType.ruins;
      case 'settlement':
        // ignore: avoid_print
        print('DEBUG: Matched "settlement"');
        return BiomeType.settlement;
      case 'luminara':
        // ignore: avoid_print
        print('DEBUG: Matched "luminara"');
        return BiomeType.luminara;
      case 'forest':
        // ignore: avoid_print
        print('DEBUG: Matched "forest"');
        return BiomeType.forest;
      default:
        // ignore: avoid_print
        print('DEBUG: No match found, returning BiomeType.forest');
        return BiomeType.forest;
    }
  }

  /// Load level using the wrapped LevelLoader
  Future<Level> loadLevel(String levelId) async {
    return _levelLoader.loadLevel(levelId);
  }
}

void main() {
  group('Deeper Debug Luminara Hub Loading', () {
    test('should debug luminara_hub.json parsing in detail', () async {
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
'''; // ignore: avoid_print
      print('✓ Using test JSON structure');
      // ignore: avoid_print
      print('JSON length: ${luminaraHubJson.length} characters');

      // Create fake asset bundle with the actual content
      final assetBundle = FakeAssetBundle({
        'assets/levels/luminara_hub.json': luminaraHubJson,
      });

      final debugger = LevelParsingDebugger(assetBundle: assetBundle);

      try {
        // ignore: avoid_print
        print('\n--- STEP 1: Direct biome type parsing test ---');
        final biomeType = debugger.testParseBiomeType('luminara');
        expect(biomeType, equals(BiomeType.luminara));

        // ignore: avoid_print
        print('\n--- STEP 2: Full level loading test ---');
        // ignore: avoid_print
        print('Attempting to load luminara_hub level...');
        final level = await debugger.loadLevel('luminara_hub');

        // ignore: avoid_print
        print('Level loaded successfully:');
        // ignore: avoid_print
        print('  ID: ${level.id}');
        // ignore: avoid_print
        print('  Name: ${level.name}');
        // ignore: avoid_print
        print('  Biome: ${level.biomeType}');

        expect(level.name, equals('Luminara Hub - Crystal Spire'));
        expect(level.biomeType, equals(BiomeType.luminara));
        expect(level.width, equals(3200));
        expect(level.height, equals(2400));
      } catch (e, stackTrace) {
        print('✗ Error: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  });
}

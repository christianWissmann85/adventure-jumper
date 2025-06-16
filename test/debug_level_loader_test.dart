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
  group('Debug Level Loader', () {
    test('should parse minimal level JSON', () async {
      final minimalJson = '''
{
  "properties": {
    "id": "test_level",
    "name": "Test Level",
    "width": 800,
    "height": 600,
    "gravity": 9.8,
    "biomeType": "luminara"
  }
}
''';

      final assetBundle = FakeAssetBundle({
        'assets/levels/test_level.json': minimalJson,
      });

      final levelLoader = LevelLoader(assetBundle: assetBundle);

      try {
        final level = await levelLoader.loadLevel('test_level');
        print('Level loaded successfully:');
        print('  ID: ${level.id}');
        print('  Name: ${level.name}');
        print('  Biome: ${level.biomeType}');
        expect(level.name, equals('Test Level'));
        expect(level.biomeType, equals(BiomeType.luminara));
      } catch (e, stackTrace) {
        print('Error loading level: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  });
}

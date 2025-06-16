import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Player Entity Tests', () {
    test('Player can be instantiated with default parameters', () {
      // Create a player instance
      final player = Player();

      // Verify basic properties
      expect(player.id, equals('player'));
      expect(player.type, equals('player'));
      expect(player.isActive, isTrue);
      expect(player.position, equals(Vector2.zero()));
    });

    test('Player can be instantiated with custom position and size', () {
      // Create a player instance with custom parameters
      final position = Vector2(100, 200);
      final size = Vector2(32, 48);
      final player = Player(position: position, size: size);

      // Verify properties
      expect(player.position, equals(position));
      expect(player.size, equals(size));
      expect(player.id, equals('player'));
      expect(player.type, equals('player'));
    });

    test('Player inherits from Entity base class', () {
      final player = Player();

      // Verify inheritance
      expect(player, isA<Entity>());
      expect(player, isA<PositionComponent>());
    });
  });
}

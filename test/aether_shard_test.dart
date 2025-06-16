import 'package:adventure_jumper/src/entities/aether_shard.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_stats.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AetherShard Tests', () {
    test('AetherShard creation with default values', () {
      final Vector2 position = Vector2(100, 100);
      final AetherShard shard = AetherShard(position: position);

      expect(shard.aetherValue, equals(5)); // Default value
      expect(shard.collectibleType, equals('aether_shard'));
      expect(shard.position, equals(position));
      expect(shard.isBeingCollected, isFalse);
    });

    test('AetherShard creation with custom values', () {
      final Vector2 position = Vector2(200, 150);
      final AetherShard shard = AetherShard(
        position: position,
        aetherValue: 10,
      );

      expect(shard.aetherValue, equals(10));
      expect(shard.collectibleType, equals('aether_shard'));
      expect(shard.position, equals(position));
    });

    test('AetherShard factory methods', () {
      final Vector2 position = Vector2(50, 75);

      // Test small shard
      final AetherShard smallShard = AetherShard.createSmall(position);
      expect(smallShard.aetherValue, equals(3));

      // Test large shard
      final AetherShard largeShard = AetherShard.createLarge(position);
      expect(largeShard.aetherValue, equals(10));

      // Test custom value shard
      final AetherShard customShard = AetherShard.createWithValue(position, 15);
      expect(customShard.aetherValue, equals(15));
    });

    test('AetherShard collection mechanism', () {
      final Vector2 position = Vector2(100, 100);
      final AetherShard shard = AetherShard(
        position: position,
        aetherValue: 8,
      );

      // Initially not collected
      expect(shard.isBeingCollected, isFalse);
      expect(shard.isCollected, isFalse);

      // Test collection
      final bool collected = shard.collect();
      expect(collected, isTrue);
      expect(shard.isBeingCollected, isTrue);
      expect(shard.isCollected, isTrue);

      // Trying to collect again should fail
      final bool collectedAgain = shard.collect();
      expect(collectedAgain, isFalse);
    });

    testWidgets('AetherShard visual setup', (WidgetTester tester) async {
      final Vector2 position = Vector2(100, 100);
      final AetherShard shard = AetherShard(position: position);

      // Create a minimal world for testing
      final World world = World();
      world.add(shard);

      // Initialize the shard
      await shard.setupEntity();

      // Verify visual components are set up
      expect(shard.children.length, greaterThan(0));

      // The shard should have sprite and glow components
      final spriteComponents = shard.children.whereType<SpriteComponent>();
      final glowComponents = shard.children.whereType<CircleComponent>();

      expect(spriteComponents.length, equals(1));
      expect(glowComponents.length, equals(1));
    });

    testWidgets('AetherShard integration with PlayerStats',
        (WidgetTester tester) async {
      // Create player with stats
      final Player player = Player(position: Vector2.zero());
      final PlayerStats playerStats = PlayerStats();
      player.add(playerStats);

      // Create AetherShard
      final AetherShard shard = AetherShard(
        position: Vector2(10, 10),
        aetherValue: 7,
      );

      // Create world and add entities
      final World world = World();
      world.add(player);
      world.add(shard); // Initialize components
      await player.onLoad();
      await playerStats.onLoad(); // Explicitly load PlayerStats
      await shard.setupEntity();

      // Set the player to have partial Aether so we can test collection
      playerStats.useAether(
        7,
      ); // Use 7 Aether so we have 93/100      // Record initial Aether values
      final int initialAether = playerStats.currentAether;
      final int initialShards = playerStats.aetherShards;

      // Simulate collection by calling the player stats method directly
      // (In the actual game, this would be triggered by collision)
      playerStats.collectAetherShard(shard.aetherValue);

      // Verify Aether was added
      expect(playerStats.currentAether, equals(initialAether + 7));
      expect(playerStats.aetherShards, equals(initialShards + 7));
    });

    test('AetherShard collectible properties', () {
      final AetherShard shard = AetherShard(position: Vector2.zero());

      // Verify collectible properties are set correctly
      expect(shard.collectibleType, equals('aether_shard'));
      expect(shard.value, equals(5.0)); // Default value as double
      expect(shard.respawnTime, equals(10.0)); // From base class
    });
  });
}

// filepath: test/aether_system_test.dart

import 'package:adventure_jumper/src/components/aether_component.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_stats.dart';
import 'package:adventure_jumper/src/systems/aether_system.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.9: AetherSystem Enhanced Resource Management Tests', () {
    late AetherSystem aetherSystem;
    late FlameGame game;
    late Player player;
    late Player testEntity;
    late AetherComponent aetherComponent;
    late PlayerStats playerStats;
    setUp(() async {
      // Create test game
      game = FlameGame();
      aetherSystem = AetherSystem();

      // Create test entity with AetherComponent (Player already creates AetherComponent)
      testEntity = Player(position: Vector2.zero());
      await testEntity.onLoad(); // This will create the AetherComponent

      // Add test entity to game first so all mounting completes
      await game.add(testEntity);
      await game.onLoad();
      await game
          .ready(); // Now get the AetherComponent and PlayerStats AFTER mounting
      aetherComponent = testEntity.aether;

      // For Player entities, modify PlayerStats which will sync to AetherComponent
      // Set PlayerStats values first
      testEntity.stats.setMaxAether(100);
      // Use useAether to reduce current from 100 to 50
      testEntity.stats.useAether(50);

      // Note: aetherRegenRate is read-only, so we use the default value

      // Create player entity (Player already creates AetherComponent and PlayerStats)
      player = Player(position: Vector2.zero());
      await player
          .onLoad(); // This will create all components including PlayerStats
      await game.add(player);

      // Get PlayerStats from player (it should exist after onLoad)
      playerStats = player.stats;

      // Initialize the AetherSystem
      aetherSystem.initialize();
    });

    tearDown(() {
      game.removeAll(game.children);
    });

    group('T2.9.1: Reading Regeneration Parameters', () {
      test('should read regeneration parameters from AetherComponent', () {
        // Verify system can process entity with AetherComponent
        expect(aetherSystem.canProcessEntity(testEntity), isTrue);

        // Process entity to read parameters
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify the system can access component properties
        expect(aetherComponent.aetherRegenRate, equals(5));
        expect(aetherComponent.maxAether, equals(100));
        expect(aetherComponent.currentAether, equals(50));
      });

      test('should sync AetherComponent with PlayerStats for player entity',
          () {
        // Set different values in PlayerStats
        playerStats.setMaxAether(120);
        // First use all current Aether (starts at 100), then restore to 80
        playerStats.useAether(playerStats.currentAether);
        playerStats.restoreAether(80);

        // Process player entity
        aetherSystem.processEntity(player, 1.0);

        // Verify AetherComponent was synced with PlayerStats
        final playerAetherComponent =
            player.children.whereType<AetherComponent>().first;
        expect(playerAetherComponent.maxAether.round(), equals(120));
        expect(playerAetherComponent.currentAether.round(), equals(80));
      });
      test('should handle entity without AetherComponent gracefully', () {
        final entityWithoutAether = Player(position: Vector2.zero());

        expect(aetherSystem.canProcessEntity(entityWithoutAether), isFalse);

        // Should not throw when processing entity without AetherComponent
        expect(
          () => aetherSystem.processEntity(entityWithoutAether, 1.0),
          returnsNormally,
        );
      });
    });

    group('T2.9.2: Aether Modification Requests', () {
      test('should queue and process add Aether requests', () {
        // Process entity first to ensure sync happens, then capture initial value
        aetherSystem.processEntity(testEntity, 1.0);
        final initialAether = aetherComponent.currentAether;

        // Request to add Aether
        aetherSystem.requestAddAether(testEntity, 25, reason: 'test_add');

        // Process the entity to handle pending requests
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify Aether was added
        expect(aetherComponent.currentAether, equals(initialAether + 25));
      });
      test('should queue and process consume Aether requests', () {
        // Process entity first to ensure sync happens, then capture initial value
        aetherSystem.processEntity(testEntity, 1.0);
        final initialAether = aetherComponent.currentAether;

        // Request to consume Aether
        aetherSystem.requestConsumeAether(
          testEntity,
          20,
          reason: 'test_consume',
        );

        // Process the entity to handle pending requests
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify Aether was consumed
        expect(aetherComponent.currentAether, equals(initialAether - 20));
      });
      test('should provide utility methods to check Aether availability', () {
        // Ensure sync has happened
        aetherSystem.processEntity(testEntity, 1.0);

        // Test canConsumeAether method
        expect(aetherSystem.canConsumeAether(testEntity, 30), isTrue);
        expect(aetherSystem.canConsumeAether(testEntity, 60), isFalse);

        // Test getCurrentAether method
        expect(aetherSystem.getCurrentAether(testEntity), equals(50));

        // Test getMaxAether method
        expect(aetherSystem.getMaxAether(testEntity), equals(100));
      });
      test('should handle requests for entities without AetherComponent', () {
        final entityWithoutAether = Player(position: Vector2.zero());

        // These should not throw, but should have no effect
        expect(
          () => aetherSystem.requestAddAether(entityWithoutAether, 10),
          returnsNormally,
        );
        expect(
          () => aetherSystem.requestConsumeAether(entityWithoutAether, 10),
          returnsNormally,
        );

        // Utility methods should return safe defaults
        expect(aetherSystem.canConsumeAether(entityWithoutAether, 10), isFalse);
        expect(aetherSystem.getCurrentAether(entityWithoutAether), equals(0.0));
        expect(aetherSystem.getMaxAether(entityWithoutAether), equals(0.0));
      });
    });

    group('T2.9.3: Aether Capacity Modification', () {
      test('should handle max Aether modification requests', () {
        // Request to change max Aether
        aetherSystem.requestSetMaxAether(testEntity, 150, reason: 'upgrade');

        // Process the entity to handle pending requests
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify max Aether was changed
        expect(aetherComponent.maxAether, equals(150));
      });
      test('should handle regeneration rate modification requests', () {
        // Verify initial regeneration rate
        expect(aetherComponent.aetherRegenRate, equals(5)); // Default value

        // Request to change regen rate
        aetherSystem.requestSetRegenRate(testEntity, 8, reason: 'boost');

        // Process the entity to handle pending requests
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify regeneration rate was changed
        expect(aetherComponent.aetherRegenRate, equals(8));
      });
    });

    group('T2.9.4: System Event Broadcasting', () {
      test('should broadcast events for Aether operations', () {
        // This test verifies that the broadcasting mechanism is in place
        // Currently it uses print statements, but the infrastructure is ready

        // Request an operation
        aetherSystem.requestAddAether(testEntity, 10, reason: 'event_test');

        // Process to trigger broadcast
        expect(
          () => aetherSystem.processEntity(testEntity, 1.0),
          returnsNormally,
        );

        // The broadcast is currently done via print statement
        // In future sprints, this would fire proper system events
      });
    });

    group('T2.9.5: System Integration', () {
      test('should process multiple requests in sequence', () {
        // Process entity first to ensure sync happens, then capture initial value
        aetherSystem.processEntity(testEntity, 1.0);
        final initialAether = aetherComponent.currentAether;

        // Queue multiple requests
        aetherSystem.requestAddAether(testEntity, 20, reason: 'first');
        aetherSystem.requestConsumeAether(testEntity, 10, reason: 'second');
        aetherSystem.requestSetMaxAether(testEntity, 120, reason: 'third');

        // Process all requests
        aetherSystem.processEntity(testEntity, 1.0);

        // Verify all operations were applied
        expect(aetherComponent.currentAether, equals(initialAether + 20 - 10));
        expect(aetherComponent.maxAether, equals(120));
      });
      test('should handle system processing with multiple entities', () {
        // Create another entity with AetherComponent
        final entity2 = Player(position: Vector2.zero());
        final aetherComponent2 = AetherComponent(
          maxAether: 80,
          currentAether: 40,
          aetherRegenRate: 3,
        );
        entity2.add(aetherComponent2);

        // Add requests for both entities
        aetherSystem.requestAddAether(testEntity, 15, reason: 'entity1');
        aetherSystem.requestAddAether(entity2, 25, reason: 'entity2');

        // Process both entities
        aetherSystem.processEntity(testEntity, 1.0);
        aetherSystem.processEntity(entity2, 1.0);

        // Verify each entity was processed correctly
        expect(aetherComponent.currentAether, equals(65)); // 50 + 15
        expect(aetherComponent2.currentAether, equals(65)); // 40 + 25
      });

      test('should integrate with system processing loop', () {
        // Test the system's processSystem method
        expect(() => aetherSystem.processSystem(1.0), returnsNormally);

        // Verify system state tracking
        expect(aetherSystem.environmentalAetherActive, isFalse);
        expect(aetherSystem.aetherMultiplier, equals(1.0));
        expect(aetherSystem.activeEffectsCount, equals(0));
      });
    });

    group('Configuration and State Management', () {
      test('should allow configuration of global multipliers', () {
        aetherSystem.setAetherMultiplier(1.5);
        expect(aetherSystem.aetherMultiplier, equals(1.5));
      });

      test('should allow configuration of environmental Aether', () {
        aetherSystem.setEnvironmentalAether(0.8, active: true);
        expect(aetherSystem.environmentalAetherLevel, equals(0.8));
        expect(aetherSystem.environmentalAetherActive, isTrue);
      });

      test('should track player entity properly', () {
        // System should track player entity when added
        aetherSystem.onEntityAdded(player);

        // Process the player entity
        expect(() => aetherSystem.processEntity(player, 1.0), returnsNormally);

        // Remove player entity
        aetherSystem.onEntityRemoved(player);
        expect(() => aetherSystem.processEntity(player, 1.0), returnsNormally);
      });
    });
  });
}

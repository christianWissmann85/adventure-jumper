// filepath: test/player_stats_integration_test.dart

import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_stats.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.7: PlayerStats Integration Tests - Player Entity Integration', () {
    late Player player;
    // late PlayerStats stats; // Unused
    late PlayerEventBus eventBus;
    List<PlayerEvent> capturedEvents = [];

    setUp(() async {
      player = Player(position: Vector2.zero());
      await player.onLoad();

      // stats = player.stats; // Unused

      // Set up event capture for testing event system integration
      eventBus = PlayerEventBus.instance;
      capturedEvents.clear();

      // Capture all events for verification
      eventBus.addListener((event) {
        capturedEvents.add(event);
      });
    });

    tearDown(() {
      capturedEvents.clear();
      eventBus.clearListeners();
    });

    group('Player-PlayerStats Integration', () {
      test('should have PlayerStats properly integrated in Player entity', () {
        expect(player.stats, isNotNull);
        expect(player.stats, isA<PlayerStats>());
        expect(player.stats.currentHealth, equals(100));
        expect(player.stats.isAlive, isTrue);
      });

      test('should forward damage calls to PlayerStats', () {
        player.takeDamage(25);

        expect(player.stats.currentHealth, equals(75));
        expect(player.isAlive, isTrue);

        // Verify events were fired through the integration
        expect(
          capturedEvents.any((e) => e is PlayerHealthChangedEvent),
          isTrue,
        );
      });

      test('should forward healing calls to PlayerStats', () {
        player.takeDamage(50); // Damage first
        capturedEvents.clear();

        player.heal(25);

        expect(player.stats.currentHealth, equals(75));
        expect(
          capturedEvents.any((e) => e is PlayerHealthChangedEvent),
          isTrue,
        );
      });

      test(
          'should maintain alive status consistency between Player and PlayerStats',
          () {
        expect(player.isAlive, equals(player.stats.isAlive));

        player.takeDamage(200); // Kill player

        expect(player.isAlive, equals(player.stats.isAlive));
        expect(player.isAlive, isFalse);
      });

      test('should allow access to position through Player entity', () {
        expect(player.playerPosition, equals(Vector2.zero()));

        player.position.setValues(100, 200);
        expect(player.playerPosition, equals(Vector2(100, 200)));
      });
    });

    group('Event System Integration with Player Entity', () {
      test('should fire events when Player methods are called', () {
        player.takeDamage(30);
        player.heal(10);

        // Should have events for both damage and healing
        final healthEvents =
            capturedEvents.whereType<PlayerHealthChangedEvent>().toList();
        expect(healthEvents.length, equals(2));

        expect(healthEvents[0].changeReason, equals('damage'));
        expect(healthEvents[1].changeReason, equals('heal'));
      });

      test('should maintain event data integrity through Player integration',
          () {
        player.takeDamage(40);

        final healthEvent =
            capturedEvents.firstWhere((e) => e is PlayerHealthChangedEvent)
                as PlayerHealthChangedEvent;

        expect(healthEvent.oldHealth, equals(100));
        expect(healthEvent.newHealth, equals(60));
        expect(healthEvent.maxHealth, equals(100));
        expect(healthEvent.changeAmount, equals(-40));
        expect(healthEvent.timestamp, greaterThan(0));
      });
    });

    group('Component Integration Tests', () {
      test('should have all required components properly initialized', () {
        expect(player.physics, isNotNull);
        expect(player.input, isNotNull);
        expect(player.controller, isNotNull);
        expect(player.animator, isNotNull);
        expect(player.health, isNotNull);
        expect(player.aether, isNotNull);
        expect(player.stats, isNotNull);
      });

      test('should handle complex stat interactions through Player interface',
          () {
        // Simulate complex gameplay through Player interface
        player.takeDamage(25); // Through Player
        player.stats.useEnergy(30); // Direct to stats
        player.stats.useAether(20); // Direct to stats
        player.heal(15); // Through Player
        player.stats.gainExperience(75); // Direct to stats

        // Verify all changes were applied correctly
        expect(player.stats.currentHealth, equals(90)); // 100 - 25 + 15
        expect(player.stats.currentEnergy, equals(70)); // 100 - 30
        expect(player.stats.currentAether, equals(80)); // 100 - 20
        expect(player.stats.experience, equals(75));

        // Should have fired appropriate events
        expect(
          capturedEvents.any((e) => e is PlayerHealthChangedEvent),
          isTrue,
        );
        expect(
          capturedEvents.any((e) => e is PlayerEnergyChangedEvent),
          isTrue,
        );
        expect(
          capturedEvents.any((e) => e is PlayerAetherChangedEvent),
          isTrue,
        );
        expect(
          capturedEvents.any((e) => e is PlayerExperienceGainedEvent),
          isTrue,
        );
      });
    });

    group('Ability Integration Tests', () {
      test('should unlock abilities and integrate with player progression', () {
        // Progress player to unlock abilities
        player.stats.gainExperience(100); // Level 2
        player.stats.collectAetherShard(10);

        expect(player.stats.canDoubleJump, isTrue);
        expect(player.stats.level, equals(2));

        // Verify level up increased stats
        expect(player.stats.maxHealth, equals(110));
        expect(player.stats.maxEnergy, equals(105));
        expect(player.stats.maxAether, equals(105));
      });

      test('should handle ability resource consumption', () {
        // Test energy consumption for abilities
        final canUseAbility = player.stats.useEnergy(25);
        expect(canUseAbility, isTrue);
        expect(player.stats.currentEnergy, equals(75));

        // Test Aether consumption
        final canUseAetherAbility = player.stats.useAether(30);
        expect(canUseAetherAbility, isTrue);
        expect(player.stats.currentAether, equals(70));

        // Verify resource checking methods work
        expect(player.stats.canUseEnergy(80), isFalse);
        expect(player.stats.canUseAether(80), isFalse);
        expect(player.stats.canUseEnergy(50), isTrue);
        expect(player.stats.canUseAether(50), isTrue);
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle multiple rapid stat changes efficiently', () {
        final startTime = DateTime.now().millisecondsSinceEpoch;

        // Perform many operations
        for (int i = 0; i < 100; i++) {
          player.takeDamage(1);
          player.heal(0.5);
          player.stats.useEnergy(1);
          player.stats.restoreEnergy(0.8);
          player.stats.useAether(1);
          player.stats.restoreAether(1);
        }

        final endTime = DateTime.now().millisecondsSinceEpoch;
        final duration = endTime - startTime;

        // Should complete quickly (less than 100ms for 600 operations)
        expect(duration, lessThan(100));

        // Stats should still be valid
        expect(player.stats.currentHealth, greaterThanOrEqualTo(0));
        expect(player.stats.currentEnergy, greaterThanOrEqualTo(0));
        expect(player.stats.currentAether, greaterThanOrEqualTo(0));
      });

      test('should not leak memory through event system', () {
        // Create many events
        for (int i = 0; i < 50; i++) {
          player.takeDamage(1);
          player.heal(1);
        }

        // Clear captured events to simulate normal cleanup
        capturedEvents.clear();

        // Should still function normally
        player.takeDamage(10);
        expect(player.stats.currentHealth, lessThan(100));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle invalid stat operations gracefully', () {
        // Try invalid operations - should not crash or corrupt state
        player.takeDamage(-50); // Negative damage
        player.heal(-25); // Negative healing
        player.stats.useEnergy(-30); // Negative energy use
        player.stats.restoreEnergy(-20); // Negative energy restore
        player.stats.useAether(-15); // Negative Aether use
        player.stats.gainExperience(-100); // Negative experience

        // Stats should remain valid
        expect(player.stats.currentHealth, equals(100));
        expect(player.stats.currentEnergy, equals(100));
        expect(player.stats.currentAether, equals(100));
        expect(player.stats.experience, equals(0));
      });

      test('should handle extreme values correctly', () {
        // Test with very large values
        player.takeDamage(999999); // Extreme damage
        expect(player.stats.currentHealth, equals(0)); // Clamped to 0

        player.heal(999999); // Extreme healing
        expect(player.stats.currentHealth, equals(100)); // Clamped to max

        // Test Aether system with extreme values
        player.stats.setMaxAether(999999);
        expect(player.stats.maxAether, equals(999999));

        player.stats.collectAetherShard(999999);
        expect(player.stats.aetherShards, equals(999999));
        expect(player.stats.currentAether, equals(999999)); // Should equal max
      });

      test('should maintain consistency during concurrent operations', () {
        // Simulate concurrent-like operations
        final initialHealth = player.stats.currentHealth;

        // Rapid alternating operations
        for (int i = 0; i < 10; i++) {
          player.takeDamage(10);
          player.heal(10);
        }

        // Should end up close to initial value
        expect(player.stats.currentHealth, equals(initialHealth));
      });
    });

    group('Real Gameplay Scenario Tests', () {
      test('should handle typical combat scenario', () {
        // Simulate a combat encounter
        player.stats.useEnergy(20); // Use movement ability
        player.takeDamage(35); // Take damage from enemy
        player.stats.useAether(15); // Use special ability
        player.takeDamage(20); // Take more damage
        player.stats.useEnergy(25); // Use defensive ability
        player.heal(10); // Use healing item
        player.stats.gainExperience(50); // Defeat enemy

        // Verify final state
        expect(player.stats.currentHealth, equals(55)); // 100 - 35 - 20 + 10
        expect(player.stats.currentEnergy, equals(55)); // 100 - 20 - 25
        expect(player.stats.currentAether, equals(85)); // 100 - 15
        expect(player.stats.experience, equals(50));

        // Should still be alive and functional
        expect(player.isAlive, isTrue);
        expect(player.stats.canUseEnergy(30), isTrue);
        expect(player.stats.canUseAether(50), isTrue);
      });

      test('should handle progression scenario', () {
        // Simulate progression through levels
        player.stats.gainExperience(100); // Level 2
        final level2MaxHealth = player.stats.maxHealth;

        player.stats.collectAetherShard(15); // Get some shards
        expect(player.stats.canDoubleJump, isTrue); // Should unlock

        player.stats.gainExperience(120); // Level 3
        expect(player.stats.level, equals(3));
        expect(player.stats.maxHealth, greaterThan(level2MaxHealth));

        player.stats.collectAetherShard(15); // Total 30 shards
        expect(player.stats.canDash, isTrue); // Should unlock

        // Verify all events were fired
        expect(
          capturedEvents.whereType<PlayerLevelUpEvent>().length,
          equals(2),
        );
        expect(
          capturedEvents.whereType<PlayerAetherChangedEvent>().length,
          greaterThan(0),
        );
      });

      test('should handle near-death and recovery scenario', () {
        // Nearly kill player
        player.takeDamage(95); // 5 health left
        expect(player.stats.isHealthLow(), isTrue);
        expect(player.isAlive, isTrue);

        // Use remaining resources
        player.stats.useEnergy(90); // Almost no energy
        player.stats.useAether(80); // Low Aether

        expect(player.stats.isEnergyLow(), isTrue);
        expect(player.stats.isAetherLow(), isTrue);

        // Recovery
        player.heal(50); // Partial recovery
        player.stats.restoreEnergy(60);
        player.stats.restoreAether(40);

        // Should be back to reasonable state
        expect(player.stats.currentHealth, equals(55));
        expect(player.stats.isHealthLow(), isFalse);
        expect(player.stats.isEnergyLow(), isFalse);
        expect(player.stats.isAetherLow(), isFalse);
      });
    });
  });
}

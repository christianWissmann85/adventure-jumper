// filepath: test/player_stats_test.dart

import 'package:adventure_jumper/src/events/player_events.dart';
import 'package:adventure_jumper/src/player/player_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.7: PlayerStats Tests - Aether System Foundation & Player Stats',
      () {
    late PlayerStats stats;
    late PlayerEventBus eventBus;
    List<PlayerEvent> capturedEvents = [];

    setUp(() async {
      stats = PlayerStats();
      await stats.onLoad();

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
      // Clear all listeners to prevent test interference
      eventBus.clearListeners();
    });

    group('Initialization and Default Values', () {
      test('should initialize with correct default values', () {
        expect(stats.currentHealth, equals(100));
        expect(stats.maxHealth, equals(100));
        expect(stats.currentEnergy, equals(100));
        expect(stats.maxEnergy, equals(100));
        expect(stats.currentAether, equals(100));
        expect(stats.maxAether, equals(100));
        expect(stats.aetherShards, equals(0));
        expect(stats.level, equals(1));
        expect(stats.experience, equals(0));
        expect(stats.experienceToNextLevel, equals(100));
        expect(stats.canDoubleJump, isFalse);
        expect(stats.canDash, isFalse);
        expect(stats.canWallJump, isFalse);
      });

      test('should have valid percentage calculations', () {
        expect(stats.healthPercentage, equals(1.0));
        expect(stats.energyPercentage, equals(1.0));
        expect(stats.aetherPercentage, equals(1.0));
        expect(stats.experienceProgress, equals(0.0));
      });

      test('should correctly report alive status', () {
        expect(stats.isAlive, isTrue);
        expect(stats.hasAether, isTrue);
        expect(stats.isAetherFull, isTrue);
      });
    });

    group('Health System Tests', () {
      test('should handle damage correctly', () {
        stats.takeDamage(25);

        expect(stats.currentHealth, equals(75));
        expect(stats.healthPercentage, equals(0.75));
        expect(stats.isAlive, isTrue);

        // Verify events were fired
        expect(
          capturedEvents.length,
          equals(2),
        ); // health and stat changed events
        expect(
          capturedEvents.any((e) => e is PlayerHealthChangedEvent),
          isTrue,
        );
        expect(capturedEvents.any((e) => e is PlayerStatChangedEvent), isTrue);
      });

      test('should prevent health from going below zero', () {
        stats.takeDamage(150); // More than max health

        expect(stats.currentHealth, equals(0));
        expect(stats.isAlive, isFalse);
      });

      test('should handle healing correctly', () {
        stats.takeDamage(50); // Health at 50
        capturedEvents.clear();

        stats.heal(25);

        expect(stats.currentHealth, equals(75));
        expect(
          capturedEvents.length,
          equals(2),
        ); // health and stat changed events

        // Verify event data
        final healthEvent =
            capturedEvents.firstWhere((e) => e is PlayerHealthChangedEvent)
                as PlayerHealthChangedEvent;
        expect(healthEvent.changeAmount, equals(25));
        expect(healthEvent.changeReason, equals('heal'));
      });

      test('should prevent overhealing', () {
        stats.heal(50); // Should not exceed max health

        expect(stats.currentHealth, equals(100)); // Still at max
        expect(stats.healthPercentage, equals(1.0));
      });

      test('should ignore negative damage and healing', () {
        final initialHealth = stats.currentHealth;

        stats.takeDamage(-10);
        stats.heal(-10);

        expect(stats.currentHealth, equals(initialHealth));
      });

      test('should correctly identify low health', () {
        stats.takeDamage(80); // Health at 20%
        expect(stats.isHealthLow(), isTrue);

        stats.heal(10); // Health at 30%
        expect(stats.isHealthLow(), isFalse);
      });
    });

    group('Energy System Tests', () {
      test('should use energy correctly', () {
        final success = stats.useEnergy(30);

        expect(success, isTrue);
        expect(stats.currentEnergy, equals(70));
        expect(stats.energyPercentage, equals(0.7));

        // Verify events were fired
        expect(
          capturedEvents.any((e) => e is PlayerEnergyChangedEvent),
          isTrue,
        );
      });

      test('should prevent using more energy than available', () {
        final success = stats.useEnergy(150);

        expect(success, isFalse);
        expect(stats.currentEnergy, equals(100)); // Unchanged
      });

      test('should restore energy correctly', () {
        stats.useEnergy(50); // Energy at 50
        capturedEvents.clear();

        stats.restoreEnergy(25);

        expect(stats.currentEnergy, equals(75));

        // Verify event data
        final energyEvent =
            capturedEvents.firstWhere((e) => e is PlayerEnergyChangedEvent)
                as PlayerEnergyChangedEvent;
        expect(energyEvent.changeAmount, equals(25));
        expect(energyEvent.changeReason, equals('restoration'));
      });

      test('should check energy availability correctly', () {
        expect(stats.canUseEnergy(50), isTrue);
        expect(stats.canUseEnergy(150), isFalse);

        stats.useEnergy(80); // Energy at 20
        expect(stats.canUseEnergy(30), isFalse);
        expect(stats.canUseEnergy(15), isTrue);
      });

      test('should correctly identify low energy', () {
        stats.useEnergy(80); // Energy at 20%
        expect(stats.isEnergyLow(), isTrue);
      });
    });

    group('Aether System Tests', () {
      test('should use Aether correctly', () {
        final success = stats.useAether(25);

        expect(success, isTrue);
        expect(stats.currentAether, equals(75));
        expect(stats.aetherPercentage, equals(0.75));

        // Verify events were fired
        expect(
          capturedEvents.any((e) => e is PlayerAetherChangedEvent),
          isTrue,
        );
      });

      test('should prevent using more Aether than available', () {
        final success = stats.useAether(150);

        expect(success, isFalse);
        expect(stats.currentAether, equals(100)); // Unchanged
      });

      test('should restore Aether correctly', () {
        stats.useAether(50); // Aether at 50
        capturedEvents.clear();

        stats.restoreAether(30);

        expect(stats.currentAether, equals(80));

        // Verify event data
        final aetherEvent =
            capturedEvents.firstWhere((e) => e is PlayerAetherChangedEvent)
                as PlayerAetherChangedEvent;
        expect(aetherEvent.changeAmount, equals(30));
        expect(aetherEvent.changeReason, equals('restoration'));
      });

      test('should collect Aether shards correctly', () {
        stats.useAether(20); // Current Aether at 80
        capturedEvents.clear();

        stats.collectAetherShard(15);

        expect(stats.aetherShards, equals(15));
        expect(stats.currentAether, equals(95)); // 80 + 15

        // Verify event data
        final aetherEvent =
            capturedEvents.firstWhere((e) => e is PlayerAetherChangedEvent)
                as PlayerAetherChangedEvent;
        expect(aetherEvent.changeReason, equals('collect_shard'));
      });

      test('should prevent Aether overflow when collecting shards', () {
        stats.collectAetherShard(10); // Should cap at max

        expect(stats.currentAether, equals(100)); // Still at max
        expect(stats.aetherShards, equals(10));
        expect(stats.isAetherFull, isTrue);
      });

      test('should check Aether availability correctly', () {
        expect(stats.canUseAether(50), isTrue);
        expect(stats.canUseAether(150), isFalse);

        stats.useAether(80); // Aether at 20
        expect(stats.canUseAether(30), isFalse);
        expect(stats.canUseAether(15), isTrue);
      });

      test('should correctly identify low Aether', () {
        stats.useAether(80); // Aether at 20%
        expect(stats.isAetherLow(), isTrue);
      });
    });

    group('Experience and Leveling System Tests', () {
      test('should gain experience correctly', () {
        stats.gainExperience(50);

        expect(stats.experience, equals(50));
        expect(stats.experienceProgress, equals(0.5));

        // Verify event was fired
        expect(
          capturedEvents.any((e) => e is PlayerExperienceGainedEvent),
          isTrue,
        );
      });

      test('should level up when experience threshold is reached', () {
        stats.gainExperience(100); // Should trigger level up

        expect(stats.level, equals(2));
        expect(stats.experience, equals(0)); // Experience reset after level up
        expect(stats.experienceToNextLevel, equals(120)); // Increased by 20%

        // Verify level up event was fired
        expect(capturedEvents.any((e) => e is PlayerLevelUpEvent), isTrue);
      });

      test('should increase stats on level up', () {
        final initialMaxHealth = stats.maxHealth;
        final initialMaxEnergy = stats.maxEnergy;
        final initialMaxAether = stats.maxAether;

        stats.gainExperience(100); // Level up

        expect(stats.maxHealth, equals(initialMaxHealth + 10));
        expect(stats.maxEnergy, equals(initialMaxEnergy + 5));
        expect(stats.maxAether, equals(initialMaxAether + 5));

        // Should fully restore all stats on level up
        expect(stats.currentHealth, equals(stats.maxHealth));
        expect(stats.currentEnergy, equals(stats.maxEnergy));
        expect(stats.currentAether, equals(stats.maxAether));
      });

      test('should handle multiple level ups in one experience gain', () {
        stats.gainExperience(300); // Should level up multiple times

        expect(stats.level, greaterThan(2));

        // Should fire multiple level up events
        final levelUpEvents =
            capturedEvents.whereType<PlayerLevelUpEvent>().toList();
        expect(levelUpEvents.length, greaterThan(1));
      });

      test('should prevent negative experience gain', () {
        final initialExperience = stats.experience;

        stats.gainExperience(-50);

        expect(stats.experience, equals(initialExperience));
      });
    });

    group('Ability Unlock System Tests', () {
      test('should unlock double jump at level 2 with 10 shards', () {
        expect(stats.canDoubleJump, isFalse);

        // Get to level 2 with 10 shards
        stats.gainExperience(100); // Level 2
        stats.collectAetherShard(10);

        expect(stats.canDoubleJump, isTrue);
      });

      test('should unlock dash at level 3 with 25 shards', () {
        expect(stats.canDash, isFalse);

        // Get to level 3 with 25 shards
        stats.gainExperience(220); // Level 3
        stats.collectAetherShard(25);

        expect(stats.canDash, isTrue);
      });

      test('should unlock wall jump at level 5 with 50 shards', () {
        expect(stats.canWallJump, isFalse);

        // Get to level 5 with 50 shards - need significant experience
        for (int i = 0; i < 10; i++) {
          stats.gainExperience(1000);
        }
        stats.collectAetherShard(50);

        expect(stats.canWallJump, isTrue);
      });

      test('should not unlock abilities without sufficient level', () {
        stats.collectAetherShard(100); // Lots of shards but level 1

        expect(stats.canDoubleJump, isFalse);
        expect(stats.canDash, isFalse);
        expect(stats.canWallJump, isFalse);
      });

      test('should not unlock abilities without sufficient shards', () {
        // Get to high level but no shards
        for (int i = 0; i < 10; i++) {
          stats.gainExperience(1000);
        }

        expect(stats.canDoubleJump, isFalse);
        expect(stats.canDash, isFalse);
        expect(stats.canWallJump, isFalse);
      });
    });

    group('Stat Validation and Bounds Checking Tests', () {
      test('should set maximum health with validation', () {
        stats.setMaxHealth(150);

        expect(stats.maxHealth, equals(150));
        expect(stats.currentHealth, equals(150)); // Should maintain percentage
      });

      test('should prevent setting health below minimum', () {
        stats.setMaxHealth(0); // Invalid

        expect(stats.maxHealth, equals(100)); // Should remain unchanged
      });

      test('should set maximum energy with validation', () {
        stats.useEnergy(50); // Energy at 50%
        stats.setMaxEnergy(200);

        expect(stats.maxEnergy, equals(200));
        expect(stats.currentEnergy, equals(100)); // 50% of new max
      });

      test('should set maximum Aether with validation', () {
        stats.useAether(30); // Aether at 70%
        stats.setMaxAether(200);

        expect(stats.maxAether, equals(200));
        expect(stats.currentAether, equals(140)); // 70% of new max
      });

      test('should maintain stat bounds during validation', () async {
        // Create stats with invalid values and load
        final testStats = PlayerStats();
        // Manually set invalid values before onLoad
        await testStats.onLoad();

        // All values should be valid after validation
        expect(testStats.currentHealth, greaterThanOrEqualTo(0));
        expect(testStats.currentHealth, lessThanOrEqualTo(testStats.maxHealth));
        expect(testStats.maxHealth, greaterThanOrEqualTo(1));
        expect(testStats.level, greaterThanOrEqualTo(1));
        expect(testStats.experience, greaterThanOrEqualTo(0));
      });
    });

    group('Event System Integration Tests', () {
      test('should fire correct events for damage', () {
        stats.takeDamage(25);

        expect(capturedEvents.length, equals(2));

        final healthEvent =
            capturedEvents.firstWhere((e) => e is PlayerHealthChangedEvent)
                as PlayerHealthChangedEvent;
        expect(healthEvent.oldHealth, equals(100));
        expect(healthEvent.newHealth, equals(75));
        expect(healthEvent.changeAmount, equals(-25));
        expect(healthEvent.changeReason, equals('damage'));

        final statEvent =
            capturedEvents.firstWhere((e) => e is PlayerStatChangedEvent)
                as PlayerStatChangedEvent;
        expect(statEvent.statType, equals('health'));
        expect(statEvent.oldValue, equals(100));
        expect(statEvent.newValue, equals(75));
      });

      test('should fire events for all stat changes', () {
        stats.takeDamage(10);
        stats.useEnergy(15);
        stats.useAether(20);
        stats.gainExperience(25);

        // Should have multiple events of different types
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
        expect(capturedEvents.any((e) => e is PlayerStatChangedEvent), isTrue);
      });

      test('should fire level up event with correct data', () {
        stats.gainExperience(100);

        final levelUpEvent = capturedEvents
            .firstWhere((e) => e is PlayerLevelUpEvent) as PlayerLevelUpEvent;
        expect(levelUpEvent.oldLevel, equals(1));
        expect(levelUpEvent.newLevel, equals(2));
        expect(levelUpEvent.healthIncrease, equals(10));
        expect(levelUpEvent.energyIncrease, equals(5));
      });

      test('should provide timestamp for all events', () {
        stats.takeDamage(10);

        for (final event in capturedEvents) {
          expect(event.timestamp, greaterThan(0));
        }
      });
    });

    group('Integration and Edge Case Tests', () {
      test('should handle complex stat interactions', () {
        // Simulate complex gameplay scenario
        stats.takeDamage(30); // Take damage
        stats.useEnergy(25); // Use ability
        stats.useAether(15); // Use Aether ability
        stats.gainExperience(50); // Gain experience
        stats.collectAetherShard(5); // Collect shard
        stats.heal(10); // Heal slightly

        // Verify final state is consistent
        expect(stats.currentHealth, equals(80)); // 100 - 30 + 10
        expect(stats.currentEnergy, equals(75)); // 100 - 25
        expect(stats.currentAether, equals(90)); // 100 - 15 + 5
        expect(stats.experience, equals(50));
        expect(stats.aetherShards, equals(5));

        // All percentages should be valid
        expect(stats.healthPercentage, greaterThanOrEqualTo(0));
        expect(stats.healthPercentage, lessThanOrEqualTo(1));
        expect(stats.energyPercentage, greaterThanOrEqualTo(0));
        expect(stats.energyPercentage, lessThanOrEqualTo(1));
        expect(stats.aetherPercentage, greaterThanOrEqualTo(0));
        expect(stats.aetherPercentage, lessThanOrEqualTo(1));
      });

      test('should handle rapid stat changes without issues', () {
        // Rapid fire many stat changes
        for (int i = 0; i < 10; i++) {
          stats.takeDamage(5);
          stats.heal(3);
          stats.useEnergy(10);
          stats.restoreEnergy(8);
          stats.useAether(5);
          stats.restoreAether(3);
        }

        // Stats should still be valid
        expect(stats.currentHealth, greaterThanOrEqualTo(0));
        expect(stats.currentHealth, lessThanOrEqualTo(stats.maxHealth));
        expect(stats.currentEnergy, greaterThanOrEqualTo(0));
        expect(stats.currentEnergy, lessThanOrEqualTo(stats.maxEnergy));
        expect(stats.currentAether, greaterThanOrEqualTo(0));
        expect(stats.currentAether, lessThanOrEqualTo(stats.maxAether));
      });

      test('should maintain consistency after death and resurrection scenario',
          () {
        stats.takeDamage(200); // Kill player
        expect(stats.isAlive, isFalse);

        stats.heal(100); // Resurrect
        expect(stats.isAlive, isTrue);
        expect(stats.currentHealth, equals(100));
      });
    });
  });
}

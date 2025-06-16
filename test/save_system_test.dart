import 'package:adventure_jumper/src/save/progress_tracker.dart';
import 'package:adventure_jumper/src/save/save_data.dart';
import 'package:adventure_jumper/src/save/save_manager.dart';
import 'package:adventure_jumper/src/save/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Initialize Flutter binding for tests that need platform services
  TestWidgetsFlutterBinding.ensureInitialized();
  group('T3.10: Basic Save System Tests', () {
    group('T3.10.1: JSON Serialization Tests', () {
      test('SaveData should serialize to and from JSON', () {
        // Create a basic SaveData instance
        final saveData = SaveData(
          slotId: 0,
          playerLevel: 5,
          experience: 1500,
          currentBiome: 'grasslands',
          currentLevel: 'grasslands_1',
        );

        // Test serialization to JSON
        final json = saveData.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['slotId'], equals(0));
        expect(json['playerLevel'], equals(5));
        expect(json['experience'], equals(1500));
        expect(json['currentBiome'], equals('grasslands'));
        expect(json['currentLevel'], equals('grasslands_1'));

        // Test deserialization from JSON
        final deserializedSaveData = SaveData.fromJson(json);
        expect(deserializedSaveData.slotId, equals(saveData.slotId));
        expect(deserializedSaveData.playerLevel, equals(saveData.playerLevel));
        expect(deserializedSaveData.experience, equals(saveData.experience));
        expect(
          deserializedSaveData.currentBiome,
          equals(saveData.currentBiome),
        );
        expect(
          deserializedSaveData.currentLevel,
          equals(saveData.currentLevel),
        );
      });

      test('Settings should serialize to and from JSON', () {
        // Create basic Settings instance
        final settings = Settings(
          masterVolume: 0.8,
          musicVolume: 0.7,
          sfxVolume: 0.9,
          fullscreen: true,
        );

        // Test serialization
        final json = settings.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['masterVolume'], equals(0.8));
        expect(json['musicVolume'], equals(0.7));
        expect(json['sfxVolume'], equals(0.9));
        expect(json['fullscreen'], equals(true)); // Test deserialization
        final deserializedSettings = Settings.fromJson(json);
        expect(
          deserializedSettings.masterVolume,
          equals(settings.masterVolume),
        );
        expect(deserializedSettings.musicVolume, equals(settings.musicVolume));
        expect(deserializedSettings.sfxVolume, equals(settings.sfxVolume));
        expect(deserializedSettings.fullscreen, equals(settings.fullscreen));
      });

      test('ProgressTracker should serialize to and from JSON', () {
        // Create basic ProgressTracker instance
        final progressTracker = ProgressTracker(
          totalPlaytime: 3600,
          totalJumps: 100,
          totalDeaths: 5,
          totalLevelsCompleted: 3,
        );

        // Test serialization
        final json = progressTracker.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['totalPlaytime'], equals(3600));
        expect(json['totalJumps'], equals(100));
        expect(json['totalDeaths'], equals(5));
        expect(json['totalLevelsCompleted'], equals(3));

        // Test deserialization
        final deserializedTracker = ProgressTracker.fromJson(json);
        expect(
          deserializedTracker.totalPlaytime,
          equals(progressTracker.totalPlaytime),
        );
        expect(
          deserializedTracker.totalJumps,
          equals(progressTracker.totalJumps),
        );
        expect(
          deserializedTracker.totalDeaths,
          equals(progressTracker.totalDeaths),
        );
        expect(
          deserializedTracker.totalLevelsCompleted,
          equals(progressTracker.totalLevelsCompleted),
        );
      });
    });

    group('T3.10.2: SaveManager Basic Functionality', () {
      test('SaveManager should be a singleton', () {
        final instance1 = SaveManager.instance;
        final instance2 = SaveManager.instance;
        expect(identical(instance1, instance2), isTrue);
      });

      test('SaveManager should have access to save data components', () {
        final saveManager = SaveManager.instance;

        // These getters should exist and not throw errors
        expect(() => saveManager.currentSave, returnsNormally);
        expect(() => saveManager.settings, returnsNormally);
        expect(() => saveManager.progressTracker, returnsNormally);
      });
    });
    group('T3.10.3: SaveManager Structure Tests', () {
      test('SaveManager should be properly structured', () {
        final saveManager = SaveManager.instance;

        // Test that SaveManager has the expected structure
        expect(saveManager, isNotNull);
        expect(saveManager.runtimeType.toString(), equals('SaveManager'));
      });

      test('SaveManager should have auto-save properties', () {
        final saveManager = SaveManager.instance;

        // Test auto-save enabled getter/setter exist and work
        expect(saveManager.autoSaveEnabled, isA<bool>());

        final originalValue = saveManager.autoSaveEnabled;
        saveManager.autoSaveEnabled = !originalValue;
        expect(saveManager.autoSaveEnabled, equals(!originalValue));

        // Restore original value
        saveManager.autoSaveEnabled = originalValue;
      });

      test('SaveManager should provide access to save components', () {
        final saveManager = SaveManager.instance;

        // These getters should exist and not throw errors when accessing
        expect(() => saveManager.currentSave, returnsNormally);
        expect(() => saveManager.settings, returnsNormally);
        expect(() => saveManager.progressTracker, returnsNormally);
      });
    });
    group('T3.10.4: Data Validation Tests', () {
      test('SaveData should validate data types correctly', () {
        // Test with invalid JSON data
        final invalidJson = <String, dynamic>{
          'slotId': 'invalid', // Should be int
          'playerLevel': -5, // Invalid negative level
          'experience': 'invalid', // Should be int
          'currentBiome': null, // Should be string
          'currentLevel': '', // Empty string
        };

        // SaveData should throw an error for invalid data types
        expect(() => SaveData.fromJson(invalidJson), throwsA(isA<TypeError>()));
      });

      test('Settings should handle boundary values', () {
        // Test boundary values for Settings
        final boundarySettings = Settings(
          masterVolume: 0.0, // Minimum
          musicVolume: 1.0, // Maximum
          sfxVolume: 0.5, // Middle
          fullscreen: false,
        );

        final json = boundarySettings.toJson();
        final restored = Settings.fromJson(json);

        expect(restored.masterVolume, equals(0.0));
        expect(restored.musicVolume, equals(1.0));
        expect(restored.sfxVolume, equals(0.5));
        expect(restored.fullscreen, equals(false));
      });

      test('ProgressTracker should handle large numbers', () {
        // Test with large values
        final tracker = ProgressTracker(
          totalPlaytime: 999999999, // Large playtime
          totalJumps: 1000000, // Million jumps
          totalDeaths: 0, // Perfect run
          totalLevelsCompleted: 999, // Many levels
        );

        final json = tracker.toJson();
        final restored = ProgressTracker.fromJson(json);

        expect(restored.totalPlaytime, equals(999999999));
        expect(restored.totalJumps, equals(1000000));
        expect(restored.totalDeaths, equals(0));
        expect(restored.totalLevelsCompleted, equals(999));
      });
    });

    group('T3.10.5: PlayerRecord Functionality Tests', () {
      test('PlayerRecord should serialize correctly', () {
        final record = PlayerRecord(
          category: 'fastest_completion',
          value: 120.5,
          context: {'level': 'tutorial_1', 'deaths': 0},
        );

        final json = record.toJson();
        expect(json['category'], equals('fastest_completion'));
        expect(json['value'], equals(120.5));
        expect(json['context']['level'], equals('tutorial_1'));
        expect(json['context']['deaths'], equals(0));

        final restored = PlayerRecord.fromJson(json);
        expect(restored.category, equals(record.category));
        expect(restored.value, equals(record.value));
        expect(restored.context['level'], equals('tutorial_1'));
      });

      test('PlayerRecord should compare values correctly', () {
        final speedRecord1 = PlayerRecord(
          category: 'fastest_completion',
          value: 120,
        );

        final speedRecord2 = PlayerRecord(
          category: 'fastest_completion',
          value: 150,
        );

        final scoreRecord1 = PlayerRecord(
          category: 'high_score',
          value: 1000,
        );

        final scoreRecord2 = PlayerRecord(
          category: 'high_score',
          value: 1500,
        );

        // For time-based records, lower is better
        expect(speedRecord1.isBetterThan(speedRecord2), isTrue);
        expect(speedRecord2.isBetterThan(speedRecord1), isFalse);

        // For score-based records, higher is better
        expect(scoreRecord2.isBetterThan(scoreRecord1), isTrue);
        expect(scoreRecord1.isBetterThan(scoreRecord2), isFalse);
      });
    });
    group('T3.10.6: ProgressTracker Advanced Features', () {
      test('ProgressTracker should record personal bests correctly', () {
        final tracker = ProgressTracker();

        // Create a personal best record
        final record = PlayerRecord(
          category: 'fastest_completion',
          value: 120,
          context: {'level': 'tutorial_1', 'deaths': 0},
        );

        // Record the personal best
        tracker.recordPersonalBest('tutorial_1', record);

        // Verify it was recorded
        expect(tracker.personalBests.containsKey('tutorial_1'), isTrue);
        expect(tracker.personalBests['tutorial_1']?.value, equals(120));
        expect(
          tracker.personalBests['tutorial_1']?.category,
          equals('fastest_completion'),
        );
      });

      test('ProgressTracker should update global statistics correctly', () {
        final tracker = ProgressTracker();

        // Update global statistics directly
        tracker.globalStatistics['total_jumps'] = 1000;
        tracker.globalStatistics['total_deaths'] = 50;
        tracker.globalStatistics['total_coins_collected'] = 250;

        expect(tracker.globalStatistics['total_jumps'], equals(1000));
        expect(tracker.globalStatistics['total_deaths'], equals(50));
        expect(tracker.globalStatistics['total_coins_collected'], equals(250));
      });

      test('ProgressTracker should handle achievements', () {
        final tracker = ProgressTracker();

        // Set some achievements
        tracker.globalAchievements['first_jump'] = true;
        tracker.globalAchievements['level_complete'] = true;
        tracker.globalAchievements['secret_finder'] = false;

        expect(tracker.globalAchievements['first_jump'], isTrue);
        expect(tracker.globalAchievements['level_complete'], isTrue);
        expect(tracker.globalAchievements['secret_finder'], isFalse);
      });

      test('ProgressTracker should serialize complex data', () {
        final tracker = ProgressTracker(
          totalPlaytime: 7200,
          totalJumps: 500,
          totalDeaths: 10,
          totalLevelsCompleted: 5,
        );

        // Add some complex data
        tracker.globalAchievements['test_achievement'] = true;
        tracker.globalStatistics['test_stat'] = 999;

        final record = PlayerRecord(
          category: 'fastest_completion',
          value: 180,
          context: {'level': 'grasslands_1'},
        );
        tracker.recordPersonalBest('grasslands_1', record);

        // Serialize and deserialize
        final json = tracker.toJson();
        final restored = ProgressTracker.fromJson(json);

        // Verify basic properties
        expect(restored.totalPlaytime, equals(7200));
        expect(restored.totalJumps, equals(500));
        expect(restored.totalDeaths, equals(10));
        expect(restored.totalLevelsCompleted, equals(5));

        // Verify complex data
        expect(restored.globalAchievements['test_achievement'], isTrue);
        expect(restored.globalStatistics['test_stat'], equals(999));
        expect(restored.personalBests.containsKey('grasslands_1'), isTrue);
        expect(restored.personalBests['grasslands_1']?.value, equals(180));
      });
    });

    group('T3.10.7: Integration and Error Handling', () {
      test('All save components should work together', () {
        // Create a complete save scenario
        final saveData = SaveData(
          slotId: 1,
          playerLevel: 10,
          experience: 5000,
          currentBiome: 'crystal_caverns',
          currentLevel: 'crystal_caverns_1',
        );

        final settings = Settings(
          masterVolume: 0.8,
          musicVolume: 0.6,
          sfxVolume: 0.9,
          fullscreen: true,
        );

        final progressTracker = ProgressTracker(
          totalPlaytime: 14400, // 4 hours
          totalJumps: 2000,
          totalDeaths: 25,
          totalLevelsCompleted: 15,
        );

        // Test that all components serialize independently
        final saveJson = saveData.toJson();
        final settingsJson = settings.toJson();
        final progressJson = progressTracker.toJson();

        expect(saveJson, isA<Map<String, dynamic>>());
        expect(settingsJson, isA<Map<String, dynamic>>());
        expect(progressJson, isA<Map<String, dynamic>>());

        // Test that all components deserialize correctly
        final restoredSave = SaveData.fromJson(saveJson);
        final restoredSettings = Settings.fromJson(settingsJson);
        final restoredProgress = ProgressTracker.fromJson(progressJson);

        expect(restoredSave.slotId, equals(saveData.slotId));
        expect(restoredSettings.masterVolume, equals(settings.masterVolume));
        expect(restoredProgress.totalJumps, equals(progressTracker.totalJumps));
      });

      test('SaveManager singleton should maintain state', () {
        final manager1 = SaveManager.instance;
        final manager2 = SaveManager.instance;

        // Set a property on one instance
        manager1.autoSaveEnabled = false;

        // Verify the other instance sees the change
        expect(manager2.autoSaveEnabled, equals(false));

        // Reset for other tests
        manager1.autoSaveEnabled = true;
      });
    });
  });
}

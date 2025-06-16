// filepath: test/enhanced_save_data_test.dart
import 'package:adventure_jumper/src/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Enhanced SaveData Tests', () {
    late SaveData saveData;

    setUp(() {
      saveData = SaveData(slotId: 1);
    });

    group('T3.11.1: Player Progress Structure', () {
      test('should initialize with default player progress data', () {
        expect(saveData.playerLevel, equals(1));
        expect(saveData.experience, equals(0));
        expect(saveData.skillPoints, equals(0));
        expect(saveData.aetherShards, equals(0));
        expect(saveData.unlockedAbilities['doubleJump'], isFalse);
        expect(saveData.unlockedAbilities['dash'], isFalse);
        expect(saveData.unlockedAbilities['wallJump'], isFalse);
      });

      test('should update player stats from PlayerStats component', () {
        saveData.updateFromPlayerStats(
          currentHealth: 85.0,
          maxHealth: 120.0,
          currentEnergy: 60.0,
          maxEnergy: 80.0,
          currentAether: 75,
          maxAether: 100,
          aetherShardsCount: 25,
          level: 5,
          experience: 1500,
          canDoubleJump: true,
          canDash: true,
          canWallJump: false,
        );

        expect(saveData.playerLevel, equals(5));
        expect(saveData.experience, equals(1500));
        expect(saveData.aetherShards, equals(25));
        expect(saveData.playerStats['currentHealth'], equals(85.0));
        expect(saveData.playerStats['maxHealth'], equals(120.0));
        expect(saveData.unlockedAbilities['doubleJump'], isTrue);
        expect(saveData.unlockedAbilities['dash'], isTrue);
        expect(saveData.unlockedAbilities['wallJump'], isFalse);
      });

      test('should unlock abilities individually', () {
        saveData.unlockAbility('wallJump');
        expect(saveData.isAbilityUnlocked('wallJump'), isTrue);
        expect(saveData.isAbilityUnlocked('doubleJump'), isFalse);
      });
    });

    group('T3.11.2: Level and Checkpoint Tracking', () {
      test('should track level completion with detailed metrics', () {
        const String levelId = 'forest_level_1';
        saveData.completeLevelWithMetrics(
          levelId,
          completionTime: 145.5,
          deathCount: 3,
          secretsFound: ['hidden_chest', 'secret_area'],
          checkpointData: {'lastCheckpoint': 'checkpoint_3'},
        );

        expect(saveData.levelsCompleted[levelId], isTrue);
        expect(saveData.levelBestTimes[levelId], equals(145.5));
        expect(saveData.levelDeathCounts[levelId], equals(3));
        expect(
          saveData.levelSecretsFound[levelId],
          containsAll(['hidden_chest', 'secret_area']),
        );
        expect(
          saveData.levelCheckpoints[levelId],
          containsValue('checkpoint_3'),
        );
      });

      test('should update best time when completing level faster', () {
        const String levelId = 'test_level';

        // First completion
        saveData.completeLevelWithMetrics(
          levelId,
          completionTime: 200.0,
          deathCount: 5,
          secretsFound: [],
        );
        expect(saveData.levelBestTimes[levelId], equals(200.0));

        // Better completion
        saveData.completeLevelWithMetrics(
          levelId,
          completionTime: 150.0,
          deathCount: 2,
          secretsFound: ['new_secret'],
        );
        expect(saveData.levelBestTimes[levelId], equals(150.0));

        // Worse completion (should not update best time)
        saveData.completeLevelWithMetrics(
          levelId,
          completionTime: 300.0,
          deathCount: 10,
          secretsFound: [],
        );
        expect(saveData.levelBestTimes[levelId], equals(150.0));
      });

      test('should get comprehensive level metrics', () {
        const String levelId = 'metrics_test_level';
        saveData.completeLevelWithMetrics(
          levelId,
          completionTime: 100.0,
          deathCount: 1,
          secretsFound: ['secret1'],
        );

        final Map<String, dynamic> metrics = saveData.getLevelMetrics(levelId);
        expect(metrics['completed'], isTrue);
        expect(metrics['bestTime'], equals(100.0));
        expect(metrics['deathCount'], equals(1));
        expect(metrics['secretsFound'], contains('secret1'));
      });

      test('should update checkpoint with enhanced data', () {
        const String levelId = 'checkpoint_test';
        final Map<String, dynamic> checkpointData = <String, dynamic>{
          'position': {'x': 100.0, 'y': 50.0},
          'checkpointId': 'cp_001',
        };

        saveData.updateLevelCheckpoint(levelId, checkpointData);

        final Map<String, dynamic> savedCheckpoint =
            saveData.levelCheckpoints[levelId]!;
        expect(savedCheckpoint['position'], equals({'x': 100.0, 'y': 50.0}));
        expect(savedCheckpoint['checkpointId'], equals('cp_001'));
        expect(savedCheckpoint['timestamp'], isNotNull);
        expect(savedCheckpoint['playerStats'], isNotNull);
        expect(savedCheckpoint['inventory'], isNotNull);
      });
    });

    group('T3.11.3: Dialogue State and NPC Interaction History', () {
      test('should record NPC interactions with detailed history', () {
        const String npcId = 'village_elder';
        final Map<String, dynamic> interactionData = <String, dynamic>{
          'dialogueTriggered': true,
          'questOffered': false,
          'dialogueId': 'elder_intro',
        };

        saveData.recordNPCInteraction(npcId, interactionData);

        expect(saveData.npcsInteracted[npcId], isTrue);
        final Map<String, dynamic> history =
            saveData.npcInteractionHistory[npcId]!;
        expect(history['interactionCount'], equals(1));
        expect(history['dialogueTriggered'], isTrue);
        expect(history['lastDialogueId'], equals('elder_intro'));
      });

      test('should track conversation history and node visits', () {
        saveData.addConversationHistoryEntry('intro_node_1');
        saveData.addConversationHistoryEntry('choice_node_a');
        saveData.addConversationHistoryEntry('intro_node_1'); // Revisit

        expect(saveData.conversationHistory.length, equals(3));
        expect(saveData.dialogueNodeVisitCounts['intro_node_1'], equals(2));
        expect(saveData.dialogueNodeVisitCounts['choice_node_a'], equals(1));
        expect(saveData.dialogueNodeLastVisited['intro_node_1'], isNotNull);
      });

      test('should import and export conversation state', () {
        final Map<String, dynamic> testDialogueState = <String, dynamic>{
          'state': <String, dynamic>{
            'met_elder': true,
            'village_reputation': 5,
          },
          'history': <String>['intro', 'quest_offer', 'accept'],
          'visitCounts': <String, int>{
            'intro': 1,
            'quest_offer': 1,
          },
          'lastVisited': <String, int>{
            'intro': DateTime.now().millisecondsSinceEpoch,
          },
        };

        saveData.importConversationState(testDialogueState);

        expect(saveData.dialogueStates['met_elder'], isTrue);
        expect(saveData.dialogueStates['village_reputation'], equals(5));
        expect(
          saveData.conversationHistory,
          containsAll(['intro', 'quest_offer', 'accept']),
        );

        // Test export
        final Map<String, dynamic> exported =
            saveData.exportConversationState();
        expect(exported['state']['met_elder'], isTrue);
        expect(exported['history'], contains('intro'));
      });

      test('should update dialogue states from DialogueSystem', () {
        final Map<String, dynamic> dialogueUpdate = <String, dynamic>{
          'player_choice_trust': true,
          'story_flag_chapter1': 'completed',
          'npc_mood_friendly': 8,
        };

        saveData.updateDialogueState(dialogueUpdate);

        expect(saveData.dialogueStates['player_choice_trust'], isTrue);
        expect(
          saveData.dialogueStates['story_flag_chapter1'],
          equals('completed'),
        );
        expect(saveData.dialogueStates['npc_mood_friendly'], equals(8));
      });
    });

    group('T3.11.4: Achievement Tracking', () {
      test('should unlock achievements with timestamps and progress', () {
        final DateTime before = DateTime.now();

        saveData.unlockAchievementWithProgress(
          'first_jump',
          progressData: <String, dynamic>{'jumps_made': 1},
        );

        final DateTime after = DateTime.now();

        expect(saveData.achievementsUnlocked['first_jump'], isTrue);
        final DateTime unlockTime =
            saveData.getAchievementUnlockTime('first_jump')!;
        expect(
          unlockTime.isAfter(before) || unlockTime.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          unlockTime.isBefore(after) || unlockTime.isAtSameMomentAs(after),
          isTrue,
        );

        final Map<String, dynamic> progress =
            saveData.getAchievementProgress('first_jump')!;
        expect(progress['jumps_made'], equals(1));
      });

      test('should not re-unlock already unlocked achievements', () {
        saveData.unlockAchievementWithProgress('test_achievement');
        final DateTime firstUnlock =
            saveData.getAchievementUnlockTime('test_achievement')!;

        // Try to unlock again
        saveData.unlockAchievementWithProgress('test_achievement');
        final DateTime secondAttempt =
            saveData.getAchievementUnlockTime('test_achievement')!;

        expect(firstUnlock, equals(secondAttempt));
      });

      test('should update achievement progress', () {
        saveData.updateAchievementProgress(
          'collector',
          <String, dynamic>{
            'items_collected': 25,
            'target': 100,
            'percentage': 25.0,
          },
        );

        final Map<String, dynamic> progress =
            saveData.getAchievementProgress('collector')!;
        expect(progress['items_collected'], equals(25));
        expect(progress['percentage'], equals(25.0));
      });
    });

    group('T3.11.5: Save Data Completeness and Accuracy', () {
      test('should validate enhanced save data integrity', () {
        // Valid save data
        expect(saveData.isValid(), isTrue);

        // Invalid cases
        final SaveData invalidData1 = SaveData(slotId: -1);
        expect(invalidData1.isValid(), isFalse);

        final SaveData invalidData2 = SaveData(slotId: 1, playerLevel: 0);
        expect(invalidData2.isValid(), isFalse);

        final SaveData invalidData3 = SaveData(slotId: 1, aetherShards: -5);
        expect(invalidData3.isValid(), isFalse);
      });

      test('should serialize and deserialize all enhanced data correctly', () {
        // Setup comprehensive save data
        saveData.updateFromPlayerStats(
          currentHealth: 80.0,
          maxHealth: 100.0,
          currentEnergy: 60.0,
          maxEnergy: 80.0,
          currentAether: 50,
          maxAether: 100,
          aetherShardsCount: 15,
          level: 3,
          experience: 750,
          canDoubleJump: true,
          canDash: false,
          canWallJump: false,
        );

        saveData.completeLevelWithMetrics(
          'test_level',
          completionTime: 120.0,
          deathCount: 2,
          secretsFound: ['secret1'],
        );

        saveData.recordNPCInteraction('npc1', <String, dynamic>{
          'dialogueTriggered': true,
          'dialogueId': 'intro',
        });

        saveData.unlockAchievementWithProgress('achievement1');

        // Serialize to JSON
        final Map<String, dynamic> json = saveData.toJson();

        // Deserialize from JSON
        final SaveData loadedData = SaveData.fromJson(json);

        // Verify all data was preserved
        expect(loadedData.playerLevel, equals(saveData.playerLevel));
        expect(loadedData.aetherShards, equals(saveData.aetherShards));
        expect(
          loadedData.unlockedAbilities['doubleJump'],
          equals(saveData.unlockedAbilities['doubleJump']),
        );
        expect(
          loadedData.levelBestTimes['test_level'],
          equals(saveData.levelBestTimes['test_level']),
        );
        expect(
          loadedData.npcsInteracted['npc1'],
          equals(saveData.npcsInteracted['npc1']),
        );
        expect(
          loadedData.achievementsUnlocked['achievement1'],
          equals(saveData.achievementsUnlocked['achievement1']),
        );
      });

      test('should handle missing fields gracefully in fromJson', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'slotId': 2,
          'playerLevel': 1,
        };

        final SaveData loadedData = SaveData.fromJson(minimalJson);

        expect(loadedData.slotId, equals(2));
        expect(loadedData.playerLevel, equals(1));
        expect(loadedData.dialogueStates, isEmpty);
        expect(loadedData.unlockedAbilities['doubleJump'], isFalse);
        expect(loadedData.isValid(), isTrue);
      });

      test('should provide comprehensive toString output', () {
        saveData.completeLevelWithMetrics(
          'level1',
          completionTime: 100.0,
          deathCount: 1,
          secretsFound: [],
        );
        saveData.unlockAchievementWithProgress('achievement1');
        saveData.unlockAbility('doubleJump');

        final String output = saveData.toString();

        expect(output, contains('slot: 1'));
        expect(output, contains('level: 1'));
        expect(output, contains('completed levels: 1'));
        expect(output, contains('achievements: 1'));
        expect(output, contains('abilities: 1'));
        expect(output, contains('aether shards: 0'));
      });
    });

    group('Integration Tests', () {
      test('should handle complex gameplay scenario', () {
        // Simulate a complete gameplay scenario

        // Player progression
        saveData.updateFromPlayerStats(
          currentHealth: 90.0,
          maxHealth: 120.0,
          currentEnergy: 70.0,
          maxEnergy: 100.0,
          currentAether: 80,
          maxAether: 120,
          aetherShardsCount: 35,
          level: 7,
          experience: 2500,
          canDoubleJump: true,
          canDash: true,
          canWallJump: true,
        );

        // Complete multiple levels
        saveData.completeLevelWithMetrics(
          'tutorial',
          completionTime: 30.0,
          deathCount: 0,
          secretsFound: [],
        );
        saveData.completeLevelWithMetrics(
          'forest_1',
          completionTime: 180.0,
          deathCount: 3,
          secretsFound: ['hidden_gem'],
        );
        saveData.completeLevelWithMetrics(
          'cave_1',
          completionTime: 240.0,
          deathCount: 5,
          secretsFound: ['ancient_rune', 'treasure'],
        );

        // NPC interactions
        saveData.recordNPCInteraction('sage', <String, dynamic>{
          'dialogueTriggered': true,
          'questOffered': true,
          'dialogueId': 'sage_wisdom',
        });

        saveData.recordNPCInteraction('merchant', <String, dynamic>{
          'dialogueTriggered': true,
          'dialogueId': 'shop_intro',
        });

        // Dialogue progression
        saveData.updateDialogueState(<String, dynamic>{
          'main_quest_started': true,
          'sage_trust_level': 5,
          'merchant_discount': 10,
        });

        // Achievement unlocks
        saveData.unlockAchievementWithProgress(
          'level_master',
          progressData: <String, dynamic>{'levels_completed': 3},
        );
        saveData.unlockAchievementWithProgress(
          'secret_hunter',
          progressData: <String, dynamic>{'secrets_found': 3},
        );
        saveData.unlockAchievementWithProgress(
          'social_butterfly',
          progressData: <String, dynamic>{'npcs_met': 2},
        );

        // Verify the complex state
        expect(saveData.isValid(), isTrue);
        expect(saveData.playerLevel, equals(7));
        expect(
          saveData.levelsCompleted.values.where((c) => c).length,
          equals(3),
        );
        expect(
          saveData.achievementsUnlocked.values.where((u) => u).length,
          equals(3),
        );
        expect(
          saveData.unlockedAbilities.values.where((u) => u).length,
          equals(3),
        );
        expect(saveData.npcsInteracted.length, equals(2));
        expect(saveData.dialogueStates.length, equals(3));

        // Test serialization of complex state
        final Map<String, dynamic> json = saveData.toJson();
        final SaveData reloaded = SaveData.fromJson(json);

        expect(reloaded.playerLevel, equals(saveData.playerLevel));
        expect(reloaded.dialogueStates['sage_trust_level'], equals(5));
        expect(reloaded.levelBestTimes['forest_1'], equals(180.0));
        expect(
          reloaded.achievementProgress['level_master']!['levels_completed'],
          equals(3),
        );
      });
    });
  });
}

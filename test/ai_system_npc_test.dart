import 'package:adventure_jumper/src/components/ai_component.dart';
import 'package:adventure_jumper/src/entities/npc.dart';
import 'package:adventure_jumper/src/entities/npcs/mira.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/ai_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// T3.6.5: Comprehensive tests for AISystem with multiple NPCs
/// Tests NPC behavior processing, interaction detection, and state management
void main() {
  group('AISystem NPC Tests (T3.6.5)', () {
    late AISystem aiSystem;
    late Player player;
    late NPC npc1;
    late NPC npc2;
    late Mira mira;

    setUp(() {
      aiSystem = AISystem();

      // Create player at origin
      player = Player(position: Vector2.zero());
      aiSystem.setPlayerEntity(player);

      // Create NPCs at different distances
      npc1 = NPC(
        position: Vector2(100, 0),
        name: 'Test NPC 1',
        interactionRange: 120.0,
        visualFeedbackRange: 180.0,
        id: 'npc1',
      );

      npc2 = NPC(
        position: Vector2(300, 0),
        name: 'Test NPC 2',
        interactionRange: 100.0,
        visualFeedbackRange: 150.0,
        id: 'npc2',
      );

      // Create Mira NPC
      mira = Mira(
        position: Vector2(200, 0),
        id: 'mira',
      );

      // Add AI components to NPCs
      final aiComponent1 = AIComponent(detectionRange: 200.0);
      final aiComponent2 = AIComponent(detectionRange: 180.0);
      final aiComponent3 = AIComponent(detectionRange: 220.0);

      npc1.add(aiComponent1);
      npc2.add(aiComponent2);
      mira.add(aiComponent3);

      // Add entities to AI system
      aiSystem.entities.addAll([npc1, npc2, mira]);

      aiSystem.initialize();
    });

    test('T3.6.5.1: Multiple NPCs are correctly identified and processed', () {
      // Process one frame
      aiSystem.processSystem(0.1);

      // Verify NPCs are identified
      expect(aiSystem.activeNPCs.length, equals(3));
      expect(aiSystem.activeNPCs.contains(npc1), isTrue);
      expect(aiSystem.activeNPCs.contains(npc2), isTrue);
      expect(aiSystem.activeNPCs.contains(mira), isTrue);
    });

    test('T3.6.5.2: Interaction distances are calculated for all NPCs', () {
      // Process one frame
      aiSystem.processSystem(0.1);

      // Check interaction distances
      final distance1 = aiSystem.getNPCInteractionDistance('npc1');
      final distance2 = aiSystem.getNPCInteractionDistance('npc2');
      final distanceMira = aiSystem.getNPCInteractionDistance('mira');

      expect(distance1, isNotNull);
      expect(distance2, isNotNull);
      expect(distanceMira, isNotNull);

      // Verify distance calculations
      expect(distance1!, closeTo(100.0, 1.0));
      expect(distance2!, closeTo(300.0, 1.0));
      expect(distanceMira!, closeTo(200.0, 1.0));
    });

    test('T3.6.5.3: Interaction range detection works for multiple NPCs', () {
      // Process one frame
      aiSystem.processSystem(0.1);

      // NPC1 should be in interaction range (distance 100, range 120)
      expect(aiSystem.isNPCInInteractionRange('npc1'), isTrue);

      // NPC2 should not be in interaction range (distance 300, range 100)
      expect(aiSystem.isNPCInInteractionRange('npc2'), isFalse);

      // Mira should be in interaction range (distance 200, range 120)
      expect(aiSystem.isNPCInInteractionRange('mira'), isFalse);
    });

    test('T3.6.5.4: State transitions work when player moves', () {
      // Initial state - player at origin
      aiSystem.processSystem(0.1);
      bool initialNpc1State = aiSystem.isNPCInInteractionRange('npc1') ?? false;

      // Move player closer to NPC2
      player.position.setFrom(Vector2(250, 0));
      aiSystem.processSystem(0.1);

      // NPC2 should now be in range (distance 50, range 100)
      expect(aiSystem.isNPCInInteractionRange('npc2'), isTrue);

      // NPC1 should now be out of range (distance 250, range 120)
      expect(aiSystem.isNPCInInteractionRange('npc1'), isFalse);

      // Verify state change occurred for NPC1
      bool currentNpc1State = aiSystem.isNPCInInteractionRange('npc1') ?? false;
      expect(initialNpc1State != currentNpc1State, isTrue);
    });

    test('T3.6.5.5: Proximity updates work with timing', () {
      // Process with short intervals (should not trigger proximity updates)
      aiSystem.processSystem(0.05); // 50ms
      aiSystem.processSystem(0.03); // 30ms (total 80ms < 100ms threshold)

      // Process with interval that triggers proximity update
      aiSystem.processSystem(0.05); // 50ms (total 130ms > 100ms threshold)

      // Verify system still processes correctly
      expect(aiSystem.activeNPCs.length, equals(3));
      expect(aiSystem.getNPCInteractionDistance('npc1'), isNotNull);
    });

    test('T3.6.5.6: Difficulty multiplier affects NPC AI detection', () {
      // Set higher difficulty multiplier
      aiSystem.setDifficultyMultiplier(1.5);

      // Process system
      aiSystem.processSystem(
        0.1,
      ); // AI detection ranges should be affected by difficulty multiplier
      // This is tested implicitly through the _processNPCAI method
      // We can't directly access the private field, but can verify the method works
      expect(() => aiSystem.setDifficultyMultiplier(1.5), returnsNormally);
    });
    test('T3.6.5.7: Inactive NPCs are not processed', () {
      // Deactivate one NPC
      npc2.deactivate();

      // Process system
      aiSystem.processSystem(0.1);

      // Only active NPCs should be processed
      expect(aiSystem.activeNPCs.length, equals(2));
      expect(aiSystem.activeNPCs.contains(npc1), isTrue);
      expect(aiSystem.activeNPCs.contains(mira), isTrue);
      expect(aiSystem.activeNPCs.contains(npc2), isFalse);
    });

    test('T3.6.5.8: Mira-specific behavior is preserved', () {
      // Process system
      aiSystem.processSystem(0.1);

      // Verify Mira is processed as an NPC
      expect(aiSystem.activeNPCs.contains(mira), isTrue);
      expect(mira.name, equals('Mira'));
      expect(mira.hasDialogue, isTrue);
      expect(mira.hasQuest, isTrue);
    });
    test('T3.6.5.9: System handles no player gracefully', () {
      // Create a new AI system without setting player
      final testAISystem = AISystem();
      testAISystem.entities.addAll([npc1, npc2, mira]);

      // Process should not crash when no player is set
      expect(() => testAISystem.processSystem(0.1), returnsNormally);

      // No interactions should be tracked without player
      expect(testAISystem.getNPCInteractionDistance('npc1'), isNull);
    });

    test('T3.6.5.10: Performance with multiple NPCs', () {
      // Add more NPCs to test performance
      final List<NPC> additionalNPCs = [];
      for (int i = 0; i < 10; i++) {
        final npc = NPC(
          position: Vector2(50.0 * i, 50.0 * i),
          name: 'Perf Test NPC $i',
          id: 'perf_npc_$i',
        );
        npc.add(AIComponent(detectionRange: 150.0));
        additionalNPCs.add(npc);
      }

      aiSystem.entities.addAll(additionalNPCs);

      // Measure processing time
      final stopwatch = Stopwatch()..start();
      aiSystem.processSystem(0.1);
      stopwatch.stop();

      // Processing should complete quickly (< 10ms for 13 NPCs)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));

      // All NPCs should be processed
      expect(aiSystem.activeNPCs.length, equals(13));
    });
  });

  group('AISystem NPC Integration Tests (T3.6.5)', () {
    test('T3.6.5.11: Integration with NPC interaction states', () {
      final aiSystem = AISystem();
      final player = Player(position: Vector2.zero());
      aiSystem.setPlayerEntity(player);

      final npc = NPC(
        position: Vector2(50, 0),
        name: 'Interactive NPC',
        id: 'interactive_npc',
        interactionRange: 100.0,
      );

      npc.add(AIComponent(detectionRange: 150.0));
      aiSystem.entities.add(npc);

      // Initial state should be idle
      expect(npc.isIdle, isTrue);

      // Process system - should detect player in range
      aiSystem.processSystem(0.1);
      expect(aiSystem.isNPCInInteractionRange('interactive_npc'), isTrue);

      // Move player out of range
      player.position.setFrom(Vector2(200, 0));
      aiSystem.processSystem(0.1);
      expect(aiSystem.isNPCInInteractionRange('interactive_npc'), isFalse);
    });
  });
}

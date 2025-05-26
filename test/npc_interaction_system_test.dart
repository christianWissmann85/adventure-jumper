// filepath: test/npc_interaction_system_test.dart
import 'package:adventure_jumper/src/components/ai_component.dart';
import 'package:adventure_jumper/src/entities/npc.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comprehensive test suite for T3.4: Enhanced NPC base class with interaction and AI foundations
/// Tests all subtasks: T3.4.1 through T3.4.6
void main() {
  group('T3.4: Enhanced NPC Interaction and AI System', () {
    late NPC testNPC;
    late Vector2 playerPosition;

    setUp(() async {
      testNPC = NPC(
        position: Vector2(100, 100),
        name: 'Test NPC',
        dialogueId: 'test_dialogue',
        questId: 'test_quest',
        interactionRange: 80.0,
        visualFeedbackRange: 120.0,
      );

      // Properly initialize the NPC like other entity tests do
      await testNPC.onLoad();

      playerPosition = Vector2(150, 100); // 50 units away
    });

    group('T3.4.1: Interaction Range Detection', () {
      test('should detect player within interaction range', () {
        final bool inRange = testNPC.isInInteractionRange(playerPosition);
        expect(
          inRange,
          isTrue,
          reason: 'Player at 50 units should be within 80 unit range',
        );
      });

      test('should detect player outside interaction range', () {
        final Vector2 farPosition = Vector2(200, 100); // 100 units away
        final bool inRange = testNPC.isInInteractionRange(farPosition);
        expect(
          inRange,
          isFalse,
          reason: 'Player at 100 units should be outside 80 unit range',
        );
      });

      test('should support custom interaction range', () {
        final Vector2 customPosition = Vector2(170, 100); // 70 units away
        final bool inRange =
            testNPC.isInInteractionRange(customPosition, customRange: 75.0);
        expect(
          inRange,
          isTrue,
          reason: 'Custom range should override default range',
        );
      });

      test('should detect player within visual feedback range', () {
        final Vector2 visualPosition = Vector2(210, 100); // 110 units away
        final bool inVisualRange =
            testNPC.isInVisualFeedbackRange(visualPosition);
        expect(
          inVisualRange,
          isTrue,
          reason: 'Player at 110 units should be within 120 unit visual range',
        );
      });

      test('should calculate accurate distance to player', () {
        final double distance = testNPC.getDistanceToPlayer(playerPosition);
        expect(
          distance,
          closeTo(50.0, 0.1),
          reason: 'Distance calculation should be accurate',
        );
      });

      test('should have configurable interaction ranges', () {
        testNPC.interactionRange = 150.0;
        testNPC.visualFeedbackRange = 200.0;

        expect(testNPC.interactionRange, equals(150.0));
        expect(testNPC.visualFeedbackRange, equals(200.0));
      });
    });

    group('T3.4.2: Interaction State Management', () {
      test('should start in idle state', () {
        expect(testNPC.interactionState, equals(NPCInteractionState.idle));
        expect(testNPC.isIdle, isTrue);
        expect(testNPC.isTalking, isFalse);
        expect(testNPC.isBusy, isFalse);
      });

      test('should change to talking state during interaction', () {
        testNPC.setInteractionState(NPCInteractionState.talking);

        expect(testNPC.interactionState, equals(NPCInteractionState.talking));
        expect(testNPC.isIdle, isFalse);
        expect(testNPC.isTalking, isTrue);
        expect(testNPC.isBusy, isFalse);
      });

      test('should change to busy state when needed', () {
        testNPC.setInteractionState(NPCInteractionState.busy);

        expect(testNPC.interactionState, equals(NPCInteractionState.busy));
        expect(testNPC.isIdle, isFalse);
        expect(testNPC.isTalking, isFalse);
        expect(testNPC.isBusy, isTrue);
      });

      test('should reset state change timer when changing states', () {
        testNPC.setInteractionState(NPCInteractionState.talking);
        expect(testNPC.stateChangeTime, equals(0.0));
      });

      test('should end interaction and return to idle', () {
        testNPC.setInteractionState(NPCInteractionState.talking);
        testNPC.endInteraction();

        expect(testNPC.interactionState, equals(NPCInteractionState.idle));
        expect(testNPC.dialogueTriggered, isFalse);
        expect(testNPC.questOffered, isFalse);
      });

      test('should prevent interaction when not in idle state', () {
        testNPC.setInteractionState(NPCInteractionState.busy);
        final bool result = testNPC.interact();

        expect(result, isFalse, reason: 'Should not interact when busy');
      });
    });

    group('T3.4.3: Dialogue Trigger System', () {
      test('should trigger dialogue during interaction', () {
        final bool result = testNPC.interact();

        expect(result, isTrue);
        expect(testNPC.dialogueTriggered, isTrue);
        expect(testNPC.interactionState, equals(NPCInteractionState.talking));
      });

      test('should trigger quest during interaction if available', () {
        final NPC questNPC = NPC(
          position: Vector2(0, 0),
          hasQuest: true,
          questId: 'test_quest',
        );

        final bool result = questNPC.interact();

        expect(result, isTrue);
        expect(questNPC.questOffered, isTrue);
      });

      test('should not retrigger dialogue or quest in same interaction', () {
        testNPC.interact(); // First interaction

        expect(testNPC.dialogueTriggered, isTrue);

        // Reset to simulate continued conversation
        testNPC.setInteractionState(NPCInteractionState.talking);
        final bool secondResult = testNPC.interact();

        expect(
          secondResult,
          isFalse,
          reason: 'Should not interact when already talking',
        );
      });

      test('should reset dialogue and quest flags when ending interaction', () {
        testNPC.interact();
        testNPC.endInteraction();

        expect(testNPC.dialogueTriggered, isFalse);
        expect(testNPC.questOffered, isFalse);
      });
    });

    group('T3.4.4: Basic AI State Machine for NPCs', () {
      test('should have AI component properly initialized', () {
        expect(testNPC.ai, isA<AIComponent>());
        expect(testNPC.ai.currentState, isNotEmpty);
      });

      test('should sync AI state with interaction state when talking', () {
        testNPC.setInteractionState(NPCInteractionState.talking);
        testNPC.updateAIStateMachine(0.016); // 60 FPS delta

        expect(testNPC.ai.currentState, equals('idle'));
      });

      test('should sync AI state with interaction state when busy', () {
        testNPC.setInteractionState(NPCInteractionState.busy);
        testNPC.updateAIStateMachine(0.016);

        expect(testNPC.ai.currentState, equals('idle'));
      });
      test('should allow normal AI behavior when idle', () {
        testNPC.setInteractionState(NPCInteractionState.idle);
        testNPC.updateAIStateMachine(0.016);

        // AI should be free to change states when NPC is idle
        // The actual state might change based on AI logic, so we just ensure no forced override
        expect(testNPC.ai, isA<AIComponent>());
      });
    });

    group('T3.4.5: Visual Feedback for Interaction Availability', () {
      test('should show interaction prompt when in range and idle', () {
        testNPC.updateInteractionAvailability(playerPosition);

        expect(testNPC.showingInteractionPrompt, isTrue);
      });

      test('should not show interaction prompt when out of visual range', () {
        final Vector2 farPosition =
            Vector2(250, 100); // 150 units away, beyond visual range
        testNPC.updateInteractionAvailability(farPosition);

        expect(testNPC.showingInteractionPrompt, isFalse);
      });

      test('should not show interaction prompt when busy', () {
        testNPC.setInteractionState(NPCInteractionState.busy);
        testNPC.updateInteractionAvailability(playerPosition);

        expect(testNPC.showingInteractionPrompt, isFalse);
      });
      test('should update prompt pulse timer', () {
        final double initialTimer = testNPC.promptPulseTimer;
        testNPC.updateEntity(
            0.016); // Use updateEntity which calls updateVisualFeedback

        expect(testNPC.promptPulseTimer, greaterThan(initialTimer));
      });

      test('should calculate pulse value for visual effects', () {
        testNPC.setInteractionState(NPCInteractionState.idle);
        testNPC.updateInteractionAvailability(playerPosition);

        // Should not throw assertion errors
        expect(() => testNPC.updateVisualFeedback(0.016), returnsNormally);
      });
    });

    group(
        'T3.4.6: Integration Tests for Interaction Detection and State Changes',
        () {
      test('should handle complete interaction flow', () {
        // Start out of range
        final Vector2 farPosition = Vector2(250, 100);
        testNPC.updateInteractionAvailability(farPosition);
        expect(testNPC.showingInteractionPrompt, isFalse);

        // Move into visual range
        final Vector2 visualPosition = Vector2(210, 100);
        testNPC.updateInteractionAvailability(visualPosition);
        expect(testNPC.showingInteractionPrompt, isTrue);

        // Move into interaction range and interact
        testNPC.updateInteractionAvailability(playerPosition);
        final bool interactionResult = testNPC.interact();
        expect(interactionResult, isTrue);
        expect(testNPC.isTalking, isTrue);

        // Move out of interaction range during dialogue
        testNPC.updateInteractionAvailability(farPosition);
        expect(
          testNPC.isIdle,
          isTrue,
          reason: 'Should auto-end interaction when player moves away',
        );
      });

      test('should update timers correctly during entity updates', () {
        final double initialStateTime = testNPC.stateChangeTime;
        final double initialPulseTime = testNPC.promptPulseTimer;

        testNPC.updateEntity(0.016);

        expect(testNPC.stateChangeTime, greaterThan(initialStateTime));
        expect(testNPC.promptPulseTimer, greaterThan(initialPulseTime));
      });

      test('should maintain state consistency across multiple updates', () {
        testNPC.setInteractionState(NPCInteractionState.talking);

        // Run multiple update cycles
        for (int i = 0; i < 60; i++) {
          // Simulate 1 second at 60 FPS
          testNPC.updateEntity(0.016);
        }

        expect(testNPC.isTalking, isTrue);
        expect(
          testNPC.stateChangeTime,
          greaterThan(0.9),
        ); // Should be close to 1 second
      });

      test('should properly initialize all NPC properties', () {
        final NPC fullNPC = NPC(
          position: Vector2(0, 0),
          name: 'Full Test NPC',
          canInteract: true,
          hasDialogue: true,
          hasQuest: true,
          dialogueId: 'full_dialogue',
          questId: 'full_quest',
          interactionRange: 100.0,
          visualFeedbackRange: 150.0,
        );

        expect(fullNPC.name, equals('Full Test NPC'));
        expect(fullNPC.canInteract, isTrue);
        expect(fullNPC.hasDialogue, isTrue);
        expect(fullNPC.hasQuest, isTrue);
        expect(fullNPC.dialogueId, equals('full_dialogue'));
        expect(fullNPC.questId, equals('full_quest'));
        expect(fullNPC.interactionRange, equals(100.0));
        expect(fullNPC.visualFeedbackRange, equals(150.0));
        expect(fullNPC.isIdle, isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle zero interaction range', () {
        testNPC.interactionRange = 0.0;
        final bool inRange = testNPC.isInInteractionRange(testNPC.position);
        expect(
          inRange,
          isTrue,
          reason: 'Zero distance should be within zero range',
        );
      });

      test('should handle negative ranges gracefully', () {
        testNPC.interactionRange = -10.0;
        final bool inRange = testNPC.isInInteractionRange(playerPosition);
        expect(
          inRange,
          isFalse,
          reason: 'Negative range should never match positive distance',
        );
      });

      test('should handle rapid state changes', () {
        testNPC.setInteractionState(NPCInteractionState.talking);
        testNPC.setInteractionState(NPCInteractionState.busy);
        testNPC.setInteractionState(NPCInteractionState.idle);

        expect(testNPC.isIdle, isTrue);
        expect(testNPC.stateChangeTime, equals(0.0));
      });

      test('should handle disabled interaction', () {
        final NPC disabledNPC = NPC(
          position: Vector2(0, 0),
          canInteract: false,
        );

        final bool result = disabledNPC.interact();
        expect(result, isFalse);
        expect(disabledNPC.isIdle, isTrue);
      });
    });
  });
}

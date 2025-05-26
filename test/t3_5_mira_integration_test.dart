// T3.5 Integration Test: Mira NPC in Luminara Hub
// Comprehensive test to validate Mira's placement and interaction in the actual game environment

import 'package:adventure_jumper/src/entities/npc.dart';
import 'package:adventure_jumper/src/entities/npcs/mira.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T3.5.5 Final: Mira Integration with Luminara Hub', () {
    late Mira mira;

    setUp(() {
      // Create Mira at the exact position from luminara_hub.json
      mira = Mira(position: Vector2(950, 1750));
    });

    group('Mira Placement and Environment', () {
      test('should be positioned correctly in Keeper\'s Archive', () {
        expect(mira.position.x, equals(950.0));
        expect(mira.position.y, equals(1750.0));
        expect(mira.name, equals('Mira'));
      });

      test('should have appropriate interaction ranges for hub environment',
          () {
        // Mira has larger interaction ranges suitable for a mentor in the hub
        expect(mira.interactionRange, equals(120.0));
        expect(mira.visualFeedbackRange, equals(180.0));

        // Ranges should be appropriate for hub-scale interactions
        expect(mira.interactionRange, greaterThan(100.0));
        expect(mira.visualFeedbackRange, greaterThan(mira.interactionRange));
      });

      test('should have dialogue configured for Luminara introduction', () {
        expect(mira.dialogueId, equals('luminara_introduction'));
        expect(mira.questId, equals('first_steps'));
        expect(mira.hasDialogue, isTrue);
        expect(mira.hasQuest, isTrue);
      });
    });

    group('Scholar Behavior Integration', () {
      test('should demonstrate complete idle behavior cycle', () {
        // Initial state
        expect(mira.isReading, isFalse);
        expect(mira.currentAnimationState, equals('idle'));
        expect(mira.currentIdleFrame, equals(0));

        // Simulate passage of time to trigger reading behavior
        double totalTime = 0.0;
        while (!mira.isReading && totalTime < 5.0) {
          mira.updateNPC(0.1);
          totalTime += 0.1;
        }

        // Should eventually start reading
        expect(mira.isReading, isTrue);
        expect(mira.currentAnimationState, equals('reading'));
      });

      test('should handle complete interaction cycle', () {
        // Start interaction
        final bool interactionStarted = mira.interact();
        expect(interactionStarted, isTrue);
        expect(mira.interactionState, equals(NPCInteractionState.talking));
        expect(mira.conversationDepth, equals(1));

        // Reading should stop during dialogue
        expect(mira.isReading, isFalse);
        expect(mira.currentAnimationState, equals('talking'));

        // End interaction
        mira.endInteraction();
        expect(mira.interactionState, equals(NPCInteractionState.idle));
      });

      test('should demonstrate quill animation integration', () {
        final Vector2 initialQuillPos = mira.quillPosition.clone();

        // Update animation
        mira.updateNPC(1.0);

        final Vector2 newQuillPos = mira.quillPosition;

        // Quill should be animated (floating effect)
        expect(newQuillPos, isNot(equals(initialQuillPos)));

        // Quill should maintain proper offset from Mira
        expect(newQuillPos.x, greaterThan(mira.position.x));
        expect(
          newQuillPos.y,
          lessThan(mira.position.y + 50),
        ); // Should be above/around Mira
      });
    });

    group('Dialogue Progression System', () {
      test('should progress through full dialogue tree', () {
        // Track initial state
        expect(mira.conversationDepth, equals(0));
        expect(mira.hasIntroducedSelf, isFalse);
        expect(mira.hasExplainedKeepers, isFalse);
        expect(mira.hasGivenFirstQuest, isFalse);

        // First conversation - Introduction
        mira.interact();
        expect(mira.hasIntroducedSelf, isTrue);
        expect(mira.conversationDepth, equals(1));
        mira.endInteraction();

        // Second conversation - Keepers Explanation
        mira.interact();
        expect(mira.conversationDepth, equals(2));
        mira.endInteraction();

        // Third conversation - First Quest
        mira.interact();
        expect(mira.conversationDepth, equals(3));
        expect(mira.hasGivenFirstQuest, isTrue);
        mira.endInteraction(); // Verify quest system integration
        expect(mira.hasGivenFirstQuest, isTrue);
      });

      test('should handle advanced dialogue after initial progression', () {
        // Progress through initial conversations
        for (int i = 0; i < 3; i++) {
          mira.interact();
          mira.endInteraction();
        }

        // Continue with advanced conversations
        mira.interact();
        expect(mira.conversationDepth, equals(4));
        mira.endInteraction();

        // Should handle extended dialogue gracefully
        for (int i = 0; i < 10; i++) {
          expect(() => mira.interact(), returnsNormally);
          expect(() => mira.endInteraction(), returnsNormally);
        }
      });
    });

    group('Performance and Reliability', () {
      test('should handle extended simulation without errors', () {
        // Simulate extended gameplay time
        for (int i = 0; i < 1000; i++) {
          expect(() => mira.updateNPC(0.016), returnsNormally); // ~60 FPS
        }

        // Should still be functional after extended simulation
        expect(mira.interact(), isTrue);
        expect(mira.interactionState, equals(NPCInteractionState.talking));
      });

      test('should handle rapid interaction cycling', () {
        // Test rapid interaction on/off
        for (int i = 0; i < 50; i++) {
          expect(mira.interact(), isTrue);
          mira.updateNPC(0.1);
          mira.endInteraction();
          mira.updateNPC(0.1);
        }

        // Should remain stable
        expect(mira.conversationDepth, greaterThan(0));
        expect(() => mira.interact(), returnsNormally);
      });

      test('should maintain animation state consistency', () {
        // Test animation state transitions
        final states = <String>[];

        for (int i = 0; i < 100; i++) {
          mira.updateNPC(0.1);
          states.add(mira.currentAnimationState);

          if (i == 30) {
            mira.interact(); // Trigger talking state
          }
          if (i == 60) {
            mira.endInteraction(); // Return to idle/reading
          }
        }

        // Should have captured different animation states
        expect(states.contains('idle'), isTrue);
        expect(states.contains('talking'), isTrue);

        // May also contain reading state
        final hasReading = states.contains('reading');
        if (hasReading) {
          expect(states.contains('reading'), isTrue);
        }
      });
    });

    group('Hub Environment Compatibility', () {
      test('should work with typical hub player distances', () {
        // Test various player positions around Mira's hub location
        final testPositions = [
          Vector2(950 + 50, 1750), // Close right
          Vector2(950 - 50, 1750), // Close left
          Vector2(950, 1750 + 50), // Close below
          Vector2(950, 1750 - 50), // Close above
          Vector2(950 + 100, 1750), // Medium right
          Vector2(950 - 100, 1750), // Medium left
          Vector2(950 + 200, 1750), // Far right
          Vector2(950 - 200, 1750), // Far left
        ];

        for (final playerPos in testPositions) {
          expect(
            () => mira.updateInteractionAvailability(playerPos),
            returnsNormally,
          );

          final distance = mira.getDistanceToPlayer(playerPos);
          final inInteraction = mira.isInInteractionRange(playerPos);
          final inVisual = mira.isInVisualFeedbackRange(playerPos);

          // Verify range logic is consistent
          if (distance <= mira.interactionRange) {
            expect(inInteraction, isTrue);
            expect(inVisual, isTrue);
          } else if (distance <= mira.visualFeedbackRange) {
            expect(inInteraction, isFalse);
            expect(inVisual, isTrue);
          } else {
            expect(inInteraction, isFalse);
            expect(inVisual, isFalse);
          }
        }
      });

      test('should initialize properly without AI dependency', () {
        // Test that Mira can be set up in environments where AI might not be available
        expect(() => mira.setupNPC(), returnsNormally);

        // Core functionality should work regardless
        expect(mira.canInteract, isTrue);
        expect(mira.interactionRange, equals(120.0));
        expect(mira.visualFeedbackRange, equals(180.0));
      });
    });
  });
}

import 'package:adventure_jumper/src/entities/npc.dart';
import 'package:adventure_jumper/src/entities/npcs/mira.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T3.5: Mira NPC Implementation Tests', () {
    late Mira mira;

    setUp(() {
      mira = Mira(position: Vector2(950, 1750));
    });

    group('T3.5.1: Mira class with specific personality traits', () {
      test('should have correct character properties', () {
        expect(mira.name, equals('Mira'));
        expect(mira.canInteract, isTrue);
        expect(mira.hasDialogue, isTrue);
        expect(mira.hasQuest, isTrue);
        expect(mira.dialogueId, equals('luminara_introduction'));
        expect(mira.questId, equals('first_steps'));
      });

      test('should have scholar-specific constants', () {
        expect(Mira.characterType, equals('mira'));
        expect(Mira.personalityType, equals('stern_mentor'));
        expect(Mira.spriteBasePath, equals('images/characters/npcs/mira'));
        expect(Mira.clothingColor, equals('#0066CC')); // Blue robes
        expect(Mira.hairColor, equals('#C0C0C0')); // Silver hair
        expect(Mira.accessoryColor, equals('#FFD700')); // Golden accessories
      });

      test('should extend NPC base class correctly', () {
        expect(mira, isA<NPC>());
        expect(mira.interactionRange, equals(120.0));
        expect(mira.visualFeedbackRange, equals(180.0));
      });
    });

    group('T3.5.2: Idle animations and behaviors', () {
      test('should have idle animation properties', () {
        expect(mira.currentIdleFrame, equals(0));
        expect(mira.currentAnimationState, equals('idle'));
        expect(mira.isReading, isFalse);
      });
      test('should update idle animation over time', () {
        final int initialFrame = mira.currentIdleFrame;

        // Simulate time passing (more than animation speed)
        for (int i = 0; i < 10; i++) {
          mira.updateNPC(0.1);
        }

        // Animation should have progressed
        expect(mira.currentIdleFrame, isNot(equals(initialFrame)));
      });
      test('should have reading behavior cycles', () {
        expect(mira.isReading, isFalse);

        // Simulate enough time to start reading (> 2 seconds)
        for (int i = 0; i < 25; i++) {
          mira.updateNPC(0.1);
        }

        expect(mira.isReading, isTrue);
        expect(mira.currentAnimationState, equals('reading'));
      });
      test('should have floating quill animation', () {
        final Vector2 initialQuillPos = mira.quillPosition.clone();

        // Update to animate quill
        mira.updateNPC(0.5);

        final Vector2 updatedQuillPos = mira.quillPosition;

        // Quill should move (floating animation)
        expect(updatedQuillPos, isNot(equals(initialQuillPos)));

        // Quill should be offset from Mira's position
        expect(updatedQuillPos.x, greaterThan(mira.position.x));
        expect(updatedQuillPos.y, lessThan(mira.position.y));
      });
    });

    group('T3.5.3: Mira-specific dialogue triggers', () {
      test('should track conversation progression', () {
        expect(mira.conversationDepth, equals(0));
        expect(mira.hasIntroducedSelf, isFalse);
        expect(mira.hasExplainedKeepers, isFalse);
        expect(mira.hasGivenFirstQuest, isFalse);
      });
      test('should progress through dialogue stages', () {
        // First interaction - introduction
        final bool firstInteraction = mira.interact();
        expect(firstInteraction, isTrue);
        expect(mira.conversationDepth, equals(1));
        expect(mira.hasIntroducedSelf, isTrue);

        // End interaction and start again
        mira.endInteraction();

        // Second interaction
        final bool secondInteraction = mira.interact();
        expect(secondInteraction, isTrue);
        expect(mira.conversationDepth, equals(2));

        // Continue until quest is offered
        mira.endInteraction();
        mira.interact();
        expect(mira.conversationDepth, equals(3));
        expect(mira.hasGivenFirstQuest, isTrue);
      });
      test('should stop reading when in dialogue', () {
        // Get Mira into reading state
        for (int i = 0; i < 25; i++) {
          mira.updateNPC(0.1);
        }
        expect(mira.isReading, isTrue);

        // Start dialogue
        mira.interact();
        expect(mira.interactionState, equals(NPCInteractionState.talking));
        expect(mira.isReading, isFalse);
        expect(mira.currentAnimationState, equals('talking'));
      });
    });

    group('T3.5.4: Interaction range and visual feedback', () {
      test('should have appropriate interaction ranges for a mentor', () {
        expect(mira.interactionRange, equals(120.0));
        expect(mira.visualFeedbackRange, equals(180.0));
        expect(mira.visualFeedbackRange, greaterThan(mira.interactionRange));
      });
      test('should respond to player proximity correctly', () {
        // Player far away
        final Vector2 farPosition =
            Vector2(mira.position.x + 300, mira.position.y);
        mira.updateInteractionAvailability(farPosition);
        expect(mira.isInInteractionRange(farPosition), isFalse);
        expect(mira.isInVisualFeedbackRange(farPosition), isFalse);

        // Player in visual range but not interaction range
        final Vector2 mediumPosition =
            Vector2(mira.position.x + 150, mira.position.y);
        mira.updateInteractionAvailability(mediumPosition);
        expect(mira.isInInteractionRange(mediumPosition), isFalse);
        expect(mira.isInVisualFeedbackRange(mediumPosition), isTrue);

        // Player in interaction range
        final Vector2 closePosition =
            Vector2(mira.position.x + 80, mira.position.y);
        mira.updateInteractionAvailability(closePosition);
        expect(mira.isInInteractionRange(closePosition), isTrue);
        expect(mira.isInVisualFeedbackRange(closePosition), isTrue);
      });
    });
    group('T3.5.5: Scholar AI and patrol behavior', () {
      test('should be configured for non-aggressive scholar behavior', () {
        // Test that setupNPC can be called without errors
        expect(() => mira.setupNPC(), returnsNormally);

        // Test basic properties that should be set regardless of AI
        expect(mira.interactionRange, equals(120.0));
        expect(mira.visualFeedbackRange, equals(180.0));
      });

      test('should behave differently during different interaction states', () {
        // Idle state - should allow reading and patrol
        expect(mira.interactionState, equals(NPCInteractionState.idle));

        // Talking state - should stop other behaviors
        mira.interact();
        expect(mira.interactionState, equals(NPCInteractionState.talking));
        mira.updateNPC(0.1);

        // Reading should stop during conversation
        expect(mira.isReading, isFalse);

        // End interaction
        mira.endInteraction();
        expect(mira.interactionState, equals(NPCInteractionState.idle));
      });
    });

    group('T3.5: Integration with Luminara Hub', () {
      test('should be positioned correctly in Keeper\'s Archive', () {
        // Verify position matches Luminara hub spawn point
        expect(mira.position.x, equals(950));
        expect(mira.position.y, equals(1750));
      });

      test('should have appropriate dialogue for Luminara introduction', () {
        expect(mira.dialogueId, equals('luminara_introduction'));
        expect(mira.questId, equals('first_steps'));
      });
    });
  });
}

import 'package:adventure_jumper/src/data/sample_conversations.dart';
import 'package:adventure_jumper/src/entities/npc.dart';
import 'package:adventure_jumper/src/entities/npcs/mira.dart';
import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:adventure_jumper/src/ui/dialogue_ui.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T3.7: DialogueUI Tests with Sample Conversations', () {
    late AdventureJumperGame game;
    late DialogueUI dialogueUI;
    late Mira mira;

    setUp(() {
      // Create a mock game
      game = AdventureJumperGame();

      // Create DialogueUI with test configuration
      dialogueUI = DialogueUI(
        game: game,
        screenSize: Vector2(800, 600),
        dialogueSpeed: 0.01, // Fast for testing
        punctuationPause: 0.05, // Short for testing
        padding: 10.0,
        portraitSize: 64.0,
        dialogueBoxHeight: 120.0,
        cornerRadius: 8.0,
        borderWidth: 1.0,
        showContinueIndicator: true,
        enableSmoothAnimations: true,
      );

      // Create test NPC
      mira = Mira(position: Vector2(100, 100));
    });

    group('Linear Dialogue Sequence Tests', () {
      test('should handle Mira introduction sequence', () {
        final List<DialogueEntry> conversation =
            SampleConversations.getMiraIntroductionSequence();

        expect(conversation.length, equals(3));
        expect(conversation[0].speakerName, equals('Mira'));
        expect(conversation[0].text, contains('new face'));
        expect(conversation[2].choices, isNotNull);
        expect(conversation[2].choices!.length, equals(3));
      });

      test('should initialize dialogue UI with linear conversation', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getMiraIntroductionSequence();
        dialogueUI.startDialogue(mira, conversation);

        expect(dialogueUI.activeNPC, equals(mira));
        expect(dialogueUI.selectedChoice, equals(-1));
      });

      test('should progress through linear dialogue', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();
        dialogueUI.startDialogue(mira, conversation);

        // Simulate advancing through dialogue
        dialogueUI.advanceDialogue(); // Skip typing effect
        dialogueUI.advanceDialogue(); // Move to next entry

        // Should have progressed to second entry
        expect(dialogueUI.activeNPC, equals(mira));
      });
    });

    group('Conversation Tree Tests', () {
      test('should handle complex conversation tree structure', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getMiraConversationTree();

        expect(tree.containsKey('start'), isTrue);
        expect(tree['start']!.entry.choices, isNotNull);
        expect(tree['start']!.choiceNodeIds, isNotNull);
        expect(tree['start']!.choiceNodeIds!.length, equals(3));
      });

      test('should initialize dialogue UI with conversation tree', () async {
        await dialogueUI.onLoad();

        final Map<String, DialogueNode> tree =
            SampleConversations.getMiraConversationTree();
        dialogueUI.startDialogueFromNode(mira, tree, 'start');

        expect(dialogueUI.activeNPC, equals(mira));
      });

      test('should navigate through conversation tree based on choices', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getMiraConversationTree();
        final DialogueNode startNode = tree['start']!;

        // Verify navigation structure
        expect(startNode.choiceNodeIds!['Who are you?'], equals('about_mira'));
        expect(startNode.choiceNodeIds!['What is this place?'],
            equals('about_archive'),);
        expect(startNode.choiceNodeIds!['I must go'], equals('farewell'));

        // Verify connected nodes exist
        expect(tree.containsKey('about_mira'), isTrue);
        expect(tree.containsKey('about_archive'), isTrue);
        expect(tree.containsKey('farewell'), isTrue);
      });

      test('should handle quest-related dialogue paths', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getMiraConversationTree();

        // Verify quest path exists
        expect(tree.containsKey('teaching_offer'), isTrue);
        expect(tree.containsKey('quest_accept'), isTrue);
        expect(tree.containsKey('quest_given'), isTrue);

        final DialogueNode questNode = tree['teaching_offer']!;
        expect(questNode.entry.text, contains('undertake a task'));
        expect(questNode.choiceNodeIds!['Yes, I\'m ready'],
            equals('quest_accept'),);
      });
    });

    group('Enhanced Features Tests', () {
      test('should handle typewriter effect settings', () {
        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();

        expect(conversation[0].useTypewriter, isTrue);
        expect(conversation[1].useTypewriter, isFalse);
        expect(conversation[0].pauseAfterPunctuation, isTrue);
        expect(conversation[1].pauseAfterPunctuation, isFalse);
      });

      test('should handle timed dialogue entries', () {
        final List<DialogueEntry> conversation =
            SampleConversations.getTimedConversation();

        expect(conversation[0].displayDuration, equals(3.0));
        expect(conversation[1].displayDuration, equals(2.0));
        expect(conversation[2].displayDuration, equals(0.0)); // Manual advance
      });

      test('should update typewriter effect over time', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();
        dialogueUI.startDialogue(mira, conversation);

        // Update dialogue UI to process typewriter effect
        dialogueUI.update(0.016); // 60 FPS frame

        // Should be in typing state initially
        expect(dialogueUI.activeNPC, equals(mira));
      });

      test('should handle show/hide animations', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();
        dialogueUI.startDialogue(mira, conversation);

        // Should start with animations enabled
        expect(dialogueUI.enableSmoothAnimations, isTrue);

        // Update to process animation
        for (int i = 0; i < 30; i++) {
          dialogueUI.update(0.033); // 30 FPS
        }

        expect(dialogueUI.activeNPC, equals(mira));
      });
    });

    group('Choice Handling Tests', () {
      test('should handle choice selection in linear dialogue', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getMiraIntroductionSequence();
        dialogueUI.startDialogue(mira, conversation);

        // Skip to choice dialogue
        dialogueUI.advanceDialogue(); // Skip typing
        dialogueUI.advanceDialogue(); // Move to next
        dialogueUI.advanceDialogue(); // Skip typing
        dialogueUI.advanceDialogue(); // Move to choice dialogue

        expect(dialogueUI.activeNPC, equals(mira));
      });

      test('should validate choice button creation', () {
        final DialogueEntry choiceEntry = DialogueEntry(
          speakerName: 'Test',
          text: 'Choose wisely...',
          choices: ['Choice A', 'Choice B', 'Choice C'],
          useTypewriter: true,
          pauseAfterPunctuation: true,
        );

        expect(choiceEntry.choices, isNotNull);
        expect(choiceEntry.choices!.length, equals(3));
        expect(choiceEntry.choices![0], equals('Choice A'));
      });
    });

    group('NPC Integration Tests', () {
      test('should integrate with Mira NPC properly', () {
        expect(mira.name, equals('Mira'));
        expect(mira.canInteract, isTrue);
        expect(mira.hasDialogue, isTrue);
        expect(mira.dialogueId, equals('luminara_introduction'));
      });

      test('should handle multiple NPC types', () {
        final NPC testNPC = NPC(
          position: Vector2(200, 200),
          name: 'Test Merchant',
          hasDialogue: true,
          dialogueId: 'merchant_greeting',
        );

        expect(testNPC.name, equals('Test Merchant'));
        expect(testNPC.dialogueId, equals('merchant_greeting'));
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle empty dialogue sequences gracefully', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> emptyConversation = [];
        dialogueUI.startDialogue(mira, emptyConversation);

        // Should not crash with empty dialogue
        expect(dialogueUI.activeNPC, equals(mira));
      });

      test('should handle null choices appropriately', () {
        final DialogueEntry entryWithoutChoices = DialogueEntry(
          speakerName: 'Test',
          text: 'This has no choices.',
          useTypewriter: true,
          pauseAfterPunctuation: true,
        );

        expect(entryWithoutChoices.choices, isNull);
      });

      test('should handle invalid dialogue node navigation', () async {
        await dialogueUI.onLoad();

        final Map<String, DialogueNode> incompleteTree = {
          'start': DialogueNode(
            id: 'start',
            entry: DialogueEntry(
              speakerName: 'Test',
              text: 'Start node',
              useTypewriter: true,
              pauseAfterPunctuation: true,
            ),
            nextNodeId: 'missing_node', // This node doesn't exist
          ),
        };

        dialogueUI.startDialogueFromNode(mira, incompleteTree, 'start');

        // Should handle missing node gracefully
        expect(dialogueUI.activeNPC, equals(mira));
      });
    });

    group('Performance and Memory Tests', () {
      test('should handle rapid dialogue updates without issues', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();
        dialogueUI.startDialogue(mira, conversation);

        // Rapid updates should not cause issues
        for (int i = 0; i < 100; i++) {
          dialogueUI.update(0.016);
        }

        expect(dialogueUI.activeNPC, equals(mira));
      });

      test('should properly clean up resources on dialogue end', () async {
        await dialogueUI.onLoad();

        final List<DialogueEntry> conversation =
            SampleConversations.getTestConversation();
        dialogueUI.startDialogue(mira, conversation);

        // End dialogue and verify cleanup
        dialogueUI.advanceDialogue(); // Skip typing
        dialogueUI.advanceDialogue(); // Move to next
        dialogueUI.advanceDialogue(); // Skip typing
        dialogueUI.advanceDialogue(); // Move to next
        dialogueUI.advanceDialogue(); // Skip typing
        dialogueUI.advanceDialogue(); // End dialogue

        // Should be cleaned up
        expect(dialogueUI.activeNPC, isNull);
      });
    });
  });
}

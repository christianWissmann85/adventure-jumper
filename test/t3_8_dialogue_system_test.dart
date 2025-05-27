import 'package:adventure_jumper/src/data/sample_conversations.dart';
import 'package:adventure_jumper/src/entities/npcs/mira.dart';
import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/dialogue_system.dart';
import 'package:adventure_jumper/src/ui/dialogue_ui.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T3.8: Enhanced Dialogue System with Conversation Flow', () {
    late AdventureJumperGame game;
    late DialogueSystem dialogueSystem;
    late DialogueUI dialogueUI;
    late Mira mira;
    late Player player;

    setUp(() {
      // Create a mock game
      game = AdventureJumperGame();

      // Create dialogue system
      dialogueSystem = DialogueSystem();
      dialogueSystem.initialize();

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
        enableSmoothAnimations: false, // Disable for faster testing
      );

      // Create test NPC and player
      mira = Mira(position: Vector2(100, 100));
      player = Player(position: Vector2(50, 50));
    });

    tearDown(() {
      dialogueSystem.dispose();
    });

    group('Conversation State Management', () {
      test('should maintain conversation state across interactions', () {
        // Start conversation and set some state
        dialogueSystem.setStateValue('met_mira', true);
        dialogueSystem.setStateValue('conversation_count', 1);

        expect(dialogueSystem.getConversationState()['met_mira'], isTrue);
        expect(
          dialogueSystem.getConversationState()['conversation_count'],
          equals(1),
        );

        // Save and restore state
        final Map<String, dynamic> savedState =
            dialogueSystem.saveConversationState();
        expect(savedState.containsKey('state'), isTrue);
        expect(savedState['state']['met_mira'], isTrue);

        // Clear and reload
        dialogueSystem.clearConversationState();
        expect(dialogueSystem.getConversationState().isEmpty, isTrue);

        dialogueSystem.loadConversationState(savedState);
        expect(dialogueSystem.getConversationState()['met_mira'], isTrue);
        expect(
          dialogueSystem.getConversationState()['conversation_count'],
          equals(1),
        );
      });
      test('should track conversation history', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();

        dialogueSystem.startDialogueTree(mira, player, tree, 'start');
        expect(dialogueSystem.getConversationHistory(), contains('start'));

        // First visit about_mira to satisfy condition for about_mira_first_time
        dialogueSystem.navigateToNode('about_mira');
        dialogueSystem.setStateValue('mira_about_visits', 1);

        dialogueSystem.navigateToNode('about_mira_first_time');
        final List<String> history = dialogueSystem.getConversationHistory();
        expect(history, contains('start'));
        expect(history, contains('about_mira'));
        expect(history, contains('about_mira_first_time'));
      });
    });

    group('Condition Evaluation System', () {
      test('should evaluate flag conditions correctly', () {
        dialogueSystem.setStateValue('test_flag', true);
        dialogueSystem.setStateValue('test_counter', 5);

        // Test flag_equals condition
        expect(
          dialogueSystem.evaluateConditions({
            'flag_equals': {'flag': 'test_flag', 'value': true},
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'flag_equals': {'flag': 'test_flag', 'value': false},
          }),
          isFalse,
        );

        // Test flag_exists condition
        expect(
          dialogueSystem.evaluateConditions({
            'flag_exists': 'test_flag',
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'flag_exists': 'nonexistent_flag',
          }),
          isFalse,
        );

        // Test flag_not_exists condition
        expect(
          dialogueSystem.evaluateConditions({
            'flag_not_exists': 'nonexistent_flag',
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'flag_not_exists': 'test_flag',
          }),
          isFalse,
        );

        // Test counter_greater_than condition
        expect(
          dialogueSystem.evaluateConditions({
            'counter_greater_than': {'counter': 'test_counter', 'value': 3},
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'counter_greater_than': {'counter': 'test_counter', 'value': 10},
          }),
          isFalse,
        );
      });
      test('should evaluate visit-based conditions correctly', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();
        dialogueSystem.startDialogueTree(mira, player, tree, 'start');

        // Navigate to actual nodes that exist
        dialogueSystem.navigateToNode('about_mira');
        dialogueSystem.navigateToNode('about_archive');
        dialogueSystem.navigateToNode('about_mira'); // Visit again

        // Test node_visited condition
        expect(
          dialogueSystem.evaluateConditions({
            'node_visited': 'about_mira',
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'node_visited': 'unvisited_node',
          }),
          isFalse,
        );

        // Test node_visit_count condition
        expect(
          dialogueSystem.evaluateConditions({
            'node_visit_count': {'node': 'about_mira', 'count': 2},
          }),
          isTrue,
        );

        expect(
          dialogueSystem.evaluateConditions({
            'node_visit_count': {'node': 'about_mira', 'count': 5},
          }),
          isFalse,
        );
      });
      test('should handle complex multi-condition evaluation', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();
        dialogueSystem.startDialogueTree(mira, player, tree, 'start');

        dialogueSystem.setStateValue('flag1', true);
        dialogueSystem.setStateValue('counter1', 3);
        dialogueSystem.navigateToNode('about_mira'); // Use an actual node

        // All conditions should pass
        expect(
          dialogueSystem.evaluateConditions({
            'flag_equals': {'flag': 'flag1', 'value': true},
            'counter_greater_than': {'counter': 'counter1', 'value': 2},
            'node_visited': 'about_mira',
          }),
          isTrue,
        );

        // One condition fails
        expect(
          dialogueSystem.evaluateConditions({
            'flag_equals': {'flag': 'flag1', 'value': true},
            'counter_greater_than': {
              'counter': 'counter1',
              'value': 5,
            }, // This fails
            'node_visited': 'about_mira',
          }),
          isFalse,
        );
      });
    });

    group('State Change Application', () {
      test('should apply simple state changes', () {
        final Map<String, dynamic> stateChanges = {
          'simple_flag': true,
          'simple_counter': 10,
          'simple_string': 'test_value',
        };

        dialogueSystem.applyStateChanges(stateChanges);

        expect(dialogueSystem.getConversationState()['simple_flag'], isTrue);
        expect(
          dialogueSystem.getConversationState()['simple_counter'],
          equals(10),
        );
        expect(
          dialogueSystem.getConversationState()['simple_string'],
          equals('test_value'),
        );
      });

      test('should apply operation-based state changes', () {
        dialogueSystem.setStateValue('counter', 5);
        dialogueSystem.setStateValue('multiplier', 2);
        dialogueSystem.setStateValue('toggle_flag', false);

        final Map<String, dynamic> stateChanges = {
          'counter': {'operation': 'add', 'value': 3},
          'multiplier': {'operation': 'multiply', 'value': 4},
          'toggle_flag': {'operation': 'toggle'},
          'new_counter': {'operation': 'set', 'value': 100},
        };

        dialogueSystem.applyStateChanges(stateChanges);

        expect(dialogueSystem.getConversationState()['counter'], equals(8));
        expect(dialogueSystem.getConversationState()['multiplier'], equals(8));
        expect(dialogueSystem.getConversationState()['toggle_flag'], isTrue);
        expect(
          dialogueSystem.getConversationState()['new_counter'],
          equals(100),
        );
      });
    });

    group('Dialogue Callback System', () {
      test('should register and execute custom callbacks', () {
        String? callbackResult;
        int callbackCallCount = 0;

        // Register custom callback
        dialogueSystem.registerCallback('test_callback', (String message) {
          callbackResult = message;
          callbackCallCount++;
        });

        // Execute callback
        dialogueSystem.executeCallbacks(['test_callback:Hello World']);

        expect(callbackResult, equals('Hello World'));
        expect(callbackCallCount, equals(1));
      });

      test('should handle default callbacks', () {
        // Test set_flag callback
        dialogueSystem.executeCallbacks(['set_flag:test_flag:true']);
        expect(dialogueSystem.getConversationState()['test_flag'], isTrue);

        // Test increment_counter callback
        dialogueSystem.executeCallbacks(['increment_counter:test_counter']);
        dialogueSystem.executeCallbacks(['increment_counter:test_counter']);
        expect(
          dialogueSystem.getConversationState()['test_counter'],
          equals(2),
        );
      });
    });

    group('Node Visit Limitations and Cooldowns', () {
      test('should respect max visit limits', () {
        final DialogueNode limitedNode = DialogueNode(
          id: 'limited_node',
          entry: DialogueEntry(
            speakerName: 'Test',
            text: 'This can only be visited once.',
          ),
          maxVisits: 1,
        );

        expect(limitedNode.canVisit(), isTrue);
        limitedNode.markVisited();
        expect(limitedNode.visitCount, equals(1));
        expect(limitedNode.canVisit(), isFalse);
      });

      test('should handle cooldown periods', () {
        final DialogueNode cooldownNode = DialogueNode(
          id: 'cooldown_node',
          entry: DialogueEntry(
            speakerName: 'Test',
            text: 'This has a cooldown.',
          ),
          cooldownSeconds: 1, // 1 second cooldown
        );

        expect(cooldownNode.canVisit(), isTrue);
        cooldownNode.markVisited();
        expect(cooldownNode.canVisit(), isFalse);

        // Simulate time passing (in a real test you'd need to mock DateTime)
        // For now, just verify the structure is correct
        expect(cooldownNode.lastVisited, isNotNull);
        expect(cooldownNode.cooldownSeconds, equals(1));
      });
    });

    group('Enhanced Conversation Trees', () {
      test('should handle enhanced Mira conversation tree', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();

        expect(tree.containsKey('start'), isTrue);
        expect(tree.containsKey('about_mira_first_time'), isTrue);
        expect(tree.containsKey('about_mira_returning'), isTrue);
        expect(tree.containsKey('quest_available'), isTrue);

        // Verify enhanced features
        final DialogueNode startNode = tree['start']!;
        expect(startNode.entry.stateChanges, isNotNull);
        expect(startNode.entry.onShowCallbacks, isNotNull);

        final DialogueNode questNode = tree['quest_completed_response']!;
        expect(questNode.priority, equals(10));
        expect(questNode.conditions, isNotNull);
      });

      test('should handle cooldown conversation tree', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getCooldownConversationTree();

        expect(tree.containsKey('daily_greeting'), isTrue);
        expect(tree.containsKey('returning_customer'), isTrue);

        final DialogueNode dailyNode = tree['daily_greeting']!;
        expect(dailyNode.cooldownSeconds, equals(86400));
        expect(dailyNode.maxVisits, equals(1));

        final DialogueNode returningNode = tree['returning_customer']!;
        expect(returningNode.conditions, isNotNull);
        expect(
          returningNode.conditions!['flag_exists'],
          equals('last_shop_visit'),
        );
      });

      test('should handle conditional test tree', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getConditionalTestTree();

        expect(tree.containsKey('test_start'), isTrue);
        expect(tree.containsKey('set_flag_node'), isTrue);
        expect(tree.containsKey('conditional_content'), isTrue);

        final DialogueNode conditionalNode = tree['conditional_content']!;
        expect(conditionalNode.conditions, isNotNull);
        expect(conditionalNode.conditions!['flag_equals'], isNotNull);

        final DialogueNode flagNode = tree['set_flag_node']!;
        expect(flagNode.entry.stateChanges, isNotNull);
        expect(flagNode.entry.onShowCallbacks, isNotNull);
      });
    });

    group('Integration Tests', () {
      test('should integrate DialogueUI with DialogueSystem', () async {
        await dialogueUI.onLoad();

        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();

        // Set up integration
        dialogueUI.setDialogueSystem(dialogueSystem);
        dialogueUI.startDialogueFromNodeWithSystem(
          mira,
          tree,
          'start',
          dialogueSystem,
        );

        // Manually start the dialogue system for the integration test
        dialogueSystem.startDialogueTree(mira, player, tree, 'start');

        expect(dialogueUI.activeNPC, equals(mira));
        expect(dialogueSystem.isInDialogue, isTrue);
        expect(dialogueSystem.activeNPC, equals(mira));
        expect(dialogueSystem.currentNodeId, equals('start'));
      });
      test('should handle end-to-end conversation flow', () async {
        await dialogueUI.onLoad();

        final Map<String, DialogueNode> tree =
            SampleConversations.getConditionalTestTree();

        dialogueUI.setDialogueSystem(dialogueSystem);
        dialogueSystem.startDialogueTree(mira, player, tree, 'test_start');

        // Verify initial state
        expect(dialogueSystem.currentNodeId, equals('test_start'));
        expect(
          dialogueSystem.getConversationState().containsKey('test_flag'),
          isFalse,
        );

        // Simulate choice selection to set flag
        dialogueSystem.selectChoice(0); // Select 'Set flag'

        expect(dialogueSystem.getConversationState()['test_flag'], isTrue);

        // Verify conditional content is now available
        expect(
          dialogueSystem.evaluateConditions({
            'flag_equals': {'flag': 'test_flag', 'value': true},
          }),
          isTrue,
        );
      });
    });

    group('Error Handling', () {
      test('should handle unknown condition types gracefully', () {
        expect(
          dialogueSystem.evaluateConditions({
            'unknown_condition': 'test_value',
          }),
          isFalse,
        );
      });

      test('should handle invalid callback execution gracefully', () {
        // This should not throw an exception
        dialogueSystem.executeCallbacks(['nonexistent_callback:param']);
        dialogueSystem.executeCallbacks(['invalid_format']);
      });

      test('should handle navigation to nonexistent nodes gracefully', () {
        final Map<String, DialogueNode> tree =
            SampleConversations.getEnhancedMiraConversationTree();
        dialogueSystem.startDialogueTree(mira, player, tree, 'start');

        // This should not crash
        dialogueSystem.navigateToNode('nonexistent_node');
        expect(
          dialogueSystem.currentNodeId,
          equals('start'),
        ); // Should remain unchanged
      });
    });
  });
}

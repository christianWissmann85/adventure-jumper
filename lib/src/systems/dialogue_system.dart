// No need for import 'package:flame/components.dart' since we're not using Component

import '../entities/entity.dart';
import '../entities/npc.dart';
import '../player/player.dart';
import '../ui/dialogue_ui.dart';
import 'base_system.dart';

/// System that manages dialogue interactions between player and NPCs
/// Handles dialogue trees, choice processing, and conversation state
class DialogueSystem extends BaseSystem {
  DialogueSystem() : super();

  // Currently active dialogue - will be implemented in Sprint 2
  NPC? _activeNPC;
  // TODO(christian): Implement usage of _currentDialogue in Sprint 2 for displaying current dialogue text.
  // ignore: unused_field
  String? _currentDialogue;
  final List<String> _dialogueChoices = <String>[];
  bool _isInDialogue = false;

  // Enhanced conversation state for T3.8
  final Map<String, dynamic> _conversationState = <String, dynamic>{};
  final Map<String, DialogueNode> _currentConversationNodes =
      <String, DialogueNode>{};
  String? _currentNodeId;
  final List<String> _conversationHistory = <String>[];
  final Map<String, int> _nodeVisitCounts = <String, int>{};
  final Map<String, DateTime> _nodeLastVisited = <String, DateTime>{};

  // Callbacks for dialogue events
  final Map<String, Function> _dialogueCallbacks = <String, Function>{};

  @override
  void processEntity(Entity entity, double dt) {
    // This will be implemented in Sprint 2
    // Currently we don't have any per-entity dialogue processing
  }
  @override
  void processSystem(double dt) {
    // Update dialogue state and handle auto-advance timers
    if (_isInDialogue && _currentNodeId != null) {
      _updateConversationState(dt);
    }
  }

  @override
  void initialize() {
    // Initialize dialogue callbacks
    _setupDefaultCallbacks();
  }

  @override
  void dispose() {
    endDialogue();
    _dialogueCallbacks.clear();
  }

  @override
  void addEntity(Entity entity) {
    // TODO(dialog): Add entity to dialogue system
  }

  @override
  void removeEntity(Entity entity) {
    // TODO(dialog): Remove entity from dialogue system
  }

  /// Start dialogue with an NPC using conversation tree
  void startDialogueTree(
    NPC npc,
    Player player,
    Map<String, DialogueNode> nodes,
    String startNodeId,
  ) {
    _activeNPC = npc;
    _isInDialogue = true;
    _currentConversationNodes.clear();
    _currentConversationNodes.addAll(nodes);

    // Navigate to starting node
    navigateToNode(startNodeId);
  }

  /// Navigate to a specific dialogue node
  void navigateToNode(String nodeId) {
    final DialogueNode? node = _currentConversationNodes[nodeId];
    if (node == null) {
      print('Warning: Dialogue node "$nodeId" not found');
      return;
    }

    // Check if node can be visited
    if (!node.canVisit()) {
      print(
        'Warning: Node "$nodeId" cannot be visited (cooldown or visit limit)',
      );
      return;
    } // Evaluate conditions
    if (!evaluateConditions(node.conditions)) {
      print('Warning: Node "$nodeId" conditions not met');
      return;
    } // Update state
    _currentNodeId = nodeId;
    node.markVisited();
    _conversationHistory.add(nodeId);

    // Populate dialogue choices from current node
    _dialogueChoices.clear();
    if (node.entry.choices != null) {
      _dialogueChoices.addAll(node.entry.choices!);
    }

    // Apply state changes from dialogue entry
    applyStateChanges(node.entry.stateChanges);

    // Execute callbacks
    executeCallbacks(node.entry.onShowCallbacks);
  }

  /// Update conversation state over time
  void _updateConversationState(double dt) {
    // Handle auto-advance timers and other time-based updates
    // This can be expanded for time-based dialogue features
  }

  /// Setup default dialogue callbacks
  void _setupDefaultCallbacks() {
    _dialogueCallbacks['debug_print'] = (String message) {
      print('Dialogue Debug: $message');
    };

    _dialogueCallbacks['set_flag'] = (String flag, String value) {
      // Convert string value to appropriate type
      dynamic convertedValue;
      if (value.toLowerCase() == 'true') {
        convertedValue = true;
      } else if (value.toLowerCase() == 'false') {
        convertedValue = false;
      } else if (int.tryParse(value) != null) {
        convertedValue = int.parse(value);
      } else if (double.tryParse(value) != null) {
        convertedValue = double.parse(value);
      } else {
        convertedValue = value; // Keep as string
      }
      _conversationState[flag] = convertedValue;
    };

    _dialogueCallbacks['increment_counter'] = (String counter) {
      _conversationState[counter] = (_conversationState[counter] ?? 0) + 1;
    };
  }

  /// Evaluate conditions for dialogue display (public for testing)
  bool evaluateConditions(Map<String, dynamic>? conditions) {
    if (conditions == null || conditions.isEmpty) {
      return true;
    }

    for (final MapEntry<String, dynamic> condition in conditions.entries) {
      if (!_evaluateSingleCondition(condition.key, condition.value)) {
        return false;
      }
    }

    return true;
  }

  /// Evaluate a single condition
  bool _evaluateSingleCondition(String key, dynamic value) {
    switch (key) {
      case 'flag_equals':
        final Map<String, dynamic> flagCheck = value as Map<String, dynamic>;
        final String flagName = flagCheck['flag'] as String;
        final dynamic expectedValue = flagCheck['value'];
        return _conversationState[flagName] == expectedValue;
      case 'flag_exists':
        return _conversationState.containsKey(value as String);

      case 'flag_not_exists':
        return !_conversationState.containsKey(value as String);

      case 'counter_greater_than':
        final Map<String, dynamic> counterCheck = value as Map<String, dynamic>;
        final String counterName = counterCheck['counter'] as String;
        final int threshold = counterCheck['value'] as int;
        return (_conversationState[counterName] ?? 0) > threshold;

      case 'node_visited':
        return _conversationHistory.contains(value as String);

      case 'node_visit_count':
        final Map<String, dynamic> visitCheck = value as Map<String, dynamic>;
        final String nodeId = visitCheck['node'] as String;
        final int expectedCount = visitCheck['count'] as int;
        final int actualCount =
            _conversationHistory.where((id) => id == nodeId).length;
        return actualCount >= expectedCount;

      default:
        print('Unknown condition type: $key');
        return false;
    }
  }

  /// Apply state changes from dialogue (public for testing)
  void applyStateChanges(Map<String, dynamic>? stateChanges) {
    if (stateChanges == null) return;

    for (final MapEntry<String, dynamic> change in stateChanges.entries) {
      final String key = change.key;
      final dynamic value = change.value;

      if (value is Map<String, dynamic>) {
        final String operation = value['operation'] as String? ?? 'set';
        final dynamic operationValue = value['value'];

        switch (operation) {
          case 'set':
            _conversationState[key] = operationValue;
            break;
          case 'add':
            _conversationState[key] =
                (_conversationState[key] ?? 0) + (operationValue as num);
            break;
          case 'multiply':
            _conversationState[key] =
                (_conversationState[key] ?? 1) * (operationValue as num);
            break;
          case 'toggle':
            _conversationState[key] = !(_conversationState[key] ?? false);
            break;
        }
      } else {
        _conversationState[key] = value;
      }
    }
  }

  /// Execute dialogue callbacks (public for testing)
  void executeCallbacks(List<String>? callbacks) {
    if (callbacks == null) return;

    for (final String callback in callbacks) {
      final List<String> parts = callback.split(':');
      final String callbackName = parts[0];

      if (_dialogueCallbacks.containsKey(callbackName)) {
        final Function callbackFunction = _dialogueCallbacks[callbackName]!;

        if (parts.length > 1) {
          // Parse parameters
          final List<String> params = parts.sublist(1);
          try {
            Function.apply(callbackFunction, params);
          } catch (e) {
            print('Error executing callback "$callbackName": $e');
          }
        } else {
          try {
            callbackFunction();
          } catch (e) {
            print('Error executing callback "$callbackName": $e');
          }
        }
      } else {
        print('Unknown callback: $callbackName');
      }
    }
  }

  /// Register a custom dialogue callback
  void registerCallback(String name, Function callback) {
    _dialogueCallbacks[name] = callback;
  }

  /// Get current conversation state
  Map<String, dynamic> getConversationState() {
    return Map<String, dynamic>.from(_conversationState);
  }

  /// Set conversation state value
  void setStateValue(String key, dynamic value) {
    _conversationState[key] = value;
  }

  /// Get conversation history
  List<String> getConversationHistory() {
    return List<String>.from(_conversationHistory);
  }

  /// Check if currently in dialogue
  bool get isInDialogue => _isInDialogue;

  /// Get current NPC
  NPC? get activeNPC => _activeNPC;

  /// Get current node ID
  String? get currentNodeId => _currentNodeId;

  /// Get current dialogue choices
  List<String> get dialogueChoices => List.unmodifiable(_dialogueChoices);

  /// Start dialogue with an NPC
  void startDialogue(NPC npc, Player player) {
    _activeNPC = npc;
    _isInDialogue = true;
    // TODO(dialog): Implement dialogue start logic
  }

  /// End current dialogue
  void endDialogue() {
    _activeNPC = null;
    _currentDialogue = null;
    _dialogueChoices.clear();
    _isInDialogue = false;
    _currentNodeId = null;
    _currentConversationNodes.clear();
    // Keep conversation state and history for persistence
  }

  /// Process dialogue choice
  void selectChoice(int choiceIndex) {
    if (choiceIndex >= 0 && choiceIndex < _dialogueChoices.length) {
      final String selectedChoice = _dialogueChoices[choiceIndex];

      // Navigate based on choice if using node system
      if (_currentNodeId != null) {
        final DialogueNode? currentNode =
            _currentConversationNodes[_currentNodeId];
        if (currentNode?.choiceNodeIds != null) {
          final String? nextNodeId =
              currentNode!.choiceNodeIds![selectedChoice];
          if (nextNodeId != null) {
            navigateToNode(nextNodeId);
          }
        }
      }
    }
  }

  /// Clear conversation state (for testing or new game)
  void clearConversationState() {
    _conversationState.clear();
    _conversationHistory.clear();
    _nodeVisitCounts.clear();
    _nodeLastVisited.clear();
  }

  /// Save conversation state to external storage
  Map<String, dynamic> saveConversationState() {
    return {
      'state': Map<String, dynamic>.from(_conversationState),
      'history': List<String>.from(_conversationHistory),
      'visitCounts': Map<String, int>.from(_nodeVisitCounts),
      'lastVisited': _nodeLastVisited
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
    };
  }

  /// Load conversation state from external storage
  void loadConversationState(Map<String, dynamic> savedData) {
    _conversationState.clear();
    _conversationHistory.clear();
    _nodeVisitCounts.clear();
    _nodeLastVisited.clear();

    if (savedData.containsKey('state')) {
      _conversationState.addAll(savedData['state'] as Map<String, dynamic>);
    }

    if (savedData.containsKey('history')) {
      _conversationHistory
          .addAll((savedData['history'] as List).cast<String>());
    }

    if (savedData.containsKey('visitCounts')) {
      _nodeVisitCounts
          .addAll((savedData['visitCounts'] as Map).cast<String, int>());
    }

    if (savedData.containsKey('lastVisited')) {
      final Map<String, dynamic> lastVisitedData =
          savedData['lastVisited'] as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in lastVisitedData.entries) {
        _nodeLastVisited[entry.key] =
            DateTime.fromMillisecondsSinceEpoch(entry.value as int);
      }
    }
  }
}

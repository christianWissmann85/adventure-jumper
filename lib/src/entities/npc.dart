import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/ai_component.dart';
import 'entity.dart';

/// T3.4.2: NPC interaction states
enum NPCInteractionState {
  idle,
  talking,
  busy,
}

/// Non-player character base class
/// Handles interaction, dialogue, and quest-related behaviors
class NPC extends Entity {
  NPC({
    required super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
    String? name,
    bool? canInteract,
    bool? hasDialogue,
    bool? hasQuest,
    String? dialogueId,
    String? questId,
    double? interactionRange,
    double? visualFeedbackRange,
  }) : super(
          type: 'npc',
        ) {
    if (name != null) _name = name;
    if (canInteract != null) _canInteract = canInteract;
    if (hasDialogue != null) _hasDialogue = hasDialogue;
    if (hasQuest != null) _hasQuest = hasQuest;
    if (dialogueId != null) _dialogueId = dialogueId;
    if (questId != null) _questId = questId;
    if (interactionRange != null) _interactionRange = interactionRange;
    if (visualFeedbackRange != null) _visualFeedbackRange = visualFeedbackRange;
  } // NPC-specific components
  late AIComponent ai;

  // NPC properties
  String _name = 'Unknown NPC';
  bool _canInteract = true;
  bool _hasDialogue = true;
  bool _hasQuest = false;
  String _dialogueId = '';
  String _questId = '';

  // T3.4.1: Interaction range detection
  double _interactionRange = 100.0;
  double _visualFeedbackRange = 150.0;

  // T3.4.2: Interaction state management
  NPCInteractionState _interactionState = NPCInteractionState.idle;
  double _stateChangeTime = 0.0;

  // T3.4.3: Dialogue trigger system
  bool _dialogueTriggered = false;
  bool _questOffered = false;

  // T3.4.5: Visual feedback for interaction availability
  bool _showingInteractionPrompt = false;
  double _promptPulseTimer = 0.0;

  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

    // Add NPC-specific components
    ai = AIComponent();
    add(ai);

    await setupNPC();
  }

  @override
  void updateEntity(double dt) {
    super.updateEntity(dt);

    // T3.4.6: Update timers
    _stateChangeTime += dt;
    _promptPulseTimer += dt;

    // NPC-specific update logic (idle animations, movement patterns)
    updateNPC(dt);

    // T3.4.4: Update AI state machine
    updateAIStateMachine(dt);

    // T3.4.5: Update visual feedback
    updateVisualFeedback(dt);
  }

  /// Custom NPC setup (to be implemented by subclasses)
  Future<void> setupNPC() async {
    // Override in subclasses
  }

  /// Custom NPC update logic (to be implemented by subclasses)
  void updateNPC(double dt) {
    // Override in subclasses
  }

  /// T3.4.4: Update AI state machine for NPCs
  void updateAIStateMachine(double dt) {
    // Sync AI component state with NPC interaction state
    switch (_interactionState) {
      case NPCInteractionState.idle:
        // Allow normal AI behavior when idle
        break;
      case NPCInteractionState.talking:
        // Override AI to stay in place during dialogue
        ai.setState('idle');
        break;
      case NPCInteractionState.busy:
        // Override AI with specific busy behavior
        ai.setState('idle');
        break;
    }
  }

  /// T3.4.5: Update visual feedback for interaction availability
  void updateVisualFeedback(double dt) {
    // Pulse the interaction prompt when available
    if (_showingInteractionPrompt) {
      final double pulseSpeed = 2.0;
      final double pulse =
          (math.sin(_promptPulseTimer * pulseSpeed) + 1.0) / 2.0;
      // Visual feedback would be implemented with actual UI components
      // This provides the logic foundation for visual indicators
      // The pulse value (0.0 to 1.0) can be used for opacity, scale, or color intensity
      assert(pulse >= 0.0 && pulse <= 1.0, 'Pulse value should be normalized');
    }
  }

  /// Handle player interaction
  bool interact() {
    if (!_canInteract || _interactionState != NPCInteractionState.idle) {
      return false;
    }

    // T3.4.2: Change to talking state
    setInteractionState(NPCInteractionState.talking);

    // T3.4.3: Trigger dialogue system
    if (_hasDialogue && !_dialogueTriggered) {
      startDialogue();
      _dialogueTriggered = true;
    }

    // T3.4.3: Trigger quest system
    if (_hasQuest && !_questOffered) {
      offerQuest();
      _questOffered = true;
    }

    return true;
  }

  /// Start dialogue with the player
  void startDialogue() {
    // T3.4.3: Enhanced dialogue trigger system
    // This will integrate with DialogueSystem in future implementations
    // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
    print('$_name: Starting dialogue with ID: $_dialogueId');
  }

  /// Offer quest to the player
  void offerQuest() {
    // T3.4.3: Enhanced quest trigger system
    // This will integrate with QuestSystem in future implementations
    // TODO: Migrate to structured logging - see docs/05_Style_Guides/LoggingStyle.md
    print('$_name: Offering quest with ID: $_questId');
  }

  /// T3.4.2: Set NPC interaction state
  void setInteractionState(NPCInteractionState newState) {
    if (_interactionState != newState) {
      _interactionState = newState;
      _stateChangeTime = 0.0;

      // Update visual feedback based on state
      _showingInteractionPrompt =
          (newState == NPCInteractionState.idle && _canInteract);
    }
  }

  /// T3.4.2: End current interaction and return to idle
  void endInteraction() {
    setInteractionState(NPCInteractionState.idle);
    _dialogueTriggered = false;
    _questOffered = false;
  }

  /// T3.4.1: Enhanced interaction range detection with multiple ranges
  bool isInInteractionRange(
    Vector2 playerPosition, {
    double? customRange,
  }) {
    final double range = customRange ?? _interactionRange;
    final double distance = position.distanceTo(playerPosition);
    return distance <= range;
  }

  /// T3.4.1: Check if player is within visual feedback range
  bool isInVisualFeedbackRange(Vector2 playerPosition) {
    final double distance = position.distanceTo(playerPosition);
    return distance <= _visualFeedbackRange;
  }

  /// T3.4.1: Get exact distance to player for proximity-based behaviors
  double getDistanceToPlayer(Vector2 playerPosition) {
    return position.distanceTo(playerPosition);
  }

  /// T3.4.6: Update interaction availability based on player proximity
  void updateInteractionAvailability(Vector2 playerPosition) {
    final bool inVisualRange = isInVisualFeedbackRange(playerPosition);
    final bool inInteractionRange = isInInteractionRange(playerPosition);

    // Show interaction prompt when in visual range and can interact
    _showingInteractionPrompt = inVisualRange &&
        _canInteract &&
        _interactionState == NPCInteractionState.idle;

    // Auto-end interaction if player moves too far away
    if (_interactionState == NPCInteractionState.talking &&
        !inInteractionRange) {
      endInteraction();
    }
  }

  // Getters and setters
  String get name => _name;
  bool get canInteract => _canInteract;
  bool get hasDialogue => _hasDialogue;
  bool get hasQuest => _hasQuest;
  String get dialogueId => _dialogueId;
  String get questId => _questId;

  // T3.4.1: Interaction range getters and setters
  double get interactionRange => _interactionRange;
  set interactionRange(double range) => _interactionRange = range;
  double get visualFeedbackRange => _visualFeedbackRange;
  set visualFeedbackRange(double range) => _visualFeedbackRange = range;

  // T3.4.2: Interaction state getters
  NPCInteractionState get interactionState => _interactionState;
  bool get isIdle => _interactionState == NPCInteractionState.idle;
  bool get isTalking => _interactionState == NPCInteractionState.talking;
  bool get isBusy => _interactionState == NPCInteractionState.busy;
  double get stateChangeTime => _stateChangeTime;

  // T3.4.3: Dialogue and quest status
  bool get dialogueTriggered => _dialogueTriggered;
  bool get questOffered => _questOffered;

  // T3.4.5: Visual feedback status
  bool get showingInteractionPrompt => _showingInteractionPrompt;
  double get promptPulseTimer => _promptPulseTimer;
}

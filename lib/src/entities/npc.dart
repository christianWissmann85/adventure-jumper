import 'package:flame/components.dart';

import '../components/ai_component.dart';
import 'entity.dart';

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
  }) : super(
          type: 'npc',
        ) {
    if (name != null) _name = name;
    if (canInteract != null) _canInteract = canInteract;
    if (hasDialogue != null) _hasDialogue = hasDialogue;
    if (hasQuest != null) _hasQuest = hasQuest;
    if (dialogueId != null) _dialogueId = dialogueId;
    if (questId != null) _questId = questId;
  }
  // NPC-specific components
  late AIComponent ai;

  // NPC properties
  String _name = 'Unknown NPC';
  bool _canInteract = true;
  bool _hasDialogue = true;
  bool _hasQuest = false;
  String _dialogueId = '';
  String _questId = '';

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

    // NPC-specific update logic (idle animations, movement patterns)
    updateNPC(dt);
  }

  /// Custom NPC setup (to be implemented by subclasses)
  Future<void> setupNPC() async {
    // Override in subclasses
  }

  /// Custom NPC update logic (to be implemented by subclasses)
  void updateNPC(double dt) {
    // Override in subclasses
  }

  /// Handle player interaction
  bool interact() {
    if (!_canInteract) return false;

    if (_hasDialogue) {
      startDialogue();
    }

    if (_hasQuest) {
      offerQuest();
    }

    return true;
  }

  /// Start dialogue with the player
  void startDialogue() {
    // Implementation needed: Trigger dialogue system with dialogueId
  }

  /// Offer quest to the player
  void offerQuest() {
    // Implementation needed: Trigger quest system with questId
  }

  /// Check if NPC is within interaction range of the player
  bool isInInteractionRange(
    Vector2 playerPosition, {
    double interactionRange = 100.0,
  }) {
    final double distance = position.distanceTo(playerPosition);
    return distance <= interactionRange;
  }

  // Getters
  String get name => _name;
  bool get canInteract => _canInteract;
  bool get hasDialogue => _hasDialogue;
  bool get hasQuest => _hasQuest;
  String get dialogueId => _dialogueId;
  String get questId => _questId;
}

import 'dart:math' as math;

import 'package:flame/components.dart';

import '../npc.dart';

/// Mira the Archivist - Keeper Scholar & Mentor
/// Specific implementation of the NPC class for Mira character in Luminara Hub
class Mira extends NPC {
  Mira({
    required super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
  }) : super(
          name: 'Mira',
          canInteract: true,
          hasDialogue: true,
          hasQuest: true,
          dialogueId: 'luminara_introduction',
          questId: 'first_steps',
          interactionRange: 120.0,
          visualFeedbackRange: 180.0,
        );

  // T3.5.1: Mira-specific personality traits and properties
  static const String characterType = 'mira';
  static const String personalityType = 'stern_mentor';

  // Character appearance constants
  static const String spriteBasePath = 'images/characters/npcs/mira';
  static const String clothingColor = '#0066CC'; // Flowing blue robes
  static const String hairColor = '#C0C0C0'; // Silver hair
  static const String accessoryColor = '#FFD700'; // Golden spectacles and tome

  // T3.5.2: Idle animation properties
  double _idleAnimationTimer = 0.0;
  double _idleAnimationSpeed = 0.8;
  int _currentIdleFrame = 0;
  static const int _maxIdleFrames = 6;

  // Reading animation properties (Mira-specific behavior)
  double _readingTimer = 0.0;
  double _readingDuration = 8.0; // Time spent reading before looking up
  bool _isReading = false;

  // Quill animation properties (Mira's floating quill)
  double _quillBobTimer = 0.0;
  final Vector2 _quillOffset = Vector2(25, -15);
  double _quillBobAmplitude = 3.0;
  double _quillBobSpeed = 2.5;

  // T3.5.3: Dialogue state tracking
  bool _hasIntroducedSelf = false;
  bool _hasExplainedKeepers = false;
  bool _hasGivenFirstQuest = false;
  int _conversationDepth = 0;
  @override
  Future<void> setupNPC() async {
    // T3.5.1: Configure Mira's specific AI and interaction settings
    // Check if AI component is available (for testing compatibility)
    try {
      ai.detectionRange = 200.0;
      ai.attackRange = 0.0; // Mira doesn't attack

      // Set up Mira's patrol behavior (she moves around the archive)
      ai.clearPatrolPoints();
      ai.addPatrolPoint(Vector2(position.x - 50, position.y));
      ai.addPatrolPoint(Vector2(position.x + 80, position.y));
      ai.addPatrolPoint(Vector2(position.x + 20, position.y - 30));
      ai.addPatrolPoint(Vector2(position.x - 20, position.y + 20));
    } catch (e) {
      // AI component not initialized (likely in test environment)
      print('Mira: AI component not available - running in test mode');
    }

    // T3.5.4: Configure interaction ranges for a scholar NPC
    interactionRange = 120.0; // Slightly larger for a mentor figure
    visualFeedbackRange = 180.0; // Shows interaction prompt from further away

    print('Mira NPC initialized at position: $position in Keeper\'s Archive');
  }

  @override
  void updateNPC(double dt) {
    // T3.5.2: Update idle animations and behaviors
    _updateIdleAnimation(dt);
    _updateReadingBehavior(dt);
    _updateQuillAnimation(dt);

    // T3.5.2: Scholar-specific behaviors based on interaction state
    _updateScholarBehaviors(dt);
  }

  /// T3.5.2: Update Mira's idle animation cycle
  void _updateIdleAnimation(double dt) {
    _idleAnimationTimer += dt;

    if (_idleAnimationTimer >= _idleAnimationSpeed) {
      _currentIdleFrame = (_currentIdleFrame + 1) % _maxIdleFrames;
      _idleAnimationTimer = 0.0;

      // Add slight variation to animation speed for natural feel
      _idleAnimationSpeed = 0.7 + (math.Random().nextDouble() * 0.2);
    }
  }

  /// T3.5.2: Update Mira's reading behavior (unique to her character)
  void _updateReadingBehavior(double dt) {
    if (interactionState == NPCInteractionState.idle) {
      _readingTimer += dt;

      if (!_isReading && _readingTimer >= 2.0) {
        // Start reading behavior
        _isReading = true;
        _readingTimer = 0.0;
        try {
          ai.setState('idle'); // Stop moving when reading
        } catch (e) {
          // AI not available (test environment)
        }
      } else if (_isReading && _readingTimer >= _readingDuration) {
        // Stop reading, look around
        _isReading = false;
        _readingTimer = 0.0;
        _readingDuration =
            6.0 + (math.Random().nextDouble() * 4.0); // 6-10 seconds
      }
    } else {
      // Not idle, stop reading
      _isReading = false;
      _readingTimer = 0.0;
    }
  }

  /// T3.5.2: Update floating quill animation (Mira's magical quill)
  void _updateQuillAnimation(double dt) {
    _quillBobTimer += dt;

    // Calculate quill position with subtle floating motion
    final double bobOffset =
        math.sin(_quillBobTimer * _quillBobSpeed) * _quillBobAmplitude;

    // The quill position would be used for rendering
    // This provides the logic foundation for visual effects
    final Vector2 quillWorldPosition = Vector2(
      position.x + _quillOffset.x,
      position.y + _quillOffset.y + bobOffset,
    );

    // Quill responds to Mira's interaction state
    if (interactionState == NPCInteractionState.talking) {
      _quillBobSpeed = 3.5; // Faster when talking
      _quillBobAmplitude = 5.0;
    } else if (_isReading) {
      _quillBobSpeed = 1.5; // Slower when reading
      _quillBobAmplitude = 2.0;
    } else {
      _quillBobSpeed = 2.5; // Normal speed
      _quillBobAmplitude = 3.0;
    } // Visual system would use quillWorldPosition for rendering
    assert(
      quillWorldPosition.x.isFinite && quillWorldPosition.y.isFinite,
      'Quill position should be valid',
    );
  }

  /// T3.5.2: Update scholar-specific behaviors
  void _updateScholarBehaviors(double dt) {
    switch (interactionState) {
      case NPCInteractionState.idle:
        // Mira studies, organizes books, occasionally looks at crystals
        _performIdleScholarActions();
        break;

      case NPCInteractionState.talking:
        // Mira is attentive, gestures with knowledge orbs
        _performDialogueActions();
        break;

      case NPCInteractionState.busy:
        // Mira is deep in research, harder to interrupt
        _performBusyScholarActions();
        break;
    }
  }

  /// Idle scholar actions (reading, organizing, studying)
  void _performIdleScholarActions() {
    // Logic for idle scholar behavior
    // This would control animation state selection

    if (_isReading) {
      // Use reading animation
      // Current frame indicates reading pose
    } else {
      // Use idle animation with occasional look-around
      // _currentIdleFrame provides animation frame
    }
  }

  /// Dialogue actions (attentive, teaching gestures)
  void _performDialogueActions() {
    // Mira is engaged in conversation
    // More animated gestures, direct eye contact
    // Knowledge orbs might appear during explanations
  }

  /// Busy scholar actions (deep research, less responsive)
  void _performBusyScholarActions() {
    // Mira is absorbed in important research
    // Minimal animation, focused on work
    // Requires more effort to get attention
  }

  @override
  bool interact() {
    // T3.5.3: Enhanced interaction with dialogue progression tracking
    if (!canInteract || interactionState != NPCInteractionState.idle) {
      return false;
    }

    // Call parent interaction logic
    final bool interactionStarted = super.interact();

    if (interactionStarted) {
      // T3.5.3: Update conversation tracking
      _conversationDepth++;

      // T3.5.3: Trigger appropriate dialogue based on progression
      _triggerContextualDialogue();

      print('Mira: Conversation depth: $_conversationDepth');
    }

    return interactionStarted;
  }

  /// T3.5.3: Trigger dialogue based on player progression and context
  void _triggerContextualDialogue() {
    // Determine dialogue based on conversation history and game state
    String dialogueKey = 'mira_default';

    if (!_hasIntroducedSelf) {
      dialogueKey = 'mira_introduction';
      _hasIntroducedSelf = true;
    } else if (!_hasExplainedKeepers && _conversationDepth >= 2) {
      dialogueKey = 'mira_keepers_explanation';
      _hasExplainedKeepers = true;
    } else if (!_hasGivenFirstQuest && _conversationDepth >= 3) {
      dialogueKey = 'mira_first_quest';
      _hasGivenFirstQuest = true;

      // Mark quest as available
      if (!questOffered) {
        offerQuest();
      }
    } else {
      // Advanced dialogue options based on player progression
      dialogueKey = _getAdvancedDialogueKey();
    }

    // Update dialogue system with selected key
    // This would integrate with the actual dialogue system
    print('Mira: Triggering dialogue: $dialogueKey');
  }

  /// Get dialogue key for advanced conversations
  String _getAdvancedDialogueKey() {
    // This would check player progression, completed quests, etc.
    // and return appropriate dialogue

    if (_conversationDepth > 10) {
      return 'mira_veteran_advice';
    } else if (_conversationDepth > 5) {
      return 'mira_lore_sharing';
    } else {
      return 'mira_friendly_chat';
    }
  }

  @override
  void startDialogue() {
    super.startDialogue();

    // T3.5.3: Mira-specific dialogue initialization
    print(
      'Mira: "Ah, young seeker of knowledge. The Archive\'s wisdom awaits those who seek truth."',
    );

    // Stop reading behavior during dialogue
    _isReading = false;

    // Visual feedback: Knowledge orbs might appear, tome closes
    _showKnowledgeOrbs();
  }

  @override
  void offerQuest() {
    super.offerQuest();

    // T3.5.3: Mira-specific quest offering
    print(
      'Mira: "The path to understanding begins with a single step. Will you help me gather the scattered pages of ancient wisdom?"',
    );
  }

  /// Show knowledge orbs visual effect (Mira's ability)
  void _showKnowledgeOrbs() {
    // This would trigger visual effects showing floating orbs of light
    // around Mira that reveal hidden knowledge or paths
    print(
      'Mira: Knowledge orbs shimmer around her, revealing hidden truths...',
    );
  }

  /// T3.5.4: Override interaction range check with Mira-specific logic
  @override
  void updateInteractionAvailability(Vector2 playerPosition) {
    super.updateInteractionAvailability(playerPosition);

    // T3.5.4: Additional Mira-specific interaction logic
    final double distance = getDistanceToPlayer(playerPosition);

    // Mira offers guidance hints when player is in medium range
    if (distance <= visualFeedbackRange && distance > interactionRange) {
      _showGuidanceHint();
    }
  }

  /// Show guidance hint when player is in range but not close enough to interact
  void _showGuidanceHint() {
    // Visual feedback: Soft glow or subtle particle effects
    // This indicates Mira is aware of the player and ready to help
    // Could show floating text like "Knowledge awaits..."
  }

  @override
  void endInteraction() {
    super.endInteraction();

    // T3.5.3: Mira-specific interaction ending
    print('Mira: "May the Archive\'s wisdom guide your path."');

    // Resume reading behavior after interaction
    _readingTimer = 0.0;
  }

  // T3.5.1: Mira-specific getters
  bool get isReading => _isReading;
  int get conversationDepth => _conversationDepth;
  bool get hasIntroducedSelf => _hasIntroducedSelf;
  bool get hasExplainedKeepers => _hasExplainedKeepers;
  bool get hasGivenFirstQuest => _hasGivenFirstQuest;
  Vector2 get quillPosition => Vector2(
        position.x + _quillOffset.x,
        position.y +
            _quillOffset.y +
            (math.sin(_quillBobTimer * _quillBobSpeed) * _quillBobAmplitude),
      );

  // Animation getters for rendering system
  int get currentIdleFrame => _currentIdleFrame;
  String get currentAnimationState {
    if (interactionState == NPCInteractionState.talking) {
      return 'talking';
    } else if (_isReading) {
      return 'reading';
    } else {
      return 'idle';
    }
  }
}

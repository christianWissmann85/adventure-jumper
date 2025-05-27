import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../entities/npc.dart';
import '../game/adventure_jumper_game.dart';
import '../systems/dialogue_system.dart';

/// Structure for a single dialogue entry
class DialogueEntry {
  DialogueEntry({
    required this.speakerName,
    required this.text,
    this.portraitSprite,
    this.choices,
    this.dialogueId,
    this.nextDialogueId,
    this.displayDuration = 0.0,
    this.useTypewriter = true,
    this.pauseAfterPunctuation = true,
    this.canSkip = true,
    this.conditions,
    this.onShowCallbacks,
    this.onCompleteCallbacks,
    this.stateChanges,
    this.metadata,
  });

  final String speakerName;
  final String text;
  final Sprite? portraitSprite;
  final List<String>? choices;
  final String? dialogueId; // Unique identifier for this dialogue entry
  final String? nextDialogueId; // ID of next dialogue in conversation tree
  final double displayDuration; // Auto-advance timer (0 for manual)
  final bool useTypewriter; // Whether to use typewriter effect
  final bool pauseAfterPunctuation; // Pause after periods, commas, etc.
  final bool canSkip; // Whether player can skip this dialogue

  // Enhanced features for T3.8
  final Map<String, dynamic>? conditions; // Conditions for showing this entry
  final List<String>? onShowCallbacks; // Callbacks to execute when shown
  final List<String>? onCompleteCallbacks; // Callbacks when completed
  final Map<String, dynamic>? stateChanges; // State changes to apply
  final Map<String, dynamic>? metadata; // Additional metadata
}

/// Dialogue navigation node for conversation trees
class DialogueNode {
  DialogueNode({
    required this.id,
    required this.entry,
    this.nextNodeId,
    this.choiceNodeIds,
    this.conditions,
    this.priority = 0,
    this.tags,
    this.visitCount = 0,
    this.maxVisits,
    this.cooldownSeconds,
    this.lastVisited,
  });

  final String id;
  final DialogueEntry entry;
  final String? nextNodeId; // Default next node
  final Map<String, String>? choiceNodeIds; // Choice text -> node ID mapping
  final Map<String, dynamic>? conditions; // Conditions for showing this node

  // Enhanced features for T3.8
  final int priority; // Priority for node selection when multiple nodes match
  final List<String>? tags; // Tags for categorizing nodes
  int visitCount; // Number of times this node has been visited
  final int? maxVisits; // Maximum number of times this node can be visited
  final int? cooldownSeconds; // Cooldown before node can be visited again
  DateTime? lastVisited; // Last time this node was visited

  /// Check if this node can be visited based on cooldown and visit limits
  bool canVisit() {
    // Check visit limit
    if (maxVisits != null && visitCount >= maxVisits!) {
      return false;
    }

    // Check cooldown
    if (cooldownSeconds != null && lastVisited != null) {
      final timeSinceLastVisit = DateTime.now().difference(lastVisited!);
      if (timeSinceLastVisit.inSeconds < cooldownSeconds!) {
        return false;
      }
    }

    return true;
  }

  /// Mark this node as visited
  void markVisited() {
    visitCount++;
    lastVisited = DateTime.now();
  }
}

/// NPC conversation interface
/// Handles displaying dialogue text, choices, and portraits for NPC interactions
class DialogueUI extends PositionComponent with TapCallbacks {
  DialogueUI({
    required this.game,
    required this.screenSize,
    this.dialogueSpeed = 0.03, // seconds per character
    this.punctuationPause = 0.15, // pause after punctuation
    this.padding = 20.0,
    this.portraitSize = 100.0,
    this.dialogueBoxHeight = 150.0,
    this.cornerRadius = 12.0,
    this.borderWidth = 2.0,
    this.font,
    this.showContinueIndicator = true,
    this.enableSmoothAnimations = true,
  }) : super(position: Vector2.zero());
  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  final double dialogueSpeed;
  final double punctuationPause;
  final double padding;
  final double portraitSize;
  final double dialogueBoxHeight;
  final double cornerRadius;
  final double borderWidth;
  final TextStyle? font;
  final bool showContinueIndicator;
  final bool enableSmoothAnimations; // Active dialogue state
  NPC? _activeNPC;
  String _currentSpeakerName = '';
  String _currentDialogueText = '';
  String _displayedText = '';
  List<String> _currentChoices = <String>[];
  int _selectedChoice = -1;
  Sprite? _speakerPortrait;
  bool _isTyping = false;
  bool _isVisible = false;
  int _currentDialogueIndex = 0;
  List<DialogueEntry> _dialogueSequence = <DialogueEntry>[];

  // Enhanced dialogue navigation
  final Map<String, DialogueNode> _dialogueNodes = <String, DialogueNode>{};
  String? _currentNodeId;
  DialogueSystem? _dialogueSystem; // Integration with dialogue system

  // Enhanced typewriter state
  double _typewriterTimer = 0.0;
  double _punctuationTimer = 0.0;
  bool _pausingForPunctuation = false;

  // Animation state
  double _showAnimationProgress = 0.0;
  bool _isAnimatingIn = false;
  bool _isAnimatingOut = false;

  // UI Components
  late final RectangleComponent _dialogueBox;
  late final TextComponent _speakerNameText;
  late final TextComponent _dialogueText;
  SpriteComponent? _portraitComponent;
  final List<ChoiceButton> _choiceButtons = <ChoiceButton>[];
  late final RectangleComponent _continueIndicator;
  // Callbacks
  void Function()? onDialogueComplete;
  void Function(int)? onChoiceSelected;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize UI but keep it hidden initially
    _createDialogueBox();
    _createNameLabel();
    _createDialogueText();
    _createPortraitSpace();
    _createContinueIndicator();
    _createChoiceButtons();

    // Hide initially
    _isVisible = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle show/hide animations
    if (_isAnimatingIn) {
      _showAnimationProgress += dt * 3.0; // Animation speed
      if (_showAnimationProgress >= 1.0) {
        _showAnimationProgress = 1.0;
        _isAnimatingIn = false;
      }
      _updateUIVisibility();
    } else if (_isAnimatingOut) {
      _showAnimationProgress -= dt * 4.0; // Slightly faster hide animation
      if (_showAnimationProgress <= 0.0) {
        _showAnimationProgress = 0.0;
        _isAnimatingOut = false;
        _isVisible = false;
      }
      _updateUIVisibility();
    }

    if (_isTyping && _isVisible && !_isAnimatingIn && !_isAnimatingOut) {
      _updateEnhancedTypewriterEffect(dt);
    }

    // Animate continue indicator
    if (!_isTyping &&
        _isVisible &&
        _currentChoices.isEmpty &&
        showContinueIndicator) {
      _animateContinueIndicator(dt);
    }
  }

  /// Display a dialogue sequence from an NPC
  void startDialogue(NPC npc, List<DialogueEntry> dialogueSequence) {
    _activeNPC = npc;
    _dialogueSequence = dialogueSequence;
    _currentDialogueIndex = 0;

    // Check if dialogue sequence is empty
    if (_dialogueSequence.isEmpty) {
      print(
        'Warning: Attempted to start dialogue with empty sequence for NPC: ${npc.runtimeType}',
      );
      return;
    }

    _isVisible = true;
    _isAnimatingIn = true;
    _showAnimationProgress = 0.0;

    // Display first dialogue entry
    _showDialogueEntry(_dialogueSequence[_currentDialogueIndex]);
  }

  /// Start a dialogue using conversation tree nodes
  void startDialogueFromNode(
    NPC npc,
    Map<String, DialogueNode> nodes,
    String startNodeId,
  ) {
    _activeNPC = npc;
    _dialogueNodes.clear();
    _dialogueNodes.addAll(nodes);
    _currentNodeId = startNodeId;

    // Check if nodes map is empty or start node doesn't exist
    if (_dialogueNodes.isEmpty) {
      print(
        'Warning: Attempted to start dialogue with empty nodes map for NPC: ${npc.runtimeType}',
      );
      return;
    }

    _isVisible = true;
    _isAnimatingIn = true;
    _showAnimationProgress = 0.0;

    // Display the starting node
    final DialogueNode? startNode = _dialogueNodes[startNodeId];
    if (startNode != null) {
      _showDialogueFromNode(startNode);
    } else {
      print(
        'Warning: Start node "$startNodeId" not found for NPC: ${npc.runtimeType}',
      );
    }
  }

  /// Set the dialogue system for advanced conversation features
  void setDialogueSystem(DialogueSystem dialogueSystem) {
    _dialogueSystem = dialogueSystem;
  }

  /// Start dialogue with integrated dialogue system support
  void startDialogueFromNodeWithSystem(
    NPC npc,
    Map<String, DialogueNode> nodes,
    String startNodeId,
    DialogueSystem dialogueSystem,
  ) {
    _dialogueSystem = dialogueSystem;

    // Start dialogue in the UI
    startDialogueFromNode(npc, nodes, startNodeId);

    // Note: The dialogue system integration will be handled through the
    // choice selection and navigation methods that use _dialogueSystem
  }

  /// Navigate to a specific dialogue node
  void navigateToNode(String nodeId) {
    final DialogueNode? node = _dialogueNodes[nodeId];
    if (node != null) {
      _currentNodeId = nodeId;
      _showDialogueFromNode(node);
    }
  }

  /// Display dialogue from a dialogue node
  void _showDialogueFromNode(DialogueNode node) {
    _currentNodeId = node.id;
    _showDialogueEntry(node.entry);
  }

  /// Show the next dialogue entry or end the dialogue
  void advanceDialogue() {
    // If currently typing, show full text instead
    if (_isTyping) {
      _displayedText = _currentDialogueText;
      _dialogueText.text = _displayedText;
      _isTyping = false;
      return;
    }

    // Handle node-based dialogue navigation
    if (_currentNodeId != null && _dialogueNodes.isNotEmpty) {
      final DialogueNode? currentNode = _dialogueNodes[_currentNodeId];
      if (currentNode != null) {
        // If no choices and has next node, navigate to it
        if (_currentChoices.isEmpty && currentNode.nextNodeId != null) {
          navigateToNode(currentNode.nextNodeId!);
          return;
        }
        // If no next node and no choices, end dialogue
        else if (_currentChoices.isEmpty) {
          _endDialogue();
          return;
        }
      }
    }
    // Handle traditional sequence-based dialogue
    else {
      _currentDialogueIndex++;

      // Check if dialogue is complete
      if (_currentDialogueIndex >= _dialogueSequence.length) {
        _endDialogue();
        return;
      }

      // Show next dialogue entry
      _showDialogueEntry(_dialogueSequence[_currentDialogueIndex]);
    }
  }

  /// Display a dialogue entry (text, speaker, portrait, choices)
  void _showDialogueEntry(DialogueEntry entry) {
    // Set dialogue content
    _currentSpeakerName = entry.speakerName;
    _currentDialogueText = entry.text;
    _displayedText = '';
    _currentChoices = entry.choices ?? <String>[];
    _selectedChoice = -1;

    // Update UI components
    _speakerNameText.text = _currentSpeakerName;

    // Start typewriter effect
    _isTyping = true;

    // Update portrait if available
    if (entry.portraitSprite != null) {
      _speakerPortrait = entry.portraitSprite;
      if (_portraitComponent != null) {
        _portraitComponent!.sprite = _speakerPortrait;
      }
    }

    // Update choices if available
    if (_currentChoices.isNotEmpty) {
      _updateChoiceButtons();
    } else {
      _hideChoiceButtons();
    }
  }

  /// Close the dialogue UI
  void _endDialogue() {
    if (enableSmoothAnimations) {
      _isAnimatingOut = true;
    } else {
      _isVisible = false;
    }

    _activeNPC = null;
    _dialogueNodes.clear();
    _currentNodeId = null;

    // Call completion callback if set
    onDialogueComplete?.call();
  }

  /// Create the main dialogue box background
  void _createDialogueBox() {
    final double boxWidth = screenSize.x - (padding * 2);

    _dialogueBox = RectangleComponent(
      size: Vector2(boxWidth, dialogueBoxHeight),
      position: Vector2(padding, screenSize.y - dialogueBoxHeight - padding),
      paint: Paint()
        ..color = const Color(0xCC000000)
        ..style = PaintingStyle.fill,
    );

    // Add border if specified
    if (borderWidth > 0) {
      final RectangleComponent border = RectangleComponent(
        size: Vector2(boxWidth, dialogueBoxHeight),
        position: Vector2.zero(),
        paint: Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
      _dialogueBox.add(border);
    }

    add(_dialogueBox);
  }

  /// Create the speaker name label
  void _createNameLabel() {
    final TextPaint textStyle = TextPaint(
      style: font?.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ) ??
          const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
    );

    _speakerNameText = TextComponent(
      text: '',
      textRenderer: textStyle,
      position: Vector2(
        _dialogueBox.position.x + padding + portraitSize + padding,
        _dialogueBox.position.y + padding,
      ),
    );

    add(_speakerNameText);
  }

  /// Create the main dialogue text component
  void _createDialogueText() {
    final TextPaint textStyle = TextPaint(
      style: font?.copyWith(
            color: Colors.white,
            fontSize: 16,
          ) ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
    );

    final double textWidth = screenSize.x - (padding * 4) - portraitSize;

    _dialogueText = TextComponent(
      text: '',
      textRenderer: textStyle,
      position: Vector2(
        _dialogueBox.position.x + padding + portraitSize + padding,
        _dialogueBox.position.y + padding + 24,
      ),
      size: Vector2(textWidth, dialogueBoxHeight - padding * 2 - 24),
    );

    add(_dialogueText);
  }

  /// Create space for character portrait
  void _createPortraitSpace() {
    // Create a placeholder for the portrait
    _portraitComponent = SpriteComponent(
      position: Vector2(
        _dialogueBox.position.x + padding,
        _dialogueBox.position.y + padding,
      ),
      size: Vector2(portraitSize, portraitSize),
    );

    add(_portraitComponent!);
  }

  /// Create the continue indicator (animated triangle/arrow)
  void _createContinueIndicator() {
    _continueIndicator = RectangleComponent(
      size: Vector2(15, 15),
      position: Vector2(
        _dialogueBox.position.x + _dialogueBox.size.x - padding - 15,
        _dialogueBox.position.y + _dialogueBox.size.y - padding - 15,
      ),
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    _continueIndicator.add(
      MoveEffect.by(
        Vector2(0, -5),
        EffectController(
          duration: 0.5,
          reverseDuration: 0.5,
          infinite: true,
        ),
      ),
    );

    add(_continueIndicator);
  }

  /// Create choice buttons for dialogue options
  void _createChoiceButtons() {
    // Will be populated when choices are available
  }

  /// Update the enhanced typewriter effect for displaying dialogue text
  void _updateEnhancedTypewriterEffect(double dt) {
    if (_pausingForPunctuation) {
      _punctuationTimer -= dt;
      if (_punctuationTimer <= 0.0) {
        _pausingForPunctuation = false;
      }
      return;
    }

    if (_displayedText.length < _currentDialogueText.length) {
      _typewriterTimer += dt;

      // Check if it's time to add the next character
      if (_typewriterTimer >= dialogueSpeed) {
        final int nextIndex = _displayedText.length + 1;
        _displayedText = _currentDialogueText.substring(0, nextIndex);
        _dialogueText.text = _displayedText;
        _typewriterTimer = 0.0;

        // Check for punctuation pause
        if (nextIndex <= _currentDialogueText.length) {
          final String currentChar = _currentDialogueText[nextIndex - 1];
          if (_isPunctuation(currentChar) &&
              getCurrentDialogueEntry()?.pauseAfterPunctuation == true) {
            _pausingForPunctuation = true;
            _punctuationTimer = punctuationPause;
          }
        }

        // Check if finished typing
        if (_displayedText.length >= _currentDialogueText.length) {
          _isTyping = false;
        }
      }
    }
  }

  /// Check if a character is punctuation that should trigger a pause
  bool _isPunctuation(String char) {
    return char == '.' ||
        char == '!' ||
        char == '?' ||
        char == ',' ||
        char == ';' ||
        char == ':';
  }

  /// Get current dialogue entry safely
  DialogueEntry? getCurrentDialogueEntry() {
    if (_currentDialogueIndex >= 0 &&
        _currentDialogueIndex < _dialogueSequence.length) {
      return _dialogueSequence[_currentDialogueIndex];
    }
    return null;
  }

  /// Update UI visibility based on animation progress
  void _updateUIVisibility() {
    if (!enableSmoothAnimations) {
      return;
    }

    final double alpha = _showAnimationProgress;
    final double scaleValue = 0.8 + (0.2 * _showAnimationProgress);

    // Apply alpha to all UI components
    _dialogueBox.paint = Paint()
      ..color = Color(0xCC000000).withOpacity(alpha * 0.8)
      ..style = PaintingStyle.fill;

    // Apply scale using Flame's scale property
    scale = Vector2.all(scaleValue);

    // Update text opacity
    _updateTextOpacity(alpha);
  }

  /// Update text component opacity
  void _updateTextOpacity(double alpha) {
    // Update speaker name opacity
    final TextPaint nameStyle = TextPaint(
      style: font?.copyWith(
            color: Colors.white.withOpacity(alpha),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ) ??
          TextStyle(
            color: Colors.white.withOpacity(alpha),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
    );
    _speakerNameText.textRenderer = nameStyle;

    // Update dialogue text opacity
    final TextPaint dialogueStyle = TextPaint(
      style: font?.copyWith(
            color: Colors.white.withOpacity(alpha),
            fontSize: 16,
          ) ??
          TextStyle(
            color: Colors.white.withOpacity(alpha),
            fontSize: 16,
          ),
    );
    _dialogueText.textRenderer = dialogueStyle;
  }

  /// Animate the continue indicator
  void _animateContinueIndicator(double dt) {
    // Animation is handled by Flame effects
  }

  /// Update choice buttons based on current dialogue choices
  void _updateChoiceButtons() {
    // Remove any existing choice buttons
    for (final ChoiceButton button in _choiceButtons) {
      button.removeFromParent();
    }
    _choiceButtons.clear();

    // Create new choice buttons
    final double buttonWidth = _dialogueBox.size.x - (padding * 2);
    const double buttonHeight = 40;
    final double startY = _dialogueBox.position.y + dialogueBoxHeight + padding;

    for (int i = 0; i < _currentChoices.length; i++) {
      final ChoiceButton button = ChoiceButton(
        text: _currentChoices[i],
        position: Vector2(
          _dialogueBox.position.x + padding,
          startY + (buttonHeight + padding) * i,
        ),
        size: Vector2(buttonWidth, buttonHeight),
        index: i,
        onPressed: (int index) {
          _selectedChoice = index;
          onChoiceSelected?.call(index);
          _handleChoiceSelection(index);
        },
      );

      add(button);
      _choiceButtons.add(button);
    }
  }

  /// Handle choice selection for both node-based and sequence-based dialogues
  void _handleChoiceSelection(int choiceIndex) {
    if (choiceIndex < 0 || choiceIndex >= _currentChoices.length) {
      return;
    }

    final String selectedChoice = _currentChoices[choiceIndex];

    // Handle node-based dialogue choices with DialogueSystem integration
    if (_currentNodeId != null && _dialogueNodes.isNotEmpty) {
      final DialogueNode? currentNode = _dialogueNodes[_currentNodeId];
      if (currentNode?.choiceNodeIds != null) {
        final String? nextNodeId = currentNode!.choiceNodeIds![selectedChoice];
        if (nextNodeId != null) {
          // Use DialogueSystem if available for enhanced state management
          if (_dialogueSystem != null) {
            _dialogueSystem!.selectChoice(choiceIndex);
            _dialogueSystem!.navigateToNode(nextNodeId);
          } else {
            navigateToNode(nextNodeId);
          }
          return;
        }
      }
    }

    // Default behavior for sequence-based dialogues
    advanceDialogue();
  }

  /// Hide all choice buttons
  void _hideChoiceButtons() {
    for (final ChoiceButton button in _choiceButtons) {
      button.removeFromParent();
    }
    _choiceButtons.clear();
  }

  /// Get the currently active NPC
  NPC? get activeNPC => _activeNPC;

  /// Get the currently selected choice index
  int get selectedChoice => _selectedChoice;

  @override
  void onTapDown(TapDownEvent event) {
    // Only process taps if dialogue UI is visible and no choices are active
    if (_isVisible && _currentChoices.isEmpty) {
      advanceDialogue();
    }
  }
}

/// A button for dialogue choices
class ChoiceButton extends PositionComponent with TapCallbacks {
  ChoiceButton({
    required this.text,
    required Vector2 position,
    required Vector2 size,
    required this.index,
    required this.onPressed,
    this.textStyle,
  }) : super(position: position, size: size);
  final String text;
  final int index;
  final void Function(int) onPressed;
  final TextStyle? textStyle;

  late final RectangleComponent _background;
  late final RectangleComponent _border;
  late final TextComponent _textComponent;
  bool _isHovered = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create button background
    _background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xAA000000)
        ..style = PaintingStyle.fill,
    );

    add(_background);

    // Create button border
    _border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    add(_border);

    // Create text
    final TextPaint style = TextPaint(
      style: textStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
    );

    _textComponent = TextComponent(
      text: text,
      textRenderer: style,
      position: Vector2(10, size.y / 2 - 8),
      size: Vector2(size.x - 20, size.y),
    );

    add(_textComponent);
  }

  void _updateHoverState() {
    if (_isHovered) {
      _background.paint = Paint()
        ..color = const Color(0xCC333333)
        ..style = PaintingStyle.fill;

      _border.paint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
    } else {
      _background.paint = Paint()
        ..color = const Color(0xAA000000)
        ..style = PaintingStyle.fill;

      _border.paint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isHovered = true;
    _updateHoverState();

    // Add a brief press animation
    add(
      ScaleEffect.to(
        Vector2.all(0.95),
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );

    onPressed(index);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isHovered = false;
    _updateHoverState();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isHovered = false;
    _updateHoverState();
  }
}

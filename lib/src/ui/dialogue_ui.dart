import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../entities/npc.dart';
import '../game/adventure_jumper_game.dart';

/// Structure for a single dialogue entry
class DialogueEntry {
  DialogueEntry({
    required this.speakerName,
    required this.text,
    this.portraitSprite,
    this.choices,
  });

  final String speakerName;
  final String text;
  final Sprite? portraitSprite;
  final List<String>? choices;
}

/// NPC conversation interface
/// Handles displaying dialogue text, choices, and portraits for NPC interactions
class DialogueUI extends PositionComponent with TapCallbacks {
  DialogueUI({
    required this.game,
    required this.screenSize,
    this.dialogueSpeed = 0.03, // seconds per character
    this.padding = 20.0,
    this.portraitSize = 100.0,
    this.dialogueBoxHeight = 150.0,
    this.font,
  }) : super(position: Vector2.zero());

  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  final double dialogueSpeed;
  final double padding;
  final double portraitSize;
  final double dialogueBoxHeight;
  final TextStyle? font; // Active dialogue
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

    if (_isTyping && _isVisible) {
      _updateTypewriterEffect(dt);
    }

    // Animate continue indicator
    if (!_isTyping && _isVisible && _choiceButtons.isEmpty) {
      _animateContinueIndicator(dt);
    }
  }

  /// Display a dialogue sequence from an NPC
  void startDialogue(NPC npc, List<DialogueEntry> dialogueSequence) {
    _activeNPC = npc;
    _dialogueSequence = dialogueSequence;
    _currentDialogueIndex = 0;
    _isVisible = true;

    // Display first dialogue entry
    _showDialogueEntry(_dialogueSequence[_currentDialogueIndex]);
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

    _currentDialogueIndex++;

    // Check if dialogue is complete
    if (_currentDialogueIndex >= _dialogueSequence.length) {
      _endDialogue();
      return;
    }

    // Show next dialogue entry
    _showDialogueEntry(_dialogueSequence[_currentDialogueIndex]);
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
    _isVisible = false;
    _activeNPC = null;

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

  /// Update the typewriter effect for displaying dialogue text
  void _updateTypewriterEffect(double dt) {
    if (_displayedText.length < _currentDialogueText.length) {
      // Calculate how many characters to add
      final int charsToAdd = (dt / dialogueSpeed).floor();
      final int nextIndex = math.min(
        _displayedText.length + charsToAdd,
        _currentDialogueText.length,
      );

      _displayedText = _currentDialogueText.substring(0, nextIndex);
      _dialogueText.text = _displayedText;

      // Check if finished typing
      if (_displayedText.length >= _currentDialogueText.length) {
        _isTyping = false;
      }
    }
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
          advanceDialogue();
        },
      );

      add(button);
      _choiceButtons.add(button);
    }
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
  late final TextComponent _textComponent;

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

  @override
  void onTapDown(TapDownEvent event) {
    onPressed(index);
  }
}

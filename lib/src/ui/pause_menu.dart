import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/position_component_extensions.dart';
import '../game/adventure_jumper_game.dart';
import 'text_paint_extensions.dart';

/// Pause screen and options
/// Displayed when game is paused, with options to resume, settings, etc.
class PauseMenu extends PositionComponent with TapCallbacks {
  PauseMenu({
    required this.game,
    required this.screenSize,
    this.onResume,
    this.onSettings,
    this.onMainMenu,
  }) : super(position: Vector2.zero(), size: screenSize);

  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  // Callbacks
  final void Function()? onResume;
  final void Function()? onSettings;
  final void Function()? onMainMenu;

  // UI components
  late final PositionComponent _overlay;
  late final TextComponent _titleText;
  late final List<PauseButton> _buttons;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create semi-transparent overlay
    _createOverlay();

    // Create title text
    _createTitleText();

    // Create buttons
    _createButtons();

    // Add entrance animations
    _addEntranceAnimations();
  }

  /// Create semi-transparent overlay
  void _createOverlay() {
    _overlay = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = const Color(0x99000000), // Semi-transparent black
    );

    add(_overlay);
  }

  /// Create pause menu title text
  void _createTitleText() {
    _titleText = TextComponent(
      text: 'PAUSED',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 10,
              color: Colors.blue,
            ),
          ],
        ),
      ),
      position: Vector2(screenSize.x / 2, screenSize.y * 0.25),
      anchor: Anchor.center,
    );

    add(_titleText);
  }

  /// Create pause menu buttons
  void _createButtons() {
    final double buttonWidth = screenSize.x * 0.3;
    const double buttonHeight = 50;
    final double buttonY = screenSize.y * 0.5;
    const double buttonSpacing = 65;

    _buttons = <PauseButton>[
      PauseButton(
        text: 'Resume',
        position: Vector2(screenSize.x / 2, buttonY),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onResume != null) onResume!();
        },
      ),
      PauseButton(
        text: 'Settings',
        position: Vector2(screenSize.x / 2, buttonY + buttonSpacing),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onSettings != null) onSettings!();
        },
      ),
      PauseButton(
        text: 'Main Menu',
        position: Vector2(screenSize.x / 2, buttonY + buttonSpacing * 2),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onMainMenu != null) onMainMenu!();
        },
      ),
    ];

    for (final PauseButton button in _buttons) {
      add(button);
    }
  }

  /// Add entrance animations
  void _addEntranceAnimations() {
    // Overlay fades in
    _overlay.opacity = 0;
    _overlay.add(
      OpacityEffect.fadeIn(
        EffectController(duration: 0.3),
      ),
    ); // Title slides down
    _titleText.position = Vector2(_titleText.position.x, -50);
    _titleText.add(
      MoveToEffect(
        Vector2(_titleText.position.x, screenSize.y * 0.25),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Buttons fade in one by one
    for (int i = 0; i < _buttons.length; i++) {
      _buttons[i].opacity = 0;
      _buttons[i].add(
        OpacityEffect.fadeIn(
          EffectController(
            duration: 0.3,
            startDelay: 0.2 + (i * 0.1),
          ),
        ),
      );
    }
  }

  /// Add exit animations and call the provided callback after completion
  Future<void> exitWithAnimation(void Function() callback) async {
    // Overlay fades out
    _overlay.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
      ),
    ); // Title slides up
    _titleText.add(
      MoveToEffect(
        Vector2(_titleText.position.x, -50),
        EffectController(
          duration: 0.4,
          curve: Curves.easeInCubic,
        ),
      ),
    );

    // Buttons fade out all at once
    for (final PauseButton button in _buttons) {
      button.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3),
        ),
      );
    } // Wait for animations to finish
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Call the provided callback
    callback();
  }
}

/// Button component for the pause menu
class PauseButton extends PositionComponent with TapCallbacks {
  PauseButton({
    required this.text,
    required Vector2 position,
    required Vector2 size,
    this.onPressed,
  }) : super(position: position, size: size, anchor: Anchor.center);
  final String text;
  final void Function()? onPressed;

  // Visual state
  bool _isHovered = false;
  bool _isPressed = false;

  // Visual settings
  final Color defaultColor = const Color(0xFF5A7EB0);
  final Color hoverColor = const Color(0xFF7DA1D9);
  final Color pressedColor = const Color(0xFF3D5A87);
  final Color textColor = Colors.white;
  final double borderRadius = 8;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Determine button color based on state
    Color buttonColor;
    if (_isPressed) {
      buttonColor = pressedColor;
    } else if (_isHovered) {
      buttonColor = hoverColor;
    } else {
      buttonColor = defaultColor;
    }

    // Draw button background with glass effect
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    ); // Draw button border
    final Paint borderPaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint); // Draw glass-like fill
    final Paint glassPaint = Paint()
      ..color = Color.fromRGBO(
        (buttonColor.r * 255.0).round() & 0xff,
        (buttonColor.g * 255.0).round() & 0xff,
        (buttonColor.b * 255.0).round() & 0xff,
        0.7,
      );
    canvas.drawRRect(rrect, glassPaint);

    // Draw button text
    final TextPaint textConfig = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
      ),
    );

    final Vector2 textOffset = textConfig.measureText(text);
    final Vector2 textPosition = Vector2(
      size.x / 2 - textOffset.x / 2,
      size.y / 2 - textOffset.y / 2,
    );

    textConfig.render(canvas, text, textPosition);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  void onHoverEnter() {
    _isHovered = true;
    add(
      ScaleEffect.to(
        Vector2(1.05, 1.05),
        EffectController(duration: 0.1),
      ),
    );
  }

  void onHoverExit() {
    _isHovered = false;
    add(
      ScaleEffect.to(
        Vector2(1, 1),
        EffectController(duration: 0.1),
      ),
    );
  }
}

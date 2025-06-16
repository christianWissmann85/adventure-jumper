import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/position_component_extensions.dart';
import '../game/adventure_jumper_game.dart';
import '../game/game_config.dart';
import 'text_paint_extensions.dart';

/// Title screen and main navigation
/// The main entry point for the game with options to start, continue, etc.
class MainMenu extends PositionComponent with TapCallbacks {
  MainMenu({
    required this.game,
    required this.screenSize,
    this.title = 'Adventure Jumper',
    this.background,
  }) : super(position: Vector2.zero(), size: screenSize);

  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  final String title;
  final Sprite? background;

  // UI components
  late final List<MenuButton> _buttons;
  late final TextComponent _titleText;
  late final TextComponent _versionText;
  // Button actions
  void Function()? onStartGame;
  void Function()? onContinueGame;
  void Function()? onSettings;
  void Function()? onCredits;
  void Function()? onQuit;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    if (background != null) {
      final SpriteComponent backgroundComponent = SpriteComponent(
        sprite: background,
        size: screenSize,
      );
      add(backgroundComponent);
    } else {
      _createDefaultBackground();
    }

    // Create title text
    _createTitleText();

    // Create version text
    _createVersionText();

    // Create menu buttons
    _createButtons();

    // Add animations
    _addEntranceAnimations();
  }

  /// Create a default background
  void _createDefaultBackground() {
    final RectangleComponent backgroundComponent = RectangleComponent(
      size: screenSize,
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF2C384A), // Dark blue
            Color(0xFF1A1F2B), // Very dark blue
          ],
        ).createShader(Rect.fromLTWH(0, 0, screenSize.x, screenSize.y)),
    );

    add(backgroundComponent);

    // Add some decorative elements
    for (int i = 0; i < 20; i++) {
      _addStarParticle();
    }
  }

  /// Add a decorative star particle
  void _addStarParticle() {
    final Vector2 position = Vector2(
      screenSize.x * (0.1 + 0.8 * game.random.nextDouble()),
      screenSize.y * (0.1 + 0.8 * game.random.nextDouble()),
    );

    final double size = 2.0 + (4.0 * game.random.nextDouble());
    final double blinkRate = 0.5 + (1.5 * game.random.nextDouble());
    final RectangleComponent star = RectangleComponent(
      position: position,
      size: Vector2(size, size),
      paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 0.7),
    );

    // Add blinking effect
    star.add(
      OpacityEffect.fadeIn(
        EffectController(
          duration: blinkRate,
          reverseDuration: blinkRate,
          infinite: true,
        ),
      ),
    );

    add(star);
  }

  /// Create the title text
  void _createTitleText() {
    _titleText = TextComponent(
      text: title,
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
      position: Vector2(screenSize.x / 2, screenSize.y * 0.2),
      anchor: Anchor.center,
    );

    add(_titleText);
  }

  /// Create version text
  void _createVersionText() {
    _versionText = TextComponent(
      text: 'v${GameConfig.version}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      position: Vector2(screenSize.x - 20, screenSize.y - 20),
      anchor: Anchor.bottomRight,
    );

    add(_versionText);
  }

  /// Create menu buttons
  void _createButtons() {
    final double buttonWidth = screenSize.x * 0.4;
    const double buttonHeight = 50;
    final double buttonY = screenSize.y * 0.5;
    const double buttonSpacing = 65;

    _buttons = <MenuButton>[
      MenuButton(
        text: 'New Game',
        position: Vector2(screenSize.x / 2, buttonY),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onStartGame != null) onStartGame!();
        },
      ),
      MenuButton(
        text: 'Continue',
        position: Vector2(screenSize.x / 2, buttonY + buttonSpacing),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onContinueGame != null) onContinueGame!();
        },
      ),
      MenuButton(
        text: 'Settings',
        position: Vector2(screenSize.x / 2, buttonY + buttonSpacing * 2),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onSettings != null) onSettings!();
        },
      ),
      MenuButton(
        text: 'Quit',
        position: Vector2(screenSize.x / 2, buttonY + buttonSpacing * 3),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () {
          if (onQuit != null) onQuit!();
        },
      ),
    ];

    for (final MenuButton button in _buttons) {
      add(button);
    }
  }

  /// Add entrance animations
  void _addEntranceAnimations() {
    // Title slides in from top    // Store initial position
    final Vector2 targetPosition = _titleText.position.clone();
    // Set starting position off-screen
    _titleText.position = Vector2(_titleText.position.x, -50);
    // Add move effect
    _titleText.add(
      MoveEffect.to(
        targetPosition,
        EffectController(
          duration: 1.5,
          curve: Curves.elasticOut,
        ),
      ),
    );

    // Buttons fade in one by one
    for (int i = 0; i < _buttons.length; i++) {
      _buttons[i].opacity = 0;
      _buttons[i].add(
        OpacityEffect.fadeIn(
          EffectController(
            duration: 0.5,
            startDelay: 0.7 + (i * 0.2),
          ),
        ),
      );
    }
  }
}

/// Button component for the main menu
class MenuButton extends PositionComponent with TapCallbacks {
  MenuButton({
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
  final double borderRadius = 10;

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

    // Draw button background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final Paint paint = Paint()..color = buttonColor;
    canvas.drawRRect(rrect, paint); // Draw button border
    final Paint borderPaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);

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

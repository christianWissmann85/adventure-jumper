import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/player.dart';

/// In-game overlay interface
/// Displays player health, aether energy, and other game information
class GameHUD extends PositionComponent {
  GameHUD({
    required this.screenSize,
    Player? player,
    this.padding = 20,
    this.barHeight = 16,
    this.showFps = false,
  })  : _player = player,
        super(position: Vector2.zero());

  // References
  final Vector2 screenSize;
  Player? _player;

  // Layout settings
  final double padding;
  final double barHeight;
  final bool showFps;

  // UI Components
  late final HealthBar _healthBar;
  late final AetherBar _aetherBar;
  late final FpsCounter? _fpsCounter;

  // UI state
  bool _isVisible = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create UI components
    _createHealthBar();
    _createAetherBar();

    // Add FPS counter if enabled
    if (showFps) {
      _createFpsCounter();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isVisible) return;

    // Update UI components with player stats
    _updateFromPlayer();
  }

  /// Create the health bar component
  void _createHealthBar() {
    // Position at top left with padding
    final Vector2 position = Vector2(padding, padding);
    final double width = screenSize.x * 0.25; // 25% of screen width

    _healthBar = HealthBar(
      position: position,
      size: Vector2(width, barHeight),
      maxHealth: _player?.health.maxHealth ?? 100,
      currentHealth: _player?.health.currentHealth ?? 100,
    );

    add(_healthBar);
  }

  /// Create the aether energy bar component
  void _createAetherBar() {
    // Position below health bar
    final Vector2 position = Vector2(padding, padding * 2 + barHeight);
    final double width = screenSize.x * 0.25; // 25% of screen width

    _aetherBar = AetherBar(
      position: position,
      size: Vector2(width, barHeight),
      maxAether: _player?.aether.maxAether ?? 100,
      currentAether: _player?.aether.currentAether ?? 0,
    );

    add(_aetherBar);
  }

  /// Create the FPS counter component
  void _createFpsCounter() {
    // Position at top right with padding
    final Vector2 position = Vector2(screenSize.x - padding - 60, padding);

    _fpsCounter = FpsCounter(
      position: position,
      size: Vector2(60, 20),
    );

    add(_fpsCounter!);
  }

  /// Update UI from player stats
  void _updateFromPlayer() {
    if (_player == null) return;

    // Update health
    _healthBar.setHealth(_player!.health.currentHealth);

    // Update aether
    _aetherBar.setAether(_player!.aether.currentAether);
  }

  /// Set the player reference for the HUD
  void setPlayer(Player player) {
    _player = player;
    _updateFromPlayer();
  }

  /// Show or hide the HUD
  void setVisible(bool visible) {
    _isVisible = visible;

    // Set visibility for all children using scale (alternative to opacity)
    for (final Component child in children) {
      if (child is PositionComponent) {
        child.scale = visible ? Vector2.all(1) : Vector2.all(0);
      }
    }
  }

  /// Update HUD layout when screen size changes
  void resize(Vector2 newScreenSize) {
    // Implementation will be added in future sprints
  }
}

/// Health bar component for the HUD
class HealthBar extends PositionComponent {
  HealthBar({
    required Vector2 position,
    required Vector2 size,
    required this.maxHealth,
    required this.currentHealth,
  }) : super(position: position, size: size);

  final double maxHealth;
  double currentHealth;

  // Visual settings
  final Color backgroundColor = const Color(0x88000000); // Semi-transparent black
  final Color healthColor = const Color(0xFFE73248); // Red
  final Color healthBorderColor = const Color(0xFFFFFFFF); // White
  final double borderWidth = 2;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw background
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );

    // Draw health fill
    final double healthWidth = (currentHealth / maxHealth) * size.x;
    final Paint healthPaint = Paint()
      ..color = healthColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, healthWidth, size.y),
      healthPaint,
    );

    // Draw border
    final Paint borderPaint = Paint()
      ..color = healthBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }

  /// Set current health value
  void setHealth(double health) {
    currentHealth = health.clamp(0, maxHealth);
  }
}

/// Aether energy bar component for the HUD
class AetherBar extends PositionComponent {
  AetherBar({
    required Vector2 position,
    required Vector2 size,
    required this.maxAether,
    required this.currentAether,
  }) : super(position: position, size: size);

  final double maxAether;
  double currentAether;

  // Visual settings
  final Color backgroundColor = const Color(0x88000000); // Semi-transparent black
  final Color aetherColor = const Color(0xFF42C6E7); // Blue
  final Color aetherBorderColor = const Color(0xFFFFFFFF); // White
  final double borderWidth = 2;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw background
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );

    // Draw aether fill
    final double aetherWidth = (currentAether / maxAether) * size.x;
    final Paint aetherPaint = Paint()
      ..color = aetherColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, aetherWidth, size.y),
      aetherPaint,
    );

    // Draw border
    final Paint borderPaint = Paint()
      ..color = aetherBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );
  }

  /// Set current aether value
  void setAether(double aether) {
    currentAether = aether.clamp(0, maxAether);
  }
}

/// FPS counter component for the HUD
class FpsCounter extends PositionComponent {
  FpsCounter({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  double _fps = 0;
  int _frameCount = 0;
  double _timeSinceLastUpdate = 0;
  final double _updateInterval = 0.5; // Update twice per second

  // Visual settings
  final Color backgroundColor = const Color(0x88000000); // Semi-transparent black
  final Color textColor = const Color(0xFFFFFFFF); // White
  final double borderWidth = 1;

  @override
  void update(double dt) {
    super.update(dt);

    // Count frames
    _frameCount++;
    _timeSinceLastUpdate += dt;

    // Update FPS calculation every updateInterval seconds
    if (_timeSinceLastUpdate >= _updateInterval) {
      _fps = _frameCount / _timeSinceLastUpdate;
      _frameCount = 0;
      _timeSinceLastUpdate = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw background
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      backgroundPaint,
    );

    // Draw text
    final TextPaint textConfig = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );

    textConfig.render(
      canvas,
      'FPS: ${_fps.toInt()}',
      Vector2(5, 5),
    );
  }
}

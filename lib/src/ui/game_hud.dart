import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../events/player_events.dart';
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
  late final PlayerEventBus _eventBus = PlayerEventBus.instance;

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
  bool _isInitialized = false;
  @override
  Future<void> onLoad() async {
    print('[GameHUD] onLoad() starting...');
    await super.onLoad();

    print('[GameHUD] Creating health bar...');
    // Create UI components
    _createHealthBar();
    print('[GameHUD] Health bar created, children count: ${children.length}');

    print('[GameHUD] Creating aether bar...');
    _createAetherBar();
    print('[GameHUD] Aether bar created, children count: ${children.length}');

    // Add FPS counter if enabled
    if (showFps) {
      print('[GameHUD] Creating FPS counter...');
      _createFpsCounter();
      print(
        '[GameHUD] FPS counter created, children count: ${children.length}',
      );
    }

    print('[GameHUD] Subscribing to player events...');
    // Subscribe to player events
    _eventBus.addListener(_handlePlayerEvent);

    // Mark as initialized
    _isInitialized = true;
    print('[GameHUD] onLoad() completed - total children: ${children.length}');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isVisible || !_isInitialized) return;

    // Update UI components with player stats
    _updateFromPlayer();
  }

  /// Create the health bar component
  void _createHealthBar() {
    print('[GameHUD] _createHealthBar() called - player: $_player');
    // Position at top left with padding
    final Vector2 position = Vector2(padding, padding);
    final double width = screenSize.x * 0.25; // 25% of screen width

    print(
      '[GameHUD] Creating HealthBar with maxHealth: ${_player?.health.maxHealth ?? 100}, currentHealth: ${_player?.health.currentHealth ?? 100}',
    );
    _healthBar = HealthBar(
      position: position,
      size: Vector2(width, barHeight),
      maxHealth: _player?.health.maxHealth ?? 100,
      currentHealth: _player?.health.currentHealth ?? 100,
    );

    print('[GameHUD] Adding HealthBar to GameHUD...');
    add(_healthBar);
    print('[GameHUD] HealthBar added successfully');
  }

  /// Create the aether energy bar component
  void _createAetherBar() {
    print('[GameHUD] _createAetherBar() called - player: $_player');
    // Position below health bar
    final Vector2 position = Vector2(padding, padding * 2 + barHeight);
    final double width = screenSize.x * 0.25; // 25% of screen width

    print(
      '[GameHUD] Creating AetherBar with maxAether: ${_player?.aether.maxAether ?? 100}, currentAether: ${_player?.aether.currentAether ?? 0}',
    );
    _aetherBar = AetherBar(
      position: position,
      size: Vector2(width, barHeight),
      maxAether: _player?.aether.maxAether ?? 100,
      currentAether: _player?.aether.currentAether ?? 0,
    );

    print('[GameHUD] Adding AetherBar to GameHUD...');
    add(_aetherBar);
    print('[GameHUD] AetherBar added successfully');
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

  /// Handle player events
  void _handlePlayerEvent(PlayerEvent event) {
    // Only process events when HUD is visible and initialized
    if (!_isVisible || !_isInitialized) return;

    // Check for aether change events specifically
    if (event is PlayerAetherChangedEvent) {
      _aetherBar.setAether(event.newAmount.toDouble());
    }
  }

  @override
  void onRemove() {
    // Unsubscribe from events when removed
    _eventBus.removeListener(_handlePlayerEvent);
    super.onRemove();
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
  final Color backgroundColor =
      const Color(0x88000000); // Semi-transparent black
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
    this.showValueText = true,
  })  : _displayedAether = currentAether,
        super(position: position, size: size);

  final double maxAether;
  double currentAether;
  final bool showValueText;

  // Visual settings
  final Color backgroundColor =
      const Color(0x88000000); // Semi-transparent black
  final Color aetherColor = const Color(0xFF42C6E7); // Blue
  final Color aetherBorderColor = const Color(0xFFFFFFFF); // White
  final Color textColor = const Color(0xFFFFFFFF); // White for text
  final double borderWidth = 2;

  // Text configuration
  late final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  );

  // Animation properties for smooth transitions
  double _displayedAether;
  final double _animationSpeed = 5.0; // Speed of the animation

  @override
  void onLoad() {
    super.onLoad();
    _displayedAether = currentAether; // Initialize displayed value
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animate the displayed value towards the actual value
    if (_displayedAether != currentAether) {
      final double diff = currentAether - _displayedAether;
      final double step = diff * dt * _animationSpeed;

      // If the step is small enough, just set it directly
      if (diff.abs() < 0.1) {
        _displayedAether = currentAether;
      } else {
        _displayedAether += step;
      }
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

    // Draw aether fill
    final double aetherWidth = (_displayedAether / maxAether) * size.x;
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

    // Draw aether value text if enabled
    if (showValueText) {
      // Rounded integer value for display
      final String aetherText =
          '${_displayedAether.round()}/${maxAether.round()}';

      // Draw the text next to the bar
      _textPaint.render(
        canvas,
        aetherText,
        Vector2(
          size.x + 10,
          size.y / 2 - 6,
        ), // Position text to right of bar, vertically centered
      );

      // Draw "AETHER" label above the text
      _textPaint.render(
        canvas,
        'AETHER',
        Vector2(size.x + 10, size.y / 2 - 20), // Position above the count text
      );
    }
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
  final Color backgroundColor =
      const Color(0x88000000); // Semi-transparent black
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

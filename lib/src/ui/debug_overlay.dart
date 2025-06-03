import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../game/adventure_jumper_game.dart';
import '../utils/debug_config.dart';

/// Debug overlay for displaying performance metrics and debug information during gameplay
class DebugOverlay extends PositionComponent
    with TapCallbacks, HasGameReference<AdventureJumperGame> {
  DebugOverlay() : super(priority: 100);

  final Logger _logger = Logger('DebugOverlay');
  late final TextComponent _fpsText;
  late final TextComponent _memoryText;
  late final TextComponent _entityCountText;

  bool _visible = true;
  final List<String> _consoleLines = [];
  final int _maxConsoleLines = 10;

  double _fps = 0;
  int _frameCount = 0;
  double _lastSecond = 0;

  @override
  Future<void> onLoad() async {
    _logger.fine('Loading debug overlay');

    // Configure overlay
    position = Vector2(10, 10);

    // FPS counter
    _fpsText = TextComponent(
      text: 'FPS: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
        ),
      ),
    );
    add(_fpsText);

    // Memory usage
    _memoryText = TextComponent(
      text: 'Memory: 0 MB',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
        ),
      ),
      position: Vector2(0, 20),
    );
    add(_memoryText);

    // Entity counter
    _entityCountText = TextComponent(
      text: 'Entities: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
        ),
      ),
      position: Vector2(0, 40),
    );
    add(_entityCountText);

    _visible = DebugConfig.showFPS || DebugConfig.showMemoryUsage;
    _logger.fine('Debug overlay loaded');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_visible) return;

    // Update FPS calculation
    _frameCount++;
    final double now = game.currentTime();
    if (now - _lastSecond > 1.0) {
      _fps = _frameCount / (now - _lastSecond);
      _frameCount = 0;
      _lastSecond = now;

      if (DebugConfig.showFPS) {
        _fpsText.text = 'FPS: ${_fps.toStringAsFixed(1)}';
        _fpsText.textRenderer = TextPaint(
          style: TextStyle(
            color: _getFpsColor(_fps),
            fontSize: 16,
          ),
        );
      }

      if (DebugConfig.showMemoryUsage) {
        _memoryText.text =
            'Memory: Unknown'; // Placeholder for actual memory usage
      }

      // Update entity count if enabled
      if (DebugConfig.showEntityCount) {
        final int entityCount = game.world.children.length;
        _entityCountText.text = 'Entities: $entityCount';
      }
    }
  }

  /// Get color based on FPS value
  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 40) return Colors.yellow;
    return Colors.red;
  }

  /// Toggle debug overlay visibility
  void toggleVisibility() {
    _visible = !_visible;
    _logger.fine('Debug overlay visibility: $_visible');
  }

  /// Add a line to the console output
  void addConsoleMessage(String message) {
    _consoleLines.add(message);
    if (_consoleLines.length > _maxConsoleLines) {
      _consoleLines.removeAt(0);
    }
  }
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'debug_config.dart';

/// Visual debugging overlay that renders debug information directly on screen
/// This helps us see what's actually being rendered without relying on console logs
class VisualDebugOverlay extends PositionComponent with HasGameRef {
  late TextComponent _debugText;
  String _debugInfo = '';
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Only initialize if visual debug overlay is enabled
    if (!DebugConfig.enableVisualDebugOverlay) {
      return;
    }

    // Create debug text component
    _debugText = TextComponent(
      text: _debugInfo,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
      position: Vector2(10, 10),
    );

    add(_debugText);

    // Set high priority to render on top
    priority = 1000;
  }

  /// Update debug information to display
  void updateDebugInfo(String info) {
    if (!DebugConfig.enableVisualDebugOverlay) return;

    _debugInfo = info;
    if (_debugText.isMounted) {
      _debugText.text = _debugInfo;
    }
  }

  /// Add a line to the debug info
  void addDebugLine(String line) {
    if (!DebugConfig.enableVisualDebugOverlay) return;

    if (_debugInfo.isNotEmpty) {
      _debugInfo += '\n';
    }
    _debugInfo += line;

    if (_debugText.isMounted) {
      _debugText.text = _debugInfo;
    }
  }

  /// Clear debug info
  void clearDebugInfo() {
    if (!DebugConfig.enableVisualDebugOverlay) return;

    _debugInfo = '';
    if (_debugText.isMounted) {
      _debugText.text = _debugInfo;
    }
  }

  /// Render a bounding box around a component for visual debugging
  void renderBoundingBox(Canvas canvas, Size size, Vector2 position,
      Vector2 componentSize, Color color,) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromLTWH(
      position.x - componentSize.x / 2,
      position.y - componentSize.y / 2,
      componentSize.x,
      componentSize.y,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  void render(Canvas canvas) {
    if (!DebugConfig.enableVisualDebugOverlay) return;

    super.render(canvas);

    // Render a semi-transparent background for the debug text
    if (_debugInfo.isNotEmpty) {
      final lines = _debugInfo.split('\n');
      const lineHeight = 14.0;
      const padding = 5.0;

      final backgroundRect = Rect.fromLTWH(
        5,
        5,
        400,
        lines.length * lineHeight + padding * 2,
      );

      final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.7);

      canvas.drawRect(backgroundRect, backgroundPaint);
    }
  }
}

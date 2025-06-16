import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../debug/debug_config.dart';

/// A debug rectangle component that provides extensive logging to verify basic rendering capability
/// This helps determine if the issue is with Flame's rendering system entirely or just with sprite components
class DebugRectangleComponent extends RectangleComponent {
  final String debugName;
  int _renderCallCount = 0;
  int _updateCallCount = 0;
  bool _hasLoggedMount = false;

  DebugRectangleComponent({
    required Vector2 size,
    required Vector2 position,
    required Color color,
    this.debugName = 'DebugRect',
    int priority = 0,
  }) : super(
          size: size,
          position: position,
          priority: priority,
          paint: Paint()..color = color,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    DebugConfig.spritePrint(
      '[$debugName] Component onLoad() completed - size: $size, position: $position, priority: $priority',
    );
  }

  @override
  void onMount() {
    super.onMount();
    if (!_hasLoggedMount) {
      DebugConfig.spritePrint(
        '[$debugName] Component onMount() called - isMounted: $isMounted',
      );
      _hasLoggedMount = true;

      // Check mounting status in next frame
      Future.delayed(Duration.zero, () {
        DebugConfig.spritePrint(
          '[$debugName] Component mounted (next frame): $isMounted',
        );
        DebugConfig.spritePrint(
          '[$debugName] Parent: ${parent?.runtimeType}',
        );
      });
    }
  }

  @override
  void render(Canvas canvas) {
    _renderCallCount++;

    // Log first few render calls and then periodically
    if (_renderCallCount <= 5 || _renderCallCount % 60 == 0) {
      DebugConfig.spritePrint(
        '[$debugName] RENDER METHOD CALLED #$_renderCallCount - size: $size, position: $position, mounted: $isMounted',
      );
    }

    // Call parent render method
    super.render(canvas);

    // Additional debug visualization - draw a border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      borderPaint,
    );

    // Draw an X in the center to make it very obvious
    final Paint xPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.x, size.y),
      xPaint,
    );
    canvas.drawLine(
      Offset(size.x, 0),
      Offset(0, size.y),
      xPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateCallCount++;

    // Log first few update calls and then periodically
    if (_updateCallCount <= 3 || _updateCallCount % 120 == 0) {
      DebugConfig.spritePrint(
        '[$debugName] UPDATE METHOD CALLED #$_updateCallCount - dt: $dt, mounted: $isMounted',
      );
    }
  }

  @override
  void onRemove() {
    DebugConfig.spritePrint(
      '[$debugName] Component being removed - render calls: $_renderCallCount, update calls: $_updateCallCount',
    );
    super.onRemove();
  }
}

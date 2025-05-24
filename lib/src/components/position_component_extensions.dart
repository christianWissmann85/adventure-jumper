import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

/// Extension methods for [PositionComponent]
extension PositionComponentExtensions on PositionComponent {
  /// Set opacity for the component
  set opacity(double value) {
    // Apply opacity through paint color manipulation
    if (this is SpriteComponent) {
      final SpriteComponent spriteComponent = this as SpriteComponent;
      final Color currentColor = spriteComponent.paint.color;
      spriteComponent.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        value,
      );
    } else if (this is SpriteAnimationComponent) {
      final SpriteAnimationComponent animComponent = this as SpriteAnimationComponent;
      final Color currentColor = animComponent.paint.color;
      animComponent.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        value,
      );
    }
  }
}

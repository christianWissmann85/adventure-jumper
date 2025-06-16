import 'package:flame/components.dart'; // For Vector2

/// Extension methods for [TextPaint]
extension TextPaintExtensions on TextPaint {
  /// Get the dimensions of text
  /// This is a compatibility method for older code
  Vector2 measureText(String text) {
    // Estimate dimensions based on text length and font size
    final double fontSize = style.fontSize ?? 14.0;
    final double textWidth = text.length * fontSize * 0.6; // Approximate width
    final double textHeight = fontSize * 1.2; // Approximate height
    return Vector2(textWidth, textHeight);
  }

  /// Get the width of text
  double measureTextWidth(String text) {
    // Approximate text width based on text length and font size
    final double fontSize = style.fontSize ?? 14.0;
    return text.length * fontSize * 0.6;
  }
}

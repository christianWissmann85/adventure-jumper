import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

/// Utility class to create placeholder sprites during runtime
/// @deprecated This class is being phased out in favor of static placeholder images.
/// Use SpriteLoader's static test_placeholder.png for test environments instead.
/// This class should only be kept as an absolute last resort fallback.
@Deprecated('Use static test_placeholder.png through SpriteLoader instead')
class PlayerPlaceholder {
  /// Creates a placeholder player sprite with the given dimensions
  static Future<Sprite> createPlaceholderSprite(
    double width,
    double height,
  ) async {
    // Create a recorder for drawing
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Create a blue rectangle with a black border
    final fillPaint = Paint()..color = const Color(0xFF3498DB); // Blue
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw the player body
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);

    // Draw eyes (two white circles with black pupils)
    final eyeBackgroundPaint = Paint()..color = Colors.white;
    final eyePupilPaint = Paint()..color = Colors.black;

    // Scale eyes based on sprite dimensions
    final eyeSize = width * 0.125;
    final pupilSize = eyeSize * 0.5;

    // Left eye
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.3),
      eyeSize,
      eyeBackgroundPaint,
    );
    canvas.drawCircle(
      Offset(width * 0.3, height * 0.3),
      pupilSize,
      eyePupilPaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(width * 0.7, height * 0.3),
      eyeSize,
      eyeBackgroundPaint,
    );
    canvas.drawCircle(
      Offset(width * 0.7, height * 0.3),
      pupilSize,
      eyePupilPaint,
    );

    // Draw a smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.05;

    final Path smilePath = Path();
    smilePath.moveTo(width * 0.3, height * 0.6);
    smilePath.quadraticBezierTo(
      width * 0.5,
      height * 0.75,
      width * 0.7,
      height * 0.6,
    );
    canvas.drawPath(smilePath, smilePaint);

    // Finish the image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());

    return Sprite(image);
  }
}

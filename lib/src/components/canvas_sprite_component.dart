import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../debug/debug_config.dart';

/// Custom canvas-based sprite renderer that bypasses Flame's SpriteComponent mounting system
/// This is a workaround for the Flutter Windows Engine VSync issue that prevents SpriteComponents from mounting
class CanvasSpriteComponent extends PositionComponent {
  CanvasSpriteComponent({
    required Vector2 position,
    required Vector2 size,
    ui.Image? spriteImage,
    Sprite? sprite,
    Vector2? srcPosition,
    Vector2? srcSize,
    double opacity = 1.0,
    Color? tintColor,
    int priority = 0,
  }) : super(
          position: position,
          size: size,
          priority: priority,
        ) {
    _spriteImage = spriteImage;
    _sprite = sprite;
    _srcPosition = srcPosition ?? Vector2.zero();
    _srcSize = srcSize ?? size;
    _opacity = opacity;
    _tintColor = tintColor ?? const Color(0xFFFFFFFF);
  }

  // Sprite properties
  ui.Image? _spriteImage;
  Sprite? _sprite;
  Vector2 _srcPosition = Vector2.zero();
  Vector2 _srcSize = Vector2.zero();
  double _opacity = 1.0;
  Color _tintColor = const Color(0xFFFFFFFF);
  bool _flipHorizontally = false;
  bool _flipVertically = false;

  // Visual effects
  bool _isFlashing = false;
  double _flashTimer = 0.0;
  double _flashDuration = 0.0;
  bool _flashVisible = true;
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Get the image to render
    ui.Image? image = _spriteImage ?? _sprite?.image;
    if (image == null) {
      DebugConfig.spritePrint(
        '[CanvasSpriteComponent] No image available to render',
      );
      return;
    }

    DebugConfig.spritePrint(
      '[CanvasSpriteComponent] Rendering image: ${image.width}x${image.height}, size: $size, opacity: $_opacity',
    );

    // Calculate opacity (considering flash effect)
    double currentOpacity = _opacity;
    if (_isFlashing && !_flashVisible) {
      currentOpacity = 0.0;
    }

    if (currentOpacity <= 0.0) {
      return; // Don't render if fully transparent
    }

    // Set up paint with opacity and tint
    final Paint paint = Paint()
      ..color = _tintColor.withOpacity(currentOpacity)
      ..filterQuality = FilterQuality.none; // Pixel-perfect rendering

    // Calculate source and destination rectangles
    final Rect srcRect = Rect.fromLTWH(
      _srcPosition.x,
      _srcPosition.y,
      _srcSize.x,
      _srcSize.y,
    );

    final Rect dstRect = Rect.fromLTWH(
      0, // Position is handled by the component transform
      0,
      size.x,
      size.y,
    );

    // Apply transforms for flipping
    canvas.save();

    if (_flipHorizontally || _flipVertically) {
      // Move to center for flipping
      canvas.translate(size.x / 2, size.y / 2);

      // Apply flips
      canvas.scale(
        _flipHorizontally ? -1.0 : 1.0,
        _flipVertically ? -1.0 : 1.0,
      );

      // Move back
      canvas.translate(-size.x / 2, -size.y / 2);
    } // Draw the image
    canvas.drawImageRect(image, srcRect, dstRect, paint);

    canvas.restore();

    DebugConfig.spritePrint(
      '[CanvasSpriteComponent] Successfully drew image at srcRect: $srcRect, dstRect: $dstRect',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update flash effect
    if (_isFlashing) {
      _flashTimer += dt;

      // Toggle visibility every 0.1 seconds
      const double flashInterval = 0.1;
      _flashVisible = (_flashTimer % (flashInterval * 2)) <
          flashInterval; // End flash after duration
      if (_flashTimer >= _flashDuration) {
        _isFlashing = false;
        _flashVisible = true;
        _flashTimer = 0.0;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    DebugConfig.spritePrint(
        '[CanvasSpriteComponent] Component loaded successfully');
  }

  @override
  void onMount() {
    super.onMount();
    DebugConfig.spritePrint(
        '[CanvasSpriteComponent] Component mounted successfully');
  }

  /// Set the sprite image directly
  void setSpriteImage(
    ui.Image image, {
    Vector2? srcPosition,
    Vector2? srcSize,
  }) {
    _spriteImage = image;
    _sprite = null;
    if (srcPosition != null) _srcPosition = srcPosition;
    if (srcSize != null) _srcSize = srcSize;

    DebugConfig.spritePrint('[CanvasSpriteComponent] Sprite image set');
  }

  /// Set a Flame sprite
  void setSprite(Sprite sprite) {
    _sprite = sprite;
    _spriteImage = null;
    _srcPosition = sprite.srcPosition;
    _srcSize = sprite.srcSize;

    DebugConfig.spritePrint('[CanvasSpriteComponent] Flame sprite set');
  }

  /// Start flash effect
  void startFlash(double duration) {
    _isFlashing = true;
    _flashDuration = duration;
    _flashTimer = 0.0;
    _flashVisible = true;

    DebugConfig.spritePrint(
      '[CanvasSpriteComponent] Flash effect started: ${duration}s',
    );
  }

  /// Set sprite flipping
  void setFlip({bool? horizontal, bool? vertical}) {
    if (horizontal != null) _flipHorizontally = horizontal;
    if (vertical != null) _flipVertically = vertical;

    DebugConfig.spritePrint(
      '[CanvasSpriteComponent] Flip set: H=$_flipHorizontally, V=$_flipVertically',
    );
  }

  /// Set opacity
  void setOpacity(double opacity) {
    _opacity = opacity.clamp(0.0, 1.0);

    DebugConfig.spritePrint('[CanvasSpriteComponent] Opacity set: $_opacity');
  }

  /// Set tint color
  void setTintColor(Color color) {
    _tintColor = color;

    DebugConfig.spritePrint('[CanvasSpriteComponent] Tint color set: $color');
  }

  // Getters
  bool get isFlashing => _isFlashing;
  double get opacity => _opacity;
  Color get tintColor => _tintColor;
  @override
  bool get isFlippedHorizontally => _flipHorizontally;
  @override
  bool get isFlippedVertically => _flipVertically;
  ui.Image? get spriteImage => _spriteImage ?? _sprite?.image;
}

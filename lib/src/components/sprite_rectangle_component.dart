import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../debug/debug_config.dart';

/// A RectangleComponent that manually renders sprites using canvas.drawImageRect()
/// This bypasses the SpriteComponent mounting issues while maintaining sprite functionality
class SpriteRectangleComponent extends RectangleComponent {
  Sprite? _sprite;
  double _opacity = 1.0;
  bool _flipHorizontally = false;
  bool _flipVertically = false;
  int _renderCallCount = 0;

  // Flash effect properties
  bool _isFlashing = false;
  double _flashTimer = 0;
  bool _flashVisible = true;

  SpriteRectangleComponent({
    required super.size,
    super.position,
    super.anchor,
    super.priority,
    Sprite? sprite,
    double opacity = 1.0,
    bool flipHorizontally = false,
    bool flipVertically = false,
  })  : _sprite = sprite,
        _opacity = opacity,
        _flipHorizontally = flipHorizontally,
        _flipVertically = flipVertically,
        super(
          paint: Paint()..color = Colors.transparent,
        ); // Transparent background

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Component loaded - size: $size, position: $position',
    );
  }

  @override
  void onMount() {
    super.onMount();
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Component mounted successfully',
    );
  }

  /// Set the sprite to render
  void setSprite(Sprite? sprite) {
    _sprite = sprite;
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Sprite set: ${sprite != null}',
    );
  }

  /// Set the opacity (0.0 to 1.0)
  void setOpacityValue(double opacity) {
    _opacity = opacity.clamp(0.0, 1.0);
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Opacity set: $_opacity',
    );
  }

  /// Set horizontal and vertical flip
  void setFlip({bool horizontal = false, bool vertical = false}) {
    _flipHorizontally = horizontal;
    _flipVertically = vertical;
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Flip set: H=$horizontal, V=$vertical',
    );
  }

  /// Start or stop the flash effect
  void setFlashing(bool isFlashing) {
    _isFlashing = isFlashing;
    _flashTimer = 0;
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Flashing ${isFlashing ? 'enabled' : 'disabled'}',
    );
  }

  /// Start flash effect for a specific duration
  void startFlash(double duration) {
    _isFlashing = true;
    _flashTimer = 0;
    _flashVisible = true;
    DebugConfig.spritePrint(
      '[SpriteRectangleComponent] Flash started for ${duration}s',
    );

    // Auto-stop after duration
    Future.delayed(Duration(milliseconds: (duration * 1000).round()), () {
      if (_isFlashing) {
        stopFlash();
      }
    });
  }

  /// Stop the flash effect
  void stopFlash() {
    _isFlashing = false;
    _flashTimer = 0;
    _flashVisible = true;
    DebugConfig.spritePrint('[SpriteRectangleComponent] Flash stopped');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update flash effect
    if (_isFlashing) {
      _flashTimer += dt;
      if (_flashTimer >= 0.5) {
        _flashVisible = !_flashVisible;
        _flashTimer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Don't call super.render() as we don't want the transparent rectangle background

    _renderCallCount++;

    // Log first few render calls for debugging
    if (_renderCallCount <= 5) {
      DebugConfig.spritePrint(
        '[SpriteRectangleComponent] RENDER CALL #$_renderCallCount - sprite: ${_sprite != null}, opacity: $_opacity',
      );

      // Add more visible debug print for initial render calls
      print(
        '[SpriteRectangleComponent] RENDER CALL #$_renderCallCount - sprite: ${_sprite != null}, size: $size, position: $position, mounted: $isMounted',
      );
    } else if (_renderCallCount % 60 == 0) {
      DebugConfig.spritePrint(
        '[SpriteRectangleComponent] RENDER CALL #$_renderCallCount (every 60th logged)',
      );

      // Add more visible debug print for periodic render calls
      print(
        '[SpriteRectangleComponent] RENDER CALL #$_renderCallCount - sprite: ${_sprite != null}, size: $size, position: $position',
      );
    }

    // Only render if we have a sprite
    if (_sprite == null) {
      DebugConfig.spritePrint('[SpriteRectangleComponent] No sprite to render');
      return;
    }

    // Save canvas state
    canvas.save();

    try {
      // Apply opacity
      if (_opacity < 1.0) {
        canvas.saveLayer(
          null,
          Paint()..color = Color.fromRGBO(255, 255, 255, _opacity),
        );
      }

      // Calculate destination rectangle (where to draw on canvas)
      final destRect = Rect.fromLTWH(0, 0, size.x, size.y);

      // Calculate source rectangle (what part of sprite image to use)
      final srcRect =
          Rect.fromLTWH(0, 0, _sprite!.srcSize.x, _sprite!.srcSize.y);

      // Apply flipping transformations
      if (_flipHorizontally || _flipVertically) {
        canvas.translate(size.x / 2, size.y / 2);
        canvas.scale(
          _flipHorizontally ? -1.0 : 1.0,
          _flipVertically ? -1.0 : 1.0,
        );
        canvas.translate(-size.x / 2, -size.y / 2);
      }

      // Draw the sprite using canvas.drawImageRect
      canvas.drawImageRect(
        _sprite!.image,
        srcRect,
        destRect,
        Paint(),
      );

      if (_renderCallCount <= 3) {
        DebugConfig.spritePrint(
          '[SpriteRectangleComponent] Successfully rendered sprite - srcRect: $srcRect, destRect: $destRect',
        );
      }

      // Draw flash effect if enabled
      if (_isFlashing && _flashVisible) {
        canvas.drawRect(
          destRect,
          Paint()..color = Color.fromRGBO(255, 255, 255, 0.5),
        );
      }
    } catch (e) {
      DebugConfig.spritePrint(
        '[SpriteRectangleComponent] ERROR rendering sprite: $e',
      );
    } finally {
      // Restore canvas state
      canvas.restore();
    }
  }

  /// Debug method to get current status
  void debugPrintStatus() {
    DebugConfig.spritePrint('[SpriteRectangleComponent] === STATUS ===');
    DebugConfig.spritePrint('  - Has sprite: ${_sprite != null}');
    DebugConfig.spritePrint('  - Size: $size');
    DebugConfig.spritePrint('  - Position: $position');
    DebugConfig.spritePrint('  - Opacity: $_opacity');
    DebugConfig.spritePrint(
      '  - Flip H/V: $_flipHorizontally/$_flipVertically',
    );
    DebugConfig.spritePrint('  - Mounted: $isMounted');
    DebugConfig.spritePrint('  - Render calls: $_renderCallCount');
    DebugConfig.spritePrint('[SpriteRectangleComponent] === END STATUS ===');
  }
}

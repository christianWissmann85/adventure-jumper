import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../debug/debug_config.dart';
import 'sprite_rectangle_component.dart';

/// Component that handles sprite rendering for entities
/// Uses SpriteRectangleComponent to bypass SpriteComponent mounting issues
class AdvSpriteComponent extends Component {
  AdvSpriteComponent({
    String? spritePath,
    Sprite? sprite,
    Vector2? spriteSize,
    Vector2? spriteOffset,
    bool? flipHorizontally,
    bool? flipVertically,
    double? opacity,
    int? priority,
  }) {
    if (sprite != null) _sprite = sprite;
    if (spriteSize != null) _spriteSize = spriteSize;
    if (spriteOffset != null) _spriteOffset = spriteOffset;
    if (flipHorizontally != null) _flipHorizontally = flipHorizontally;
    if (flipVertically != null) _flipVertically = flipVertically;
    if (opacity != null) _opacity = opacity;
    if (priority != null) _renderPriority = priority;
  }

  // Sprite properties
  Sprite? _sprite;
  SpriteAnimation? _currentAnimation;
  Vector2 _spriteSize = Vector2.zero();
  Vector2 _spriteOffset = Vector2.zero();
  bool _flipHorizontally = false;
  bool _flipVertically = false;
  double _opacity = 1;
  int _renderPriority = 0;

  // Visual effects
  bool _isFlashing = false;
  double _flashTimer = 0;
  bool _flashVisible = true;

  // Working sprite component reference (uses RectangleComponent base)
  SpriteRectangleComponent? _spriteRectangleComponent;
  SpriteAnimationComponent? _animationComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    DebugConfig.spritePrint('[AdvSpriteComponent] onLoad() called');

    if (parent is PositionComponent) {
      final PositionComponent parentComp = parent as PositionComponent;

      // Initialize based on sprite or animation
      if (_sprite != null) {
        _createSpriteRectangleComponent();
        parentComp.add(_spriteRectangleComponent!);
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Added SpriteRectangleComponent to parent',
        );
      } else if (_currentAnimation != null) {
        _createAnimationComponent();
        parentComp.add(_animationComponent!);
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Added AnimationComponent to parent',
        );
      }
    }
  }

  // Layer for rendering order
  int get renderLayer => _renderPriority;

  // Sprite dimensions
  Vector2 get size {
    if (_spriteSize != Vector2.zero()) {
      return _spriteSize;
    }

    // Return natural sprite size if no custom size set
    if (_sprite != null) {
      return Vector2(_sprite!.srcSize.x, _sprite!.srcSize.y);
    }

    if (_currentAnimation != null && _currentAnimation!.frames.isNotEmpty) {
      final firstFrame = _currentAnimation!.frames.first.sprite;
      return Vector2(firstFrame.srcSize.x, firstFrame.srcSize.y);
    }

    return Vector2.zero();
  }

  // Set a sprite
  void setSprite(Sprite sprite) {
    _sprite = sprite;
    _currentAnimation = null;
    _updateSpriteRectangleComponent();
  }

  // Set a sprite animation
  void setAnimation(SpriteAnimation animation) {
    _currentAnimation = animation;
    _sprite = null;
    _updateAnimationComponent();
  }

  // Set sprite flipping
  void setFlip(bool horizontal, bool vertical) {
    _flipHorizontally = horizontal;
    _flipVertically = vertical;

    if (_spriteRectangleComponent != null) {
      _spriteRectangleComponent!.setFlip(
        horizontal: horizontal,
        vertical: vertical,
      );
    }

    if (_animationComponent != null) {
      if (horizontal) _animationComponent!.flipHorizontallyAroundCenter();
      if (vertical) _animationComponent!.flipVerticallyAroundCenter();
    }
  }

  // Update sprite rectangle component based on current settings
  void _updateSpriteRectangleComponent() {
    DebugConfig.spritePrint(
      '[AdvSpriteComponent] Updating sprite rectangle component',
    );
    if (parent is PositionComponent) {
      // Remove any animation component
      if (_animationComponent != null && _animationComponent!.isMounted) {
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Removing existing animation component',
        );
        _animationComponent!.removeFromParent();
        _animationComponent = null;
      } // Update existing sprite rectangle component OR create new one
      if (_spriteRectangleComponent != null &&
          _spriteRectangleComponent!.isMounted) {
        // Update existing component instead of recreating
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Updating existing sprite rectangle component',
        );
        _spriteRectangleComponent!.setSprite(_sprite);
        _spriteRectangleComponent!.setFlip(
          horizontal: _flipHorizontally,
          vertical: _flipVertically,
        );
        _spriteRectangleComponent!.setOpacityValue(_opacity);
      } else if (_sprite != null) {
        // Create new sprite rectangle component only if needed
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Creating new sprite rectangle component',
        );
        _createSpriteRectangleComponent();
        (parent as PositionComponent).add(_spriteRectangleComponent!);
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Added new sprite rectangle component',
        );
      }
    }
  }

  // Update animation component based on current settings
  void _updateAnimationComponent() {
    DebugConfig.spritePrint(
      '[AdvSpriteComponent] Updating animation component',
    );
    if (parent is PositionComponent) {
      // Remove any sprite rectangle component
      if (_spriteRectangleComponent != null &&
          _spriteRectangleComponent!.isMounted) {
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Removing existing sprite rectangle component',
        );
        _spriteRectangleComponent!.removeFromParent();
        _spriteRectangleComponent = null;
      }

      // Remove existing animation component
      if (_animationComponent != null && _animationComponent!.isMounted) {
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Removing existing animation component',
        );
        _animationComponent!.removeFromParent();
        _animationComponent = null;
      }

      // Create new animation component
      if (_currentAnimation != null) {
        _createAnimationComponent();
        (parent as PositionComponent).add(_animationComponent!);
        DebugConfig.spritePrint(
          '[AdvSpriteComponent] Added new animation component',
        );
      }
    }
  }

  // Create a SpriteRectangleComponent (uses working RectangleComponent base)
  void _createSpriteRectangleComponent() {
    if (_sprite == null) return;

    _spriteRectangleComponent = SpriteRectangleComponent(
      sprite: _sprite!,
      size: size,
      priority: _renderPriority,
    );

    // Apply visual effects
    _spriteRectangleComponent!.setFlip(
      horizontal: _flipHorizontally,
      vertical: _flipVertically,
    );
    _spriteRectangleComponent!.setOpacity(_opacity);

    DebugConfig.spritePrint(
      '[AdvSpriteComponent] SpriteRectangleComponent created with size: ${_spriteRectangleComponent!.size}',
    );
  }

  // Create animation component
  void _createAnimationComponent() {
    if (_currentAnimation == null) return;

    _animationComponent = SpriteAnimationComponent(
      animation: _currentAnimation!,
      size: size,
      position: _spriteOffset,
      priority: _renderPriority,
    );

    // Apply flipping
    if (_flipHorizontally) _animationComponent!.flipHorizontallyAroundCenter();
    if (_flipVertically) _animationComponent!.flipVerticallyAroundCenter();

    // Apply opacity
    _animationComponent!.paint.color = Color.fromRGBO(255, 255, 255, _opacity);

    DebugConfig.spritePrint(
      '[AdvSpriteComponent] Animation component created with size: ${_animationComponent!.size}',
    );
  }

  // Start a flash effect
  void startFlash(double duration) {
    _isFlashing = true;
    _flashTimer = duration;
    _flashVisible = true;

    if (_spriteRectangleComponent != null) {
      _spriteRectangleComponent!.startFlash(duration);
    }

    if (_animationComponent != null) {
      _animationComponent!.paint.color = Color.fromRGBO(
        255,
        255,
        255,
        _flashVisible ? _opacity : _opacity * 0.3,
      );
    }
  }

  // Alias for startFlash for backward compatibility
  void flash(double duration) => startFlash(duration);

  // Stop the flash effect
  void stopFlash() {
    _isFlashing = false;
    _flashVisible = true;

    if (_spriteRectangleComponent != null) {
      _spriteRectangleComponent!.stopFlash();
    }

    if (_animationComponent != null) {
      _animationComponent!.paint.color = Color.fromRGBO(
        255,
        255,
        255,
        _opacity,
      );
    }
  }

  // Set opacity
  void setOpacity(double opacity) {
    _opacity = opacity;

    if (_spriteRectangleComponent != null) {
      _spriteRectangleComponent!.setOpacityValue(_opacity);
    }

    if (_animationComponent != null) {
      _animationComponent!.paint.color =
          Color.fromRGBO(255, 255, 255, _opacity);
    }
  }

  // Debug status
  void printDebugStatus() {
    DebugConfig.spritePrint('[AdvSpriteComponent] Debug Status:');
    DebugConfig.spritePrint(
      '  - SpriteRectangleComponent exists: ${_spriteRectangleComponent != null}',
    );
    DebugConfig.spritePrint(
      '  - AnimationComponent exists: ${_animationComponent != null}',
    );
    DebugConfig.spritePrint('  - Current sprite: ${_sprite != null}');
    DebugConfig.spritePrint(
      '  - Current animation: ${_currentAnimation != null}',
    );
    DebugConfig.spritePrint('  - Opacity: $_opacity');
    DebugConfig.spritePrint(
      '  - Flip H/V: $_flipHorizontally/$_flipVertically',
    );

    if (_spriteRectangleComponent != null) {
      DebugConfig.spritePrint(
        '  - SpriteRectangleComponent mounted: ${_spriteRectangleComponent!.isMounted}',
      );
      DebugConfig.spritePrint(
        '  - SpriteRectangleComponent size: ${_spriteRectangleComponent!.size}',
      );
      DebugConfig.spritePrint(
        '  - SpriteRectangleComponent position: ${_spriteRectangleComponent!.position}',
      );
    }

    if (_animationComponent != null) {
      DebugConfig.spritePrint(
        '  - AnimationComponent mounted: ${_animationComponent!.isMounted}',
      );
      DebugConfig.spritePrint(
        '  - AnimationComponent size: ${_animationComponent!.size}',
      );
      DebugConfig.spritePrint(
        '  - AnimationComponent position: ${_animationComponent!.position}',
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update flash effect
    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _isFlashing = false;
        stopFlash();
      } else {
        // Toggle visibility for flashing effect
        _flashVisible = !_flashVisible;
        if (_animationComponent != null) {
          _animationComponent!.paint.color = Color.fromRGBO(
            255,
            255,
            255,
            _flashVisible ? _opacity : _opacity * 0.3,
          );
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Note: SpriteRectangleComponent and SpriteAnimationComponent handle their own rendering
    // This render method is mainly for debugging
    DebugConfig.spritePrint(
      '[AdvSpriteComponent] render() called - hasSprite: ${_sprite != null}, hasAnimation: ${_currentAnimation != null}',
    );
    super.render(canvas);
  }
}

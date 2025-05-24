import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

/// Component that handles sprite rendering for entities
/// Manages sprite sheets, animations, and visual effects
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
    if (spritePath != null) {/* No longer storing path */}
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
  // Flash timer tracks remaining time
  double _flashTimer = 0;
  bool _flashVisible = true;

  // Sprite component references
  SpriteAnimationComponent? _animationComponent;
  SpriteComponent? _spriteComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (parent is PositionComponent) {
      final PositionComponent parentComp = parent as PositionComponent;

      // Initialize based on sprite or animation
      if (_sprite != null) {
        _createSpriteComponent();
        parentComp.add(_spriteComponent!);
      } else if (_currentAnimation != null) {
        _createAnimationComponent();
        parentComp.add(_animationComponent!);
      }
    }
  }

  // Layer for rendering order
  int get renderLayer => _renderPriority;

  // Sprite dimensions
  Vector2 get size => _spriteSize;

  // Set a sprite
  void setSprite(Sprite sprite) {
    _sprite = sprite;
    _currentAnimation = null;

    _updateSpriteComponent();
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

    if (_spriteComponent != null) {
      if (horizontal) _spriteComponent!.flipHorizontallyAroundCenter();
      if (vertical) _spriteComponent!.flipVerticallyAroundCenter();
    }

    if (_animationComponent != null) {
      if (horizontal) _animationComponent!.flipHorizontallyAroundCenter();
      if (vertical) _animationComponent!.flipVerticallyAroundCenter();
    }
  }

  // Update sprite component based on current settings
  void _updateSpriteComponent() {
    if (parent is PositionComponent) {
      // Remove any animation component
      if (_animationComponent != null && _animationComponent!.isMounted) {
        _animationComponent!.removeFromParent();
        _animationComponent = null;
      }

      // Replace existing sprite component
      if (_spriteComponent != null && _spriteComponent!.isMounted) {
        _spriteComponent!.removeFromParent();
      }

      if (_sprite != null) {
        _createSpriteComponent();
        (parent as PositionComponent).add(_spriteComponent!);
      }
    }
  }

  // Update animation component based on current settings
  void _updateAnimationComponent() {
    if (parent is PositionComponent) {
      // Remove existing sprite component
      if (_spriteComponent != null && _spriteComponent!.isMounted) {
        _spriteComponent!.removeFromParent();
        _spriteComponent = null;
      }

      // Create or update animation component
      if (_animationComponent != null && _animationComponent!.isMounted) {
        _animationComponent!.removeFromParent();
      }

      if (_currentAnimation != null) {
        _createAnimationComponent();
        (parent as PositionComponent).add(_animationComponent!);
      }
    }
  }

  // Create a new sprite component with current settings
  void _createSpriteComponent() {
    _spriteComponent = SpriteComponent(
      sprite: _sprite,
      position: _spriteOffset,
      size: _spriteSize,
      anchor: Anchor.center,
    );
    if (_flipHorizontally) _spriteComponent!.flipHorizontallyAroundCenter();
    if (_flipVertically) {
      _spriteComponent!.flipVerticallyAroundCenter(); // Set opacity
    }
    final Color currentColor = _spriteComponent!.paint.color;
    _spriteComponent!.paint.color = Color.fromRGBO(
      (currentColor.r * 255.0).round() & 0xff,
      (currentColor.g * 255.0).round() & 0xff,
      (currentColor.b * 255.0).round() & 0xff,
      _opacity,
    );
  }

  // Create a new animation component with current settings
  void _createAnimationComponent() {
    _animationComponent = SpriteAnimationComponent(
      animation: _currentAnimation,
      position: _spriteOffset,
      size: _spriteSize,
      anchor: Anchor.center,
    );
    if (_flipHorizontally) _animationComponent!.flipHorizontallyAroundCenter();
    if (_flipVertically) {
      _animationComponent!.flipVerticallyAroundCenter(); // Set opacity
    }
    final Color currentColor = _animationComponent!.paint.color;
    _animationComponent!.paint.color = Color.fromRGBO(
      (currentColor.r * 255.0).round() & 0xff,
      (currentColor.g * 255.0).round() & 0xff,
      (currentColor.b * 255.0).round() & 0xff,
      _opacity,
    );
  }

  // Handle time-based effects like flashing
  void applyTimeBasedEffects(double dt) {
    if (_isFlashing) {
      _flashTimer -= dt;
      if (_flashTimer <= 0) {
        _isFlashing = false;
        _flashVisible = true;
        _updateVisibility();
      } else {
        // Flash visibility toggling - simplified logic
        const double flashInterval = 0.1;
        if ((_flashTimer % (flashInterval * 2)) < flashInterval) {
          _flashVisible = true;
        } else {
          _flashVisible = false;
        }
        _updateVisibility();
      }
    }
  }

  // Start a flashing effect
  void flash(double duration) {
    _isFlashing = true;
    _flashTimer = duration;
    _flashVisible = true;
  }

  // Update visibility based on effects
  void _updateVisibility() {
    if (_spriteComponent != null) {
      final Color currentColor = _spriteComponent!.paint.color;
      _spriteComponent!.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        _flashVisible ? _opacity : 0,
      );
    }
    if (_animationComponent != null) {
      final Color currentColor = _animationComponent!.paint.color;
      _animationComponent!.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        _flashVisible ? _opacity : 0,
      );
    }
  }

  // Set opacity/transparency
  void setOpacity(double opacity) {
    _opacity = opacity;
    if (_spriteComponent != null) {
      final Color currentColor = _spriteComponent!.paint.color;
      _spriteComponent!.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        _opacity,
      );
    }

    if (_animationComponent != null) {
      final Color currentColor = _animationComponent!.paint.color;
      _animationComponent!.paint.color = Color.fromRGBO(
        (currentColor.r * 255.0).round() & 0xff,
        (currentColor.g * 255.0).round() & 0xff,
        (currentColor.b * 255.0).round() & 0xff,
        _opacity,
      );
    }
  }
}

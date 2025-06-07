import 'package:flame/components.dart';

/// Component that handles sprite rendering for entities
/// Manages sprite sheets, animations, and visual effects
class CustomSpriteComponent extends Component {
  CustomSpriteComponent({
    String? spritePath,
    Sprite? sprite,
    Vector2? newSpriteSize,
    Vector2? newSpriteOffset,
    bool? flipHorizontally,
    bool? flipVertically,
    double? opacity,
    int? priority,
  }) : spriteSize = newSpriteSize ?? Vector2.zero(),
       spriteOffset = newSpriteOffset ?? Vector2.zero() {
    if (spritePath != null) _spritePath = spritePath;
    if (sprite != null) _sprite = sprite;
    if (flipHorizontally != null) _flipHorizontally = flipHorizontally;
    if (flipVertically != null) _flipVertically = flipVertically;
    if (opacity != null) _opacity = opacity;
    if (priority != null) _renderPriority = priority;
  }

  // Sprite properties
  String _spritePath = '';
  Sprite? _sprite;
  SpriteAnimation? _currentAnimation;
  Vector2 spriteSize;
  Vector2 spriteOffset;
  bool _flipHorizontally = false;
  bool _flipVertically = false;
  double _opacity = 1;
  int _renderPriority = 0;

  // Visual effects
  bool _isFlashing = false;
  double _flashDuration = 0;
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

      // Initialize sprite size based on parent if not set
      if (spriteSize == Vector2.zero() && parentComp.size != Vector2.zero()) {
        spriteSize = parentComp.size.clone();
      }

      // Load sprite if path is provided
      if (_spritePath.isNotEmpty && _sprite == null) {
        _sprite = await Sprite.load(_spritePath);
      }

      // Create sprite component
      if (_sprite != null) {
        _spriteComponent = _createSpriteComponent();
        parentComp.add(_spriteComponent!);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update flash effect if active
    if (_isFlashing) {
      _updateFlash(dt);
    } // Update flip state
    if (_spriteComponent != null) {
      _spriteComponent!.scale.x = _flipHorizontally ? -1 : 1;
      _spriteComponent!.scale.y = _flipVertically ? -1 : 1;
      _spriteComponent!.position = spriteOffset;
      _spriteComponent!.opacity = _flashVisible ? _opacity : 0;
    }

    if (_animationComponent != null) {
      _animationComponent!.scale.x = _flipHorizontally ? -1 : 1;
      _animationComponent!.scale.y = _flipVertically ? -1 : 1;
      _animationComponent!.position = spriteOffset;
      _animationComponent!.opacity = _flashVisible ? _opacity : 0;
    }
  }

  /// Create Flame sprite component
  SpriteComponent _createSpriteComponent() {
    return SpriteComponent(
      sprite: _sprite,
      size: spriteSize,
      position: spriteOffset,
      priority: _renderPriority,
      anchor: Anchor.center,
    );
  }

  /// Set sprite
  Future<void> setSprite(String spritePath) async {
    _spritePath = spritePath;
    _sprite =
        await Sprite.load(spritePath); // Replace existing sprite component
    if (_spriteComponent != null && _spriteComponent!.isMounted) {
      _spriteComponent!.removeFromParent();
    }

    if (parent is PositionComponent) {
      _spriteComponent = _createSpriteComponent();
      (parent as PositionComponent).add(_spriteComponent!);
    } // Remove any animation component
    if (_animationComponent != null && _animationComponent!.isMounted) {
      _animationComponent!.removeFromParent();
      _animationComponent = null;
    }
  }

  /// Set sprite animation
  void setAnimation(SpriteAnimation animation) {
    _currentAnimation = animation; // Remove existing sprite component
    if (_spriteComponent != null && _spriteComponent!.isMounted) {
      _spriteComponent!.removeFromParent();
      _spriteComponent = null;
    }

    // Create or update animation component
    if (_animationComponent != null && _animationComponent!.isMounted) {
      _animationComponent!.animation = animation;
    } else if (parent is PositionComponent) {
      _animationComponent = SpriteAnimationComponent(
        animation: animation,
        size: spriteSize,
        position: spriteOffset,
        priority: _renderPriority,
        anchor: Anchor.center,
      );
      (parent as PositionComponent).add(_animationComponent!);
    }
  }

  /// Start flash effect
  void startFlash(double duration) {
    _isFlashing = true;
    _flashDuration = duration;
    _flashTimer = 0;
    _flashVisible = true;
  }

  /// Update flash effect
  void _updateFlash(double dt) {
    _flashTimer += dt;

    // Toggle visibility every 0.1 seconds for flash effect
    if (_flashTimer % 0.2 < 0.1) {
      _flashVisible = true;
    } else {
      _flashVisible = false;
    }

    // End flash effect after duration
    if (_flashTimer >= _flashDuration) {
      _isFlashing = false;
      _flashVisible = true;
    }
  }

  /// Set sprite flip horizontally
  void setFlipHorizontally(bool flip) {
    _flipHorizontally = flip;
  }

  /// Set sprite flip vertically
  void setFlipVertically(bool flip) {
    _flipVertically = flip;
  }

  /// Set sprite opacity
  void setOpacity(double opacity) {
    _opacity = opacity.clamp(0.0, 1.0);
  }

  // Getters/setters
  Sprite? get sprite => _sprite;
  SpriteAnimation? get currentAnimation => _currentAnimation;

  bool get isFlipped => _flipHorizontally;
}

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

/// Component that handles animations for entities
/// Manages sprite sheet animations, transitions, and playback control
class AnimationComponent extends Component {
  AnimationComponent({
    Map<String, SpriteAnimation>? animations,
    String? initialAnimation,
    double? animationSpeed,
    bool? isPlaying,
  }) {
    if (animations != null) _animations = animations;
    if (initialAnimation != null &&
        animations != null &&
        animations.containsKey(initialAnimation)) {
      _currentAnimationName = initialAnimation;
      _currentAnimation = animations[initialAnimation];
    }
    if (animationSpeed != null) speed = animationSpeed;
    if (isPlaying != null) _isPlaying = isPlaying;
    // Note: loop parameter is used for individual animation play calls
  }
  // Animation properties
  Map<String, SpriteAnimation> _animations = <String, SpriteAnimation>{};
  String _currentAnimationName = 'idle';
  SpriteAnimation? _currentAnimation;
  double speed = 1;
  bool _isPlaying = true;

  // Animation component reference
  SpriteAnimationComponent? _animationComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create animation component if we have a current animation
    if (_currentAnimation != null && parent is PositionComponent) {
      _createAnimationComponent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_animationComponent != null) {
      // Update animation properties
      _animationComponent!.playing = _isPlaying;
    }
  }

  /// Create or update animation component
  void _createAnimationComponent() {
    if (_currentAnimation == null || parent is! PositionComponent) return;

    // Remove existing component if it exists
    if (_animationComponent != null && _animationComponent!.isMounted) {
      _animationComponent!.removeFromParent();
    }

    // Create new animation component
    _animationComponent = SpriteAnimationComponent(
      animation: _currentAnimation!,
      playing: _isPlaying,
      anchor: Anchor.center,
      size: (parent as PositionComponent).size,
    );

    // Add to parent
    (parent as PositionComponent).add(_animationComponent!);
  }

  /// Add an animation
  void addAnimation(String name, SpriteAnimation animation) {
    _animations[name] = animation;

    // Set as current if we don't have one
    if (_currentAnimation == null) {
      _currentAnimationName = name;
      _currentAnimation = animation;
      _createAnimationComponent();
    }
  }

  /// Play a specific animation by name
  void play(String animationName, {bool loop = true, double? speed}) {
    if (!_animations.containsKey(animationName)) return;

    _currentAnimationName = animationName;
    _currentAnimation = _animations[animationName];

    if (speed != null) {
      this.speed = speed;
    }

    _isPlaying = true;

    // Update animation component
    _createAnimationComponent();
  }

  /// Stop the current animation
  void stop() {
    _isPlaying = false;

    if (_animationComponent != null) {
      _animationComponent!.playing = false;
    }
  }

  /// Resume the current animation
  void resume() {
    _isPlaying = true;

    if (_animationComponent != null) {
      _animationComponent!.playing = true;
    }
  }

  /// Reset the current animation to first frame
  void reset() {
    if (_animationComponent?.animationTicker != null) {
      _animationComponent!.animationTicker!.reset();
    }
  }

  /// Get the name of the current animation
  String get currentAnimationName => _currentAnimationName;

  /// Check if the animation has finished playing
  bool get isComplete {
    return _animationComponent?.animationTicker?.isLastFrame ?? false;
  }

  /// Get the current animation
  SpriteAnimation? get currentAnimation => _currentAnimation;

  /// Check if animation is playing
  bool get isPlaying => _isPlaying;

  /// Create animation from sprite sheet
  static SpriteAnimation fromSpriteSheet({
    required SpriteSheet spriteSheet,
    required int row,
    required int frames,
    required double stepTime,
    bool loop = true,
  }) {
    return spriteSheet.createAnimation(
      row: row,
      stepTime: stepTime,
      to: frames,
      loop: loop,
    );
  }
}

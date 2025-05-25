import 'package:flame/components.dart';

import '../utils/logger.dart';
import 'sprite_loader.dart';

/// Handles loading and management of animations for the game
class AnimationLoader {
  factory AnimationLoader() => _instance;
  AnimationLoader._internal();
  static final AnimationLoader _instance = AnimationLoader._internal();

  final Map<String, SpriteAnimation> _animationCache =
      <String, SpriteAnimation>{};
  final SpriteLoader _spriteLoader = SpriteLoader();

  bool _isInitialized = false;

  /// Initialize the animation loader
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _spriteLoader.initialize();
    await _preloadCriticalAnimations();
    _isInitialized = true;
  }

  /// Create animation from sprite sheet
  Future<SpriteAnimation> createAnimation(
    String spritePath, {
    required int frameCount,
    required double stepTime,
    int columns = 0,
    int rows = 1,
    double? spriteWidth,
    double? spriteHeight,
    bool loop = true,
  }) async {
    final String cacheKey =
        '$spritePath:$frameCount:$stepTime:$columns:$rows:$loop';

    if (_animationCache.containsKey(cacheKey)) {
      return _animationCache[cacheKey]!;
    }
    try {
      // If columns not specified, assume all frames are in a single row
      final int finalColumns = columns == 0 ? frameCount : columns;

      final List<Sprite> sprites = await _spriteLoader.loadSpriteSheet(
        spritePath,
        columns: finalColumns,
        rows: rows,
        spriteWidth: spriteWidth ?? 32.0,
        spriteHeight: spriteHeight ?? 32.0,
      );

      // Take only the required number of frames
      final List<Sprite> animationSprites = sprites.take(frameCount).toList();

      final SpriteAnimation animation = SpriteAnimation.spriteList(
        animationSprites,
        stepTime: stepTime,
        loop: loop,
      );

      _animationCache[cacheKey] = animation;
      return animation;
    } catch (e) {
      throw Exception(
        'Failed to create animation from: $spritePath. Error: $e',
      );
    }
  }

  /// Create animation from individual sprite files
  Future<SpriteAnimation> createAnimationFromFiles(
    List<String> spritePaths, {
    required double stepTime,
    bool loop = true,
  }) async {
    final String cacheKey = '${spritePaths.join(':')}:$stepTime:$loop';

    if (_animationCache.containsKey(cacheKey)) {
      return _animationCache[cacheKey]!;
    }

    try {
      final List<Sprite> sprites = <Sprite>[];

      for (final String path in spritePaths) {
        final Sprite sprite = await _spriteLoader.loadSprite(path);
        sprites.add(sprite);
      }

      final SpriteAnimation animation = SpriteAnimation.spriteList(
        sprites,
        stepTime: stepTime,
        loop: loop,
      );

      _animationCache[cacheKey] = animation;
      return animation;
    } catch (e) {
      throw Exception(
        'Failed to create animation from files: $spritePaths. Error: $e',
      );
    }
  }

  /// Load player animations
  Future<Map<String, SpriteAnimation>> loadPlayerAnimations() async {
    final Map<String, SpriteAnimation> animations = <String, SpriteAnimation>{};

    // Idle animation
    animations['idle'] = await createAnimation(
      'player/idle.png',
      frameCount: 4,
      stepTime: 0.2,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Walk animation
    animations['walk'] = await createAnimation(
      'player/walk.png',
      frameCount: 8,
      stepTime: 0.1,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Jump animation
    animations['jump'] = await createAnimation(
      'player/jump.png',
      frameCount: 6,
      stepTime: 0.15,
      loop: false,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Attack animation
    animations['attack'] = await createAnimation(
      'player/attack.png',
      frameCount: 5,
      stepTime: 0.1,
      loop: false,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Fall animation
    animations['fall'] = await createAnimation(
      'player/fall.png',
      frameCount: 2,
      stepTime: 0.2,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    return animations;
  }

  /// Load enemy animations
  Future<Map<String, Map<String, SpriteAnimation>>>
      loadEnemyAnimations() async {
    final Map<String, Map<String, SpriteAnimation>> enemyAnimations =
        <String, Map<String, SpriteAnimation>>{};

    // Goblin animations
    final Map<String, SpriteAnimation> goblinAnims =
        <String, SpriteAnimation>{};
    goblinAnims['idle'] = await createAnimation(
      'enemies/goblin_idle.png',
      frameCount: 4,
      stepTime: 0.25,
      spriteWidth: 24,
      spriteHeight: 24,
    );
    goblinAnims['walk'] = await createAnimation(
      'enemies/goblin_walk.png',
      frameCount: 6,
      stepTime: 0.15,
      spriteWidth: 24,
      spriteHeight: 24,
    );
    goblinAnims['attack'] = await createAnimation(
      'enemies/goblin_attack.png',
      frameCount: 4,
      stepTime: 0.12,
      loop: false,
      spriteWidth: 24,
      spriteHeight: 24,
    );
    enemyAnimations['goblin'] = goblinAnims;

    // Orc animations
    final Map<String, SpriteAnimation> orcAnims = <String, SpriteAnimation>{};
    orcAnims['idle'] = await createAnimation(
      'enemies/orc_idle.png',
      frameCount: 4,
      stepTime: 0.3,
      spriteWidth: 48,
      spriteHeight: 48,
    );
    orcAnims['walk'] = await createAnimation(
      'enemies/orc_walk.png',
      frameCount: 6,
      stepTime: 0.2,
      spriteWidth: 48,
      spriteHeight: 48,
    );
    orcAnims['attack'] = await createAnimation(
      'enemies/orc_attack.png',
      frameCount: 7,
      stepTime: 0.1,
      loop: false,
      spriteWidth: 48,
      spriteHeight: 48,
    );
    enemyAnimations['orc'] = orcAnims;

    return enemyAnimations;
  }

  /// Load UI animations (button states, transitions, etc.)
  Future<Map<String, SpriteAnimation>> loadUIAnimations() async {
    final Map<String, SpriteAnimation> animations = <String, SpriteAnimation>{};

    // Button hover animation
    animations['button_hover'] = await createAnimation(
      'ui/button_states.png',
      frameCount: 3,
      stepTime: 0.1,
      loop: false,
      spriteWidth: 96,
      spriteHeight: 32,
    );

    // Loading spinner
    animations['loading_spinner'] = await createAnimation(
      'ui/loading_spinner.png',
      frameCount: 8,
      stepTime: 0.125,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Health bar pulse
    animations['health_pulse'] = await createAnimation(
      'ui/health_pulse.png',
      frameCount: 4,
      stepTime: 0.2,
      spriteWidth: 64,
      spriteHeight: 8,
    );

    return animations;
  }

  /// Load environmental animations (water, fire, etc.)
  Future<Map<String, SpriteAnimation>> loadEnvironmentAnimations() async {
    final Map<String, SpriteAnimation> animations = <String, SpriteAnimation>{};

    // Water animation
    animations['water'] = await createAnimation(
      'environment/water.png',
      frameCount: 6,
      stepTime: 0.2,
      spriteWidth: 32,
      spriteHeight: 32,
    );

    // Fire animation
    animations['fire'] = await createAnimation(
      'environment/fire.png',
      frameCount: 8,
      stepTime: 0.1,
      spriteWidth: 24,
      spriteHeight: 32,
    );

    // Wind effect
    animations['wind'] = await createAnimation(
      'environment/wind.png',
      frameCount: 4,
      stepTime: 0.3,
      spriteWidth: 16,
      spriteHeight: 16,
    );

    // Collectible sparkle
    animations['sparkle'] = await createAnimation(
      'effects/sparkle.png',
      frameCount: 6,
      stepTime: 0.1,
      loop: false,
      spriteWidth: 16,
      spriteHeight: 16,
    );

    return animations;
  }

  /// Create a composite animation with multiple layers
  Future<CompositeAnimation> createCompositeAnimation(
    Map<String, AnimationLayer> layers,
  ) async {
    final Map<String, SpriteAnimation> animationLayers =
        <String, SpriteAnimation>{};

    for (final MapEntry<String, AnimationLayer> entry in layers.entries) {
      final String layerName = entry.key;
      final AnimationLayer layer = entry.value;

      final SpriteAnimation animation = await createAnimation(
        layer.spritePath,
        frameCount: layer.frameCount,
        stepTime: layer.stepTime,
        spriteWidth: layer.spriteWidth,
        spriteHeight: layer.spriteHeight,
        loop: layer.loop,
      );

      animationLayers[layerName] = animation;
    }

    return CompositeAnimation(animationLayers);
  }

  /// Get cached animation if available
  SpriteAnimation? getCachedAnimation(String key) {
    return _animationCache[key];
  }

  /// Pre-load critical animations
  Future<void> _preloadCriticalAnimations() async {
    try {
      // Load basic player animations
      await loadPlayerAnimations();

      // Load basic UI animations
      await loadUIAnimations();
    } catch (e) {
      logger.warning('Failed to preload some animations', e);
    }
  }

  /// Clear specific animation from cache
  void clearAnimation(String key) {
    _animationCache.remove(key);
  }

  /// Clear all cached animations
  void clearCache() {
    _animationCache.clear();
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    return <String, dynamic>{
      'cached_animations': _animationCache.length,
      'sprite_loader_stats': _spriteLoader.getMemoryStats(),
    };
  }

  /// Dispose resources
  void dispose() {
    clearCache();
    _isInitialized = false;
  }

  /// Load animation by name
  Future<SpriteAnimation?> loadAnimation(String name) async {
    // Check if already cached
    if (_animationCache.containsKey(name)) {
      return _animationCache[name];
    }

    try {
      // Try to load from predefined animation sets
      if (name.startsWith('player_')) {
        final Map<String, SpriteAnimation> playerAnimations =
            await loadPlayerAnimations();
        final String animName = name.substring(7); // Remove 'player_' prefix
        return playerAnimations[animName];
      } else if (name.startsWith('enemy_')) {
        final List<String> parts = name.split('_');
        if (parts.length >= 3) {
          final String enemyType = parts[1];
          final String animName = parts.sublist(2).join('_');
          final Map<String, Map<String, SpriteAnimation>> enemyAnimations =
              await loadEnemyAnimations();
          return enemyAnimations[enemyType]?[animName];
        }
      } else if (name.startsWith('ui_')) {
        final Map<String, SpriteAnimation> uiAnimations =
            await loadUIAnimations();
        final String animName = name.substring(3); // Remove 'ui_' prefix
        return uiAnimations[animName];
      } else if (name.startsWith('env_')) {
        final Map<String, SpriteAnimation> envAnimations =
            await loadEnvironmentAnimations();
        final String animName = name.substring(4); // Remove 'env_' prefix
        return envAnimations[animName];
      }

      return null;
    } catch (e) {
      logger.warning('Failed to load animation: $name', e);
      return null;
    }
  }

  /// Check if animation is loaded in cache
  bool isLoaded(String name) {
    return _animationCache.containsKey(name);
  }

  /// Unload specific animation from cache
  void unload(String name) {
    _animationCache.remove(name);
  }
}

/// Configuration for animation layers in composite animations
class AnimationLayer {
  const AnimationLayer({
    required this.spritePath,
    required this.frameCount,
    required this.stepTime,
    this.spriteWidth = 32.0,
    this.spriteHeight = 32.0,
    this.loop = true,
    this.offset,
    this.opacity = 1.0,
  });
  final String spritePath;
  final int frameCount;
  final double stepTime;
  final double spriteWidth;
  final double spriteHeight;
  final bool loop;
  final Vector2? offset;
  final double opacity;
}

/// Composite animation that can handle multiple animation layers
class CompositeAnimation {
  CompositeAnimation(this.layers);
  final Map<String, SpriteAnimation> layers;

  /// Get animation for specific layer
  SpriteAnimation? getLayer(String layerName) {
    return layers[layerName];
  }
}

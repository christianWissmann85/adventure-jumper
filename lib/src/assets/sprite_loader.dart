import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../utils/error_handler.dart';
import '../utils/exceptions.dart';

/// Handles loading and management of sprite assets for the game
class SpriteLoader {
  factory SpriteLoader() => _instance;
  SpriteLoader._internal();
  static final SpriteLoader _instance = SpriteLoader._internal();

  final Map<String, Sprite> _spriteCache = <String, Sprite>{};
  final Map<String, ui.Image> _imageCache = <String, ui.Image>{};
  final Images _flameImages = Images();

  bool _isInitialized = false;

  /// Initialize the sprite loader
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Pre-load critical sprites
    await _preloadCriticalSprites();
    _isInitialized = true;
  }

  /// Load a sprite from the given path
  Future<Sprite> loadSprite(String path) async {
    if (_spriteCache.containsKey(path)) {
      return _spriteCache[path]!;
    }

    return ErrorHandler.handleAssetError<Sprite>(
      () async {
        final ui.Image image = await _flameImages.load(path);
        final Sprite sprite = Sprite(image);
        _spriteCache[path] = sprite;
        return sprite;
      },
      path,
      'sprite',
      context: 'SpriteLoader',
    ).then((Sprite? sprite) {
      if (sprite == null) {
        throw AssetNotFoundException(path, 'sprite');
      }
      return sprite;
    });
  }

  /// Load a sprite with specific source rectangle
  Future<Sprite> loadSpriteWithSrc(
    String path, {
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
  }) async {
    final String cacheKey = '$path:$srcX:$srcY:$srcWidth:$srcHeight';

    if (_spriteCache.containsKey(cacheKey)) {
      return _spriteCache[cacheKey]!;
    }
    return ErrorHandler.handleAssetError<Sprite>(
      () async {
        final ui.Image image = await _flameImages.load(path);
        final Sprite sprite = Sprite(
          image,
          srcPosition: Vector2(srcX, srcY),
          srcSize: Vector2(srcWidth, srcHeight),
        );
        _spriteCache[cacheKey] = sprite;
        return sprite;
      },
      path,
      'sprite_section',
      context: 'SpriteLoader.loadSpriteWithSrc',
    ).then((Sprite? sprite) {
      if (sprite == null) {
        // Use the constructor that doesn't require a context parameter
        throw AssetNotFoundException(path, 'sprite_section');
      }
      return sprite;
    });
  }

  /// Load multiple sprites from a sprite sheet
  Future<List<Sprite>> loadSpriteSheet(
    String path, {
    required int columns,
    required int rows,
    required double spriteWidth,
    required double spriteHeight,
  }) async {
    final List<Sprite>? result = await ErrorHandler.handleAssetError<List<Sprite>>(
      () async {
        final List<Sprite> sprites = <Sprite>[];

        for (int row = 0; row < rows; row++) {
          for (int col = 0; col < columns; col++) {
            try {
              final Sprite sprite = await loadSpriteWithSrc(
                path,
                srcX: col * spriteWidth,
                srcY: row * spriteHeight,
                srcWidth: spriteWidth,
                srcHeight: spriteHeight,
              );
              sprites.add(sprite);
            } on AssetNotFoundException catch (e) {
              ErrorHandler.logWarning(
                'Failed to load sprite sheet cell (row=$row, col=$col) from $path',
                error: e,
                context: 'SpriteLoader.loadSpriteSheet',
              );
              // Add placeholder or continue without this sprite
              continue;
            }
          }
        }

        if (sprites.isEmpty) {
          throw AssetLoadingException(
            'Failed to load any sprites from sprite sheet',
            path,
            'sprite_sheet',
          );
        }

        return sprites;
      },
      path,
      'sprite_sheet',
      context: 'SpriteLoader.loadSpriteSheet',
      fallback: <Sprite>[],
    );

    // Always return a non-nullable list (either the result or an empty list)
    return result ?? <Sprite>[];
  }

  /// Load sprites for character animations
  Future<Map<String, List<Sprite>>> loadCharacterSprites(
    String basePath,
    Map<String, SpriteSheetConfig> animations,
  ) async {
    final Map<String, List<Sprite>> characterSprites = <String, List<Sprite>>{};

    for (final MapEntry<String, SpriteSheetConfig> entry in animations.entries) {
      final String animationName = entry.key;
      final SpriteSheetConfig config = entry.value;
      final String fullPath = '$basePath/${config.fileName}';

      try {
        final List<Sprite> sprites = await loadSpriteSheet(
          fullPath,
          columns: config.columns,
          rows: config.rows,
          spriteWidth: config.spriteWidth,
          spriteHeight: config.spriteHeight,
        );

        characterSprites[animationName] = sprites;
      } on AssetNotFoundException catch (e) {
        ErrorHandler.logError(
          'Failed to load character animation "$animationName" from $fullPath',
          error: e,
          context: 'SpriteLoader.loadCharacterSprites',
        );
        // Add empty list so code depending on this animation can still function
        characterSprites[animationName] = <Sprite>[];
      } on AssetLoadingException catch (e) {
        ErrorHandler.logError(
          'Error loading character animation "$animationName" from $fullPath',
          error: e,
          context: 'SpriteLoader.loadCharacterSprites',
        );
        // Add empty list so code depending on this animation can still function
        characterSprites[animationName] = <Sprite>[];
      }
    }

    return characterSprites;
  }

  /// Get cached sprite if available
  Sprite? getCachedSprite(String path) {
    return _spriteCache[path];
  }

  /// Get cached image if available
  ui.Image? getCachedImage(String path) {
    return _imageCache[path];
  }

  /// Pre-load critical sprites for immediate use
  Future<void> _preloadCriticalSprites() async {
    final List<String> criticalSprites = <String>[
      'player/idle.png',
      'ui/button_normal.png',
      'ui/button_pressed.png',
      'ui/health_bar.png',
      'ui/energy_bar.png',
    ];

    for (final String spritePath in criticalSprites) {
      try {
        await loadSprite(spritePath);
      } on AssetNotFoundException catch (e) {
        // Log warning but continue - some sprites might not exist yet
        ErrorHandler.logWarning(
          'Failed to preload sprite: $spritePath',
          error: e,
          context: 'SpriteLoader._preloadCriticalSprites',
        );
      } on AssetLoadingException catch (e) {
        ErrorHandler.logWarning(
          'Error preloading sprite: $spritePath',
          error: e,
          context: 'SpriteLoader._preloadCriticalSprites',
        );
      }
    }
  }

  /// Check if sprite is loaded in cache
  bool isLoaded(String path) {
    return _spriteCache.containsKey(path);
  }

  /// Unload specific sprite from cache
  void unload(String path) {
    _spriteCache.remove(path);
    _imageCache.remove(path);
  }

  /// Clear specific sprite from cache
  void clearSprite(String path) {
    _spriteCache.remove(path);
  }

  /// Clear all cached sprites
  void clearCache() {
    _spriteCache.clear();
    _imageCache.clear();
    _flameImages.clearCache();
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    return <String, dynamic>{
      'cached_sprites': _spriteCache.length,
      'cached_images': _imageCache.length,
      'flame_cache_initialized': _isInitialized,
    };
  }

  /// Dispose resources
  void dispose() {
    clearCache();
    _isInitialized = false;
  }
}

/// Configuration for sprite sheet loading
class SpriteSheetConfig {
  const SpriteSheetConfig({
    required this.fileName,
    required this.columns,
    required this.rows,
    required this.spriteWidth,
    required this.spriteHeight,
  });
  final String fileName;
  final int columns;
  final int rows;
  final double spriteWidth;
  final double spriteHeight;
}

/// Predefined sprite configurations for common game assets
class SpriteConfigs {
  static const Map<String, SpriteSheetConfig> playerAnimations = <String, SpriteSheetConfig>{
    'idle': SpriteSheetConfig(
      fileName: 'player_idle.png',
      columns: 4,
      rows: 1,
      spriteWidth: 32,
      spriteHeight: 32,
    ),
    'walk': SpriteSheetConfig(
      fileName: 'player_walk.png',
      columns: 8,
      rows: 1,
      spriteWidth: 32,
      spriteHeight: 32,
    ),
    'jump': SpriteSheetConfig(
      fileName: 'player_jump.png',
      columns: 6,
      rows: 1,
      spriteWidth: 32,
      spriteHeight: 32,
    ),
    'attack': SpriteSheetConfig(
      fileName: 'player_attack.png',
      columns: 5,
      rows: 1,
      spriteWidth: 32,
      spriteHeight: 32,
    ),
  };

  static const Map<String, Map<String, SpriteSheetConfig>> enemyAnimations = <String, Map<String, SpriteSheetConfig>>{
    'goblin': <String, SpriteSheetConfig>{
      'idle': SpriteSheetConfig(
        fileName: 'goblin_idle.png',
        columns: 4,
        rows: 1,
        spriteWidth: 24,
        spriteHeight: 24,
      ),
      'walk': SpriteSheetConfig(
        fileName: 'goblin_walk.png',
        columns: 6,
        rows: 1,
        spriteWidth: 24,
        spriteHeight: 24,
      ),
    },
    'orc': <String, SpriteSheetConfig>{
      'idle': SpriteSheetConfig(
        fileName: 'orc_idle.png',
        columns: 4,
        rows: 1,
        spriteWidth: 48,
        spriteHeight: 48,
      ),
      'attack': SpriteSheetConfig(
        fileName: 'orc_attack.png',
        columns: 7,
        rows: 1,
        spriteWidth: 48,
        spriteHeight: 48,
      ),
    },
  };

  static const Map<String, SpriteSheetConfig> uiSprites = <String, SpriteSheetConfig>{
    'button_normal': SpriteSheetConfig(
      fileName: 'ui_button.png',
      columns: 3,
      rows: 1,
      spriteWidth: 96,
      spriteHeight: 32,
    ),
    'health_bar': SpriteSheetConfig(
      fileName: 'health_bar.png',
      columns: 1,
      rows: 1,
      spriteWidth: 64,
      spriteHeight: 8,
    ),
  };
}

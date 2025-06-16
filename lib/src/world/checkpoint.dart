import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../assets/sprite_loader.dart';
import '../components/collision_component.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import '../utils/logger.dart';

/// Save point functionality
/// Allows players to save progress and respawn at checkpoints
class Checkpoint extends Entity {
  Checkpoint({
    required super.position,
    required this.checkpointId,
    this.activationRadius = 32.0,
    this.activationMessage = 'Progress saved',
    this.showMessage = true,
  });

  // Checkpoint properties
  final String checkpointId;
  final double activationRadius;
  final String activationMessage;
  final bool showMessage;

  // State tracking
  bool _isActivated = false;

  /// Whether this checkpoint has been activated
  bool get isActivated => _isActivated;

  // Visual components
  late SpriteComponent _inactiveSpriteComponent;
  late SpriteComponent _activeSpriteComponent;
  late CollisionComponent _collisionComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load checkpoint sprites
    await _loadSprites();

    // Set up collision for player detection
    _setupCollision();

    // Initial visual state
    _updateVisuals();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isActivated) return;

    // Check for player proximity
    _checkPlayerProximity();
  }

  /// Load checkpoint sprite assets
  Future<void> _loadSprites() async {
    // Load actual checkpoint sprites using SpriteLoader
    final SpriteLoader spriteLoader = SpriteLoader();

    try {
      // Load inactive checkpoint sprite (small crystal)
      final Sprite inactiveSprite = await spriteLoader
          .loadSprite('props/luminara/prop_luminara_small_crystal.png');
      _inactiveSpriteComponent = SpriteComponent(
        sprite: inactiveSprite,
        size: Vector2(32, 32),
      );

      // Load active checkpoint sprite (star)
      final Sprite activeSprite =
          await spriteLoader.loadSprite('ui/icons/star.png');
      _activeSpriteComponent = SpriteComponent(
        sprite: activeSprite,
        size: Vector2(32, 32),
      );

      print('[Checkpoint] Loaded actual sprites for checkpoint states');
    } catch (e) {
      print('[Checkpoint] Failed to load sprites, using fallback: $e');

      // Fallback to basic sprite components if loading fails
      _inactiveSpriteComponent = SpriteComponent()..size = Vector2(32, 32);
      _activeSpriteComponent = SpriteComponent()..size = Vector2(32, 32);
    }

    // Add sprites as children
    add(_inactiveSpriteComponent);
    add(_activeSpriteComponent);

    // Initially hide the activated sprite
    _activeSpriteComponent.opacity = 0;
  }

  /// Set up collision detection
  void _setupCollision() {
    _collisionComponent = CollisionComponent();

    // In a future sprint, we'll properly configure the collision shape
    // For now, just add it as a placeholder
    add(_collisionComponent);
  }

  /// Check if player is near checkpoint
  void _checkPlayerProximity() {
    // Player proximity check will be implemented in future sprints
  }

  /// Activate the checkpoint
  @override
  void activate([Entity? entity]) {
    if (_isActivated) return;
    final Player? player = entity is Player ? entity : null;
    if (player == null) return;

    _isActivated = true;

    // Update visuals
    _updateVisuals(); // Display activation message if enabled
    if (showMessage) {
      // Message display will be implemented in future sprints
      logger.info('Checkpoint: $activationMessage');
    }

    // Save game progress
    _saveProgress(player);

    // Play activation effects
    _playActivationEffects();
  }

  /// Save game progress at this checkpoint
  void _saveProgress(Player player) {
    // Save manager integration will be implemented in future sprints

    // Log checkpoint save progress
    logger.info('Checkpoint: Saved progress at checkpoint $checkpointId');
  }

  /// Update visuals based on activation state
  void _updateVisuals() {
    _inactiveSpriteComponent.opacity = _isActivated ? 0 : 1;
    _activeSpriteComponent.opacity = _isActivated ? 1 : 0;
  }

  /// Play visual and audio effects when activated
  void _playActivationEffects() {
    // Add visual pulse effect
    final ColorEffect colorEffect = ColorEffect(
      const Color(0xFFFFFFFF),
      EffectController(
        duration: 0.5,
        reverseDuration: 0.5,
      ),
      opacityTo: 0.7,
    );

    add(colorEffect);

    // Add scale pulsing effect
    final ScaleEffect scaleEffect = ScaleEffect.by(
      Vector2.all(1.5),
      EffectController(
        duration: 0.5,
        reverseDuration: 0.5,
      ),
    );

    add(scaleEffect);

    // Audio effect will be implemented in future sprints
  }
}

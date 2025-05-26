import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../player/player.dart';
import '../player/player_stats.dart';
import 'collectible.dart';
import 'entity.dart';

/// AetherShard collectible class
/// Provides Aether energy to the player when collected
/// Features floating animation, pulse effects, and particle feedback
class AetherShard extends Collectible {
  AetherShard({
    required super.position,
    int? aetherValue,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
  }) : super(
          collectibleType: 'aether_shard',
          autoCollect: true,
          respawns: false,
          value: (aetherValue ?? _defaultAetherValue).toDouble(),
          hasPulseEffect: true,
          hasFloatEffect: true,
        ) {
    _aetherValue = aetherValue ?? _defaultAetherValue;
  }

  // Default Aether value for shards
  static const int _defaultAetherValue = 5;

  // Aether value this shard provides
  int _aetherValue = _defaultAetherValue;

  // Visual components
  SpriteComponent? _spriteComponent;
  CircleComponent? _glowEffect;

  // Pickup animation state
  bool _isBeingCollected = false;

  // Visual effect parameters
  static const double _baseSize = 16.0;
  static const double _glowSize = 24.0;
  final Color _aetherColor = const Color(0xFF4FC3F7); // Light blue Aether color
  final Color _glowColor = const Color(0x664FC3F7); // Semi-transparent glow

  @override
  Future<void> setupCollectible() async {
    // Set default size if not provided
    if (size == Vector2.zero()) {
      size = Vector2.all(_baseSize);
    }

    await _setupVisuals();
    await _setupEffects();
  }

  /// Setup visual components for the AetherShard
  Future<void> _setupVisuals() async {
    // Create the main shard sprite component
    // For now, use a placeholder diamond shape until we have actual sprites
    _spriteComponent = SpriteComponent(
      size: Vector2.all(_baseSize),
      anchor: Anchor.center,
    );

    // Create a diamond-shaped placeholder sprite using a rotated rectangle
    final RectangleComponent diamond = RectangleComponent(
      size: Vector2.all(_baseSize * 0.8),
      paint: Paint()
        ..color = _aetherColor
        ..style = PaintingStyle.fill,
      anchor: Anchor.center,
    );
    diamond.angle = pi / 4; // 45 degrees rotation to make diamond shape

    // Add border to the diamond
    final RectangleComponent border = RectangleComponent(
      size: Vector2.all(_baseSize * 0.8),
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
      anchor: Anchor.center,
    );
    border.angle = pi / 4;

    _spriteComponent!.add(diamond);
    _spriteComponent!.add(border);
    add(_spriteComponent!);

    // Create glow effect
    _glowEffect = CircleComponent(
      radius: _glowSize / 2,
      paint: Paint()
        ..color = _glowColor
        ..style = PaintingStyle.fill,
      anchor: Anchor.center,
    );
    add(_glowEffect!);
  }

  /// Setup visual effects (floating, pulsing)
  Future<void> _setupEffects() async {
    // Add a subtle rotation animation to the shard
    if (_spriteComponent != null) {
      _spriteComponent!.add(
        RotateEffect.by(
          2 * pi,
          EffectController(
            duration: 4.0,
            infinite: true,
          ),
        ),
      );
    }

    // Add pulsing glow effect
    if (_glowEffect != null) {
      _glowEffect!.add(
        ScaleEffect.by(
          Vector2.all(1.2),
          EffectController(
            duration: 1.5,
            infinite: true,
            alternate: true,
          ),
        ),
      );
    }
  }

  @override
  void updateCollectible(double dt) {
    // Additional shard-specific update logic can go here
    // The base floating and pulsing effects are handled by the parent class
  }

  @override
  void onCollected() {
    if (_isBeingCollected) return; // Prevent double collection
    _isBeingCollected = true;

    // Play collection effects
    _playCollectionAnimation();
    _giveAetherToPlayer();

    // Remove after animation completes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isMounted) {
        removeFromParent();
      }
    });
  }

  /// Play visual feedback animation when collected
  void _playCollectionAnimation() {
    // Scale up and fade out animation
    add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(duration: 0.3),
      ),
    );

    add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.5),
      ),
    );

    // Create particle-like sparkle effects
    _createSparkleEffects();
  }

  /// Create sparkle particle effects on collection
  void _createSparkleEffects() {
    const int sparkleCount = 8;
    const double sparkleSpeed = 50.0;

    for (int i = 0; i < sparkleCount; i++) {
      final double angle = (i / sparkleCount) * 2 * pi;
      final Vector2 direction = Vector2(cos(angle), sin(angle));

      final CircleComponent sparkle = CircleComponent(
        radius: 2.0,
        paint: Paint()..color = _aetherColor,
        anchor: Anchor.center,
      );

      // Position sparkle at shard center
      sparkle.position = position.clone();

      // Add movement effect
      sparkle.add(
        MoveByEffect(
          direction * sparkleSpeed,
          EffectController(duration: 0.4),
        ),
      );

      // Add fade out effect
      sparkle.add(
        OpacityEffect.to(
          0.0,
          EffectController(duration: 0.4),
          onComplete: () => sparkle.removeFromParent(),
        ),
      );

      // Add to parent world
      if (parent != null) {
        parent!.add(sparkle);
      }
    }
  }

  /// Give Aether to the player
  void _giveAetherToPlayer() {
    // Find the player entity to give Aether to
    Entity? playerEntity = _findPlayerEntity();

    if (playerEntity is Player) {
      // Get player stats component
      final PlayerStats? playerStats =
          playerEntity.children.whereType<PlayerStats>().isNotEmpty
              ? playerEntity.children.whereType<PlayerStats>().first
              : null;

      if (playerStats != null) {
        // Use the collectAetherShard method which handles both shard counting
        // and current Aether restoration
        playerStats.collectAetherShard(_aetherValue);
      }
    }
  }

  /// Find the player entity in the game world
  Entity? _findPlayerEntity() {
    // Walk up the component tree to find the game world
    Component? current = parent;
    while (current != null && current.parent != null) {
      current = current.parent;
    }

    if (current != null) {
      // Search for player entity in the world
      return _findPlayerInComponent(current);
    }

    return null;
  }

  /// Recursively search for player entity
  Entity? _findPlayerInComponent(Component component) {
    // Check if this component is a Player
    if (component is Player) {
      return component;
    }

    // Search in children
    for (final Component child in component.children) {
      if (child is Player) {
        return child;
      }

      // Recursively search in child's children
      final Entity? found = _findPlayerInComponent(child);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  @override
  void onCollision(Entity other) {
    // The base Collectible class already handles auto-collection on player contact
    super.onCollision(other);
  }

  // Getters
  int get aetherValue => _aetherValue;
  bool get isBeingCollected => _isBeingCollected;

  /// Static factory method to create AetherShard with specific Aether value
  static AetherShard createWithValue(Vector2 position, int aetherValue) {
    return AetherShard(
      position: position,
      aetherValue: aetherValue,
    );
  }

  /// Static factory method to create small AetherShard (3 Aether)
  static AetherShard createSmall(Vector2 position) {
    return AetherShard(
      position: position,
      aetherValue: 3,
    );
  }

  /// Static factory method to create large AetherShard (10 Aether)
  static AetherShard createLarge(Vector2 position) {
    return AetherShard(
      position: position,
      aetherValue: 10,
    );
  }
}

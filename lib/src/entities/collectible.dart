import 'dart:math';

import 'package:flame/components.dart';

import 'entity.dart';

/// Base class for collectible items
/// Handles pickup mechanics, effects, and animations
class Collectible extends Entity {
  Collectible({
    required Vector2 position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
    String? collectibleType,
    bool? autoCollect,
    bool? respawns,
    double? respawnTime,
    double? value,
    bool? hasPulseEffect,
    bool? hasFloatEffect,
  }) : super(
          position: position,
          type: 'collectible',
        ) {
    if (collectibleType != null) _collectibleType = collectibleType;
    if (autoCollect != null) _autoCollect = autoCollect;
    if (respawns != null) _respawns = respawns;
    if (respawnTime != null) _respawnTime = respawnTime;
    if (value != null) _value = value;
    if (hasPulseEffect != null) _hasPulseEffect = hasPulseEffect;
    if (hasFloatEffect != null) _hasFloatEffect = hasFloatEffect;
    _originalPosition = position.clone();
    _initialFloatOffset = position.y;
  }
  // Collectible properties
  String _collectibleType = 'generic';
  bool _isCollected = false;
  bool _autoCollect = true;
  bool _respawns = false;
  double _respawnTime = 10;
  double _value = 1;

  // Visual effects
  bool _hasPulseEffect = true;
  bool _hasFloatEffect = true;
  final double _pulseFrequency = 2;
  final double _floatAmplitude = 5;
  final double _floatFrequency = 1;
  double _initialFloatOffset = 0;

  // Animation tracking
  double _animationTime = 0;
  Vector2 _originalPosition = Vector2.zero();
  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

    // Setup collectible-specific components and properties
    await setupCollectible();

    // Setup default collision handler for auto-collection
    onCollision = _handleCollision;
  }

  /// Handle collision with another entity
  void _handleCollision(Entity other) {
    // Auto-collect on player contact if enabled
    if (_autoCollect && other.type == 'player') {
      collect();
    }
  }

  @override
  void updateEntity(double dt) {
    super.updateEntity(dt);

    if (_isCollected) return;

    _animationTime += dt;

    // Apply visual effects
    if (_hasFloatEffect) {
      applyFloatEffect(dt);
    }

    if (_hasPulseEffect) {
      applyPulseEffect(dt);
    }

    // Collectible-specific update logic
    updateCollectible(dt);
  }

  /// Custom collectible setup (to be implemented by subclasses)
  Future<void> setupCollectible() async {
    // Override in subclasses
  }

  /// Custom collectible update logic (to be implemented by subclasses)
  void updateCollectible(double dt) {
    // Override in subclasses
  }

  /// Collect this item
  bool collect() {
    if (_isCollected) return false;

    _isCollected = true;

    // Apply collection effect
    onCollected();

    // Handle disappearance or respawn
    if (_respawns) {
      startRespawnTimer();
    } else {
      removeFromParent();
    }

    return true;
  }

  /// Actions to take when collected (to be implemented by subclasses)
  void onCollected() {
    // Override in subclasses
    // Default: Play collection animation and sound
  }

  /// Start respawn timer if item respawns
  void startRespawnTimer() {
    deactivate();

    // Implementation needed: Implement respawn timer logic
    // After _respawnTime seconds, call respawn()
  }

  /// Respawn this collectible
  void respawn() {
    _isCollected = false;
    activate();
  }

  /// Apply floating effect animation
  void applyFloatEffect(double dt) {
    // Simple sine wave floating motion
    final double newY = _originalPosition.y +
        sin(_animationTime * _floatFrequency) * _floatAmplitude;
    position.y = newY;
  }

  /// Apply pulse effect animation
  void applyPulseEffect(double dt) {
    // Simple scale pulsing
    final double pulse = 1.0 + (sin(_animationTime * _pulseFrequency) * 0.1);
    scale = Vector2.all(pulse);
  }

  // Getters
  String get collectibleType => _collectibleType;
  bool get isCollected => _isCollected;
  double get value => _value;
  double get respawnTime => _respawnTime;
  double get initialFloatOffset => _initialFloatOffset;
}

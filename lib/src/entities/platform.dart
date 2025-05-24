import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color, Paint;

import '../components/adv_sprite_component.dart';
import '../components/physics_component.dart';
import 'entity.dart';

/// Base class for platforms in the game
/// Handles various platform types: static, moving, breaking, etc.
class Platform extends Entity {
  Platform({
    required Vector2 position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
    String? platformType,
    bool? isMoving,
    Vector2? moveStart,
    Vector2? moveEnd,
    double? moveSpeed,
    bool? isBreakable,
    bool? isOneWay,
    bool? needsPlayerWeight,
  }) : super(
          position: position,
          type: 'platform',
        ) {
    if (platformType != null) _platformType = platformType;
    if (isMoving != null) _isMoving = isMoving;
    if (moveStart != null) _moveStart = moveStart;
    if (moveEnd != null) _moveEnd = moveEnd;
    if (moveSpeed != null) _moveSpeed = moveSpeed;
    if (isBreakable != null) _isBreakable = isBreakable;
    if (isOneWay != null) _isOneWay = isOneWay;
    if (needsPlayerWeight != null) _needsPlayerWeight = needsPlayerWeight;

    // Initialize movement states
    if (_isMoving) {
      _moveStart = _moveStart ?? position.clone();
      _moveEnd = _moveEnd ?? position.clone();
      _currentTarget = _moveEnd!;
    }
  }

  // Platform properties
  String _platformType = 'solid';
  bool _isMoving = false;
  Vector2? _moveStart;
  Vector2? _moveEnd;
  double _moveSpeed = 50;
  bool _isBreakable = false;
  bool _breakProgress = false;
  bool _isOneWay = false;
  bool _needsPlayerWeight = false;
  bool _hasPlayerContact = false;

  // Movement tracking
  Vector2? _currentTarget;
  double _movementT = 0;
  bool _movingToEnd = true;
  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

    // Setup platform-specific physics - platforms usually have static physics
    physics = PhysicsComponent()
      ..isStatic = !_isMoving
      ..isSensor = _isOneWay;

    add(physics!);

    // Configure collision component for platform boundaries
    collision.setHitboxSize(size);
    collision.isOneWay = _isOneWay;
    collision.addCollisionTag('platform');
    collision.addCollisionTag(_platformType);

    // Additional platform setup
    await setupPlatform();
  }

  @override
  void updateEntity(double dt) {
    super.updateEntity(dt);

    // Handle platform movement if it's a moving platform
    if (_isMoving) {
      updateMovement(dt);
    }

    // Handle breakable platforms
    if (_isBreakable && _breakProgress) {
      updateBreaking(dt);
    }

    // Platform-specific update logic
    updatePlatform(dt);
  }

  /// Custom platform setup (to be implemented by subclasses)
  Future<void> setupPlatform() async {
    // Initialize sprite component (inherited from Entity)
    sprite = AdvSpriteComponent(
      spriteSize: size,
      opacity: 1.0,
    );
    add(sprite!);

    // For now, create a placeholder sprite using a colored rectangle
    // In the future, this will load actual platform sprites from assets
    // We'll create a temporary sprite representation using RectangleComponent
    final RectangleComponent platformSprite = RectangleComponent(
      size: size,
      paint: Paint()..color = _getPlatformColor(),
    );
    add(platformSprite);

    // TODO: Replace with actual sprite loading in future sprints
    // Example: await sprite!.setSprite(await Sprite.load('platforms/${_platformType}_platform.png'));
  }

  /// Get platform color based on type
  Color _getPlatformColor() {
    switch (_platformType) {
      case 'solid':
        return const Color(0xFF8B4513); // Brown
      case 'ice':
        return const Color(0xFF87CEEB); // Sky blue
      case 'lava':
        return const Color(0xFFFF4500); // Orange red
      case 'grass':
        return const Color(0xFF228B22); // Forest green
      default:
        return const Color(0xFF696969); // Dim gray
    }
  }

  /// Custom platform update logic (to be implemented by subclasses)
  void updatePlatform(double dt) {
    // Override in subclasses
  }

  /// Handle platform movement logic
  void updateMovement(double dt) {
    if (_moveStart == null || _moveEnd == null || _currentTarget == null) {
      return;
    }

    // Calculate movement progress
    _movementT += dt * _moveSpeed / 100;

    if (_movementT >= 1.0) {
      // Reached target point, switch direction
      _movementT = 0.0;
      _movingToEnd = !_movingToEnd;
      _currentTarget = _movingToEnd ? _moveEnd! : _moveStart!;
    }

    // Interpolate position between start and end points
    final Vector2 from = _movingToEnd ? _moveStart! : _moveEnd!;
    final Vector2 to = _currentTarget!;
    position = from + (to - from) * _movementT;
  }

  /// Handle breaking platform logic
  void updateBreaking(double dt) {
    // Override in subclasses to implement breaking animation and logic
  }

  /// Start platform breaking sequence
  void startBreaking() {
    if (_isBreakable) {
      _breakProgress = true;
      // Logic to handle breaking will be in updateBreaking
    }
  }

  /// Player contact began
  void onPlayerContact(bool hasContact) {
    _hasPlayerContact = hasContact;

    if (_needsPlayerWeight && hasContact) {
      // Platform responds to player weight (e.g., sinking platform)
    }
  }

  /// Get platform type
  String get platformType => _platformType;

  /// Check if platform is one-way (can be jumped through from below)
  bool get isOneWay => _isOneWay;

  /// Check if platform is breakable
  bool get isBreakable => _isBreakable;

  /// Check if platform is currently in movement
  bool get isMoving => _isMoving;

  /// Check if platform currently has player contact
  bool get hasPlayerContact => _hasPlayerContact;
}

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../assets/player_placeholder.dart';
import '../assets/sprite_loader.dart';
import 'player.dart';
import 'player_controller.dart';

/// Player animation states
enum AnimationState { idle, run, jump, fall, landing, attack, damaged, death }

/// Manages player animations
/// Handles animation state transitions, sprite management, and visual effects
///
/// Will be properly integrated with the game in Sprint 2
class PlayerAnimator extends Component {
  PlayerAnimator(this.player);
  final Player player;

  AnimationState _currentState = AnimationState.idle;
  final SpriteLoader _spriteLoader = SpriteLoader();

  // Animation maps
  final Map<AnimationState, SpriteAnimation> _animations = {};
  final Map<AnimationState, Sprite> _sprites = {};
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load placeholder animation frames for each state (T2.14.4)
    await _loadPlaceholderAnimations();
  }

  /// Load placeholder animation frames for each animation state
  /// Implements T2.14.4: Integrate placeholder animation frames for each state
  Future<void> _loadPlaceholderAnimations() async {
    try {
      // Use SpriteLoader's test environment detection
      if (_spriteLoader.isInTestEnvironment) {
        // In tests, always use placeholder sprites to avoid asset loading issues
        await _createPlaceholderAnimations();
      } else {
        // In normal runtime, try to load actual animations, fall back to placeholders
        try {
          await _loadActualAnimations();
        } catch (_) {
          // If asset loading fails, fall back to placeholder animations
          await _createPlaceholderAnimations();
        }
      }

      // Set initial animation to player
      if (player.sprite != null && _sprites.containsKey(AnimationState.idle)) {
        player.sprite!.setSprite(_sprites[AnimationState.idle]!);
      }
    } catch (e) {
      // If everything fails, log the error but don't crash
      print('Failed to load player animations: $e');

      // Create minimal fallback sprite
      final fallbackSprite = await PlayerPlaceholder.createPlaceholderSprite(
        player.size.x,
        player.size.y,
      );
      _sprites[AnimationState.idle] = fallbackSprite;

      if (player.sprite != null) {
        player.sprite!.setSprite(fallbackSprite);
      }
    }
  }

  /// Create placeholder animations for all states
  Future<void> _createPlaceholderAnimations() async {
    // Create placeholder sprites for each animation state
    final idleSprite = await PlayerPlaceholder.createPlaceholderSprite(32, 64);
    final runSprite = await _createAnimatedPlaceholder(32, 64, 'run');
    final jumpSprite = await _createAnimatedPlaceholder(32, 64, 'jump');
    final fallSprite = await _createAnimatedPlaceholder(32, 64, 'fall');
    final landingSprite = await _createAnimatedPlaceholder(32, 64, 'landing');
    final attackSprite = await _createAnimatedPlaceholder(32, 64, 'attack');
    final damagedSprite = await _createAnimatedPlaceholder(32, 64, 'damaged');
    final deathSprite = await _createAnimatedPlaceholder(32, 64, 'death');

    // Store sprites for each state
    _sprites[AnimationState.idle] = idleSprite;
    _sprites[AnimationState.run] = runSprite;
    _sprites[AnimationState.jump] = jumpSprite;
    _sprites[AnimationState.fall] = fallSprite;
    _sprites[AnimationState.landing] = landingSprite;
    _sprites[AnimationState.attack] = attackSprite;
    _sprites[AnimationState.damaged] = damagedSprite;
    _sprites[AnimationState.death] = deathSprite;

    // Create simple placeholder animations using sprite repetition
    _animations[AnimationState.idle] =
        SpriteAnimation.spriteList([idleSprite], stepTime: 0.5);
    _animations[AnimationState.run] =
        SpriteAnimation.spriteList([runSprite, idleSprite], stepTime: 0.2);
    _animations[AnimationState.jump] =
        SpriteAnimation.spriteList([jumpSprite], stepTime: 0.3, loop: false);
    _animations[AnimationState.fall] =
        SpriteAnimation.spriteList([fallSprite], stepTime: 0.2);
    _animations[AnimationState.landing] = SpriteAnimation.spriteList(
      [landingSprite],
      stepTime: 0.15,
      loop: false,
    );
    _animations[AnimationState.attack] = SpriteAnimation.spriteList(
      [attackSprite, idleSprite],
      stepTime: 0.1,
      loop: false,
    );
    _animations[AnimationState.damaged] = SpriteAnimation.spriteList(
      [damagedSprite, idleSprite],
      stepTime: 0.1,
      loop: false,
    );
    _animations[AnimationState.death] =
        SpriteAnimation.spriteList([deathSprite], stepTime: 0.2, loop: false);
  }

  /// Load actual animations from assets
  Future<void> _loadActualAnimations() async {
    // Try to load actual sprites from asset files
    _sprites[AnimationState.idle] =
        await _spriteLoader.loadSprite('characters/player/player_idle.png');
    _sprites[AnimationState.run] =
        await _spriteLoader.loadSprite('characters/player/player_run.png');
    _sprites[AnimationState.jump] =
        await _spriteLoader.loadSprite('characters/player/player_jump.png');
    _sprites[AnimationState.fall] =
        await _spriteLoader.loadSprite('characters/player/player_fall.png');
    _sprites[AnimationState.landing] =
        await _spriteLoader.loadSprite('characters/player/player_landing.png');
    _sprites[AnimationState.attack] =
        await _spriteLoader.loadSprite('characters/player/player_attack.png');
    _sprites[AnimationState.damaged] =
        await _spriteLoader.loadSprite('characters/player/player_damaged.png');
    _sprites[AnimationState.death] =
        await _spriteLoader.loadSprite('characters/player/player_death.png');

    // TODO: Load actual sprite animations when asset files are available
  }

  /// Create animated placeholder sprite with visual indicators for different states
  Future<Sprite> _createAnimatedPlaceholder(
    double width,
    double height,
    String stateType,
  ) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Base color depends on animation state
    Color baseColor;
    switch (stateType) {
      case 'run':
        baseColor = const Color(0xFF2ECC71); // Green for running
        break;
      case 'jump':
        baseColor = const Color(0xFFE74C3C); // Red for jumping
        break;
      case 'fall':
        baseColor = const Color(0xFFE67E22); // Orange for falling
        break;
      case 'landing':
        baseColor = const Color(0xFFF39C12); // Yellow for landing
        break;
      case 'attack':
        baseColor = const Color(0xFF9B59B6); // Purple for attack
        break;
      case 'damaged':
        baseColor = const Color(0xFFEC7063); // Light red for damaged
        break;
      case 'death':
        baseColor = const Color(0xFF85929E); // Gray for death
        break;
      default:
        baseColor = const Color(0xFF3498DB); // Blue for default
    }

    final fillPaint = Paint()..color = baseColor;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw the player body
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fillPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);

    // Draw simple visual indicators for the state
    _drawStateIndicator(canvas, width, height, stateType);

    // Finish the image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());

    return Sprite(image);
  }

  /// Draw visual indicators for different animation states
  void _drawStateIndicator(
    Canvas canvas,
    double width,
    double height,
    String stateType,
  ) {
    final indicatorPaint = Paint()..color = Colors.white;

    switch (stateType) {
      case 'run':
        // Draw motion lines
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(
            Offset(width * 0.1, height * (0.3 + i * 0.15)),
            Offset(width * 0.4, height * (0.3 + i * 0.15)),
            indicatorPaint..strokeWidth = 2,
          );
        }
        break;
      case 'jump':
        // Draw upward arrow
        final path = Path();
        path.moveTo(width * 0.5, height * 0.2);
        path.lineTo(width * 0.4, height * 0.4);
        path.lineTo(width * 0.6, height * 0.4);
        path.close();
        canvas.drawPath(path, indicatorPaint);
        break;
      case 'fall':
        // Draw downward arrow
        final path = Path();
        path.moveTo(width * 0.5, height * 0.6);
        path.lineTo(width * 0.4, height * 0.4);
        path.lineTo(width * 0.6, height * 0.4);
        path.close();
        canvas.drawPath(path, indicatorPaint);
        break;
      case 'landing':
        // Draw impact lines
        canvas.drawLine(
          Offset(width * 0.2, height * 0.8),
          Offset(width * 0.4, height * 0.7),
          indicatorPaint..strokeWidth = 3,
        );
        canvas.drawLine(
          Offset(width * 0.8, height * 0.8),
          Offset(width * 0.6, height * 0.7),
          indicatorPaint..strokeWidth = 3,
        );
        break;
      case 'attack':
        // Draw sword or action indicator
        canvas.drawLine(
          Offset(width * 0.7, height * 0.3),
          Offset(width * 0.9, height * 0.1),
          indicatorPaint..strokeWidth = 4,
        );
        break;
      case 'damaged':
        // Draw impact star
        for (int i = 0; i < 4; i++) {
          final angle = (i * 90) * (3.14159 / 180);
          final startX = width * 0.8 + 8 * cos(angle);
          final startY = height * 0.2 + 8 * sin(angle);
          final endX = width * 0.8 + 4 * cos(angle);
          final endY = height * 0.2 + 4 * sin(angle);
          canvas.drawLine(
            Offset(startX, startY),
            Offset(endX, endY),
            indicatorPaint..strokeWidth = 2,
          );
        }
        break;
      case 'death':
        // Draw X eyes
        canvas.drawLine(
          Offset(width * 0.25, height * 0.25),
          Offset(width * 0.35, height * 0.35),
          indicatorPaint..strokeWidth = 3,
        );
        canvas.drawLine(
          Offset(width * 0.35, height * 0.25),
          Offset(width * 0.25, height * 0.35),
          indicatorPaint..strokeWidth = 3,
        );
        canvas.drawLine(
          Offset(width * 0.65, height * 0.25),
          Offset(width * 0.75, height * 0.35),
          indicatorPaint..strokeWidth = 3,
        );
        canvas.drawLine(
          Offset(width * 0.75, height * 0.25),
          Offset(width * 0.65, height * 0.35),
          indicatorPaint..strokeWidth = 3,
        );
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateAnimationState();
    // Update current animation based on state
    _updateCurrentAnimation();
  }

  /// Update animation state based on player state
  /// Enhanced to integrate with PlayerController's jump state machine
  void updateAnimationState() {
    // Enhanced state determination integrating with PlayerController's jump state machine
    if (player.physics != null) {
      final velocity = player.physics!.velocity;
      final jumpState = player.controller.jumpState;

      // Priority: Check jump state machine first for more accurate state detection
      switch (jumpState) {
        case JumpState.grounded:
          // On ground - determine idle vs run based on horizontal velocity
          if (velocity.x.abs() > 10) {
            playAnimation(AnimationState.run);
          } else {
            playAnimation(AnimationState.idle);
          }
          break;
        case JumpState.jumping:
          // Player is ascending
          playAnimation(AnimationState.jump);
          break;
        case JumpState.falling:
          // Player is descending
          playAnimation(AnimationState.fall);
          break;
        case JumpState.landing:
          // Player just landed - brief landing state
          playAnimation(AnimationState.landing);
          break;
      }
    } else {
      // Fallback to basic physics-based detection if controller is not available
      if (player.physics != null) {
        final velocity = player.physics!.velocity;

        if (player.physics!.isOnGround) {
          if (velocity.x.abs() > 10) {
            playAnimation(AnimationState.run);
          } else {
            playAnimation(AnimationState.idle);
          }
        } else {
          if (velocity.y < 0) {
            playAnimation(AnimationState.jump);
          } else {
            playAnimation(AnimationState.fall);
          }
        }
      }
    }
  }

  /// Play specific animation
  void playAnimation(AnimationState state) {
    if (_currentState == state) return;
    _currentState = state;
    _updateCurrentAnimation();
  }

  /// Update the current displayed animation
  void _updateCurrentAnimation() {
    if (player.sprite == null) return;

    // Use animation if available
    if (_animations.containsKey(_currentState)) {
      player.sprite!.setAnimation(_animations[_currentState]!);
      return;
    }

    // Fall back to static sprite if available
    if (_sprites.containsKey(_currentState)) {
      player.sprite!.setSprite(_sprites[_currentState]!);
      return;
    }

    // Ultimate fallback - use idle sprite or first available sprite
    if (_sprites.containsKey(AnimationState.idle)) {
      player.sprite!.setSprite(_sprites[AnimationState.idle]!);
    } else if (_sprites.isNotEmpty) {
      player.sprite!.setSprite(_sprites.values.first);
    }
  }

  /// Get current animation state
  AnimationState getCurrentState() {
    return _currentState;
  }
}

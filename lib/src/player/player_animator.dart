import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../game/adventure_jumper_game.dart';
import '../assets/sprite_loader.dart';
import '../debug/debug_config.dart';
import 'player.dart';
import 'player_controller.dart';

/// Player animation states
enum AnimationState { idle, run, jump, fall, landing, attack, damaged, death }

/// Manages player animations
/// Handles animation state transitions, sprite management, and visual effects
///
/// Will be properly integrated with the game in Sprint 2
class PlayerAnimator extends Component with HasGameReference<AdventureJumperGame> {
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
        DebugConfig.animatorPrint(
          '[PlayerAnimator] Test environment detected, using placeholder sprites',
        );
        await _createPlaceholderAnimations();

        // Verify sprites were loaded for test environment
        if (_sprites.isEmpty || !_sprites.containsKey(AnimationState.fall)) {
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Test placeholder sprites not created properly, retrying...',
          );
          // Try direct creation for any missing sprites, especially fall
          if (!_sprites.containsKey(AnimationState.fall)) {
            _sprites[AnimationState.fall] =
                await _createAnimatedPlaceholder(32, 64, 'fall');
            DebugConfig.animatorPrint(
              '[PlayerAnimator] Created fall placeholder sprite directly',
            );

            // Create animation if needed
            if (!_animations.containsKey(AnimationState.fall)) {
              _animations[AnimationState.fall] = SpriteAnimation.spriteList(
                [_sprites[AnimationState.fall]!],
                stepTime: 0.2,
              );
              DebugConfig.animatorPrint(
                '[PlayerAnimator] Created fall animation from directly created sprite',
              );
            }
          }
        }

        // Double-check all animations have sprites
        for (final state in AnimationState.values) {
          if (!_sprites.containsKey(state)) {
            DebugConfig.animatorPrint(
              '[PlayerAnimator] Missing sprite for ${state.name}, creating placeholder',
            );
            _sprites[state] =
                await _createAnimatedPlaceholder(32, 64, state.name);
            if (!_animations.containsKey(state)) {
              _animations[state] =
                  SpriteAnimation.spriteList([_sprites[state]!], stepTime: 0.2);
            }
          }
        }
      } else {
        // In normal runtime, try to load actual animations, fall back to placeholders
        DebugConfig.animatorPrint(
          '[PlayerAnimator] Attempting to load actual sprite assets...',
        );
        bool actualAnimationsLoaded = false;

        try {
          await _loadActualAnimations();
          actualAnimationsLoaded = true;
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Successfully loaded actual sprite assets',
          );
        } catch (e) {
          // Log the specific asset loading error but continue with fallback
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Asset loading failed: $e',
          );
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Falling back to placeholder animations',
          );
        }

        // If actual animations failed to load, use placeholders
        if (!actualAnimationsLoaded) {
          await _createPlaceholderAnimations();
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Placeholder animations created successfully',
          );
        }
      }

      // Set initial animation to player
      if (player.sprite != null && _sprites.containsKey(AnimationState.idle)) {
        player.sprite!.setSprite(_sprites[AnimationState.idle]!);
        DebugConfig.animatorPrint(
          '[PlayerAnimator] Initial idle animation set on player',
        );
      } else {
        DebugConfig.animatorPrint(
          '[PlayerAnimator] Warning: Could not set initial animation - missing idle sprite or player sprite component',
        );
      }
    } catch (e, stackTrace) {
      // If everything fails, log the error but don't crash
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Critical error in _loadPlaceholderAnimations: $e',
      );
      DebugConfig.animatorPrint('[PlayerAnimator] Stack trace: $stackTrace');

      try {
        // Create minimal fallback sprite as last resort
        final fallbackSprite = await game.loadSprite('static/test_placeholder.png');
        _sprites[AnimationState.idle] = fallbackSprite;

        if (player.sprite != null) {
          player.sprite!.setSprite(fallbackSprite);
          DebugConfig.animatorPrint(
            '[PlayerAnimator] Emergency fallback sprite created and applied',
          );
        }
      } catch (fallbackError) {
        DebugConfig.animatorPrint(
          '[PlayerAnimator] FATAL: Even fallback sprite creation failed: $fallbackError',
        );
        // At this point, we've done everything we can - the component will continue without sprites
      }
    }
  }

  /// Create placeholder animations for all states
  Future<void> _createPlaceholderAnimations() async {
    // Use SpriteLoader to get placeholder sprites for each animation state
    // This ensures consistent fallback behavior
    for (final state in AnimationState.values) {
      try {
        // Request a generic placeholder from SpriteLoader - it will handle the fallback
        _sprites[state] = await _spriteLoader
            .loadSprite('placeholder/generic_player_state.png');

        // Create simple animation from the placeholder sprite
        _animations[state] = SpriteAnimation.spriteList(
          [_sprites[state]!],
          stepTime: 0.5,
          loop: state != AnimationState.jump &&
              state != AnimationState.landing &&
              state != AnimationState.attack &&
              state != AnimationState.damaged &&
              state != AnimationState.death,
        );
      } catch (e) {
        // This should rarely happen since SpriteLoader has its own fallbacks
        print(
          '[PlayerAnimator] Failed to create placeholder for ${state.name}: $e',
        );
      }
    }
  }

  /// Load actual animations from assets
  Future<void> _loadActualAnimations() async {
    // Define the correct relative paths for each player animation state
    final Map<AnimationState, String> spritePaths = {
      AnimationState.idle: 'player/player_idle.png',
      AnimationState.run: 'player/player_run.png',
      AnimationState.jump: 'player/player_jump.png',
      AnimationState.fall: 'player/player_fall.png',
      AnimationState.landing: 'player/player_landing.png',
      AnimationState.attack: 'player/player_attack.png',
      AnimationState.damaged: 'player/player_damaged.png',
      AnimationState.death: 'player/player_death.png',
    };

    int successCount = 0;
    int failureCount = 0;

    // Try to load each sprite individually through SpriteLoader
    for (final entry in spritePaths.entries) {
      final state = entry.key;
      final path = entry.value;

      try {
        _sprites[state] = await _spriteLoader.loadSprite(path);
        successCount++;
        print('[PlayerAnimator] Successfully loaded sprite: $path');

        // Create single-frame animation from the sprite
        // Note: If your sprites are sprite sheets, you'll need to update this
        // to use SpriteSheet.createAnimation with proper frame parameters
        _animations[state] = SpriteAnimation.spriteList(
          [_sprites[state]!],
          stepTime: 0.2,
          loop: state != AnimationState.jump &&
              state != AnimationState.landing &&
              state != AnimationState.attack &&
              state != AnimationState.damaged &&
              state != AnimationState.death,
        );
      } catch (e) {
        failureCount++;
        print('[PlayerAnimator] Failed to load sprite: $path - $e');

        // SpriteLoader already handles fallbacks, so if we get here it means
        // we got a placeholder sprite successfully
        try {
          _sprites[state] = await _spriteLoader.loadSprite(path);
          _animations[state] = SpriteAnimation.spriteList(
            [_sprites[state]!],
            stepTime: 0.2,
          );
          print('[PlayerAnimator] Using fallback for: ${state.name}');
        } catch (placeholderError) {
          print(
            '[PlayerAnimator] Failed to get fallback for ${state.name}: $placeholderError',
          );
        }
      }
    }

    print(
      '[PlayerAnimator] Asset loading summary: $successCount succeeded, $failureCount failed',
    );

    // Note: We don't throw an error here since SpriteLoader handles fallbacks
    // The game should continue running even if some assets fail to load
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
    DebugConfig.animatorPrint(
      '[PlayerAnimator] _updateCurrentAnimation called for state: $_currentState',
    );

    if (player.sprite == null) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] ERROR: player.sprite is null!',
      );
      return;
    }

    // Use animation if available
    if (_animations.containsKey(_currentState)) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Setting animation for state: $_currentState',
      );
      player.sprite!.setAnimation(_animations[_currentState]!);
      if (DebugConfig.enableComponentHierarchyLogging) {
        player.sprite!.printDebugStatus();
      }
      return;
    }

    // Fall back to static sprite if available
    if (_sprites.containsKey(_currentState)) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Setting sprite for state: $_currentState',
      );
      player.sprite!.setSprite(_sprites[_currentState]!);
      if (DebugConfig.enableComponentHierarchyLogging) {
        player.sprite!.printDebugStatus();
      }
      return;
    }

    // Ultimate fallback - use idle sprite or first available sprite
    if (_sprites.containsKey(AnimationState.idle)) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Fallback to idle sprite for $_currentState state',
      );
      player.sprite!.setSprite(_sprites[AnimationState.idle]!);
      if (DebugConfig.enableComponentHierarchyLogging) {
        player.sprite!.printDebugStatus();
      }
    } else if (_sprites.isNotEmpty) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Fallback to first available sprite for $_currentState state',
      );
      player.sprite!.setSprite(_sprites.values.first);
      if (DebugConfig.enableComponentHierarchyLogging) {
        player.sprite!.printDebugStatus();
      }
    } else {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] ERROR: No sprites available for state: $_currentState',
      );
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Sprite map contains states: ${_sprites.keys.map((s) => s.name).join(', ')}',
      );
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Animation map contains states: ${_animations.keys.map((s) => s.name).join(', ')}',
      );
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Expected file: characters/player/player_${_currentState.name}.png',
      );

      // Emergency fallback - create the missing sprite on the fly
      _createEmergencyPlaceholder();
    }
  }

  /// Create an emergency placeholder sprite for the current state if it's missing
  Future<void> _createEmergencyPlaceholder() async {
    try {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Creating emergency placeholder for state: $_currentState',
      );

      // Create placeholder sprite for the current state
      final sprite =
          await _createAnimatedPlaceholder(32, 64, _currentState.name);
      _sprites[_currentState] = sprite;

      // Create a simple animation for the sprite
      _animations[_currentState] =
          SpriteAnimation.spriteList([sprite], stepTime: 0.2);

      // Apply the sprite
      if (player.sprite != null) {
        player.sprite!.setSprite(sprite);
        DebugConfig.animatorPrint(
          '[PlayerAnimator] Emergency placeholder created and applied for: ${_currentState.name}',
        );
      }
    } catch (e) {
      DebugConfig.animatorPrint(
        '[PlayerAnimator] Failed to create emergency placeholder: $e',
      );
    }
  }

  /// Get current animation state
  AnimationState getCurrentState() {
    return _currentState;
  }
}

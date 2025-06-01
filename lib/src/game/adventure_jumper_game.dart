// filepath: c:\Users\User\source\repos\Cascade\adventure-jumper\lib\src\game\adventure_jumper_game.dart
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color, KeyEventResult;
import 'package:flutter/services.dart' show KeyEvent, LogicalKeyboardKey;
import 'package:logging/logging.dart';

import '../debug/debug_config.dart';
import '../debug/visual_debug_overlay.dart';
import '../systems/input_system.dart';
import '../systems/movement_system.dart';
import '../systems/physics_system.dart';
import '../ui/game_hud.dart';
import 'game_camera.dart';
import 'game_config.dart';
import 'game_world.dart';

/// Main game class for Adventure Jumper
/// Handles overall game state, system coordination, and scene management
class AdventureJumperGame extends FlameGame
    with TapDetector, HasKeyboardHandlerComponents {
  late GameWorld gameWorld;
  late GameCamera gameCamera;
  late InputSystem inputSystem;
  late MovementSystem movementSystem;
  late PhysicsSystem physicsSystem;
  late GameHUD gameHUD; // Add GameHUD reference
  late VisualDebugOverlay debugOverlay; // Add debug overlay

  // Random number generator for the game
  final math.Random random = math.Random();

  // Logger for this class
  final Logger _logger = Logger('AdventureJumperGame');

  @override
  Color backgroundColor() => GameConfig.backgroundColor;

  @override
  Future<void> onLoad() async {
    _logger.info('Initializing game'); // Initialize input system first
    inputSystem = InputSystem();
    add(inputSystem);
    _logger.fine('Input system initialized'); // Initialize movement system
    movementSystem = MovementSystem();
    add(movementSystem);
    _logger.fine('Movement system initialized');

    // Initialize physics system
    physicsSystem = PhysicsSystem();
    add(physicsSystem);
    _logger.fine('Physics system initialized');

    // Set up keyboard event forwarding to input system
    // The input system will handle keyboard events and distribute to entities    _setupInputHandlers(); // Initialize camera
    gameCamera = GameCamera();
    camera.viewfinder.add(gameCamera);
    _logger.fine('Game camera initialized'); // Initialize game world
    print('🎮 [DEBUG] AdventureJumperGame.onLoad() - Creating GameWorld');
    gameWorld = GameWorld();
    print(
      '🎮 [DEBUG] AdventureJumperGame.onLoad() - Adding GameWorld to game (not camera)',
    );
    add(gameWorld);
    _logger.fine('Game world initialized');

    // Wait for world to load
    print(
      '🎮 [DEBUG] AdventureJumperGame.onLoad() - Waiting for GameWorld to load',
    );
    await gameWorld.loaded;
    print(
      '🎮 [DEBUG] AdventureJumperGame.onLoad() - GameWorld loaded successfully',
    );

    /*// Add a test debug rectangle directly to the game to verify basic rendering
    final DebugRectangleComponent gameTestRect = DebugRectangleComponent(
      size: Vector2(80, 80),
      position: Vector2(200, 200), // Top-left area, should be clearly visible
      color: const Color(0xFFFF0000), // Bright red
      debugName: 'GameTestRect',
      priority: 100, // High priority to render on top
    );
    add(gameTestRect);
    _logger.info(
      'Added test debug rectangle to game - position: ${gameTestRect.position}, size: ${gameTestRect.size}',
    );*/

    // Initialize the game HUD
    final screenSize = Vector2(size.x, size.y);
    gameHUD = GameHUD(
      screenSize: screenSize,
      player: gameWorld.player,
      showFps: true,
    );
    add(gameHUD);
    _logger.fine(
      'Game HUD initialized',
    ); // Initialize visual debug overlay (conditional)
    if (DebugConfig.enableVisualDebugOverlay) {
      debugOverlay = VisualDebugOverlay();
      add(debugOverlay);
      _logger.fine('Visual debug overlay initialized');
    }

    // Register player with input system once world is loaded
    if (gameWorld.player != null) {
      inputSystem.setFocusedEntity(gameWorld.player!);
      _logger.fine(
        'Player registered with input system',
      ); // Register player with movement system
      movementSystem.addEntity(gameWorld.player!);
      _logger.fine('Player registered with movement system');

      // Register player with physics system
      physicsSystem.addEntity(gameWorld.player!);
      _logger.fine(
        'Player registered with physics system',
      ); // Set camera to follow player
      gameCamera.follow(gameWorld.player!);
      gameCamera.setFollowSpeed(8.0); // Responsive camera following
      // Set camera bounds to include the game world coordinates (Y=650-1000 for platforms and player)
      gameCamera.setBounds(math.Rectangle<int>(-200, 600, 1600, 500));

      // Set initial camera position to player location for immediate visibility
      camera.viewfinder.position = gameWorld.player!.position.clone();

      _logger.fine(
        'Camera configured to follow player with bounds: left=-200, top=600, width=1600, height=500 (bottom=1100)',
      );
    } // Register all platforms with physics system
    _logger.info(
      'PHASE 1 DEBUG: Starting platform registration with PhysicsSystem',
    );
    _logger.info(
      '  PhysicsSystem entity count before registration: ${physicsSystem.entityCount}',
    );
    _logger.info('  GameWorld platforms count: ${gameWorld.platforms.length}');

    await gameWorld.registerPlatformsWithPhysics(physicsSystem);

    _logger.info('PHASE 1 DEBUG: Platform registration completed');
    _logger.info(
      '  PhysicsSystem entity count after registration: ${physicsSystem.entityCount}',
    );
    _logger.fine('Platforms registered with physics system');

    // TODO(game): Load initial assets
    // TODO(game): Initialize input handlers
    // TODO(game): Set up game state management    _logger.info('Game initialization complete');
  }

  @override
  void render(ui.Canvas canvas) {
    print('🎮 RENDER DEBUG: AdventureJumperGame.render() called');
    super.render(canvas);
    print(
      '🎮 RENDER DEBUG: AdventureJumperGame.render() super.render(canvas) completed',
    );
  }

  // Input handling methods
  @override
  void onTapDown(TapDownInfo info) {
    // Handle tap down events
    super.onTapDown(info);
    // Forward to input system if needed
    // inputSystem.handlePointerEvent(info.eventPosition);
  }

  @override
  void onTapUp(TapUpInfo info) {
    // Handle tap up events
    super.onTapUp(info);
  }

  /// Set up input handlers for keyboard and other input devices
  void _setupInputHandlers() {
    // Input handling is managed entirely by the InputSystem
    // The InputSystem will register with entities that have InputComponents
    // Keyboard events are forwarded via the onKeyEvent method below
    _logger.fine('Input handlers configured');
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Call parent method first
    super.onKeyEvent(event, keysPressed);

    // Forward keyboard events to the input system
    inputSystem.handleKeyEvent(event);

    // Indicate that we've handled the event
    return KeyEventResult.handled;
  }

  /// Get the input system for external access
  InputSystem get input => inputSystem;

  /// Get the movement system for external access
  MovementSystem get movement => movementSystem;
}

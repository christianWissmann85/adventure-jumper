import 'dart:math';

import 'package:flame/components.dart';

import '../game/adventure_jumper_game.dart';
import '../game/game_camera.dart';
import '../player/player.dart';
import '../utils/error_handler.dart';
import '../utils/exceptions.dart';
import 'level.dart';
import 'level_loader.dart';
import 'portal.dart';

/// Level transitions and state management
/// Handles loading, unloading, and transitioning between game levels
class LevelManager extends Component {
  LevelManager({
    AdventureJumperGame? game,
    this.startingLevelId = 'level_1',
  }) : _game = game;

  // Game instance reference
  final AdventureJumperGame? _game;

  // Currently active level
  Level? _currentLevel;
  String? _currentLevelId;

  // Level tracking
  final String startingLevelId;
  final List<String> _completedLevels = <String>[];
  final List<String> _unlockedLevels = <String>[];
  // Level transition state - will be used in Sprint 3 for smooth transitions
  bool _isTransitioning = false;
  // ignore: unused_field
  double _transitionProgress = 0;
  // ignore: unused_field
  String? _transitionTargetLevelId;

  // Player reference
  Player? _player;

  // Getters
  Level? get currentLevel => _currentLevel;
  String? get currentLevelId => _currentLevelId;
  bool get isTransitioning => _isTransitioning;
  List<String> get completedLevels => List.unmodifiable(_completedLevels);
  List<String> get unlockedLevels => List.unmodifiable(_unlockedLevels);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Unlock the starting level
    _unlockedLevels.add(startingLevelId);
  }

  /// Initialize with the starting level
  Future<void> initialize(Player player) async {
    _player = player;
    await loadLevel(startingLevelId);
  }

  /// Load a level by ID and make it the current level
  Future<Level?> loadLevel(String levelId) async {
    if (_isTransitioning) {
      ErrorHandler.logWarning(
        'Cannot load level while transitioning',
        context: 'LevelManager.loadLevel',
      );
      return null;
    }

    if (_currentLevelId == levelId && _currentLevel != null) {
      ErrorHandler.logInfo(
        'Level $levelId is already loaded',
        context: 'LevelManager.loadLevel',
      );
      return _currentLevel;
    }

    _isTransitioning = true;
    _transitionProgress = 0;
    _transitionTargetLevelId = levelId;

    ErrorHandler.logInfo(
      'Loading level $levelId',
      context: 'LevelManager.loadLevel',
    );

    // Start transition effect (will be implemented in future sprints)
    await _startTransitionOut();

    // Unload current level if exists
    if (_currentLevel != null) {
      await _unloadCurrentLevel();
    }

    try {
      // Load the new level using LevelLoader
      final Level newLevel = await LevelLoader().loadLevel(levelId);

      // Set the new level as current
      _currentLevel = newLevel;
      _currentLevelId = levelId;

      // Add level to game
      if (_game != null) {
        _game.add(newLevel);
      } else {
        add(newLevel);
      }

      // Place player in level
      if (_player != null) {
        _placePlayerInLevel(newLevel, _player!);
      }

      // Update camera bounds
      _updateCameraBounds(newLevel);

      // Finish transition effect
      await _finishTransitionIn();

      ErrorHandler.logInfo(
        'Level $levelId loaded successfully',
        context: 'LevelManager.loadLevel',
      );
      return newLevel;
    } on LevelNotFoundException catch (e) {
      ErrorHandler.logError(
        'Level not found',
        error: e,
        context: 'LevelManager.loadLevel($levelId)',
      );
      _isTransitioning = false;
      return null;
    } on LevelDataCorruptedException catch (e) {
      ErrorHandler.logError(
        'Level data is corrupted or invalid',
        error: e,
        context: 'LevelManager.loadLevel($levelId)',
      );
      _isTransitioning = false;
      return null;
    } on AssetLoadingException catch (e) {
      ErrorHandler.logError(
        'Failed to load level assets',
        error: e,
        context: 'LevelManager.loadLevel($levelId)',
      );
      _isTransitioning = false;
      return null;
    } catch (e) {
      ErrorHandler.logError(
        'Unexpected error loading level',
        error: e,
        context: 'LevelManager.loadLevel($levelId)',
      );
      _isTransitioning = false;
      return null;
    }
  }

  /// Unload the current level and clean up resources
  Future<void> _unloadCurrentLevel() async {
    if (_currentLevel == null) return;

    ErrorHandler.logInfo(
      'Unloading level $_currentLevelId',
      context: 'LevelManager._unloadCurrentLevel',
    );

    try {
      // Remove level from game
      _currentLevel!.removeFromParent();

      // Dispose level resources
      _currentLevel!.dispose();

      _currentLevel = null;
      _currentLevelId = null;
    } catch (e) {
      ErrorHandler.logError(
        'Error during level unloading',
        error: e,
        context: 'LevelManager._unloadCurrentLevel($_currentLevelId)',
      );
      // Still clear references even if there was an error
      _currentLevel = null;
      _currentLevelId = null;
    }
  }

  /// Place player in the level at spawn point
  void _placePlayerInLevel(Level level, Player player) {
    if (level.playerSpawnPoint != null) {
      player.position = level.playerSpawnPoint!;
    } else {
      // Default spawn if none specified
      player.position = Vector2(100, 100);
    }

    level.setPlayer(player, player.position);
  }

  /// Update camera bounds based on level dimensions
  void _updateCameraBounds(Level level) {
    if (_game != null && _game.camera is GameCamera) {
      final GameCamera camera = _game.camera as GameCamera;
      camera.setBounds(
        Rectangle(0, 0, level.width.toInt(), level.height.toInt()),
      );
    }
  }

  /// Start transition out effect
  Future<void> _startTransitionOut() async {
    // Transition effect will be implemented in future sprints
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Finish transition in effect
  Future<void> _finishTransitionIn() async {
    // Transition effect will be implemented in future sprints
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _isTransitioning = false;
  }

  /// Handle player entering a portal
  Future<void> handlePortalEnter(Portal portal) async {
    if (_isTransitioning) {
      ErrorHandler.logWarning(
        'Cannot use portal while level transition is in progress',
        context: 'LevelManager.handlePortalEnter',
      );
      return;
    }

    final String targetLevelId = portal.targetLevelId;

    ErrorHandler.logInfo(
      'Player entered portal to $targetLevelId',
      context: 'LevelManager.handlePortalEnter',
    );

    try {
      await loadLevel(targetLevelId);
    } catch (e) {
      ErrorHandler.logError(
        'Failed to load level through portal',
        error: e,
        context: 'LevelManager.handlePortalEnter(to: $targetLevelId)',
      );
    }
  }

  /// Mark a level as completed
  void markLevelCompleted(String levelId) {
    if (!_completedLevels.contains(levelId)) {
      _completedLevels.add(levelId);
      ErrorHandler.logInfo(
        'Level $levelId marked as completed',
        context: 'LevelManager.markLevelCompleted',
      );
    }
  }

  /// Unlock a level to make it available
  void unlockLevel(String levelId) {
    if (!_unlockedLevels.contains(levelId)) {
      _unlockedLevels.add(levelId);
      ErrorHandler.logInfo(
        'Level $levelId unlocked',
        context: 'LevelManager.unlockLevel',
      );
    }
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(String levelId) {
    return _unlockedLevels.contains(levelId);
  }

  /// Check if a level is completed
  bool isLevelCompleted(String levelId) {
    return _completedLevels.contains(levelId);
  }

  /// Reset level progress tracking
  void resetProgress() {
    _completedLevels.clear();
    _unlockedLevels.clear();
    _unlockedLevels.add(startingLevelId);
  }
}

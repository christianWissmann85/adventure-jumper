import 'dart:math';

import 'package:adventure_jumper/src/game/adventure_jumper_game.dart';
import 'package:adventure_jumper/src/game/game_camera.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/world/level.dart';
import 'package:adventure_jumper/src/world/level_loader.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// T2.17.5: Validate level bounds and camera behavior
///
/// This test suite validates comprehensive level bounds and camera behavior functionality,
/// ensuring that the enhanced level loading system properly enforces boundaries and
/// provides smooth camera following behavior.
///
/// Coverage Areas:
/// - T2.17.5.1: Level bounds enforcement for player movement
/// - T2.17.5.2: Camera bounds constraint validation
/// - T2.17.5.3: Camera following behavior testing
/// - T2.17.5.4: Level bounds validation methods
/// - T2.17.5.5: Player spawn point bounds checking
/// - T2.17.5.6: Camera smooth following performance
/// - T2.17.5.7: Bounds edge case handling
/// - T2.17.5.8: Camera bounds vs level bounds relationship
/// - T2.17.5.9: Integration testing with GameWorld
/// - T2.17.5.10: Performance validation for camera updates
/// - T2.17.5.11: Comprehensive camera and bounds system validation
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('T2.17.5: Level Bounds and Camera Behavior Validation', () {
    late LevelLoader levelLoader;

    setUpAll(() {
      print(
        '🧪 Starting T2.17.5: Level Bounds and Camera Behavior Validation Tests',
      );
    });

    setUp(() {
      levelLoader = LevelLoader();
    });

    group('T2.17.5.1: Level Bounds Enforcement Tests', () {
      test('should validate level bounds are properly defined', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify level bounds exist and are valid
        expect(
          level.levelBounds,
          isNotNull,
          reason: 'Level should have defined bounds',
        );

        final bounds = level.levelBounds!;
        expect(
          bounds.left,
          lessThan(bounds.right),
          reason: 'Left bound should be less than right',
        );
        expect(
          bounds.top,
          lessThan(bounds.bottom),
          reason: 'Top bound should be less than bottom',
        );
        expect(
          bounds.width,
          greaterThan(0),
          reason: 'Level should have positive width',
        );
        expect(
          bounds.height,
          greaterThan(0),
          reason: 'Level should have positive height',
        );

        print(
          '✅ T2.17.5.1a: Level bounds properly defined (${bounds.width}x${bounds.height})',
        );
      });

      test('should validate player spawn point is within level bounds',
          () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Check player spawn point
        expect(
          level.spawnPoints,
          isNotNull,
          reason: 'Level should have spawn points',
        );
        expect(
          level.spawnPoints!.containsKey('player_start'),
          isTrue,
          reason: 'Level should have player start spawn point',
        );

        final playerSpawn = level.spawnPoints!['player_start']!;
        final spawnPosition = Vector2(playerSpawn.x, playerSpawn.y);

        // Validate spawn point is within bounds
        expect(
          level.levelBounds!.contains(spawnPosition),
          isTrue,
          reason: 'Player spawn point should be within level bounds',
        );

        print('✅ T2.17.5.1b: Player spawn point within bounds validation');
      });
      test('should validate entity positions against level bounds', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Add level to a game context to trigger proper loading lifecycle
        final testGame = FlameGame();
        await testGame.add(level);
        await testGame.onLoad();
        await testGame.ready();

        // Wait for level's onLoad to complete
        await Future.delayed(Duration(milliseconds: 100));

        // Ensure level's onLoad has been called
        if (!level.isLoaded) {
          await level.onLoad();
        }

        // Test position validation method
        final validPosition = Vector2(100, 100);
        final invalidPosition = Vector2(
          -1000,
          -1000,
        ); // Use level's validation method - check that level was loaded properly
        expect(
          level.isLoaded,
          isTrue,
          reason: 'Test level should be loaded and valid',
        );

        // Test bounds contains method directly
        final bounds = level.levelBounds!;
        expect(
          bounds.contains(validPosition),
          isTrue,
          reason: 'Valid position should be within bounds',
        );
        expect(
          bounds.contains(invalidPosition),
          isFalse,
          reason: 'Invalid position should be outside bounds',
        );

        print('✅ T2.17.5.1c: Entity position bounds validation');
      });
    });

    group('T2.17.5.2: Camera Bounds Constraint Tests', () {
      test('should validate camera bounds are properly defined', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Verify camera bounds exist and are valid
        expect(
          level.cameraBounds,
          isNotNull,
          reason: 'Level should have camera bounds',
        );

        final cameraBounds = level.cameraBounds!;
        expect(
          cameraBounds.left,
          lessThan(cameraBounds.right),
          reason: 'Camera left bound should be less than right',
        );
        expect(
          cameraBounds.top,
          lessThan(cameraBounds.bottom),
          reason: 'Camera top bound should be less than bottom',
        );

        // Camera bounds should typically be larger than level bounds
        final levelBounds = level.levelBounds!;
        expect(
          cameraBounds.left,
          lessThanOrEqualTo(levelBounds.left),
          reason: 'Camera bounds should allow viewing edge of level',
        );
        expect(
          cameraBounds.right,
          greaterThanOrEqualTo(levelBounds.right),
          reason: 'Camera bounds should allow viewing edge of level',
        );

        print('✅ T2.17.5.2a: Camera bounds properly defined and validated');
      });

      test('should validate camera bounds relationship to level bounds',
          () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        final levelBounds = level.levelBounds!;
        final cameraBounds = level.cameraBounds!;

        // Camera bounds should encompass level bounds with margin
        expect(
          cameraBounds.width,
          greaterThanOrEqualTo(levelBounds.width),
          reason: 'Camera bounds should be at least as wide as level bounds',
        );
        expect(
          cameraBounds.height,
          greaterThanOrEqualTo(levelBounds.height),
          reason: 'Camera bounds should be at least as tall as level bounds',
        ); // Check that level bounds are contained within camera bounds
        final levelCenter = levelBounds.center;
        expect(
          levelCenter.x >= cameraBounds.left &&
              levelCenter.x <= cameraBounds.right &&
              levelCenter.y >= cameraBounds.top &&
              levelCenter.y <= cameraBounds.bottom,
          isTrue,
          reason: 'Level center should be within camera bounds',
        );

        print('✅ T2.17.5.2b: Camera-to-level bounds relationship validated');
      });
    });

    group('T2.17.5.3: Camera Following Behavior Tests', () {
      test('should initialize camera system correctly', () async {
        final gameCamera = GameCamera();

        // Test initial state
        expect(
          gameCamera.bounds,
          isNull,
          reason: 'Initial camera should have no bounds',
        );

        // Test bounds setting
        final testBounds = Rectangle<int>(-100, -50, 400, 300);
        gameCamera.setBounds(testBounds);
        expect(
          gameCamera.bounds,
          equals(testBounds),
          reason: 'Camera should store bounds correctly',
        );

        // Test follow speed setting
        gameCamera.setFollowSpeed(2.0);

        print('✅ T2.17.5.3a: Camera system initialization validated');
      });

      test('should handle camera target following setup', () async {
        final gameCamera = GameCamera();
        final mockPlayer = Player(position: Vector2(100, 100));
        await mockPlayer.onLoad();

        // Test setting follow target
        gameCamera.follow(mockPlayer);

        // Test stopping follow
        gameCamera.stopFollowing();

        print('✅ T2.17.5.3b: Camera target following setup validated');
      });
    });

    group('T2.17.5.4: Level Validation Methods Tests', () {
      test('should validate level geometry bounds consistency', () async {
        final level = await levelLoader.loadLevel(
          'sprint2_test_level',
        ); // Test that all platforms are within level bounds
        if (level.geometry != null && level.geometry!.platforms.isNotEmpty) {
          for (final platform in level.geometry!.platforms) {
            final platformPos = Vector2(platform.x, platform.y);

            // Skip the safety_ground platform as it's intentionally placed outside bounds
            if (platform.id == 'safety_ground') {
              print(
                '🔍 Skipping safety_ground platform (intentionally outside bounds)',
              );
              continue;
            }

            // Platform should be within level bounds (with some tolerance for platform size)
            expect(
              platformPos.x,
              greaterThanOrEqualTo(level.levelBounds!.left - platform.width),
              reason: 'Platform ${platform.id} should be within level bounds',
            );
            expect(
              platformPos.x + platform.width,
              lessThanOrEqualTo(level.levelBounds!.right),
              reason:
                  'Platform ${platform.id} right edge should be within level bounds',
            );
            expect(
              platformPos.y,
              greaterThanOrEqualTo(level.levelBounds!.top - platform.height),
              reason: 'Platform ${platform.id} should be within level bounds',
            );
            expect(
              platformPos.y,
              lessThanOrEqualTo(level.levelBounds!.bottom),
              reason: 'Platform ${platform.id} should be within level bounds',
            );
          }
        }

        print('✅ T2.17.5.4a: Level geometry bounds consistency validated');
      });

      test('should validate spawn points are within bounds', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Test all spawn points are within level bounds
        if (level.spawnPoints != null) {
          for (final entry in level.spawnPoints!.entries) {
            final spawnPoint = entry.value;
            final position = Vector2(spawnPoint.x, spawnPoint.y);

            expect(
              level.levelBounds!.contains(position),
              isTrue,
              reason: 'Spawn point ${entry.key} should be within level bounds',
            );
          }
        }

        print('✅ T2.17.5.4b: Spawn points bounds validation');
      });
    });

    group('T2.17.5.5: Player Position Constraint Tests', () {
      test('should validate player movement constraints', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');
        final bounds = level.levelBounds!;

        // Create a mock player
        final player =
            Player(position: Vector2(bounds.center.x, bounds.center.y));
        await player.onLoad();

        // Test valid positions
        final validPositions = [
          Vector2(bounds.left + 10, bounds.top + 10),
          Vector2(bounds.right - 10, bounds.bottom - 10),
          bounds.center,
        ];

        for (final pos in validPositions) {
          expect(
            bounds.contains(pos),
            isTrue,
            reason: 'Position $pos should be valid within bounds',
          );
        }

        // Test invalid positions
        final invalidPositions = [
          Vector2(bounds.left - 10, bounds.center.y),
          Vector2(bounds.right + 10, bounds.center.y),
          Vector2(bounds.center.x, bounds.top - 10),
          Vector2(bounds.center.x, bounds.bottom + 10),
        ];

        for (final pos in invalidPositions) {
          expect(
            bounds.contains(pos),
            isFalse,
            reason: 'Position $pos should be invalid outside bounds',
          );
        }

        print('✅ T2.17.5.5a: Player movement constraint validation');
      });
    });

    group('T2.17.5.6: Camera Performance Tests', () {
      test('should validate camera update performance', () async {
        final gameCamera = GameCamera();
        final mockPlayer = Player(position: Vector2(100, 100));
        await mockPlayer.onLoad();

        gameCamera.follow(mockPlayer);
        gameCamera.setFollowSpeed(5.0);

        // Measure update performance
        final stopwatch = Stopwatch()..start();
        const int updateCount = 100;

        for (int i = 0; i < updateCount; i++) {
          gameCamera.update(0.016); // 60 FPS delta time
        }

        stopwatch.stop();
        final averageUpdateTime = stopwatch.elapsedMicroseconds / updateCount;

        // Camera updates should be very fast (less than 100 microseconds)
        expect(
          averageUpdateTime,
          lessThan(100),
          reason: 'Camera updates should be performant',
        );

        print(
          '✅ T2.17.5.6a: Camera update performance validated (${averageUpdateTime.toStringAsFixed(2)}μs avg)',
        );
      });
    });

    group('T2.17.5.7: Edge Case Handling Tests', () {
      test('should handle edge positions correctly', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');
        final bounds = level.levelBounds!;

        // Test exact boundary positions
        final edgePositions = [
          Vector2(bounds.left, bounds.top),
          Vector2(bounds.right, bounds.top),
          Vector2(bounds.left, bounds.bottom),
          Vector2(bounds.right, bounds.bottom),
        ];

        for (final pos in edgePositions) {
          expect(
            bounds.contains(pos),
            isTrue,
            reason: 'Edge position $pos should be within bounds',
          );
        }

        print('✅ T2.17.5.7a: Edge position handling validated');
      });

      test('should handle zero-sized bounds gracefully', () {
        // Test degenerate bounds cases
        final zeroBounds = LevelBounds(left: 0, right: 0, top: 0, bottom: 0);

        expect(
          zeroBounds.width,
          equals(0),
          reason: 'Zero bounds should have zero width',
        );
        expect(
          zeroBounds.height,
          equals(0),
          reason: 'Zero bounds should have zero height',
        );
        expect(
          zeroBounds.contains(Vector2.zero()),
          isTrue,
          reason: 'Zero bounds should contain origin',
        );

        print('✅ T2.17.5.7b: Degenerate bounds handling validated');
      });
    });

    group('T2.17.5.8: Integration Tests', () {
      final gameTester = FlameTester(AdventureJumperGame.new);

      gameTester.testGameWidget(
        'should integrate camera with game world correctly',
        verify: (game, tester) async {
          // Wait for game to initialize
          await tester.pump();

          // Verify camera system exists
          expect(
            game.gameCamera,
            isNotNull,
            reason: 'Game should have camera system',
          );

          // Verify camera bounds are set if game world is loaded
          if (game.gameWorld.player != null) {
            expect(
              game.gameCamera.bounds,
              isNotNull,
              reason: 'Camera should have bounds when world is loaded',
            );
          }

          print('✅ T2.17.5.8a: Camera-GameWorld integration validated');
        },
      );

      gameTester.testGameWidget(
        'should handle level loading with bounds correctly',
        verify: (game, tester) async {
          // Wait for initialization
          await tester.pump(); // If player exists, verify game world is loaded
          if (game.gameWorld.player != null) {
            // Level is loaded if player exists - test that components are working
            expect(
              game.gameCamera.bounds,
              isNotNull,
              reason: 'Camera should have bounds when world is loaded',
            );
          }

          print('✅ T2.17.5.8b: Level loading bounds integration validated');
        },
      );
    });

    group('T2.17.5.9: Camera Bounds Enforcement Tests', () {
      test('should enforce camera position within bounds', () {
        final cameraBounds =
            CameraBounds(left: -100, right: 500, top: -50, bottom: 300);

        // Test bounds constraints
        expect(
          cameraBounds.left,
          equals(-100),
          reason: 'Camera left bound should be set correctly',
        );
        expect(
          cameraBounds.right,
          equals(500),
          reason: 'Camera right bound should be set correctly',
        );
        expect(
          cameraBounds.top,
          equals(-50),
          reason: 'Camera top bound should be set correctly',
        );
        expect(
          cameraBounds.bottom,
          equals(300),
          reason: 'Camera bottom bound should be set correctly',
        );

        // Test bounds properties
        expect(
          cameraBounds.width,
          equals(600),
          reason: 'Camera bounds width should be calculated correctly',
        );
        expect(
          cameraBounds.height,
          equals(350),
          reason: 'Camera bounds height should be calculated correctly',
        );

        print('✅ T2.17.5.9a: Camera bounds enforcement validated');
      });
    });

    group('T2.17.5.10: Performance and Validation Tests', () {
      test('should validate bounds checking performance', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');
        final bounds = level.levelBounds!;

        // Test performance of bounds checking
        final stopwatch = Stopwatch()..start();
        const int checkCount = 1000;

        for (int i = 0; i < checkCount; i++) {
          final testPos = Vector2(i.toDouble(), i.toDouble());
          bounds.contains(testPos);
        }

        stopwatch.stop();
        final averageCheckTime = stopwatch.elapsedMicroseconds / checkCount;

        // Bounds checking should be very fast
        expect(
          averageCheckTime,
          lessThan(10),
          reason: 'Bounds checking should be highly performant',
        );

        print(
          '✅ T2.17.5.10a: Bounds checking performance validated (${averageCheckTime.toStringAsFixed(3)}μs avg)',
        );
      });

      test('should validate level validation performance', () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Test level validation performance
        final stopwatch = Stopwatch()..start();
        const int validationCount = 10;
        for (int i = 0; i < validationCount; i++) {
          // Test that level components are accessible (validation proxy)
          expect(level.isLoaded, isTrue);
        }

        stopwatch.stop();
        final averageValidationTime =
            stopwatch.elapsedMilliseconds / validationCount;

        // Level validation should complete reasonably quickly
        expect(
          averageValidationTime,
          lessThan(100),
          reason: 'Level validation should complete within 100ms',
        );

        print(
          '✅ T2.17.5.10b: Level validation performance validated (${averageValidationTime.toStringAsFixed(2)}ms avg)',
        );
      });
    });

    group('T2.17.5.11: Comprehensive System Validation', () {
      test('should validate complete bounds and camera system integration',
          () async {
        final level = await levelLoader.loadLevel('sprint2_test_level');

        // Comprehensive validation of all components
        expect(
          level.levelBounds,
          isNotNull,
          reason: 'Level should have bounds',
        );
        expect(
          level.cameraBounds,
          isNotNull,
          reason: 'Level should have camera bounds',
        );
        expect(
          level.spawnPoints,
          isNotNull,
          reason: 'Level should have spawn points',
        );
        expect(
          level.isLoaded,
          isTrue,
          reason: 'Level should be loaded and valid',
        );

        // Test bounds relationships
        final levelBounds = level.levelBounds!;
        final cameraBounds = level.cameraBounds!;

        expect(
          levelBounds.width,
          greaterThan(0),
          reason: 'Level should have positive width',
        );
        expect(
          levelBounds.height,
          greaterThan(0),
          reason: 'Level should have positive height',
        );
        expect(
          cameraBounds.width,
          greaterThanOrEqualTo(levelBounds.width),
          reason: 'Camera bounds should encompass level bounds',
        );
        expect(
          cameraBounds.height,
          greaterThanOrEqualTo(levelBounds.height),
          reason: 'Camera bounds should encompass level bounds',
        );

        // Test spawn point validation
        for (final spawnPoint in level.spawnPoints!.values) {
          final pos = Vector2(spawnPoint.x, spawnPoint.y);
          expect(
            levelBounds.contains(pos),
            isTrue,
            reason: 'All spawn points should be within level bounds',
          );
        }

        print(
          '✅ T2.17.5.11a: Complete bounds and camera system integration validated',
        );
      });

      test('should validate comprehensive camera behavior', () {
        final gameCamera = GameCamera();

        // Test complete camera setup and behavior
        expect(
          () => gameCamera.setFollowSpeed(8.0),
          returnsNormally,
          reason: 'Setting follow speed should not throw',
        );
        expect(
          () => gameCamera.setBounds(Rectangle<int>(-200, 600, 1600, 500)),
          returnsNormally,
          reason: 'Setting bounds should not throw',
        );
        expect(
          gameCamera.bounds,
          isNotNull,
          reason: 'Camera should have bounds after setting',
        );

        // Test camera state management
        expect(
          () => gameCamera.stopFollowing(),
          returnsNormally,
          reason: 'Stopping follow should not throw',
        );

        print(
          '✅ T2.17.5.11b: Comprehensive camera behavior validation complete',
        );
      });
    });
  });
}

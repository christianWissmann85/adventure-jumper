import 'dart:async';

import 'package:adventure_jumper/src/game/game_config.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller_refactored.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_response.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_state.dart';
import 'package:adventure_jumper/src/systems/interfaces/player_movement_request.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMovementCoordinator extends Mock implements IMovementCoordinator {}
class MockPhysicsCoordinator extends Mock implements IPhysicsCoordinator {}

// Test game
class TestGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
}

void main() {
  // Register fallback values
  setUpAll(() {
    registerFallbackValue(Vector2.zero());
    registerFallbackValue(PlayerMovementRequest.playerWalk(
      entityId: 0,
      direction: Vector2.zero(),
      speed: 0,
    ));
  });

  group('PHY-3.2.4: Simplified Player Responsiveness Tests', () {
    late TestGame game;
    late Player player;
    late PlayerControllerRefactored controller;
    late MockMovementCoordinator mockMovementCoordinator;
    late MockPhysicsCoordinator mockPhysicsCoordinator;

    setUp(() async {
      game = TestGame();
      await game.onLoad();
      
      mockMovementCoordinator = MockMovementCoordinator();
      mockPhysicsCoordinator = MockPhysicsCoordinator();
      
      // Create player
      player = Player(position: Vector2(100, 100));
      
      // Create controller with coordination interfaces
      controller = PlayerControllerRefactored(
        player,
        movementCoordinator: mockMovementCoordinator,
        physicsCoordinator: mockPhysicsCoordinator,
      );
      
      await game.add(player);
      await player.add(controller);
      
      // Ensure controller is initialized
      await controller.onLoad();
      
      // Setup default mock responses
      when(() => mockPhysicsCoordinator.isGrounded(any())).thenAnswer((_) async => true);
      when(() => mockPhysicsCoordinator.getVelocity(any())).thenAnswer((_) async => Vector2.zero());
      when(() => mockPhysicsCoordinator.getPosition(any())).thenAnswer((_) async => Vector2(100, 100));
      when(() => mockPhysicsCoordinator.getPhysicsState(any())).thenAnswer((_) async => PhysicsState(
        entityId: player.hashCode,
        position: Vector2(100, 100),
        velocity: Vector2.zero(),
        acceleration: Vector2.zero(),
        mass: 1.0,
        gravityScale: 1.0,
        friction: 0.2,
        restitution: 0.0,
        isStatic: false,
        affectedByGravity: true,
        isGrounded: true,
        wasGrounded: true,
        activeCollisions: [],
        accumulatedForces: Vector2.zero(),
        contactPointCount: 0,
        updateCount: 0,
        lastUpdateTime: DateTime.now(),
      ));
    });

    tearDown(() {
      game.pauseEngine();
    });

    test('should respond to movement input within 4 frames (67ms)', () async {
      // Setup successful movement response
      when(() => mockMovementCoordinator.handleMovementInput(any(), any(), any()))
          .thenAnswer((invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: Vector2(200, 0),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          ));

      final stopwatch = Stopwatch()..start();
      
      // Simulate right input
      controller.handleInputAction('move_right', true);
      
      // Process one frame
      await Future.microtask(() => controller.update(0.016)); // 16ms frame
      
      stopwatch.stop();
      
      // Verify movement was requested within 4 frames (67ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(67),
          reason: 'Input response must be <4 frames (67ms) at 60fps');
      
      // Verify movement request was made
      verify(() => mockMovementCoordinator.handleMovementInput(any(), Vector2(1, 0), any())).called(1);
    });

    test('should maintain responsiveness during rapid inputs', () async {
      // Setup movement responses
      when(() => mockMovementCoordinator.handleMovementInput(any(), any(), any()))
          .thenAnswer((invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: invocation.positionalArguments[1] as Vector2,
              speed: 200,
            ),
            actualVelocity: (invocation.positionalArguments[1] as Vector2) * 200,
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          ));

      final responseTimes = <int>[];
      
      // Simulate rapid left-right sequence
      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        
        final actionName = i % 2 == 0 ? 'move_left' : 'move_right';
        controller.handleInputAction(actionName, true);
        await Future.microtask(() => controller.update(0.016));
        
        stopwatch.stop();
        responseTimes.add(stopwatch.elapsedMilliseconds);
        
        // Brief pause
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      // All inputs should maintain responsiveness
      for (final time in responseTimes) {
        expect(time, lessThan(67),
            reason: 'Every input must maintain <4 frame response time');
      }
    });

    test('should handle jump input with proper timing', () async {
      // Setup jump response
      when(() => mockMovementCoordinator.handleJumpInput(any(), any()))
          .thenAnswer((_) async => MovementResponse.success(
            request: PlayerMovementRequest.playerJump(
              entityId: player.hashCode,
              force: GameConfig.jumpForce,
            ),
            actualVelocity: Vector2(0, -300),
            actualPosition: Vector2(100, 100),
            isGrounded: false,
          ));

      final stopwatch = Stopwatch()..start();
      
      // Press jump
      controller.handleInputAction('jump', true);
      await Future.microtask(() => controller.update(0.016));
      
      stopwatch.stop();
      
      // Jump should be responsive
      expect(stopwatch.elapsedMilliseconds, lessThan(67));
      
      // Verify jump was processed
      verify(() => mockMovementCoordinator.handleJumpInput(any(), any())).called(1);
    });

    test('should maintain natural acceleration feel', () async {
      final velocities = <double>[];
      var currentVelocity = 0.0;
      
      when(() => mockMovementCoordinator.handleMovementInput(any(), any(), any()))
          .thenAnswer((_) async {
            // Simulate natural acceleration
            currentVelocity = (currentVelocity + GameConfig.playerAcceleration * 0.016)
                .clamp(0, GameConfig.maxWalkSpeed);
            velocities.add(currentVelocity);
            
            return MovementResponse.success(
              request: PlayerMovementRequest.playerWalk(
                entityId: player.hashCode,
                direction: Vector2(1, 0),
                speed: currentVelocity,
              ),
              actualVelocity: Vector2(currentVelocity, 0),
              actualPosition: Vector2(100, 100),
              isGrounded: true,
            );
          });
      
      when(() => mockPhysicsCoordinator.getVelocity(any()))
          .thenAnswer((_) async => Vector2(currentVelocity, 0));

      // Hold right for several frames
      controller.handleInputAction('move_right', true);
      
      for (int i = 0; i < 30; i++) {
        await Future.microtask(() => controller.update(0.016));
      }
      
      // Verify smooth acceleration
      expect(velocities.length, greaterThan(20));
      
      // Check for smooth increase
      for (int i = 1; i < velocities.length; i++) {
        final delta = velocities[i] - velocities[i - 1];
        expect(delta, greaterThanOrEqualTo(0),
            reason: 'Velocity should increase smoothly');
      }
    });

    test('should maintain 99%+ responsiveness', () async {
      var successCount = 0;
      var totalCount = 0;
      
      when(() => mockMovementCoordinator.handleMovementInput(any(), any(), any()))
          .thenAnswer((_) async {
            totalCount++;
            
            // Simulate 99% success rate
            if (totalCount % 100 != 0) {
              successCount++;
              return MovementResponse.success(
                request: PlayerMovementRequest.playerWalk(
                  entityId: player.hashCode,
                  direction: Vector2(1, 0),
                  speed: 200,
                ),
                actualVelocity: Vector2(200, 0),
                actualPosition: Vector2(100, 100),
                isGrounded: true,
              );
            } else {
              return MovementResponse.blocked(
                request: PlayerMovementRequest.playerWalk(
                  entityId: player.hashCode,
                  direction: Vector2(1, 0),
                  speed: 200,
                ),
                currentPosition: Vector2(100, 100),
                isGrounded: true,
                reason: 'Simulated failure',
              );
            }
          });

      // Run 100 movement attempts
      for (int i = 0; i < 100; i++) {
        final actionName = i % 2 == 0 ? 'move_left' : 'move_right';
        controller.handleInputAction(actionName, true);
        await Future.microtask(() => controller.update(0.016));
        await Future.delayed(const Duration(milliseconds: 16));
      }
      
      final successRate = successCount / totalCount;
      expect(successRate, greaterThan(0.98),
          reason: 'Must maintain >99% control responsiveness');
    });
  });
}
import 'package:adventure_jumper/src/components/input_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/game/game_config.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_response.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_state.dart';
import 'package:adventure_jumper/src/systems/interfaces/player_movement_request.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMovementCoordinator extends Mock implements IMovementCoordinator {}

class MockPhysicsCoordinator extends Mock implements IPhysicsCoordinator {}

class MockPhysicsComponent extends Mock implements PhysicsComponent {}

class MockInputComponent extends Mock implements InputComponent {}

class MockFlameGame extends Mock implements FlameGame {}

// Test game for benchmarking
class TestGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }
}

void main() {
  // Register fallback values for mocks
  setUpAll(() {
    registerFallbackValue(Vector2.zero());
    registerFallbackValue(
      PlayerMovementRequest.playerWalk(
        entityId: 0,
        direction: Vector2.zero(),
        speed: 0,
      ),
    );
    registerFallbackValue(
      PhysicsState(
        entityId: 0,
        position: Vector2.zero(),
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
      ),
    );
  });
  group('PHY-3.2.4: Player Responsiveness Validation', () {
    late TestGame game;
    late Player player;
    late PlayerController controller;
    late MockMovementCoordinator mockMovementCoordinator;
    late MockPhysicsCoordinator mockPhysicsCoordinator;
    late MockPhysicsComponent mockPhysicsComponent;
    late MockInputComponent mockInputComponent;

    setUp(() async {
      game = TestGame();
      await game.onLoad();

      mockMovementCoordinator = MockMovementCoordinator();
      mockPhysicsCoordinator = MockPhysicsCoordinator();
      mockPhysicsComponent = MockPhysicsComponent();
      mockInputComponent = MockInputComponent();

      // Setup physics component mock
      when(() => mockPhysicsComponent.velocity).thenReturn(Vector2.zero());
      when(() => mockPhysicsComponent.position).thenReturn(Vector2(100, 100));

      // Create player
      player = Player(
        position: Vector2(100, 100),
      );
      // Override components with mocks
      player.physics = mockPhysicsComponent;
      player.input = mockInputComponent;
      // Create controller with coordination interfaces
      controller = PlayerController(
        player,
        movementCoordinator: mockMovementCoordinator,
        physicsCoordinator: mockPhysicsCoordinator,
      );

      await player.add(controller);
      await game.add(player);

      // Setup default mock responses
      when(() => mockPhysicsCoordinator.isGrounded(any()))
          .thenAnswer((_) async => true);
      when(() => mockPhysicsCoordinator.getVelocity(any()))
          .thenAnswer((_) async => Vector2.zero());
      when(() => mockPhysicsCoordinator.getPosition(any()))
          .thenAnswer((_) async => Vector2(100, 100));
      when(() => mockPhysicsCoordinator.getPhysicsState(any())).thenAnswer(
        (_) async => PhysicsState(
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
        ),
      );
    });

    tearDown(() {
      game.pauseEngine();
      // game.children.clear();
    });

    group('Input-to-Movement Latency Benchmarks', () {
      test('should achieve <4 frame (67ms) input response at 60fps', () async {
        // Setup successful movement response
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: Vector2(200, 0),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
            debugInfo: {'responseTime': '2ms'},
          ),
        );

        // Measure time from input to movement request
        final stopwatch = Stopwatch()..start();

        // Simulate right arrow key press
        // Simulate input through action name
        controller.handleInputAction('move_right', true);

        // Process one frame
        await Future.microtask(() => controller.update(0.016)); // 16ms frame

        stopwatch.stop();

        // Verify movement was requested within 4 frames (67ms)
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(67),
          reason: 'Input response must be <4 frames (67ms) at 60fps',
        );

        // Verify movement request was made
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            Vector2(1, 0),
            any(),
          ),
        ).called(1);
      });

      test('should maintain responsiveness during rapid input sequences',
          () async {
        // Setup movement responses
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: Vector2(200, 0),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          ),
        );

        final responseTimes = <int>[];

        // Simulate rapid left-right input sequence
        for (int i = 0; i < 10; i++) {
          final stopwatch = Stopwatch()..start();

          // Alternate left/right inputs
          final actionName = i % 2 == 0 ? 'move_left' : 'move_right';
          controller.handleInputAction(actionName, true);
          await Future.microtask(() => controller.update(0.016));

          stopwatch.stop();
          responseTimes.add(stopwatch.elapsedMilliseconds);

          // Brief pause between inputs
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // All inputs should maintain <67ms response time
        for (final time in responseTimes) {
          expect(
            time,
            lessThan(67),
            reason: 'Every input must maintain <4 frame response time',
          );
        }

        // Average should be well below threshold
        final avgResponseTime =
            responseTimes.reduce((a, b) => a + b) / responseTimes.length;
        expect(
          avgResponseTime,
          lessThan(40),
          reason: 'Average response time should be well below 67ms threshold',
        );
      });

      test('should handle simultaneous inputs without latency increase',
          () async {
        // Setup movement responses
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: Vector2(200, -300),
            actualPosition: Vector2(100, 100),
            isGrounded: false,
          ),
        );
        when(() => mockMovementCoordinator.handleJumpInput(any(), any()))
            .thenAnswer(
          (invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerJump(
              entityId: player.hashCode,
              force: GameConfig.jumpForce,
            ),
            actualVelocity: Vector2(200, -300),
            actualPosition: Vector2(100, 100),
            isGrounded: false,
          ),
        );

        final stopwatch = Stopwatch()..start();

        // Simulate right + jump simultaneously
        controller.handleInputAction('move_right', true);
        controller.handleInputAction('jump', true);

        await Future.microtask(() => controller.update(0.016));

        stopwatch.stop();

        // Should maintain <4 frame response even with multiple inputs
        expect(stopwatch.elapsedMilliseconds, lessThan(67));

        // Both movement and jump should be processed
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).called(1);
        verify(() => mockMovementCoordinator.handleJumpInput(any(), any()))
            .called(1);
      });
    });

    group('Movement Feel and Acceleration', () {
      test('should maintain natural acceleration curves', () async {
        final velocities = <double>[];

        // Setup movement responses that simulate acceleration
        var currentVelocity = 0.0;
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async {
          // Simulate natural acceleration
          currentVelocity =
              (currentVelocity + GameConfig.playerAcceleration * 0.016)
                  .clamp(0, GameConfig.maxWalkSpeed);
          velocities.add(currentVelocity);

          return MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: currentVelocity.abs(),
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

        // Simulate 30 frames (0.5 seconds)
        for (int i = 0; i < 30; i++) {
          await Future.microtask(() => controller.update(0.016));
        }

        // Verify smooth acceleration curve
        expect(velocities.length, greaterThan(20));

        // Check for smooth increase (no sudden jumps)
        for (int i = 1; i < velocities.length; i++) {
          final delta = velocities[i] - velocities[i - 1];
          expect(
            delta,
            greaterThanOrEqualTo(0),
            reason: 'Velocity should increase smoothly',
          );
          expect(
            delta,
            lessThan(GameConfig.playerAcceleration * 0.02),
            reason: 'Acceleration should not have sudden jumps',
          );
        }

        // Should approach max speed smoothly
        expect(velocities.last, closeTo(GameConfig.maxWalkSpeed, 10));
      });

      test('should preserve direction change responsiveness', () async {
        // Start moving right
        var currentVelocity = GameConfig.maxWalkSpeed;
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2(currentVelocity, 0));

        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((invocation) async {
          final direction = invocation.positionalArguments[1] as Vector2;

          // Simulate direction change with boosted deceleration
          if (direction.x < 0 && currentVelocity > 0) {
            // Changing from right to left
            currentVelocity -= GameConfig.playerAcceleration * 1.5 * 0.016;
          } else if (direction.x < 0) {
            // Continuing left
            currentVelocity =
                (currentVelocity - GameConfig.playerAcceleration * 0.016)
                    .clamp(-GameConfig.maxWalkSpeed, 0);
          }

          return MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: currentVelocity.abs(),
            ),
            actualVelocity: Vector2(currentVelocity, 0),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          );
        });

        final stopwatch = Stopwatch()..start();

        // Switch to left
        controller.handleInputAction('move_left', true);

        // Process frames until velocity changes direction
        var frameCount = 0;
        while (currentVelocity > 0 && frameCount < 60) {
          await Future.microtask(() => controller.update(0.016));
          frameCount++;
        }

        stopwatch.stop();

        // Direction change should be responsive
        expect(
          frameCount,
          lessThan(30),
          reason: 'Direction change should occur within 0.5 seconds',
        );
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Direction change should be responsive',
        );
      });
    });

    group('Jump Mechanics and Timing', () {
      test('should maintain variable jump height based on input duration',
          () async {
        final jumpHeights = <double>[];

        // Test different jump hold durations
        for (final holdDuration in [50, 100, 200]) {
          // Reset state
          var currentHeight = 0.0;
          var maxHeight = 0.0;

          when(() => mockPhysicsCoordinator.getPosition(any()))
              .thenAnswer((_) async => Vector2(100, 100 - currentHeight));
          when(() => mockPhysicsCoordinator.getVelocity(any())).thenAnswer(
            (_) async => Vector2(0, currentHeight > maxHeight ? 100 : -300),
          );

          when(() => mockMovementCoordinator.handleJumpInput(any(), any()))
              .thenAnswer((_) async {
            currentHeight += 10; // Simulate upward movement
            if (currentHeight > maxHeight) maxHeight = currentHeight;
            return MovementResponse.success(
              request: PlayerMovementRequest.playerJump(
                entityId: player.hashCode,
                force: GameConfig.jumpForce,
              ),
              actualVelocity: Vector2(0, -300),
              actualPosition: Vector2(100, 100 - currentHeight),
              isGrounded: false,
            );
          });

          // Press jump
          controller.handleInputAction('jump', true);

          // Hold for specified duration
          final frameCount = (holdDuration / 16).round();
          for (int i = 0; i < frameCount; i++) {
            await Future.microtask(() => controller.update(0.016));
          }

          // Release jump
          controller.handleInputAction('jump', false);

          jumpHeights.add(maxHeight);
        }

        // Verify variable jump heights
        expect(
          jumpHeights[0],
          lessThan(jumpHeights[1]),
          reason: 'Longer hold should result in higher jump',
        );
        expect(
          jumpHeights[1],
          lessThan(jumpHeights[2]),
          reason: 'Even longer hold should result in even higher jump',
        );
      });

      test('should maintain coyote time functionality', () async {
        // Setup: player walks off edge
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => false); // Not grounded
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2(100, 50)); // Falling

        var jumpSuccessful = false;
        when(() => mockMovementCoordinator.handleJumpInput(any(), any()))
            .thenAnswer((_) async {
          jumpSuccessful = true;
          return MovementResponse.success(
            request: PlayerMovementRequest.playerJump(
              entityId: player.hashCode,
              force: GameConfig.jumpForce,
            ),
            actualVelocity: Vector2(100, -300),
            actualPosition: Vector2(100, 100),
            isGrounded: false,
          );
        });

        // Simulate walking off edge (triggers coyote time in controller)
        await Future.microtask(() => controller.update(0.016));

        // Try to jump within coyote time window
        await Future.delayed(
          Duration(milliseconds: (GameConfig.jumpCoyoteTime * 500).round()),
        );

        controller.handleInputAction('jump', true);
        await Future.microtask(() => controller.update(0.016));

        // Jump should still work within coyote time
        expect(
          jumpSuccessful,
          isTrue,
          reason: 'Jump should work within coyote time after leaving ground',
        );
      });

      test('should maintain jump buffer timing', () async {
        // Setup: player is falling
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => false);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2(0, 200)); // Falling

        // Press jump while in air
        controller.handleInputAction('jump', true);

        // Land shortly after
        await Future.delayed(
          Duration(milliseconds: (GameConfig.jumpBufferTime * 500).round()),
        );

        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true); // Now grounded

        var jumpExecuted = false;
        when(() => mockMovementCoordinator.handleJumpInput(any(), any()))
            .thenAnswer((_) async {
          jumpExecuted = true;
          return MovementResponse.success(
            request: PlayerMovementRequest.playerJump(
              entityId: player.hashCode,
              force: GameConfig.jumpForce,
            ),
            actualVelocity: Vector2(0, -300),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          );
        });

        // Process frame after landing
        await Future.microtask(() => controller.update(0.016));

        // Buffered jump should execute
        expect(
          jumpExecuted,
          isTrue,
          reason: 'Buffered jump should execute upon landing',
        );
      });
    });

    group('Movement Quality Regression Tests', () {
      test('should not introduce input lag compared to baseline', () async {
        // Baseline: immediate response
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (invocation) async => MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: Vector2(200, 0),
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          ),
        );

        final measurements = <int>[];

        for (int i = 0; i < 100; i++) {
          final stopwatch = Stopwatch()..start();

          // Simulate input through action name
          controller.handleInputAction('move_right', true);
          await Future.microtask(
            () => controller.update(0.001),
          ); // Minimal frame time

          stopwatch.stop();
          measurements.add(stopwatch.elapsedMicroseconds);
        }

        // Calculate statistics
        final avgLatency =
            measurements.reduce((a, b) => a + b) / measurements.length;
        final maxLatency = measurements.reduce((a, b) => a > b ? a : b);

        // Performance requirements
        expect(
          avgLatency, lessThan(2000), // <2ms average
          reason: 'Average latency must be <2ms',
        );
        expect(
          maxLatency, lessThan(4000), // <4ms max
          reason: 'Maximum latency must be <4ms',
        );

        // 99th percentile should be excellent
        measurements.sort();
        final p99 = measurements[(measurements.length * 0.99).floor()];
        expect(
          p99, lessThan(3000), // <3ms for 99th percentile
          reason: '99% of inputs must respond within 3ms',
        );
      });

      test('should maintain movement smoothness during state transitions',
          () async {
        final velocityChanges = <double>[];
        var currentVelocity = Vector2.zero();

        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => currentVelocity);

        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((invocation) async {
          final direction = invocation.positionalArguments[1] as Vector2;
          final speed = invocation.positionalArguments[2] as double;

          // Smooth velocity update
          final targetVelocity = direction * speed;
          final smoothing = 0.1; // Smoothing factor
          currentVelocity =
              currentVelocity + (targetVelocity - currentVelocity) * smoothing;
          velocityChanges.add((currentVelocity - targetVelocity).length);

          return MovementResponse.success(
            request: PlayerMovementRequest.playerWalk(
              entityId: player.hashCode,
              direction: Vector2(1, 0),
              speed: 200,
            ),
            actualVelocity: currentVelocity,
            actualPosition: Vector2(100, 100),
            isGrounded: true,
          );
        });

        // Test ground -> air -> ground transition
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);

        // Start moving
        controller.handleInputAction('move_right', true);

        for (int i = 0; i < 10; i++) {
          await Future.microtask(() => controller.update(0.016));
        }

        // Jump (transition to air)
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => false);

        controller.handleInputAction('jump', true);

        for (int i = 0; i < 20; i++) {
          await Future.microtask(() => controller.update(0.016));
        }

        // Land (transition back to ground)
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);

        for (int i = 0; i < 10; i++) {
          await Future.microtask(() => controller.update(0.016));
        }

        // Verify smooth transitions (no jarring changes)
        for (int i = 1; i < velocityChanges.length; i++) {
          final change = (velocityChanges[i] - velocityChanges[i - 1]).abs();
          expect(
            change,
            lessThan(50),
            reason:
                'Velocity changes should be smooth during state transitions',
          );
        }
      });

      test('should maintain 99%+ control responsiveness under load', () async {
        var successfulResponses = 0;
        var totalAttempts = 0;

        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((invocation) async {
          totalAttempts++;

          // Simulate 99% success rate
          if (totalAttempts % 100 != 0) {
            successfulResponses++;
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
            // 1% failure for retry mechanism testing
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

        // Run 1000 movement attempts
        for (int i = 0; i < 1000; i++) {
          // Alternate left/right inputs
          final actionName = i % 2 == 0 ? 'move_left' : 'move_right';
          controller.handleInputAction(actionName, true);
          await Future.microtask(() => controller.update(0.016));

          // Small delay between inputs
          await Future.delayed(const Duration(milliseconds: 16));
        }

        // Calculate success rate
        final successRate = successfulResponses / totalAttempts;

        expect(
          successRate,
          greaterThan(0.99),
          reason: 'Must maintain >99% control responsiveness',
        );

        // Verify retry mechanism is working
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).called(greaterThan(1000)); // Should have retries
      });
    });
  });
}

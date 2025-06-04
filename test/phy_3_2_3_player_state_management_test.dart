import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/player/player_controller.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_request.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_response.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/player_movement_request.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMovementCoordinator extends Mock implements IMovementCoordinator {}

class MockPhysicsCoordinator extends Mock implements IPhysicsCoordinator {}

class MockPlayer extends Mock implements Player {
  @override
  final NotifyingVector2 position = NotifyingVector2(100, 200);

  @override
  int get hashCode => 123;
}

void main() {
  late PlayerController controller;
  late MockMovementCoordinator mockMovementCoordinator;
  late MockPhysicsCoordinator mockPhysicsCoordinator;
  late MockPlayer mockPlayer;

  setUpAll(() {
    registerFallbackValue(Vector2.zero());
    registerFallbackValue(MovementType.walk);
    registerFallbackValue(PlayerAction.walk);
    registerFallbackValue(
        MovementRequest.walk(entityId: 0, direction: Vector2.zero(), speed: 0));
  });

  setUp(() {
    mockMovementCoordinator = MockMovementCoordinator();
    mockPhysicsCoordinator = MockPhysicsCoordinator();
    mockPlayer =
        MockPlayer(); // No need to setup mocks for overridden properties

    controller = PlayerController(
      mockPlayer,
      movementCoordinator: mockMovementCoordinator,
      physicsCoordinator: mockPhysicsCoordinator,
    );
  });

  group('PHY-3.2.3 Player State Management Tests', () {
    group('Retry Mechanism', () {
      test('should retry movement with fallback speed on failure', () async {
        // Setup failed first attempt
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.failed(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2(-1, 0), speed: 100),
            reason: 'blocked',
            currentPosition: Vector2(100, 200),
          ),
        );

        // Mock physics queries
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());

        await controller.onLoad();
        controller.handleInputAction('move_left', true);

        // Wait for async operations
        await Future.delayed(Duration(milliseconds: 50));

        // Verify retry attempts were made
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).called(greaterThan(1));
      });

      test('should use emergency fallback after retry failures', () async {
        // Setup all attempts to fail
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.failed(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2(1, 0), speed: 100),
            reason: 'blocked',
            currentPosition: Vector2(100, 200),
          ),
        );

        // Mock physics coordinator for emergency fallback
        when(
          () => mockPhysicsCoordinator.requestMovement(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.success(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2.zero(), speed: 30),
            actualVelocity: Vector2(30, 0),
            actualPosition: Vector2(100, 200),
            isGrounded: true,
          ),
        );
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());

        await controller.onLoad();
        controller.handleInputAction('move_right', true);

        // Wait for async operations
        await Future.delayed(Duration(milliseconds: 50));

        // Verify emergency fallback was triggered
        verify(
          () => mockPhysicsCoordinator.requestMovement(
            any(),
            any(),
            any(),
          ),
        ).called(1);
      });
    });

    group('Respawn State', () {
      test('should create proper RespawnState on respawn', () async {
        // Mock physics state queries
        when(() => mockPhysicsCoordinator.getPosition(any())).thenAnswer(
            (_) async => Vector2(100, 1500)); // Below fall threshold
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => false);
        when(() => mockPhysicsCoordinator.resetPhysicsState(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .thenAnswer((_) async {});

        await controller.onLoad();

        // Trigger respawn by updating with high Y position
        controller.update(0.016);
        await Future.delayed(Duration(milliseconds: 50));

        // Verify physics reset was called
        verify(() => mockPhysicsCoordinator.resetPhysicsState(any())).called(1);
        verify(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .called(greaterThanOrEqualTo(1));
      });

      test('should reset input state on respawn', () async {
        // Setup mocks for respawn
        when(() => mockPhysicsCoordinator.getPosition(any()))
            .thenAnswer((_) async => Vector2(100, 200));
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .thenAnswer((_) async {});

        await controller.onLoad();

        // Set some input state
        controller.handleInputAction('move_left', true);
        controller.handleInputAction('jump', true);

        // Reset input state
        controller.resetInputState();

        // Verify state is reset
        expect(controller.isMovingLeft, false);
        expect(controller.isMovingRight, false);
        expect(controller.isJumping, false);

        // Verify accumulation clearing was requested
        verify(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .called(1);
      });
    });

    group('Rapid Input Detection', () {
      test('should detect rapid input sequences', () async {
        int accumulationPreventionCalls = 0;

        // Mock successful movement
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.success(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2(-1, 0), speed: 100),
            actualVelocity: Vector2(100, 0),
            actualPosition: Vector2(100, 200),
            isGrounded: true,
          ),
        );

        // Mock physics queries
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());
        when(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .thenAnswer((_) async {
          accumulationPreventionCalls++;
        });

        await controller.onLoad();

        // Simulate rapid input (more than 5 inputs in 200ms)
        for (int i = 0; i < 10; i++) {
          controller.handleInputAction('move_left', true);
          controller.handleInputAction('move_left', false);
          controller.update(0.01); // 10ms between inputs
          await Future.delayed(Duration(milliseconds: 15));
        }

        // Should have triggered accumulation prevention
        expect(accumulationPreventionCalls, greaterThan(0));
      });

      test('should reset rapid input tracking after gaps', () async {
        // Mock successful movement
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.success(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2(-1, 0), speed: 100),
            actualVelocity: Vector2(100, 0),
            actualPosition: Vector2(100, 200),
            isGrounded: true,
          ),
        );

        // Mock physics queries
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());

        int preventionCalls = 0;
        when(() => mockPhysicsCoordinator.clearAccumulatedForces(any()))
            .thenAnswer((_) async {
          preventionCalls++;
        });

        await controller.onLoad();

        // First sequence
        for (int i = 0; i < 3; i++) {
          controller.handleInputAction('move_left', true);
          controller.update(0.01);
          await Future.delayed(Duration(milliseconds: 10));
        }

        // Gap
        await Future.delayed(Duration(milliseconds: 300));

        // Second sequence (should start fresh)
        for (int i = 0; i < 3; i++) {
          controller.handleInputAction('move_left', true);
          controller.update(0.01);
          await Future.delayed(Duration(milliseconds: 10));
        }

        // Should not have triggered prevention with only 3 inputs per sequence
        expect(preventionCalls, 0);
      });
    });

    group('Movement Request Integration', () {
      test('should create PlayerMovementRequest with proper metadata',
          () async {
        MovementResponse? capturedResponse;

        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((invocation) async {
          final direction = invocation.positionalArguments[1] as Vector2;
          final speed = invocation.positionalArguments[2] as double;
          capturedResponse = MovementResponse.success(
            request: MovementRequest.walk(
                entityId: 123, direction: direction, speed: speed),
            actualVelocity: direction * speed,
            actualPosition: Vector2(100, 200),
            isGrounded: true,
          );
          return capturedResponse!;
        });

        // Mock physics queries
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());

        await controller.onLoad();

        // Perform a movement
        controller.handleInputAction('move_right', true);
        controller.update(0.016);
        await Future.delayed(Duration(milliseconds: 50));

        // Verify movement was processed
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            123,
            Vector2(1, 0),
            any(),
          ),
        ).called(1);
      });

      test('should track action sequences for combo detection', () async {
        // Mock successful movements and jumps
        when(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.success(
            request: MovementRequest.walk(
                entityId: 123, direction: Vector2(1, 0), speed: 100),
            actualVelocity: Vector2(100, 0),
            actualPosition: Vector2(100, 200),
            isGrounded: true,
          ),
        );

        when(
          () => mockMovementCoordinator.handleJumpInput(
            any(),
            any(),
            variableHeight: any(named: 'variableHeight'),
          ),
        ).thenAnswer(
          (_) async => MovementResponse.success(
            request: MovementRequest.jump(entityId: 123, force: 300),
            actualVelocity: Vector2(0, -300),
            actualPosition: Vector2(100, 200),
            isGrounded: false,
          ),
        );

        when(() => mockMovementCoordinator.canJump(any()))
            .thenAnswer((_) async => true);

        // Mock physics queries
        when(() => mockPhysicsCoordinator.isGrounded(any()))
            .thenAnswer((_) async => true);
        when(() => mockPhysicsCoordinator.getVelocity(any()))
            .thenAnswer((_) async => Vector2.zero());

        await controller.onLoad();

        // Perform action sequence
        controller.handleInputAction('move_right', true);
        controller.update(0.016);
        await Future.delayed(Duration(milliseconds: 20));

        controller.handleInputAction('jump', true);
        controller.update(0.016);
        await Future.delayed(Duration(milliseconds: 20));

        // Verify both actions were processed
        verify(
          () => mockMovementCoordinator.handleMovementInput(
            any(),
            any(),
            any(),
          ),
        ).called(greaterThan(0));
        verify(
          () => mockMovementCoordinator.handleJumpInput(
            any(),
            any(),
            variableHeight: any(named: 'variableHeight'),
          ),
        ).called(1);
      });
    });
  });
}

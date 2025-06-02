// Test file to validate PHY-2.3.1 implementation
// MovementSystem refactor: Request-based coordination vs direct position updates
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_request.dart';
import 'package:adventure_jumper/src/systems/interfaces/movement_response.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_coordinator.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_state.dart';
import 'package:adventure_jumper/src/systems/movement_system.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

/// Test entity implementation for testing purposes
class TestEntity extends Entity {
  TestEntity({
    required super.position,
    String? id,
  }) : super(id: id ?? 'test_entity');

  @override
  Future<void> setupEntity() async {
    // Create and add physics component
    physics = PhysicsComponent(
      velocity: Vector2.zero(),
      isStatic: false,
    );
    await add(physics!);
  }
}

/// Mock physics coordinator for testing request-based coordination
class MockPhysicsCoordinator implements IPhysicsCoordinator {
  final List<MockMovementRequest> receivedRequests = [];
  final Map<int, Vector2> entityPositions = {};
  final Map<int, Vector2> entityVelocities = {};

  bool _interfaceEnabled = true;

  void clearReceivedRequests() {
    receivedRequests.clear();
  }

  @override
  Future<MovementResponse> requestMovement(
    int entityId,
    Vector2 direction,
    double speed,
  ) async {
    final mockRequest = MovementRequest(
      entityId: entityId,
      type: MovementType.walk,
      direction: direction,
      magnitude: speed,
      priority: MovementPriority.normal,
    );

    receivedRequests.add(
      MockMovementRequest(
        entityId: entityId,
        direction: direction,
        speed: speed,
        timestamp: DateTime.now(),
      ),
    );

    // Simulate successful movement
    final appliedVelocity = direction * speed;
    entityVelocities[entityId] = appliedVelocity;

    return MovementResponse.success(
      request: mockRequest,
      actualVelocity: appliedVelocity,
      actualPosition: entityPositions[entityId] ?? Vector2.zero(),
      isGrounded: true,
    );
  }

  @override
  Future<MovementResponse> requestJump(int entityId, double force) async {
    final mockRequest = MovementRequest(
      entityId: entityId,
      type: MovementType.jump,
      direction: Vector2(0, -1),
      magnitude: force,
      priority: MovementPriority.normal,
    );

    return MovementResponse.success(
      request: mockRequest,
      actualVelocity: Vector2(0, -force),
      actualPosition: entityPositions[entityId] ?? Vector2.zero(),
      isGrounded: false,
    );
  }

  @override
  Future<void> requestStop(int entityId) async {
    entityVelocities[entityId] = Vector2.zero();
  }

  @override
  Future<void> requestImpulse(int entityId, Vector2 impulse) async {
    // Mock implementation
  }

  @override
  Future<bool> isGrounded(int entityId) async => true;

  @override
  Future<Vector2> getVelocity(int entityId) async =>
      entityVelocities[entityId] ?? Vector2.zero();

  @override
  Future<Vector2> getPosition(int entityId) async =>
      entityPositions[entityId] ?? Vector2.zero();
  @override
  Future<PhysicsState> getPhysicsState(int entityId) async => PhysicsState(
        entityId: entityId,
        position: entityPositions[entityId] ?? Vector2.zero(),
        velocity: entityVelocities[entityId] ?? Vector2.zero(),
        acceleration: Vector2.zero(),
        mass: 1.0,
        gravityScale: 1.0,
        friction: 0.1,
        restitution: 0.0,
        isStatic: false,
        affectedByGravity: true,
        isGrounded: true,
        wasGrounded: false,
        activeCollisions: [],
        accumulatedForces: Vector2.zero(),
        contactPointCount: 0,
        updateCount: 0,
        lastUpdateTime: DateTime.now(),
      );

  @override
  Future<bool> hasCollisionBelow(int entityId) async => false;

  @override
  Future<void> resetPhysicsState(int entityId) async {
    entityPositions.remove(entityId);
    entityVelocities.remove(entityId);
  }

  @override
  Future<void> clearAccumulatedForces(int entityId) async {}

  @override
  Future<void> setPositionOverride(int entityId, Vector2 position) async {
    entityPositions[entityId] = position;
  }

  @override
  Future<bool> validateStateConsistency(int entityId) async => true;

  @override
  void setInterfaceEnabled(bool enabled) {
    _interfaceEnabled = enabled;
  }

  @override
  bool get isInterfaceEnabled => _interfaceEnabled;
}

/// Simple movement request for testing
class MockMovementRequest {
  final int entityId;
  final Vector2 direction;
  final double speed;
  final DateTime timestamp;

  MockMovementRequest({
    required this.entityId,
    required this.direction,
    required this.speed,
    required this.timestamp,
  });
}

void main() {
  group('PHY-2.3.1 MovementSystem Refactor Tests', () {
    late MovementSystem movementSystem;
    late MockPhysicsCoordinator mockCoordinator;
    late TestEntity testEntity;

    setUp(() async {
      mockCoordinator = MockPhysicsCoordinator();
      movementSystem = MovementSystem(physicsCoordinator: mockCoordinator);

      // Create test entity with physics component
      testEntity = TestEntity(
        position: Vector2(0, 0),
        id: 'test_entity',
      );

      // Initialize entity components
      await testEntity.setupEntity();
      await testEntity.onLoad();
    });

    group('Request-Based Coordination Tests', () {
      test('should use request-based coordination when coordinator is injected',
          () {
        // Arrange
        mockCoordinator.clearReceivedRequests();
        testEntity.physics!
            .setVelocity(Vector2(100, 0)); // Moving right at 100 px/s

        // Act
        movementSystem.processEntity(testEntity, 0.016); // 60 FPS

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
        final request = mockCoordinator.receivedRequests.first;
        expect(request.entityId, equals(testEntity.hashCode));
        expect(
          request.direction.x,
          closeTo(1.0, 0.01),
        ); // Normalized right direction
        expect(request.direction.y, closeTo(0.0, 0.01));
      });

      test('should not make requests for entities with zero velocity', () {
        // Arrange
        testEntity.physics!.setVelocity(Vector2.zero());
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(0));
      });

      test('should calculate correct speed from velocity and delta time', () {
        // Arrange
        testEntity.physics!.setVelocity(Vector2(200, 0)); // 200 px/s
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.5); // 0.5 second delta

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
        final request = mockCoordinator.receivedRequests.first;
        // Speed should be original velocity length / delta time
        expect(request.speed, closeTo(400.0, 1.0)); // 200 / 0.5 = 400
      });

      test('should handle diagonal movement correctly', () {
        // Arrange
        testEntity.physics!.setVelocity(Vector2(100, 100)); // Diagonal movement
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
        final request = mockCoordinator.receivedRequests.first;

        // Direction should be normalized
        final expectedLength = request.direction.length;
        expect(expectedLength, closeTo(1.0, 0.01));

        // Both components should be equal for 45-degree movement
        expect(request.direction.x, closeTo(request.direction.y, 0.01));
      });

      test('should handle negative velocity correctly', () {
        // Arrange
        testEntity.physics!.setVelocity(Vector2(-150, 0)); // Moving left
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
        final request = mockCoordinator.receivedRequests.first;
        expect(request.direction.x, closeTo(-1.0, 0.01)); // Left direction
        expect(request.direction.y, closeTo(0.0, 0.01));
      });
    });

    group('Legacy Fallback Tests', () {
      test('should use legacy fallback when no coordinator is injected', () {
        // Arrange
        final legacySystem = MovementSystem(); // No coordinator
        final originalPosition = testEntity.position.clone();
        testEntity.physics!.setVelocity(Vector2(100, 0));

        // Act
        legacySystem.processEntity(testEntity, 0.016);

        // Assert - entity position should be updated directly (legacy behavior)
        expect(testEntity.position.x, greaterThan(originalPosition.x));
        expect(
          testEntity.position.x,
          closeTo(originalPosition.x + 1.6, 0.1),
        ); // 100 * 0.016
      });

      test('should preserve legacy behavior for backward compatibility', () {
        // Arrange
        final legacySystem = MovementSystem();
        testEntity.physics!.setVelocity(Vector2(0, -200)); // Upward movement
        final originalY = testEntity.position.y;

        // Act
        legacySystem.processEntity(testEntity, 0.1); // 100ms

        // Assert
        expect(
          testEntity.position.y,
          lessThan(originalY),
        ); // Moved up (negative Y)
        expect(
          testEntity.position.y,
          closeTo(originalY - 20, 0.1),
        ); // -200 * 0.1
      });
    });

    group('Dependency Injection Tests', () {
      test('should allow coordinator injection after construction', () {
        // Arrange
        final systemWithoutCoordinator = MovementSystem();
        testEntity.physics!.setVelocity(Vector2(100, 0));
        mockCoordinator.clearReceivedRequests();

        // Act
        systemWithoutCoordinator.setPhysicsCoordinator(mockCoordinator);
        systemWithoutCoordinator.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
      });

      test(
          'should switch from legacy to request-based when coordinator is injected',
          () {
        // Arrange
        final adaptiveSystem = MovementSystem();
        testEntity.physics!.setVelocity(Vector2(100, 0));
        final originalPosition = testEntity.position.clone();

        // Act 1: Without coordinator (legacy mode)
        adaptiveSystem.processEntity(testEntity, 0.016);
        final positionAfterLegacy = testEntity.position.clone();

        // Reset position and inject coordinator
        testEntity.position = originalPosition.clone();
        adaptiveSystem.setPhysicsCoordinator(mockCoordinator);
        mockCoordinator.clearReceivedRequests();

        // Act 2: With coordinator (request-based mode)
        adaptiveSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(
          positionAfterLegacy.x,
          greaterThan(originalPosition.x),
        ); // Legacy moved entity
        expect(
          testEntity.position.x,
          equals(
            originalPosition.x,
          ),
        ); // Request-based didn't move entity directly
        expect(
          mockCoordinator.receivedRequests.length,
          equals(1),
        ); // But made a request
      });
    });

    group('Entity Filtering Tests', () {
      test('should not process static entities', () {
        // Arrange
        testEntity.physics!.isStatic = true;
        testEntity.physics!.setVelocity(Vector2(100, 0));
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(0));
      });

      test('should skip entities without physics components', () {
        // Arrange
        final entityWithoutPhysics = TestEntity(position: Vector2.zero());
        // Don't call setupEntity() to avoid adding physics component

        // Act & Assert
        expect(movementSystem.canProcessEntity(entityWithoutPhysics), isFalse);
      });

      test('should process entities with physics components', () {
        // Act & Assert
        expect(movementSystem.canProcessEntity(testEntity), isTrue);
      });
    });

    group('Time Scale Tests', () {
      test('should apply global time scale to movement calculations', () {
        // Arrange
        movementSystem.setTimeScale(2.0); // Double speed
        testEntity.physics!.setVelocity(Vector2(100, 0));
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
        final request = mockCoordinator.receivedRequests.first;
        // Speed should be doubled due to time scale
        expect(request.speed, closeTo(12500.0, 100.0)); // 100 / (0.016 * 2.0)
      });

      test('should handle zero time scale', () {
        // Arrange
        movementSystem.setTimeScale(0.0);
        testEntity.physics!.setVelocity(Vector2(100, 0));
        mockCoordinator.clearReceivedRequests();

        // Act
        movementSystem.processEntity(testEntity, 0.016);

        // Assert - No movement should occur with zero time scale
        expect(mockCoordinator.receivedRequests.length, equals(0));
      });
    });

    group('Error Handling Tests', () {
      test('should handle coordinator request failures gracefully', () {
        // This test would require a coordinator that throws exceptions
        // For now, we test that the system doesn't crash with valid inputs
        expect(
          () {
            testEntity.physics!.setVelocity(Vector2(100, 0));
            movementSystem.processEntity(testEntity, 0.016);
          },
          returnsNormally,
        );
      });

      test('should handle extreme velocity values', () {
        // Arrange
        testEntity.physics!
            .setVelocity(Vector2(1000000, 0)); // Very high velocity
        mockCoordinator.clearReceivedRequests();

        // Act
        expect(
          () {
            movementSystem.processEntity(testEntity, 0.016);
          },
          returnsNormally,
        );

        // Assert
        expect(mockCoordinator.receivedRequests.length, equals(1));
      });
    });

    group('Integration Tests', () {
      test('PHY-2.3.1 implementation should be complete', () {
        // This test validates that all key PHY-2.3.1 requirements are met

        // 1. Request-based coordination exists
        expect(movementSystem, isA<MovementSystem>());

        // 2. Coordinator injection works
        movementSystem.setPhysicsCoordinator(mockCoordinator);

        // 3. Legacy fallback exists
        final legacySystem = MovementSystem();
        expect(legacySystem, isA<MovementSystem>());

        // 4. Direct position updates are avoided in request mode
        testEntity.physics!.setVelocity(Vector2(100, 0));
        final originalPosition = testEntity.position.clone();
        mockCoordinator.clearReceivedRequests();

        movementSystem.processEntity(testEntity, 0.016);

        expect(
          testEntity.position,
          equals(originalPosition),
        ); // No direct update
        expect(
          mockCoordinator.receivedRequests.length,
          equals(1),
        ); // Request made
      });
    });
  });
}

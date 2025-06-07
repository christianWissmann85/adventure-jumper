import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:adventure_jumper/src/utils/constants.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test entity class for physics testing
class TestEntity extends Entity {
  TestEntity({
    required String super.id,
    required String super.type,
    required super.position,
    required Vector2 super.size,
  });
}

/// T2.1.7: Basic physics test scene with independent testing scenarios
/// Tests for Sprint 2 - Physics Enhancement & Jump Implementation
void main() {
  group('Physics Enhancement Tests', () {
    late PhysicsSystem physicsSystem;
    late TestEntity testEntity;
    late PhysicsComponent physics;

    setUp(() {
      physicsSystem = PhysicsSystem();
      physicsSystem.initialize();

      testEntity = TestEntity(
        id: 'test-entity',
        type: 'test',
        position: Vector2(0, 0),
        size: Vector2(32, 32),
      );
      physics = PhysicsComponent(
        mass: 1.0,
        affectedByGravity: true,
      );
      testEntity.physics = physics;
      testEntity.add(physics); // Ensure parent relationship

      physicsSystem.addEntity(testEntity);
    });

    group('T2.1.1: Gravity Constant Application', () {
      test('should apply gravity from PhysicsConstants', () {
        // Arrange: Store initial acceleration
        // final initialAcceleration = physics.acceleration.clone(); // Unused

        // Act
        physicsSystem.processEntity(testEntity, 1 / 60); // 60 FPS

        // Assert: Check that gravity was applied by looking at velocity change
        // (Acceleration is reset after integration, so we check velocity)
        expect(
          physics.velocity.y,
          greaterThan(0),
        ); // Should have positive (downward) velocity
        expect(physics.velocity.x, equals(0.0)); // No horizontal acceleration
      });
      test('should respect gravity scale multiplier', () {
        // Arrange
        physics.setGravityScale(0.5);
        final dt = 1 / 60; // Act
        physicsSystem.processEntity(testEntity, dt);

        // Assert: Check velocity change instead of acceleration (which is reset)
        final expectedVelocityChange = PhysicsConstants.gravity * 0.5 * dt;
        expect(physics.velocity.y, closeTo(expectedVelocityChange, 0.1));
      });

      test('should not apply gravity to static entities', () {
        // Arrange        physics.isStatic = true;

        // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert
        expect(physics.acceleration.y, equals(0.0));
      });

      test('should not apply gravity when affectedByGravity is false', () {
        // Arrange        physics.affectedByGravity = false;

        // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert
        expect(physics.acceleration.y, equals(0.0));
      });
    });

    group('T2.1.2: Velocity Integration with Delta Time', () {
      test('should integrate velocity correctly with small delta time', () {
        // Arrange
        physics.applyForce(Vector2(100, 200)); // Apply some force
        final dt = 1 / 60; // 60 FPS        // Act
        physicsSystem.processEntity(testEntity, dt);

        // Assert: Velocity should have been updated based on acceleration and delta time
        expect(physics.velocity.x, greaterThan(0));
        expect(physics.velocity.y, greaterThan(0));
      });

      test('should handle large delta time without instability', () {
        // Arrange
        physics.applyForce(Vector2(100, 200));
        final dt = 1 / 10; // 10 FPS (large delta)        // Act
        physicsSystem.processEntity(testEntity, dt);

        // Assert: Should still be stable
        expect(physics.velocity.x.isFinite, isTrue);
        expect(physics.velocity.y.isFinite, isTrue);
        expect(physics.velocity.x, lessThan(1000)); // Reasonable bounds
        expect(physics.velocity.y, lessThan(1000));
      });
      test('should apply position changes based on velocity and delta time',
          () {
        // Arrange: Disable gravity for this test to isolate velocity effects
        physics.affectedByGravity = false;
        physics.setVelocity(Vector2(100, 50));
        final dt = 1 / 60;
        final initialPosition = testEntity.position.clone(); // Act
        physicsSystem.processEntity(testEntity, dt);

        // Assert: Position should have changed
        expect(testEntity.position.x, greaterThan(initialPosition.x));
        expect(testEntity.position.y, greaterThan(initialPosition.y));

        // Check exact position change
        final expectedDeltaX = 100 * dt;
        final expectedDeltaY = 50 * dt;
        expect(
          testEntity.position.x - initialPosition.x,
          closeTo(expectedDeltaX, 0.1),
        );
        expect(
          testEntity.position.y - initialPosition.y,
          closeTo(expectedDeltaY, 0.1),
        );
      });
    });

    group('T2.1.3: Terminal Velocity Constraints', () {
      test('should limit falling velocity to terminal velocity', () {
        // Arrange: Set very high downward velocity
        physics.setVelocity(
          Vector2(0, PhysicsConstants.terminalVelocity + 100),
        ); // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert: Should be clamped to terminal velocity
        expect(physics.velocity.y, equals(PhysicsConstants.terminalVelocity));
      });

      test('should limit upward velocity to prevent excessive jumping', () {
        // Arrange: Set very high upward velocity
        physics
            .setVelocity(Vector2(0, -PhysicsConstants.terminalVelocity - 100));

        // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert: Should be clamped
        expect(physics.velocity.y, equals(-PhysicsConstants.terminalVelocity));
      });

      test('should limit horizontal velocity to maximum horizontal speed', () {
        // Arrange: Set very high horizontal velocity
        physics
            .setVelocity(Vector2(PhysicsConstants.maxHorizontalSpeed + 100, 0));

        // Act
        physicsSystem.processEntity(
          testEntity,
          1 / 60,
        ); // Assert: Should be clamped
        expect(
          physics.velocity.x,
          closeTo(PhysicsConstants.maxHorizontalSpeed, 0.2),
        );
      });

      test('should preserve velocity direction when clamping', () {
        // Arrange: Set high negative horizontal velocity
        physics.setVelocity(
          Vector2(-PhysicsConstants.maxHorizontalSpeed - 100, 0),
        );

        // Act
        physicsSystem.processEntity(
          testEntity,
          1 / 60,
        ); // Assert: Should be clamped but maintain negative direction
        expect(
          physics.velocity.x,
          closeTo(-PhysicsConstants.maxHorizontalSpeed, 0.2),
        );
      });
    });

    group('T2.1.4: Horizontal Friction and Air Resistance', () {
      test('should apply ground friction when on ground', () {
        // Arrange
        physics.setVelocity(Vector2(100, 0));
        physics.setOnGround(true);
        final initialVelocityX = physics.velocity.x;

        // Act
        physicsSystem.processEntity(
          testEntity,
          1 / 60,
        ); // Assert: Horizontal velocity should be reduced by ground friction
        expect(physics.velocity.x, lessThan(initialVelocityX));
        // Ground friction in constants is 0.85, so 85% of velocity is retained
        expect(
          physics.velocity.x,
          closeTo(initialVelocityX * PhysicsConstants.groundFriction, 0.1),
        );
      });

      test('should apply air resistance when in air', () {
        // Arrange
        physics.setVelocity(Vector2(100, 0));
        physics.setOnGround(false);
        final initialVelocityX = physics.velocity.x;

        // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert: Horizontal velocity should be reduced by air resistance
        expect(physics.velocity.x, lessThan(initialVelocityX));
      });

      test('should apply stronger friction on ground than in air', () {
        // Test ground friction
        physics.setVelocity(Vector2(100, 0));
        physics.setOnGround(true);
        physicsSystem.processEntity(testEntity, 1 / 60);
        final groundVelocity = physics.velocity.x;

        // Reset and test air resistance
        physics.setVelocity(Vector2(100, 0));
        physics.setOnGround(false);
        physicsSystem.processEntity(testEntity, 1 / 60);
        final airVelocity = physics.velocity.x;

        // Assert: Ground friction should be stronger
        expect(groundVelocity, lessThan(airVelocity));
      });
    });
    group('T2.1.5: Physics Simulation Testing with Player', () {
      late Player player;

      setUp(() async {
        player = Player(
          position: Vector2(100, 50),
          size: Vector2(32, 48),
        );
        await player.onLoad(); // Ensure components are initialized

        physicsSystem.addEntity(player);
      });
      test('should simulate realistic falling behavior', () {
        // Arrange: Player starts above platform
        player.position = Vector2(100, 0);
        player.physics!.setVelocity(Vector2(0, 0));

        // Act: Simulate multiple physics steps
        for (int i = 0; i < 10; i++) {
          physicsSystem.processSystem(1 / 60);
        }

        // Assert: Player should be falling
        expect(player.physics!.velocity.y, greaterThan(0));
        expect(player.position.y, greaterThan(0));
      });

      test('should handle jump mechanics properly', () {
        // Arrange: Player starts with jump impulse
        player.position = Vector2(100, 68);
        player.physics!.setVelocity(Vector2(0, 0));
        player.physics!.setOnGround(true);

        // Act: Apply jump force
        player.physics!
            .applyImpulse(Vector2(0, PhysicsConstants.playerJumpVelocity));

        // Process physics
        physicsSystem.processSystem(1 / 60);

        // Assert: Player should have upward velocity
        expect(player.physics!.velocity.y, lessThan(0));
      });

      test('should handle horizontal movement with physics', () {
        // Arrange
        player.position = Vector2(100, 68);
        player.physics!
            .setVelocity(Vector2(PhysicsConstants.playerWalkSpeed, 0));

        final initialX = player.position.x;

        // Act: Process physics for one frame
        physicsSystem.processSystem(1 / 60);

        // Assert: Player should move horizontally
        expect(player.position.x, greaterThan(initialX));
      });
    });

    group('T2.1.6: Performance Monitoring', () {
      test('should track frame times for performance monitoring', () {
        // Act: Process physics multiple times
        for (int i = 0; i < 10; i++) {
          physicsSystem.processEntity(testEntity, 1 / 60);
        }

        // Assert: Should have performance data
        expect(physicsSystem.averageFrameTime, greaterThanOrEqualTo(0));
        expect(physicsSystem.getPerformanceStatus(), isNotEmpty);
      });

      test('should provide performance status', () {
        // Act
        physicsSystem.processEntity(testEntity, 1 / 60);

        // Assert
        final status = physicsSystem.getPerformanceStatus();
        expect(
          ['No data', 'Optimal', 'Good', 'Fair', 'Poor'],
          contains(status),
        );
      });

      test('should identify optimal performance', () {
        // Act: Process a few frames
        for (int i = 0; i < 5; i++) {
          physicsSystem.processEntity(testEntity, 1 / 60);
        }

        // Assert: Should be optimal for simple physics
        expect(physicsSystem.isPerformanceOptimal, isTrue);
      });
    });

    group('Integration Tests', () {
      test('should handle multiple entities with different physics properties',
          () {
        // Arrange: Create entities with different properties
        final heavyEntity = TestEntity(
          id: 'heavy',
          type: 'heavy',
          position: Vector2(0, 0),
          size: Vector2(64, 64),
        );
        heavyEntity.physics = PhysicsComponent(
          mass: 10.0,
          affectedByGravity: true,
        );
        heavyEntity.add(heavyEntity.physics!);

        final lightEntity = TestEntity(
          id: 'light',
          type: 'light',
          position: Vector2(100, 0),
          size: Vector2(16, 16),
        );
        lightEntity.physics = PhysicsComponent(
          mass: 0.1,
          affectedByGravity: true,
        );
        lightEntity.add(lightEntity.physics!);

        physicsSystem.addEntity(heavyEntity);
        physicsSystem.addEntity(lightEntity); // Act: Process physics
        physicsSystem.processSystem(1 / 60);

        // Assert: Both should have physics applied (check velocity instead of acceleration)
        expect(heavyEntity.physics!.velocity.y, greaterThan(0));
        expect(lightEntity.physics!.velocity.y, greaterThan(0));

        // Both entities should have the same velocity change due to gravity
        // (F = ma, but a = F/m, so same gravity force results in same acceleration)
        expect(
          heavyEntity.physics!.velocity.y,
          closeTo(lightEntity.physics!.velocity.y, 0.1),
        );
      });

      test('should maintain consistent physics across multiple frames', () {
        // Arrange
        physics.setVelocity(Vector2(50, -100));
        final List<double> velocities = [];

        // Act: Record velocities over multiple frames
        for (int i = 0; i < 60; i++) {
          // 1 second at 60 FPS
          physicsSystem.processEntity(testEntity, 1 / 60);
          velocities.add(physics.velocity.y);
        }

        // Assert: Physics should be consistent and predictable
        expect(velocities.length, equals(60));
        expect(velocities.first, lessThan(0)); // Should start moving up
        expect(
          velocities.last,
          greaterThan(
            0,
          ),
        ); // Should end moving down due to gravity        // Check for smooth transition (no sudden jumps)
        for (int i = 1; i < velocities.length; i++) {
          final diff = (velocities[i] - velocities[i - 1]).abs();
          expect(
            diff,
            lessThan(
              100,
            ),
          ); // Allow for larger changes due to gravity accumulation
        }
      });
    });
  });
}

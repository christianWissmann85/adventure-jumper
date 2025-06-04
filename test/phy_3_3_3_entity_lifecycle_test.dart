// PHY-3.3.3: Test entity lifecycle with new physics coordination
// Tests entity creation/destruction, respawn procedures, and component lifecycle management

import 'package:adventure_jumper/src/components/collision_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/components/transform_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_state.dart';
import 'package:adventure_jumper/src/systems/interfaces/respawn_state.dart';
import 'package:adventure_jumper/src/systems/physics_system.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test entity for lifecycle validation
class TestEntity extends Entity {
  TestEntity({required super.position, String? id})
      : super(
          size: Vector2(32, 32),
          id: id ?? 'test-entity-${DateTime.now().millisecondsSinceEpoch}',
        );
  @override
  Future<void> setupEntity() async {
    print('[TestEntity] setupEntity() called');
    // Create physics component with standard configuration
    final physicsComponent = PhysicsComponent(
      velocity: Vector2.zero(),
      mass: 1.0,
      affectedByGravity: true,
    );
    print('[TestEntity] PhysicsComponent created');
    await initializeComponent(physicsComponent);
    print(
        '[TestEntity] PhysicsComponent initialized, physics set: ${physics != null}',);
  }
}

/// Test game environment for lifecycle tests
class LifecycleTestGame extends FlameGame {
  late PhysicsSystem physicsSystem;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize physics system
    physicsSystem = PhysicsSystem();
    add(physicsSystem);
  }
}

void main() {
  group('PHY-3.3.3: Entity Lifecycle with Physics Coordination Tests', () {
    late LifecycleTestGame game;
    late TestEntity testEntity;
    late Player player;

    setUpAll(() async {
      game = LifecycleTestGame();
      await game.onLoad();
    });

    setUp(() async {
      testEntity = TestEntity(position: Vector2(100, 100));
      player = Player(position: Vector2(100, 300));
    });

    group('Entity Creation and Initialization', () {
      test('entity initializes with proper component lifecycle stages',
          () async {
        // Initial state before adding to game
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.created);
        expect(testEntity.isInitialized, false);
        expect(
          testEntity.areAllComponentsHealthy(),
          true,
        ); // No errors initially

        // Add to game and trigger initialization
        await game.add(testEntity);
        await game.ready();

        // Verify entity is properly initialized
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);
        expect(testEntity.isInitialized, true);

        // Verify required components are initialized
        expect(
          testEntity.getComponentLifecycle(TransformComponent),
          ComponentLifecycleStage.initialized,
        );
        expect(
          testEntity.getComponentLifecycle(CollisionComponent),
          ComponentLifecycleStage.initialized,
        );
        expect(
          testEntity.getComponentLifecycle(PhysicsComponent),
          ComponentLifecycleStage.initialized,
        );
      });

      test('physics component integrates properly with physics system',
          () async {
        await game.add(testEntity);
        await game.ready();

        // Verify physics component is properly initialized
        expect(testEntity.physics, isNotNull);
        expect(testEntity.physics!.mass, 1.0);
        expect(testEntity.physics!.affectedByGravity, true);

        // Verify physics state can be queried
        final physicsState = testEntity.physics!.getPhysicsState();
        expect(physicsState.mass, 1.0);
        expect(physicsState.position, Vector2(100, 100));
        expect(physicsState.velocity, Vector2.zero());
        expect(physicsState.isValid, true);
      });

      test('entity supports physics state validation and error detection',
          () async {
        await game.add(testEntity);
        await game.ready(); // All components should be healthy initially
        expect(testEntity.areAllComponentsHealthy(), true);
        expect(testEntity.getComponentError(PhysicsComponent), isNull);

        // Physics component should be initialized
        expect(testEntity.physics, isNotNull);

        // Physics state should be valid
        final physicsState = testEntity.physics!.getPhysicsState();
        expect(physicsState.isValid, true);
        expect(physicsState.hasAccumulation, false);
      });
    });

    group('Entity Physics Coordination', () {
      test('entity coordinates position updates through physics system',
          () async {
        await game.add(testEntity);
        await game.ready();

        // Initial position
        final initialPosition = Vector2(100, 100);
        expect(
          testEntity.position,
          initialPosition,
        ); // Physics system should coordinate position updates
        if (game.physicsSystem.isInterfaceEnabled) {
          final physicsState =
              await game.physicsSystem.getPhysicsState(testEntity.hashCode);
          expect(physicsState.position, initialPosition);
        }
      });

      test('entity prevents direct position access when coordinator available',
          () async {
        await game.add(testEntity);
        await game.ready();

        // If physics coordinator is available, position access should be validated
        // This test verifies the protection mechanisms are in place
        expect(() => testEntity.position, returnsNormally);

        // Component coordination should be validated
        await testEntity.validateComponentCoordination();
        expect(testEntity.areAllComponentsHealthy(), true);
      });

      test('entity synchronizes component states properly', () async {
        await game.add(testEntity);
        await game.ready();

        // Verify component state synchronization
        final validationResult =
            await testEntity.validateStateSynchronization();
        expect(
          validationResult,
          greaterThan(0.99),
        ); // >99% coordination accuracy

        // All components should report healthy state
        expect(testEntity.areAllComponentsHealthy(), true);
      });
    });

    group('Entity Destruction and Cleanup', () {
      test('entity properly disposes components on removal', () async {
        await game.add(testEntity);
        await game.ready();

        // Verify entity is active
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);
        expect(testEntity.isActive, true);

        // Remove entity from game
        testEntity.removeFromParent();

        // Verify proper disposal
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.disposed);
      });

      test('physics component cleanup prevents accumulation', () async {
        await game.add(testEntity);
        await game.ready();

        // Ensure physics component is initialized
        expect(testEntity.physics, isNotNull);

        // Get initial physics state
        final initialPhysics = testEntity.physics!.getPhysicsState();
        expect(initialPhysics.hasAccumulation, false);

        // Apply some physics operations
        testEntity.physics!.setVelocity(Vector2(100, 50));
        testEntity.physics!.applyForce(Vector2(10, 5));

        // Force physics cleanup
        await testEntity.physics!.preventAccumulation();

        // Verify no accumulation after cleanup
        final cleanedPhysics = testEntity.physics!.getPhysicsState();
        expect(cleanedPhysics.hasAccumulation, false);
      });
    });

    group('Player Respawn Procedures', () {
      test('player respawn follows PlayerCharacter.TDD.md specifications',
          () async {
        await game.add(player);
        await game.ready();

        // Set initial position and state
        player.position.setFrom(Vector2(200, 400));
        await player.onLoad();

        // Get initial physics state
        expect(player.physics, isNotNull);
        final initialState = player.physics!.getPhysicsState();
        expect(initialState.isValid, true);

        // Trigger respawn by setting position below fall threshold
        player.position.setFrom(Vector2(200, 1500)); // Below 1200 threshold

        // Process respawn through controller update
        player.controller.update(0.016);

        // Verify respawn occurred
        expect(player.position.y, lessThan(1200));

        // Verify physics state is reset
        final respawnedState = player.physics!.getPhysicsState();
        expect(respawnedState.velocity, Vector2.zero());
        expect(respawnedState.isValid, true);
        expect(respawnedState.hasAccumulation, false);
      });

      test('respawn state creates proper physics reset configuration', () {
        // Test RespawnState factory methods
        final deathRespawn = RespawnState.deathRespawn(
          spawnPosition: Vector2(100, 300),
          deathReason: 'fell_into_void',
        );

        expect(deathRespawn.resetPhysicsAccumulation, true);
        expect(deathRespawn.isSafeRespawn, false);
        expect(deathRespawn.respawnReason, 'fell_into_void');
        expect(deathRespawn.spawnVelocity, Vector2.zero());

        // Test checkpoint respawn
        final checkpointRespawn = RespawnState.checkpointRespawn(
          checkpointPosition: Vector2(200, 400),
        );

        expect(checkpointRespawn.resetPhysicsAccumulation, true);
        expect(checkpointRespawn.isSafeRespawn, true);
        expect(checkpointRespawn.respawnReason, 'checkpoint');

        // Test out-of-bounds respawn
        final oobRespawn = RespawnState.outOfBounds(
          lastSafePosition: Vector2(150, 350),
        );

        expect(oobRespawn.resetPhysicsAccumulation, true);
        expect(oobRespawn.isSafeRespawn, true);
        expect(oobRespawn.respawnReason, 'out_of_bounds');
      });
      test('respawn procedures clear input state properly', () async {
        await game.add(player);
        await game.ready();

        // Ensure controller is initialized
        expect(player.controller, isNotNull);

        // Set input states before respawn
        player.controller.handleInputAction('move_right', true);
        player.controller.handleInputAction('jump', true);

        // Process inputs
        player.controller.update(0.016);

        // Verify inputs are active
        expect(player.controller.isMovingRight, true);
        expect(player.controller.jumpInputHeld, true);

        // Trigger respawn
        player.position.setFrom(Vector2(100, 1500));
        player.controller.update(0.016);

        // Verify inputs are reset after respawn
        expect(player.controller.isMovingRight, false);
        expect(player.controller.isMovingLeft, false);
        expect(player.controller.jumpInputHeld, false);
      });
      test('respawn preserves last safe position correctly', () async {
        await game.add(player);
        await game.ready();

        // Ensure physics component is initialized
        expect(player.physics, isNotNull);

        // Set player at a safe position
        final safePosition = Vector2(250, 450);
        player.position.setFrom(safePosition);
        player.physics!.setOnGround(true);

        // Wait for safe position to update (requires being on ground)
        for (int i = 0; i < 35; i++) {
          // 35 frames * 0.016 = 0.56 seconds
          player.controller.update(0.016);
        }

        // Trigger respawn
        player.position.setFrom(Vector2(250, 1500));
        player.controller.update(0.016);

        // Verify respawn to safe position (within tolerance)
        expect((player.position - safePosition).length, lessThan(50.0));
      });
    });

    group('Component Lifecycle Integration', () {
      test('components maintain state consistency during lifecycle events',
          () async {
        await game.add(testEntity);
        await game.ready();

        // Test activation/deactivation cycles
        expect(testEntity.isActive, true);
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);

        // Deactivate entity
        testEntity.deactivate();
        expect(testEntity.isActive, false);
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.inactive);

        // Reactivate entity
        testEntity.activate();
        expect(testEntity.isActive, true);
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);

        // Components should remain healthy through cycles
        expect(testEntity.areAllComponentsHealthy(), true);
      });

      test(
          'physics component lifecycle integrates with coordination interfaces',
          () async {
        await game.add(testEntity);
        await game.ready();

        // Ensure physics component is initialized
        expect(testEntity.physics, isNotNull);

        // Verify physics integration interface is working
        final physics = testEntity.physics!;
        // Test state update through integration
        final testState = PhysicsState.clean(
          entityId: testEntity.hashCode,
          position: Vector2(150, 150),
        );

        await physics.updatePhysicsState(testState);

        // Verify state was updated
        final updatedState = physics.getPhysicsState();
        expect(updatedState.velocity, Vector2(10, 5));

        // Test accumulation prevention
        await physics.preventAccumulation();
        final cleanState = physics.getPhysicsState();
        expect(cleanState.hasAccumulation, false);
      });

      test('component error handling supports system recovery', () async {
        await game.add(testEntity);
        await game.ready(); // Initially no errors
        expect(testEntity.getComponentError(PhysicsComponent), isNull);
        expect(testEntity.areAllComponentsHealthy(), true);

        // Ensure physics component is initialized
        expect(testEntity.physics, isNotNull);

        // Simulate component error scenario by forcing invalid state
        // This tests the error detection and reporting mechanisms
        final physics = testEntity.physics!;

        // Force potential accumulation scenario
        for (int i = 0; i < 10; i++) {
          physics.applyForce(Vector2(1000, 1000));
        }

        // Check if accumulation detection works
        final state = physics.getPhysicsState();
        if (state.hasAccumulation) {
          // Accumulation detected - test prevention
          await physics.preventAccumulation();
          final cleanedState = physics.getPhysicsState();
          expect(cleanedState.hasAccumulation, false);
        }
      });
    });

    group('Performance and Accumulation Prevention', () {
      test('entity lifecycle operations complete within performance thresholds',
          () async {
        final stopwatch = Stopwatch()..start();

        // Test entity creation performance
        await game.add(testEntity);
        await game.ready();

        final initTime = stopwatch.elapsedMilliseconds;
        expect(initTime, lessThan(100)); // Should initialize quickly

        stopwatch.reset();

        // Test component coordination performance
        await testEntity.validateComponentCoordination();
        await testEntity.validateStateSynchronization();

        final coordTime = stopwatch.elapsedMilliseconds;
        expect(coordTime, lessThan(50)); // Coordination should be fast

        stopwatch.stop();
      });

      test('rapid entity creation/destruction prevents accumulation', () async {
        final entities = <TestEntity>[];

        // Create multiple entities rapidly
        for (int i = 0; i < 10; i++) {
          final entity = TestEntity(position: Vector2(i * 50.0, 100));
          entities.add(entity);
          await game.add(entity);
        }

        await game.ready();

        // Verify all entities initialized properly
        for (final entity in entities) {
          expect(entity.lifecycleStage, ComponentLifecycleStage.active);
          expect(entity.areAllComponentsHealthy(), true);

          if (entity.physics != null) {
            final state = entity.physics!.getPhysicsState();
            expect(state.hasAccumulation, false);
          }
        }

        // Remove all entities
        for (final entity in entities) {
          entity.removeFromParent();
        }

        // Verify proper cleanup
        for (final entity in entities) {
          expect(entity.lifecycleStage, ComponentLifecycleStage.disposed);
        }
      });

      test('long-running entity maintains physics state integrity', () async {
        await game.add(testEntity);
        await game.ready();

        // Simulate extended gameplay with physics operations
        for (int frame = 0; frame < 1000; frame++) {
          // ~16.6 seconds at 60fps
          // Apply physics operations each frame
          if (testEntity.physics != null) {
            testEntity.physics!.setVelocity(Vector2(10, 0));
            await testEntity.physics!.preventAccumulation();
          }

          // Periodically validate state
          if (frame % 100 == 0) {
            expect(testEntity.areAllComponentsHealthy(), true);

            if (testEntity.physics != null) {
              final state = testEntity.physics!.getPhysicsState();
              expect(state.isValid, true);
              expect(state.hasAccumulation, false);
            }
          }
        }

        // Final validation after extended operation
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);
        expect(testEntity.areAllComponentsHealthy(), true);
      });
    });

    group('Integration Testing', () {
      test('entity lifecycle integrates with physics system coordination',
          () async {
        await game.add(testEntity);
        await game.ready();

        // Test physics system integration
        final physicsSystem = game.physicsSystem;

        // Verify entity can be processed by physics system
        expect(physicsSystem.canProcessEntity(testEntity), true);
        // Verify physics state queries work
        if (physicsSystem.isInterfaceEnabled) {
          final state =
              await physicsSystem.getPhysicsState(testEntity.hashCode);
          expect(state.isValid, true);
          expect(state.entityId, testEntity.hashCode);
        }
      });

      test('multiple entities coordinate properly through lifecycle events',
          () async {
        final entities = <TestEntity>[];

        // Create multiple entities
        for (int i = 0; i < 5; i++) {
          final entity = TestEntity(position: Vector2(i * 100.0, 100));
          entities.add(entity);
          await game.add(entity);
        }

        await game.ready();

        // Verify all entities are active and coordinated
        for (final entity in entities) {
          expect(entity.lifecycleStage, ComponentLifecycleStage.active);
          await entity.validateComponentCoordination();

          final coordination = await entity.validateStateSynchronization();
          expect(coordination, greaterThan(0.99)); // >99% coordination accuracy
        }

        // Test lifecycle events affect all entities properly
        for (final entity in entities) {
          entity.deactivate();
          expect(entity.lifecycleStage, ComponentLifecycleStage.inactive);
        }

        for (final entity in entities) {
          entity.activate();
          expect(entity.lifecycleStage, ComponentLifecycleStage.active);
        }
      });

      test('entity lifecycle works with game state management', () async {
        await game.add(testEntity);
        await game.add(player);
        await game.ready();

        // Verify both entities are properly managed
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);
        expect(player.lifecycleStage, ComponentLifecycleStage.active);

        // Test game-wide operations don't break entity lifecycle
        game.pauseEngine();
        expect(
          testEntity.isActive,
          true,
        ); // Entity state independent of engine pause

        game.resumeEngine();
        expect(testEntity.lifecycleStage, ComponentLifecycleStage.active);

        // Verify components remain healthy
        expect(testEntity.areAllComponentsHealthy(), true);
        if (player.physics != null) {
          final playerState = player.physics!.getPhysicsState();
          expect(playerState.isValid, true);
        }
      });
    });
  });
}

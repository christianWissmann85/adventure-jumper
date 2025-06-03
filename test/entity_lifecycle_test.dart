import 'package:adventure_jumper/src/components/collision_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/components/transform_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

// Test entity implementation
class TestEntity extends Entity {
  TestEntity({required super.position})
      : super(size: Vector2(32, 32), id: 'test-entity');

  @override
  Future<void> setupEntity() async {
    // Add physics component for testing
    final physicsComponent = PhysicsComponent(
      velocity: Vector2.zero(),
      mass: 1.0,
      affectedByGravity: true,
    );
    // Use protected method to properly initialize component with lifecycle tracking
    await initializeComponent(physicsComponent);
  }
  
}

void main() {
  group('Entity Lifecycle Management Tests', () {
    late FlameGame game;
    late TestEntity entity;

    setUp(() {
      game = FlameGame();
      entity = TestEntity(position: Vector2(100, 100));
    });

    test('Entity initializes with correct lifecycle stages', () async {
      // Initial state
      expect(entity.lifecycleStage, ComponentLifecycleStage.created);
      expect(entity.isInitialized, false);

      // Add to game to trigger onLoad
      await game.add(entity);
      await game.ready();

      // After initialization
      expect(entity.lifecycleStage, ComponentLifecycleStage.active);
      expect(entity.isInitialized, true);
    });

    test('Entity tracks component lifecycle stages', () async {
      await game.add(entity);
      await game.ready();

      // Check required components are tracked
      expect(entity.getComponentLifecycle(TransformComponent),
          ComponentLifecycleStage.initialized,);
      expect(entity.getComponentLifecycle(CollisionComponent),
          ComponentLifecycleStage.initialized,);
      expect(
          entity.getComponentLifecycle(PhysicsComponent),
          ComponentLifecycleStage.initialized,);
    });

    test('Entity activation and deactivation affects all components', () async {
      await game.add(entity);
      await game.ready();

      // Initially active
      expect(entity.isActive, true);
      expect(entity.lifecycleStage, ComponentLifecycleStage.active);

      // Deactivate
      entity.deactivate();
      expect(entity.isActive, false);
      expect(entity.lifecycleStage, ComponentLifecycleStage.inactive);

      // Reactivate
      entity.activate();
      expect(entity.isActive, true);
      expect(entity.lifecycleStage, ComponentLifecycleStage.active);
    });

    test('Entity reports component health correctly', () async {
      await game.add(entity);
      await game.ready();

      // All components should be healthy after successful initialization
      expect(entity.areAllComponentsHealthy(), true);
    });

    test('Entity disposes components properly on removal', () async {
      await game.add(entity);
      await game.ready();

      // Remove entity
      entity.removeFromParent();
      
      // Check lifecycle stage after removal
      expect(entity.lifecycleStage, ComponentLifecycleStage.disposed);
    });

    test('Entity handles physics component coordination', () async {
      await game.add(entity);
      await game.ready();

      // Physics component should be initialized
      expect(entity.physics, isNotNull);
      expect(entity.physics!.mass, 1.0);
      expect(entity.physics!.affectedByGravity, true);
      
      // Physics state should be accessible
      final physicsState = entity.physics!.getPhysicsState();
      expect(physicsState.mass, 1.0);
      expect(physicsState.position, Vector2(100, 100));
    });
  });
}
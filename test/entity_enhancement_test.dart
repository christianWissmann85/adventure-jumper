import 'package:adventure_jumper/src/components/collision_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

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
    await initializeComponent(physicsComponent);
  }
}

void main() {
  group('Entity Enhancement Tests', () {
    test('Entity has lifecycle management properties', () {
      final entity = TestEntity(position: Vector2(100, 100));
      
      // Check initial state
      expect(entity.lifecycleStage, ComponentLifecycleStage.created);
      expect(entity.isInitialized, false);
      expect(entity.isActive, true);
    });

    testWithFlameGame('Entity tracks component lifecycle', (game) async {
      final entity = TestEntity(position: Vector2(100, 100));
      await game.add(entity);
      await game.ready();
      
      // Entity should be initialized after adding to game
      expect(entity.isInitialized, true);
      
      // Check component lifecycle tracking
      expect(entity.getComponentLifecycle(CollisionComponent), isNotNull);
    });

    test('Entity can report component health', () {
      final entity = TestEntity(position: Vector2(100, 100));
      
      // Initially should report healthy (no errors)
      expect(entity.areAllComponentsHealthy(), true);
    });

    test('Entity activation/deactivation methods work', () {
      final entity = TestEntity(position: Vector2(100, 100));
      
      // Initially active
      expect(entity.isActive, true);
      
      // Deactivate
      entity.deactivate();
      expect(entity.isActive, false);
      
      // Reactivate
      entity.activate();
      expect(entity.isActive, true);
    });

    testWithFlameGame('Entity initializes physics component', (game) async {
      final entity = TestEntity(position: Vector2(100, 100));
      await game.add(entity);
      await game.ready();
      
      // Physics component should be initialized
      expect(entity.physics, isNotNull);
      expect(entity.physics!.mass, 1.0);
      
      // Should be able to get physics state
      final physicsState = entity.physics!.getPhysicsState();
      expect(physicsState.mass, 1.0);
      expect(physicsState.position, Vector2(100, 100));
    });

    test('Entity provides component error tracking', () {
      final entity = TestEntity(position: Vector2(100, 100));
      
      // Should be able to check for component errors
      final error = entity.getComponentError(PhysicsComponent);
      expect(error, isNull); // No errors initially
    });
  });
}
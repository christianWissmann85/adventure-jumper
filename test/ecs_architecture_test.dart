import 'package:adventure_jumper/src/components/health_component.dart';
import 'package:adventure_jumper/src/components/input_component.dart';
import 'package:adventure_jumper/src/components/physics_component.dart';
import 'package:adventure_jumper/src/entities/entity.dart';
import 'package:adventure_jumper/src/player/player.dart';
import 'package:adventure_jumper/src/systems/base_system.dart';
import 'package:adventure_jumper/src/systems/input_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ECS Architecture Tests', () {
    group('Entity Tests', () {
      test('should create player with required components', () async {
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        expect(player.transformComponent, isNotNull);
        expect(player.collision, isNotNull);
        expect(player.isActive, isTrue);
        expect(player.type, equals('player'));
      });

      test('should allow entity activation and deactivation', () async {
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        expect(player.isActive, isTrue);

        player.deactivate();
        expect(player.isActive, isFalse);

        player.activate();
        expect(player.isActive, isTrue);
      });
      test('should create entity with consistent ID', () async {
        final player1 = Player(position: Vector2.zero());
        final player2 = Player(position: Vector2.zero());
        await player1.onLoad();
        await player2.onLoad();

        expect(player1.id, isNotEmpty);
        expect(player2.id, isNotEmpty);
        expect(player1.id, equals('player'));
        expect(player2.id, equals('player'));
      });
    });
    group('Component Tests', () {
      test('should create physics component with default values', () {
        final physics = PhysicsComponent();

        expect(physics.velocity, equals(Vector2.zero()));
        expect(physics.acceleration, equals(Vector2.zero()));
        expect(physics.mass, equals(1.0));
        expect(physics.friction, equals(0.1));
      });

      test('should create health component with valid values', () {
        final health = HealthComponent(maxHealth: 100.0);

        expect(health.maxHealth, equals(100.0));
        expect(health.currentHealth, equals(100.0));
        expect(health.isInvulnerable, isFalse);
        expect(health.isDead, isFalse);
      });

      test('should create input component with default settings', () {
        final input = InputComponent();

        expect(input.inputMode, isNotNull);
        expect(input.inputSource, isNotNull);
        expect(input.bufferingMode, isNotNull);
      });
    });

    group('System Tests', () {
      test('should implement system interface correctly', () {
        final system = TestSystem();

        expect(system.isActive, isTrue);
        expect(system.priority, equals(0));
        expect(system.entities, isEmpty);
        expect(system.entityCount, equals(0));
      });

      test('should add and remove entities correctly', () async {
        final system = TestSystem();
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        system.addEntity(player);
        expect(system.entityCount, equals(1));
        expect(system.entities, contains(player));

        system.removeEntity(player);
        expect(system.entityCount, equals(0));
        expect(system.entities, isEmpty);
      });

      test('should not add duplicate entities', () async {
        final system = TestSystem();
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        system.addEntity(player);
        system.addEntity(player); // Try to add again

        expect(system.entityCount, equals(1));
      });

      test('should process active entities only', () async {
        final system = TestSystem();
        final player1 = Player(position: Vector2.zero());
        final player2 = Player(position: Vector2.zero());
        await player1.onLoad();
        await player2.onLoad();

        player2.deactivate(); // Deactivate second player

        system.addEntity(player1);
        system.addEntity(player2);

        system.update(0.016); // Simulate 60 FPS

        expect(system.processedEntities, equals(1));
      });

      test('should respect system active state', () async {
        final system = TestSystem();
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        system.addEntity(player);
        system.isActive = false;

        system.update(0.016);

        expect(system.processedEntities, equals(0));
      });
    });
    group('System Integration Tests', () {
      test('should handle entity lifecycle properly', () async {
        final inputSystem = InputSystem();
        final player = Player(position: Vector2.zero());
        await player.onLoad();

        // Test entity registration
        inputSystem.setFocusedEntity(player);
        expect(inputSystem.focusedEntity, equals(player));

        // Test system update
        inputSystem.update(0.016);

        // Test entity removal
        inputSystem.removeEntity(player);
        expect(inputSystem.focusedEntity, isNull);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple entities efficiently', () async {
        final system = TestSystem();
        final entities = <Player>[];

        // Create 100 entities
        for (int i = 0; i < 100; i++) {
          final player = Player(position: Vector2(i.toDouble(), 0));
          await player.onLoad();
          entities.add(player);
          system.addEntity(player);
        }

        expect(system.entityCount, equals(100));

        final stopwatch = Stopwatch()..start();
        system.update(0.016);
        stopwatch.stop();

        // Should process quickly (less than 10ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
        expect(system.processedEntities, equals(100));
      });
    });
  });
}

/// Test system implementation for testing purposes
class TestSystem extends BaseSystem {
  int processedEntities = 0;

  @override
  bool canProcessEntity(Entity entity) => true;

  @override
  void processEntity(Entity entity, double dt) {
    processedEntities++;
  }

  @override
  void initialize() {
    // Empty implementation
  }

  @override
  void dispose() {
    super.dispose();
    processedEntities = 0;
  }

  @override
  void update(double dt) {
    processedEntities = 0; // Reset counter
    super.update(dt);
  }
}

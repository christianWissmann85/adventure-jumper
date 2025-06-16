import 'package:adventure_jumper/src/components/collision_component.dart';
import 'package:adventure_jumper/src/systems/interfaces/physics_state.dart'
    as ps;
import 'package:adventure_jumper/src/utils/logger.dart'; // For GameLogger, if needed directly in tests
import 'package:flame/components.dart';
import 'package:test/test.dart';

// Mock/Dummy classes for testing
// These would ideally be more robust or come from a testing utility library
class MockParentEntity extends PositionComponent {
  MockParentEntity({Vector2? size}) : super(size: size ?? Vector2(32, 32));
  // Add any other properties or methods your CollisionComponent might expect from its parent
}

// Mock for PhysicsState from the correct import
class MockPhysicsState implements ps.PhysicsState {
  @override
  int entityId = 1;
  @override
  bool isGrounded = false;
  @override
  List<ps.CollisionInfo> activeCollisions = []; // Use ps.CollisionInfo
  @override
  Vector2 position = Vector2.zero();
  @override
  Vector2 velocity = Vector2.zero();

  // Default implementations for other PhysicsState members
  @override
  Vector2 acceleration = Vector2.zero();
  @override
  bool affectedByGravity = true;
  @override
  Vector2 accumulatedForces = Vector2.zero();
  @override
  int contactPointCount = 0;
  @override
  Map<String, dynamic> debugData = {};
  @override
  double friction = 0.1;
  @override
  double gravityScale = 1.0;
  @override
  DateTime lastUpdateTime = DateTime.now();
  @override
  double mass = 1.0;
  @override
  double restitution = 0.1;
  @override
  bool isStatic = false;
  @override
  int updateCount = 0;
  @override
  bool wasGrounded = false;
  @override
  DateTime snapshotTime = DateTime.now();

  // --- Getters from PhysicsState interface ---
  // These are utility getters for the mock, not necessarily overriding PhysicsState interface members

  @override
  bool get groundedStateChanged => wasGrounded != isGrounded;

  @override
  bool get isFalling => !isGrounded && velocity.y > 0.1; // Simple mock logic

  bool get hasActiveCollision => activeCollisions.any((c) => c.isActive);

  bool get hasWallCollision =>
      activeCollisions.any((c) => c.isActive && c.collisionType == 'wall');

  bool get hasCeilingCollision =>
      activeCollisions.any((c) => c.isActive && c.collisionType == 'ceiling');

  bool get hasGroundCollision =>
      activeCollisions.any((c) => c.isActive && c.collisionType == 'ground');

  @override
  ps.CollisionInfo? get groundCollision {
    try {
      return activeCollisions
          .firstWhere((c) => c.isActive && c.collisionType == 'ground');
    } catch (e) {
      return null;
    }
  }

  @override
  List<ps.CollisionInfo> get wallCollisions => activeCollisions
      .where((c) => c.isActive && c.collisionType == 'wall')
      .toList();

  List<ps.CollisionInfo> get ceilingCollisions => activeCollisions
      .where((c) => c.isActive && c.collisionType == 'ceiling')
      .toList();

  List<ps.CollisionInfo> get otherCollisions => activeCollisions
      .where(
        (c) =>
            c.isActive &&
            c.collisionType != 'wall' &&
            c.collisionType != 'ceiling' &&
            c.collisionType != 'ground',
      )
      .toList();

  @override
  bool get hasAccumulation => accumulatedForces.length2 > 0.001;

  @override
  bool get isValid => true; // Simple mock, always valid

  @override
  bool get isJumping => false;

  @override
  bool get justLanded => false;

  @override
  bool get justLeftGround => false;

  @override
  double get kineticEnergy => 0.0;

  @override
  int get stateAgeMs => 0; // Added to satisfy interface
  // --- End Getters ---

  @override
  bool isMoving([double threshold = 0.1]) =>
      velocity.length2 > threshold * threshold;

  @override
  bool isStale([int thresholdMs = 100]) =>
      DateTime.now().difference(lastUpdateTime).inMilliseconds > thresholdMs;

  @override
  ps.PhysicsState copyWith({
    int? entityId,
    Vector2? position,
    Vector2? velocity,
    Vector2? acceleration,
    double? mass,
    double? gravityScale,
    double? friction,
    double? restitution,
    bool? isStatic,
    bool? affectedByGravity,
    bool? isGrounded,
    bool? wasGrounded,
    List<ps.CollisionInfo>? activeCollisions,
    Vector2? accumulatedForces,
    int? contactPointCount,
    int? updateCount,
    DateTime? lastUpdateTime,
    Map<String, dynamic>? debugData,
  }) {
    throw UnimplementedError('copyWith not implemented in mock');
  }

  void logSummary() {
    // Mock implementation, do nothing or log to a test logger if needed
  }

  void validate() {
    // Mock implementation, do nothing
  }

  @override
  String toString() {
    return 'MockPhysicsState(isGrounded: $isGrounded, activeCollisions: ${activeCollisions.length})';
  }
}

void main() {
  // Initialize GameLogger for testing purposes if necessary
  // GameLogger.initialize(enableConsoleOutput: false); // Example: disable console output for tests

  group('CollisionComponent isEffectivelyGrounded', () {
    late CollisionComponent collisionComponent;
    late MockParentEntity mockParentEntity;
    late MockPhysicsState mockPhysicsState;

    setUp(() {
      try {
        GameLogger.initialize(enableConsoleOutput: false);
      } catch (e) {
        // Ignore if already initialized
      }
      mockParentEntity = MockParentEntity(size: Vector2(32, 32));
      collisionComponent = CollisionComponent(
        hitboxSize: Vector2(10, 10),
        createTestHitbox: false,
      );
      mockParentEntity.add(collisionComponent); // Add component to parent
      collisionComponent.onLoad(); // Manually call onLoad for initialization
      mockPhysicsState = MockPhysicsState();
    });

    test('should be true when actually grounded', () async {
      mockPhysicsState.isGrounded = true;
      await collisionComponent.syncWithPhysics(mockPhysicsState);
      expect(collisionComponent.isEffectivelyGrounded, isTrue);
    });

    test('should be true when airborne but within coyote time', () async {
      final lastGroundedTime = DateTime.now().subtract(
        const Duration(
          milliseconds: 50,
        ),
      ); // 50ms ago, within 150ms coyote time
      mockPhysicsState.isGrounded = false;
      mockPhysicsState.lastUpdateTime = lastGroundedTime;
      await collisionComponent.syncWithPhysics(mockPhysicsState);
      expect(collisionComponent.isEffectivelyGrounded, isTrue);
    });

    test('should be false when airborne and outside coyote time', () async {
      final lastGroundedTime = DateTime.now().subtract(
        const Duration(
          milliseconds: 200,
        ),
      ); // 200ms ago, outside 150ms coyote time
      mockPhysicsState.isGrounded = false;
      mockPhysicsState.lastUpdateTime = lastGroundedTime;
      await collisionComponent.syncWithPhysics(mockPhysicsState);
      expect(collisionComponent.isEffectivelyGrounded, isFalse);
    });

    test('should be false when groundInfo is null (never grounded or reset)',
        () async {
      // Simulate never having been grounded or being airborne for a very long time
      final ancientPhysicsState = MockPhysicsState()
        ..isGrounded = true
        ..lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(0)
            .subtract(const Duration(seconds: 10));
      await collisionComponent
          .syncWithPhysics(ancientPhysicsState); // Grounded anciently

      mockPhysicsState.isGrounded = false; // Now airborne
      await collisionComponent
          .syncWithPhysics(mockPhysicsState); // Explicitly set to null
      expect(collisionComponent.isEffectivelyGrounded, isFalse);
    });

    test('should be true at the exact edge of coyote time (150ms ago)',
        () async {
      final lastGroundedTime =
          DateTime.now().subtract(const Duration(milliseconds: 150));
      mockPhysicsState.isGrounded = false;
      mockPhysicsState.lastUpdateTime = lastGroundedTime;
      await collisionComponent.syncWithPhysics(mockPhysicsState);
      expect(collisionComponent.isEffectivelyGrounded, isTrue);
    });

    test('should be false just after the edge of coyote time (151ms ago)',
        () async {
      // Simulate being grounded recently
      final initialPhysicsState = MockPhysicsState()..isGrounded = true;
      await collisionComponent.syncWithPhysics(initialPhysicsState);
      // Now airborne
      mockPhysicsState.isGrounded = false;
      mockPhysicsState.lastUpdateTime = DateTime.now()
          .subtract(const Duration(milliseconds: 50)); // Ensure time passes
      await collisionComponent.syncWithPhysics(mockPhysicsState);
      expect(collisionComponent.isEffectivelyGrounded, isFalse);
    });
  });

  group('CollisionComponent isMovementBlocked', () {
    late CollisionComponent collisionComponent;
    late MockParentEntity mockParentEntity;
    late MockPhysicsState mockPhysicsState;

    setUp(() {
      try {
        GameLogger.initialize(enableConsoleOutput: false);
      } catch (e) {
        // Ignore if already initialized
      }
      mockParentEntity = MockParentEntity(size: Vector2(32, 32));
      collisionComponent = CollisionComponent(
        hitboxSize: Vector2(10, 10),
        createTestHitbox: false,
      );
      mockParentEntity.add(collisionComponent); // Add component to parent
      collisionComponent.onLoad(); // Manually call onLoad for initialization
      mockPhysicsState = MockPhysicsState();
    });

    void setupCollisions(List<ps.CollisionInfo> collisions) {
      mockPhysicsState.activeCollisions = collisions;
      collisionComponent.syncWithPhysics(mockPhysicsState);
    }

    test('should be true when moving into a wall', () async {
      final wallCollision = ps.CollisionInfo(
        collisionId: 'wall_right',
        collisionType: 'wall', // Use string type as per ps.CollisionInfo
        contactNormal: Vector2(1, 0), // Wall to the right
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([wallCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(-1, 0)),
        isTrue,
        reason: 'Movement left should be blocked by wall on right',
      );
    });

    test('should be true when moving into a ceiling', () async {
      final ceilingCollision = ps.CollisionInfo(
        collisionId: 'ceiling_above',
        collisionType: 'ceiling', // Use string type as per ps.CollisionInfo
        contactNormal: Vector2(0, 1), // Ceiling above (normal points up)
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([ceilingCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(0, -1)),
        isTrue,
        reason: 'Movement up should be blocked by ceiling above',
      );
    });

    test('should be false when moving away from a wall', () async {
      final wallCollision = ps.CollisionInfo(
        collisionId: 'wall_right',
        collisionType: 'wall', // Use string type as per ps.CollisionInfo
        contactNormal: Vector2(1, 0), // Wall to the right
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([wallCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(1, 0)),
        isFalse,
        reason: 'Movement right should not be blocked by wall on right',
      );
    });

    test('should be false for non-blocking collision types like trigger',
        () async {
      final triggerCollision = ps.CollisionInfo(
        collisionId: 'trigger',
        collisionType: 'trigger', // Use string type as per ps.CollisionInfo
        contactNormal: Vector2(1, 0), // Trigger to the right
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([triggerCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(-1, 0)),
        isFalse,
      );
    });

    test('should be false when no active collisions', () async {
      setupCollisions([]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(-1, 0)),
        isFalse,
      );
    });

    test(
        'should be false for blocking types if normal is not opposing movement',
        () async {
      // Wall to the right (normal points +X), movement also to the right (+X)
      final wallCollision = ps.CollisionInfo(
        collisionId: 'wall_right_non_opposing',
        collisionType: 'wall',
        contactNormal: Vector2(1, 0),
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([wallCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(1, 0)),
        isFalse,
      );
    });

    test(
        'should be false for blocking types if dot product is zero (sliding along wall)',
        () async {
      final wallCollision = ps.CollisionInfo(
        collisionId: 'wall_right_sliding',
        collisionType: 'wall',
        contactNormal: Vector2(1, 0), // Wall to the right
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([wallCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(0, 1)),
        isFalse,
      ); // Moving up, parallel to wall face
    });

    test('should consider only wall and ceiling types for blocking', () async {
      final groundCollision = ps.CollisionInfo(
        collisionId: 'ground_below_mixed',
        collisionType: 'ground',
        contactNormal: Vector2(0, 1),
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      final entityCollision = ps.CollisionInfo(
        collisionId: 'entity_right_mixed',
        collisionType: 'entity',
        contactNormal: Vector2(1, 0),
        contactPoint: Vector2.zero(),
        isActive: true,
      );
      setupCollisions([groundCollision, entityCollision]);
      expect(
        await collisionComponent.isMovementBlocked(Vector2(0, -1)),
        isFalse,
        reason: 'Upward movement should not be blocked by ground below (jump)',
      );
      expect(
        await collisionComponent.isMovementBlocked(Vector2(-1, 0)),
        isFalse,
        reason:
            'Movement into an entity should not be considered blocked by this method',
      );
    });
  });
}

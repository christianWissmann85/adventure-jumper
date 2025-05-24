import 'package:flame/components.dart';

import '../components/physics_component.dart';
import '../entities/entity.dart';
import '../entities/platform.dart';
import '../utils/collision_utils.dart';
import 'base_flame_system.dart';

/// System that handles physics simulation and collision resolution
/// Manages gravity, acceleration, velocity, and collision responses
class PhysicsSystem extends BaseFlameSystem {
  PhysicsSystem({
    Vector2? gravity,
    double? timeScale,
    bool? usePixelPerfectCollision,
  }) : super() {
    if (gravity != null) _gravity = gravity;
    if (timeScale != null) _timeScale = timeScale;
    if (usePixelPerfectCollision != null) {
      _usePixelPerfectCollision = usePixelPerfectCollision;
    }
  }

  // Configuration
  double _timeScale = 1;
  Vector2 _gravity = Vector2(0, 800); // Default gravity (pixels/second^2)
  // Will be implemented in Sprint 3 for detailed collision detection
  // ignore: unused_field
  bool _usePixelPerfectCollision = false;

  // Collision processing
  final List<CollisionPair> _collisions = <CollisionPair>[];
  bool _enableCollision = true;
  @override
  void processSystem(double dt) {
    // Apply scaled time
    final double scaledDt = dt * _timeScale;

    // Clear previous collision data
    _collisions.clear();

    // Process collisions if enabled
    if (_enableCollision) {
      detectCollisions();
      resolveCollisions(scaledDt);
    }
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Apply scaled time
    final double scaledDt = dt * _timeScale;

    // Process entity physics
    processEntityPhysics(entity, scaledDt);
  }

  @override
  bool canProcessEntity(Entity entity) {
    // Only process entities with physics components
    return entity.physics != null;
  }

  /// Process physics for a single entity
  void processEntityPhysics(Entity entity, double dt) {
    // Skip entities without required components
    if (entity.physics == null) return;

    final PhysicsComponent physics = entity.physics!;

    // Skip static entities (don't have physics applied)
    if (physics.isStatic) return;

    // Clear ground state (will be set by collision resolution if touching ground)
    physics.setOnGround(false);

    // Apply gravity force (PhysicsComponent handles the actual physics update)
    physics.applyForce(_gravity * physics.mass);
  }

  /// Detect collisions between entities
  void detectCollisions() {
    if (!_enableCollision) return;

    // Simple N^2 collision detection for small entity counts
    // For larger games, this would be optimized with spatial partitioning
    for (int i = 0; i < entities.length; i++) {
      final Entity entityA = entities[i];

      // Skip inactive entities or those without collision component
      if (!entityA.isActive) continue;

      for (int j = i + 1; j < entities.length; j++) {
        final Entity entityB = entities[j];

        // Skip inactive entities or those without collision component
        if (!entityB.isActive) continue;

        // Check if collision is possible
        if (checkEntityCollision(entityA, entityB)) {
          _collisions.add(CollisionPair(entityA, entityB));
        }
      }
    }
  }

  /// Check if two entities are colliding
  bool checkEntityCollision(Entity entityA, Entity entityB) {
    // Get entity positions and sizes for AABB collision detection
    final Vector2 posA = entityA.position;
    final Vector2 sizeA = entityA.size;
    final Vector2 posB = entityB.position;
    final Vector2 sizeB = entityB.size;

    // Use CollisionUtils for AABB collision detection
    return CollisionUtils.aabbCollision(posA, sizeA, posB, sizeB);
  }

  /// Resolve all detected collisions
  void resolveCollisions(double dt) {
    for (final CollisionPair collision in _collisions) {
      // Apply collision resolution
      resolveEntityCollision(collision.entityA, collision.entityB, dt);

      // Notify entities of the collision
      collision.entityA.onCollision(collision.entityB);
      collision.entityB.onCollision(collision.entityA);
    }
  }

  /// Resolve collision between two entities
  void resolveEntityCollision(Entity entityA, Entity entityB, double dt) {
    // Determine which entity is the player and which is the platform
    Entity? player;
    Entity? platform;

    if (entityA.type == 'player' && entityB.type == 'platform') {
      player = entityA;
      platform = entityB;
    } else if (entityA.type == 'platform' && entityB.type == 'player') {
      player = entityB;
      platform = entityA;
    }
    // Handle player-platform collision
    if (player != null && platform != null && player.physics != null) {
      _resolvePlayerPlatformCollision(player, platform);
      return;
    }

    // Handle other collision types (to be implemented in future sprints)
    // For now, we focus on player-platform collision for basic ground mechanics
  }

  /// Resolve collision between player and platform
  void _resolvePlayerPlatformCollision(Entity player, Entity platform) {
    // Calculate overlap on both axes
    final double overlapX = _calculateOverlapX(player, platform);
    final double overlapY = _calculateOverlapY(player, platform);

    // Determine collision direction based on smallest overlap
    if (overlapX.abs() < overlapY.abs()) {
      // Horizontal collision (side collision)
      _resolveHorizontalCollision(player, platform, overlapX);
    } else {
      // Vertical collision (top/bottom collision)
      _resolveVerticalCollision(player, platform, overlapY);
    }
  }

  /// Calculate horizontal overlap between two entities
  double _calculateOverlapX(Entity entityA, Entity entityB) {
    final double leftA = entityA.position.x;
    final double rightA = entityA.position.x + entityA.size.x;
    final double leftB = entityB.position.x;
    final double rightB = entityB.position.x + entityB.size.x;

    if (rightA > leftB && leftA < rightB) {
      // Calculate which side has less overlap
      final double overlapLeft = rightA - leftB;
      final double overlapRight = rightB - leftA;

      return overlapLeft < overlapRight ? -overlapLeft : overlapRight;
    }

    return 0;
  }

  /// Calculate vertical overlap between two entities
  double _calculateOverlapY(Entity entityA, Entity entityB) {
    final double topA = entityA.position.y;
    final double bottomA = entityA.position.y + entityA.size.y;
    final double topB = entityB.position.y;
    final double bottomB = entityB.position.y + entityB.size.y;

    if (bottomA > topB && topA < bottomB) {
      // Calculate which side has less overlap
      final double overlapTop = bottomA - topB;
      final double overlapBottom = bottomB - topA;

      return overlapTop < overlapBottom ? -overlapTop : overlapBottom;
    }

    return 0;
  }

  /// Resolve horizontal collision (side collision with platform)
  void _resolveHorizontalCollision(
      Entity player, Entity platform, double overlapX) {
    final PhysicsComponent physics = player.physics!;

    // Separate the entities
    player.position.x -= overlapX;

    // Stop horizontal velocity
    physics.velocity.x = 0;
  }

  /// Resolve vertical collision (top/bottom collision with platform)
  void _resolveVerticalCollision(
      Entity player, Entity platform, double overlapY) {
    final PhysicsComponent physics = player.physics!;
    final bool isOneWayPlatform = platform is Platform && platform.isOneWay;

    // Handle one-way platforms (can jump through from below)
    if (isOneWayPlatform && overlapY > 0 && physics.velocity.y < 0) {
      // Player is hitting platform from below, allow passing through
      return;
    }

    // Don't allow landing on one-way platforms when falling fast
    // This simulates "breaking through" thin platforms when falling at high speed
    if (isOneWayPlatform && physics.velocity.y > 600) {
      return;
    }

    // Separate the entities
    player.position.y -= overlapY;

    // Handle landing on platform (player on top)
    if (overlapY < 0 && physics.velocity.y > 0) {
      // Player is landing on top of platform
      physics.velocity.y = 0;
      physics.setOnGround(true);
    }
    // Handle hitting platform from below (head collision)
    else if (overlapY > 0 && physics.velocity.y < 0) {
      // Player hit platform from below
      physics.velocity.y = 0;
    }
  }

  /// Set gravity force
  void setGravity(Vector2 gravity) {
    _gravity = gravity;
  }

  /// Enable/disable collision detection and resolution
  void setCollisionEnabled(bool enabled) {
    _enableCollision = enabled;
  }

  @override
  void clearEntities() {
    super.clearEntities();
    _collisions.clear();
  }

  // Getters
  Vector2 get gravity => _gravity;
  bool get collisionEnabled => _enableCollision;
  double get timeScale => _timeScale;

  @override
  void initialize() {
    // Initialize physics system
  }
}

/// Helper class to store colliding entity pairs
class CollisionPair {
  CollisionPair(this.entityA, this.entityB);
  final Entity entityA;
  final Entity entityB;
}

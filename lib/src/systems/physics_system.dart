import 'dart:math';

import 'package:flame/components.dart';

import '../components/collision_component.dart';
import '../components/physics_component.dart';
import '../entities/entity.dart';
import '../entities/platform.dart';
import '../utils/collision_utils.dart';
import '../utils/constants.dart';
import '../utils/edge_detection_utils.dart';
import '../utils/logger.dart';
import 'base_flame_system.dart';

// T2.4.2: Collision layers for different entity types
enum CollisionLayer {
  player(1),
  platform(2),
  enemy(4),
  collectible(8),
  projectile(16),
  environment(32);

  const CollisionLayer(this.mask);
  final int mask;

  /// Check if this layer can collide with another layer
  bool canCollideWith(CollisionLayer other) {
    return (mask & other.mask) != 0;
  }
}

// T2.4.1: Enhanced collision data structure with separation vectors
class CollisionData {
  CollisionData({
    required this.entityA,
    required this.entityB,
    required this.separationVector,
    required this.normal,
    required this.penetrationDepth,
    required this.contactPoint,
  });

  final Entity entityA;
  final Entity entityB;
  final Vector2 separationVector;
  final Vector2 normal;
  final double penetrationDepth;
  final Vector2 contactPoint;
}

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
  Vector2 _gravity =
      Vector2(0, PhysicsConstants.gravity); // Use constants gravity
  // Will be implemented in Sprint 3 for detailed collision detection
  // ignore: unused_field
  bool _usePixelPerfectCollision = false;

  // Performance monitoring
  final List<double> _frameTimes = [];
  double _averageFrameTime = 0;
  final int _maxFrameTimeSamples = 60;

  // Collision processing
  final List<CollisionData> _collisions = <CollisionData>[];
  bool _enableCollision = true;
  @override
  void processSystem(double dt) {
    // Apply scaled time
    final double scaledDt = dt * _timeScale;

    // First process all entities (physics simulation)
    for (final Entity entity in entities) {
      if (!entity.isActive) continue;
      processEntity(entity, scaledDt);
    }

    // Clear previous collision data
    _collisions.clear(); // Process collisions if enabled
    if (_enableCollision) {
      detectCollisions();
      resolveCollisions(scaledDt);
    }

    // T2.6.2: Process edge detection after collision resolution
    processEdgeDetection();
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
    final DateTime startTime = DateTime.now();

    // Skip entities without required components
    if (entity.physics == null) return;

    final PhysicsComponent physics =
        entity.physics!; // Skip static entities (don't have physics applied)
    if (physics.isStatic) return;

    // Store ground state before clearing (for friction calculation)
    final bool wasOnGround = physics.isOnGround;

    // Clear ground state (will be set by collision resolution if touching ground)
    physics.setOnGround(
      false,
    ); // T2.1.1: Apply gravity constant from PhysicsConstants
    if (physics.affectedByGravity) {
      final Vector2 gravityForce = Vector2(
        0,
        PhysicsConstants.gravity * physics.mass * physics.gravityScale,
      );
      physics.applyForce(gravityForce);
    }

    // T2.1.2: Enhanced velocity integration with delta time
    integrateVelocity(physics, dt);

    // T2.1.3: Apply terminal velocity constraints
    applyTerminalVelocityConstraints(physics);

    // T2.1.4: Apply horizontal friction/drag (use stored ground state)
    applyHorizontalFrictionAndDrag(physics, dt, wasOnGround);

    // T2.1.6: Performance monitoring
    _recordFrameTime(startTime);
  }

  /// T2.1.2: Integrate velocity with proper delta time handling
  void integrateVelocity(PhysicsComponent physics, double dt) {
    // Apply acceleration to velocity with delta time integration
    physics.velocity.x += physics.acceleration.x * dt;
    physics.velocity.y += physics.acceleration.y * dt;

    // Apply velocity to position with delta time integration
    // The entity that owns this physics component
    if (physics.parent is Entity) {
      final Entity entity = physics.parent as Entity;
      entity.position.x += physics.velocity.x * dt;
      entity.position.y += physics.velocity.y * dt;
    }

    // Reset acceleration after integration
    physics.acceleration.setZero();
  }

  /// T2.1.3: Apply terminal velocity constraints for falling
  void applyTerminalVelocityConstraints(PhysicsComponent physics) {
    // Constrain vertical velocity to terminal velocity
    if (physics.velocity.y > PhysicsConstants.terminalVelocity) {
      physics.velocity.y = PhysicsConstants.terminalVelocity;
    }

    // Also constrain upward velocity to prevent excessive jumping
    if (physics.velocity.y < -PhysicsConstants.terminalVelocity) {
      physics.velocity.y = -PhysicsConstants.terminalVelocity;
    }

    // Constrain horizontal velocity to maximum horizontal speed
    if (physics.velocity.x.abs() > PhysicsConstants.maxHorizontalSpeed) {
      physics.velocity.x =
          physics.velocity.x.sign * PhysicsConstants.maxHorizontalSpeed;
    }
  }

  /// T2.1.4: Apply horizontal friction and air resistance
  void applyHorizontalFrictionAndDrag(
    PhysicsComponent physics,
    double dt,
    bool wasOnGround,
  ) {
    // Apply ground friction when on ground
    if (wasOnGround) {
      physics.velocity.x *= PhysicsConstants.groundFriction;
    } else {
      // Apply air resistance when in air
      final double airResistanceForce = physics.velocity.x.abs() *
          PhysicsConstants.airResistance *
          physics.mass;
      physics.velocity.x -= physics.velocity.x.sign * airResistanceForce * dt;
    }
  }

  /// T2.1.6: Record frame time for performance monitoring
  void _recordFrameTime(DateTime startTime) {
    final double frameTime =
        DateTime.now().difference(startTime).inMicroseconds / 1000.0;

    _frameTimes.add(frameTime);
    if (_frameTimes.length > _maxFrameTimeSamples) {
      _frameTimes.removeAt(0);
    }

    // Calculate rolling average
    _averageFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// T2.1.6: Get performance monitoring data
  double get averageFrameTime => _averageFrameTime;

  /// T2.1.6: Check if physics is performing well (< 1ms average)
  bool get isPerformanceOptimal => _averageFrameTime < 1.0;

  /// T2.1.6: Get current performance status
  String getPerformanceStatus() {
    if (_frameTimes.isEmpty) return 'No data';
    if (_averageFrameTime < 1.0) return 'Optimal';
    if (_averageFrameTime < 2.0) return 'Good';
    if (_averageFrameTime < 5.0) return 'Fair';
    return 'Poor';
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

        // T2.4.2: Check collision layers before detecting collision
        final CollisionLayer layerA = getEntityCollisionLayer(entityA);
        final CollisionLayer layerB = getEntityCollisionLayer(entityB);

        if (!canLayersCollide(layerA, layerB)) {
          continue;
        }

        // Check if collision is possible
        final bool hasCollision = checkEntityCollision(entityA, entityB);

        if (hasCollision) {
          // T2.4.1: Enhanced collision data with proper separation vectors and normals
          final CollisionData collisionData =
              calculateCollisionData(entityA, entityB);
          _collisions.add(collisionData);
        }
      }
    }
  }

  /// T2.4.5: Optimized collision detection with spatial partitioning
  /// This is a simple spatial hash for demonstration - can be enhanced further
  final Map<String, List<Entity>> _spatialHash = {};

  /// Update spatial hash for entities (simple grid-based partitioning)
  void updateSpatialHash() {
    _spatialHash.clear();

    const double cellSize = 128.0; // Grid cell size in pixels

    for (final Entity entity in entities) {
      if (!entity.isActive) continue;

      // Calculate grid cell coordinates
      final int gridX = (entity.position.x / cellSize).floor();
      final int gridY = (entity.position.y / cellSize).floor();
      final String cellKey = '${gridX}_$gridY';

      // Add entity to its grid cell
      _spatialHash.putIfAbsent(cellKey, () => <Entity>[]);
      _spatialHash[cellKey]!.add(entity);
    }
  }

  /// T2.4.5: Optimized collision detection using spatial partitioning
  void detectCollisionsOptimized() {
    if (!_enableCollision) return;

    updateSpatialHash();
    final Set<String> checkedPairs = <String>{}; // Prevent duplicate checks

    for (final List<Entity> cellEntities in _spatialHash.values) {
      // Check collisions within each cell
      for (int i = 0; i < cellEntities.length; i++) {
        final Entity entityA = cellEntities[i];
        if (!entityA.isActive) continue;

        for (int j = i + 1; j < cellEntities.length; j++) {
          final Entity entityB = cellEntities[j];
          if (!entityB.isActive) continue;

          // Create unique pair identifier
          final String pairKey = '${entityA.hashCode}_${entityB.hashCode}';
          if (checkedPairs.contains(pairKey)) continue;
          checkedPairs.add(pairKey);

          // T2.4.2: Check collision layers
          final CollisionLayer layerA = getEntityCollisionLayer(entityA);
          final CollisionLayer layerB = getEntityCollisionLayer(entityB);

          if (!canLayersCollide(layerA, layerB)) continue;

          // Check collision
          if (checkEntityCollision(entityA, entityB)) {
            final CollisionData collisionData =
                calculateCollisionData(entityA, entityB);
            _collisions.add(collisionData);
          }
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
    // T2.4.3: Sort collisions by resolution priority (Y-axis first for platforming)
    _collisions.sort((a, b) {
      // Prioritize vertical collisions over horizontal ones for better platforming
      final double aVerticalPenetration = a.separationVector.y.abs();
      final double bVerticalPenetration = b.separationVector.y.abs();

      if (aVerticalPenetration > 0 && bVerticalPenetration == 0) return -1;
      if (bVerticalPenetration > 0 && aVerticalPenetration == 0) return 1;

      // If both are vertical or both are horizontal, prioritize deeper penetrations
      return b.penetrationDepth.compareTo(a.penetrationDepth);
    });

    logger.fine('RESOLVE COLLISIONS: Found ${_collisions.length} collisions');
    for (final CollisionData collision in _collisions) {
      logger.finer(
        'RESOLVING COLLISION: ${collision.entityA.type} vs ${collision.entityB.type}',
      );
      // Apply collision resolution using enhanced collision data
      resolveCollisionWithData(collision, dt);

      // Notify entities of the collision
      collision.entityA.onCollision(collision.entityB);
      collision.entityB.onCollision(collision.entityA);
    }
  }

  /// T2.4.1 & T2.4.3: Enhanced collision resolution using collision data
  void resolveCollisionWithData(CollisionData collision, double dt) {
    final Entity entityA = collision.entityA;
    final Entity entityB = collision.entityB;

    // Determine which entity should be moved (prefer moving non-static entities)
    Entity? movableEntity;
    Entity? staticEntity;

    final bool aHasPhysics =
        entityA.physics != null && !entityA.physics!.isStatic;
    final bool bHasPhysics =
        entityB.physics != null && !entityB.physics!.isStatic;

    if (aHasPhysics && !bHasPhysics) {
      movableEntity = entityA;
      staticEntity = entityB;
    } else if (bHasPhysics && !aHasPhysics) {
      movableEntity = entityB;
      staticEntity = entityA;
    } else if (aHasPhysics && bHasPhysics) {
      // Both entities can move - use player-platform logic
      if (entityA.type == 'player') {
        movableEntity = entityA;
        staticEntity = entityB;
      } else if (entityB.type == 'player') {
        movableEntity = entityB;
        staticEntity = entityA;
      } else {
        // Default: move the first entity
        movableEntity = entityA;
        staticEntity = entityB;
      }
    }

    if (movableEntity != null && staticEntity != null) {
      // Use enhanced collision resolution
      resolveCollisionWithSeparation(movableEntity, staticEntity, collision);
    } else {
      // Fallback to old resolution method
      resolveEntityCollision(entityA, entityB, dt);
    }
  }

  /// T2.4.1: Resolve collision using separation vector and normal
  void resolveCollisionWithSeparation(
    Entity movableEntity,
    Entity staticEntity,
    CollisionData collision,
  ) {
    final PhysicsComponent? physics = movableEntity.physics;
    if (physics == null) return;

    final Vector2 separation = collision.separationVector;
    final Vector2 normal = collision.normal;

    // Check for one-way platform special handling BEFORE applying separation
    if (staticEntity is Platform && staticEntity.isOneWay) {
      // For one-way platforms, only allow landing from above
      if (normal.y < 0 && physics.velocity.y > 0) {
        // Valid landing on one-way platform from above        // Log collision resolution for one-way platform landing
        logger.fine(
          'COLLISION RESOLUTION: Landing on one-way platform - Moving ${movableEntity.type} by $separation',
        );
        logger.finer('  Before: ${movableEntity.position}');

        movableEntity.position.add(separation);
        logger.finer('  After: ${movableEntity.position}');

        physics.velocity.y = 0;
        physics.setOnGround(true);

        // T2.5.1: Enhanced landing data with collision normal
        physics.setLandingData(
          collisionNormal: normal,
          separationVector: separation,
          landingVelocity: physics.velocity.y,
          landingPosition: movableEntity.position,
          platformType: 'one_way_platform',
        );
        return;
      } else {
        // Allow pass-through for all other directions (below, sides)
        logger.fine(
          'COLLISION RESOLUTION: One-way platform pass-through - No movement applied',
        );
        return;
      }
    } // Log standard collision resolution
    logger.fine(
      'COLLISION RESOLUTION: Moving ${movableEntity.type} by $separation',
    );
    logger.finer('  Before: ${movableEntity.position}');

    // Move the entity out of collision
    movableEntity.position.add(separation);

    logger.finer('  After: ${movableEntity.position}');
    // Apply collision response based on normal direction
    if (normal.y.abs() > normal.x.abs()) {
      // Vertical collision is primary
      if (normal.y < 0) {
        // Normal pointing up - entity is landing on top of static entity
        physics.velocity.y = 0;
        physics.setOnGround(true);

        // T2.5.1: Enhanced landing data with collision normal
        String platformType = 'platform';
        if (staticEntity is Platform) {
          platformType =
              staticEntity.isOneWay ? 'one_way_platform' : 'solid_platform';
        }

        physics.setLandingData(
          collisionNormal: normal,
          separationVector: separation,
          landingVelocity: physics.velocity.y,
          landingPosition: movableEntity.position,
          platformType: platformType,
        );
      } else {
        // Normal pointing down - entity is hitting static entity from below
        if (physics.velocity.y < 0) {
          physics.velocity.y = 0;
        }
      }
    } else {
      // Horizontal collision is primary
      physics.velocity.x = 0;
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
    Entity player,
    Entity platform,
    double overlapX,
  ) {
    final PhysicsComponent physics = player.physics!;

    // Separate the entities
    player.position.x -= overlapX;

    // Stop horizontal velocity
    physics.velocity.x = 0;
  }

  /// Resolve vertical collision (top/bottom collision with platform)
  void _resolveVerticalCollision(
    Entity player,
    Entity platform,
    double overlapY,
  ) {
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

      // T2.5.1: Enhanced landing data for fallback collision resolution
      String platformType = 'platform';
      if (platform is Platform) {
        platformType =
            platform.isOneWay ? 'one_way_platform' : 'solid_platform';
      }

      physics.setLandingData(
        collisionNormal: Vector2(0, -1), // Upward normal for top collision
        separationVector: Vector2(0, -overlapY),
        landingVelocity: physics.velocity.y,
        landingPosition: player.position,
        platformType: platformType,
      );
    }
    // Handle hitting platform from below (head collision)
    else if (overlapY > 0 && physics.velocity.y < 0) {
      // Player hit platform from below
      physics.velocity.y = 0;
    }
  }

  /// T2.4.1: Calculate detailed collision data with separation vectors and normals
  CollisionData calculateCollisionData(Entity entityA, Entity entityB) {
    final Vector2 posA = entityA.position;
    final Vector2 sizeA = entityA.size;
    final Vector2 posB = entityB.position;
    final Vector2 sizeB = entityB.size;

    // Calculate bounds for each entity
    final double leftA = posA.x;
    final double rightA = posA.x + sizeA.x;
    final double topA = posA.y;
    final double bottomA = posA.y + sizeA.y;

    final double leftB = posB.x;
    final double rightB = posB.x + sizeB.x;
    final double topB = posB.y;
    final double bottomB = posB.y +
        sizeB.y; // Calculate overlaps (positive values mean overlap exists)
    double overlapX = 0;
    double overlapY = 0;

    // Check for horizontal overlap
    if (rightA > leftB && leftA < rightB) {
      final double overlapLeft = rightA - leftB;
      final double overlapRight = rightB - leftA;
      overlapX = overlapLeft < overlapRight ? overlapLeft : overlapRight;
    }

    // Check for vertical overlap
    if (bottomA > topB && topA < bottomB) {
      final double overlapTop = bottomA - topB;
      final double overlapBottom = bottomB - topA;
      overlapY = overlapTop < overlapBottom ? overlapTop : overlapBottom;
    }

    // Determine which axis has smaller overlap (primary collision direction)
    Vector2 separationVector;
    Vector2 normal;
    double penetrationDepth;
    if (overlapX < overlapY) {
      // Horizontal collision is primary
      penetrationDepth = overlapX;
      if ((rightA - leftB) < (rightB - leftA)) {
        // A is overlapping from the left, separate A leftward
        separationVector = Vector2(-overlapX, 0);
        normal = Vector2(-1, 0);
      } else {
        // A is overlapping from the right, separate A rightward
        separationVector = Vector2(overlapX, 0);
        normal = Vector2(1, 0);
      }
    } else {
      // Vertical collision is primary
      penetrationDepth = overlapY;

      // For platformer games, determine separation based on collision context
      // If entityA's top is above entityB's top, then A is landing on B from above
      if (topA < topB) {
        // Entity A is above entity B, separate A upward (negative Y direction)
        separationVector = Vector2(0, -overlapY);
        normal = Vector2(0, -1);
      } else {
        // Entity A is below entity B, separate A downward (positive Y direction)
        separationVector = Vector2(0, overlapY);
        normal = Vector2(0, 1);
      }
    } // Calculate contact point (center of overlap region)
    final Vector2 contactPoint = Vector2(
      (max(leftA, leftB) + min(rightA, rightB)) / 2,
      (max(topA, topB) + min(bottomA, bottomB)) / 2,
    );

    return CollisionData(
      entityA: entityA,
      entityB: entityB,
      separationVector: separationVector,
      normal: normal,
      penetrationDepth: penetrationDepth,
      contactPoint: contactPoint,
    );
  }

  /// T2.4.2: Check if two collision layers can interact
  bool canLayersCollide(CollisionLayer layerA, CollisionLayer layerB) {
    // Define collision matrix - which layers can collide with each other
    const Map<CollisionLayer, List<CollisionLayer>> collisionMatrix = {
      CollisionLayer.player: [
        CollisionLayer.platform,
        CollisionLayer.enemy,
        CollisionLayer.collectible,
        CollisionLayer.environment,
      ],
      CollisionLayer.platform: [
        CollisionLayer.player,
        CollisionLayer.enemy,
        CollisionLayer.projectile,
      ],
      CollisionLayer.enemy: [
        CollisionLayer.player,
        CollisionLayer.platform,
        CollisionLayer.projectile,
        CollisionLayer.environment,
      ],
      CollisionLayer.collectible: [
        CollisionLayer.player,
      ],
      CollisionLayer.projectile: [
        CollisionLayer.platform,
        CollisionLayer.enemy,
        CollisionLayer.environment,
      ],
      CollisionLayer.environment: [
        CollisionLayer.player,
        CollisionLayer.enemy,
        CollisionLayer.projectile,
      ],
    };

    return collisionMatrix[layerA]?.contains(layerB) == true ||
        collisionMatrix[layerB]?.contains(layerA) == true;
  }

  /// T2.4.3: Get collision layer for entity type
  CollisionLayer getEntityCollisionLayer(Entity entity) {
    switch (entity.type.toLowerCase()) {
      case 'player':
        return CollisionLayer.player;
      case 'platform':
        return CollisionLayer.platform;
      case 'enemy':
        return CollisionLayer.enemy;
      case 'collectible':
        return CollisionLayer.collectible;
      case 'projectile':
        return CollisionLayer.projectile;
      default:
        return CollisionLayer.environment;
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

  /// T2.6.2: Process edge detection for all player entities
  void processEdgeDetection() {
    // Find all platforms for edge detection
    final List<CollisionComponent> platforms = [];

    for (final Entity entity in entities) {
      if (entity is Platform) {
        platforms.add(entity.collision);
      }
    }

    // Process edge detection for each player entity
    for (final Entity entity in entities) {
      if (entity.type == 'player' && entity.physics != null) {
        final EdgeDetectionResult result =
            EdgeDetectionUtils.detectPlatformEdges(
          playerPosition: entity.position,
          playerSize: entity.size,
          platforms: platforms,
          detectionThreshold: entity.physics!.edgeDetectionThreshold,
        );

        // Update physics component with edge detection data
        entity.physics!.setEdgeDetectionData(
          isNearLeftEdge: result.isNearLeftEdge,
          isNearRightEdge: result.isNearRightEdge,
          leftEdgeDistance: result.leftEdgeDistance,
          rightEdgeDistance: result.rightEdgeDistance,
          leftEdgePosition: result.leftEdgePosition,
          rightEdgePosition: result.rightEdgePosition,
        );
      }
    }
  }
}

/// Helper class to store colliding entity pairs
class CollisionPair {
  CollisionPair(this.entityA, this.entityB);
  final Entity entityA;
  final Entity entityB;
}

import 'package:flame/components.dart';
import 'package:logging/logging.dart';

import '../components/collision_component.dart'; // Ensure this import is present and used
import '../components/physics_component.dart';
import '../entities/entity.dart';
import '../entities/platform.dart';
import '../utils/collision_utils.dart';
import '../utils/constants.dart';
import '../utils/edge_detection_utils.dart';
import 'base_flame_system.dart';

// Logger for physics system
final Logger logger = Logger('PhysicsSystem');

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
///
/// ARCHITECTURE:
/// -------------
/// PhysicsSystem is the core system responsible for physical simulation in the game.
/// It integrates with other systems in the following ways:
/// - Processes entities with PhysicsComponent
/// - Detects and resolves collisions between entities
/// - Notifies entities of collision events for custom handling
/// - Interfaces with input and animation systems via entity state changes
///
/// PERFORMANCE CHARACTERISTICS:
/// ---------------------------
/// - Basic collision detection: O(n²) complexity where n is entity count
/// - Optimized spatial partitioning: O(n + k) where k is potential collisions
/// - Integration is O(n) where n is entity count
/// - Memory usage: Maintains collision data structures proportional to collision count
///
/// CONFIGURATION OPTIONS:
/// ---------------------
/// - Gravity: Vector2 defining world gravity direction and magnitude
/// - TimeScale: Allows slowing down or speeding up physics
/// - UsePixelPerfectCollision: Toggle for precise but more expensive collisions
///
/// USAGE EXAMPLES:
/// --------------
/// ```dart
/// // Create physics system with custom gravity
/// final physicsSystem = PhysicsSystem(
///   gravity: Vector2(0, 600),
///   timeScale: 1.0,
/// );
///
/// // Register an entity for physics processing
/// physicsSystem.addEntity(player);
/// ```
class PhysicsSystem extends BaseFlameSystem {
  PhysicsSystem({
    Vector2? gravity,
    double? timeScale,
  }) : super() {
    if (gravity != null) _gravity = gravity;
    if (timeScale != null) _timeScale = timeScale;
  }

  // Configuration
  double _timeScale = 1.0;
  Vector2 _gravity = Vector2(0, PhysicsConstants.gravity);
  bool _enableCollision = true;

  // Performance monitoring
  final List<double> _frameTimes = [];
  double _averageFrameTime = 0;
  final int _maxFrameTimeSamples = 60;
  // Collision processing
  final List<CollisionData> _collisions = <CollisionData>[];
  final Map<String, List<Entity>> _spatialHash = {};

  // PHASE 1 DEBUG: Entity count logging
  int _logCounter = 0;

  @override
  void update(double dt) {
    if (!isActive) return;
    processSystem(dt);
  }

  @override
  void initialize() {
    // Initialize the physics system
    _collisions.clear();
    _frameTimes.clear();
    _spatialHash.clear();
  }

  @override
  void processSystem(double dt) {
    // PHASE 1 DEBUG: Periodic entity count logging
    _logCounter++;
    if (_logCounter % 120 == 0) {
      // Log every 2 seconds at 60fps
      logger.info(
        'PHASE 1 DEBUG: PhysicsSystem.processSystem() entity count: ${entities.length}',
      );
      for (int i = 0; i < entities.length; i++) {
        final Entity entity = entities[i];
        logger.info(
          '  Entity $i: type=${entity.type}, id=${entity.id}, active=${entity.isActive}',
        );
      }
    }

    // Apply scaled time
    final double scaledDt = dt * _timeScale;

    // First process all entities (physics simulation)
    for (final Entity entity in entities) {
      if (!entity.isActive) continue;
      processEntity(entity, scaledDt);
    }

    // Clear previous collision data
    _collisions.clear();

    // Process collisions if enabled
    if (_enableCollision) {
      detectCollisions();
      resolveCollisions(scaledDt);
    }

    // T2.6.2: Process edge detection after collision resolution
    processEdgeDetection();
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Process entity physics
    processEntityPhysics(entity, dt);
  }

  @override
  bool canProcessEntity(Entity entity) {
    // Process entities with physics components for full physics simulation
    if (entity.physics != null) return true;

    // Also process collectibles for collision detection (they don't need physics but need collision)
    if (entity.type == 'collectible') return true;

    // Process other entities that need collision detection but not full physics
    // Add more entity types here as needed

    return false;
  }

  @override
  void onEntityAdded(Entity entity) {
    // PHASE 1 DEBUG: Log entity registration details
    logger.info('DEBUG: PhysicsSystem.onEntityAdded() - Adding entity');
    logger.info('  Entity type: ${entity.type}');
    logger.info('  Entity ID: ${entity.id}');
    logger.info('  Has physics component: ${entity.physics != null}');
    logger.info('  Current entities count before add: ${entities.length}');

    // Additional setup for entity when added to system
    if (entity.physics != null) {
      logger.info('  Physics component details:');
      logger.info('    Is static: ${entity.physics!.isStatic}');
      logger.info('    Velocity: ${entity.physics!.velocity}');
      logger.info('    Mass: ${entity.physics!.mass}');
      // Initialize physics properties if needed
    }

    logger.info('  Collision component details:');
    logger.info('    Is active: ${entity.collision.isActive}');
    logger.info('    Hitbox size: ${entity.collision.hitboxSize}');

    logger.info('  Entity position: ${entity.position}');
    logger.info('  Entity size: ${entity.size}');
    logger.info('  Current entities count after add: ${entities.length}');
  }

  @override
  void onEntityRemoved(Entity entity) {
    // PHASE 1 DEBUG: Log entity removal
    logger.info('DEBUG: PhysicsSystem.onEntityRemoved() - Removing entity');
    logger.info('  Entity type: ${entity.type}');
    logger.info('  Entity ID: ${entity.id}');
    logger.info('  Current entities count after removal: ${entities.length}');
    // Clean up any resources when entity is removed
  }

  /// Process physics for a single entity
  void processEntityPhysics(Entity entity, double dt) {
    final DateTime startTime = DateTime.now();

    // Skip entities without required components
    if (entity.physics == null) return;

    final PhysicsComponent physics = entity.physics!;

    // Skip static entities (don't have physics applied)
    if (physics.isStatic) return;

    // Store ground state before clearing (for friction calculation)
    final bool wasOnGround = physics.isOnGround;

    // Only clear ground state if entity is jumping (has significant upward velocity)
    // This prevents gravity from being applied when entity should remain on ground
    if (physics.isOnGround && physics.velocity.y < -10.0) {
      // Entity is jumping off the ground
      physics.setOnGround(false);
    }

    // T2.1.1: Apply gravity constant from PhysicsConstants
    // Only apply gravity if entity is not on ground
    if (physics.affectedByGravity && !physics.isOnGround) {
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

    // Handle ground collision response - zero out downward velocity when on ground
    if (physics.isOnGround && physics.velocity.y > 0) {
      physics.velocity.y = 0;
    }

    // T2.1.4: Apply horizontal friction/drag (use stored ground state)
    applyHorizontalFrictionAndDrag(physics, dt, wasOnGround);

    // T2.1.6: Performance monitoring
    recordFrameTime(startTime);
  }

  /// T2.1.2: Integrate velocity with proper delta time handling
  void integrateVelocity(PhysicsComponent physics, double dt) {
    // Apply acceleration to velocity with delta time integration
    physics.velocity.x += physics.acceleration.x * dt;
    physics.velocity.y += physics.acceleration.y *
        dt; // Apply velocity to position with delta time integration
    // The entity that owns this physics component
    if (physics.parent is Entity) {
      final Entity entity = physics.parent as Entity;

      // DEBUG: Log position changes
      final Vector2 oldPosition = entity.position.clone();

      entity.position.x += physics.velocity.x * dt;
      entity.position.y += physics.velocity.y * dt;

      // CRITICAL FIX: Also update the TransformComponent to prevent it from overriding the position
      entity.transformComponent.setPosition(entity.position);

      // DEBUG: Only log if position actually changed significantly
      if ((entity.position - oldPosition).length > 0.1) {
        print(
          '[PhysicsSystem] integrateVelocity: ${entity.type} position changed from $oldPosition to ${entity.position} (velocity: ${physics.velocity}, dt: $dt)',
        );
        print(
            '[PhysicsSystem] TransformComponent position updated to: ${entity.transformComponent.position}');
      }
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

  /// T2.1.4: Apply horizontal friction and air resistance - T2.13.4: Enhanced for smoother movement
  void applyHorizontalFrictionAndDrag(
    PhysicsComponent physics,
    double dt,
    bool wasOnGround,
  ) {
    // Apply ground friction when on ground (reduced for smoother movement)
    if (wasOnGround) {
      physics.velocity.x *= PhysicsConstants.groundFriction;

      // T2.13.4: Apply minimum movement threshold to prevent micro-movements
      if (physics.velocity.x.abs() < 5.0) {
        // 5 pixels/second threshold
        physics.velocity.x = 0.0;
      }
    } else {
      // Apply air resistance when in air (reduced for better air control)
      final double airResistanceForce = physics.velocity.x.abs() *
          PhysicsConstants.airResistance *
          physics.mass;
      physics.velocity.x -= physics.velocity.x.sign * airResistanceForce * dt;
    }
  }

  /// T2.1.6: Record frame time for performance monitoring
  void recordFrameTime(DateTime startTime) {
    final double frameTime =
        DateTime.now().difference(startTime).inMicroseconds / 1000.0;

    _frameTimes.add(frameTime);
    if (_frameTimes.length > _maxFrameTimeSamples) {
      _frameTimes.removeAt(0);
    }

    // Calculate rolling average if there are frame times to average
    if (_frameTimes.isNotEmpty) {
      _averageFrameTime =
          _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    }
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

    print(
      '[PhysicsSystem] detectCollisions() called with ${entities.length} entities',
    );
    for (int i = 0; i < entities.length; i++) {
      final Entity entity = entities[i];
      print(
        '[PhysicsSystem] Entity $i: ${entity.type}, position: ${entity.position}, size: ${entity.size}, active: ${entity.isActive}',
      );
    }

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
    }); // Process all collisions
    print('[PhysicsSystem] Processing ${_collisions.length} collisions');
    for (final CollisionData collision in _collisions) {
      print(
        '[PhysicsSystem] Collision between ${collision.entityA.type} and ${collision.entityB.type}',
      );

      // Apply collision resolution using enhanced collision data
      resolveCollisionWithData(collision, dt);

      // Notify entities of the collision using null-safe calls
      print(
        '[PhysicsSystem] Calling onCollision for ${collision.entityA.type}: ${collision.entityA.onCollision != null}',
      );
      collision.entityA.onCollision?.call(collision.entityB);

      print(
        '[PhysicsSystem] Calling onCollision for ${collision.entityB.type}: ${collision.entityB.onCollision != null}',
      );
      collision.entityB.onCollision?.call(collision.entityA);
    }
  }

  /// Basic entity collision resolution
  void resolveEntityCollision(Entity entityA, Entity entityB, double dt) {
    // Simple fallback collision response
    // This method is used when enhanced collision data is not available

    // For typical platform games, simply determine if this is a vertical or horizontal collision
    final Vector2 delta = entityB.position - entityA.position;

    // If vertical distance is greater, treat as vertical collision
    if (delta.y.abs() > delta.x.abs()) {
      // Vertical collision handling
      handleVerticalCollision(entityA, entityB);
    } else {
      // Horizontal collision handling
      handleHorizontalCollision(entityA, entityB);
    }
  }

  /// Handle vertical collision between entities
  void handleVerticalCollision(Entity entityA, Entity entityB) {
    // Basic vertical collision logic
    if (entityA.physics != null && !entityA.physics!.isStatic) {
      // Handle landing on surfaces
      if (entityA.position.y < entityB.position.y) {
        entityA.physics!.setOnGround(true);
        entityA.physics!.velocity.y = 0;
      } else {
        // Hitting ceiling
        entityA.physics!.velocity.y = 0;
      }
    }
  }

  /// Handle horizontal collision between entities
  void handleHorizontalCollision(Entity entityA, Entity entityB) {
    // Basic horizontal collision logic
    if (entityA.physics != null && !entityA.physics!.isStatic) {
      entityA.physics!.velocity.x = 0;
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

    final Vector2 separation = collision
        .separationVector; // entityA is movable, so separation is from B to A
    final Vector2 normal = collision.normal;

    print('[PhysicsSystem] resolveCollisionWithSeparation DEBUG:');
    print(
      '  Movable entity (${movableEntity.type}): pos=${movableEntity.position}',
    );
    print(
      '  Static entity (${staticEntity.type}): pos=${staticEntity.position}',
    );
    print('  Separation vector: $separation');
    print('  Normal: $normal');
    print('  Physics velocity before: ${physics.velocity}');
    print('  Physics isOnGround before: ${physics.isOnGround}');

    // Check for one-way platform special handling BEFORE applying separation
    if (staticEntity is Platform && staticEntity.isOneWay) {
      // For one-way platforms, only allow landing from above
      if (normal.y < 0 && physics.velocity.y > 0) {
        // Valid landing on one-way platform from above
        print('  ONE-WAY PLATFORM: Landing from above detected');
        // Apply position correction to prevent sinking
        movableEntity.position += separation;
        print('  Position after separation: ${movableEntity.position}');

        // Update physics state
        physics.setOnGround(true);
        physics.velocity.y = 0; // Stop downward motion
        print('  Set onGround=true, velocity.y=0');

        // End early - we handled this collision
        return;
      } else {
        // Not landing from above - don't collide with one-way platforms
        print(
          '  ONE-WAY PLATFORM: Not landing from above - ignoring collision',
        );
        return;
      }
    }

    // Standard collision resolution (for solid obstacles)
    print('  SOLID COLLISION: Applying standard resolution');

    // Apply position correction to prevent sinking
    print('  Applying separation: ${movableEntity.position} += $separation');
    movableEntity.position += separation;
    print('  Position after separation: ${movableEntity.position}');

    // Handle ground detection
    if (normal.y < -0.5) {
      // If normal points mostly upward
      print('  GROUND DETECTED: Setting onGround=true (normal.y=${normal.y})');
      physics.setOnGround(true);
    } else {
      print('  NO GROUND: normal.y=${normal.y} (not < -0.5)');
    }

    // Reflect velocity based on collision normal for bouncy objects
    if (physics.bounciness > 0) {
      // Calculate reflection vector
      final double dot = physics.velocity.dot(normal);

      // Only reflect velocity component in the normal direction
      if (dot < 0) {
        Vector2 reflection = Vector2(
          physics.velocity.x - 2 * dot * normal.x,
          physics.velocity.y - 2 * dot * normal.y,
        );

        // Apply bounciness factor
        physics.velocity.setFrom(reflection * physics.bounciness);
        print('  BOUNCY: Applied reflection velocity: ${physics.velocity}');
      }
    } else {
      // For non-bouncy objects, just zero out velocity in the normal direction
      if (normal.y.abs() > normal.x.abs()) {
        // Vertical collision
        print('  VELOCITY: Zeroing Y velocity (was ${physics.velocity.y})');
        physics.velocity.y = 0;
      } else {
        // Horizontal collision
        print('  VELOCITY: Zeroing X velocity (was ${physics.velocity.x})');
        physics.velocity.x = 0;
      }
      print('  Final velocity: ${physics.velocity}');
    }

    print(
      '  Final physics state: isOnGround=${physics.isOnGround}, velocity=${physics.velocity}',
    );
  }

  /// T2.4.1: Calculate collision data between entities
  CollisionData calculateCollisionData(Entity entityA, Entity entityB) {
    print('[PhysicsSystem] calculateCollisionData DEBUG:');
    print(
      '  EntityA (${entityA.type}): pos=${entityA.position}, size=${entityA.size}',
    );
    print(
      '  EntityB (${entityB.type}): pos=${entityB.position}, size=${entityB.size}',
    );

    // Calculate centers
    final Vector2 centerA = entityA.position + (entityA.size * 0.5);
    final Vector2 centerB = entityB.position + (entityB.size * 0.5);
    print('  CenterA: $centerA, CenterB: $centerB');

    // Calculate distance
    final Vector2 distance = centerA - centerB;
    print('  Distance vector (A-B): $distance');

    // Calculate combined half-sizes
    final Vector2 combinedHalfSize = (entityA.size + entityB.size) * 0.5;
    print('  Combined half-size: $combinedHalfSize');

    // Calculate overlap
    final double overlapX = combinedHalfSize.x - distance.x.abs();
    final double overlapY = combinedHalfSize.y - distance.y.abs();
    print('  OverlapX: $overlapX, OverlapY: $overlapY');

    // Calculate separation vector (smallest movement to resolve collision)
    Vector2 separationVector;
    Vector2 normal;
    double penetrationDepth;

    if (overlapX < overlapY) {
      // Horizontal collision
      final double signX = distance.x > 0 ? 1 : -1;
      separationVector = Vector2(overlapX * signX, 0);
      normal = Vector2(signX, 0);
      penetrationDepth = overlapX;
      print('  HORIZONTAL collision detected');
    } else {
      // Vertical collision
      final double signY = distance.y > 0 ? 1 : -1;
      separationVector = Vector2(0, overlapY * signY);
      normal = Vector2(0, signY);
      penetrationDepth = overlapY;
      print('  VERTICAL collision detected');
    }

    print('  Separation vector: $separationVector');
    print('  Normal: $normal');
    print('  Penetration depth: $penetrationDepth');

    // Calculate contact point (approximate at center of overlap)
    final Vector2 contactPoint = centerA - (separationVector * 0.5);

    return CollisionData(
      entityA: entityA,
      entityB: entityB,
      separationVector: separationVector,
      normal: normal,
      penetrationDepth: penetrationDepth,
      contactPoint: contactPoint,
    );
  }

  /// T2.6.2: Process edge detection for all entities
  void processEdgeDetection() {
    // Only process entities that need edge detection
    for (final Entity entity in entities) {
      if (!entity.isActive) continue;
      if (entity.physics == null) continue;

      // Check if entity is on ground and should detect edges
      final PhysicsComponent physics = entity.physics!;
      if (!physics.isOnGround) continue;
      if (!physics.useEdgeDetection) continue;

      // Detect platform edges
      // We need to extract the CollisionComponent from each Platform entity.
      // Assuming Platform is an Entity (Component) and has children,
      // one of which is the CollisionComponent.
      final List<CollisionComponent> platformColliders = entities
          .whereType<Platform>()
          .map((platform) {
            // Find the CollisionComponent among the platform's children
            for (final child in platform.children) {
              if (child is CollisionComponent) {
                return child; // Return the first one found
              }
            }
            return null; // No CollisionComponent found for this platform, or platform has no children
          })
          .whereType<
              CollisionComponent>() // Filters out nulls and casts valid items to CollisionComponent
          .toList();

      EdgeDetectionUtils.detectPlatformEdges(
        playerPosition: entity.position,
        playerSize: entity.size,
        platforms: platformColliders,
      );
    }
  }

  /// T2.4.2: Check if two collision layers can collide
  bool canLayersCollide(CollisionLayer layerA, CollisionLayer layerB) {
    // Collision matrix (can be expanded as needed)
    final Map<CollisionLayer, Set<CollisionLayer>> collisionMatrix = {
      CollisionLayer.player: {
        CollisionLayer.platform,
        CollisionLayer.enemy,
        CollisionLayer.collectible,
        CollisionLayer.environment,
      },
      CollisionLayer.enemy: {
        CollisionLayer.platform,
        CollisionLayer.player,
        CollisionLayer.projectile,
        CollisionLayer.environment,
      },
      CollisionLayer.projectile: {
        CollisionLayer.enemy,
        CollisionLayer.platform,
        CollisionLayer.environment,
      },
      CollisionLayer.collectible: {
        CollisionLayer.player,
      },
    };

    // Check if either layer has the other in its collision set
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
      case 'projectile':
        return CollisionLayer.projectile;
      case 'collectible':
        return CollisionLayer.collectible;
      default:
        return CollisionLayer.environment;
    }
  }

  /// T2.5.2: Check if an entity is on the ground
  bool isEntityOnGround(Entity entity) {
    return entity.physics?.isOnGround ?? false;
  }

  /// Set gravity vector
  void setGravity(Vector2 gravity) {
    _gravity = gravity;
  }

  /// Enable/disable collisions
  void setCollisionEnabled(bool enabled) {
    _enableCollision = enabled;
  }

  /// Set physics time scale
  void setTimeScale(double timeScale) {
    _timeScale = timeScale.clamp(0.1, 10.0);
  }

  /// Get current gravity vector
  Vector2 get gravity => _gravity;

  /// Get collision enabled state
  bool get collisionEnabled => _enableCollision;

  /// Get current time scale
  double get timeScale => _timeScale;

  // Helper method to clear all entities
  void clearAllEntities() {
    entities.clear();
    _collisions.clear();
  }

  @override
  void dispose() {
    // Release any resources
    _collisions.clear();
    _spatialHash.clear();
    _frameTimes.clear();
    super.dispose();
  }
}

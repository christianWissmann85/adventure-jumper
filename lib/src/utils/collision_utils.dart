import 'dart:math' as math;

import 'package:flame/components.dart';

import 'math_utils.dart';

/// Collision detection and response utilities for the Adventure Jumper game
/// Provides comprehensive collision systems for 2D platformer mechanics
class CollisionUtils {
  // Private constructor to prevent instantiation
  CollisionUtils._();

  /// Check collision between two axis-aligned bounding boxes (AABB)
  static bool aabbCollision(
    Vector2 pos1,
    Vector2 size1,
    Vector2 pos2,
    Vector2 size2,
  ) {
    return pos1.x < pos2.x + size2.x &&
        pos1.x + size1.x > pos2.x &&
        pos1.y < pos2.y + size2.y &&
        pos1.y + size1.y > pos2.y;
  }

  /// Check collision between two circles
  static bool circleCollision(
    Vector2 center1,
    double radius1,
    Vector2 center2,
    double radius2,
  ) {
    final double distance = MathUtils.distance(center1, center2);
    return distance <= radius1 + radius2;
  }

  /// Check collision between a circle and an AABB
  static bool circleAABBCollision(
    Vector2 circleCenter,
    double radius,
    Vector2 boxPos,
    Vector2 boxSize,
  ) {
    // Find the closest point on the rectangle to the circle
    final double closestX = MathUtils.clamp(circleCenter.x, boxPos.x, boxPos.x + boxSize.x);
    final double closestY = MathUtils.clamp(circleCenter.y, boxPos.y, boxPos.y + boxSize.y);
    final Vector2 closest = Vector2(closestX, closestY);

    // Calculate distance and check collision
    final double distance = MathUtils.distance(circleCenter, closest);
    return distance <= radius;
  }

  /// Check if a point is inside an AABB
  static bool pointInAABB(Vector2 point, Vector2 boxPos, Vector2 boxSize) {
    return point.x >= boxPos.x &&
        point.x <= boxPos.x + boxSize.x &&
        point.y >= boxPos.y &&
        point.y <= boxPos.y + boxSize.y;
  }

  /// Check if a point is inside a circle
  static bool pointInCircle(Vector2 point, Vector2 center, double radius) {
    return MathUtils.distance(point, center) <= radius;
  }

  /// Check collision between two oriented bounding boxes (OBB)
  static bool obbCollision(
    Vector2 center1,
    Vector2 size1,
    double rotation1,
    Vector2 center2,
    Vector2 size2,
    double rotation2,
  ) {
    // Transform both boxes to axis-aligned in the coordinate system of the first box
    final double cos1 = math.cos(rotation1);
    final double sin1 = math.sin(rotation1);
    final double cos2 = math.cos(rotation2 - rotation1);
    final double sin2 = math.sin(rotation2 - rotation1);

    // Relative position
    final Vector2 relativePos = center2 - center1;
    final Vector2 localPos = Vector2(
      relativePos.x * cos1 + relativePos.y * sin1,
      -relativePos.x * sin1 + relativePos.y * cos1,
    );

    // Half sizes
    final Vector2 half1 = size1 / 2;
    final Vector2 half2 = size2 / 2;

    // Rotation matrix for second box
    final List<List<double>> rotMatrix = <List<double>>[
      <double>[cos2, sin2],
      <double>[-sin2, cos2],
    ];

    // Check separating axes
    for (int i = 0; i < 2; i++) {
      double sum = half1[i];
      for (int j = 0; j < 2; j++) {
        sum += (rotMatrix[j][i] * half2[j]).abs();
      }
      if (localPos[i].abs() > sum) return false;
    }

    for (int i = 0; i < 2; i++) {
      double sum = 0;
      for (int j = 0; j < 2; j++) {
        sum += (rotMatrix[i][j] * half1[j]).abs();
      }
      sum += half2[i];

      double projection = 0;
      for (int j = 0; j < 2; j++) {
        projection += rotMatrix[i][j] * localPos[j];
      }

      if (projection.abs() > sum) return false;
    }

    return true;
  }

  /// Check line-circle intersection
  static bool lineCircleIntersection(
    Vector2 lineStart,
    Vector2 lineEnd,
    Vector2 circleCenter,
    double radius,
  ) {
    final Vector2 lineVec = lineEnd - lineStart;
    final Vector2 toCircle = circleCenter - lineStart;

    final double lineLength2 = lineVec.length2;
    if (lineLength2 < MathUtils.epsilon) {
      return MathUtils.distance(lineStart, circleCenter) <= radius;
    }

    final double t = MathUtils.clamp(toCircle.dot(lineVec) / lineLength2, 0, 1);
    final Vector2 closestPoint = lineStart + lineVec * t;

    return MathUtils.distance(closestPoint, circleCenter) <= radius;
  }

  /// Check line-AABB intersection
  static bool lineAABBIntersection(
    Vector2 lineStart,
    Vector2 lineEnd,
    Vector2 boxPos,
    Vector2 boxSize,
  ) {
    final Vector2 lineDir = lineEnd - lineStart;
    final Vector2 boxMax = boxPos + boxSize;

    double tMin = 0;
    double tMax = 1;

    for (int i = 0; i < 2; i++) {
      final double dir = lineDir[i];
      final double start = lineStart[i];
      final double min = boxPos[i];
      final double max = boxMax[i];

      if (dir.abs() < MathUtils.epsilon) {
        // Line is parallel to the axis
        if (start < min || start > max) return false;
      } else {
        // Calculate intersection times
        final double t1 = (min - start) / dir;
        final double t2 = (max - start) / dir;

        final double tEnter = math.min(t1, t2);
        final double tExit = math.max(t1, t2);

        tMin = math.max(tMin, tEnter);
        tMax = math.min(tMax, tExit);

        if (tMin > tMax) return false;
      }
    }

    return tMin <= tMax;
  }

  /// Raycast against multiple AABBs and return the closest hit
  static RaycastHit? raycastAABBs(
    Vector2 rayStart,
    Vector2 rayDir,
    List<CollisionBox> boxes,
  ) {
    RaycastHit? closestHit;
    double closestDistance = double.infinity;

    for (final CollisionBox box in boxes) {
      final RaycastHit? hit = raycastAABB(rayStart, rayDir, box.position, box.size);
      if (hit != null && hit.distance < closestDistance) {
        closestHit = hit;
        closestDistance = hit.distance;
      }
    }

    return closestHit;
  }

  /// Raycast against a single AABB
  static RaycastHit? raycastAABB(
    Vector2 rayStart,
    Vector2 rayDir,
    Vector2 boxPos,
    Vector2 boxSize,
  ) {
    final Vector2 boxMax = boxPos + boxSize;

    double tMin = 0;
    double tMax = double.infinity;
    Vector2? hitNormal;

    for (int i = 0; i < 2; i++) {
      final double dir = rayDir[i];
      final double start = rayStart[i];
      final double min = boxPos[i];
      final double max = boxMax[i];

      if (dir.abs() < MathUtils.epsilon) {
        // Ray is parallel to the axis
        if (start < min || start > max) return null;
      } else {
        // Calculate intersection times
        final double t1 = (min - start) / dir;
        final double t2 = (max - start) / dir;

        final double tEnter = math.min(t1, t2);
        final double tExit = math.max(t1, t2);

        if (tEnter > tMin) {
          tMin = tEnter;
          // Determine which face we hit
          if (i == 0) {
            hitNormal = Vector2(dir > 0 ? -1 : 1, 0);
          } else {
            hitNormal = Vector2(0, dir > 0 ? -1 : 1);
          }
        }

        tMax = math.min(tMax, tExit);

        if (tMin > tMax) return null;
      }
    }

    if (tMin >= 0 && tMin <= rayDir.length) {
      final Vector2 hitPoint = rayStart + rayDir.normalized() * tMin;
      return RaycastHit(
        point: hitPoint,
        normal: hitNormal ?? Vector2.zero(),
        distance: tMin,
      );
    }

    return null;
  }

  /// Calculate collision resolution for two AABBs
  static CollisionResolution resolveAABBCollision(
    Vector2 pos1,
    Vector2 size1,
    Vector2 vel1,
    Vector2 pos2,
    Vector2 size2,
    Vector2 vel2, {
    bool immovable2 = false,
  }) {
    // Calculate overlap
    final double overlapX = math.min(pos1.x + size1.x, pos2.x + size2.x) - math.max(pos1.x, pos2.x);
    final double overlapY = math.min(pos1.y + size1.y, pos2.y + size2.y) - math.max(pos1.y, pos2.y);

    if (overlapX <= 0 || overlapY <= 0) {
      return CollisionResolution(); // No collision
    }

    Vector2 separation;
    Vector2 normal;

    // Resolve along the axis with smallest overlap
    if (overlapX < overlapY) {
      // Horizontal collision
      final double centerDiff = (pos1.x + size1.x / 2) - (pos2.x + size2.x / 2);
      if (centerDiff < 0) {
        separation = Vector2(-overlapX, 0);
        normal = Vector2(-1, 0);
      } else {
        separation = Vector2(overlapX, 0);
        normal = Vector2(1, 0);
      }
    } else {
      // Vertical collision
      final double centerDiff = (pos1.y + size1.y / 2) - (pos2.y + size2.y / 2);
      if (centerDiff < 0) {
        separation = Vector2(0, -overlapY);
        normal = Vector2(0, -1);
      } else {
        separation = Vector2(0, overlapY);
        normal = Vector2(0, 1);
      }
    }

    return CollisionResolution(
      hasCollision: true,
      separation: separation,
      normal: normal,
      depth: math.min(overlapX, overlapY),
    );
  }

  /// Calculate elastic collision response for two objects
  static CollisionResponse calculateElasticResponse(
    double mass1,
    Vector2 vel1,
    double mass2,
    Vector2 vel2,
    Vector2 normal, {
    double restitution = 0.8,
  }) {
    final double totalMass = mass1 + mass2;
    final Vector2 relativeVel = vel1 - vel2;
    final double separatingVel = relativeVel.dot(normal);

    // Don't resolve if objects are separating
    if (separatingVel > 0) {
      return CollisionResponse(newVel1: vel1, newVel2: vel2);
    }

    // Calculate impulse
    final double impulse = -(1 + restitution) * separatingVel / totalMass;
    final Vector2 impulseVector = normal * impulse;

    // Apply impulse to velocities
    final Vector2 newVel1 = vel1 + impulseVector * mass2;
    final Vector2 newVel2 = vel2 - impulseVector * mass1;

    return CollisionResponse(newVel1: newVel1, newVel2: newVel2);
  }

  /// Check if a moving AABB will collide with a static AABB
  static SweptCollision? sweptAABBCollision(
    Vector2 movingPos,
    Vector2 movingSize,
    Vector2 velocity,
    Vector2 staticPos,
    Vector2 staticSize,
  ) {
    // Expand the static box by the moving box's size
    final Vector2 expandedPos = staticPos - movingSize;
    final Vector2 expandedSize = staticSize + movingSize;

    // Raycast the center of the moving box against the expanded static box
    final RaycastHit? hit = raycastAABB(movingPos, velocity, expandedPos, expandedSize);

    if (hit != null && hit.distance <= velocity.length) {
      return SweptCollision(
        time: hit.distance / velocity.length,
        normal: hit.normal,
        hitPoint: hit.point,
      );
    }

    return null;
  }

  /// Calculate the minimum translation vector to separate two overlapping AABBs
  static Vector2? calculateMTV(
    Vector2 pos1,
    Vector2 size1,
    Vector2 pos2,
    Vector2 size2,
  ) {
    // Calculate overlap on each axis
    final double overlapX = math.min(pos1.x + size1.x, pos2.x + size2.x) - math.max(pos1.x, pos2.x);
    final double overlapY = math.min(pos1.y + size1.y, pos2.y + size2.y) - math.max(pos1.y, pos2.y);

    // No overlap means no collision
    if (overlapX <= 0 || overlapY <= 0) return null;

    // Choose the axis with minimum overlap
    if (overlapX < overlapY) {
      // Separate along X axis
      final double centerDiff = (pos1.x + size1.x / 2) - (pos2.x + size2.x / 2);
      return Vector2(centerDiff < 0 ? -overlapX : overlapX, 0);
    } else {
      // Separate along Y axis
      final double centerDiff = (pos1.y + size1.y / 2) - (pos2.y + size2.y / 2);
      return Vector2(0, centerDiff < 0 ? -overlapY : overlapY);
    }
  }

  /// Check collision using Separating Axis Theorem (SAT) for polygons
  static bool satCollision(List<Vector2> poly1, List<Vector2> poly2) {
    final List<Vector2> allAxes = <Vector2>[];

    // Get axes from both polygons
    allAxes.addAll(_getPolygonAxes(poly1));
    allAxes.addAll(_getPolygonAxes(poly2));

    // Test each axis
    for (final Vector2 axis in allAxes) {
      final Projection proj1 = _projectPolygon(poly1, axis);
      final Projection proj2 = _projectPolygon(poly2, axis);

      if (proj1.max < proj2.min || proj2.max < proj1.min) {
        return false; // Separating axis found
      }
    }

    return true; // No separating axis found, collision detected
  }

  /// Get the perpendicular axes of a polygon for SAT
  static List<Vector2> _getPolygonAxes(List<Vector2> polygon) {
    final List<Vector2> axes = <Vector2>[];

    for (int i = 0; i < polygon.length; i++) {
      final Vector2 current = polygon[i];
      final Vector2 next = polygon[(i + 1) % polygon.length];
      final Vector2 edge = next - current;
      final Vector2 axis = Vector2(-edge.y, edge.x).normalized();
      axes.add(axis);
    }

    return axes;
  }

  /// Project a polygon onto an axis
  static Projection _projectPolygon(List<Vector2> polygon, Vector2 axis) {
    double min = polygon[0].dot(axis);
    double max = min;

    for (int i = 1; i < polygon.length; i++) {
      final double projection = polygon[i].dot(axis);
      min = math.min(min, projection);
      max = math.max(max, projection);
    }

    return Projection(min: min, max: max);
  }
}

/// Represents a collision box for spatial partitioning
class CollisionBox {
  CollisionBox({
    required this.position,
    required this.size,
    this.userData,
  });
  Vector2 position;
  Vector2 size;
  dynamic userData;

  Vector2 get center => position + size / 2;
  Vector2 get min => position;
  Vector2 get max => position + size;
}

/// Result of a raycast operation
class RaycastHit {
  RaycastHit({
    required this.point,
    required this.normal,
    required this.distance,
  });
  final Vector2 point;
  final Vector2 normal;
  final double distance;
}

/// Result of collision resolution
class CollisionResolution {
  CollisionResolution({
    this.hasCollision = false,
    Vector2? separation,
    Vector2? normal,
    this.depth = 0.0,
  })  : separation = separation ?? Vector2.zero(),
        normal = normal ?? Vector2.zero();
  final bool hasCollision;
  final Vector2 separation;
  final Vector2 normal;
  final double depth;
}

/// Result of collision response calculation
class CollisionResponse {
  CollisionResponse({
    required this.newVel1,
    required this.newVel2,
  });
  final Vector2 newVel1;
  final Vector2 newVel2;
}

/// Result of swept collision detection
class SweptCollision {
  SweptCollision({
    required this.time,
    required this.normal,
    required this.hitPoint,
  });
  final double time; // Time of collision (0-1)
  final Vector2 normal;
  final Vector2 hitPoint;
}

/// Projection of a polygon onto an axis
class Projection {
  Projection({required this.min, required this.max});
  final double min;
  final double max;
}

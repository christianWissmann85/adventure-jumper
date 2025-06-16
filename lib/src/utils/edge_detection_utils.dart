import 'package:flame/components.dart';

import '../components/collision_component.dart';
import 'collision_utils.dart';

/// Edge detection utilities for platform awareness
/// Provides methods to detect platform boundaries and calculate edge proximity
class EdgeDetectionUtils {
  // Private constructor to prevent instantiation
  EdgeDetectionUtils._();

  /// T2.6.1: Detect platform edges using raycasts near player feet
  /// Returns edge detection data for left and right sides
  static EdgeDetectionResult detectPlatformEdges({
    required Vector2 playerPosition,
    required Vector2 playerSize,
    required List<CollisionComponent> platforms,
    double detectionThreshold = 32.0,
    double raycastDepth = 16.0,
  }) {
    // Calculate raycast starting positions near player feet
    final double playerBottom = playerPosition.y + playerSize.y;
    final double playerLeft = playerPosition.x;
    final double playerRight = playerPosition.x + playerSize.x;

    // Raycast downward from left and right edges of player
    final Vector2 leftRayStart = Vector2(playerLeft - 4.0, playerBottom - 8.0);
    final Vector2 rightRayStart =
        Vector2(playerRight + 4.0, playerBottom - 8.0);
    final Vector2 rayDirection = Vector2(0, raycastDepth); // Downward

    // Find platform edges by raycasting
    bool isNearLeftEdge = false;
    bool isNearRightEdge = false;
    double leftEdgeDistance = double.infinity;
    double rightEdgeDistance = double.infinity;
    Vector2? leftEdgePosition;
    Vector2? rightEdgePosition;

    // Check left edge
    RaycastHit? leftHit =
        _raycastToPlatforms(leftRayStart, rayDirection, platforms);
    if (leftHit == null) {
      // No platform found to the left, we're near a left edge
      leftEdgeDistance =
          _calculateEdgeDistance(playerPosition, playerSize, 'left', platforms);
      if (leftEdgeDistance <= detectionThreshold) {
        isNearLeftEdge = true;
        leftEdgePosition = Vector2(playerLeft, playerBottom);
      }
    }

    // Check right edge
    RaycastHit? rightHit =
        _raycastToPlatforms(rightRayStart, rayDirection, platforms);
    if (rightHit == null) {
      // No platform found to the right, we're near a right edge
      rightEdgeDistance = _calculateEdgeDistance(
        playerPosition,
        playerSize,
        'right',
        platforms,
      );
      if (rightEdgeDistance <= detectionThreshold) {
        isNearRightEdge = true;
        rightEdgePosition = Vector2(playerRight, playerBottom);
      }
    }

    return EdgeDetectionResult(
      isNearLeftEdge: isNearLeftEdge,
      isNearRightEdge: isNearRightEdge,
      leftEdgeDistance: leftEdgeDistance,
      rightEdgeDistance: rightEdgeDistance,
      leftEdgePosition: leftEdgePosition,
      rightEdgePosition: rightEdgePosition,
    );
  }

  /// T2.6.2: Calculate precise edge proximity using platform bounds
  static double calculateEdgeProximity({
    required Vector2 playerPosition,
    required Vector2 playerSize,
    required List<CollisionComponent> platforms,
    required String side, // 'left' or 'right'
  }) {
    return _calculateEdgeDistance(playerPosition, playerSize, side, platforms);
  }

  /// T2.6.1: Raycast to multiple platforms and return closest hit
  static RaycastHit? _raycastToPlatforms(
    Vector2 rayStart,
    Vector2 rayDirection,
    List<CollisionComponent> platforms,
  ) {
    RaycastHit? closestHit;
    double closestDistance = double.infinity;

    for (final platform in platforms) {
      // In tests, use hitboxOffset directly since there's no parent component
      final Vector2 position = platform.hitbox.isMounted
          ? platform.hitbox.position
          : platform.hitboxOffset;

      final RaycastHit? hit = CollisionUtils.raycastAABB(
        rayStart,
        rayDirection,
        position,
        platform.hitboxSize,
      );

      if (hit != null && hit.distance < closestDistance) {
        closestDistance = hit.distance;
        closestHit = hit;
      }
    }

    return closestHit;
  }

  /// T2.6.2: Calculate distance to nearest platform edge
  static double _calculateEdgeDistance(
    Vector2 playerPosition,
    Vector2 playerSize,
    String side,
    List<CollisionComponent> platforms,
  ) {
    double minDistance = double.infinity;
    final double playerCenterY = playerPosition.y + playerSize.y / 2;

    for (final platform in platforms) {
      // In tests, use hitboxOffset directly since there's no parent component
      final Vector2 platformPos = platform.hitbox.isMounted
          ? platform.hitbox.position
          : platform.hitboxOffset;
      final Vector2 platformSize = platform.hitboxSize;
      final double platformTop = platformPos.y;
      final double platformBottom = platformPos.y + platformSize.y;

      // Only consider platforms at similar Y level (player could be standing on them)
      if (playerCenterY >= platformTop &&
          playerCenterY <= platformBottom + playerSize.y) {
        double distance;

        if (side == 'left') {
          // Distance from player's left edge to platform's right edge
          final double playerLeft = playerPosition.x;
          final double platformRight = platformPos.x + platformSize.x;
          distance = (playerLeft - platformRight).abs();
        } else {
          // Distance from player's right edge to platform's left edge
          final double playerRight = playerPosition.x + playerSize.x;
          final double platformLeft = platformPos.x;
          distance = (platformLeft - playerRight).abs();
        }

        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }

    return minDistance;
  }

  /// T2.6.4: Validate edge detection for testing
  static bool validateEdgeDetection({
    required Vector2 playerPosition,
    required Vector2 playerSize,
    required Vector2 platformPosition,
    required Vector2 platformSize,
    required double threshold,
    required String expectedSide,
  }) {
    final List<CollisionComponent> testPlatforms = [
      CollisionComponent(
        hitboxSize: platformSize,
        hitboxOffset: platformPosition,
      ),
    ];

    final EdgeDetectionResult result = detectPlatformEdges(
      playerPosition: playerPosition,
      playerSize: playerSize,
      platforms: testPlatforms,
      detectionThreshold: threshold,
    );

    if (expectedSide == 'left') {
      return result.isNearLeftEdge;
    } else if (expectedSide == 'right') {
      return result.isNearRightEdge;
    } else if (expectedSide == 'none') {
      return !result.isNearLeftEdge && !result.isNearRightEdge;
    }

    return false;
  }
}

/// Result of edge detection operation
class EdgeDetectionResult {
  const EdgeDetectionResult({
    required this.isNearLeftEdge,
    required this.isNearRightEdge,
    required this.leftEdgeDistance,
    required this.rightEdgeDistance,
    this.leftEdgePosition,
    this.rightEdgePosition,
  });

  final bool isNearLeftEdge;
  final bool isNearRightEdge;
  final double leftEdgeDistance;
  final double rightEdgeDistance;
  final Vector2? leftEdgePosition;
  final Vector2? rightEdgePosition;

  bool get isNearAnyEdge => isNearLeftEdge || isNearRightEdge;
}

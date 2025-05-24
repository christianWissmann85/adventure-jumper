import 'dart:math' as math;

import 'package:flame/components.dart';

/// Mathematical utility functions for the Adventure Jumper game
/// Provides common calculations for 2D platformer mechanics
class MathUtils {
  // Private constructor to prevent instantiation
  MathUtils._();

  // Mathematical constants
  static const double pi = math.pi;
  static const double twoPi = 2 * math.pi;
  static const double halfPi = math.pi / 2;
  static const double radToDeg = 180.0 / math.pi;
  static const double degToRad = math.pi / 180.0;
  static const double epsilon = 0.0001;

  /// Clamp a value between min and max
  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  /// Clamp an integer value between min and max
  static int clampInt(int value, int min, int max) {
    return math.max(min, math.min(max, value));
  }

  /// Linear interpolation between two values
  static double lerp(double a, double b, double t) {
    return a + (b - a) * clamp(t, 0, 1);
  }

  /// Smooth step interpolation (ease-in-out)
  static double smoothStep(double edge0, double edge1, double x) {
    final double t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
    return t * t * (3.0 - 2.0 * t);
  }

  /// Smoother step interpolation (more gradual ease)
  static double smootherStep(double edge0, double edge1, double x) {
    final double t = clamp((x - edge0) / (edge1 - edge0), 0, 1);
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
  }

  /// Calculate distance between two 2D points
  static double distance(Vector2 a, Vector2 b) {
    return (a - b).length;
  }

  /// Calculate squared distance (faster than distance for comparisons)
  static double distanceSquared(Vector2 a, Vector2 b) {
    return (a - b).length2;
  }

  /// Calculate Manhattan distance (sum of absolute differences)
  static double manhattanDistance(Vector2 a, Vector2 b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  /// Normalize an angle to the range [0, 2π]
  static double normalizeAngle(double angle) {
    double normalizedAngle = angle;
    while (normalizedAngle < 0) {
      normalizedAngle += twoPi;
    }
    while (normalizedAngle >= twoPi) {
      normalizedAngle -= twoPi;
    }
    return normalizedAngle;
  }

  /// Calculate the shortest angular difference between two angles
  static double angleDifference(double a, double b) {
    double diff = normalizeAngle(b - a);
    if (diff > pi) diff -= twoPi;
    return diff;
  }

  /// Move an angle towards a target angle by a maximum delta
  static double moveTowardsAngle(
    double current,
    double target,
    double maxDelta,
  ) {
    final double diff = angleDifference(current, target);
    if (diff.abs() <= maxDelta) return target;
    return normalizeAngle(current + (diff > 0 ? 1.0 : -1.0) * maxDelta);
  }

  /// Check if a value is approximately equal to another within epsilon
  static bool approximately(double a, double b, [double eps = epsilon]) {
    return (a - b).abs() < eps;
  }

  /// Check if a value is approximately zero
  static bool isZero(double value, [double eps = epsilon]) {
    return value.abs() < eps;
  }

  /// Round a value to a specified number of decimal places
  static double roundTo(double value, int decimals) {
    final num factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Calculate a smooth bounce interpolation
  static double bounce(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      final double adjustedT = t - 1.5 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.75;
    } else if (t < 2.5 / 2.75) {
      final double adjustedT = t - 2.25 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.9375;
    } else {
      final double adjustedT = t - 2.625 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.984375;
    }
  }

  /// Calculate elastic interpolation
  static double elastic(double t) {
    if (t == 0 || t == 1) return t;
    return -math.pow(2, 10 * (t - 1)) * math.sin((t - 1.1) * 5 * pi);
  }

  /// Map a value from one range to another
  static double mapRange(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    final double ratio = (value - fromMin) / (fromMax - fromMin);
    return toMin + ratio * (toMax - toMin);
  }

  /// Generate a random float between min and max
  static double randomRange(double min, double max, [math.Random? random]) {
    random ??= math.Random();
    return min + random.nextDouble() * (max - min);
  }

  /// Generate a random integer between min and max (inclusive)
  static int randomRangeInt(int min, int max, [math.Random? random]) {
    random ??= math.Random();
    return min + random.nextInt(max - min + 1);
  }

  /// Calculate 2D cross product (useful for determining side of a point relative to a line)
  static double cross2D(Vector2 a, Vector2 b) {
    return a.x * b.y - a.y * b.x;
  }

  /// Calculate the perpendicular vector (90 degrees counterclockwise)
  static Vector2 perpendicular(Vector2 v) {
    return Vector2(-v.y, v.x);
  }

  /// Project vector a onto vector b
  static Vector2 project(Vector2 a, Vector2 b) {
    final double dot = a.dot(b);
    final double length2 = b.length2;
    if (length2 < epsilon) return Vector2.zero();
    return b * (dot / length2);
  }

  /// Reflect vector across a normal
  static Vector2 reflect(Vector2 vector, Vector2 normal) {
    return vector - normal * (2.0 * vector.dot(normal));
  }

  /// Calculate the angle between two vectors in radians
  static double angleBetween(Vector2 a, Vector2 b) {
    final double dot = a.dot(b);
    final double lengths = a.length * b.length;
    if (lengths < epsilon) return 0;
    return math.acos(clamp(dot / lengths, -1, 1));
  }

  /// Rotate a 2D vector by an angle (in radians)
  static Vector2 rotateVector(Vector2 vector, double angle) {
    final double cos = math.cos(angle);
    final double sin = math.sin(angle);
    return Vector2(
      vector.x * cos - vector.y * sin,
      vector.x * sin + vector.y * cos,
    );
  }

  /// Calculate the area of a triangle given three points
  static double triangleArea(Vector2 a, Vector2 b, Vector2 c) {
    return ((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)).abs() / 2.0;
  }

  /// Check if a point is inside a triangle
  static bool pointInTriangle(Vector2 point, Vector2 a, Vector2 b, Vector2 c) {
    final double area = triangleArea(a, b, c);
    final double area1 = triangleArea(point, b, c);
    final double area2 = triangleArea(a, point, c);
    final double area3 = triangleArea(a, b, point);

    return approximately(area, area1 + area2 + area3);
  }

  /// Calculate Bezier curve point at parameter t
  static Vector2 bezierPoint(
    Vector2 p0,
    Vector2 p1,
    Vector2 p2,
    Vector2 p3,
    double t,
  ) {
    final double u = 1.0 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    return p0 * uuu + p1 * (3 * uu * t) + p2 * (3 * u * tt) + p3 * ttt;
  }

  /// Calculate the derivative of a Bezier curve (tangent vector)
  static Vector2 bezierDerivative(
    Vector2 p0,
    Vector2 p1,
    Vector2 p2,
    Vector2 p3,
    double t,
  ) {
    final double u = 1.0 - t;
    final double tt = t * t;
    final double uu = u * u;

    return (p1 - p0) * (3 * uu) + (p2 - p1) * (6 * u * t) + (p3 - p2) * (3 * tt);
  }

  /// Calculate spring force for physics simulations
  static double springForce(
    double displacement,
    double stiffness,
    double damping,
    double velocity,
  ) {
    return -stiffness * displacement - damping * velocity;
  }

  /// Calculate gravity acceleration based on mass and distance
  static double gravitationalForce(
    double mass1,
    double mass2,
    double distance, [
    double G = 6.674e-11,
  ]) {
    return G * mass1 * mass2 / (distance * distance);
  }

  /// Calculate terminal velocity for falling objects
  static double terminalVelocity(
    double mass,
    double dragCoefficient,
    double airDensity,
    double area,
  ) {
    return math.sqrt((2 * mass * 9.81) / (dragCoefficient * airDensity * area));
  }

  /// Convert screen coordinates to world coordinates
  static Vector2 screenToWorld(
    Vector2 screenPos,
    Vector2 cameraPos,
    double cameraZoom,
  ) {
    return (screenPos / cameraZoom) + cameraPos;
  }

  /// Convert world coordinates to screen coordinates
  static Vector2 worldToScreen(
    Vector2 worldPos,
    Vector2 cameraPos,
    double cameraZoom,
  ) {
    return (worldPos - cameraPos) * cameraZoom;
  }

  /// Generate Perlin noise value (simplified implementation)
  static double perlinNoise(double x, double y, [int seed = 0]) {
    // Simple pseudo-random function based on coordinates
    int n = (x * 374761393 + y * 668265263 + seed).toInt();
    n = (n << 13) ^ n;
    return 1.0 - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
  }

  /// Calculate fractal noise (multiple octaves of Perlin noise)
  static double fractalNoise(
    double x,
    double y,
    int octaves,
    double persistence, [
    int seed = 0,
  ]) {
    double value = 0;
    double amplitude = 1;
    double frequency = 1;
    double maxValue = 0;

    for (int i = 0; i < octaves; i++) {
      value += perlinNoise(x * frequency, y * frequency, seed) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2.0;
    }

    return value / maxValue;
  }

  /// Calculate the next power of 2 greater than or equal to n
  static int nextPowerOfTwo(int n) {
    int result = n - 1;
    result |= result >> 1;
    result |= result >> 2;
    result |= result >> 4;
    result |= result >> 8;
    result |= result >> 16;
    return result + 1;
  }

  /// Check if a number is a power of 2
  static bool isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }
}

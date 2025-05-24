import 'dart:ui' as ui;

import 'package:flame/components.dart';

/// Simple camera class for the game world
/// Used for tracking player position and implementing screen effects
class Camera {
  /// Creates a new camera with the specified position
  Camera({
    Vector2? position,
    double? zoom,
    double? rotation,
    Vector2? viewportSize,
    ui.Rect? bounds,
  }) {
    if (position != null) this.position = position;
    if (zoom != null) this.zoom = zoom;
    if (rotation != null) this.rotation = rotation;
    if (viewportSize != null) this.viewportSize = viewportSize;
    if (bounds != null) this.bounds = bounds;
  }
  // Camera position in the world
  Vector2 position = Vector2.zero();

  // Camera zoom level (1.0 is normal)
  double zoom = 1;

  // Camera rotation in radians
  double rotation = 0;
  // Viewport dimensions
  Vector2 viewportSize = Vector2.zero();

  // Camera bounds
  ui.Rect? bounds;

  // Target entity for auto-following
  Vector2? target;

  /// Updates camera position, zoom, and rotation
  void update(double dt) {
    // Camera following logic would go here
    if (target != null) {
      // Simple follow algorithm
      position = Vector2(
        position.x + (target!.x - position.x) * 0.1,
        position.y + (target!.y - position.y) * 0.1,
      );

      // Apply bounds if set
      if (bounds != null) {
        position.x = position.x.clamp(bounds!.left, bounds!.right);
        position.y = position.y.clamp(bounds!.top, bounds!.bottom);
      }
    }
  }

  /// World position to screen position
  Vector2 worldToScreen(Vector2 worldPos) {
    return (worldPos - position) * zoom + viewportSize / 2;
  }

  /// Screen position to world position
  Vector2 screenToWorld(Vector2 screenPos) {
    return (screenPos - viewportSize / 2) / zoom + position;
  }

  /// Set camera target for following
  void follow(Vector2 targetPosition) {
    target = targetPosition;
  }
}

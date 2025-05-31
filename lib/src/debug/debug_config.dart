/// Debug configuration for the Adventure Jumper game
/// Controls various debug features and logging levels
class DebugConfig {
  // === SPRITE AND RENDERING DEBUG ===
  /// Enable detailed sprite component logging
  static const bool enableSpriteDebugLogging = true;

  /// Enable visual debug overlay on screen
  static const bool enableVisualDebugOverlay = true;

  /// Enable player animator debug logging
  static const bool enablePlayerAnimatorLogging = true;

  /// Enable component hierarchy debugging
  static const bool enableComponentHierarchyLogging = true;

  // === VISUAL DEBUG FEATURES ===
  /// Show bounding boxes around sprites
  static const bool showSpriteBoundingBoxes = false;

  /// Show collision boxes
  static const bool showCollisionBoxes = false;

  /// Show camera bounds
  static const bool showCameraBounds = false;

  // === PERFORMANCE DEBUG ===
  /// Enable FPS display in debug overlay
  static const bool showFpsInDebugOverlay = true;

  /// Enable memory usage display
  static const bool showMemoryUsage = false;

  // === SYSTEM DEBUG ===
  /// Enable input system debug logging
  static const bool enableInputSystemLogging = false;

  /// Enable physics system debug logging
  static const bool enablePhysicsSystemLogging = false;

  /// Enable movement system debug logging
  static const bool enableMovementSystemLogging = false;

  // === DEBUG HELPERS ===
  /// Print debug message only if logging is enabled for the category
  static void debugPrint(String message, {bool condition = true}) {
    if (condition) {
      print(message);
    }
  }

  /// Print sprite debug message only if sprite logging is enabled
  static void spritePrint(String message) {
    debugPrint(message, condition: enableSpriteDebugLogging);
  }

  /// Print animator debug message only if animator logging is enabled
  static void animatorPrint(String message) {
    debugPrint(message, condition: enablePlayerAnimatorLogging);
  }

  /// Print component hierarchy debug message only if hierarchy logging is enabled
  static void hierarchyPrint(String message) {
    debugPrint(message, condition: enableComponentHierarchyLogging);
  }
}

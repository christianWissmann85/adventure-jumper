import 'package:flutter/material.dart';

/// Configuration and constants for Adventure Jumper
/// Contains game settings, physics constants, and configuration values
class GameConfig {
  // Game Constants
  static const String gameTitle = 'Adventure Jumper';
  static const String gameVersion = '0.1.0';
  static const String version = gameVersion; // Alias for compatibility

  // Display Settings
  static const Color backgroundColor = Color(0xFF2E3440);
  static const double targetFps = 60;
  // Physics Constants
  static const double gravity = 980; // pixels per second squared
  static const double playerSpeed = 200; // pixels per second
  static const double friction = 0.8;

  // Jump Parameters (T2.3.3: Configurable jump mechanics)
  static const double jumpForce = -450; // pixels/second (negative = up)
  static const double jumpHoldForce =
      -200; // Additional force when holding jump
  static const double jumpCutOffMultiplier =
      0.5; // Velocity multiplier for jump cut-off
  static const double minJumpHeight = -200; // Minimum jump velocity
  static const double maxJumpHeight = -600; // Maximum jump velocity with hold
  static const double jumpHoldMaxTime =
      0.3; // Maximum time to hold jump (seconds)
  static const double jumpBufferTime = 0.1; // Jump input buffer time
  static const double jumpCoyoteTime =
      0.15; // Coyote time for jump grace period
  static const double jumpCooldown = 0.1; // Cooldown between jumps

  // Player Settings
  static const double playerWidth = 32;
  static const double playerHeight = 48;
  static const double playerMaxHealth = 100;

  // Camera Settings
  static const double cameraFollowSpeed = 5;
  static const double cameraZoom = 1;

  // Debug Settings
  static const bool debugMode = false;
  static const bool showDebugInfo = false;
  static const bool showCollisionBounds = false;

  // Asset Paths
  static const String spritesPath = 'images/';
  static const String audioPath = 'audio/';
  static const String levelsPath = 'levels/';

  // Input Constants
  static const double inputBufferTime = 0.1; // seconds
  static const double coyoteTime = 0.15; // seconds for jump grace period

  // World Constants
  static const double tileSize = 16;
  static const int worldChunkSize = 32; // tiles per chunk
}

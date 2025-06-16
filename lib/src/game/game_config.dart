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
  static const double targetFps =
      60; // Physics Constants - T2.13.1: Fine-tuned for optimal responsiveness & feel
  static const double gravity =
      1400; // pixels per second squared (increased for snappier, more responsive feel)
  static const double playerSpeed =
      280; // pixels per second (enhanced base speed for better flow)
  static const double friction =
      0.65; // Further reduced for maximum responsiveness
  // Jump Parameters - T2.13.1: Optimized for expressive movement and sub-2-frame response
  static const double jumpForce =
      -720; // pixels/second (increased for better platform reach)
  static const double jumpHoldForce =
      -280; // Additional force when holding jump (increased for variable height expression)
  static const double jumpCutOffMultiplier =
      0.35; // Velocity multiplier for jump cut-off (more responsive cut-off)
  static const double minJumpHeight =
      -320; // Minimum jump velocity (enhanced for better minimum jump)
  static const double maxJumpHeight =
      -880; // Maximum jump velocity with hold (increased ceiling for expression)
  static const double jumpHoldMaxTime =
      0.25; // Maximum time to hold jump (slightly longer for higher jumps)
  static const double jumpBufferTime =
      0.15; // Jump input buffer time (more generous for combo flow)
  static const double jumpCoyoteTime =
      0.20; // Coyote time for jump grace period (more forgiving for fluid play)
  static const double jumpCooldown =
      0.06; // Cooldown between jumps (faster for better combo potential)
  // T2.13.2: Enhanced horizontal movement for maximum responsiveness
  static const double playerAcceleration =
      1400; // pixels/second² (increased for ultra-responsive feel)
  static const double playerDeceleration =
      1800; // pixels/second² (enhanced for precision control)
  static const double airAcceleration =
      900; // pixels/second² (improved air control)
  static const double airDeceleration =
      650; // pixels/second² (balanced air movement)
  static const double maxWalkSpeed = 280; // pixels/second (enhanced base speed)
  static const double maxRunSpeed =
      450; // pixels/second (increased for fluid high-speed movement)
  // T2.13.3: Enhanced air control for maximum expressive movement
  static const double airControlMultiplier =
      0.75; // Increased multiplier for better air responsiveness
  static const double airSpeedRetention =
      0.90; // Higher retention for smoother momentum preservation
  static const double maxAirSpeed =
      350; // pixels/second (increased for better air expression)
  static const double airAccelerationBoost =
      1.3; // Enhanced boost for better air control feel
  static const double airTurnAroundSpeed =
      1100; // pixels/second² (faster direction changes for responsiveness)
  // T2.13.4: Optimized movement smoothing for jitter-free motion
  static const double velocitySmoothingFactor =
      0.12; // Enhanced smoothing for ultra-fluid transitions
  static const double inputSmoothingTime =
      0.06; // Reduced time for faster input response (sub-2-frame target)
  static const double minMovementThreshold =
      3.0; // Lower threshold for more precise movement (pixels/second)
  static const double accelerationSmoothingFactor =
      0.18; // Optimized smoothing for acceleration changes

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

/// Game constants and configuration values for Adventure Jumper
///
/// This file contains all static constants used throughout the game,
/// organized by categories for easy maintenance and configuration.
library;

import 'dart:ui';

/// Physics and movement constants - T2.13.1: Optimized for maximum responsiveness and fluid movement
class PhysicsConstants {
  // World physics - T2.13.1: Enhanced for sub-2-frame responsive feel
  static const double gravity =
      1400; // pixels/second² (increased for snappier, more responsive movement)
  static const double terminalVelocity =
      950; // pixels/second (slightly higher for better feel)
  static const double airResistance =
      0.012; // Further reduced for enhanced air control
  static const double groundFriction =
      0.65; // Reduced for maximum responsive ground movement

  // Player movement - T2.13.2: Enhanced for ultra-responsive acceleration and speeds
  static const double playerWalkSpeed =
      280; // pixels/second (enhanced base speed for better flow)
  static const double playerRunSpeed =
      450; // pixels/second (increased top speed for fluid movement)
  static const double playerJumpVelocity =
      -540; // pixels/second (enhanced for better arc and responsiveness)
  static const double playerDoubleJumpVelocity =
      -440; // Enhanced double jump feel
  static const double playerWallJumpVelocity =
      -470; // Improved wall jump responsiveness
  static const double playerWallSlideSpeed = 75; // Optimized for better control

  // Movement constraints - T2.13.2: Enhanced for maximum expressive movement
  static const double maxHorizontalSpeed =
      600; // Higher speed ceiling for expression
  static const double maxVerticalSpeed =
      1200; // Enhanced vertical limits for better jumps
  static const double coyoteTime =
      0.20; // seconds (more forgiving for fluid play)
  static const double jumpBufferTime =
      0.15; // seconds (more generous for combo flow)

  // Collision detection
  static const double collisionTolerance = 0.1;
  static const double slopeAngleLimit = 45; // degrees
}

/// Visual and rendering constants
class RenderConstants {
  // Screen and camera
  static const double baseResolutionWidth = 1920;
  static const double baseResolutionHeight = 1080;
  static const double pixelsPerUnit = 64; // pixels per game unit
  static const double cameraFollowSpeed = 5;
  static const double cameraLookAheadDistance = 100;

  // Animation
  static const double defaultAnimationSpeed = 1;
  static const int defaultSpriteFrameRate = 12; // fps
  static const double fadeTransitionDuration = 0.5; // seconds

  // Layers and depth
  static const int backgroundLayer = -100;
  static const int terrainLayer = 0;
  static const int decorationLayer = 10;
  static const int entityLayer = 20;
  static const int playerLayer = 30;
  static const int effectsLayer = 40;
  static const int uiLayer = 100;

  // Visual effects
  static const double defaultParticleLifetime = 2; // seconds
  static const int maxParticlesPerEmitter = 100;
  static const double screenShakeIntensity = 5;
  static const double screenShakeDuration = 0.3;
}

/// Game timing and progression constants
class GameConstants {
  // Core game timing
  static const double fixedTimeStep = 1.0 / 60.0; // 60 FPS
  static const double maxFrameTime = 1.0 / 20.0; // 20 FPS minimum
  static const int targetFrameRate = 60;

  // Level progression
  static const int totalLevels = 50;
  static const int levelsPerBiome = 10;
  static const int totalBiomes = 5;
  static const int starsPerLevel = 3;

  // Player stats
  static const int playerMaxHealth = 100;
  static const int playerStartingLives = 3;
  static const int playerMaxLives = 9;
  static const double invincibilityDuration = 2; // seconds
  static const double respawnDelay = 1.5; // seconds

  // Collectibles and scoring
  static const int coinValue = 10;
  static const int gemValue = 50;
  static const int treasureValue = 200;
  static const int enemyDefeatScore = 100;
  static const int levelCompletionBonus = 1000;
  static const int perfectLevelBonus = 5000; // no damage taken
}

/// Audio system constants
class AudioConstants {
  // Volume levels (0.0 to 1.0)
  static const double defaultMasterVolume = 0.8;
  static const double defaultMusicVolume = 0.7;
  static const double defaultSfxVolume = 0.8;
  static const double defaultVoiceVolume = 0.9;

  // Audio settings
  static const double fadeInDuration = 1; // seconds
  static const double fadeOutDuration = 0.5; // seconds
  static const int maxSimultaneousSounds = 32;
  static const double spatialAudioMaxDistance = 1000; // pixels
  static const double spatialAudioFalloffExponent = 2;

  // Music system
  static const double musicCrossfadeDuration = 2; // seconds
  static const bool enableDynamicMusic = true;
  static const double silenceBetweenTracks = 0.5; // seconds
}

/// User interface constants
class UIConstants {
  // HUD positioning and sizing
  static const double hudMargin = 20;
  static const double hudElementSpacing = 15;
  static const double healthBarWidth = 200;
  static const double healthBarHeight = 20;
  static const double minimapSize = 150;

  // Menu styling
  static const double buttonHeight = 60;
  static const double buttonSpacing = 20;
  static const double menuPadding = 40;
  static const double dialogueBoxHeight = 120;

  // Fonts and text
  static const double defaultFontSize = 16;
  static const double headerFontSize = 24;
  static const double titleFontSize = 32;
  static const double uiFontSize = 14;

  // Animation durations
  static const double menuTransitionDuration = 0.3; // seconds
  static const double buttonPressAnimation = 0.1; // seconds
  static const double tooltipDelay = 1; // seconds
  static const double notificationDuration = 3; // seconds
}

/// File paths and asset organization
class AssetPaths {
  // Base directories
  static const String images = 'images/';
  static const String audio = 'audio/';
  static const String data = 'data/';
  static const String fonts = 'fonts/';

  // Image subdirectories
  static const String sprites = '${images}sprites/';
  static const String backgrounds = '${images}backgrounds/';
  static const String ui = '${images}ui/';
  static const String effects = '${images}effects/';
  static const String tiles = '${images}tiles/';

  // Audio subdirectories
  static const String music = '${audio}music/';
  static const String sfx = '${audio}sfx/';
  static const String voice = '${audio}voice/';
  static const String ambient = '${audio}ambient/';

  // Data files
  static const String levels = '${data}levels/';
  static const String animations = '${data}animations/';
  static const String dialogue = '${data}dialogue/';
  static const String translations = '${data}translations/';

  // Player sprites
  static const String playerIdle = '${sprites}player/idle.png';
  static const String playerRun = '${sprites}player/run.png';
  static const String playerJump = '${sprites}player/jump.png';
  static const String playerFall = '${sprites}player/fall.png';

  // Common UI elements
  static const String buttonNormal = '${ui}button_normal.png';
  static const String buttonPressed = '${ui}button_pressed.png';
  static const String buttonDisabled = '${ui}button_disabled.png';
  static const String healthBarFill = '${ui}health_bar_fill.png';
  static const String healthBarEmpty = '${ui}health_bar_empty.png';
}

/// Input and control constants
class InputConstants {
  // Input timing
  static const double inputBufferDuration = 0.1; // seconds
  static const double doubleTapWindow = 0.3; // seconds
  static const double holdThreshold = 0.5; // seconds

  // Touch controls
  static const double touchDeadzone = 10; // pixels
  static const double swipeMinDistance = 50; // pixels
  static const double swipeMaxTime = 0.5; // seconds

  // Gamepad settings
  static const double analogStickDeadzone = 0.2; // 0.0 to 1.0
  static const double triggerDeadzone = 0.1; // 0.0 to 1.0
  static const double vibrationIntensity = 0.7; // 0.0 to 1.0
}

/// Debug and development constants
class DebugConstants {
  // Debug visualization
  static const Color collisionBoxColor = Color(0xFF00FF00);
  static const Color hitboxColor = Color(0xFFFF0000);
  static const Color velocityVectorColor = Color(0xFF0000FF);
  static const Color gridColor = Color(0x33FFFFFF);

  // Debug settings
  static const bool showCollisionBoxes = false;
  static const bool showVelocityVectors = false;
  static const bool showPerformanceMetrics = false;
  static const bool enableConsoleLogging = true;
  static const bool enableProfiler = false;

  // Performance thresholds
  static const double lowFpsThreshold = 45;
  static const double criticalFpsThreshold = 30;
  static const double highMemoryThreshold = 500; // MB
  static const double criticalMemoryThreshold = 800; // MB
}

/// Platform and device constants
class PlatformConstants {
  // Mobile-specific
  static const double mobileButtonSize = 80;
  static const double mobileJoystickSize = 120;
  static const bool enableHapticFeedback = true;

  // Desktop-specific
  static const bool enableKeyboardShortcuts = true;
  static const bool enableMouseControls = true;
  static const double scrollSensitivity = 1;

  // Web-specific
  static const bool enableWebGLRenderer = true;
  static const bool enableLocalStorage = true;
  static const int maxWebCacheSize = 50; // MB
}

/// Save system constants
class SaveConstants {
  // File management
  static const String saveFileExtension = '.ajsave';
  static const String saveDirectory = 'saves/';
  static const String backupDirectory = 'backups/';
  static const String settingsFileName = 'settings.json';

  // Save slots and versioning
  static const int maxSaveSlots = 5;
  static const int currentSaveVersion = 1;
  static const int maxBackupFiles = 10;

  // Auto-save settings
  static const bool enableAutoSave = true;
  static const double autoSaveInterval = 300; // seconds (5 minutes)
  static const bool saveOnLevelComplete = true;
  static const bool saveOnCheckpoint = true;
}

/// Color palette and theming constants
class ColorConstants {
  // Primary game colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryGreen = Color(0xFF7ED321);
  static const Color primaryRed = Color(0xFFD0021B);
  static const Color primaryYellow = Color(0xFFF5A623);
  static const Color primaryPurple = Color(0xFF9013FE);

  // UI colors
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2D2D2D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color accent = Color(0xFF4A90E2);

  // Health and status colors
  static const Color healthFull = Color(0xFF4CAF50);
  static const Color healthMedium = Color(0xFFFF9800);
  static const Color healthLow = Color(0xFFF44336);
  static const Color energyColor = Color(0xFF2196F3);
  static const Color experienceColor = Color(0xFF9C27B0);

  // Biome colors
  static const Color forestGreen = Color(0xFF2E7D32);
  static const Color desertYellow = Color(0xFFFBC02D);
  static const Color iceBlue = Color(0xFF0277BD);
  static const Color volcanoRed = Color(0xFFD32F2F);
  static const Color spaceBlack = Color(0xFF212121);
}

/// Mathematical constants used in game calculations
class MathConstants {
  static const double pi = 3.14159265359;
  static const double twoPi = 2 * pi;
  static const double halfPi = pi / 2;
  static const double radToDeg = 180.0 / pi;
  static const double degToRad = pi / 180.0;
  static const double epsilon = 0.000001;
  static const double goldenRatio = 1.618033988749;
}

/// String constants for localization keys
class LocalizationKeys {
  // Main menu
  static const String mainMenuTitle = 'main_menu.title';
  static const String playButton = 'main_menu.play';
  static const String settingsButton = 'main_menu.settings';
  static const String quitButton = 'main_menu.quit';

  // Gameplay
  static const String pauseGame = 'gameplay.pause';
  static const String resumeGame = 'gameplay.resume';
  static const String restartLevel = 'gameplay.restart_level';
  static const String levelComplete = 'gameplay.level_complete';
  static const String gameOver = 'gameplay.game_over';

  // Settings
  static const String audioSettings = 'settings.audio';
  static const String videoSettings = 'settings.video';
  static const String controlSettings = 'settings.controls';
  static const String masterVolume = 'settings.master_volume';
  static const String musicVolume = 'settings.music_volume';
  static const String sfxVolume = 'settings.sfx_volume';

  // HUD elements
  static const String health = 'hud.health';
  static const String score = 'hud.score';
  static const String lives = 'hud.lives';
  static const String time = 'hud.time';
  static const String coins = 'hud.coins';
}

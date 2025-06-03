/// Manages all game settings including audio, graphics, input, and gameplay preferences
/// Settings persist across all save files and game sessions
class Settings {
  Settings({
    this.masterVolume = 1.0,
    this.musicVolume = 0.8,
    this.sfxVolume = 1.0,
    this.voiceVolume = 1.0,
    this.ambientVolume = 0.6,
    this.muteWhenUnfocused = true,
    this.audioQuality = 'high',
    this.resolution = '1920x1080',
    this.fullscreen = false,
    this.vsync = true,
    this.frameRateLimit = 60,
    this.graphicsQuality = 'high',
    this.showFPS = false,
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.gamma = 1.0,
    this.particleEffects = true,
    this.screenShake = true,
    this.flashingEffects = true,
    this.motionBlur = false,
    this.bloom = true,
    this.particleDensity = 1.0,
    Map<String, String>? keyBindings,
    Map<String, String>? gamepadBindings,
    this.mouseSensitivity = 1.0,
    this.invertMouseY = false,
    this.gamepadSensitivity = 1.0,
    this.gamepadVibration = true,
    this.gamepadDeadzone = 0.2,
    this.difficulty = 'normal',
    this.autoSave = true,
    this.autoSaveInterval = 5,
    this.showHints = true,
    this.showTutorials = true,
    this.pauseOnFocusLoss = true,
    this.skipCutscenes = false,
    this.gameSpeed = 1.0,
    this.colorBlindAssist = false,
    this.colorBlindType = 'none',
    this.highContrast = false,
    this.largeText = false,
    this.subtitles = false,
    this.subtitleSize = 1.0,
    this.audioDescriptions = false,
    this.reducedMotion = false,
    this.simplifiedUI = false,
    this.uiScale = 1.0,
    this.language = 'en',
    this.dateFormat = 'MM/DD/YYYY',
    this.timeFormat = '12h',
    this.showDamageNumbers = true,
    this.showHealthBars = true,
    this.showMinimap = true,
    this.hudOpacity = 0.9,
    this.telemetryEnabled = true,
    this.crashReporting = true,
    this.analyticsEnabled = true,
    this.cloudSaveEnabled = true,
    this.autoUpdateEnabled = true,
    Map<String, dynamic>? advancedSettings,
    Map<String, dynamic>? experimentalFeatures,
  })  : keyBindings = keyBindings ?? _defaultKeyBindings(),
        gamepadBindings = gamepadBindings ?? _defaultGamepadBindings(),
        advancedSettings = advancedSettings ?? <String, dynamic>{},
        experimentalFeatures = experimentalFeatures ?? <String, dynamic>{};

  /// Create from JSON
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      masterVolume: (json['masterVolume'] as num? ?? 1.0).toDouble(),
      musicVolume: (json['musicVolume'] as num? ?? 0.8).toDouble(),
      sfxVolume: (json['sfxVolume'] as num? ?? 1.0).toDouble(),
      voiceVolume: (json['voiceVolume'] as num? ?? 1.0).toDouble(),
      ambientVolume: (json['ambientVolume'] as num? ?? 0.6).toDouble(),
      muteWhenUnfocused: json['muteWhenUnfocused'] as bool? ?? true,
      audioQuality: json['audioQuality'] as String? ?? 'high',
      resolution: json['resolution'] as String? ?? '1920x1080',
      fullscreen: json['fullscreen'] as bool? ?? false,
      vsync: json['vsync'] as bool? ?? true,
      frameRateLimit: json['frameRateLimit'] as int? ?? 60,
      graphicsQuality: json['graphicsQuality'] as String? ?? 'high',
      showFPS: json['showFPS'] as bool? ?? false,
      brightness: (json['brightness'] as num? ?? 1.0).toDouble(),
      contrast: (json['contrast'] as num? ?? 1.0).toDouble(),
      gamma: (json['gamma'] as num? ?? 1.0).toDouble(),
      particleEffects: json['particleEffects'] as bool? ?? true,
      screenShake: json['screenShake'] as bool? ?? true,
      flashingEffects: json['flashingEffects'] as bool? ?? true,
      motionBlur: json['motionBlur'] as bool? ?? false,
      bloom: json['bloom'] as bool? ?? true,
      particleDensity: (json['particleDensity'] as num? ?? 1.0).toDouble(),
      keyBindings: json['keyBindings'] != null
          ? Map<String, String>.from(
              json['keyBindings'] as Map<String, dynamic>,
            )
          : _defaultKeyBindings(),
      gamepadBindings: json['gamepadBindings'] != null
          ? Map<String, String>.from(
              json['gamepadBindings'] as Map<String, dynamic>,
            )
          : _defaultGamepadBindings(),
      mouseSensitivity: (json['mouseSensitivity'] as num? ?? 1.0).toDouble(),
      invertMouseY: json['invertMouseY'] as bool? ?? false,
      gamepadSensitivity:
          (json['gamepadSensitivity'] as num? ?? 1.0).toDouble(),
      gamepadVibration: json['gamepadVibration'] as bool? ?? true,
      gamepadDeadzone: (json['gamepadDeadzone'] as num? ?? 0.2).toDouble(),
      difficulty: json['difficulty'] as String? ?? 'normal',
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 5,
      showHints: json['showHints'] as bool? ?? true,
      showTutorials: json['showTutorials'] as bool? ?? true,
      pauseOnFocusLoss: json['pauseOnFocusLoss'] as bool? ?? true,
      skipCutscenes: json['skipCutscenes'] as bool? ?? false,
      gameSpeed: (json['gameSpeed'] as num? ?? 1.0).toDouble(),
      colorBlindAssist: json['colorBlindAssist'] as bool? ?? false,
      colorBlindType: json['colorBlindType'] as String? ?? 'none',
      highContrast: json['highContrast'] as bool? ?? false,
      largeText: json['largeText'] as bool? ?? false,
      subtitles: json['subtitles'] as bool? ?? false,
      subtitleSize: (json['subtitleSize'] as num? ?? 1.0).toDouble(),
      audioDescriptions: json['audioDescriptions'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      simplifiedUI: json['simplifiedUI'] as bool? ?? false,
      uiScale: (json['uiScale'] as num? ?? 1.0).toDouble(),
      language: json['language'] as String? ?? 'en',
      dateFormat: json['dateFormat'] as String? ?? 'MM/DD/YYYY',
      timeFormat: json['timeFormat'] as String? ?? '12h',
      showDamageNumbers: json['showDamageNumbers'] as bool? ?? true,
      showHealthBars: json['showHealthBars'] as bool? ?? true,
      showMinimap: json['showMinimap'] as bool? ?? true,
      hudOpacity: (json['hudOpacity'] as num? ?? 0.9).toDouble(),
      telemetryEnabled: json['telemetryEnabled'] as bool? ?? true,
      crashReporting: json['crashReporting'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      cloudSaveEnabled: json['cloudSaveEnabled'] as bool? ?? true,
      autoUpdateEnabled: json['autoUpdateEnabled'] as bool? ?? true,
      advancedSettings: json['advancedSettings'] != null
          ? Map<String, dynamic>.from(
              json['advancedSettings'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
      experimentalFeatures: json['experimentalFeatures'] != null
          ? Map<String, dynamic>.from(
              json['experimentalFeatures'] as Map<String, dynamic>,
            )
          : <String, dynamic>{},
    );
  }
  // Audio settings
  double masterVolume;
  double musicVolume;
  double sfxVolume;
  double voiceVolume;
  double ambientVolume;
  bool muteWhenUnfocused;
  String audioQuality; // 'low', 'medium', 'high'

  // Graphics settings
  String resolution; // '1920x1080', '1280x720', etc.
  bool fullscreen;
  bool vsync;
  int frameRateLimit; // 0 = unlimited, 30, 60, 120, etc.
  String graphicsQuality; // 'low', 'medium', 'high', 'ultra'
  bool showFPS;
  double brightness;
  double contrast;
  double gamma;

  // Visual effects settings
  bool particleEffects;
  bool screenShake;
  bool flashingEffects;
  bool motionBlur;
  bool bloom;
  double particleDensity; // 0.0 to 1.0

  // Input settings
  Map<String, String> keyBindings;
  Map<String, String> gamepadBindings;
  double mouseSensitivity;
  bool invertMouseY;
  double gamepadSensitivity;
  bool gamepadVibration;
  double gamepadDeadzone;

  // Gameplay settings
  String difficulty; // 'easy', 'normal', 'hard', 'expert'
  bool autoSave;
  int autoSaveInterval; // in minutes
  bool showHints;
  bool showTutorials;
  bool pauseOnFocusLoss;
  bool skipCutscenes;
  double gameSpeed; // 0.5 to 2.0

  // Accessibility settings
  bool colorBlindAssist;
  String colorBlindType; // 'protanopia', 'deuteranopia', 'tritanopia'
  bool highContrast;
  bool largeText;
  bool subtitles;
  double subtitleSize;
  bool audioDescriptions;
  bool reducedMotion;
  bool simplifiedUI;

  // UI settings
  double uiScale;
  String language;
  String dateFormat;
  String timeFormat;
  bool showDamageNumbers;
  bool showHealthBars;
  bool showMinimap;
  double hudOpacity;

  // Privacy and data settings
  bool telemetryEnabled;
  bool crashReporting;
  bool analyticsEnabled;
  bool cloudSaveEnabled;
  bool autoUpdateEnabled;

  // Advanced settings
  Map<String, dynamic> advancedSettings;
  Map<String, dynamic> experimentalFeatures;

  /// Default keyboard bindings
  static Map<String, String> _defaultKeyBindings() {
    return <String, String>{
      'move_left': 'a',
      'move_right': 'd',
      'jump': 'space',
      'crouch': 's',
      'interact': 'e',
      'attack': 'left_click',
      'special_attack': 'right_click',
      'inventory': 'i',
      'pause': 'escape',
      'run': 'left_shift',
      'map': 'm',
      'quick_save': 'f5',
      'quick_load': 'f9',
    };
  }

  /// Default gamepad bindings
  static Map<String, String> _defaultGamepadBindings() {
    return <String, String>{
      'move_left': 'left_stick_left',
      'move_right': 'left_stick_right',
      'jump': 'a',
      'crouch': 'right_stick_down',
      'interact': 'x',
      'attack': 'right_trigger',
      'special_attack': 'left_trigger',
      'inventory': 'y',
      'pause': 'start',
      'run': 'left_bumper',
      'map': 'back',
    };
  }

  /// Get volume for a specific audio category
  double getVolumeForCategory(String category) {
    switch (category) {
      case 'music':
        return masterVolume * musicVolume;
      case 'sfx':
        return masterVolume * sfxVolume;
      case 'voice':
        return masterVolume * voiceVolume;
      case 'ambient':
        return masterVolume * ambientVolume;
      default:
        return masterVolume;
    }
  }

  /// Set key binding
  void setKeyBinding(String action, String key) {
    keyBindings[action] = key;
  }

  /// Set gamepad binding
  void setGamepadBinding(String action, String button) {
    gamepadBindings[action] = button;
  }

  /// Get key for action
  String? getKeyForAction(String action) {
    return keyBindings[action];
  }

  /// Get gamepad button for action
  String? getGamepadButtonForAction(String action) {
    return gamepadBindings[action];
  }

  /// Reset to default settings
  void resetToDefaults() {
    final Settings defaultSettings = Settings();

    // Copy all default values
    masterVolume = defaultSettings.masterVolume;
    musicVolume = defaultSettings.musicVolume;
    sfxVolume = defaultSettings.sfxVolume;
    voiceVolume = defaultSettings.voiceVolume;
    ambientVolume = defaultSettings.ambientVolume;
    muteWhenUnfocused = defaultSettings.muteWhenUnfocused;
    audioQuality = defaultSettings.audioQuality;

    resolution = defaultSettings.resolution;
    fullscreen = defaultSettings.fullscreen;
    vsync = defaultSettings.vsync;
    frameRateLimit = defaultSettings.frameRateLimit;
    graphicsQuality = defaultSettings.graphicsQuality;
    showFPS = defaultSettings.showFPS;
    brightness = defaultSettings.brightness;
    contrast = defaultSettings.contrast;
    gamma = defaultSettings.gamma;

    particleEffects = defaultSettings.particleEffects;
    screenShake = defaultSettings.screenShake;
    flashingEffects = defaultSettings.flashingEffects;
    motionBlur = defaultSettings.motionBlur;
    bloom = defaultSettings.bloom;
    particleDensity = defaultSettings.particleDensity;

    keyBindings = Map.from(defaultSettings.keyBindings);
    gamepadBindings = Map.from(defaultSettings.gamepadBindings);
    mouseSensitivity = defaultSettings.mouseSensitivity;
    invertMouseY = defaultSettings.invertMouseY;
    gamepadSensitivity = defaultSettings.gamepadSensitivity;
    gamepadVibration = defaultSettings.gamepadVibration;
    gamepadDeadzone = defaultSettings.gamepadDeadzone;

    difficulty = defaultSettings.difficulty;
    autoSave = defaultSettings.autoSave;
    autoSaveInterval = defaultSettings.autoSaveInterval;
    showHints = defaultSettings.showHints;
    showTutorials = defaultSettings.showTutorials;
    pauseOnFocusLoss = defaultSettings.pauseOnFocusLoss;
    skipCutscenes = defaultSettings.skipCutscenes;
    gameSpeed = defaultSettings.gameSpeed;

    colorBlindAssist = defaultSettings.colorBlindAssist;
    colorBlindType = defaultSettings.colorBlindType;
    highContrast = defaultSettings.highContrast;
    largeText = defaultSettings.largeText;
    subtitles = defaultSettings.subtitles;
    subtitleSize = defaultSettings.subtitleSize;
    audioDescriptions = defaultSettings.audioDescriptions;
    reducedMotion = defaultSettings.reducedMotion;
    simplifiedUI = defaultSettings.simplifiedUI;

    uiScale = defaultSettings.uiScale;
    language = defaultSettings.language;
    dateFormat = defaultSettings.dateFormat;
    timeFormat = defaultSettings.timeFormat;
    showDamageNumbers = defaultSettings.showDamageNumbers;
    showHealthBars = defaultSettings.showHealthBars;
    showMinimap = defaultSettings.showMinimap;
    hudOpacity = defaultSettings.hudOpacity;

    telemetryEnabled = defaultSettings.telemetryEnabled;
    crashReporting = defaultSettings.crashReporting;
    analyticsEnabled = defaultSettings.analyticsEnabled;
    cloudSaveEnabled = defaultSettings.cloudSaveEnabled;
    autoUpdateEnabled = defaultSettings.autoUpdateEnabled;

    advancedSettings = Map.from(defaultSettings.advancedSettings);
    experimentalFeatures = Map.from(defaultSettings.experimentalFeatures);
  }

  /// Reset specific category to defaults
  void resetCategoryToDefaults(String category) {
    final Settings defaultSettings = Settings();

    switch (category) {
      case 'audio':
        masterVolume = defaultSettings.masterVolume;
        musicVolume = defaultSettings.musicVolume;
        sfxVolume = defaultSettings.sfxVolume;
        voiceVolume = defaultSettings.voiceVolume;
        ambientVolume = defaultSettings.ambientVolume;
        muteWhenUnfocused = defaultSettings.muteWhenUnfocused;
        audioQuality = defaultSettings.audioQuality;
        break;

      case 'graphics':
        resolution = defaultSettings.resolution;
        fullscreen = defaultSettings.fullscreen;
        vsync = defaultSettings.vsync;
        frameRateLimit = defaultSettings.frameRateLimit;
        graphicsQuality = defaultSettings.graphicsQuality;
        showFPS = defaultSettings.showFPS;
        brightness = defaultSettings.brightness;
        contrast = defaultSettings.contrast;
        gamma = defaultSettings.gamma;
        particleEffects = defaultSettings.particleEffects;
        screenShake = defaultSettings.screenShake;
        flashingEffects = defaultSettings.flashingEffects;
        motionBlur = defaultSettings.motionBlur;
        bloom = defaultSettings.bloom;
        particleDensity = defaultSettings.particleDensity;
        break;

      case 'input':
        keyBindings = Map.from(defaultSettings.keyBindings);
        gamepadBindings = Map.from(defaultSettings.gamepadBindings);
        mouseSensitivity = defaultSettings.mouseSensitivity;
        invertMouseY = defaultSettings.invertMouseY;
        gamepadSensitivity = defaultSettings.gamepadSensitivity;
        gamepadVibration = defaultSettings.gamepadVibration;
        gamepadDeadzone = defaultSettings.gamepadDeadzone;
        break;

      case 'gameplay':
        difficulty = defaultSettings.difficulty;
        autoSave = defaultSettings.autoSave;
        autoSaveInterval = defaultSettings.autoSaveInterval;
        showHints = defaultSettings.showHints;
        showTutorials = defaultSettings.showTutorials;
        pauseOnFocusLoss = defaultSettings.pauseOnFocusLoss;
        skipCutscenes = defaultSettings.skipCutscenes;
        gameSpeed = defaultSettings.gameSpeed;
        break;

      case 'accessibility':
        colorBlindAssist = defaultSettings.colorBlindAssist;
        colorBlindType = defaultSettings.colorBlindType;
        highContrast = defaultSettings.highContrast;
        largeText = defaultSettings.largeText;
        subtitles = defaultSettings.subtitles;
        subtitleSize = defaultSettings.subtitleSize;
        audioDescriptions = defaultSettings.audioDescriptions;
        reducedMotion = defaultSettings.reducedMotion;
        simplifiedUI = defaultSettings.simplifiedUI;
        break;
    }
  }

  /// Validate settings values
  bool validateSettings() {
    try {
      // Validate ranges
      if (masterVolume < 0.0 || masterVolume > 1.0) return false;
      if (musicVolume < 0.0 || musicVolume > 1.0) return false;
      if (sfxVolume < 0.0 || sfxVolume > 1.0) return false;
      if (voiceVolume < 0.0 || voiceVolume > 1.0) return false;
      if (ambientVolume < 0.0 || ambientVolume > 1.0) return false;

      if (brightness < 0.5 || brightness > 2.0) return false;
      if (contrast < 0.5 || contrast > 2.0) return false;
      if (gamma < 0.5 || gamma > 2.0) return false;

      if (mouseSensitivity < 0.1 || mouseSensitivity > 5.0) return false;
      if (gamepadSensitivity < 0.1 || gamepadSensitivity > 5.0) return false;
      if (gamepadDeadzone < 0.0 || gamepadDeadzone > 0.5) return false;

      if (gameSpeed < 0.5 || gameSpeed > 2.0) return false;
      if (particleDensity < 0.0 || particleDensity > 1.0) return false;
      if (subtitleSize < 0.5 || subtitleSize > 2.0) return false;
      if (uiScale < 0.5 || uiScale > 2.0) return false;
      if (hudOpacity < 0.0 || hudOpacity > 1.0) return false;

      // Validate enums
      if (!<String>['low', 'medium', 'high'].contains(audioQuality)) {
        return false;
      }
      if (!<String>['low', 'medium', 'high', 'ultra']
          .contains(graphicsQuality)) {
        return false;
      }
      if (!<String>['easy', 'normal', 'hard', 'expert'].contains(difficulty)) {
        return false;
      }
      if (!<String>['none', 'protanopia', 'deuteranopia', 'tritanopia']
          .contains(colorBlindType)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Apply graphics quality preset
  void applyGraphicsPreset(String preset) {
    switch (preset) {
      case 'low':
        graphicsQuality = 'low';
        particleEffects = false;
        screenShake = false;
        motionBlur = false;
        bloom = false;
        particleDensity = 0.3;
        frameRateLimit = 30;
        break;

      case 'medium':
        graphicsQuality = 'medium';
        particleEffects = true;
        screenShake = true;
        motionBlur = false;
        bloom = false;
        particleDensity = 0.6;
        frameRateLimit = 60;
        break;

      case 'high':
        graphicsQuality = 'high';
        particleEffects = true;
        screenShake = true;
        motionBlur = true;
        bloom = true;
        particleDensity = 0.8;
        frameRateLimit = 60;
        break;

      case 'ultra':
        graphicsQuality = 'ultra';
        particleEffects = true;
        screenShake = true;
        motionBlur = true;
        bloom = true;
        particleDensity = 1.0;
        frameRateLimit = 0; // Unlimited
        break;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'masterVolume': masterVolume,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'voiceVolume': voiceVolume,
      'ambientVolume': ambientVolume,
      'muteWhenUnfocused': muteWhenUnfocused,
      'audioQuality': audioQuality,
      'resolution': resolution,
      'fullscreen': fullscreen,
      'vsync': vsync,
      'frameRateLimit': frameRateLimit,
      'graphicsQuality': graphicsQuality,
      'showFPS': showFPS,
      'brightness': brightness,
      'contrast': contrast,
      'gamma': gamma,
      'particleEffects': particleEffects,
      'screenShake': screenShake,
      'flashingEffects': flashingEffects,
      'motionBlur': motionBlur,
      'bloom': bloom,
      'particleDensity': particleDensity,
      'keyBindings': keyBindings,
      'gamepadBindings': gamepadBindings,
      'mouseSensitivity': mouseSensitivity,
      'invertMouseY': invertMouseY,
      'gamepadSensitivity': gamepadSensitivity,
      'gamepadVibration': gamepadVibration,
      'gamepadDeadzone': gamepadDeadzone,
      'difficulty': difficulty,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'showHints': showHints,
      'showTutorials': showTutorials,
      'pauseOnFocusLoss': pauseOnFocusLoss,
      'skipCutscenes': skipCutscenes,
      'gameSpeed': gameSpeed,
      'colorBlindAssist': colorBlindAssist,
      'colorBlindType': colorBlindType,
      'highContrast': highContrast,
      'largeText': largeText,
      'subtitles': subtitles,
      'subtitleSize': subtitleSize,
      'audioDescriptions': audioDescriptions,
      'reducedMotion': reducedMotion,
      'simplifiedUI': simplifiedUI,
      'uiScale': uiScale,
      'language': language,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'showDamageNumbers': showDamageNumbers,
      'showHealthBars': showHealthBars,
      'showMinimap': showMinimap,
      'hudOpacity': hudOpacity,
      'telemetryEnabled': telemetryEnabled,
      'crashReporting': crashReporting,
      'analyticsEnabled': analyticsEnabled,
      'cloudSaveEnabled': cloudSaveEnabled,
      'autoUpdateEnabled': autoUpdateEnabled,
      'advancedSettings': advancedSettings,
      'experimentalFeatures': experimentalFeatures,
    };
  }

  @override
  String toString() {
    return 'Settings(difficulty: $difficulty, graphics: $graphicsQuality, audio: $audioQuality)';
  }
}

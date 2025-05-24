import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/position_component_extensions.dart';
import '../game/adventure_jumper_game.dart';
import 'text_paint_extensions.dart';

/// Game configuration screen
/// Allows player to adjust game settings like audio, controls, and display options
class SettingsMenu extends PositionComponent with TapCallbacks {
  SettingsMenu({
    required this.game,
    required this.screenSize,
    this.onClose,
    this.onSaveSettings,
  }) : super(position: Vector2.zero(), size: screenSize);

  // References
  final AdventureJumperGame game;
  final Vector2 screenSize;
  // Callbacks
  final void Function()? onClose;
  final void Function()? onSaveSettings;

  // UI components
  late final PositionComponent _background;
  late final TextComponent _titleText;
  late final SettingsPanel _settingsPanel;
  late final PositionComponent _buttonRow;

  // Settings data
  final GameSettings _settings = GameSettings();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create semi-transparent background
    _createBackground();

    // Create title
    _createTitle();

    // Create settings panel
    _createSettingsPanel();

    // Create button row
    _createButtonRow();

    // Add entrance animations
    _addEntranceAnimations();
  }

  /// Create semi-transparent background
  void _createBackground() {
    _background = RectangleComponent(
      size: screenSize,
      paint: Paint()..color = const Color(0xDD000000), // Semi-transparent black
    );

    add(_background);
  }

  /// Create settings title
  void _createTitle() {
    _titleText = TextComponent(
      text: 'SETTINGS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(screenSize.x / 2, 40),
      anchor: Anchor.center,
    );

    add(_titleText);
  }

  /// Create settings panel with options
  void _createSettingsPanel() {
    final double panelWidth = screenSize.x * 0.6;
    final double panelHeight = screenSize.y * 0.7;

    _settingsPanel = SettingsPanel(
      position: Vector2(screenSize.x / 2 - panelWidth / 2, 80),
      size: Vector2(panelWidth, panelHeight),
      settings: _settings,
    );

    add(_settingsPanel);
  }

  /// Create button row for save/cancel
  void _createButtonRow() {
    _buttonRow = PositionComponent(
      position: Vector2(screenSize.x / 2, screenSize.y - 60),
      size: Vector2(300, 40),
      anchor: Anchor.center,
    );

    add(_buttonRow);

    // Save button
    final SettingsButton saveButton = SettingsButton(
      text: 'Save Settings',
      position: Vector2(-80, 0),
      size: Vector2(150, 40),
      onPressed: () {
        // Save settings and close
        if (onSaveSettings != null) onSaveSettings!();
        if (onClose != null) onClose!();
      },
    );

    // Cancel button
    final SettingsButton cancelButton = SettingsButton(
      text: 'Cancel',
      position: Vector2(80, 0),
      size: Vector2(150, 40),
      buttonColor: const Color(0x99555555),
      onPressed: () {
        // Close without saving
        if (onClose != null) onClose!();
      },
    );

    _buttonRow.add(saveButton);
    _buttonRow.add(cancelButton);
  }

  /// Add entrance animations
  void _addEntranceAnimations() {
    // Background fades in
    _background.opacity = 0;
    _background.add(
      OpacityEffect.fadeIn(
        EffectController(duration: 0.3),
      ),
    ); // Title and panel slide in from top
    _titleText.position = Vector2(_titleText.position.x, -50);
    _titleText.add(
      MoveToEffect(
        Vector2(_titleText.position.x, 40),
        EffectController(
          duration: 0.5,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _settingsPanel.position = Vector2(_settingsPanel.position.x, -_settingsPanel.size.y);
    _settingsPanel.add(
      MoveToEffect(
        Vector2(_settingsPanel.position.x, 80),
        EffectController(
          duration: 0.6,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Buttons fade in
    _buttonRow.opacity = 0;
    _buttonRow.add(
      OpacityEffect.fadeIn(
        EffectController(
          duration: 0.5,
          startDelay: 0.4,
        ),
      ),
    );
  }
}

/// Panel containing all settings options
class SettingsPanel extends PositionComponent {
  SettingsPanel({
    required Vector2 position,
    required Vector2 size,
    required this.settings,
  }) : super(position: position, size: size);

  final GameSettings settings;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create panel background
    _createBackground();

    // Create settings sections
    _createAudioSection();
    _createDisplaySection();
    _createControlsSection();
    _createGameplaySection();
  }

  /// Create panel background
  void _createBackground() {
    final RectangleComponent background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xAA333333), // Dark semi-transparent gray
    );

    add(background);
  }

  /// Create audio settings section
  void _createAudioSection() {
    const double sectionStart = 20;
    final double sectionWidth = size.x - 40;

    // Section header
    final TextComponent<TextPaint> headerText = TextComponent(
      text: 'Audio Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, sectionStart),
      anchor: Anchor.topLeft,
    );

    add(headerText);

    // Master volume slider
    final TextComponent<TextPaint> masterVolumeLabel = TextComponent(
      text: 'Master Volume',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(30, sectionStart + 30),
      anchor: Anchor.topLeft,
    );

    add(masterVolumeLabel);

    final SettingsSlider masterVolumeSlider = SettingsSlider(
      position: Vector2(30, sectionStart + 55),
      size: Vector2(sectionWidth - 60, 20),
      value: settings.masterVolume,
      onChanged: (double value) {
        settings.masterVolume = value;
      },
    );

    add(masterVolumeSlider);

    // Music volume slider
    final TextComponent<TextPaint> musicVolumeLabel = TextComponent(
      text: 'Music Volume',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(30, sectionStart + 85),
      anchor: Anchor.topLeft,
    );

    add(musicVolumeLabel);

    final SettingsSlider musicVolumeSlider = SettingsSlider(
      position: Vector2(30, sectionStart + 110),
      size: Vector2(sectionWidth - 60, 20),
      value: settings.musicVolume,
      onChanged: (double value) {
        settings.musicVolume = value;
      },
    );

    add(musicVolumeSlider);

    // SFX volume slider
    final TextComponent<TextPaint> sfxVolumeLabel = TextComponent(
      text: 'Sound Effects Volume',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(30, sectionStart + 140),
      anchor: Anchor.topLeft,
    );

    add(sfxVolumeLabel);

    final SettingsSlider sfxVolumeSlider = SettingsSlider(
      position: Vector2(30, sectionStart + 165),
      size: Vector2(sectionWidth - 60, 20),
      value: settings.sfxVolume,
      onChanged: (double value) {
        settings.sfxVolume = value;
      },
    );

    add(sfxVolumeSlider);

    // Music enabled toggle
    final SettingsToggle musicEnabledToggle = SettingsToggle(
      position: Vector2(30, sectionStart + 205),
      size: Vector2(sectionWidth - 60, 30),
      label: 'Music Enabled',
      isEnabled: settings.musicEnabled,
      onChanged: (bool value) {
        settings.musicEnabled = value;
      },
    );

    add(musicEnabledToggle);

    // SFX enabled toggle
    final SettingsToggle sfxEnabledToggle = SettingsToggle(
      position: Vector2(30, sectionStart + 245),
      size: Vector2(sectionWidth - 60, 30),
      label: 'Sound Effects Enabled',
      isEnabled: settings.sfxEnabled,
      onChanged: (bool value) {
        settings.sfxEnabled = value;
      },
    );

    add(sfxEnabledToggle);
  }

  /// Create display settings section
  void _createDisplaySection() {
    const double sectionStart = 300;
    final double sectionWidth = size.x - 40;

    // Section header
    final TextComponent<TextPaint> headerText = TextComponent(
      text: 'Display Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, sectionStart),
      anchor: Anchor.topLeft,
    );

    add(headerText);

    // Fullscreen toggle
    final SettingsToggle fullscreenToggle = SettingsToggle(
      position: Vector2(30, sectionStart + 40),
      size: Vector2(sectionWidth - 60, 30),
      label: 'Fullscreen',
      isEnabled: settings.fullscreen,
      onChanged: (bool value) {
        settings.fullscreen = value;
      },
    );

    add(fullscreenToggle);

    // FPS counter toggle
    final SettingsToggle fpsCounterToggle = SettingsToggle(
      position: Vector2(30, sectionStart + 80),
      size: Vector2(sectionWidth - 60, 30),
      label: 'Show FPS Counter',
      isEnabled: settings.showFps,
      onChanged: (bool value) {
        settings.showFps = value;
      },
    );

    add(fpsCounterToggle);
  }

  /// Create controls settings section
  void _createControlsSection() {
    const double sectionStart = 400;
    final double sectionWidth = size.x - 40;

    // Section header
    final TextComponent<TextPaint> headerText = TextComponent(
      text: 'Controls Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, sectionStart),
      anchor: Anchor.topLeft,
    );

    add(headerText);

    // Control sensitivity slider
    final TextComponent<TextPaint> sensitivityLabel = TextComponent(
      text: 'Input Sensitivity',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(30, sectionStart + 40),
      anchor: Anchor.topLeft,
    );

    add(sensitivityLabel);

    final SettingsSlider sensitivitySlider = SettingsSlider(
      position: Vector2(30, sectionStart + 65),
      size: Vector2(sectionWidth - 60, 20),
      value: settings.controlSensitivity,
      onChanged: (double value) {
        settings.controlSensitivity = value;
      },
    );

    add(sensitivitySlider);
  }

  /// Create gameplay settings section
  void _createGameplaySection() {
    const double sectionStart = 500;
    final double sectionWidth = size.x - 40;

    // Section header
    final TextComponent<TextPaint> headerText = TextComponent(
      text: 'Gameplay Settings',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, sectionStart),
      anchor: Anchor.topLeft,
    );

    add(headerText);

    // Screen shake toggle
    final SettingsToggle screenShakeToggle = SettingsToggle(
      position: Vector2(30, sectionStart + 40),
      size: Vector2(sectionWidth - 60, 30),
      label: 'Screen Shake',
      isEnabled: settings.screenShakeEnabled,
      onChanged: (bool value) {
        settings.screenShakeEnabled = value;
      },
    );

    add(screenShakeToggle);

    // Difficulty selection
    final TextComponent<TextPaint> difficultyLabel = TextComponent(
      text: 'Difficulty',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      position: Vector2(30, sectionStart + 80),
      anchor: Anchor.topLeft,
    );

    add(difficultyLabel);

    final List<String> difficultyOptions = <String>['Easy', 'Normal', 'Hard'];
    final SettingsSelector difficultySelector = SettingsSelector(
      position: Vector2(30, sectionStart + 105),
      size: Vector2(sectionWidth - 60, 30),
      options: difficultyOptions,
      selectedIndex: settings.difficulty.index,
      onChanged: (int index) {
        settings.difficulty = GameDifficulty.values[index];
      },
    );

    add(difficultySelector);
  }
}

/// Settings button component
class SettingsButton extends PositionComponent with TapCallbacks {
  SettingsButton({
    required this.text,
    required Vector2 position,
    required Vector2 size,
    this.buttonColor = const Color(0xFF5A7EB0),
    this.onPressed,
  }) : super(position: position, size: size, anchor: Anchor.center);
  final String text;
  final Color buttonColor;
  final void Function()? onPressed;

  // Visual state
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Determine button color based on state
    Color color = buttonColor;
    if (_isHovered) {
      color = color.withAlpha(((color.a * 255.0).round() & 0xff + 40).clamp(0, 255));
    }

    if (_isPressed) {
      color = color.withAlpha(((color.a * 255.0).round() & 0xff - 40).clamp(0, 255));
    }

    // Draw button background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

    final Paint buttonPaint = Paint()..color = color;
    canvas.drawRRect(rrect, buttonPaint); // Draw button border
    final Paint borderPaint = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    // Draw button text
    final TextPaint textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final Vector2 textOffset = textPaint.measureText(text);
    final Vector2 textPosition = Vector2(
      size.x / 2 - textOffset.x / 2,
      size.y / 2 - textOffset.y / 2,
    );

    textPaint.render(canvas, text, textPosition);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  void onHoverEnter() {
    _isHovered = true;
    add(
      ScaleEffect.to(
        Vector2(1.05, 1.05),
        EffectController(duration: 0.1),
      ),
    );
  }

  void onHoverExit() {
    _isHovered = false;
    add(
      ScaleEffect.to(
        Vector2(1, 1),
        EffectController(duration: 0.1),
      ),
    );
  }
}

/// Settings slider component
class SettingsSlider extends PositionComponent with DragCallbacks {
  SettingsSlider({
    required Vector2 position,
    required Vector2 size,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
  }) : super(position: position, size: size);
  // Slider values
  double value;
  final double min;
  final double max;
  final void Function(double)? onChanged;

  // Visual state
  bool _isDragging = false;

  // Visual settings
  final Color trackColor = const Color(0xFF555555);
  final Color activeTrackColor = const Color(0xFF5A7EB0);
  final Color knobColor = Colors.white;
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double trackHeight = size.y * 0.4;
    final RRect trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.y - trackHeight) / 2, size.x, trackHeight),
      Radius.circular(trackHeight / 2),
    );

    // Draw track background
    final Paint trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(trackRect, trackPaint);

    // Draw active portion of track
    final double progress = (value - min) / (max - min);
    final double activeWidth = size.x * progress;

    final RRect activeTrackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (size.y - trackHeight) / 2, activeWidth, trackHeight),
      Radius.circular(trackHeight / 2),
    );

    final Paint activeTrackPaint = Paint()..color = activeTrackColor;
    canvas.drawRRect(activeTrackRect, activeTrackPaint);

    // Draw knob with dragging effect
    final double knobRadius = size.y * 0.6;
    Color currentKnobColor = knobColor;
    if (_isDragging) {
      currentKnobColor = Color.fromRGBO(
        (knobColor.r * 255.0).round() & 0xff,
        (knobColor.g * 255.0).round() & 0xff,
        (knobColor.b * 255.0).round() & 0xff,
        0.8,
      );
    }
    final Paint knobPaint = Paint()..color = currentKnobColor;

    final double knobX = activeWidth;
    final double knobY = size.y / 2;

    canvas.drawCircle(Offset(knobX, knobY), knobRadius, knobPaint);

    // Draw value text
    final String valueText = (value * 100).toInt().toString();
    final TextPaint textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    );

    final Vector2 textOffset = textPaint.measureText(valueText);
    final double textX = size.x + 10;
    final double textY = (size.y - textOffset.y) / 2;

    textPaint.render(canvas, valueText, Vector2(textX, textY));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    _updateValueFromPosition(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _updateValueFromPosition(event.localDelta + event.localStartPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
  }

  /// Update slider value based on drag position
  void _updateValueFromPosition(Vector2 position) {
    final double newProgress = (position.x / size.x).clamp(0.0, 1.0);
    final double newValue = min + (max - min) * newProgress;

    if (value != newValue) {
      value = newValue;
      if (onChanged != null) {
        onChanged!(value);
      }
    }
  }
}

/// Settings toggle component
class SettingsToggle extends PositionComponent with TapCallbacks {
  SettingsToggle({
    required Vector2 position,
    required Vector2 size,
    required this.label,
    required this.isEnabled,
    this.onChanged,
  }) : super(position: position, size: size);
  final String label;
  bool isEnabled;
  final void Function(bool)? onChanged;

  // Visual state
  bool _isHovered = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Draw label with hover effect
    Color labelColor = Colors.white;
    if (_isHovered) {
      labelColor = const Color.fromRGBO(255, 255, 255, 0.8);
    }

    final TextPaint textPaint = TextPaint(
      style: TextStyle(
        color: labelColor,
        fontSize: 14,
      ),
    );

    textPaint.render(canvas, label, Vector2(0, size.y / 2 - 7));

    // Draw toggle track
    const double trackWidth = 40;
    const double trackHeight = 20;
    final RRect trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.x - trackWidth,
        (size.y - trackHeight) / 2,
        trackWidth,
        trackHeight,
      ),
      const Radius.circular(trackHeight / 2),
    );

    Color trackColor = isEnabled ? const Color(0xFF5A7EB0) : const Color(0xFF555555);
    if (_isHovered) {
      trackColor = Color.fromRGBO(
        (trackColor.r * 255.0).round() & 0xff,
        (trackColor.g * 255.0).round() & 0xff,
        (trackColor.b * 255.0).round() & 0xff,
        0.8,
      );
    }
    final Paint trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(trackRect, trackPaint);

    // Draw toggle knob
    const double knobRadius = trackHeight * 0.8;
    final Paint knobPaint = Paint()..color = Colors.white;

    final double knobX = isEnabled ? size.x - trackWidth / 5 : size.x - trackWidth + trackWidth / 5;

    final double knobY = size.y / 2;

    canvas.drawCircle(Offset(knobX, knobY), knobRadius / 2, knobPaint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isEnabled = !isEnabled;
    if (onChanged != null) {
      onChanged!(isEnabled);
    }
  }

  void onHoverEnter() {
    _isHovered = true;
  }

  void onHoverExit() {
    _isHovered = false;
  }
}

/// Settings selector component (dropdown alternative)
class SettingsSelector extends PositionComponent with TapCallbacks {
  SettingsSelector({
    required Vector2 position,
    required Vector2 size,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  }) : super(position: position, size: size);
  final List<String> options;
  int selectedIndex;
  final void Function(int)? onChanged;

  // Visual state
  bool _isHovered = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw selector background
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

    final Color bgColor = _isHovered ? const Color(0xFF444444) : const Color(0xFF333333);
    final Paint bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    // Draw selected value
    final String selectedValue = options[selectedIndex];
    final TextPaint textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    );

    textPaint.render(canvas, selectedValue, Vector2(10, size.y / 2 - 7));

    // Draw arrows
    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left arrow
    final Offset leftArrowStart = Offset(size.x - 50, size.y / 2);
    final Offset leftArrowPoint1 = Offset(size.x - 58, size.y / 2 - 4);
    final Offset leftArrowPoint2 = Offset(size.x - 58, size.y / 2 + 4);

    canvas.drawLine(leftArrowStart, leftArrowPoint1, arrowPaint);
    canvas.drawLine(leftArrowStart, leftArrowPoint2, arrowPaint);

    // Right arrow
    final Offset rightArrowStart = Offset(size.x - 15, size.y / 2);
    final Offset rightArrowPoint1 = Offset(size.x - 7, size.y / 2 - 4);
    final Offset rightArrowPoint2 = Offset(size.x - 7, size.y / 2 + 4);

    canvas.drawLine(rightArrowStart, rightArrowPoint1, arrowPaint);
    canvas.drawLine(rightArrowStart, rightArrowPoint2, arrowPaint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final Vector2 tapPosition = event.localPosition;

    // Check if left arrow tapped
    if (tapPosition.x > size.x - 60 && tapPosition.x < size.x - 40) {
      _cycleToPrevious();
    }
    // Check if right arrow tapped
    else if (tapPosition.x > size.x - 20 && tapPosition.x < size.x) {
      _cycleToNext();
    }
  }

  /// Cycle to previous option
  void _cycleToPrevious() {
    selectedIndex = (selectedIndex - 1 + options.length) % options.length;
    if (onChanged != null) {
      onChanged!(selectedIndex);
    }
  }

  /// Cycle to next option
  void _cycleToNext() {
    selectedIndex = (selectedIndex + 1) % options.length;
    if (onChanged != null) {
      onChanged!(selectedIndex);
    }
  }

  void onHoverEnter() {
    _isHovered = true;
  }

  void onHoverExit() {
    _isHovered = false;
  }
}

/// Placeholder game settings class
/// Will be replaced with actual settings class from SaveModule in future sprints
class GameSettings {
  // Audio settings
  double masterVolume = 0.8;
  double musicVolume = 0.7;
  double sfxVolume = 1;
  bool musicEnabled = true;
  bool sfxEnabled = true;

  // Display settings
  bool fullscreen = false;
  bool showFps = false;

  // Control settings
  double controlSensitivity = 0.5;

  // Gameplay settings
  bool screenShakeEnabled = true;
  GameDifficulty difficulty = GameDifficulty.normal;
}

/// Game difficulty enum
enum GameDifficulty {
  easy,
  normal,
  hard,
}

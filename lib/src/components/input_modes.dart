/// Defines input modes for the game's input system
///
/// This enum replaces boolean flags for better semantics and API design.
enum InputMode {
  /// Input processing is active and responding to events
  active,

  /// Input processing is disabled/inactive
  inactive,
}

/// Defines the input source used by the input component
enum InputSource {
  /// Keyboard input (keys, buttons)
  keyboard,

  /// Virtual on-screen controls (touch)
  virtualController,

  /// Both keyboard and virtual controller inputs
  both,

  /// No input sources (disabled)
  none,
}

/// Defines how input buffering behaves
enum InputBufferingMode {
  /// Enable input buffering for action timing windows
  enabled,

  /// Disable input buffering for immediate responses only
  disabled,
}

/// Defines the activation state of a portal
enum PortalState {
  /// Portal is active and can be used for transitions
  active,

  /// Portal is inactive and cannot be used
  inactive,
}

/// Defines how a player interacts with a portal
enum PortalInteractionType {
  /// Portal activates automatically on contact
  automatic,

  /// Portal requires player to press interaction button
  requiresInteraction,
}

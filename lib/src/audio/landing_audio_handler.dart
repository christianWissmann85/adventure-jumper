import '../events/player_events.dart';
import '../systems/audio_system.dart';
import '../utils/logger.dart';

/// Audio handler for player landing events
/// Demonstrates the landing event system integration with audio
class LandingAudioHandler {
  LandingAudioHandler(this.audioSystem) {
    _setupEventListeners();
  }

  final AudioSystem audioSystem;

  void _setupEventListeners() {
    PlayerEventBus.instance.addListener(_handlePlayerEvent);
  }

  void _handlePlayerEvent(PlayerEvent event) {
    switch (event.type) {
      case PlayerEventType.landed:
        _handleLandingEvent(event as PlayerLandedEvent);
        break;
      case PlayerEventType.leftGround:
        _handleLeftGroundEvent(event as PlayerLeftGroundEvent);
        break;
      case PlayerEventType.jumped:
        _handleJumpEvent(event as PlayerJumpedEvent);
        break;
      default:
        // Handle other events as needed
        break;
    }
  }

  void _handleLandingEvent(PlayerLandedEvent event) {
    // Determine landing sound based on impact force and platform type
    String soundId = 'land_soft';
    double volume = 0.7;

    // Adjust sound based on impact force
    if (event.impactForce != null) {
      if (event.impactForce! > 400) {
        soundId = 'land_hard';
        volume = 1.0;
      } else if (event.impactForce! > 200) {
        soundId = 'land_medium';
        volume = 0.85;
      }
    }

    // Adjust sound based on platform type
    switch (event.platformType) {
      case 'one_way_platform':
        soundId = '${soundId}_wood';
        break;
      case 'solid_platform':
        soundId = '${soundId}_stone';
        break;
      default:
        // Default sound
        break;
    }

    // Play the landing sound with spatial audio
    audioSystem.playSpatialSfx(
      soundId,
      event.landingPosition,
      volume: volume,
    ); // Debug output with structured logging
    logger.fine(
      'Landing: ${event.impactForce?.toStringAsFixed(1)} force on ${event.platformType}',
    );
  }

  void _handleLeftGroundEvent(PlayerLeftGroundEvent event) {
    // Could play a subtle "whoosh" sound when leaving ground
    // For now, just debug output with structured logging
    logger.fine(
      'Left ground: ${event.leaveReason} at velocity ${event.leaveVelocity.y.toStringAsFixed(1)}',
    );
  }

  void _handleJumpEvent(PlayerJumpedEvent event) {
    // Play jump sound
    String soundId = 'jump';
    if (event.isCoyoteJump) {
      soundId = 'jump_coyote';
    }

    audioSystem.playSpatialSfx(
      soundId,
      event.jumpPosition,
      volume: 0.8,
    ); // Debug output with structured logging
    logger.fine(
      'Jump: ${event.jumpForce} force${event.isCoyoteJump ? " (coyote)" : ""}',
    );
  }

  /// Clean up event listeners
  void dispose() {
    PlayerEventBus.instance.removeListener(_handlePlayerEvent);
  }
}

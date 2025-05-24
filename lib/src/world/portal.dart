import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../components/collision_component.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import 'portal_types.dart';

/// Level transition mechanics
/// Portals allow players to move between different levels or areas
class Portal extends Entity {
  Portal({
    required super.position,
    required this.targetLevelId,
    this.targetSpawnId,
    PortalState initialState = PortalState.active,
    PortalInteractionType interactionType = PortalInteractionType.automatic,
    this.transitionDuration = 1.0,
  })  : _portalState = initialState,
        _interactionType = interactionType,
        requiresInteraction = interactionType == PortalInteractionType.requiresInteraction,
        isActive = initialState == PortalState.active;

  // Portal properties
  final String targetLevelId;
  final String? targetSpawnId;
  @override
  bool isActive;
  final bool requiresInteraction;
  final double transitionDuration;

  // New enum-based properties
  PortalState _portalState;
  final PortalInteractionType _interactionType;

  // Enum getters
  PortalState get portalState => _portalState;
  PortalInteractionType get interactionType => _interactionType;

  // Visual components
  late SpriteComponent _spriteComponent;
  late CollisionComponent _collisionComponent;

  // Portal state
  bool _isPlayerInRange = false;
  bool _isTransitioning = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load portal sprite
    await _loadSprite();

    // Set up collision for player detection
    _setupCollision();

    // Start portal animation
    _startIdleAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for player interaction if needed
    if (_isPlayerInRange && requiresInteraction) {
      _checkForInteraction();
    }

    // Update visual effects
    _updateEffects(dt);
  }

  /// Load portal sprite asset
  Future<void> _loadSprite() async {
    // Sprite loading will be implemented in future sprints
    // For now we create a placeholder sprite
    _spriteComponent = SpriteComponent()..size = Vector2(64, 64);
    add(_spriteComponent);
  }

  /// Set up collision detection
  void _setupCollision() {
    _collisionComponent = CollisionComponent();

    add(_collisionComponent);
  }

  /// Handle player collision with portal
  void onPlayerCollision(Player player, bool isColliding) {
    if (isColliding) {
      _onPlayerEnterRange(player);
    } else {
      _onPlayerExitRange(player);
    }
  }

  /// Start idle animation for portal
  void _startIdleAnimation() {
    // Animation will be implemented in future sprints

    // Add pulsing effect
    final ScaleEffect pulseEffect = ScaleEffect.by(
      Vector2.all(1.1),
      EffectController(
        duration: 1.5,
        reverseDuration: 1.5,
        infinite: true,
      ),
    );

    add(pulseEffect);
  }

  /// Update visual effects
  void _updateEffects(double dt) {
    // Effects updating will be implemented in future sprints
  }

  /// Called when player enters the portal range
  void _onPlayerEnterRange(Player player) {
    if (!isActive || _isTransitioning) return;

    _isPlayerInRange = true;

    // If portal doesn't require interaction, trigger immediately
    if (!requiresInteraction) {
      _triggerPortal(player);
    } else {
      // Show interaction prompt
      _showInteractionPrompt();
    }
  }

  /// Called when player exits the portal range
  void _onPlayerExitRange(Player player) {
    _isPlayerInRange = false;

    // Hide interaction prompt
    _hideInteractionPrompt();
  }

  /// Check if player is interacting with the portal
  void _checkForInteraction() {
    // Interaction check will be implemented in future sprints
    // For now we just simulate interaction
  }

  /// Show prompt for player interaction
  void _showInteractionPrompt() {
    // Prompt will be implemented in future sprints
    print('Portal: Press E to enter portal to $targetLevelId');
  }

  /// Hide interaction prompt
  void _hideInteractionPrompt() {
    // Implementation will be added in future sprints
  }

  /// Trigger the portal to transition to target level
  void _triggerPortal(Player player) {
    if (_isTransitioning) return;

    _isTransitioning = true;

    // Play transition effect
    _playTransitionEffect();

    // Notify level manager of portal entry
    // This will be properly integrated in future sprints

    // For now, we just print a message
    print('Portal: Transitioning to $targetLevelId');

    // Reset state after transition
    Future<void>.delayed(Duration(milliseconds: (transitionDuration * 1000).toInt()), () {
      _isTransitioning = false;
    });
  }

  /// Play visual transition effect
  void _playTransitionEffect() {
    // Add flash effect
    final ColorEffect colorEffect = ColorEffect(
      const Color(0xFFFFFFFF),
      EffectController(
        duration: transitionDuration / 2,
      ),
    );

    add(colorEffect);

    // Add expand effect
    final ScaleEffect scaleEffect = ScaleEffect.by(
      Vector2.all(3),
      EffectController(
        duration: transitionDuration / 2,
      ),
    );

    add(scaleEffect);

    // Add fade effect
    final OpacityEffect opacityEffect = OpacityEffect.to(
      0,
      EffectController(
        duration: transitionDuration / 2,
        startDelay: transitionDuration / 2,
      ),
    );

    add(opacityEffect);

    // Audio effect will be implemented in future sprints
  }

  /// Set portal active or inactive (legacy boolean API)
  void setActive(bool active) {
    isActive = active;
    _portalState = active ? PortalState.active : PortalState.inactive;

    // Update visual state
    _spriteComponent.opacity = active ? 1.0 : 0.5;
  }

  /// Set portal state using enum (modern API)
  void setPortalState(PortalState state) {
    _portalState = state;
    isActive = state == PortalState.active;

    // Update visual state
    _spriteComponent.opacity = isActive ? 1.0 : 0.5;
  }
}

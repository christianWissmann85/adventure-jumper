import '../components/animation_component.dart';
import '../components/physics_component.dart';
import 'entity.dart';

/// Base class for environmental hazards in the game
/// Handles dangerous elements like spikes, lava, traps, etc.
class Hazard extends Entity {
  Hazard({
    required super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    super.id,
    String? hazardType,
    double? damage,
    bool? isInstantKill,
    bool? isTimed,
    double? activeTime,
    double? inactiveTime,
    bool? isTriggered,
  }) : super(
          type: 'hazard',
        ) {
    if (hazardType != null) _hazardType = hazardType;
    if (damage != null) _damage = damage;
    if (isInstantKill != null) _isInstantKill = isInstantKill;
    if (isTimed != null) _isTimed = isTimed;
    if (activeTime != null) _activeTime = activeTime;
    if (inactiveTime != null) _inactiveTime = inactiveTime;
    if (isTriggered != null) _isTriggered = isTriggered;
  }

  // Hazard properties
  String _hazardType = 'spike';
  double _damage = 20;
  bool _isInstantKill = false;
  bool _isActive = true;
  bool _isTimed = false;
  double _activeTime = 3;
  double _inactiveTime = 2;
  bool _isTriggered = false;

  // Animation and timing
  late AnimationComponent? animation;
  double _timer = 0;

  @override
  Future<void> setupEntity() async {
    await super.setupEntity();

    // Setup hazard-specific components
    physics = PhysicsComponent()
      ..isStatic = true
      ..isSensor = true; // Hazards don't provide solid collision, just trigger damage

    add(physics!);

    // Hazard animations
    animation = AnimationComponent();
    add(animation!);

    // Additional hazard setup
    await setupHazard();
  }

  @override
  void updateEntity(double dt) {
    super.updateEntity(dt);

    // Handle timed activation/deactivation
    if (_isTimed) {
      updateTimedState(dt);
    }

    // Hazard-specific update logic
    updateHazard(dt);
  }

  /// Custom hazard setup (to be implemented by subclasses)
  Future<void> setupHazard() async {
    // Override in subclasses
  }

  /// Custom hazard update logic (to be implemented by subclasses)
  void updateHazard(double dt) {
    // Override in subclasses
  }

  /// Handle timed activation/deactivation logic
  void updateTimedState(double dt) {
    _timer += dt;

    if (_isActive) {
      // Currently active, check if it's time to deactivate
      if (_timer >= _activeTime) {
        _timer = 0;
        _isActive = false;
        deactivateHazard();
      }
    } else {
      // Currently inactive, check if it's time to activate
      if (_timer >= _inactiveTime) {
        _timer = 0;
        _isActive = true;
        activateHazard();
      }
    }
  }

  /// Handle collision with player
  void onPlayerContact() {
    if (!_isActive) return;

    // Apply damage to player
    // Will be handled by the collision system and player's takeDamage method
  }

  /// Activate the hazard (after being inactive)
  void activateHazard() {
    _isActive = true;
    // Visual and audio indicators of activation
    // Override in subclasses for specific activation behavior
  }

  /// Deactivate the hazard (temporarily disabled)
  void deactivateHazard() {
    _isActive = false;
    // Visual and audio indicators of deactivation
    // Override in subclasses for specific deactivation behavior
  }

  /// Trigger the hazard (for trigger-based hazards)
  void trigger() {
    if (_isTriggered) {
      // Only applies to triggered hazards
      activateHazard();
    }
  }

  /// Get hazard type
  String get hazardType => _hazardType;

  /// Get damage amount
  double get damage => _damage;

  /// Check if hazard is active
  @override
  bool get isActive => _isActive;

  /// Check if hazard causes instant death
  bool get isInstantKill => _isInstantKill;

  /// Check if hazard is currently in triggered state
  bool get isTriggered => _isTriggered;
}

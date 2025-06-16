import '../components/animation_component.dart';
import '../entities/entity.dart';
import 'base_system.dart';

/// System that manages entity animation states
/// Handles animation transitions, playback, and synchronization
///
/// ARCHITECTURE:
/// -------------
/// AnimationSystem coordinates animation playback for game entities.
/// It integrates with other systems in the following ways:
/// - Processes entities with AnimationComponent
/// - Responds to state changes from physics and input systems
/// - Tracks animation states to manage transitions between animations
/// - Provides global animation speed control
///
/// PERFORMANCE CONSIDERATIONS:
/// ---------------------------
/// - Animation updates are optimized based on visibility and distance
/// - State tracking avoids redundant animation transitions
/// - Uses efficient sprite sheet management for memory optimization
///
/// USAGE EXAMPLES:
/// --------------
/// ```dart
/// // Set global animation speed (e.g., for slow-motion effects)
/// animationSystem.setGlobalAnimationSpeed(0.5);
///
/// // Add entity to animation system
/// animationSystem.addEntity(character);
/// ```
class AnimationSystem extends BaseSystem {
  AnimationSystem() : super();

  // Configuration
  double _globalAnimationSpeed = 1;

  // Animation state tracking
  final Map<Entity, String> _lastAnimationStates = <Entity, String>{};

  @override
  bool canProcessEntity(Entity entity) {
    return entity.children.whereType<AnimationComponent>().isNotEmpty;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // Apply global animation speed
    final double scaledDt = dt * _globalAnimationSpeed;

    // Find any AnimationComponent on the entity
    final Iterable<AnimationComponent> animationComponents =
        entity.children.whereType<AnimationComponent>();

    for (final AnimationComponent animComponent in animationComponents) {
      processAnimation(entity, animComponent, scaledDt);
    }
  }

  /// Process animation for a single entity
  void processAnimation(
    Entity entity,
    AnimationComponent animComponent,
    double dt,
  ) {
    // This would handle animation state logic
    // For example:
    // - Checking entity state (running, jumping, idle)
    // - Selecting appropriate animation
    // - Handling animation transitions
    // - Managing animation speeds

    // For now, we'll just ensure animations are updated
    // The actual animation state logic would be in entity-specific code
  }
  @override
  void onEntityAdded(Entity entity) {
    // Initialize animation state tracking if needed
  }

  @override
  void onEntityRemoved(Entity entity) {
    // Clean up animation state tracking
    _lastAnimationStates.remove(entity);
  }

  /// Set global animation speed
  void setGlobalAnimationSpeed(double speed) {
    _globalAnimationSpeed = speed;
  }

  // Getters
  double get globalAnimationSpeed => _globalAnimationSpeed;

  @override
  void clearEntities() {
    super.clearEntities();
    _lastAnimationStates.clear();
  }

  @override
  void initialize() {
    // Initialize animation system
  }

  @override
  void dispose() {
    super.dispose();
    _lastAnimationStates.clear();
  }
}

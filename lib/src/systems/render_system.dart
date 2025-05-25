import 'package:flame/components.dart';

import '../components/adv_sprite_component.dart';
import '../components/transform_component.dart';
import '../entities/entity.dart';
import 'base_system.dart';

/// System that manages rendering for all entities
/// Handles sprite rendering, animations, and visual effects
class RenderSystem extends BaseSystem {
  RenderSystem() : super();

  // Rendering configuration
  bool _debugMode = false;
  double _globalOpacity = 1;

  @override
  bool canProcessEntity(Entity entity) {
    // Only process entities with sprite components
    return entity.sprite != null;
  }

  @override
  void processEntity(Entity entity, double dt) {
    // No need to check for sprite component - canProcessEntity handles that
    final TransformComponent transform = entity.transformComponent;
    final AdvSpriteComponent sprite = entity.sprite!; // Safe to use ! as we checked in canProcessEntity

    // Update sprite position based on transform
    if (sprite.parent is PositionComponent) {
      final PositionComponent positionComponent = sprite.parent! as PositionComponent;
      positionComponent.position = transform.position;
      positionComponent.scale = transform.scale;
      positionComponent.angle = transform.rotation;
    }
  }

  /// Set debug mode for rendering
  void setDebugMode(bool debug) {
    _debugMode = debug;
  }

  /// Set global opacity for all rendered entities
  void setGlobalOpacity(double opacity) {
    _globalOpacity = opacity.clamp(0.0, 1.0);
  }

  // Getters
  bool get debugMode => _debugMode;
  double get globalOpacity => _globalOpacity;
}

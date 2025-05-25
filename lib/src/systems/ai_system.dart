import 'package:flame/components.dart';

import '../components/ai_component.dart';
import '../entities/enemy.dart';
import '../entities/entity.dart';
import '../player/player.dart';
import 'base_system.dart';

/// System that manages AI behavior execution
/// Handles enemy behaviors, NPC routines, and environmental AI
class AISystem extends BaseSystem {
  AISystem();

  // Configuration
  double _difficultyMultiplier = 1;

  // Player reference for AI targeting
  Player? _playerEntity;
  // Optimization settings
  bool _useProximityProcessing = true;
  // Will be used in Sprint 3 for AI optimization when implementing dynamic LOD for AI
  // ignore: unused_field
  double _proximityThreshold = 1200; // Distance beyond which AI is simplified
  int _maxActiveAIEntities = 20; // Maximum number of fully active AI entities

  @override
  void processSystem(double dt) {
    // Skip AI processing if no player (target) exists
    if (_playerEntity == null) return;

    // Apply proximity-based processing if enabled
    if (_useProximityProcessing && _playerEntity != null) {
      // Get player position for AI targeting
      final Vector2 playerPosition = _playerEntity!.position.clone();

      // Sort entities by distance to player
      final List<Entity> sortedEntities = _getSortedEntitiesByDistance(playerPosition);

      // Limit number of fully processed AI entities
      if (sortedEntities.length > _maxActiveAIEntities) {
        // Process only the closest entities
        for (int i = 0; i < _maxActiveAIEntities && i < sortedEntities.length; i++) {
          final Entity entity = sortedEntities[i];
          if (entity.isActive) {
            processEntity(entity, dt);
          }
        }
        return; // Skip the normal processing in BaseSystem.update
      }
    }

    // Normal processing will continue in BaseSystem.update
  }

  @override
  bool canProcessEntity(Entity entity) {
    return entity.children.whereType<AIComponent>().isNotEmpty;
  }

  @override
  void processEntity(Entity entity, double dt) {
    if (_playerEntity == null) return;

    final Vector2 playerPosition = _playerEntity!.position.clone();
    processEntityAI(entity, dt, playerPosition);
  }

  /// Process AI for a single entity
  void processEntityAI(Entity entity, double dt, Vector2 playerPosition) {
    // Find AI component on the entity
    final Iterable<AIComponent> aiComponents = entity.children.whereType<AIComponent>();
    if (aiComponents.isEmpty) return;

    final AIComponent aiComponent = aiComponents.first;

    // Calculate distance to player
    final double distanceToPlayer = entity.position.distanceTo(playerPosition);

    // Set target if entity is an enemy and player is within detection range
    if (entity is Enemy) {
      final bool isPlayerDetected = distanceToPlayer <= aiComponent.detectionRange;
      aiComponent.setTarget(playerPosition, isPlayerDetected);
    }

    // AI state logic is handled within the component's update method
    // This system just provides context, like player position
  }

  /// Get entities sorted by distance to a position (closest first)
  List<Entity> _getSortedEntitiesByDistance(Vector2 position) {
    final List<Entity> sortedEntities = List<Entity>.from(entities);

    // Sort by distance to the given position
    sortedEntities.sort((Entity a, Entity b) {
      final double distA = a.position.distanceTo(position);
      final double distB = b.position.distanceTo(position);
      return distA.compareTo(distB);
    });

    return sortedEntities;
  }

  /// Set the player entity reference
  void setPlayerEntity(Player player) {
    _playerEntity = player;
  }

  /// Set global difficulty multiplier
  void setDifficultyMultiplier(double difficulty) {
    _difficultyMultiplier = difficulty;
  }

  /// Set proximity optimization settings
  void setProximitySettings({bool? use, double? threshold, int? maxEntities}) {
    if (use != null) _useProximityProcessing = use;
    if (threshold != null) _proximityThreshold = threshold;
    if (maxEntities != null) _maxActiveAIEntities = maxEntities;
  }

  @override
  void initialize() {
    // Initialize AI system
  }

  // Getters
  double get difficultyMultiplier => _difficultyMultiplier;
}

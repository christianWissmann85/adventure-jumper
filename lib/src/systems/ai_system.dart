import 'package:flame/components.dart';

import '../components/ai_component.dart';
import '../entities/enemy.dart';
import '../entities/entity.dart';
import '../entities/npc.dart';
import '../player/player.dart';
import 'base_system.dart';

/// System that manages AI behavior execution
/// Handles enemy behaviors, NPC routines, and environmental AI
/// Enhanced in T3.6 to process NPC behaviors including interaction detection and behavior patterns
class AISystem extends BaseSystem {
  AISystem();

  // Configuration
  double _difficultyMultiplier = 1;

  // Player reference for AI targeting and NPC interactions
  Player? _playerEntity;

  // Optimization settings
  bool _useProximityProcessing = true;
  // Will be used in Sprint 3 for AI optimization when implementing dynamic LOD for AI
  // ignore: unused_field
  double _proximityThreshold = 1200; // Distance beyond which AI is simplified
  int _maxActiveAIEntities = 20; // Maximum number of fully active AI entities

  // T3.6: NPC-specific processing
  final List<NPC> _activeNPCs = <NPC>[];
  final List<Enemy> _activeEnemies = <Enemy>[];

  // T3.6.2: Interaction range tracking
  final Map<String, double> _npcInteractionDistances = <String, double>{};
  final Map<String, bool> _npcInteractionStates = <String, bool>{};

  // T3.6.4: Proximity detection settings
  final double _npcProximityUpdateRate =
      0.1; // Update NPC proximity every 100ms
  double _npcProximityTimer = 0.0;
  @override
  void processSystem(double dt) {
    // Skip AI processing if no player (target) exists
    if (_playerEntity == null) return;

    // T3.6.4: Update proximity detection timer
    _npcProximityTimer += dt;

    // T3.6.1: Process NPC behaviors first (they have priority for interaction)
    _processNPCBehaviors(dt);

    // Apply proximity-based processing if enabled
    if (_useProximityProcessing && _playerEntity != null) {
      // Get player position for AI targeting
      final Vector2 playerPosition = _playerEntity!.position.clone();

      // Sort entities by distance to player
      final List<Entity> sortedEntities =
          _getSortedEntitiesByDistance(playerPosition);

      // Limit number of fully processed AI entities
      if (sortedEntities.length > _maxActiveAIEntities) {
        // Process only the closest entities
        for (int i = 0;
            i < _maxActiveAIEntities && i < sortedEntities.length;
            i++) {
          final Entity entity = sortedEntities[i];
          if (entity.isActive && entity is! NPC) {
            // NPCs already processed above
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
    final Iterable<AIComponent> aiComponents =
        entity.children.whereType<AIComponent>();
    if (aiComponents.isEmpty) return;

    final AIComponent aiComponent = aiComponents.first;

    // Calculate distance to player
    final double distanceToPlayer = entity.position.distanceTo(playerPosition);

    // Set target if entity is an enemy and player is within detection range
    if (entity is Enemy) {
      final bool isPlayerDetected =
          distanceToPlayer <= aiComponent.detectionRange;
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

  /// T3.6.1: Process NPC behaviors with interaction detection and state management
  void _processNPCBehaviors(double dt) {
    if (_playerEntity == null) return;

    // T3.6.1: Update active NPC list from entities
    _updateActiveNPCList();

    final Vector2 playerPosition = _playerEntity!.position.clone();

    // T3.6.1: Process each active NPC
    for (final NPC npc in _activeNPCs) {
      if (!npc.isActive) continue; // T3.6.2: Calculate interaction distance
      final double distanceToPlayer = npc.getDistanceToPlayer(playerPosition);
      final String npcId = npc.id;

      // T3.6.2: Store current interaction distance
      _npcInteractionDistances[npcId] = distanceToPlayer;

      // T3.6.2: Check if player is in interaction range
      final bool inInteractionRange = npc.isInInteractionRange(playerPosition);
      final bool wasInInteractionRange = _npcInteractionStates[npcId] ?? false;

      // T3.6.3: Handle interaction state transitions
      if (inInteractionRange != wasInInteractionRange) {
        _handleNPCInteractionStateChange(
          npc,
          npcId,
          inInteractionRange,
          playerPosition,
        );
      }

      // T3.6.2: Update interaction states
      _npcInteractionStates[npcId] = inInteractionRange;

      // T3.6.4: Perform proximity-based updates if timer allows
      if (_npcProximityTimer >= _npcProximityUpdateRate) {
        _updateNPCProximityBehavior(npc, playerPosition, distanceToPlayer);
      }

      // T3.6.1: Process AI behaviors for NPCs using standard AI processing
      _processNPCAI(npc, dt, playerPosition);
    }

    // T3.6.4: Reset proximity update timer
    if (_npcProximityTimer >= _npcProximityUpdateRate) {
      _npcProximityTimer = 0.0;
    }
  }

  /// T3.6.1: Update the list of active NPCs from all entities
  void _updateActiveNPCList() {
    _activeNPCs.clear();
    _activeEnemies.clear();

    for (final Entity entity in entities) {
      if (!entity.isActive) continue;

      if (entity is NPC) {
        _activeNPCs.add(entity);
      } else if (entity is Enemy) {
        _activeEnemies.add(entity);
      }
    }
  }

  /// T3.6.3: Handle NPC interaction state changes (entering/leaving interaction range)
  void _handleNPCInteractionStateChange(
    NPC npc,
    String npcId,
    bool inInteractionRange,
    Vector2 playerPosition,
  ) {
    if (inInteractionRange) {
      // T3.6.3: Player entered interaction range
      print('Player entered interaction range of ${npc.name}');

      // Update NPC interaction availability
      npc.updateInteractionAvailability(playerPosition);

      // Handle automatic state transitions if NPC is idle
      if (npc.isIdle && npc.canInteract) {
        // NPC can potentially start interaction, but wait for player input
        // This is where you'd integrate with an interaction input system
      }
    } else {
      // T3.6.3: Player left interaction range
      print('Player left interaction range of ${npc.name}');

      // End any ongoing interactions
      if (npc.isTalking) {
        npc.endInteraction();
      }

      // Update interaction availability
      npc.updateInteractionAvailability(playerPosition);
    }
  }

  /// T3.6.4: Update NPC proximity-based behaviors
  void _updateNPCProximityBehavior(
    NPC npc,
    Vector2 playerPosition,
    double distance,
  ) {
    // T3.6.4: Update interaction availability based on proximity
    npc.updateInteractionAvailability(playerPosition);

    // T3.6.4: Handle visual feedback range
    if (npc.isInVisualFeedbackRange(playerPosition)) {
      // NPC should show visual feedback (handled by NPC's own update logic)
      // This is where you'd trigger visual effects, animations, etc.
    }

    // T3.6.4: Update NPC awareness based on distance
    if (distance <= npc.interactionRange * 0.5) {
      // Player is very close - NPC should be highly aware
      // Could trigger special close-proximity behaviors
    } else if (distance <= npc.interactionRange) {
      // Player is in interaction range - normal awareness
    } else if (distance <= npc.visualFeedbackRange) {
      // Player is in visual range - low awareness
    }
  }

  /// T3.6.1: Process AI behaviors specific to NPCs
  void _processNPCAI(NPC npc, double dt, Vector2 playerPosition) {
    // Find AI component on the NPC
    final Iterable<AIComponent> aiComponents =
        npc.children.whereType<AIComponent>();
    if (aiComponents.isEmpty) return;

    final AIComponent aiComponent =
        aiComponents.first; // T3.6.1: NPCs use different AI logic than enemies
    // Set player position for AI awareness (but NPCs don't "target" like enemies)
    final double distanceToPlayer = npc.position.distanceTo(playerPosition);
    final bool isPlayerNearby = distanceToPlayer <=
        (aiComponent.detectionRange * _difficultyMultiplier);

    // T3.6.1: Update AI component with player awareness (without setting as target)
    if (isPlayerNearby) {
      // NPC is aware of player but doesn't target them aggressively
      // This could influence idle behaviors, dialogue availability, etc.
      aiComponent.setTarget(
        playerPosition,
        false,
      ); // false = not a hostile target
    }

    // T3.6.1: Let the NPC's AI component handle its own update logic
    // The AI component will manage patrol routes, idle behaviors, etc.
  }

  /// T3.6.2: Get interaction distance for a specific NPC
  double? getNPCInteractionDistance(String npcId) {
    return _npcInteractionDistances[npcId];
  }

  /// T3.6.2: Check if NPC is currently in interaction range
  bool? isNPCInInteractionRange(String npcId) {
    return _npcInteractionStates[npcId];
  }

  /// T3.6.1: Get list of active NPCs
  List<NPC> get activeNPCs => List<NPC>.unmodifiable(_activeNPCs);

  /// T3.6.1: Get list of active enemies
  List<Enemy> get activeEnemies => List<Enemy>.unmodifiable(_activeEnemies);
}

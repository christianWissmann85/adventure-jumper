# Enemy AI - Technical Design Document

## 1. Overview

Defines the implementation of enemy artificial intelligence systems, including behavior trees, pathfinding, decision-making, and combat AI for all enemy types in Adventure Jumper.

*For enemy design specifications, see [Enemies of Aetheris](../../01_Game_Design/Characters/03-enemies.md).*

### Purpose
- Implement intelligent and engaging enemy behaviors
- Create varied and challenging AI patterns for different enemy types
- Handle pathfinding and navigation in complex environments
- Integrate AI behaviors with combat and environmental systems

### Scope
- Base AI architecture and behavior trees
- Pathfinding and navigation systems
- Combat AI and tactical decisions
- State machines for enemy behaviors
- AI difficulty scaling and adaptation

## 2. Class Design

### Core AI Classes

```dart
// Main AI system that coordinates all enemy AI behaviors
class AISystem extends BaseSystem {
  // AI entity management and coordination
  // AI execution scheduling
  // Target sharing and awareness
  // Performance optimization
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has AI components
    return entity.children.whereType<EnemyAI>().isNotEmpty ||
           entity.hasTags(['enemy', 'npc', 'ai-controlled']);
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Update AI components on this entity
    // Process behavior trees
    // Update path finding and movement
  }
  
  @override
  void processSystem(double dt) {
    // Handle global AI concerns
    // Manage target visibility across enemies
    // Optimize AI processing based on distance to player
  }
}

// Base AI controller for all enemies
abstract class EnemyAI extends GameComponent {
  // Behavior tree execution
  // State management
  // Decision making
  // Target tracking
}

// Behavior tree system
class BehaviorTree {
  // Tree structure and nodes
  // Execution logic
  // State persistence
  // Dynamic modification
}

// Pathfinding and navigation
class AINavigation {
  // Path calculation
  // Obstacle avoidance
  // Movement execution
  // Goal tracking
}
```

### Specific Enemy AI Classes

```dart
// Corrupted Drone AI (flying enemy)
class CorruptedDroneAI extends EnemyAI {
  // Hover and patrol behavior
  // Dive attack patterns
  // Evasion maneuvers
}

// Void Crawler AI (ground enemy)
class VoidCrawlerAI extends EnemyAI {
  // Ground-based movement
  // Wall climbing abilities
  // Ambush tactics
}

// Crystal Guardian AI (boss enemy)
class CrystalGuardianAI extends EnemyAI {
  // Multi-phase behaviors
  // Area denial attacks
  // Defensive positioning
}
```

## 3. Data Structures

### AI State
```dart
class AIState {
  String currentState;       // Current behavior state
  GameComponent target;      // Current target entity
  Vector2 destination;       // Movement goal
  double alertLevel;         // Awareness/aggression level
  DateTime lastTargetSeen;   // When target was last detected
  List<Vector2> patrolPath;  // Patrol route points
  Map<String, dynamic> blackboard; // Shared AI data
}
```

### Behavior Node
```dart
abstract class BehaviorNode {
  String nodeId;
  NodeType type;            // Selector, Sequence, Action, Condition
  List<BehaviorNode> children;
  NodeStatus status;        // Running, Success, Failure
  
  NodeStatus execute(AIState state);
  void reset();
}
```

### AI Senses
```dart
class AISenses {
  double sightRange;        // Visual detection range
  double hearingRange;      // Audio detection range
  double fieldOfView;       // Visual angle (degrees)
  bool canSeeTarget;        // Current target visibility
  bool canHearTarget;       // Current target audibility
  List<GameComponent> detectedTargets; // All detected entities
}
```

## 4. Algorithms

### Pathfinding (A* Algorithm)
```
function findPath(start, goal):
  openSet = [start]
  closedSet = []
  
  while openSet is not empty:
    current = node in openSet with lowest fScore
    
    if current == goal:
      return reconstructPath(current)
    
    move current from openSet to closedSet
    
    for each neighbor of current:
      if neighbor in closedSet:
        continue
      
      tentativeGScore = gScore[current] + distance(current, neighbor)
      
      if neighbor not in openSet:
        add neighbor to openSet
      elif tentativeGScore >= gScore[neighbor]:
        continue
      
      update neighbor's scores and parent
  
  return no path found
```

### Behavior Tree Execution
```
function executeBehaviorTree(rootNode, aiState):
  return rootNode.execute(aiState)

function executeSelector(children, aiState):
  for each child in children:
    status = child.execute(aiState)
    if status != FAILURE:
      return status
  return FAILURE

function executeSequence(children, aiState):
  for each child in children:
    status = child.execute(aiState)
    if status != SUCCESS:
      return status
  return SUCCESS
```

### Target Detection
```
function detectTargets(aiSenses, aiPosition):
  detectedTargets = []
  
  for each potential target in range:
    distance = calculateDistance(aiPosition, target.position)
    
    if distance <= aiSenses.sightRange:
      angle = calculateAngle(aiPosition, target.position)
      
      if angle <= aiSenses.fieldOfView / 2:
        if hasLineOfSight(aiPosition, target.position):
          detectedTargets.add(target)
    
    if distance <= aiSenses.hearingRange:
      if target.isMoving() or target.isMakingNoise():
        detectedTargets.add(target)
  
  return detectedTargets
```

## 5. API/Interfaces

### AI Controller Interface
```dart
interface IEnemyAI {
  void initialize();
  void updateAI(double deltaTime);
  void setTarget(GameComponent target);
  void receiveSignal(String signal, Map<String, dynamic> data);
  AIState getCurrentState();
}

interface IAIBehavior {
  NodeStatus execute(AIState state);
  void onEnter(AIState state);
  void onExit(AIState state);
}
```

### Navigation Interface
```dart
interface IAINavigation {
  List<Vector2> findPath(Vector2 start, Vector2 goal);
  void setDestination(Vector2 destination);
  bool isPathBlocked();
  void updateMovement(double deltaTime);
}

interface IAISenses {
  List<GameComponent> detectTargets();
  bool canSeeTarget(GameComponent target);
  bool canHearTarget(GameComponent target);
  void updateSenses(double deltaTime);
}
```

## 6. Dependencies

### System Dependencies
- **Physics System**: For collision detection and movement
- **Combat System**: For attack execution and damage handling
- **Level Management**: For navigation mesh and pathfinding data
- **Player Character**: For target tracking and interaction
- **Audio System**: For AI sound effects and audio cues

### Component Dependencies
- Level geometry for pathfinding obstacles
- Trigger zones for AI state changes
- Visual effects for AI abilities and attacks

## 7. File Structure

```
lib/
  game/
    ai/
      enemy_ai.dart                 # Base AI controller
      behavior_tree.dart           # Behavior tree system
      ai_navigation.dart           # Pathfinding and movement
      ai_senses.dart              # Detection and awareness
      ai_state.dart               # AI state management
      behaviors/
        combat_behaviors.dart      # Combat-related behaviors
        patrol_behaviors.dart      # Patrol and movement behaviors
        react_behaviors.dart       # Reaction and response behaviors
      enemies/
        corrupted_drone_ai.dart    # Drone AI implementation
        void_crawler_ai.dart       # Crawler AI implementation
        crystal_guardian_ai.dart   # Guardian boss AI
        forge_automaton_ai.dart    # Industrial enemy AI
        temporal_wraith_ai.dart    # Time-based enemy AI
    pathfinding/
      astar.dart                   # A* pathfinding algorithm
      navigation_mesh.dart         # Navigation mesh generation
      path_smoother.dart          # Path optimization
```

## 8. Performance Considerations

### Optimization Strategies
- Level-of-detail AI processing based on distance from player
- Shared pathfinding calculations for similar enemies
- Behavior tree node caching and reuse
- Spatial partitioning for target detection

### Memory Management
- Object pooling for pathfinding nodes
- Efficient storage of behavior tree states
- Lazy evaluation of expensive AI calculations

## 9. Testing Strategy

### Unit Tests
- Behavior tree execution correctness
- Pathfinding algorithm accuracy
- Target detection range and accuracy
- AI state transition validation

### Integration Tests
- AI integration with combat system
- Navigation in complex level geometry
- Performance under multiple active AIs
- AI response to player actions

## 10. Implementation Notes

### Development Phases
1. **Phase 1**: Base AI architecture and simple behaviors
2. **Phase 2**: Pathfinding and navigation systems
3. **Phase 3**: Combat AI and attack behaviors
4. **Phase 4**: Advanced behaviors and boss AI
5. **Phase 5**: Performance optimization and polish

### AI Design Principles
- **Predictable but not boring**: Consistent patterns with variations
- **Fair play**: Clear telegraphs for dangerous attacks
- **Emergent complexity**: Simple rules creating complex behaviors
- **Player-focused**: AI that enhances player experience

## 11. Future Considerations

### Expandability
- Machine learning integration for adaptive AI
- Cooperative AI behaviors between different enemy types
- Dynamic difficulty adjustment based on player performance
- Modular behavior system for easy enemy creation

### Advanced Features
- Procedural behavior generation
- AI director system for pacing control
- Multi-layered decision making (strategic, tactical, reactive)
- AI communication and coordination systems

## Related Design Documents

- See [Enemies of Aetheris](../../01_Game_Design/Characters/03-enemies.md) for enemy design specifications
- See [Combat System Design](../../01_Game_Design/Mechanics/CombatSystem_Design.md) for combat mechanics
- See [World-Specific Enemies](../../01_Game_Design/Worlds/00-World-Connections.md) for environment-based behavior

# System Architecture - Technical Design Document

## 1. Overview

Defines the high-level architecture of Adventure Jumper, emphasizing design cohesion principles that support Fluid & Expressive Movement, Engaging & Dynamic Combat, and Progressive Mastery throughout Kael's journey.

> **Related Documents:**
> - [Architecture Overview](../Architecture.md) - High-level architecture diagrams
> - [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md) - Design principles and validation criteria
> - [Agile Sprint Plan](../../04_Project_Management/AgileSprintPlan.md) - Sprint delivery timeline
> - [Component Reference](../ComponentsReference.md) - Component usage across modules
> - [AssetPipeline.md](../AssetPipeline.md) - Asset strategy supporting architecture

### Purpose
- Establish architectural patterns that enhance responsive gameplay and player expression
- Define component communication protocols that support seamless system integration
- Ensure scalable and maintainable code structure that grows with player abilities
- Guide implementation decisions that prioritize player experience over technical complexity

### Scope
- Game engine integration (Flame) optimized for 60fps gameplay
- Component-based architecture supporting fluid movement and combat integration  
- System communication patterns enabling real-time responsiveness
- Performance optimization strategies for smooth player experience
- Design cohesion validation framework ensuring technical decisions support game vision

## 2. Class Design

### Core Architecture Classes

```dart
// Main game class - entry point and system coordinator
class AdventureJumperGame extends FlameGame {
  // System managers
  // Game state management
  // Scene coordination
}

// Base component for all game entities
abstract class Entity extends Component {
  // Common component functionality
  // State management
  // Lifecycle methods
}

// System interface that all systems implement
abstract class System {
  // System active state
  bool get isActive;
  set isActive(bool value);
  
  // System priority for update order
  int get priority;
  set priority(int value);
  
  // Core system methods
  void update(double dt);
  void initialize();
  void dispose();
  
  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
}

// Base system implementation
abstract class BaseSystem implements System {
  // Entity list for tracking
  final List<Entity> _entities = <Entity>[];
  
  // System state
  bool _isActive = true;
  int _priority = 0;
  
  // Entity management
  void addEntity(Entity entity) {
    if (canProcessEntity(entity) && !_entities.contains(entity)) {
      _entities.add(entity);
      onEntityAdded(entity);
    }
  }
  
  void removeEntity(Entity entity) {
    if (_entities.remove(entity)) {
      onEntityRemoved(entity);
    }
  }
  
  // System update loop
  void update(double dt) {
    if (!isActive) return;
    
    // Process all registered entities
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;
      processEntity(entity, dt);
    }
    
    // Handle system-wide logic
    processSystem(dt);
  }
  
  // Override these in derived systems
  bool canProcessEntity(Entity entity);
  void processEntity(Entity entity, double dt);
  void processSystem(double dt) {}
  void onEntityAdded(Entity entity) {}
  void onEntityRemoved(Entity entity) {}
}

// Flame-specific system implementation
abstract class BaseFlameSystem extends Component implements System {
  // Entity list for tracking
  final List<Entity> _entities = <Entity>[];
  
  // System state
  bool _isActive = true;
  int _priority = 0;
  
  // Entity management
  void addEntity(Entity entity) {
    if (canProcessEntity(entity) && !_entities.contains(entity)) {
      _entities.add(entity);
      onEntityAdded(entity);
    }
  }
  
  void removeEntity(Entity entity) {
    if (_entities.remove(entity)) {
      onEntityRemoved(entity);
    }
  }
  
  // Component integration
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isActive) return;
    
    // Process all registered entities
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;
      processEntity(entity, dt);
    }
    
    // Handle system-wide logic
    processSystem(dt);
  }
  
  // Override these in derived systems
  bool canProcessEntity(Entity entity);
  void processEntity(Entity entity, double dt);
  void processSystem(double dt) {}
  void onEntityAdded(Entity entity) {}
  void onEntityRemoved(Entity entity) {}
}
```

### Key Responsibilities
- **AdventureGame**: Main game loop, system coordination, scene management
- **GameComponent**: Base functionality for all game entities
- **GameSystem**: Abstract base for specialized systems (Combat, AI, Audio, etc.)

## 3. Data Structures

### Game Configuration
```dart
class GameConfig {
  // Performance settings
  // Control mappings
  // Audio settings
  // Graphics quality
}
```

### System Organization
```dart
// Systems are added to the game world directly
class GameWorld {
  // Add systems to the game
  void addSystem(System system);
  
  // Systems organized by function
  late final RenderSystem renderSystem;        // extends BaseSystem
  late final PhysicsSystem physicsSystem;      // extends BaseFlameSystem
  late final MovementSystem movementSystem;    // extends BaseFlameSystem
  late final InputSystem inputSystem;          // extends BaseFlameSystem
  late final AISystem aiSystem;                // extends BaseSystem
  late final CombatSystem combatSystem;        // extends BaseSystem
  late final AetherSystem aetherSystem;        // extends BaseSystem
  late final AnimationSystem animationSystem;  // extends BaseSystem
  late final AudioSystem audioSystem;          // extends BaseSystem
  late final DialogueSystem dialogueSystem;    // extends BaseSystem
}
```

## 4. Algorithms

### Component Update Ordering
- Priority-based system updates
- Dependency resolution for system initialization
- Event propagation patterns

### System Processing Flow
1. Entity added to game world 
2. Each system evaluates the entity using `canProcessEntity()`
3. If a system can process the entity, it adds it to its internal list
4. On each update, systems process their entities in order of priority
5. Within each system, `processEntity()` is called for each active entity
6. After entity processing, `processSystem()` handles system-wide logic

### ECS Refactoring
The System architecture was refactored to improve maintainability and reduce code duplication:
- Created standardized base classes for all systems
- Implemented consistent entity filtering and processing patterns
- Reduced duplicate code across systems by ~200 lines
- Added backward compatibility methods for legacy code
- Standardized lifecycle management (initialize, update, dispose)

### Memory Management
- Object pooling for frequently created/destroyed entities
- Efficient component storage and retrieval
- Asset loading and unloading strategies

## 5. API/Interfaces

### System API
```dart
// Core System interface
abstract class System {
  // Whether this system is active
  bool get isActive;
  set isActive(bool value);

  // Priority for update order (higher values update first)
  int get priority;
  set priority(int value);

  // Core methods
  void update(double dt);
  void initialize();
  void dispose();
  
  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
  void initialize();
  void dispose();
  
  // Entity management
  void addEntity(Entity entity);
  void removeEntity(Entity entity);
}

// BaseSystem extension points
abstract class BaseSystem implements System {
  // Entity filtering
  bool canProcessEntity(Entity entity);
  
  // Entity processing
  void processEntity(Entity entity, double dt);
  
  // System-wide processing
  void processSystem(double dt);
  
  // Entity callbacks
  void onEntityAdded(Entity entity);
  void onEntityRemoved(Entity entity);
}
```

### Component Integration
```dart
// Components are added to entities
class Entity {
  // Add a component to this entity
  void add(Component component);
  
  // Get components by type
  T? getComponent<T extends Component>();
  List<T> getComponents<T extends Component>();
}
```

## 6. Dependencies

### External Dependencies
- **Flame Engine**: Core game framework
- **Flutter**: UI and platform integration
- **Dart**: Programming language and runtime

### Internal Dependencies
- All game systems depend on this architecture
- Asset management system
- Configuration management

## 7. File Structure

```
lib/
  game/
    adventure_game.dart              # Main game class
    core/
      game_component.dart            # Base component class
      game_system.dart              # Base system class
      system_registry.dart          # System management
      game_config.dart              # Configuration data
    systems/
      [individual system files]     # Specific system implementations
    events/
      game_events.dart              # Event system
      event_bus.dart               # Event communication
```

## 8. Performance Considerations

### Optimization Strategies
- Component pooling for enemies and effects
- Efficient update loop ordering
- Selective rendering based on viewport
- Asset streaming for large worlds

### Memory Management
- Automatic cleanup of unused components
- Efficient data structures for large collections
- Lazy loading of non-critical systems

## 9. Testing Strategy

### Unit Tests
- Individual component functionality
- System initialization and cleanup
- Event propagation correctness

### Integration Tests
- System communication protocols
- Performance under load
- Memory usage patterns

## 10. Implementation Notes

### Sprint-Aligned Development Phases
1. **Sprint 1**: Core architecture and 11-module scaffolding (Foundation)
   - Base classes for all 65+ planned classes
   - System registry and basic communication
   - Design Cohesion validation framework implementation
   
2. **Sprint 2-3**: System Integration and Movement Foundation  
   - Player movement systems emphasizing responsiveness
   - Basic physics optimized for gameplay feel
   - Input handling with buffering for fluid control
   
3. **Sprint 4-6**: Combat Integration and Ability Framework
   - Combat systems that enhance rather than interrupt movement
   - Ability framework supporting progressive mastery
   - Performance optimization for smooth gameplay
   
4. **Sprint 7+**: Advanced Features and Polish
   - World-specific mechanics integration
   - Advanced ability combinations
   - Final optimization and accessibility features

### Design Cohesion Validation Checkpoints

**Fluid & Expressive Movement Validation:**
- Input lag measurement: Target <2 frames for all player actions
- Movement transition smoothness verification
- Physics consistency testing across platforms
- Ability combo responsiveness validation

**Engaging & Dynamic Combat Validation:**
- Combat-movement integration testing
- Multiple approach validation for encounters
- Feedback clarity assessment (audio/visual)
- Damage calculation fairness verification

**Progressive Mastery Validation:**
- Ability complexity growth assessment
- Player skill expression metrics
- Learning curve progression testing
- Consistent growth pattern validation

### Design Patterns Used
- **Component Pattern**: For game entity composition supporting modularity
- **Observer Pattern**: For event handling enabling loose coupling
- **Strategy Pattern**: For swappable system behaviors supporting different play styles
- **Factory Pattern**: For component creation enabling consistent initialization

### Architecture Principles Supporting Design Cohesion
- **Responsiveness First**: All systems prioritize immediate feedback over complex simulation
- **Composable Design**: Systems built to work together seamlessly (movement + combat)
- **Progressive Complexity**: Architecture supports natural growth in player capabilities
- **Clear Interfaces**: Well-defined boundaries between systems for maintainability

## 11. Future Considerations

### Scalability
- Plugin architecture for modding support
- Network multiplayer foundation
- Cross-platform optimization

### Maintainability
- Clear separation of concerns
- Well-defined interfaces
- Comprehensive documentation

## Related Design Documents

- See [Architecture Overview](../Architecture.md) for high-level system design
- See [Core Gameplay Loop](../../01_Game_Design/Mechanics/CoreGameplayLoop.md) for gameplay systems integration
- See [Code Style Guide](../../05_Style_Guides/CodeStyle.md) for implementation standards
- See [TDD Overview](README.md) for all technical system details

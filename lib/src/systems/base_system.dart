import '../entities/entity.dart';
import 'system.dart';

/// A base implementation of the System interface that provides common functionality
/// for entity registration and management.
///
/// This class implements the basic entity management patterns that are common
/// across all systems, reducing code duplication.
abstract class BaseSystem implements System {
  BaseSystem();

  /// Entities being processed by this system
  final List<Entity> _entities = <Entity>[];

  /// Whether this system is currently active
  bool _isActive = true;
  @override
  bool get isActive => _isActive;
  @override
  set isActive(bool value) => _isActive = value;

  /// Priority for update order (higher values update first)
  int _priority = 0;
  @override
  int get priority => _priority;
  @override
  set priority(int value) => _priority = value;

  /// Get all entities managed by this system
  List<Entity> get entities => _entities;

  /// Number of entities in this system
  int get entityCount => _entities.length;

  /// Register an entity with this system if it has the required components
  @override
  void addEntity(Entity entity) {
    if (canProcessEntity(entity) && !_entities.contains(entity)) {
      _entities.add(entity);
      onEntityAdded(entity);
    }
  }

  /// Remove an entity from this system
  @override
  void removeEntity(Entity entity) {
    if (_entities.remove(entity)) {
      onEntityRemoved(entity);
    }
  }

  /// Process entities on update
  @override
  void update(double dt) {
    if (!isActive) return;

    // Process all registered entities
    for (final Entity entity in _entities) {
      if (!entity.isActive) continue;

      processEntity(entity, dt);
    }

    // Additional processing if needed
    processSystem(dt);
  }

  /// Set system active state
  void setActive(bool active) {
    isActive = active;
  }

  /// Clear all entities from the system
  void clearEntities() {
    _entities.clear();
  }

  @override
  void initialize() {
    // Default empty implementation
  }

  @override
  void dispose() {
    clearEntities();
  }

  /// Check if this entity can be processed by this system
  /// Subclasses should override this to check for required components
  bool canProcessEntity(Entity entity) => true;

  /// Process a single entity
  /// Subclasses must implement this method to define entity processing
  void processEntity(Entity entity, double dt);

  /// Process system-wide logic after entity processing
  /// Subclasses can override this for system-level processing after entities are updated
  void processSystem(double dt) {
    // Default empty implementation
  }

  /// Called when an entity is added to the system
  /// Subclasses can override for custom behavior
  void onEntityAdded(Entity entity) {
    // Default empty implementation
  }

  /// Called when an entity is removed from the system
  /// Subclasses can override for custom behavior
  void onEntityRemoved(Entity entity) {
    // Default empty implementation
  }

  /// Backward compatibility method for legacy code
  /// @deprecated Use addEntity instead
  void registerEntity(Entity entity) {
    addEntity(entity);
  }

  /// Backward compatibility method for legacy code
  /// @deprecated Use removeEntity instead
  void unregisterEntity(Entity entity) {
    removeEntity(entity);
  }
}

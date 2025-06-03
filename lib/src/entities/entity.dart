import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

import '../components/adv_sprite_component.dart';
import '../components/collision_component.dart';
import '../components/physics_component.dart';
import '../components/transform_component.dart';
import '../components/interfaces/physics_integration.dart';
import '../components/interfaces/transform_integration.dart';
import '../components/interfaces/collision_integration.dart';
import '../utils/logger.dart';

enum ComponentLifecycleStage {
  created,
  initializing,
  initialized,
  active,
  inactive,
  disposing,
  disposed,
  error,
}

class ComponentError {
  final String componentType;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  ComponentError({
    required this.componentType,
    required this.message,
    this.error,
    this.stackTrace,
  }) : timestamp = DateTime.now();
}

/// Base entity class for all game objects
/// Provides common functionality for entities in the game world
/// Enhanced with component lifecycle management and physics integration patterns
abstract class Entity extends PositionComponent {
  Entity({
    required Vector2 super.position,
    super.size,
    super.angle,
    super.anchor,
    super.priority,
    String? id,
    String? type,
  }) {
    if (id != null) _id = id;
    if (type != null) _type = type;
  }
  
  // Component lifecycle management
  final Map<Type, ComponentLifecycleStage> _componentLifecycle = {};
  final Map<Type, ComponentError?> _componentErrors = {};
  final List<Component> _managedComponents = [];
  
  // Required components
  late TransformComponent transformComponent;
  late CollisionComponent collision;
  
  // Optional components (may be null if not needed)
  PhysicsComponent? physics;
  AdvSpriteComponent? sprite;
  
  // Entity state
  bool _isActive = true;
  String _id = '';
  String _type = 'entity';
  bool _isInitialized = false;
  ComponentLifecycleStage _entityLifecycle = ComponentLifecycleStage.created;
  
  // Collision callback - this is assignable from external code
  Function(Entity)? onCollision;
  
  // Logger for entity operations
  static final _logger = GameLogger.getLogger('Entity');

  @override
  Future<void> onLoad() async {
    _logger.info('onLoad() called - id: $_id, type: $_type');
    _entityLifecycle = ComponentLifecycleStage.initializing;
    
    try {
      await super.onLoad();

      // Create and add required components with lifecycle tracking
      transformComponent = TransformComponent();
      collision = CollisionComponent();
      
      await initializeComponent(transformComponent);
      await initializeComponent(collision);
      
      // Setup entity-specific components after required components are initialized
      await setupEntity();
      
      // Validate all components are properly initialized
      await _validateComponentInitialization();
      
      _entityLifecycle = ComponentLifecycleStage.initialized;
      _isInitialized = true;
      
      _logger.info(
        'onLoad() completed - id: $_id, type: $_type, components: ${_managedComponents.length}',
      );
    } catch (e, stack) {
      _entityLifecycle = ComponentLifecycleStage.error;
      _logger.severe('Entity initialization failed: $e', e, stack);
      await _handleEntityError(e, stack);
      rethrow;
    }
  }

  @override
  void onMount() {
    _logger.info('onMount() called - id: $_id, type: $_type');
    super.onMount();
    
    if (_isInitialized && _entityLifecycle == ComponentLifecycleStage.initialized) {
      _entityLifecycle = ComponentLifecycleStage.active;
      _activateAllComponents();
    }
    
    _logger.info(
      'onMount() completed - id: $_id, type: $_type, lifecycle: $_entityLifecycle',
    );
  }

  @override
  void onGameResize(Vector2 size) {
    _logger.info(
      'onGameResize() called - id: $_id, type: $_type, size: $size',
    );
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isActive || _entityLifecycle != ComponentLifecycleStage.active) return;

    // Synchronize component states if needed
    _synchronizeComponentStates();
    
    // Entity-specific update logic
    updateEntity(dt);
  }

  /// Custom entity setup (to be implemented by subclasses)
  Future<void> setupEntity() async {
    // Override in subclasses
  }

  /// Custom entity update logic (to be implemented by subclasses)
  void updateEntity(double dt) {
    // Override in subclasses
  }

  /// Trigger collision with another entity
  void triggerCollision(Entity other) {
    // Call collision callback if set
    onCollision?.call(other);
  }

  /// Activate the entity and all its components
  void activate() {
    _isActive = true;
    if (_entityLifecycle == ComponentLifecycleStage.inactive) {
      _entityLifecycle = ComponentLifecycleStage.active;
      _activateAllComponents();
    }
  }

  /// Deactivate the entity and all its components
  void deactivate() {
    _isActive = false;
    if (_entityLifecycle == ComponentLifecycleStage.active) {
      _entityLifecycle = ComponentLifecycleStage.inactive;
      _deactivateAllComponents();
    }
  }

  @override
  void render(Canvas canvas) {
    // Always call super.render to ensure the component tree is processed correctly
    super.render(canvas);
  }
  
  @override
  void onRemove() {
    _logger.info('onRemove() called - id: $_id, type: $_type');
    _entityLifecycle = ComponentLifecycleStage.disposing;
    
    // Dispose all managed components
    _disposeAllComponents();
    
    _entityLifecycle = ComponentLifecycleStage.disposed;
    super.onRemove();
  }

  /// Get entity ID
  String get id => _id;

  /// Get entity type
  String get type => _type;

  /// Check if entity is active
  bool get isActive => _isActive;
  
  /// Get entity lifecycle stage
  ComponentLifecycleStage get lifecycleStage => _entityLifecycle;
  
  /// Check if entity is properly initialized
  bool get isInitialized => _isInitialized;
  
  // Component lifecycle management methods
  
  /// Initialize a component with lifecycle tracking
  @protected
  Future<void> initializeComponent(Component component) async {
    final componentType = component.runtimeType;
    _componentLifecycle[componentType] = ComponentLifecycleStage.initializing;
    
    try {
      await add(component);
      _managedComponents.add(component);
      
      // Track physics component
      if (component is PhysicsComponent) {
        physics = component;
        // Set up physics coordination if needed
        await _setupPhysicsCoordination(component);
      }
      
      _componentLifecycle[componentType] = ComponentLifecycleStage.initialized;
      _componentErrors[componentType] = null;
    } catch (e, stack) {
      _componentLifecycle[componentType] = ComponentLifecycleStage.error;
      _componentErrors[componentType] = ComponentError(
        componentType: componentType.toString(),
        message: 'Component initialization failed: $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
  
  /// Set up physics coordination for components that support it
  Future<void> _setupPhysicsCoordination(Component component) async {
    if (physics == null || component is! IPhysicsIntegration) return;
    
    // Sync initial physics state
    final physicsState = physics!.getPhysicsState();
    await (component as IPhysicsIntegration).updatePhysicsState(physicsState);
  }
  
  /// Validate all components are properly initialized
  Future<void> _validateComponentInitialization() async {
    for (final component in _managedComponents) {
      final componentType = component.runtimeType;
      final lifecycle = _componentLifecycle[componentType];
      
      if (lifecycle != ComponentLifecycleStage.initialized) {
        final error = _componentErrors[componentType];
        throw StateError(
          'Component $componentType failed to initialize: ${error?.message ?? "Unknown error"}',
        );
      }
    }
  }
  
  /// Activate all managed components
  void _activateAllComponents() {
    for (final component in _managedComponents) {
      final componentType = component.runtimeType;
      if (_componentLifecycle[componentType] == ComponentLifecycleStage.initialized ||
          _componentLifecycle[componentType] == ComponentLifecycleStage.inactive) {
        _componentLifecycle[componentType] = ComponentLifecycleStage.active;
      }
    }
  }
  
  /// Deactivate all managed components
  void _deactivateAllComponents() {
    for (final component in _managedComponents) {
      final componentType = component.runtimeType;
      if (_componentLifecycle[componentType] == ComponentLifecycleStage.active) {
        _componentLifecycle[componentType] = ComponentLifecycleStage.inactive;
      }
    }
  }
  
  /// Dispose all managed components
  void _disposeAllComponents() {
    for (final component in _managedComponents) {
      final componentType = component.runtimeType;
      _componentLifecycle[componentType] = ComponentLifecycleStage.disposing;
      
      try {
        component.removeFromParent();
        _componentLifecycle[componentType] = ComponentLifecycleStage.disposed;
      } catch (e, stack) {
        _logger.severe(
          'Failed to dispose component $componentType: $e',
          e,
          stack,
        );
      }
    }
    
    _managedComponents.clear();
    _componentLifecycle.clear();
    _componentErrors.clear();
  }
  
  /// Synchronize component states with physics system
  void _synchronizeComponentStates() {
    if (physics == null) return;
    
    // Sync transform component with physics position
    final transform = transformComponent as ITransformIntegration;
    // Sync position directly with entity's position property
    // TransformComponent no longer allows direct position setting
    position.setFrom(physics!.position);
      
    // Sync collision component with physics state
    final collisionIntegration = collision as ICollisionIntegration;
    // Sync collision component with physics state
    final physicsState = physics!.getPhysicsState();
    collisionIntegration.syncWithPhysics(physicsState);
    }
  
  /// Handle entity-level errors with recovery procedures
  Future<void> _handleEntityError(Object error, StackTrace stack) async {
    _logger.severe(
      'Entity error occurred - attempting recovery: $error',
      error,
      stack,
    );
    
    // Attempt to recover based on entity state
    if (_entityLifecycle == ComponentLifecycleStage.initializing) {
      // Reset initialization state and retry
      _entityLifecycle = ComponentLifecycleStage.created;
      _isInitialized = false;
      
      // Clean up partially initialized components
      for (final component in List.from(_managedComponents)) {
        try {
          component.removeFromParent();
        } catch (_) {}
      }
      _managedComponents.clear();
      _componentLifecycle.clear();
    }
  }
  
  /// Get the lifecycle stage of a specific component type
  ComponentLifecycleStage? getComponentLifecycle(Type componentType) {
    return _componentLifecycle[componentType];
  }
  
  /// Get error information for a specific component type
  ComponentError? getComponentError(Type componentType) {
    return _componentErrors[componentType];
  }
  
  /// Check if all components are in a healthy state
  bool areAllComponentsHealthy() {
    for (final entry in _componentLifecycle.entries) {
      if (entry.value == ComponentLifecycleStage.error ||
          entry.value == ComponentLifecycleStage.disposed) {
        return false;
      }
    }
    return true;
  }
}

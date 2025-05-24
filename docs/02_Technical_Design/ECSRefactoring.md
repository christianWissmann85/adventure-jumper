# Entity-Component-System (ECS) Refactoring

This document outlines the refactoring performed on the Entity-Component-System (ECS) architecture in Adventure Jumper for Sprint 1.

## Overview of Changes

### 1. Created Base System Classes

To eliminate code duplication across system implementations, we introduced two base classes:

- **`BaseSystem`** - A standard implementation of the `System` interface that handles common entity management tasks
- **`BaseFlameSystem`** - A specialized version that extends Flame's `Component` class while implementing the `System` interface

### 2. Refactored System Implementations

The following systems were updated to use the new base classes:

- **`RenderSystem`** now extends `BaseSystem`
- **`PhysicsSystem`** now extends `BaseFlameSystem`
- **`MovementSystem`** now extends `BaseFlameSystem`
- **`AISystem`** now extends `BaseSystem`

### 3. Updated API Usage

The refactoring changed the entity registration API:
- Removed `registerEntity()` and `unregisterEntity()` methods from individual systems
- Standardized on the `addEntity()` and `removeEntity()` methods from the System interface
- Updated all code that was using the old methods to use the new standardized methods

### 3. Improved Entity Processing Pattern

The new base classes implement a consistent entity processing pattern:

```dart
void update(double dt) {
  if (!isActive) return;

  // Process all registered entities
  for (final Entity entity in _entities) {
    if (!entity.isActive) continue;
    processEntity(entity, dt);
  }
  
  // Additional system-wide processing
  processSystem(dt);
}
```

Systems now only need to implement:
- `canProcessEntity(Entity)` - Check if an entity can be processed by this system
- `processEntity(Entity, double)` - Process a single entity
- `processSystem(double)` - Optional system-wide processing after entities are processed

### 4. Enhanced Error Handling and Null Safety

- Added proper entity validity checks before processing
- Used the `canProcessEntity()` method to validate entities before adding them
- Made null-safety explicit with proper null checks
- Implemented safe component access through type checking
- Added safeguards against duplicate entity registration
- Included entity activation checks before processing

For example, in the `MovementSystem`, the refactoring prevents null reference errors:

```dart
@override
bool canProcessEntity(Entity entity) {
  // Only process entities with physics components
  return entity.physics != null;
}

@override
void processEntity(Entity entity, double dt) {
  final PhysicsComponent physics = entity.physics!; 
  // Safe now with canProcessEntity check
  
  // Processing logic...
}
```

### 5. Consistent API

All systems now offer a consistent API for:
- Entity registration/unregistration
- System activation/deactivation
- Component access and validation
- Resource management (initialization/disposal)

## Benefits

1. **Reduced Code Duplication** - Eliminated repeated entity management code
2. **Improved Maintainability** - Systems now follow a consistent pattern
3. **Better Error Handling** - Added proper validation through the inheritance hierarchy
4. **Cleaner Architecture** - Clearer separation of responsibilities
5. **Easier Extension** - New systems can be created by extending the base classes

## Future Improvements

1. **Performance Optimization** - Further optimize entity processing for large numbers of entities
2. **Component Filtering** - Add more sophisticated filtering of entities by component types
3. **Event System Integration** - Better integration with an event system for inter-system communication

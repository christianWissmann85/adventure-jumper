# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Owner
- **Name**: Chris
- **Role**: Lead Developer
- **Preferences**: 
  - Prefers detailed task tracking in markdown files
  - Values clean code architecture and proper separation of concerns
  - Focuses on systematic refactoring with clear documentation

## Project Overview

Adventure Jumper is a 2D platformer game built with Flutter and the Flame game engine. It follows a hybrid Entity-Component-System (ECS) architecture pattern.

## Common Development Commands

### Running the Game
```bash
# Run on Chrome (recommended for development)
flutter run -d chrome

# Run on Windows
flutter run -d windows

# List available devices
flutter devices
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/player_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality
```bash
# Format code
dart format .

# Analyze code (check for errors only, ignore warnings)
flutter analyze | grep -E "error"

# Full analysis including warnings
flutter analyze
```

## Architecture Overview

The codebase follows a hybrid ECS architecture with these key patterns:

1. **Entities** inherit from `Entity` base class and represent game objects
2. **Components** provide reusable behaviors (PhysicsComponent, SpriteComponent, etc.)
3. **Systems** process entities with specific components each frame

### Core Systems Flow
```
AdventureJumperGame (main game class)
  └── GameWorld (manages the game state)
      ├── Entities (Player, Enemy, Platform, etc.)
      │   └── Components (Physics, Sprite, Health, etc.)
      └── Systems (process entities each frame)
          ├── InputSystem (keyboard/touch input)
          ├── PhysicsSystem (gravity, collisions)
          ├── MovementSystem (entity movement)
          └── RenderSystem (drawing sprites)
```

### Key Design Patterns

1. **System Base Classes**:
   - `BaseSystem`: Standard ECS system for processing entities
   - `BaseFlameSystem`: Extends Flame's Component for engine integration

2. **Component Filtering**:
   - Systems use `canProcessEntity()` to filter which entities to process
   - Example: PhysicsSystem only processes entities with PhysicsComponent

3. **Movement Coordination**:
   - MovementSystem uses request/response pattern for coordinated movement
   - Interfaces in `/lib/src/systems/interfaces/` define contracts

### Level System

Levels are JSON files in `assets/levels/` with this structure:
- Metadata (name, version, dimensions)
- Camera bounds
- Player start position
- Layers (background, main, foreground)
- Entity definitions with components

### Important Modules

- `/lib/src/game/`: Core game loop and world management
- `/lib/src/player/`: Player character, controls, stats
- `/lib/src/systems/`: All game systems (physics, movement, combat, etc.)
- `/lib/src/components/`: Reusable component behaviors
- `/lib/src/entities/`: Game objects (enemies, platforms, NPCs)
- `/lib/src/world/`: Level loading and management
- `/lib/src/ui/`: HUD, menus, dialogue system

## Current Development Focus

### Physics-Movement System Refactor (Critical)
**Status**: IN PROGRESS (64% complete as of June 3, 2025)
**Tracker**: `/docs/04_Project_Management/Physics-Movement-Refactor/Physics-movement-refactor-task-tracker.md`

The project is undergoing a critical refactor to fix physics degradation issues:
- **Problem**: Progressive movement slowdown due to physics value accumulation
- **Solution**: Implementing proper system boundaries and coordination interfaces
- **Progress**: Phases 1-2 complete, Phase 3 in progress (Player Character Integration)
  - ✅ Core Component Integration (PHY-3.1.1 through PHY-3.1.5)
  - ✅ Player Controller Refactored (PHY-3.2.1, PHY-3.2.2, PHY-3.2.3)
  - 🚧 Next: PHY-3.2.4 (Player responsiveness validation)

Key refactor elements:
- Request-based movement coordination between systems
- Physics system owns all position updates (no direct position manipulation)
- Enhanced collision detection with proper state management
- Component integration with coordination interfaces
- Accumulation prevention mechanisms

### Important Technical Details

1. **Position Ownership**: 
   - ONLY PhysicsSystem can update entity positions
   - TransformComponent has read-only position access
   - Position updates go through `syncWithPhysics()` with authorization

2. **Movement Flow**:
   - Input → InputComponent.generateMovementRequest()
   - MovementRequest → MovementSystem.processRequest()
   - MovementSystem → PhysicsCoordinator.requestMovement()
   - PhysicsSystem → Updates position and syncs components

3. **Component Interfaces** (in `/lib/src/components/interfaces/`):
   - `IPhysicsIntegration`: Physics component coordination
   - `ITransformIntegration`: Transform synchronization
   - `ICollisionIntegration`: Collision state management
   - `IInputIntegration`: Input validation and request generation

4. **System Priorities** (execution order):
   - InputSystem: 100 (highest)
   - MovementSystem: 90
   - PhysicsSystem: 80
   - CollisionSystem: 70

5. **Player State Management** (PHY-3.2.3 completed):
   - `PlayerMovementRequest`: Enhanced movement requests with retry capability
   - `RespawnState`: Proper physics reset during respawn with accumulation prevention
   - Rapid input detection triggers automatic accumulation prevention
   - Emergency fallback mechanism for persistent movement failures

6. **Known Issues**:
   - One failing movement polish test (jump force calibration)
   - Minor warnings in flutter analyze (can be ignored)
   - Test isolation issues in player_controller_refactor_test.dart (2 tests skipped)

### Development Workflow

1. **Task Tracking**: Always update task tracker when completing tasks
2. **Testing**: Run `flutter test` after major changes
3. **Git**: Do NOT commit unless explicitly asked by Chris
4. **Documentation**: Update TDD files when implementation differs from spec

### Code Style Preferences

- NO unnecessary comments in code
- Use descriptive variable/method names instead of comments
- Keep methods focused and single-purpose
- Prefer composition over inheritance
- Use interfaces for cross-system communication

### Recent Implementation Notes (June 3, 2025)

**PHY-3.2.3 Implementation Details**:
- Added retry mechanism to PlayerControllerRefactored for failed movement requests
- Created RespawnState class in `/lib/src/systems/interfaces/respawn_state.dart`
- Enhanced rapid input detection with automatic accumulation prevention
- Emergency fallback uses 30% speed through direct physics coordinator
- Test coverage: `phy_3_2_3_simple_state_test.dart` (5/5 tests passing)

**Key Files Modified**:
- `/lib/src/player/player_controller_refactored.dart`: Added retry logic, rapid input tracking
- `/lib/src/systems/interfaces/respawn_state.dart`: New file for respawn state management
- `/lib/src/systems/interfaces/player_movement_request.dart`: Already had retry support built-in

**Testing Notes**:
- Simplified tests work better than complex mock setups
- Flame's NotifyingVector2 requires special handling in tests
- Direct property testing often more reliable than behavior testing for data classes

### Debugging Tips

1. **Physics Issues**: Check `_updateEntityPosition` in PhysicsSystem
2. **Movement Issues**: Verify MovementRequest generation and processing
3. **Input Issues**: Check accumulation prevention and frequency limits
4. **Collision Issues**: Verify ground state tracking and event processing

### Session Continuity

When starting a new session, reference:
1. Task tracker for current progress
2. Recent git commits for implementation details
3. This file for project context
4. Test results for any failing tests

**Current State (June 3, 2025)**:
- Physics refactor at 64% (18/28 tasks complete)
- Just completed PHY-3.2.3 (Player state management)
- Two player controllers exist: 
  - `player_controller.dart` (old - to be removed)
  - `player_controller_refactored.dart` (new - uses coordination interfaces)
- Next task: PHY-3.2.4 (Validate player responsiveness)

Example session start:
```
"Continue physics refactor from task tracker. Last completed: PHY-3.2.3 (Player state management). 
Currently at 64% progress. Next task is PHY-3.2.4."
```
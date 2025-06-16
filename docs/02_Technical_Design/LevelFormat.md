# Adventure Jumper - Level Format Specification
*Last Updated: May 23, 2025*

This document describes the structure and format of level files in Adventure Jumper, detailing their JSON schema and how they integrate with the game's systems.

> **Related Documents:**
> - [Architecture](Architecture.md) - System architecture overview
> - [TDD/LevelManagement](TDD/LevelManagement.TDD.md) - Level management implementation
> - [TDD/SystemArchitecture](TDD/SystemArchitecture.TDD.md) - System integration details
> - [Worlds/World-Connections](../01_Game_Design/Worlds/00-World-Connections.md) - World design overview

## File Format

Levels are stored as JSON files in the `assets/levels/` directory with the `.json` extension.

## Basic Structure

```json
{
  "metadata": {
    "version": "1.0",
    "name": "Level 1: Forest Start",
    "author": "Your Name",
    "description": "The first level introducing basic mechanics",
    "nextLevel": "level_2.json",
    "parTime": 60,
    "theme": "forest"
  },
  "camera": {
    "bounds": {"x": 0, "y": 0, "width": 2560, "height": 1440},
    "startPosition": {"x": 100, "y": 800}
  },
  "playerStart": {"x": 100, "y": 800},
  "layers": [
    {
      "name": "background",
      "type": "tilelayer",
      "parallax": 0.5,
      "visible": true,
      "tiles": [
        // Tile data arrays
      ]
    },
    {
      "name": "main",
      "type": "tilelayer",
      "visible": true,
      "tiles": [
        // Tile data arrays
      ]
    },
    {
      "name": "foreground",
      "type": "tilelayer",
      "parallax": 1.2,
      "visible": true,
      "tiles": [
        // Tile data arrays
      ]
    }
  ],
  "entities": [
    {
      "type": "enemy",
      "subtype": "slime",
      "position": {"x": 400, "y": 800},
      "properties": {
        "patrolDistance": 100,
        "speed": 30
      }
    },
    {
      "type": "collectible",
      "subtype": "coin",
      "position": {"x": 300, "y": 750},
      "properties": {
        "value": 5,
        "respawn": false
      }
    }
  ],
  "triggers": [
    {
      "id": "checkpoint_1",
      "type": "checkpoint",
      "position": {"x": 600, "y": 800},
      "size": {"width": 32, "height": 64},
      "properties": {
        "saveGame": true
      }
    },
    {
      "id": "level_end",
      "type": "level_transition",
      "position": {"x": 2500, "y": 800},
      "size": {"width": 32, "height": 96},
      "properties": {
        "targetLevel": "level_2.json",
        "targetSpawn": "start"
      }
    }
  ],
  "hazards": [
    {
      "type": "spike",
      "position": {"x": 700, "y": 832},
      "size": {"width": 32, "height": 16},
      "properties": {
        "damage": 10,
        "respawnPlayer": true
      }
    }
  ],
  "platforms": [
    {
      "type": "moving_platform",
      "position": {"x": 800, "y": 700},
      "size": {"width": 96, "height": 16},
      "properties": {
        "movementType": "linear",
        "path": [
          {"x": 800, "y": 700},
          {"x": 800, "y": 500}
        ],
        "speed": 50,
        "waitTime": 1.0
      }
    }
  ],
  "decorations": [
    {
      "type": "tree",
      "position": {"x": 200, "y": 768},
      "properties": {
        "variant": 2,
        "foreground": false
      }
    }
  ],
  "lighting": {
    "ambientColor": {"r": 200, "g": 220, "b": 255, "a": 255},
    "sources": [
      {
        "type": "point",
        "position": {"x": 500, "y": 700},
        "color": {"r": 255, "g": 200, "b": 100, "a": 255},
        "radius": 200,
        "intensity": 0.8
      }
    ]
  },
  "audio": {
    "music": "forest_theme.mp3",
    "ambientSounds": [
      {
        "sound": "wind.wav",
        "volume": 0.3,
        "position": {"x": -1, "y": -1},
        "radius": -1
      },
      {
        "sound": "waterfall.wav",
        "volume": 0.5,
        "position": {"x": 1500, "y": 700},
        "radius": 300
      }
    ]
  }
}
```

## Section Definitions

### Metadata

Contains high-level information about the level:

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Level format version |
| `name` | string | Display name of the level |
| `author` | string | Level creator's name |
| `description` | string | Brief description of the level |
| `nextLevel` | string | Filename of the next level |
| `parTime` | number | Target completion time in seconds |
| `theme` | string | Visual theme identifier |

### Camera

Defines camera behavior and boundaries:

| Field | Type | Description |
|-------|------|-------------|
| `bounds` | object | Camera movement boundaries |
| `startPosition` | object | Initial camera position |

### Layers

Array of tile layers, ordered from back to front:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Layer identifier |
| `type` | string | `"tilelayer"`, `"objectlayer"`, etc. |
| `parallax` | number | Parallax scrolling factor (optional) |
| `visible` | boolean | Visibility flag |
| `tiles` | array | 2D array of tile indices |

### Entities

Array of game entities (enemies, NPCs, etc.):

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Entity type |
| `subtype` | string | Entity subtype |
| `position` | object | Entity position |
| `properties` | object | Entity-specific properties |

### Triggers

Invisible regions that trigger events:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique trigger identifier |
| `type` | string | Trigger type |
| `position` | object | Trigger position |
| `size` | object | Trigger dimensions |
| `properties` | object | Trigger-specific properties |

## Tile Encoding

Tile data is stored as a 2D array of integers, where each integer represents:

- **0**: Empty tile
- **Positive values**: Tile index in the tileset
- **Negative values**: Special tiles (animations, one-way platforms, etc.)

### Tile Properties

Tiles can have additional properties defined in the tileset:

```json
"tileProperties": {
  "1": { "solid": true },
  "2": { "solid": true, "friction": 0.8 },
  "3": { "solid": false, "hazard": true, "damage": 10 }
}
```

## Level Loading Process

1. Level file is loaded from assets
2. JSON is parsed into LevelData object
3. Tile layers are converted to collision data and visual elements
4. Entities, triggers, and other objects are instantiated
5. Level systems are initialized with loaded data

## Importing from Level Editor

Levels can be imported from the Tiled level editor using the Adventure Jumper Level Converter tool:

```bash
flutter run -t tools/level_converter.dart --input tiled_level.json --output assets/levels/level_1.json
```

The converter handles:
- Converting Tiled layer format to Adventure Jumper format
- Validating entity and object properties
- Optimizing tile data for runtime performance

## Best Practices

### Performance Optimization
- Keep level size reasonable (under 200x100 tiles)
- Use multiple smaller layers instead of few large ones
- Limit the number of dynamic lights and entities
- Use object pooling for frequently spawned entities

### Design Recommendations
- Place checkpoints before difficult sections
- Ensure the player can see hazards before encountering them
- Include both challenge and exploration paths
- Introduce new mechanics gradually

## Validation and Testing

Every level should be validated using the Level Validator tool:

```bash
flutter run -t tools/level_validator.dart --level assets/levels/level_1.json
```

The validator checks:
- JSON schema compliance
- Reference integrity (assets, next level)
- Playability (reachable exit, no impossible jumps)
- Performance metrics (entity count, layer size)

## Technical Implementation

The level loading system uses the following components:

### LevelManager

Main controller for level loading and transitions:

```dart
class LevelManager {
  Future<void> loadLevel(String levelPath) async {
    final levelData = await loadLevelData(levelPath);
    await buildLevel(levelData);
    await spawnEntities(levelData.entities);
    setupCamera(levelData.camera);
    initializePlayer(levelData.playerStart);
    setupAudio(levelData.audio);
  }
  
  // Other implementation details...
}
```

### TileMapRenderer

Handles efficient rendering of tile layers:

```dart
class TileMapRenderer {
  void renderLayer(TileLayer layer, Canvas canvas) {
    // Implementation details for efficient tile rendering...
  }
}
```

## Related Documentation

- [LevelManagement.TDD](TDD/LevelManagement.TDD.md) - Technical implementation details
- [Level Editor Integration](../03_Development_Process/LevelEditorGuide.md) - Guide for level designers
- [World Design Guidelines](../01_Game_Design/Worlds/06-puzzles-mechanics.md) - Level design principles

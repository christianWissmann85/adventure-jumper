# Adventure Jumper - Project Structure

This document provides an overview of the Adventure Jumper project structure, a 2D platformer game built with Flutter and Flame engine. The project follows a modular architecture with clear separation of concerns across different domains.

## File Tree

```
adventure-jumper/
├── lib/
│   ├── main.dart
│   └── src/
│       ├── assets/ (6 files)
│       ├── audio/ (7 files)
│       ├── components/ (16 files)
│       ├── data/ (1 file)
│       ├── debug/ (2 files)
│       ├── entities/ (7 files)
│       ├── events/ (1 file)
│       ├── game/ (4 files)
│       ├── gameplay/ (1 file)
│       ├── player/ (5 files)
│       ├── save/ (4 files)
│       ├── systems/ (14 files)
│       ├── ui/ (8 files)
│       ├── utils/ (18 files)
│       └── world/ (7 files)
├── assets/
│   ├── asset_manifest.json
│   ├── audio/ (42 files)
│   ├── fonts/ (0 files)
│   ├── images/ (91 files)
│   └── levels/ (8 files)
├── test/ (43 files)
├── docs/
│   ├── 01_Game_Design/ (34 files)
│   ├── 02_Technical_Design/ (28 files)
│   ├── 03_Development_Process/ (9 files)
│   ├── 04_Project_Management/ (12 files)
│   ├── 05_Style_Guides/ (8 files)
│   ├── 06_Player_Facing_Documentation/ (3 files)
│   ├── 07_Reports/ (6 files)
│   ├── README.md
│   └── Terminology_Glossary.md
├── scripts/ (11 files)
├── tool/ (1 file)
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── CHANGELOG.md
├── ROADMAP.md
└── [Configuration Files]
```

## Directory Explanations

### `/lib` - Core Application Code

The main source code directory containing all Dart/Flutter code organized in a modular structure.

- **`main.dart`** - Application entry point and initialization
- **`src/`** - Core game source code organized by domain:
  - **`assets/`** - Asset management and loading utilities
  - **`audio/`** - Sound effects and music management
  - **`components/`** - Reusable Flame components (ECS architecture)
  - **`data/`** - Data models and serialization
  - **`debug/`** - Development tools and debugging utilities
  - **`entities/`** - Game entities and entity definitions
  - **`events/`** - Event system and game event handling
  - **`game/`** - Core game loop and engine integration
  - **`gameplay/`** - Game mechanics and rules implementation
  - **`player/`** - Player character logic, animation, and controls
  - **`save/`** - Save system and persistent data management
  - **`systems/`** - ECS systems for game logic (physics, input, etc.)
  - **`ui/`** - User interface components and screens
  - **`utils/`** - Shared utilities and helper functions
  - **`world/`** - Level management and world generation

### `/assets` - Game Assets

Static resources used by the game including graphics, audio, and level data.

- **`audio/`** - Sound effects and background music files
- **`fonts/`** - Custom fonts for UI and in-game text
- **`images/`** - Sprites, textures, and visual assets
- **`levels/`** - Level configuration and map data
- **`asset_manifest.json`** - Asset registry and metadata

### `/test` - Test Suite

Comprehensive testing infrastructure covering unit, integration, and end-to-end tests for all game systems.

### `/docs` - Documentation

Well-organized project documentation covering all aspects of development:

- **`01_Game_Design/`** - Game mechanics, narrative, and design specifications
- **`02_Technical_Design/`** - Architecture, systems design, and technical specifications
- **`03_Development_Process/`** - Development workflows, standards, and procedures
- **`04_Project_Management/`** - Sprint planning, roadmaps, and project tracking
- **`05_Style_Guides/`** - Code style, art style, and consistency guidelines
- **`06_Player_Facing_Documentation/`** - User manuals and help documentation
- **`07_Reports/`** - Progress reports and project analysis

### `/scripts` - Development Automation

Python and shell scripts for asset generation, build automation, and development workflow support.

### `/tool` - Development Tools

Custom development tools and utilities specific to the project build process.

## Architecture Notes

The project follows a **Entity-Component-System (ECS)** architecture pattern using the Flame engine, with clear separation between:

- **Entities** - Game objects (player, enemies, collectibles)
- **Components** - Data containers (position, velocity, health)
- **Systems** - Logic processors (physics, input, rendering)

This modular approach ensures maintainable, testable, and scalable code as the game grows in complexity.

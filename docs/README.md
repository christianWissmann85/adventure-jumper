# Adventure Jumper Documentation

Welcome to the Adventure Jumper documentation suite. This repository contains all the design, development, and project management documents for the Adventure Jumper game.

## Documentation Categories

1. [Game Design](01_Game_Design/README.md) - Game mechanics, narrative, worlds, characters, and UI/UX design

   - [Game Design Document (GDD)](01_Game_Design/GDD.md) - Master design document
   - [Characters](01_Game_Design/Characters/README.md) - Character designs and specifications
   - [Worlds](01_Game_Design/Worlds/README.md) - World designs and environments
   - [Narrative](01_Game_Design/Narrative/README.md) - Story, dialog, and narrative elements
   - [Mechanics](01_Game_Design/Mechanics/README.md) - Gameplay systems and mechanics
   - [UI/UX Design](01_Game_Design/UI_UX_Design/README.md) - Interface and user experience
     - [Design Philosophy](01_Game_Design/UI_UX_Design/DesignPhilosophy.md) - Core UI/UX principles
     - [Menus and Layouts](01_Game_Design/UI_UX_Design/Menus_Layouts.md) - Menu screen organization
     - [HUD Layouts](01_Game_Design/UI_UX_Design/HUD_Layouts.md) - In-game interface elements
   - [Lore](01_Game_Design/Lore/README.md) - World history and background

2. [Technical Design](02_Technical_Design/README.md) - Architecture, technical specifications, and technical design documents

   - [Architecture](02_Technical_Design/Architecture.md) - System architecture overview
   - [Asset Pipeline](02_Technical_Design/AssetPipeline.md) - Asset workflow
   - [Technical Design Documents](02_Technical_Design/TDD/README.md) - System specifications

3. [Development Process](03_Development_Process/README.md) - Implementation guides and development workflows

   - [Implementation Guide](03_Development_Process/ImplementationGuide.md) - Code standards
   - [Testing Strategy](03_Development_Process/TestingStrategy.md) - QA approach
   - [Version Control](03_Development_Process/VersionControl.md) - Git workflow
   - [Action Plan: Logging Migration](ActionPlan_LoggingMigration.md) - Guide for refactoring `print()` calls to a structured logging system.

4. [Project Management](04_Project_Management/README.md) - Roadmaps, sprint plans, and task tracking

   - [Roadmap](04_Project_Management/Roadmap.md) - Development timeline
   - [Sprint Plan](04_Project_Management/AgileSprintPlan.md) - Current sprint
   - [Task Tracking](04_Project_Management/TaskTracking.md) - Work management

5. [Style Guides](05_Style_Guides/README.md) - Code, art, audio, UI/UX, and documentation style guides

   - [Code Style](05_Style_Guides/CodeStyle.md) - Programming standards
   - [Art Style](05_Style_Guides/ArtStyle.md) - Visual guidelines
   - [Audio Style](05_Style_Guides/AudioStyle.md) - Sound design standards
   - [UI/UX Style](05_Style_Guides/UI_UX_Style.md) - Interface design guidelines
   - [Documentation Style](05_Style_Guides/DocumentationStyle.md) - Documentation standards

6. [Player Facing Documentation](06_Player_Facing_Documentation/README.md) - User manual and FAQ
   - [User Manual](06_Player_Facing_Documentation/User-Manual.md) - Game instructions
   - [FAQ](06_Player_Facing_Documentation/FAQ.md) - Common questions

## Key Documents by Role

### For Designers

- [Game Design Document (GDD)](01_Game_Design/GDD.md) - Complete game design overview
- [Core Gameplay Loop](01_Game_Design/Mechanics/CoreGameplayLoop.md) - Fundamental gameplay
- [World Connections](01_Game_Design/Worlds/00-World-Connections.md) - World structure
- [Story Outline](01_Game_Design/Narrative/00-story-outline.md) - Narrative flow

### For Developers

- [Architecture](02_Technical_Design/Architecture.md) - System architecture
- [TDD Directory](02_Technical_Design/TDD/README.md) - Technical specifications
- [Implementation Guide](03_Development_Process/ImplementationGuide.md) - Development standards
- [Asset Pipeline](02_Technical_Design/AssetPipeline.md) - Asset workflow

### For Artists

- [Art Style Guide](05_Style_Guides/ArtStyle.md) - Visual standards
- [World Design Documents](01_Game_Design/Worlds/) - Environment specifications
- [Character Design Documents](01_Game_Design/Characters/) - Character specifications
- [UI/UX Style Guide](05_Style_Guides/UI_UX_Style.md) - Interface guidelines

### For Project Managers

- [Development Roadmap](04_Project_Management/Roadmap.md) - Project timeline
- [Agile Sprint Plan](04_Project_Management/AgileSprintPlan.md) - Current sprint
- [Task Tracking](04_Project_Management/TaskTracking.md) - Work management
- [Design Cohesion Guide](04_Project_Management/DesignCohesionGuide.md) - Maintaining consistency

## About This Documentation Structure

This documentation is organized to provide a clear separation of concerns while maintaining cross-references between related documents. The structure is designed to:

- Make it easy to find related information
- Reduce redundancy by establishing a single source of truth for each topic
- Enable cross-linking between design documents and their technical implementations
- Support both high-level overviews and detailed specifications

## Getting Started

New team members should start by reading:

1. The Game Design Document (GDD) in [01_Game_Design/GDD.md](01_Game_Design/GDD.md)
2. The Technical Architecture overview in [02_Technical_Design/Architecture.md](02_Technical_Design/Architecture.md)
3. The Implementation Guide in [03_Development_Process/ImplementationGuide.md](03_Development_Process/ImplementationGuide.md)
4. The Style Guides applicable to your work area in [05_Style_Guides/](05_Style_Guides/)

## Document Relationships

- Game design documents in [01_Game_Design/](01_Game_Design/) define the player experience
- Technical design documents in [02_Technical_Design/](02_Technical_Design/) specify how to implement that experience
- Development process documents in [03_Development_Process/](03_Development_Process/) establish workflows
- Project management documents in [04_Project_Management/](04_Project_Management/) track progress
- Style guides in [05_Style_Guides/](05_Style_Guides/) ensure consistency

## Documentation Maintenance

This documentation is maintained according to the standards in [05_Style_Guides/DocumentationStyle.md](05_Style_Guides/DocumentationStyle.md).

For questions about the documentation structure, contact the Documentation Lead.

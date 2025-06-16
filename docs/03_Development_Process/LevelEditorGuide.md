# Level Editor Guide
*Last Updated: May 23, 2025*

This document provides a comprehensive guide to using the level editor for Adventure Jumper, covering installation, interface, workflows, and best practices for level designers.

> **Related Documents:**
> - [Level Format](../02_Technical_Design/LevelFormat.md) - Technical details of level files
> - [World Design](../01_Game_Design/Worlds/00-World-Connections.md) - World design principles
> - [Art Style Guide](../05_Style_Guides/ArtStyle.md) - Visual styling guidelines
> - [Implementation Guide](ImplementationGuide.md) - Custom script implementation

## 1. Level Editor Overview

### 1.1 Editor Selection
Adventure Jumper uses a customized version of Tiled Map Editor for level design. This provides:
- Familiar interface for designers with tilemap experience
- Custom properties and behaviors for game-specific features
- Integration with our asset pipeline
- Support for collaborative level design

### 1.2 Editor Requirements
- **Tiled Map Editor**: Version 1.8.5 or higher
- **Adventure Jumper Extension**: Version 2.3.0 or higher
- **Graphics Hardware**: OpenGL 3.0 compatible
- **RAM**: 8GB minimum, 16GB recommended

### 1.3 Installation Process
1. Install standard Tiled Map Editor from [mapeditor.org](https://www.mapeditor.org/)
2. Clone the Adventure Jumper extension repository
3. Run the extension installer script
4. Configure project paths in the extension settings
5. Verify installation with the test project

## 2. Editor Interface

### 2.1 Interface Overview
The level editor interface consists of:
- **Project Panel**: Shows available assets and level files
- **Canvas**: Main editing area displaying the current level
- **Tile Palette**: Available tiles organized by category
- **Properties Panel**: Edit properties of selected objects
- **Layers Panel**: Manage level layers
- **Custom Tools Panel**: Game-specific tools and functions

### 2.2 Custom Adventure Jumper Extensions
Our customizations include:
- **Entity Browser**: Pre-configured game entities
- **Mechanic Builder**: Visual scripting for level mechanics
- **Test Runner**: Play and test levels directly in editor
- **Physics Visualizer**: Preview collision and physics behaviors
- **Path Editor**: Create movement paths for platforms and enemies
- **Connectivity Checker**: Validate level traversability

### 2.3 Editor Configuration
Configure these settings for optimal workflow:
- Enable auto-save (every 5 minutes recommended)
- Set up grid snapping (16x16 pixels default)
- Configure keyboard shortcuts for common operations
- Set up the workspace layout based on your monitor setup

## 3. Level Creation Workflow

### 3.1 Creating a New Level
1. Select File → New → Adventure Jumper Level
2. Choose a level template (Basic, Cave, Forest, etc.)
3. Set level dimensions and properties
4. Define the base layer structure
5. Save the level with appropriate naming (zone_levelname.json)

### 3.2 Basic Level Structure
All levels should include these layers:
- **Background**: Decorative background elements (parallax)
- **Terrain**: Primary collision layers
- **Foreground**: Decorative elements in front of player
- **Entities**: Interactive game objects
- **Triggers**: Invisible interaction zones
- **Routes**: Paths for moving objects
- **Lighting**: Light sources and effects (optional)

### 3.3 Level Development Process
Follow this process for efficient level creation:
1. **Block Out**: Create basic terrain and critical paths
2. **Playtest**: Test basic traversal and flow
3. **Detail Pass**: Add visual elements and details
4. **Entity Placement**: Add enemies, collectibles, and mechanics
5. **Polish Pass**: Add decorative elements and effects
6. **Optimization**: Check performance and make adjustments
7. **Final Test**: Complete verification of all paths and features

## 4. Terrain and Environment

### 4.1 Terrain Types
Adventure Jumper supports these terrain types:
- **Solid**: Standard collision blocks
- **One-Way**: Platforms player can jump through from below
- **Slippery**: Reduces player friction/control
- **Bouncy**: Provides jump boost
- **Damaging**: Causes player damage on contact
- **Crumbling**: Breaks after player stands on it
- **Moving**: Platforms that follow defined paths

### 4.2 Terrain Rules
When creating terrain:
- Always connect solid terrain pieces properly
- Avoid "impossible jumps" beyond player's abilities
- Use terrain rule tiles for automatic connections
- Consider how terrain affects enemy movement
- Test all platforms with all player abilities

### 4.3 Environmental Elements
Enhance your level with:
- **Background paralax layers**: Create depth
- **Animated elements**: Waterfalls, flowing lava, etc.
- **Particle effects**: Dust, mist, falling leaves
- **Ambient animations**: Swaying trees, flickering lights
- **Weather effects**: Rain, snow, fog

## 5. Entity Placement

### 5.1 Entity Types
The editor provides these entity categories:
- **Enemies**: Hostile NPCs with behaviors
- **Collectibles**: Items for player to gather
- **Hazards**: Environmental dangers
- **NPCs**: Non-hostile characters
- **Interactables**: Objects player can interact with
- **Mechanics**: Special gameplay elements

### 5.2 Enemy Placement Guidelines
When placing enemies:
- Consider player approach direction
- Create fair placement with appropriate warning
- Test with different player skill levels
- Balance enemy density for difficulty progression
- Create interesting combinations of enemy types
- Define patrol paths where appropriate

### 5.3 Collectible Placement
For collectible items:
- Use collectibles to guide players to critical paths
- Create optional challenging paths for bonus collectibles
- Consider collectible density and pacing
- Use special collectibles to reward exploration
- Ensure collectibles are visibly distinguishable

## 6. Triggers and Scripting

### 6.1 Trigger Types
Available trigger zones include:
- **Checkpoint**: Save player progress
- **Camera Control**: Modify camera behavior
- **Event Trigger**: Activate cutscene or event
- **Level Transition**: Move to another level
- **Enemy Spawn**: Dynamically spawn enemies
- **Environment Change**: Modify environment (e.g., raise water level)

### 6.2 Scripting System
The visual scripting system allows:
- **Event Sequences**: Chain of actions triggered by events
- **Conditional Logic**: Different outcomes based on conditions
- **Timer Events**: Actions triggered after time delays
- **State Management**: Track and modify level state
- **Player Interaction**: Respond to player actions

### 6.3 Advanced Scripting
For complex behaviors:
- Use variables to track level state
- Create reusable script components
- Build multi-stage puzzles with script connections
- Test script timing with different player approaches
- Document script behavior for other team members

## 7. Testing and Validation

### 7.1 In-Editor Testing
Test your level using:
- **Play Mode**: Test gameplay directly in editor
- **Entity Simulation**: Test entity behavior without full playtest
- **Path Verification**: Validate all intended paths
- **Collectible Checker**: Ensure all collectibles are reachable
- **Performance Monitor**: Check level performance metrics

### 7.2 Test Checklist
Before submission, verify:
- All paths are completable
- No unintended shortcuts exist
- Difficulty progression is appropriate
- Level performs well (no lag)
- All collectibles are reachable
- Visual elements display correctly
- No z-order issues with sprites
- Lighting and effects work as intended

### 7.3 Common Issues
Watch for these frequent problems:
- Unreachable areas or items
- Player stuck scenarios
- Inconsistent difficulty spikes
- Visual layering issues
- Unclear player guidance
- Performance issues with too many entities
- Unintended physics interactions

## 8. Optimization

### 8.1 Performance Considerations
Keep levels performant by:
- Limiting active entities in view
- Using texture atlases for tiles
- Limiting lighting and particle effects
- Breaking large levels into connected sections
- Using LOD (Level of Detail) for complex elements

### 8.2 Memory Management
Manage memory efficiently:
- Reuse common elements
- Limit unique assets per level
- Use procedural generation for repetitive details
- Consider texture memory limitations
- Test on minimum specification devices

### 8.3 Load Time Optimization
Reduce loading times by:
- Breaking very large levels into zones
- Optimizing asset sizes
- Using streaming techniques for large areas
- Limiting unique assets per level section

## 9. Collaboration and Version Control

### 9.1 Level Files in Version Control
When working with version control:
- Commit level files with descriptive messages
- Break large changes into multiple commits
- Coordinate with other designers on shared areas
- Use feature branches for experimental designs

### 9.2 Collaborative Editing
For team-based level design:
- Divide levels into ownership zones
- Use pull requests for level reviews
- Document design intentions in level metadata
- Create level design documents for complex levels

### 9.3 Asset Management
When using game assets:
- Only use approved assets from the asset library
- Request new assets through the asset request system
- Document custom asset usage in level metadata
- Test with placeholder assets before final art is ready

## 10. Best Practices

### 10.1 Level Design Principles
Follow these core principles:
- **Introduce, Develop, Challenge**: Structure mechanics progression
- **Signpost**: Clearly indicate critical paths
- **Reward Exploration**: Hide bonuses off the main path
- **Provide Breathing Room**: Balance intense sections with quieter areas
- **Visual Storytelling**: Use environment to tell stories

### 10.2 Accessibility Considerations
Make levels accessible by:
- Providing multiple difficulty options where possible
- Using clear visual language for important elements
- Avoiding color-only indicators
- Ensuring text is readable at various distances
- Testing with accessibility features enabled

### 10.3 Performance Testing
Regularly test levels for:
- Frame rate on target platforms
- Memory usage
- Loading time
- Entity count
- Physics stability

## 11. Publishing and Sharing Levels

### 11.1 Level Submission Process
When your level is complete:
1. Run the validation tool
2. Fix any reported issues
3. Submit for peer review
4. Address feedback
5. Submit final version for integration
6. Update level documentation

### 11.2 Level Documentation
Document your level with:
- **Level Brief**: Design intention and player experience
- **Completion Requirements**: What player needs to accomplish
- **Special Features**: Unique mechanics or features
- **Testing Notes**: Areas that need special attention
- **Performance Considerations**: Any optimization notes

### 11.3 Custom Level Distribution
For sharing custom levels:
- Export using the Level Package tool
- Include all custom assets in the package
- Test package on a clean installation
- Provide installation instructions
- Consider compatibility with different game versions

## 12. Troubleshooting

### 12.1 Common Editor Issues
Solutions for frequent problems:
- **Editor crashes on large levels**: Split into multiple connected levels
- **Missing textures**: Reimport texture assets or verify paths
- **Script errors**: Check script editor for syntax issues
- **Entity behavior issues**: Verify entity properties and constraints
- **Collision problems**: Rebuild collision data or check terrain type

### 12.2 Level Debugging
Debug techniques include:
- Enable debug visualization mode
- Use the entity inspector for runtime values
- Check the editor console for warnings
- Use the physics visualizer to check collisions
- Record test sessions for review

### 12.3 Support Resources
Get help with editor issues:
- Editor documentation in the Wiki
- #level-design channel in Slack
- Weekly level design office hours
- Bug reporting system for editor issues
- Level design community forum

---

*For additional support with the level editor, contact the Tools Team or Lead Level Designer.*

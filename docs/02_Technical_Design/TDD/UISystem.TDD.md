# UI System - Technical Design Document

## 1. Overview

Defines the implementation of the UI system for Adventure Jumper, focusing on clear, non-intrusive interfaces that support **Fluid & Expressive Movement**, provide clear feedback for **Engaging & Dynamic Combat**, and visualize progression in **Progressive Mastery**. The UI system prioritizes player immersion through minimal, context-aware interfaces that communicate essential information without interrupting gameplay flow.

*For UI/UX design specifications, see:*
- *[UI/UX Design Philosophy](../../01_Game_Design/UI_UX_Design/DesignPhilosophy.md)*
- *[HUD Layouts](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md)*
- *[Menus and Layouts](../../01_Game_Design/UI_UX_Design/Menus_Layouts.md)*
- *[UI/UX Style Guide](../../05_Style_Guides/UI_UX_Style.md)*

*For design cohesion principles, see [Design Cohesion Guide](../../04_Project_Management/DesignCohesionGuide.md)*
*For implementation timeline, see [Agile Sprint Plan](../../04_Project_Management/AgileSprintPlan.md)*

### Purpose
- **Primary**: Provide clear, minimal interfaces that enhance rather than interrupt gameplay
- Support fluid gameplay through non-intrusive, context-aware HUD elements
- Communicate combat state and options clearly without disrupting flow
- Visualize player progression to reinforce sense of mastery
- Implement world-themed UI elements that strengthen environmental identity
- Handle menu navigation, dialogue presentation with seamless transitions
- Support accessibility features for diverse player needs

### Scope
- Minimalist HUD elements (health, energy, abilities) with context-aware visibility
- Menu system with smooth transitions maintaining world immersion
- Dialogue system supporting narrative depth while maintaining pacing
- Non-intrusive notifications and player feedback
- UI theming based on world location enhancing world identity
- Fluid UI animation and transitions maintaining gameplay focus
- Input handling optimized for responsive gameplay

### Design Cohesion Focus Areas
This UI system specifically supports all three Design Pillars:

**Fluid & Expressive Movement:**
- Minimal HUD elements that don't obstruct movement visualization
- Context-sensitive UI that appears only when needed
- Motion-responsive feedback that enhances movement feel

**Engaging & Dynamic Combat:**
- Clear combat state visualization (health, energy, cooldowns)
- Non-intrusive enemy indicators maintaining spatial awareness
- Visual feedback reinforcing combat impact and success

**Progressive Mastery:**
- Visual progression indicators showing skill development
- Ability upgrade visualization supporting player growth
- Achievement and mastery milestone celebrations

## 2. Class Design

### Core UI Classes

```dart
// Main UI management system
class UISystem extends BaseFlameSystem {
  // UI state management
  // Layer coordination
  // Theme handling
  // UI transitions
  
  @override
  bool canProcessEntity(Entity entity) {
    // Check if entity has UI components
    return entity.children.whereType<UIComponent>().isNotEmpty ||
           entity.hasTags(['ui', 'interface', 'menu']);
  }
  
  @override
  void processEntity(Entity entity, double dt) {
    // Update UI components on entities
    // Handle entity-specific UI elements (health bars, indicators)
    // Process UI interactions and state changes
  }
  
  @override
  void processSystem(double dt) {
    // Update global UI state
    // Handle screen transitions
    // Process theme changes and animations
  }
}

// UI screen controller
class UIScreen {
  // Screen layout and components
  // Input handling
  // Animation states
  // Navigation logic
}

// World-specific theming
class UITheme {
  // Color palettes
  // Asset references
  // Animation properties
  // Sound effects
}
```

### UI Component Classes

```dart
// Base UI component class
class UIComponent extends GameComponent {
  // Layout properties
  // Input handling
  // Animation state
  // Theme application
}

// Player HUD (see: ../../01_Game_Design/UI_UX_Design/HUD_Layouts.md for design details)
class PlayerHUD extends UIComponent {
  // Health visualization
  // Aether energy display
  // Ability cooldowns
  // Context-sensitive prompts
}

// Dialogue system
class DialogueSystem extends UIComponent {
  // Text presentation
  // Character portraits
  // Choice handling
  // Timing and flow
}
```

## 3. Data Structures

### UI Configuration
```dart
class UIConfig {
  double uiScale;           // Overall UI scaling
  bool showFrameRate;       // Performance metrics toggle
  bool reduceAnimations;    // Accessibility option
  bool highContrastMode;    // Accessibility option
  Map<String, bool> hudElementVisibility; // HUD element toggles
  String fontFamily;       // UI font selection
  double textSize;         // Base text size
  Map<String, Color> customColors; // User color overrides
}
```

### UI Theme Data
```dart
class UIThemeData {
  String themeId;               // Unique theme identifier 
  Color primaryColor;           // Main UI color
  Color secondaryColor;         // Accent UI color
  Color backgroundColor;        // Background UI color
  Color textColor;             // Primary text color
  Color highlightColor;        // Selection highlight color
  String backgroundTexturePath; // Background texture asset
  String borderStylePath;       // Border style asset
  String iconSetPath;          // Icon set for this theme
  String fontOverride;         // Optional theme-specific font
  Map<String, AnimationData> animations; // Theme-specific animations
}
```

### UI Element Data
```dart
class UIElementData {
  String elementId;          // Unique element identifier
  Vector2 position;          // Element position (relative or absolute)
  Vector2 size;              // Element dimensions
  Alignment alignment;       // Positioning alignment
  bool isVisible;            // Current visibility state
  double opacity;            // Transparency level
  List<String> tags;         // Classification tags
  Map<String, dynamic> properties; // Element-specific properties
}
```

### Dialogue Entry
```dart
class DialogueEntry {
  String dialogueId;         // Unique dialogue identifier
  String speakerName;        // Character name
  String portraitPath;       // Character portrait asset
  String text;               // Dialogue text content
  double displayDuration;    // Auto-advance timer (0 for manual)
  List<DialogueChoice> choices; // Player response options
  Map<String, String> localizations; // Translated text
  List<DialogueEffect> effects; // Special effects during dialogue
}
```

## 4. Algorithms

### UI Scaling and Positioning
```
function calculateUIElementPosition(elementData, screenSize, uiScale):
  // Apply UI scale
  scaledSize = elementData.size * uiScale
  
  // Calculate position based on alignment and screen size
  switch elementData.alignment:
    case TOP_LEFT:
      finalPosition = elementData.position * uiScale
    case TOP_RIGHT:
      finalPosition = Vector2(
        screenSize.width - (elementData.position.x * uiScale) - scaledSize.width,
        elementData.position.y * uiScale
      )
    case BOTTOM_LEFT:
      finalPosition = Vector2(
        elementData.position.x * uiScale,
        screenSize.height - (elementData.position.y * uiScale) - scaledSize.height
      )
    // Handle other alignments...
  
  return finalPosition
```

### Theme Transition
```
function transitionToTheme(currentTheme, targetTheme, duration):
  transitionTimer = 0
  
  while transitionTimer < duration:
    progress = easeInOutCubic(transitionTimer / duration)
    
    // Interpolate colors
    blendedTheme = new UIThemeData()
    blendedTheme.primaryColor = lerpColor(currentTheme.primaryColor, targetTheme.primaryColor, progress)
    blendedTheme.secondaryColor = lerpColor(currentTheme.secondaryColor, targetTheme.secondaryColor, progress)
    blendedTheme.backgroundColor = lerpColor(currentTheme.backgroundColor, targetTheme.backgroundColor, progress)
    blendedTheme.textColor = lerpColor(currentTheme.textColor, targetTheme.textColor, progress)
    blendedTheme.highlightColor = lerpColor(currentTheme.highlightColor, targetTheme.highlightColor, progress)
    
    // Apply current blended theme
    applyTheme(blendedTheme)
    
    transitionTimer += deltaTime
  
  // Finalize theme change
  applyTheme(targetTheme)
```

### Dialogue Presentation
```
function displayDialogue(dialogue):
  // Prepare dialogue box
  showDialogueBox()
  setDialogueSpeaker(dialogue.speakerName)
  setDialoguePortrait(dialogue.portraitPath)
  
  // Animate text display
  if dialogue.useTypewriter:
    currentCharIndex = 0
    targetText = dialogue.text
    
    while currentCharIndex < targetText.length:
      displayText = targetText.substring(0, currentCharIndex)
      setDialogueText(displayText)
      
      if isCharacterPunctuation(targetText[currentCharIndex]):
        wait(PUNCTUATION_PAUSE_TIME)
      else:
        wait(CHARACTER_DISPLAY_TIME)
      
      currentCharIndex++
  else:
    setDialogueText(dialogue.text)
  
  // Setup choices if available
  if dialogue.choices.length > 0:
    displayDialogueChoices(dialogue.choices)
  else if dialogue.displayDuration > 0:
    wait(dialogue.displayDuration)
    hideDialogueBox()
  else:
    waitForInput()
    hideDialogueBox()
```

## 5. API/Interfaces

### UI System Interface
```dart
interface IUISystem {
  void showScreen(String screenId);
  void hideScreen(String screenId);
  void setTheme(String themeId);
  void transitionToTheme(String themeId, double duration);
  void showNotification(String message, NotificationType type);
  void updateHUDElement(String elementId, dynamic value);
  bool isScreenVisible(String screenId);
}

interface IUIInput {
  void handlePointerDown(PointerDownEvent event);
  void handlePointerUp(PointerUpEvent event);
  void handlePointerMove(PointerMoveEvent event);
  bool onKeyEvent(KeyEvent event);
}
```

### Dialogue System Interface
```dart
interface IDialogueSystem {
  void showDialogue(String dialogueId);
  void showDialogueSequence(List<String> dialogueIds);
  void selectDialogueChoice(int choiceIndex);
  void skipCurrentDialogue();
  bool isDialogueActive();
}

interface IUIAnimation {
  void playAnimation(String animationId);
  void stopAnimation(String animationId);
  bool isAnimationPlaying(String animationId);
  void setAnimationSpeed(double speedMultiplier);
}
```

## 6. Dependencies

### System Dependencies
- **Input System**: For UI navigation and interaction
- **Aether System**: For energy display and ability cooldowns
- **Level Management**: For world detection and theme switching
- **Save System**: For settings persistence
- **Audio System**: For UI sound effects and feedback

### Asset Dependencies
- UI texture atlases and spritesheets
- Font files and text rendering
- UI sound effects
- Animation data
- Localization data

## 7. File Structure

```
lib/
  game/
    ui/
      ui_system.dart              # Main UI management system
      ui_screen.dart             # Screen controller
      ui_theme.dart              # Theming system
      ui_config.dart             # Configuration data
      components/
        ui_component.dart        # Base UI component
        player_hud.dart         # Player HUD implementation
        menu_screen.dart        # Menu implementation
        dialogue_system.dart    # Dialogue implementation
        notification.dart       # Notification system
      screens/
        main_menu_screen.dart    # Main menu implementation
        pause_screen.dart       # Pause screen implementation
        inventory_screen.dart   # Inventory implementation
        ability_screen.dart     # Ability upgrade screen
      themes/
        theme_luminara.dart      # Luminara world theme
        theme_verdant.dart      # Verdant world theme
        theme_forge.dart        # Forge world theme
        theme_archive.dart      # Archive world theme
        theme_void.dart         # Edge world theme
      dialogue/
        dialogue_controller.dart  # Dialogue presentation
        dialogue_parser.dart     # Dialogue data loading
        dialogue_choices.dart    # Choice implementation
    data/
      ui/
        ui_layouts.dart          # UI element positioning data
        ui_themes.dart          # Theme definitions
        dialogue_data.dart      # Dialogue content
```

## 8. Performance Considerations

### Optimization Strategies
- Texture atlasing for UI elements
- Efficient UI batching and rendering
- Dynamically loaded theme assets
- Canvas-based rendering for simple UI
- Widget caching for complex layouts

### Memory Management
- Efficient texture memory usage
- Unloading unused theme assets
- Text rendering optimization
- Minimal UI state storage

## 9. Testing Strategy

### Unit Tests
- UI layout and scaling across different screen sizes
- Theme application and blending without performance impact
- Dialogue parsing and presentation maintaining game flow
- Input handling with responsive navigation

### Integration Tests
- UI system integration with game systems without disrupting gameplay
- Theme transitions between worlds maintaining immersion
- Performance testing ensuring UI never causes frame drops
- Platform-specific rendering tests for consistency

### Design Cohesion Testing
- **Movement Support Tests**: Verify UI never obstructs movement visibility
- **Combat Clarity Tests**: Confirm combat state clearly communicated without distraction
- **Progression Visualization Tests**: Check UI effectively communicates player growth
- **Contextual Adaptation Tests**: Validate UI shows appropriate information for player context

## 10. Implementation Notes

### Sprint-Aligned Development Phases

**Sprint 1-2: Minimal Core UI Framework**
- Basic UI framework with non-intrusive design
- Essential HUD elements (health, energy) with context-sensitive visibility
- Simple menu structure with smooth transitions
- Initial player feedback system (damage, pickups)
- *Validation*: UI never obstructs critical gameplay visibility

**Sprint 3-4: Game System Integration**
- Menu system with full navigation and game state management
- Ability UI showing cooldowns and availability
- Combat feedback enhancing gameplay clarity
- Settings and accessibility options
- *Validation*: UI provides clear feedback without disrupting flow

**Sprint 5-6: Narrative and World Integration**
- Dialogue system supporting narrative depth
- Initial world-specific UI theming
- Progress visualization and mastery feedback
- Context-sensitive tutorial elements
- *Validation*: UI strengthens world identity and progression feel

**Sprint 7+: Polish and Advanced Experience**
- Complete world-specific UI themes with transitions
- Advanced accessibility features implementation
- Performance optimization for all platforms
- Final UI polish and animation refinement
- *Validation*: UI feels like natural extension of each world

### Design Cohesion Validation Metrics

**UI Experience Metrics:**
- **Non-intrusion**: <10% screen space for essential HUD elements
- **Responsiveness**: UI navigation response <50ms
- **Context Awareness**: No unnecessary UI elements during active gameplay
- **Information Clarity**: Critical information visible in 2 seconds or less

**Player Experience Validation:**
- UI enhances rather than impedes gameplay flow
- Information hierarchy prioritizes current player needs
- Visual style strengthens world identity and immersion
- Interface adapts to different player skill levels

### UI Design Principles Supporting Cohesion
- **Gameplay First**: UI never obstructs or slows down core gameplay
- **Clarity Through Minimalism**: Only showing what's necessary when necessary
- **Context Integration**: UI feels like part of the world, not overlaid
- **Progressive Disclosure**: Information complexity matches player progression
- **Accessibility By Design**: Inclusive design from the foundation

## 11. Future Considerations

### Expandability
- Custom UI modding support
- Advanced accessibility features
- Dynamic UI layout system
- Real-time UI editing tools

### Advanced Features
- 3D UI elements for certain worlds
- Spatial UI elements in game world
- Controller-specific UI enhancements
- VR/AR adaptation potential

## Related Design Documents

- See [UI/UX Design Philosophy](../../01_Game_Design/UI_UX_Design/DesignPhilosophy.md) for core design principles
- See [HUD Layouts](../../01_Game_Design/UI_UX_Design/HUD_Layouts.md) for in-game interface specifications
- See [Menus and Layouts](../../01_Game_Design/UI_UX_Design/Menus_Layouts.md) for menu structure and design
- See [UI/UX Style Guide](../../05_Style_Guides/UI_UX_Style.md) for visual standards

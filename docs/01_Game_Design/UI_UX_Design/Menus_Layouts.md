# Menus and Layouts

*This document details the menu structures and screen layouts for Adventure Jumper. For technical implementation details, see [UI System TDD](../../02_Technical_Design/TDD/UISystem.TDD.md). For visual style guidelines, see [UI/UX Style Guide](../../05_Style_Guides/UI_UX_Style.md).*

## Menu Structure Overview

Adventure Jumper features a hierarchical menu system with consistent navigation patterns across all screens. The diagram below shows the relationship between different menu screens:

```
Main Menu
├── New Game
├── Continue
├── Options
│   ├── Graphics
│   ├── Audio
│   ├── Controls
│   └── Accessibility
├── Extras
│   ├── Gallery
│   ├── Achievements
│   └── Credits
└── Quit Game

In-Game Menu (Pause)
├── Resume
├── Inventory
│   ├── Equipment
│   ├── Consumables
│   └── Key Items
├── Abilities
│   ├── Active Abilities
│   ├── Passive Abilities
│   └── Upgrades
├── Codex
│   ├── Characters
│   ├── Worlds
│   └── Lore
├── Map
├── Options
└── Quit to Main Menu
```

## Main Menu

### Layout
- **Background**: Animated scene of Luminara's floating islands
- **Title**: Adventure Jumper logo (top center)
- **Menu Options**: Vertical list (center-right)
- **Character**: Animated Kael figure (left side)
- **Visual Effects**: Subtle Aether particles flowing through scene

### Navigation
- **Selection**: Highlights current option with glow effect and slight size increase
- **Confirmation**: Button press triggers smooth transition to selected screen
- **Back**: Returns to previous menu with slide-out animation

### Special Elements
- **Version Number**: Bottom right corner
- **Developer Logo**: Bottom left corner
- **Animated Elements**: Floating islands shift slowly, clouds pass by

## Pause Menu

### Layout
- **Overlay**: Semi-transparent dark background (70% opacity)
- **Menu Panel**: Central floating panel with Aether-infused borders
- **Game World**: Visible but darkened in background
- **Menu Options**: Vertical list with icons (center)
- **Title**: "Paused" text (top center)

### Navigation
- **Quick Resume**: Dedicated button for instant return to game
- **Tab Navigation**: Shoulder buttons switch between main categories
- **Visual Cues**: Small previews of submenu content on hover

### Special Elements
- **Location Info**: Current world and area displayed
- **Play Time**: Total time played shown
- **Quick Stats**: Brief display of player level and resources

## Inventory System

### Layout
- **Grid View**: Items displayed in scrollable grid
- **Categories**: Tab-based filtering system (top)
- **Item Details**: Right panel shows selected item information
- **Character Preview**: Left panel shows Kael with equipment

### Navigation
- **Item Selection**: D-pad/thumbstick navigation through grid
- **Category Switching**: Shoulder buttons or tabs
- **Item Actions**: Context menu for use/equip/drop options
- **Sorting**: Options to sort by type, rarity, or recent acquisition

### Special Elements
- **Comparison Tooltips**: When hovering over equipment
- **Rarity Indicators**: Color-coded borders on items
- **New Item Indicators**: Glowing effect on unexamined items
- **Stack Counters**: Numerical indicators for stackable items

## Abilities Screen

### Layout
- **Constellation View**: Abilities arranged in themed constellations
- **Ability Details**: Panel showing selected ability information
- **Current Loadout**: Quick-access bar showing equipped abilities
- **Upgrade Path**: Visual connections showing progression paths

### Navigation
- **Constellation Navigation**: Free-form movement between ability nodes
- **Ability Selection**: Highlight and confirm to view details
- **Upgrade Navigation**: Visual paths show possible progression
- **Loadout Management**: Drag-and-drop interface for equipped abilities

### Special Elements
- **Locked Abilities**: Grayed out with unlock requirements shown
- **Upgrade Indicators**: Glowing nodes for available upgrades
- **Resource Counter**: Shows available upgrade resources
- **Ability Preview**: Animated demonstration of selected ability

## Map System

### Layout
- **World Overview**: Zoomed-out view of all discovered regions
- **Detailed View**: Zoomed-in view of current area
- **Legend**: Icon explanations (bottom left)
- **Current Location**: Highlighted with pulsing indicator

### Navigation
- **Panning**: Smooth scrolling across map areas
- **Zooming**: Multiple detail levels from world view to local area
- **Location Selection**: Cursor highlighting of points of interest
- **Fast Travel**: Selection of unlocked waypoints

### Special Elements
- **Fog of War**: Undiscovered areas obscured
- **Objective Markers**: Current quest locations highlighted
- **Collection Tracking**: Icons showing collectible status by area
- **Region Information**: Data panel for selected region

## Codex

### Layout
- **Category Tabs**: Top navigation for different codex sections
- **Entry List**: Scrollable list of discovered entries (left)
- **Entry Content**: Detailed information with images (right)
- **Progress Tracker**: Collection completion percentage

### Navigation
- **Category Selection**: Tab-based navigation
- **Entry Browsing**: Vertical list navigation
- **Content Scrolling**: Multi-page entries with page turning
- **Search Function**: Filter entries by keyword

### Special Elements
- **New Entry Indicators**: Highlights for unread entries
- **Related Entries**: Links to connected codex pages
- **Animation/3D Models**: Interactive models for character/enemy entries
- **Audio Samples**: Playable sounds for relevant entries

## Options Menu

### Layout
- **Category Tabs**: Top navigation for different settings
- **Setting List**: Scrollable list of options (left)
- **Adjustment Controls**: Sliders, toggles, dropdown menus (right)
- **Defaults Button**: Option to reset to default settings

### Navigation
- **Category Tabs**: Horizontal tab navigation
- **Setting Selection**: Vertical list navigation
- **Value Adjustment**: Horizontal sliders, toggle buttons
- **Apply/Revert**: Confirmation for changes that require restart

### Special Elements
- **Preview Panel**: Visual/audio previews of setting changes
- **Tooltip Descriptions**: Detailed explanations of each setting
- **Controller Layout**: Visual representation in Controls tab
- **Accessibility Features**: Prominently placed for easy access

## Technical Implementation Notes

The menu system is built on a flexible, component-based architecture that allows for:

- **Consistent Theming**: All menus adapt to world-specific visual themes
- **Responsive Layouts**: Automatic adjustment for different screen sizes and platforms
- **Controller/Keyboard/Touch Support**: Adaptive input handling
- **Memory Efficiency**: Menu assets loaded/unloaded as needed

*For technical details on menu implementation, see [UI Screen Management](../../02_Technical_Design/TDD/UISystem.TDD.md#screen-management).*

## Related Documents
- [Design Philosophy](DesignPhilosophy.md) - Core UI/UX principles
- [HUD Layouts](HUD_Layouts.md) - In-game interface elements
- [UI System TDD](../../02_Technical_Design/TDD/UISystem.TDD.md) - Technical implementation

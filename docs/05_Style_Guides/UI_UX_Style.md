# UI/UX Style Guide

This document outlines the user interface (UI) and user experience (UX) standards for the Adventure Jumper project.

## UI Design Philosophy

### Core Principles
1. **Minimalist by Default**: Show only what players need when they need it
2. **Diegetic When Possible**: Integrate UI into the game world
3. **Consistent Visual Language**: Use consistent patterns players can learn once
4. **Progressive Disclosure**: Reveal complexity gradually as the player advances
5. **Responsive Feedback**: Provide clear, immediate feedback to player actions

## Visual Style

### Overall Aesthetic
The UI follows a modern pixel art style that complements the game's visual approach while ensuring readability across all platforms.

### Color Scheme

#### Primary UI Colors
- **Background**: Dark Blue (#1A1C2C)
- **Primary**: Cyan (#5FCDE4)
- **Secondary**: Amber (#FFD700)
- **Accent**: Purple (#9E6AFF)
- **Text**: White (#FFFFFF)

#### Functional Colors
- **Positive/Success**: Green (#42E45F)
- **Warning/Important**: Yellow (#FFD700)
- **Danger/Error**: Red (#FF5A5A)
- **Health**: Red (#FF4A6D)
- **Aether Energy**: Cyan (#42E5F5)

### Typography

#### Fonts
- **Primary Font**: "Pixel Bold" (custom pixel font)
  - Used for headers, button text, and important UI elements
- **Secondary Font**: "Pixel Regular" (custom pixel font)
  - Used for body text, descriptions, and smaller UI elements

#### Text Sizes
- **Large**: 24px (headers, important notifications)
- **Medium**: 18px (button text, menu items)
- **Small**: 14px (descriptions, tooltips)
- **Tiny**: 10px (debug info, credits)

### Icons & Elements

#### Icon Style
- 16x16px or 32x32px pixel art
- 1px outlines for clarity
- Consistent visual weight across the icon set
- Clear silhouettes recognizable at small sizes

#### UI Elements
- **Buttons**: Rounded rectangles with subtle gradient
- **Panels**: Semi-transparent dark backgrounds with light borders
- **Toggles**: Custom designed switches with clear state indication
- **Sliders**: Pixel art sliders with distinctive handles
- **Progress Bars**: Chunky bars with clear fill direction

## Layout & Structure

### Grid System
- Base grid of 8x8 pixels
- UI elements snap to grid
- Consistent spacing (8px, 16px, 24px, 32px)
- Responsive scaling for different screen sizes

### Screen Layouts

#### HUD (Heads-Up Display)
- **Health**: Top-left corner, heart icons or bar
- **Aether Energy**: Top-left corner, below health, glowing bar
- **Abilities**: Bottom-right corner, icon-based
- **Collectibles**: Top-right corner, icon + count
- **Minimap** (when unlocked): Bottom-left corner, toggle-able

#### Menus
- **Main Menu**: Centered title with vertical button layout
- **Pause Menu**: Semi-transparent overlay with centered panel
- **Inventory**: Grid-based layout with item details panel
- **Map Screen**: Full-screen map with legend and markers
- **Settings**: Categorized options with clear labels and controls

### Responsive Design
- UI scales appropriately for different screen sizes
- Mobile interfaces have larger touch targets (minimum 44x44px)
- Alternative layouts for extremely wide or narrow screens
- Critical information always visible regardless of aspect ratio

## Interaction Design

### Input Feedback
- Button presses have visual and audio feedback
- Hover states provide clear indication of interactivity
- Loading states shown for any action taking >0.5 seconds
- Error states clearly communicate issues with resolution paths

### Navigation Patterns
- Consistent back/forward navigation
- Breadcrumb indication for deep menu structures
- Quick-access shortcuts for common actions
- Controller, keyboard, and touch navigation fully supported

### Accessibility
- Color-blind friendly palette with sufficient contrast
- Text size adjustable in settings
- Critical information conveyed through multiple channels (visual + audio)
- Controller remapping and alternative control schemes

## Animation & Motion

### UI Transitions
- **Menus**: Slide in/out (200ms ease-in-out)
- **Popups**: Scale up/down (150ms ease-out)
- **Notifications**: Fade + slide (300ms)
- **Page Transitions**: Cross-fade (250ms)

### Interactive Feedback
- Buttons compress slightly when clicked
- Icons pulse subtly for important notifications
- Progress bars fill smoothly rather than jumping
- Achievements/unlocks have celebratory animation sequence

### Timing Guidelines
- UI transitions: 150-300ms
- Feedback animations: 50-100ms
- Celebratory animations: 500-1000ms
- No essential information hidden for more than 2000ms

## Component Library

### Basic Components
- Text (multiple styles)
- Buttons (primary, secondary, disabled)
- Icons (system, ability, item, navigation)
- Panels (regular, highlighted, warning)

### Compound Components
- Dialog boxes
- Progress indicators
- Selection lists
- Tab controls
- Dropdown menus
- Item cards

### Screen Templates
- Standard menu screen
- Map screen
- Inventory grid
- Settings panel
- Achievement display

## Implementation Guidelines

### Technical Requirements
- UI scales correctly between 720p and 4K resolutions
- Animations maintain 60fps even during intensive gameplay
- UI elements load asynchronously to avoid game stutter
- Memory footprint kept minimal (max 15% of total budget)

### Asset Creation
- UI elements delivered as PNG sprites
- Use sprite atlases for optimal performance
- Include normal, hover, pressed, and disabled states
- Follow naming convention: `ui_[element]_[state].png`

### Code Structure
- UI logic separated from game logic
- Component-based architecture
- Responsive to different input methods
- Localizable text in external resource files

## UX Best Practices

### Onboarding
- Tutorial elements introduce mechanics one at a time
- First-time user experience (FTUE) guides through basic controls
- Progressive hints that reduce frequency as player demonstrates mastery
- Optional help system accessible at any time

### Feedback Systems
- Clear indication of successful/failed actions
- Contextual hints when player appears stuck
- Subtle guidance toward objectives
- Celebration of achievements and milestones

### Flow & Pacing
- Minimize interruptions during core gameplay
- Keep required menu interactions brief
- Allow skipping of non-essential cutscenes and dialogs
- Save automatically at appropriate intervals

## Quality Control

### UI Review Checklist
- [ ] Consistent with style guide (colors, typography, spacing)
- [ ] Functional across all supported resolutions
- [ ] Accessible with all input methods
- [ ] Performs within technical constraints
- [ ] Animations smooth and purposeful
- [ ] Text properly displaying and readable
- [ ] Localization ready with expandable text areas

### User Testing Focus Areas
- Navigation intuitiveness
- Information hierarchy clarity
- Time to accomplish common tasks
- Error recovery
- First-time user experience
- Cross-platform consistency

## Related Documents

### External References
- [Adventure Jumper UI Kit](https://ui-kit.link) (Internal resource)
- [Interactive Prototype](https://prototype.link) (Internal resource)
- [UI Animation Guidelines](https://animation.link) (Internal resource)
- [Accessibility Standards](https://accessibility.link) (Internal resource)

### Project Documents
- [UI System TDD](../02_Technical_Design/TDD/UISystem.TDD.md) - Technical implementation of UI components
- [Design Philosophy](../01_Game_Design/UI_UX_Design/DesignPhilosophy.md) - Core UI/UX design principles
- [Menus & Layouts](../01_Game_Design/UI_UX_Design/Menus_Layouts.md) - Menu structure and screen layouts
- [HUD Layouts](../01_Game_Design/UI_UX_Design/HUD_Layouts.md) - In-game UI element specifications
- [UI Design README](../01_Game_Design/UI_UX_Design/README.md) - Overview of all UI/UX design documents

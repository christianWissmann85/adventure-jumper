# VS Code Setup for Flutter Development

This document provides guidance on setting up VS Code for optimal Flutter development experience.

## Recommended Extensions

1. **Dart & Flutter Extensions**
   - Dart (by Dart Code)
   - Flutter (by Dart Code)
   - Awesome Flutter Snippets
   - Flutter Widget Snippets

2. **Productivity**
   - GitLens
   - Error Lens
   - Better Comments
   - Todo Tree
   - Code Spell Checker

3. **Themes & Icons**
   - Material Icon Theme
   - One Dark Pro

## Workspace Settings

The `.vscode` directory contains the following configuration files:

- `settings.json`: Workspace-specific settings for VS Code
- `launch.json`: Debug configurations
- `tasks.json`: Common development tasks
- `extensions.json`: Recommended extensions

## Keyboard Shortcuts

| Command | Windows/Linux | macOS |
|---------|---------------|-------|
| Hot Reload | Ctrl+\ | Cmd+\ |
| Hot Restart | Ctrl+Shift+\ | Cmd+Shift+\ |
| Open DevTools | Ctrl+Shift+D | Cmd+Shift+D |
| Format Document | Shift+Alt+F | Shift+Option+F |
| Quick Fix | Ctrl+. | Cmd+. |

## Debugging

Use the following launch configurations:

1. **Flutter (debug)**: Standard debug mode
2. **Flutter (profile)**: Profile mode for performance analysis
3. **Flutter (release)**: Release mode for final builds
4. **Flutter (web)**: Run in Chrome
5. **Flutter (windows)**: Run as Windows desktop app

## Common Tasks

Access tasks via `Ctrl+Shift+P` > "Tasks: Run Task"

- **Flutter: Run** - Run the app in debug mode
- **Flutter: Test** - Run tests
- **Flutter: Build APK** - Build Android release APK
- **Flutter: Build Web** - Build web version
- **Flutter: Clean** - Clean the project
- **Flutter: Pub Get** - Get packages
- **Flutter: Run Dev Tools** - Launch Flutter DevTools
- **Flutter: Analyze** - Run static analysis
- **Flutter: Format** - Format the code

## Tips

1. Use `Ctrl+Space` for code completion
2. `F12` to go to definition
3. `Alt+Enter` for quick fixes
4. `Ctrl+.` for code actions
5. `Ctrl+Shift+O` to navigate to symbols

## Linting

The project includes linting rules to maintain code quality. The linter will automatically run on save and highlight any issues in the Problems panel.

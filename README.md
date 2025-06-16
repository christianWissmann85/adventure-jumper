# Adventure Jumper 🏃‍♂️💨

[![CI/CD](https://github.com/christianwissmann85/adventure-jumper/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/christianwissmann85/adventure-jumper/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Flame](https://img.shields.io/badge/Flame-FF6B6B?logo=flame&logoColor=white)](https://flame-engine.org/)

A 2D platformer game built with Flutter and Flame engine. Embark on an exciting adventure through vibrant worlds, jumping over obstacles, and discovering secrets!

## 🎮 Features

- 🎮 Smooth platformer controls with responsive input
- 🌍 Multiple hand-crafted levels to explore
- ⭐ Collectibles and power-ups to enhance gameplay
- 📱 Responsive design for mobile and desktop
- 🚀 Built with Flutter for cross-platform compatibility
- 🎨 Pixel-perfect animations and visual effects
- 🎵 Immersive sound design and background music

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or later)
- Android Studio (for Android development)
- VS Code or Android Studio (recommended IDEs)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/christianwissmann85/adventure-jumper.git
   cd adventure-jumper
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   - For web: `flutter run -d chrome`
   - For Android: `flutter run -d <device-id>`
   - For Windows: `flutter run -d windows`

### Development Setup

1. **Code Formatting**
   ```bash
   # Format Dart code
   dart format .
   
   # Analyze code
   flutter analyze
   ```

2. **Running Tests**
   ```bash
   # Run all tests
   flutter test
   
   # Run tests with coverage
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

3. **Building for Release**
   ```bash
   # Build web
   flutter build web --release
   
   # Build Android APK
   flutter build apk --release --split-per-abi
   
   # Build Windows
   flutter build windows --release
   ```

### VS Code Setup (Recommended)

1. Install the following extensions:
   - Dart
   - Flutter
   - Pubspec Assist
   - Flutter Widget Snippets

2. Recommended settings (`.vscode/settings.json`):
   ```json
   {
     "dart.debugExternalPackageLibraries": true,
     "dart.debugSdkLibraries": false,
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true,
     "editor.formatOnSave": true,
     "editor.rulers": [80, 120],
     "editor.tabSize": 2,
     "files.trimTrailingWhitespace": true,
     "files.insertFinalNewline": true,
     "files.trimFinalNewlines": true
   }
   ```

## 🛠️ Building

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

## 📂 Project Structure

```
lib/
├── game/                  # Core game logic
│   ├── components/        # Game components (player, enemies, etc.)
│   ├── entities/         # Game entities
│   ├── levels/           # Level definitions
│   └── systems/          # Game systems (physics, rendering, etc.)
├── screens/              # Game screens (menu, game over, etc.)
└── utils/                # Utility classes and helpers
```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. **Fork** the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your Changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the Branch (`git push origin feature/AmazingFeature`)
5. Open a **Pull Request**

### 🛠 Development Setup

1. Ensure you have the latest stable version of Flutter installed
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter analyze` to check for any issues
5. Write tests for new features and ensure all tests pass

### 📜 Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) to understand the expectations for community behavior.

For questions or feedback, please open an issue on the [GitHub repository](https://github.com/christianwissmann85/adventure-jumper/issues).

## 🙏 Acknowledgments

- Inspired by classic 2D platformers
- Built with the amazing Flutter framework
- Special thanks to the Flame engine developers

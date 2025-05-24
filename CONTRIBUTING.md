# Contributing to Adventure Jumper 🎮

Thank you for your interest in contributing to Adventure Jumper! We're excited to have you on board. This guide will help you get started with contributing to our project.

## 📜 Code of Conduct

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing. We expect all contributors to adhere to its guidelines to maintain a welcoming and inclusive environment.

## 🚀 How to Contribute

### Reporting Issues
- Check if the issue already exists in the [issue tracker](https://github.com/your-username/adventure-jumper/issues)
- Provide a clear title and description
- Include steps to reproduce the issue
- Add screenshots or screen recordings if applicable
- Specify your device and OS version

### Suggesting Enhancements
- Open an issue with the "enhancement" label
- Clearly describe the proposed feature or improvement
- Explain why this would be valuable for the game
- Include any relevant references or examples

### Making Code Changes
1. **Fork** the repository and create your branch from `main`
   ```bash
   git checkout -b feature/amazing-feature
   ```
2. **Code** your changes following our coding standards
3. **Test** your changes thoroughly
4. **Lint** your code
   ```bash
   flutter analyze
   ```
5. **Commit** your changes with a clear message
   ```bash
   git commit -m "feat: add amazing feature"
   ```
6. **Push** to your fork
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request** against the `main` branch

## 🛠 Development Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Git
- IDE: VS Code (recommended) or Android Studio
- Optional: Flutter and Dart plugins for your IDE

### Getting Started

1. **Fork and clone** the repository
   ```bash
   git clone https://github.com/your-username/adventure-jumper.git
   cd adventure-jumper
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

## 🎨 Code Style

We follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and use the following tools:

- **Analysis Options**: Our [analysis_options.yaml](analysis_options.yaml) defines our lint rules
- **Formatting**: Run `dart format .` to format your code
- **Linting**: Run `flutter analyze` to check for issues

### Commit Message Format
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Example:
```
feat(player): add double jump ability

- Implement double jump mechanics
- Add double jump animation
- Update player physics for double jump

Closes #123
```

### Pull Request Guidelines
- Keep PRs focused on a single feature or bug fix
- Update documentation as needed
- Ensure all tests pass
- Request reviews from maintainers
- Address all CI/CD checks
- Run `dart format .` before committing
- Keep lines under 80 characters
- Use meaningful variable and function names

## Testing

- Write tests for new features
- Run all tests before submitting a PR:
  ```bash
  flutter test
  ```

## Pull Request Guidelines

- Keep PRs focused on a single feature or bug fix
- Update documentation as needed
- Include tests for new features
- Ensure all tests pass
- Update the CHANGELOG.md if applicable

## Reporting Issues

When creating an issue, please include:

1. A clear title and description
2. Steps to reproduce the issue
3. Expected vs. actual behavior
4. Screenshots if applicable
5. Device/OS version
6. Flutter version (`flutter --version`)

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

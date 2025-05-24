# 📜 Changelog

All notable changes to the Adventure Jumper project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 🚀 [Unreleased]

### Added
- Project documentation structure
- GitHub workflows for CI/CD
- Core game mechanics implementation
  - Player movement and physics
  - Basic level design
  - Collision detection system
- Development environment setup guide
- Contribution guidelines and code of conduct

### Changed
- Updated Flutter SDK to 3.19.0 and Dart SDK to 3.3.0
- Restructured project documentation for better clarity
- Improved development workflow with automated checks
- Updated analysis options for better code quality
- Enhanced README with detailed setup instructions

### Fixed
- Resolved lint warnings and errors across the codebase
- Fixed key event handling for smoother controls
- Addressed performance issues in the rendering pipeline
- Fixed collision detection edge cases

## [0.1.0] - 2025-05-21

### Added
- Initial project setup with Flutter and Flame
- Basic game structure and architecture
- Core game mechanics foundation
- Documentation framework
- Basic test suite

### Changed
- N/A (Initial release)

### Fixed
- N/A (Initial release)

---

## 📋 Versioning Policy

This project uses [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR** version (1.0.0):
  - Incompatible API changes
  - Major rewrites or refactoring
  - Breaking changes to existing functionality

- **MINOR** version (0.2.0):
  - New features and enhancements
  - Backward-compatible additions
  - Significant improvements to existing features

- **PATCH** version (0.0.1):
  - Bug fixes and patches
  - Minor improvements
  - Documentation updates
  - Dependency updates

## ⚠️ Deprecation Policy

- Deprecated features will be:
  - Marked with `@deprecated` in the code
  - Documented in the relevant version's changelog
  - Supported for at least one MINOR version before removal

- Migration guides will be provided when:
  - Major breaking changes are introduced
  - Features are removed
  - Significant architectural changes occur

## 🔄 Release Process

1. Update version numbers in `pubspec.yaml`
2. Update this CHANGELOG.md with release notes
3. Create a git tag with the version number (e.g., `v1.0.0`)
4. Push changes and tags to the repository
5. Create a GitHub release with the changelog entries

## 📅 Maintenance Policy

- **Active Development**: Regular updates and new features
- **Maintenance Mode**: Only critical bug fixes and security updates
- **End of Life**: No further updates or support

Current status: **Active Development**

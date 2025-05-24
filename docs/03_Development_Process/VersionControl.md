# Version Control

*This document outlines the version control workflow and best practices for the Adventure Jumper project. It should be used in conjunction with our [Code Style Guide](../05_Style_Guides/CodeStyle.md) and the [Documentation Style Guide](../05_Style_Guides/DocumentationStyle.md).*

## Git Workflow

Adventure Jumper uses a modified Git Flow workflow:

### Branches

- **`main`**: Production-ready code. Protected branch that only accepts merges through pull requests.
- **`develop`**: Integration branch for features. This is where features are combined and tested before release.
- **`feature/<name>`**: Feature branches for new development work.
- **`bugfix/<issue-number>`**: Bug fix branches for addressing specific issues.
- **`release/<version>`**: Release candidate branches for final testing before merging to main.
- **`hotfix/<issue-number>`**: Critical fixes for production issues.

### Workflow Process

1. **Feature Development**:
   - Create branch from `develop`: `git checkout -b feature/new-ability develop`
   - Develop the feature
   - Create pull request to merge back into `develop`
   - Delete branch after merge

2. **Bug Fixes**:
   - Create branch from `develop`: `git checkout -b bugfix/123 develop`
   - Fix the bug
   - Create pull request to merge back into `develop`
   - Delete branch after merge

3. **Releases**:
   - Create branch from `develop`: `git checkout -b release/1.0.0 develop`
   - Perform release testing and fixes
   - Create pull request to merge into `main`
   - Tag the release in `main`: `git tag -a v1.0.0 -m "Version 1.0.0"`
   - Merge release branch back to `develop`
   - Delete release branch

4. **Hotfixes**:
   - Create branch from `main`: `git checkout -b hotfix/456 main`
   - Fix the critical issue
   - Create pull requests to merge into both `main` and `develop`
   - Tag the hotfix in `main`: `git tag -a v1.0.1 -m "Hotfix 1.0.1"`
   - Delete hotfix branch

## Commit Guidelines

### Commit Message Format

We follow a simplified version of conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect the code's meaning (formatting, etc.)
- **refactor**: Code changes that neither fix a bug nor add a feature
- **perf**: Performance improvements
- **test**: Adding or correcting tests
- **chore**: Changes to build process, tools, etc.

Example:
```
feat(player): add double jump ability

Implement double jump ability for the player character.
The player can now jump once more while already in the air.

Closes #42
```

### Best Practices

1. **Commit frequently** with small, logical changes
2. **Write descriptive messages** that explain why the change was made
3. **Reference issue numbers** in commit messages when applicable
4. **Squash commits** before merging to keep history clean

## Pull Request Process

1. Create a pull request with a clear description
2. Link related issues
3. Ensure all CI checks pass
4. Request review from at least one team member
5. Address review feedback
6. Squash and merge when approved

## Git LFS

We use Git LFS for large binary files:

### Tracked File Types
- Images (*.png, *.jpg)
- Audio (*.mp3, *.wav)
- Fonts (*.ttf)
- Large data files (*.json over 5MB)

To set up Git LFS:
```
git lfs install
git lfs track "*.png"
git lfs track "*.mp3"
git lfs track "*.wav"
git lfs track "*.ttf"
git add .gitattributes
```

## Git Hooks

We use pre-commit and pre-push hooks to maintain code quality:

### Pre-commit
- Format code
- Run linter
- Run quick unit tests

### Pre-push
- Run full test suite
- Ensure no debug code is committed

## Related Documents

### Process Documents
- [Implementation Guide](ImplementationGuide.md) - Development workflow details
- [Testing Strategy](TestingStrategy.md) - Test branch management

### Style Guides
- [Code Style Guide](../05_Style_Guides/CodeStyle.md) - Coding standards and conventions
- [Documentation Style Guide](../05_Style_Guides/DocumentationStyle.md) - Standards for commit messages and documentation

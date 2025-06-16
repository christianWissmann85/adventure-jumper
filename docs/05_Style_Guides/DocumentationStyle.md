# Documentation Style Guide

This document provides guidelines for creating and maintaining documentation for the Adventure Jumper project.

## Documentation Principles

1. **Clarity First**: Write for understanding, not to impress
2. **Keep It Current**: Documentation must evolve with the project
3. **Know Your Audience**: Tailor content to the intended readers
4. **Show, Don't Tell**: Use examples, diagrams, and code samples
5. **Structure Matters**: Organize information logically and consistently

## Document Types

### Project Documentation

- **README.md**: Project overview and quick start
- **CONTRIBUTING.md**: Contribution guidelines
- **CHANGELOG.md**: Version history and changes
- **LICENSE**: Legal terms for usage

### Design Documentation

- **Game Design Document (GDD)**: Core gameplay and feature specs
- **Technical Design Documents (TDDs)**: System implementation details
- **Art/Audio Guidelines**: Visual and audio direction

### Technical Documentation

- **API Documentation**: Interface descriptions and usage
- **Code Comments**: In-code explanations
- **Architecture Overview**: System structure and interactions

### Process Documentation

- **Workflow Guides**: How to perform common tasks
- **Standards Documents**: Team conventions and practices
- **Tutorial Content**: Step-by-step learning resources

## Formatting Standards

### Markdown Usage

#### Headers

Use hierarchy appropriately:

```markdown
# Top-Level Document Title (H1)

## Major Section (H2)

### Subsection (H3)

#### Detail Group (H4)
```

#### Lists

- Use bullet points for unordered lists
- Use numbered lists for sequential steps
- Nest with consistent indentation (2 spaces)

#### Code

- Inline code with single backticks: `variable`
- Code blocks with triple backticks and language identifier:
  ```dart
  void main() {
    print('Hello, Adventure Jumper!');
  }
  ```

#### Tables

| Use tables | For structured data |
| ---------- | ------------------- |
| Align      | For readability     |
| Keep       | Tables simple       |

#### Links

- Internal document links: [Document Title](./path/to/document.md)
- Section links: [Section Title](#section-anchor)
- External links: [Resource Name](https://example.com)

### Visual Elements

#### Images

- Include meaningful alt text
- Keep images reasonably sized
- Use consistent styling for diagrams
- Caption images where necessary

#### Diagrams

- Use Mermaid for flowcharts, sequence diagrams, etc.
- Maintain consistent color schemes
- Include legend for complex diagrams
- Keep text in diagrams legible

### Text Style

#### Voice and Tone

- Use active voice
- Be direct and concise
- Maintain professional but approachable tone
- Use present tense when possible

#### Technical Writing

- Define acronyms on first use
- Explain jargon when necessary
- Use consistent terminology
- Avoid subjective language

## Document Structure

### Standard Sections

#### For All Documents

1. **Title**: Clear, descriptive document title
2. **Overview/Introduction**: Brief explanation of purpose
3. **Table of Contents**: For longer documents
4. **Main Content**: Organized in logical sections
5. **References**: Related documents or resources

#### For Technical Documents

1. **Prerequisites**: Required knowledge or setup
2. **Installation/Setup**: Getting started steps
3. **Usage Examples**: Practical applications
4. **API Reference**: Detailed interface documentation
5. **Troubleshooting**: Common issues and solutions

#### For Design Documents

1. **Design Goals**: Intended outcomes
2. **Specifications**: Detailed requirements
3. **Implementation Notes**: Technical considerations
4. **Open Questions**: Unresolved design decisions
5. **Revision History**: Document changes

## File Organization

### Naming Conventions

- Use descriptive, hyphenated names: `player-movement-system.md`
- Maintain consistent capitalization (prefer lowercase)
- Avoid spaces in filenames
- Use standard file extensions (`.md` for Markdown)

### Directory Structure

- Group related documents in folders
- Use clear, descriptive folder names
- Maintain reasonable nesting depth (max 3-4 levels)
- Include README.md in each directory to explain contents

## Documentation Process

### Creation Workflow

1. Identify documentation need
2. Determine appropriate document type
3. Create using template if applicable
4. Write initial draft
5. Review for technical accuracy
6. Edit for style and clarity
7. Publish to repository

### Maintenance

- Review documentation quarterly
- Update with significant code changes
- Mark outdated sections clearly
- Archive obsolete documents
- Track documentation tasks in project management system

### Collaborative Practices

- Use pull requests for significant changes
- Conduct documentation reviews
- Assign clear ownership for document sets
- Encourage team contributions and improvements

## Writing Guidelines

### Do's

- Use consistent terminology
- Write in clear, simple language
- Break complex topics into digestible sections
- Provide context before details
- Include practical examples

### Don'ts

- Use unnecessary jargon
- Write overly long paragraphs
- Leave placeholder text in published documents
- Duplicate information found elsewhere
- Make assumptions about reader knowledge

## Templates

### Basic Document Template

```markdown
# [Document Title]

## Overview

Brief description of the document's purpose and content.

## [Main Section 1]

Content for the first main section.

### [Subsection 1.1]

More detailed information.

## [Main Section 2]

Content for the second main section.

## Related Documents

- [Related Document 1](./path/to/document.md)
- [Related Document 2](./path/to/document.md)
```

### Technical Design Document Template

```markdown
# [System Name] - Technical Design Document

## 1. Overview

Purpose and scope of the system.

## 2. Class Design

Key classes, responsibilities, and relationships.

## 3. Data Structures

Important data formats and schemas.

## 4. Algorithms

Core algorithms and their implementation.

## 5. API/Interfaces

How the system interacts with others.

## 6. Dependencies

Other systems this relies on.

## 7. File Structure

Proposed file organization.

## 8. Performance Considerations

Optimization strategies and concerns.

## 9. Testing Strategy

Approach to ensuring correctness.
```

## Quality Standards

### Review Checklist

- [ ] Content is technically accurate
- [ ] Document follows style guidelines
- [ ] Structure is logical and consistent
- [ ] Links and references work correctly
- [ ] Images and diagrams are clear
- [ ] No spelling or grammar errors
- [ ] Terminology is consistent
- [ ] Examples are working and relevant

### Common Issues to Avoid

- Outdated information
- Inconsistent formatting
- Unclear explanations
- Missing prerequisites
- Broken links or references
- Overly complex language
- Incomplete sections

## Tools and Resources

### Recommended Tools

- Visual Studio Code with Markdown extensions
- Grammarly for proofreading
- Mermaid for diagrams
- PlantUML for UML diagrams
- Screenshot tools with annotation capabilities

### Style References

- [Google Developer Documentation Style Guide](https://developers.google.com/style)
- [Microsoft Writing Style Guide](https://docs.microsoft.com/style-guide/welcome/)
- [Material Design Documentation Guidelines](https://material.io/design)

## Related Documents

### Project Documents

- [Terminology Glossary](../Terminology_Glossary.md) - Standard terminology for all documentation
- [Implementation Guide](../03_Development_Process/ImplementationGuide.md) - Code documentation standards
- [Version Control](../03_Development_Process/VersionControl.md) - Git commit message standards
- [README Template](../README.md) - Example of main documentation structure

## Logging Standards

### When to Use Different Logging Methods

Adventure Jumper uses a structured logging approach with different methods for different scenarios:

#### `print()` Usage (Discouraged)

- **Avoid** using `print()` in production code
- Only acceptable for:
  - CLI scripts (e.g., `scripts/add_trailing_commas.dart`)
  - Bootstrap logging before logger initialization
  - Development console output (e.g., `error_handler.dart` development mode)

#### `developer.log()` Usage

- **Temporary debugging** during active development
- Short-term debugging that will be removed after issue resolution
- Always include descriptive `name` parameter for DevTools context

```dart
import 'dart:developer' as developer;

developer.log(
  'Player moving left (velocity: ${velocity.x})',
  name: 'PlayerController._movePlayerLeft',
  level: 800, // INFO level
);
```

#### `logger.*()` Usage (Structured Logging)

- **Persistent logging** for production code
- Use appropriate log levels based on message importance

### Log Level Guidelines

| Level     | Method             | When to Use                                  | Examples                                      |
| --------- | ------------------ | -------------------------------------------- | --------------------------------------------- |
| `SEVERE`  | `logger.severe()`  | Critical errors that affect functionality    | Asset loading failures, save corruption       |
| `WARNING` | `logger.warning()` | Potential problems that don't halt execution | Missing optional assets, performance warnings |
| `INFO`    | `logger.info()`    | Significant events and operations            | Level transitions, player achievements        |
| `FINE`    | `logger.fine()`    | Detailed debugging information               | Entity state changes, collision details       |
| `FINER`   | `logger.finer()`   | Very detailed debugging                      | Step-by-step algorithm execution              |
| `FINEST`  | `logger.finest()`  | Extremely granular debugging                 | Variable value tracking                       |

### Logging Patterns

#### Basic Class Logging

```dart
import '../utils/logger.dart';

class MyGameSystem {
  // Use the LoggerExtension for automatic class naming
  void performOperation() {
    logger.info('Starting operation');

    try {
      // Operation code here
      logger.fine('Operation completed successfully');
    } catch (e, stackTrace) {
      logger.severe('Operation failed', e, stackTrace);
    }
  }
}
```

#### Static Logger Instance

```dart
import '../utils/logger.dart';

class MyUtilityClass {
  static final _logger = GameLogger.getLogger('MyUtilityClass');

  static void utilityMethod() {
    _logger.info('Utility method called');
  }
}
```

#### Error Logging with Context

```dart
// For errors that should be handled by ErrorHandler
logger.severe('Failed to load level', exception, stackTrace);

// For warnings that don't need error handling
logger.warning('Performance threshold exceeded: ${duration}ms');
```

### Test Logging Conventions

- Use `logger.fine()` for detailed test debugging
- Use `logger.info()` for test milestone logging
- Preserve test output clarity - avoid excessive logging
- Use `developer.log()` for temporary test debugging

```dart
test('Player movement system', () {
  logger.info('Testing player movement system');

  // Test setup
  logger.fine('Player initial position: ${player.position}');

  // Test execution and assertions
  player.moveLeft();

  logger.fine('Player final position: ${player.position}');
  expect(player.position.x, lessThan(initialX));
});
```

### Security Considerations

**Never log sensitive information:**

- Passwords or authentication tokens
- Personal user data
- API keys or secrets
- Complete save file contents (log metadata only)

```dart
// Good - log operation status
logger.info('User authentication successful');

// Bad - log sensitive data
logger.info('User logged in with password: $password');

// Good - log save operation metadata
logger.info('Save file written: ${saveFile.name} (${saveFile.size} bytes)');

// Bad - log complete save data
logger.info('Save data: ${saveFile.content}');
```

### Performance Considerations

- Use appropriate log levels to avoid performance impact
- Wrap expensive logging operations in level checks:

```dart
if (logger.isLoggable(Level.FINE)) {
  logger.fine('Expensive debug info: ${computeExpensiveDebugInfo()}');
}
```

- Structured logging is efficient, but avoid excessive logging in tight loops

### DevTools Integration

All structured logging integrates with Flutter DevTools:

- View logs in the Logging tab
- Filter by logger name and level
- Error logs automatically route to ErrorHandler
- Warning logs use `developer.log()` for better DevTools display

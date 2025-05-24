# Enums and Named Parameters Guide

## Overview
This document outlines the improvements made to the Adventure Jumper API by replacing boolean parameters with named parameters and enums to improve code readability, maintainability, and self-documentation.

## Why Use Enums Instead of Boolean Parameters?

Boolean parameters in method signatures can lead to several issues:

1. **Readability Problems**: When calling a method with multiple boolean parameters, it's hard to understand what each value means:
   ```dart
   // Hard to understand what each boolean means
   portal.initialize(true, false, true);
   
   // Much clearer with enums
   portal.initialize(
     state: PortalState.active,
     interaction: PortalInteractionType.automatic,
     saveProgress: true
   );
   ```

2. **Limited States**: Booleans only represent two states. If you need to express more than two states, you'd need to use additional booleans, leading to complex combinations.

3. **Error-Prone API**: Easy to accidentally swap boolean parameters, leading to bugs that are hard to detect.

4. **Poor Documentation**: Boolean parameters don't self-document their purpose in code.

## Implemented Enum-Based APIs

### 1. Error Handling Modes

**Before:**
```dart
FileUtils.readFileAsString(filePath, shouldRethrow: true);
```

**After:**
```dart
FileUtils.readFileAsString(
  filePath, 
  errorHandling: ErrorHandlingMode.rethrowAfterLogging
);
```

Available modes:
- `ErrorHandlingMode.suppressAndReturnFallback` - Suppresses exceptions and returns a fallback value
- `ErrorHandlingMode.rethrowAfterLogging` - Logs and then rethrows exceptions

### 2. Input Component API

**Before:**
```dart
InputComponent(
  isActive: true,
  useKeyboard: true,
  useVirtualController: false,
  enableInputBuffering: true
);
```

**After:**
```dart
InputComponent(
  inputMode: InputMode.active,
  inputSource: InputSource.keyboard,
  bufferingMode: InputBufferingMode.enabled
);
```

Available enums:
- `InputMode`: `active`, `inactive`
- `InputSource`: `keyboard`, `virtualController`, `both`, `none`
- `InputBufferingMode`: `enabled`, `disabled`

### 3. Portal API

**Before:**
```dart
Portal(
  position: Vector2(100, 100),
  targetLevelId: 'level2',
  isActive: true,
  requiresInteraction: false
);
```

**After:**
```dart
Portal(
  position: Vector2(100, 100),
  targetLevelId: 'level2',
  initialState: PortalState.active,
  interactionType: PortalInteractionType.automatic
);
```

Available enums:
- `PortalState`: `active`, `inactive`
- `PortalInteractionType`: `automatic`, `requiresInteraction`

## Best Practices for Using Enums

1. **Name Clearly**: Choose descriptive enum names that represent the concept, not just the property
2. **Value Coverage**: Ensure enum values cover all possible states of the property
3. **Default Values**: Always provide sensible default values
4. **Documentation**: Document each enum value to explain its purpose
5. **Backward Compatibility**: When updating existing APIs, consider keeping the old boolean methods with "deprecated" annotations

## Converting Boolean Parameters to Enums

If you need to convert more boolean parameters to enums, follow these steps:

1. Identify a boolean parameter that would be clearer as an enum
2. Define an enum with descriptive value names
3. Update the method signature to accept the enum
4. Update the method implementation to use the enum
5. Update all call sites to use the enum
6. Add appropriate documentation

## Conclusion

Using enums and named parameters makes our Adventure Jumper API more:
- Self-documenting
- Type-safe
- Extensible
- Maintainable

These improvements lay the groundwork for a more robust, developer-friendly codebase that will be easier to maintain and extend as the project grows.

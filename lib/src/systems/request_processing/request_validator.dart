import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flame/components.dart';

import '../interfaces/movement_request.dart';
import '../interfaces/player_movement_request.dart';

/// Validation result for movement requests.
///
/// Provides detailed information about validation failures to aid debugging
/// and provide meaningful error messages.
class ValidationResult {
  /// Whether the request passed validation
  final bool isValid;

  /// Human-readable error message if validation failed
  final String? errorMessage;

  /// Specific validation rule that failed
  final ValidationRule? failedRule;

  /// Suggested correction if applicable
  final String? suggestion;
  
  /// Warning message for valid requests with concerns
  final String? warning;
  
  /// Whether accumulation prevention is recommended
  final bool requiresAccumulationPrevention;

  const ValidationResult.valid({
    this.warning,
    this.requiresAccumulationPrevention = false,
  })  : isValid = true,
        errorMessage = null,
        failedRule = null,
        suggestion = null;

  const ValidationResult.invalid({
    required this.errorMessage,
    this.failedRule,
    this.suggestion,
    this.requiresAccumulationPrevention = false,
  })  : isValid = false,
        warning = null;
}

/// Specific validation rules that can fail.
enum ValidationRule {
  invalidEntityId,
  invalidDirection,
  invalidMagnitude,
  speedTooHigh,
  forceTooHigh,
  requestExpired,
  invalidRequestType,
  physicsStateConflict,
  rateLimitExceeded,
  rapidInputDetected,
  oscillationDetected,
  invalidActionCombination,
  inputSpamDetected,
}

/// Validates movement requests before processing.
///
/// This validator implements comprehensive validation as specified in
/// PHY-2.3.2 of the Physics-Movement System Refactor. It ensures:
/// - Request data integrity
/// - Physics constraints compliance
/// - Performance boundaries
/// - State consistency
class RequestValidator {
  /// Maximum allowed speeds for different movement types
  static const double maxWalkSpeed = 500.0;
  static const double maxDashSpeed = 1000.0;
  static const double maxGlobalSpeed = 10000.0;

  /// Maximum allowed forces
  static const double maxJumpForce = 1000.0;
  static const double maxImpulseForce = 5000.0;

  /// Minimum thresholds
  static const double minDirectionMagnitude = 0.001;
  static const double minSpeed = 0.1;

  /// Validation statistics
  int _totalValidations = 0;
  int _passedValidations = 0;
  final Map<ValidationRule, int> _failuresByRule = {};
  
  /// Request history for rate limiting and pattern detection (PHY-3.2.2)
  final Map<int, Queue<DateTime>> _requestHistory = {};
  
  /// Recent request types for pattern detection
  final Map<int, Queue<MovementType>> _recentRequestTypes = {};
  
  /// Rapid input sequence tracking
  final Map<int, RapidInputTracker> _rapidInputTrackers = {};
  
  /// Rate limiting constants
  static const int maxRequestsPerSecond = 60;
  static const int rateLimitWindow = 1000; // milliseconds
  static const int minRequestInterval = 16; // ~60fps

  /// Validate a movement request comprehensively.
  ///
  /// Performs multiple validation checks:
  /// 1. Basic data integrity
  /// 2. Type-specific constraints
  /// 3. Physics boundaries
  /// 4. Performance limits
  ///
  /// **Parameters:**
  /// - [request]: The movement request to validate
  /// - [currentSpeed]: Optional current entity speed for context
  ///
  /// **Returns:** Detailed validation result
  ValidationResult validateMovementRequest(
    MovementRequest request, {
    double? currentSpeed,
  }) {
    _totalValidations++;

    // Basic validation using request's built-in validation
    if (!request.isValid) {
      return _recordFailure(
        ValidationRule.invalidEntityId,
        'Request failed basic validation: ${request.entityId < 0 ? "Invalid entity ID" : "Invalid data"}',
      );
    }

    // Check expiration
    if (request.isExpired()) {
      return _recordFailure(
        ValidationRule.requestExpired,
        'Request expired (age: ${request.ageInMilliseconds}ms)',
        suggestion: 'Submit requests immediately after creation',
      );
    }
    
    // PHY-3.2.2: Rate limiting check
    final rateLimitResult = _checkRateLimit(request);
    if (!rateLimitResult.isValid) {
      return rateLimitResult;
    }
    
    // PHY-3.2.2: Pattern detection for accumulation prevention
    final patternResult = _checkRequestPatterns(request);
    if (!patternResult.isValid) {
      return patternResult;
    }
    
    // PHY-3.2.2: Player-specific validation
    if (request is PlayerMovementRequest) {
      final playerResult = _validatePlayerRequest(request);
      if (!playerResult.isValid) {
        return playerResult;
      }
    }
    
    // Update tracking data
    _updateRequestHistory(request);

    // Type-specific validation
    switch (request.type) {
      case MovementType.walk:
        return _validateWalkRequest(request);

      case MovementType.dash:
        return _validateDashRequest(request);

      case MovementType.jump:
        return _validateJumpRequest(request);

      case MovementType.stop:
        return _validateStopRequest(request);

      case MovementType.impulse:
        return _validateImpulseRequest(request);
    }
  }

  /// Check if a direction vector is valid for movement.
  bool isValidDirection(Vector2 direction) {
    // Check for NaN or infinity
    if (!direction.x.isFinite || !direction.y.isFinite) {
      return false;
    }

    // Check for zero vector (except for stop requests)
    if (direction.length < minDirectionMagnitude) {
      return false;
    }

    // Check for reasonable magnitude (should be roughly normalized)
    if (direction.length > 10.0) {
      developer.log(
        'Direction vector too large: ${direction.length}',
        name: 'RequestValidator',
      );
      return false;
    }

    return true;
  }

  /// Check if a speed value is valid for the entity.
  bool isValidSpeed(double speed, int entityId, {MovementType? type}) {
    // Check for NaN or infinity
    if (!speed.isFinite) {
      return false;
    }

    // Check for negative speed
    if (speed < 0) {
      return false;
    }

    // Type-specific speed limits
    if (type != null) {
      switch (type) {
        case MovementType.walk:
          if (speed > maxWalkSpeed) {
            developer.log(
              'Walk speed too high for entity $entityId: $speed',
              name: 'RequestValidator',
            );
            return false;
          }
          break;

        case MovementType.dash:
          if (speed > maxDashSpeed) {
            developer.log(
              'Dash speed too high for entity $entityId: $speed',
              name: 'RequestValidator',
            );
            return false;
          }
          break;

        default:
          // Other types don't have specific speed limits
          break;
      }
    }

    // Global speed limit
    if (speed > maxGlobalSpeed) {
      developer.log(
        'Speed exceeds global limit for entity $entityId: $speed',
        name: 'RequestValidator',
      );
      return false;
    }

    return true;
  }

  /// Validate walk movement request.
  ValidationResult _validateWalkRequest(MovementRequest request) {
    // Check direction
    if (!isValidDirection(request.direction)) {
      return _recordFailure(
        ValidationRule.invalidDirection,
        'Invalid walk direction: ${request.direction}',
        suggestion: 'Ensure direction is normalized and non-zero',
      );
    }

    // Check speed
    if (!isValidSpeed(request.magnitude, request.entityId,
        type: MovementType.walk,)) {
      return _recordFailure(
        ValidationRule.speedTooHigh,
        'Walk speed too high: ${request.magnitude} (max: $maxWalkSpeed)',
        suggestion: 'Reduce speed to within walk limits',
      );
    }

    // Check minimum speed
    if (request.magnitude < minSpeed) {
      return _recordFailure(
        ValidationRule.invalidMagnitude,
        'Walk speed too low: ${request.magnitude} (min: $minSpeed)',
        suggestion: 'Use stop request for zero movement',
      );
    }

    _passedValidations++;
    return const ValidationResult.valid();
  }

  /// Validate dash movement request.
  ValidationResult _validateDashRequest(MovementRequest request) {
    // Check direction
    if (!isValidDirection(request.direction)) {
      return _recordFailure(
        ValidationRule.invalidDirection,
        'Invalid dash direction: ${request.direction}',
        suggestion: 'Ensure direction is normalized and non-zero',
      );
    }

    // Check speed
    if (!isValidSpeed(request.magnitude, request.entityId,
        type: MovementType.dash,)) {
      return _recordFailure(
        ValidationRule.speedTooHigh,
        'Dash speed too high: ${request.magnitude} (max: $maxDashSpeed)',
        suggestion: 'Reduce speed to within dash limits',
      );
    }

    // Dash should have meaningful speed
    if (request.magnitude < maxWalkSpeed * 0.5) {
      return _recordFailure(
        ValidationRule.invalidMagnitude,
        'Dash speed too low: ${request.magnitude} (should be > ${maxWalkSpeed * 0.5})',
        suggestion: 'Use walk request for slower movement',
      );
    }

    _passedValidations++;
    return const ValidationResult.valid();
  }

  /// Validate jump movement request.
  ValidationResult _validateJumpRequest(MovementRequest request) {
    // Jump direction should be upward
    if (request.direction.y >= 0) {
      return _recordFailure(
        ValidationRule.invalidDirection,
        'Jump direction not upward: ${request.direction}',
        suggestion: 'Jump direction should have negative Y component',
      );
    }

    // Check force magnitude
    if (request.magnitude <= 0) {
      return _recordFailure(
        ValidationRule.invalidMagnitude,
        'Jump force must be positive: ${request.magnitude}',
      );
    }

    if (request.magnitude > maxJumpForce) {
      return _recordFailure(
        ValidationRule.forceTooHigh,
        'Jump force too high: ${request.magnitude} (max: $maxJumpForce)',
        suggestion: 'Reduce jump force to reasonable levels',
      );
    }

    _passedValidations++;
    return const ValidationResult.valid();
  }

  /// Validate stop movement request.
  ValidationResult _validateStopRequest(MovementRequest request) {
    // Stop requests should have zero direction and magnitude
    if (request.direction.length > minDirectionMagnitude) {
      developer.log(
        'Stop request has non-zero direction: ${request.direction}',
        name: 'RequestValidator',
      );
    }

    if (request.magnitude > 0) {
      developer.log(
        'Stop request has non-zero magnitude: ${request.magnitude}',
        name: 'RequestValidator',
      );
    }

    // Stop requests are generally always valid
    _passedValidations++;
    return const ValidationResult.valid();
  }

  /// Validate impulse movement request.
  ValidationResult _validateImpulseRequest(MovementRequest request) {
    // Check direction
    if (!isValidDirection(request.direction)) {
      return _recordFailure(
        ValidationRule.invalidDirection,
        'Invalid impulse direction: ${request.direction}',
        suggestion: 'Ensure direction is normalized and non-zero',
      );
    }

    // Check force magnitude
    if (request.magnitude <= 0) {
      return _recordFailure(
        ValidationRule.invalidMagnitude,
        'Impulse force must be positive: ${request.magnitude}',
      );
    }

    if (request.magnitude > maxImpulseForce) {
      return _recordFailure(
        ValidationRule.forceTooHigh,
        'Impulse force too high: ${request.magnitude} (max: $maxImpulseForce)',
        suggestion: 'Reduce impulse force to prevent physics instability',
      );
    }

    _passedValidations++;
    return const ValidationResult.valid();
  }

  /// Record a validation failure for statistics.
  ValidationResult _recordFailure(
    ValidationRule rule,
    String errorMessage, {
    String? suggestion,
  }) {
    _failuresByRule[rule] = (_failuresByRule[rule] ?? 0) + 1;

    developer.log(
      'Validation failed: $errorMessage',
      name: 'RequestValidator',
    );

    return ValidationResult.invalid(
      errorMessage: errorMessage,
      failedRule: rule,
      suggestion: suggestion,
    );
  }

  /// Get validation statistics.
  Map<String, dynamic> get statistics => {
        'total': _totalValidations,
        'passed': _passedValidations,
        'failed': _totalValidations - _passedValidations,
        'passRate': _totalValidations > 0
            ? '${(_passedValidations / _totalValidations * 100)
                    .toStringAsFixed(1)}%'
            : 'N/A',
        'failuresByRule': Map<String, int>.fromEntries(
            _failuresByRule.entries.map((e) => MapEntry(e.key.name, e.value)),),
      };

  /// Reset statistics counters.
  void resetStatistics() {
    _totalValidations = 0;
    _passedValidations = 0;
    _failuresByRule.clear();
  }
  
  /// PHY-3.2.2: Check rate limiting for the entity.
  ValidationResult _checkRateLimit(MovementRequest request) {
    final history = _requestHistory.putIfAbsent(
      request.entityId,
      () => Queue<DateTime>(),
    );
    
    // Remove old entries outside the rate limit window
    final cutoffTime = DateTime.now().subtract(
      Duration(milliseconds: rateLimitWindow),
    );
    while (history.isNotEmpty && history.first.isBefore(cutoffTime)) {
      history.removeFirst();
    }
    
    // Check if we've exceeded the rate limit
    if (history.length >= maxRequestsPerSecond) {
      return _recordFailure(
        ValidationRule.rateLimitExceeded,
        'Rate limit exceeded (${history.length} requests in ${rateLimitWindow}ms)',
        suggestion: 'Reduce input frequency',
      );
    }
    
    // Check minimum interval between requests
    if (history.isNotEmpty) {
      final timeSinceLastRequest = request.timestamp.difference(history.last).inMilliseconds;
      if (timeSinceLastRequest < minRequestInterval) {
        return ValidationResult.valid(
          warning: 'Request frequency high (${timeSinceLastRequest}ms since last)',
          requiresAccumulationPrevention: true,
        );
      }
    }
    
    return const ValidationResult.valid();
  }
  
  /// PHY-3.2.2: Check for problematic request patterns.
  ValidationResult _checkRequestPatterns(MovementRequest request) {
    final recentTypes = _recentRequestTypes.putIfAbsent(
      request.entityId,
      () => Queue<MovementType>(),
    );
    
    // Track rapid input sequences
    final tracker = _rapidInputTrackers.putIfAbsent(
      request.entityId,
      () => RapidInputTracker(),
    );
    
    // Update tracker
    tracker.addRequest(request);
    
    // Check for rapid oscillation (e.g., left-right-left-right)
    if (_detectOscillation(recentTypes, request.type)) {
      return _recordFailure(
        ValidationRule.oscillationDetected,
        'Rapid oscillation detected in movement',
        suggestion: 'Smooth out input transitions',
      );
    }
    
    // Check for input spam patterns
    if (tracker.isSpamming) {
      return _recordFailure(
        ValidationRule.inputSpamDetected,
        'Input spam detected (${tracker.requestsPerSecond.toStringAsFixed(1)} req/s)',
        suggestion: 'Reduce input frequency below 30 req/s',
      );
    }
    
    // Add current type to history
    recentTypes.add(request.type);
    if (recentTypes.length > 10) {
      recentTypes.removeFirst();
    }
    
    return const ValidationResult.valid();
  }
  
  /// PHY-3.2.2: Validate player-specific request properties.
  ValidationResult _validatePlayerRequest(PlayerMovementRequest request) {
    // Check for invalid action combinations
    if (request.action == PlayerAction.jump && 
        request.previousAction == PlayerAction.crouch) {
      return _recordFailure(
        ValidationRule.invalidActionCombination,
        'Cannot jump while crouching',
        suggestion: 'Stand up before jumping',
      );
    }
    
    // Check rapid input handling
    if (request.isRapidInput && !request.requiresAccumulationPrevention) {
      return ValidationResult.valid(
        warning: 'Rapid input detected but accumulation prevention not requested',
        requiresAccumulationPrevention: true,
      );
    }
    
    return const ValidationResult.valid();
  }
  
  /// PHY-3.2.2: Detect oscillation patterns in request types.
  bool _detectOscillation(Queue<MovementType> history, MovementType current) {
    if (history.length < 4) return false;
    
    // Check for A-B-A-B pattern
    final types = history.toList();
    if (types.length >= 3) {
      final last3 = types.sublist(types.length - 3);
      if (last3[0] == current && 
          last3[1] != current && 
          last3[2] == current) {
        return true;
      }
    }
    
    return false;
  }
  
  /// PHY-3.2.2: Update request history after validation.
  void _updateRequestHistory(MovementRequest request) {
    final history = _requestHistory.putIfAbsent(
      request.entityId,
      () => Queue<DateTime>(),
    );
    history.add(request.timestamp);
  }
  
  /// PHY-3.2.2: Clear history for an entity (useful for respawns).
  void clearEntityHistory(int entityId) {
    _requestHistory.remove(entityId);
    _recentRequestTypes.remove(entityId);
    _rapidInputTrackers.remove(entityId);
  }
  
  /// PHY-3.2.2: Get current request rate for an entity.
  double getRequestRate(int entityId) {
    final tracker = _rapidInputTrackers[entityId];
    return tracker?.requestsPerSecond ?? 0.0;
  }
  
  /// PHY-3.2.2: Check if entity has active rapid input.
  bool hasRapidInput(int entityId) {
    final tracker = _rapidInputTrackers[entityId];
    return tracker?.isRapidSequence ?? false;
  }
}

/// PHY-3.2.2: Tracks rapid input sequences for spam detection.
class RapidInputTracker {
  static const int windowSize = 1000; // 1 second window
  static const int sequenceThreshold = 50; // 50ms between inputs
  static const double spamThreshold = 30.0; // 30 requests per second
  
  final Queue<DateTime> _timestamps = Queue<DateTime>();
  DateTime? _sequenceStart;
  int _sequenceCount = 0;
  
  void addRequest(MovementRequest request) {
    final now = request.timestamp;
    
    // Clean old timestamps
    final cutoff = now.subtract(Duration(milliseconds: windowSize));
    while (_timestamps.isNotEmpty && _timestamps.first.isBefore(cutoff)) {
      _timestamps.removeFirst();
    }
    
    // Check for rapid sequence
    if (_timestamps.isNotEmpty) {
      final timeSinceLast = now.difference(_timestamps.last).inMilliseconds;
      if (timeSinceLast < sequenceThreshold) {
        if (_sequenceStart == null) {
          _sequenceStart = _timestamps.last;
          _sequenceCount = 2;
        } else {
          _sequenceCount++;
        }
      } else {
        // Sequence broken
        _sequenceStart = null;
        _sequenceCount = 0;
      }
    }
    
    _timestamps.add(now);
  }
  
  double get requestsPerSecond {
    if (_timestamps.isEmpty) return 0.0;
    
    final duration = _timestamps.last.difference(_timestamps.first).inMilliseconds;
    if (duration == 0) return 0.0;
    
    return (_timestamps.length * 1000.0) / duration;
  }
  
  bool get isRapidSequence => _sequenceCount > 3;
  
  bool get isSpamming => requestsPerSecond > spamThreshold;
}

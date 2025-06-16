import 'dart:math' as math;

import 'package:flame/components.dart';

/// Component that handles AI logic for entities
/// Manages behavior states, pathfinding, and decision-making
class AIComponent extends Component {
  AIComponent({
    String? initialState,
    double? detectionRange,
    double? attackRange,
    int? difficulty,
    bool? isAggressive,
    bool? canPatrol,
    bool? canFollow,
  }) {
    if (initialState != null) currentState = initialState;
    if (detectionRange != null) detectionRange = detectionRange;
    if (attackRange != null) attackRange = attackRange;
    if (difficulty != null) _difficulty = difficulty;
    if (isAggressive != null) _isAggressive = isAggressive;
    if (canPatrol != null) _canPatrol = canPatrol;
    if (canFollow != null) _canFollow = canFollow;
  }

  // AI States
  String currentState = 'idle';
  final List<String> _availableStates = <String>[
    'idle',
    'patrol',
    'chase',
    'attack',
    'flee',
    'stunned',
  ];
  // AI Parameters
  double detectionRange = 200;
  double attackRange = 50;
  // Will be used in Sprint 3 for scaling enemy difficulty
  // ignore: unused_field
  int _difficulty = 1; // 1-5, higher is more difficult
  bool _isAggressive = true;
  bool _canPatrol = true;
  bool _canFollow = true;

  // Target tracking
  Vector2? targetPosition;
  bool hasTarget = false;
  final math.Random _random = math.Random();

  // Patrol points
  final List<Vector2> _patrolPoints = <Vector2>[];
  int _currentPatrolIndex = 0;
  double _waitTime = 0;
  double _waitTimer = 0;

  // State timers
  double _stateTime = 0;
  final Map<String, double> _stateDurations = <String, double>{
    'idle': 2.0,
    'stunned': 3.0,
  };

  @override
  void onMount() {
    super.onMount();

    // Initialize patrol points around entity position if none provided
    if (_patrolPoints.isEmpty && parent is PositionComponent) {
      // TODO(christian): Kept nullable (pos) due to previous runtime errors related to parent component's state/type. Re-evaluate when AI lifecycle is more stable.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Vector2? pos = (parent as PositionComponent).position;
      if (pos != null) {
        _patrolPoints.add(Vector2(pos.x - 100, pos.y));
        _patrolPoints.add(Vector2(pos.x + 100, pos.y));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update state timer
    _stateTime += dt;

    // Update based on current state
    switch (currentState) {
      case 'idle':
        _updateIdleState(dt);
        break;
      case 'patrol':
        _updatePatrolState(dt);
        break;
      case 'chase':
        _updateChaseState(dt);
        break;
      case 'attack':
        _updateAttackState(dt);
        break;
      case 'flee':
        _updateFleeState(dt);
        break;
      case 'stunned':
        _updateStunnedState(dt);
        break;
    }
  }

  /// Set AI state
  void setState(String newState) {
    if (_availableStates.contains(newState)) {
      currentState = newState;
      _stateTime = 0;
    }
  }

  /// Update idle state logic
  void _updateIdleState(double dt) {
    // Wait for some time, then switch to patrol if able
    if (_stateTime >= _stateDurations['idle']!) {
      if (_canPatrol) {
        setState('patrol');
      } else {
        _stateTime = 0; // Reset timer to keep idling
      }
    }

    // If target detected and aggressive, switch to chase
    if (hasTarget && _isAggressive) {
      setState('chase');
    }
  }

  /// Update patrol state logic
  void _updatePatrolState(double dt) {
    if (!_canPatrol || _patrolPoints.isEmpty) {
      setState('idle');
      return;
    }

    // Get current patrol point
    final Vector2 targetPoint = _patrolPoints[_currentPatrolIndex];

    // Move towards patrol point
    if (parent is PositionComponent) {
      // TODO(christian): Kept nullable (pos) due to previous runtime errors related to parent component's state/type. Re-evaluate when AI lifecycle is more stable.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Vector2? pos = (parent as PositionComponent).position;
      if (pos == null) return;
      final double distance = pos.distanceTo(targetPoint);

      if (distance < 10) {
        // Reached patrol point
        _waitTimer += dt;

        if (_waitTimer >= _waitTime) {
          // Move to next patrol point
          _currentPatrolIndex =
              (_currentPatrolIndex + 1) % _patrolPoints.length;
          _waitTimer = 0;
          _waitTime = 1.0 +
              _random.nextDouble() *
                  2.0; // Random wait time between 1-3 seconds
        }
      } else {
        // Move towards patrol point
        // Actual movement would be handled by a physics or movement component
      }
    }

    // If target detected and aggressive, switch to chase
    if (hasTarget && _isAggressive) {
      setState('chase');
    }
  }

  /// Update chase state logic
  void _updateChaseState(double dt) {
    if (!hasTarget || !_canFollow || targetPosition == null) {
      setState('idle');
      return;
    }

    if (parent is PositionComponent) {
      // TODO(christian): Kept nullable (pos) due to previous runtime errors related to parent component's state/type. Re-evaluate when AI lifecycle is more stable.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Vector2? pos = (parent as PositionComponent).position;
      if (pos == null) return;
      final double distanceToTarget = pos.distanceTo(targetPosition!);

      // If within attack range, switch to attack
      if (distanceToTarget <= attackRange) {
        setState('attack');
        return;
      }

      // If target too far, go back to patrol
      if (distanceToTarget > detectionRange * 1.5) {
        setState('patrol');
        hasTarget = false;
        targetPosition = null;
        return;
      }

      // Move towards target
      // Actual movement would be handled by a physics or movement component
    }
  }

  /// Update attack state logic
  void _updateAttackState(double dt) {
    if (!hasTarget || targetPosition == null) {
      setState('idle');
      return;
    }

    if (parent is PositionComponent) {
      // TODO(christian): Kept nullable (pos) due to previous runtime errors related to parent component's state/type. Re-evaluate when AI lifecycle is more stable.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Vector2? pos = (parent as PositionComponent).position;
      if (pos == null) return;
      final double distanceToTarget = pos.distanceTo(targetPosition!);

      // If target moved out of attack range, chase again
      if (distanceToTarget > attackRange) {
        setState('chase');
        return;
      }

      // Perform attack
      // Attack logic would be handled by entity-specific code
    }
  }

  /// Update flee state logic
  void _updateFleeState(double dt) {
    if (!hasTarget || targetPosition == null) {
      setState('idle');
      return;
    }

    // Move away from target
    // Actual movement would be handled by a physics or movement component
  }

  /// Update stunned state logic
  void _updateStunnedState(double dt) {
    // Remain stunned for duration
    if (_stateTime >= _stateDurations['stunned']!) {
      setState('idle');
    }
  }

  /// Set target position
  void setTarget(Vector2 targetValue, bool isAwareOfTarget) {
    targetPosition = targetValue.clone();
    hasTarget = isAwareOfTarget;
  }

  /// Add patrol point
  void addPatrolPoint(Vector2 point) {
    _patrolPoints.add(point.clone());
  }

  /// Clear patrol points
  void clearPatrolPoints() {
    _patrolPoints.clear();
    _currentPatrolIndex = 0;
  }

  /// Stun this AI entity
  void stun(double duration) {
    _stateDurations['stunned'] = duration;
    setState('stunned');
  }

  // Getters and setters
}

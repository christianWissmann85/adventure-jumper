import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';

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
    if (initialState != null) _currentState = initialState;
    if (detectionRange != null) _detectionRange = detectionRange;
    if (attackRange != null) _attackRange = attackRange;
    if (difficulty != null) _difficulty = difficulty;
    if (isAggressive != null) _isAggressive = isAggressive;
    if (canPatrol != null) _canPatrol = canPatrol;
    if (canFollow != null) _canFollow = canFollow;
  }

  // AI States
  String _currentState = 'idle';
  final List<String> _availableStates = <String>[
    'idle',
    'patrol',
    'chase',
    'attack',
    'flee',
    'stunned',
  ];
  // AI Properties
  double _detectionRange = 200;
  double _attackRange = 50;
  // Will be used in Sprint 3 for scaling enemy difficulty
  // ignore: unused_field
  int _difficulty = 1; // 1-5, higher is more difficult
  bool _isAggressive = true;
  bool _canPatrol = true;
  bool _canFollow = true;

  // Target tracking
  Vector2? _targetPosition;
  bool _hasTarget = false;
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
      final NotifyingVector2 pos = (parent as PositionComponent).position;
      _patrolPoints.add(Vector2(pos.x - 100, pos.y));
      _patrolPoints.add(Vector2(pos.x + 100, pos.y));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update state timer
    _stateTime += dt;

    // Update based on current state
    switch (_currentState) {
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
      _currentState = newState;
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
    if (_hasTarget && _isAggressive) {
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
      final NotifyingVector2 pos = (parent as PositionComponent).position;
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
    if (_hasTarget && _isAggressive) {
      setState('chase');
    }
  }

  /// Update chase state logic
  void _updateChaseState(double dt) {
    if (!_hasTarget || !_canFollow || _targetPosition == null) {
      setState('idle');
      return;
    }

    if (parent is PositionComponent) {
      final NotifyingVector2 pos = (parent as PositionComponent).position;
      final double distanceToTarget = pos.distanceTo(_targetPosition!);

      // If within attack range, switch to attack
      if (distanceToTarget <= _attackRange) {
        setState('attack');
        return;
      }

      // If target too far, go back to patrol
      if (distanceToTarget > _detectionRange * 1.5) {
        setState('patrol');
        _hasTarget = false;
        _targetPosition = null;
        return;
      }

      // Move towards target
      // Actual movement would be handled by a physics or movement component
    }
  }

  /// Update attack state logic
  void _updateAttackState(double dt) {
    if (!_hasTarget || _targetPosition == null) {
      setState('idle');
      return;
    }

    if (parent is PositionComponent) {
      final NotifyingVector2 pos = (parent as PositionComponent).position;
      final double distanceToTarget = pos.distanceTo(_targetPosition!);

      // If target moved out of attack range, chase again
      if (distanceToTarget > _attackRange) {
        setState('chase');
        return;
      }

      // Perform attack
      // Attack logic would be handled by entity-specific code
    }
  }

  /// Update flee state logic
  void _updateFleeState(double dt) {
    if (!_hasTarget || _targetPosition == null) {
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
  void setTarget(Vector2 target, bool isAwareOfTarget) {
    _targetPosition = target.clone();
    _hasTarget = isAwareOfTarget;
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
  String get currentState => _currentState;
  double get detectionRange => _detectionRange;
  set detectionRange(double range) => _detectionRange = range;
  double get attackRange => _attackRange;
  set attackRange(double range) => _attackRange = range;
  bool get hasTarget => _hasTarget;
  Vector2? get targetPosition => _targetPosition;
}

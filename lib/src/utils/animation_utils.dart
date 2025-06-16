import 'dart:math' as math;

import 'package:flame/components.dart';

/// Animation and interpolation utilities for Adventure Jumper
/// Provides easing functions, interpolation helpers, and animation curves
class AnimationUtils {
  // Private constructor - static class
  AnimationUtils._();

  /// Linear interpolation between two values
  static double lerp(double start, double end, double t) {
    return start + (end - start) * t.clamp(0.0, 1.0);
  }

  /// Vector2 linear interpolation
  static Vector2 lerpVector2(Vector2 start, Vector2 end, double t) {
    return Vector2(
      lerp(start.x, end.x, t),
      lerp(start.y, end.y, t),
    );
  }

  /// Smooth step interpolation (S-curve)
  static double smoothStep(double start, double end, double t) {
    final double clampedT = t.clamp(0.0, 1.0);
    final double smoothedT = clampedT * clampedT * (3.0 - 2.0 * clampedT);
    return start + (end - start) * smoothedT;
  }

  /// Smoother step interpolation (smoother S-curve)
  static double smootherStep(double start, double end, double t) {
    final double clampedT = t.clamp(0.0, 1.0);
    final double smoothedT = clampedT *
        clampedT *
        clampedT *
        (clampedT * (clampedT * 6.0 - 15.0) + 10.0);
    return start + (end - start) * smoothedT;
  }

  /// Inverse linear interpolation - find t given start, end, and value
  static double inverseLerp(double start, double end, double value) {
    if (start == end) return 0;
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  /// Remap value from one range to another
  static double remap(
    double value,
    double inputMin,
    double inputMax,
    double outputMin,
    double outputMax,
  ) {
    final double t = inverseLerp(inputMin, inputMax, value);
    return lerp(outputMin, outputMax, t);
  }

  /// Bounce interpolation
  static double bounce(double t) {
    if (t < 1.0 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2.0 / 2.75) {
      final double adjustedT = t - 1.5 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.75;
    } else if (t < 2.5 / 2.75) {
      final double adjustedT = t - 2.25 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.9375;
    } else {
      final double adjustedT = t - 2.625 / 2.75;
      return 7.5625 * adjustedT * adjustedT + 0.984375;
    }
  }

  /// Elastic interpolation
  static double elastic(
    double t, {
    double amplitude = 1.0,
    double period = 0.3,
  }) {
    if (t == 0.0 || t == 1.0) return t;

    double s = period / 4.0;
    double finalAmplitude = amplitude;
    if (finalAmplitude < 1.0) {
      finalAmplitude = 1.0;
      s = period / 4.0;
    } else {
      s = period / (2.0 * math.pi) * math.asin(1.0 / finalAmplitude);
    }

    final double adjustedT = t - 1.0;
    return -(finalAmplitude *
        math.pow(2.0, 10.0 * adjustedT) *
        math.sin((adjustedT - s) * (2.0 * math.pi) / period));
  }

  /// Back interpolation (overshoot)
  static double back(double t, {double overshoot = 1.70158}) {
    return t * t * ((overshoot + 1.0) * t - overshoot);
  }

  /// Circular interpolation
  static double circularIn(double t) {
    return 1.0 - math.sqrt(1.0 - t * t);
  }

  static double circularOut(double t) {
    final double adjustedT = t - 1.0;
    return math.sqrt(1.0 - adjustedT * adjustedT);
  }

  static double circularInOut(double t) {
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) {
      return -0.5 * (math.sqrt(1.0 - scaledT * scaledT) - 1.0);
    }
    final double adjustedT = scaledT - 2.0;
    return 0.5 * (math.sqrt(1.0 - adjustedT * adjustedT) + 1.0);
  }

  /// Exponential interpolation
  static double exponentialIn(double t) {
    return t == 0.0 ? 0.0 : math.pow(2.0, 10.0 * (t - 1.0)).toDouble();
  }

  static double exponentialOut(double t) {
    return t == 1.0 ? 1.0 : 1.0 - math.pow(2.0, -10.0 * t);
  }

  static double exponentialInOut(double t) {
    if (t == 0.0 || t == 1.0) return t;
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) {
      return 0.5 * math.pow(2.0, 10.0 * (scaledT - 1.0));
    }
    return 0.5 * (2.0 - math.pow(2.0, -10.0 * (scaledT - 1.0)));
  }

  /// Sine interpolation
  static double sineIn(double t) {
    return 1.0 - math.cos(t * math.pi / 2.0);
  }

  static double sineOut(double t) {
    return math.sin(t * math.pi / 2.0);
  }

  static double sineInOut(double t) {
    return -0.5 * (math.cos(math.pi * t) - 1.0);
  }

  /// Quadratic interpolation
  static double quadIn(double t) {
    return t * t;
  }

  static double quadOut(double t) {
    return t * (2.0 - t);
  }

  static double quadInOut(double t) {
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) return 0.5 * scaledT * scaledT;
    final double adjustedT = scaledT - 1.0;
    return -0.5 * (adjustedT * (adjustedT - 2.0) - 1.0);
  }

  /// Cubic interpolation
  static double cubicIn(double t) {
    return t * t * t;
  }

  static double cubicOut(double t) {
    final double adjustedT = t - 1.0;
    return adjustedT * adjustedT * adjustedT + 1.0;
  }

  static double cubicInOut(double t) {
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) return 0.5 * scaledT * scaledT * scaledT;
    final double adjustedT = scaledT - 2.0;
    return 0.5 * (adjustedT * adjustedT * adjustedT + 2.0);
  }

  /// Quartic interpolation
  static double quartIn(double t) {
    return t * t * t * t;
  }

  static double quartOut(double t) {
    final double adjustedT = t - 1.0;
    return 1.0 - adjustedT * adjustedT * adjustedT * adjustedT;
  }

  static double quartInOut(double t) {
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) return 0.5 * scaledT * scaledT * scaledT * scaledT;
    final double adjustedT = scaledT - 2.0;
    return -0.5 * (adjustedT * adjustedT * adjustedT * adjustedT - 2.0);
  }

  /// Quintic interpolation
  static double quintIn(double t) {
    return t * t * t * t * t;
  }

  static double quintOut(double t) {
    final double adjustedT = t - 1.0;
    return adjustedT * adjustedT * adjustedT * adjustedT * adjustedT + 1.0;
  }

  static double quintInOut(double t) {
    final double scaledT = t * 2.0;
    if (scaledT < 1.0) {
      return 0.5 * scaledT * scaledT * scaledT * scaledT * scaledT;
    }
    final double adjustedT = scaledT - 2.0;
    return 0.5 *
        (adjustedT * adjustedT * adjustedT * adjustedT * adjustedT + 2.0);
  }

  /// Apply easing curve to interpolation
  static double applyEasing(double t, EasingType easing) {
    switch (easing) {
      case EasingType.linear:
        return t;
      case EasingType.quadIn:
        return quadIn(t);
      case EasingType.quadOut:
        return quadOut(t);
      case EasingType.quadInOut:
        return quadInOut(t);
      case EasingType.cubicIn:
        return cubicIn(t);
      case EasingType.cubicOut:
        return cubicOut(t);
      case EasingType.cubicInOut:
        return cubicInOut(t);
      case EasingType.quartIn:
        return quartIn(t);
      case EasingType.quartOut:
        return quartOut(t);
      case EasingType.quartInOut:
        return quartInOut(t);
      case EasingType.quintIn:
        return quintIn(t);
      case EasingType.quintOut:
        return quintOut(t);
      case EasingType.quintInOut:
        return quintInOut(t);
      case EasingType.sineIn:
        return sineIn(t);
      case EasingType.sineOut:
        return sineOut(t);
      case EasingType.sineInOut:
        return sineInOut(t);
      case EasingType.exponentialIn:
        return exponentialIn(t);
      case EasingType.exponentialOut:
        return exponentialOut(t);
      case EasingType.exponentialInOut:
        return exponentialInOut(t);
      case EasingType.circularIn:
        return circularIn(t);
      case EasingType.circularOut:
        return circularOut(t);
      case EasingType.circularInOut:
        return circularInOut(t);
      case EasingType.bounce:
        return bounce(t);
      case EasingType.elastic:
        return elastic(t);
      case EasingType.back:
        return back(t);
      case EasingType.smoothStep:
        return smoothStep(0, 1, t);
      case EasingType.smootherStep:
        return smootherStep(0, 1, t);
    }
  }

  /// Animate a value over time using an easing curve
  static double animateValue(
    double startValue,
    double endValue,
    double progress,
    EasingType easing,
  ) {
    final double easedProgress = applyEasing(progress, easing);
    return lerp(startValue, endValue, easedProgress);
  }

  /// Animate a Vector2 over time using an easing curve
  static Vector2 animateVector2(
    Vector2 startValue,
    Vector2 endValue,
    double progress,
    EasingType easing,
  ) {
    final double easedProgress = applyEasing(progress, easing);
    return lerpVector2(startValue, endValue, easedProgress);
  }

  /// Create a wave animation (sine wave)
  static double wave(
    double time, {
    double frequency = 1.0,
    double amplitude = 1.0,
    double offset = 0.0,
  }) {
    return amplitude * math.sin(2.0 * math.pi * frequency * time + offset);
  }

  /// Create a pulse animation (abs sine wave)
  static double pulse(
    double time, {
    double frequency = 1.0,
    double amplitude = 1.0,
  }) {
    return amplitude * (math.sin(2.0 * math.pi * frequency * time).abs());
  }

  /// Create a sawtooth wave animation
  static double sawtooth(
    double time, {
    double frequency = 1.0,
    double amplitude = 1.0,
  }) {
    final double t = (time * frequency) % 1.0;
    return amplitude * (2.0 * t - 1.0);
  }

  /// Create a triangle wave animation
  static double triangle(
    double time, {
    double frequency = 1.0,
    double amplitude = 1.0,
  }) {
    final double t = (time * frequency) % 1.0;
    return amplitude * (1.0 - 4.0 * (t - 0.5).abs());
  }

  /// Create a square wave animation
  static double square(
    double time, {
    double frequency = 1.0,
    double amplitude = 1.0,
    double dutyCycle = 0.5,
  }) {
    final double t = (time * frequency) % 1.0;
    return amplitude * (t < dutyCycle ? 1.0 : -1.0);
  }

  /// Ping-pong a value between 0 and length
  static double pingPong(double time, double length) {
    final double wrappedTime = time % (length * 2.0);
    return length - (wrappedTime - length).abs();
  }

  /// Create a smooth oscillation between two values
  static double oscillate(
    double time,
    double min,
    double max, {
    double frequency = 1.0,
  }) {
    final double t = (math.sin(2.0 * math.pi * frequency * time) + 1.0) * 0.5;
    return lerp(min, max, t);
  }

  /// Damped oscillation (spring-like movement)
  static double dampedOscillation(
    double time, {
    double frequency = 1.0,
    double damping = 0.1,
  }) {
    return math.exp(-damping * time) *
        math.cos(2.0 * math.pi * frequency * time);
  }

  /// Spring interpolation for smooth animations
  static double spring(
    double displacement,
    double velocity,
    double springConstant,
    double damping,
    double deltaTime,
  ) {
    final double force = -springConstant * displacement - damping * velocity;
    final double newVelocity = velocity + force * deltaTime;
    final double newDisplacement = displacement + newVelocity * deltaTime;
    return newDisplacement;
  }

  /// Calculate spring parameters for animation duration
  static SpringParams calculateSpringParams(
    double duration,
    double dampingRatio,
  ) {
    final double omega = 2.0 * math.pi / duration;
    final double damping = 2.0 * dampingRatio * omega;
    final double springConstant = omega * omega;

    return SpringParams(
      springConstant: springConstant,
      damping: damping,
      omega: omega,
    );
  }

  /// Shake animation for screen shake effects
  static Vector2 shake(
    double time,
    double intensity, {
    double frequency = 10.0,
    int seed = 0,
  }) {
    final math.Random random = math.Random(seed);
    final double x = (random.nextDouble() - 0.5) *
        2.0 *
        intensity *
        math.sin(2.0 * math.pi * frequency * time);
    final double y = (random.nextDouble() - 0.5) *
        2.0 *
        intensity *
        math.cos(2.0 * math.pi * frequency * time);
    return Vector2(x, y);
  }

  /// Noise-based shake for more organic feeling
  static Vector2 noiseShake(
    double time,
    double intensity, {
    double frequency = 10.0,
  }) {
    // Simple noise approximation using sine waves with different frequencies
    final double x = intensity *
        (math.sin(2.0 * math.pi * frequency * time) * 0.5 +
            math.sin(2.0 * math.pi * frequency * 1.337 * time) * 0.3 +
            math.sin(2.0 * math.pi * frequency * 2.719 * time) * 0.2);
    final double y = intensity *
        (math.cos(2.0 * math.pi * frequency * time) * 0.5 +
            math.cos(2.0 * math.pi * frequency * 1.619 * time) * 0.3 +
            math.cos(2.0 * math.pi * frequency * 3.141 * time) * 0.2);
    return Vector2(x, y);
  }

  /// Create bezier curve interpolation
  static double bezier(double t, double p0, double p1, double p2, double p3) {
    final double u = 1.0 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    return uuu * p0 + 3.0 * uu * t * p1 + 3.0 * u * tt * p2 + ttt * p3;
  }

  /// Create cubic bezier curve for custom easing
  static double cubicBezier(
    double t,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // Approximate cubic bezier curve evaluation
    // This is a simplified version - for production, consider using a proper implementation
    return bezier(t, 0, y1, y2, 1);
  }

  /// Animation sequencing - create animations that play one after another
  static double sequence(
    double t,
    List<double> durations,
    List<double Function(double)> animations,
  ) {
    if (durations.length != animations.length) {
      throw ArgumentError(
        'Durations and animations lists must have the same length',
      );
    }

    final double totalDuration =
        durations.fold(0, (double sum, double duration) => sum + duration);
    final double normalizedTime = (t * totalDuration).clamp(0.0, totalDuration);

    double currentTime = 0;
    for (int i = 0; i < durations.length; i++) {
      if (normalizedTime <= currentTime + durations[i]) {
        final double localTime = (normalizedTime - currentTime) / durations[i];
        return animations[i](localTime.clamp(0.0, 1.0));
      }
      currentTime += durations[i];
    }

    return animations.last(1);
  }

  /// Create parallel animations that blend together
  static double parallel(
    double t,
    List<double> weights,
    List<double Function(double)> animations,
  ) {
    if (weights.length != animations.length) {
      throw ArgumentError(
        'Weights and animations lists must have the same length',
      );
    }

    final double totalWeight =
        weights.fold(0, (double sum, double weight) => sum + weight);
    if (totalWeight == 0.0) return 0;

    double result = 0;
    for (int i = 0; i < animations.length; i++) {
      result += animations[i](t) * (weights[i] / totalWeight);
    }

    return result;
  }
}

/// Easing types for animations
enum EasingType {
  linear,
  quadIn,
  quadOut,
  quadInOut,
  cubicIn,
  cubicOut,
  cubicInOut,
  quartIn,
  quartOut,
  quartInOut,
  quintIn,
  quintOut,
  quintInOut,
  sineIn,
  sineOut,
  sineInOut,
  exponentialIn,
  exponentialOut,
  exponentialInOut,
  circularIn,
  circularOut,
  circularInOut,
  bounce,
  elastic,
  back,
  smoothStep,
  smootherStep,
}

/// Spring animation parameters
class SpringParams {
  const SpringParams({
    required this.springConstant,
    required this.damping,
    required this.omega,
  });
  final double springConstant;
  final double damping;
  final double omega;
}

/// Animation timeline for complex sequenced animations
class AnimationTimeline {
  final Map<String, AnimationTrack> _tracks = <String, AnimationTrack>{};
  double _duration = 0;

  /// Add an animation track
  void addTrack(String name, AnimationTrack track) {
    _tracks[name] = track;
    _duration = math.max(_duration, track.endTime);
  }

  /// Remove an animation track
  void removeTrack(String name) {
    _tracks.remove(name);
    _recalculateDuration();
  }

  /// Get value from a specific track at time t
  double? getTrackValue(String name, double time) {
    return _tracks[name]?.getValue(time);
  }

  /// Get all track values at time t
  Map<String, double> getAllValues(double time) {
    final Map<String, double> values = <String, double>{};
    for (final String name in _tracks.keys) {
      final double? value = _tracks[name]?.getValue(time);
      if (value != null) {
        values[name] = value;
      }
    }
    return values;
  }

  /// Recalculate total duration
  void _recalculateDuration() {
    _duration = _tracks.values.fold(
      0,
      (double max, AnimationTrack track) => math.max(max, track.endTime),
    );
  }

  double get duration => _duration;
  bool get isEmpty => _tracks.isEmpty;
}

/// Individual animation track within a timeline
class AnimationTrack {
  const AnimationTrack({
    required this.duration,
    this.startTime = 0.0,
    this.startValue = 0.0,
    this.endValue = 1.0,
    this.easing = EasingType.linear,
  });
  final double startTime;
  final double duration;
  final double startValue;
  final double endValue;
  final EasingType easing;

  double get endTime => startTime + duration;

  /// Get the value at a specific time
  double? getValue(double time) {
    if (time < startTime || time > endTime) {
      return null;
    }

    final double t = (time - startTime) / duration;
    return AnimationUtils.animateValue(startValue, endValue, t, easing);
  }
}

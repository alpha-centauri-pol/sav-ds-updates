import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class AppMotion {
  // Reduces motion (for accessibility).
  static bool reduce(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  // Spring Definitions
  static const SpringDescription springInteractive = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );

  static const SpringDescription springDefault = SpringDescription(
    mass: 1,
    stiffness: 100, // ~0.45s, bounce 0
    damping: 20,    // Critically damped
  );

  static const SpringDescription springSnappy = SpringDescription(
    mass: 1,
    stiffness: 400, // 150ms curve
    damping: 40,    // Over-damped (bounce 0)
  );

  static const SpringDescription springGentle = SpringDescription(
    mass: 1,
    stiffness: 50,
    damping: 10,
  );

  static const SpringDescription springPhysical = SpringDescription(
    mass: 1,
    stiffness: 150,
    damping: 15,
  );

  // Durations
  static const Duration durationHigh = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLow = Duration(milliseconds: 450);
  static const Duration durationRare = Duration(milliseconds: 600);

  // Helper for reduced motion
  static Duration duration(BuildContext context, Duration baseDuration) {
    return reduce(context) ? Duration.zero : baseDuration;
  }

  // Curves
  static const Curve curveOut = Curves.easeOutCubic;
  static const Curve curveInOut = Curves.easeInOutCubic;
  static const Curve curveGentleOut = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve curveEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  // Helper for applying enter blur
  static Widget blurIn(Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (reduce(context)) return child!;
        final double blurAmount = 4.0 * (1.0 - animation.value);
        if (blurAmount <= 0.05) return child!;
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: child,
        );
      },
      child: child,
    );
  }

  // Helper for a standard premium enter/exit AnimatedSwitcher
  static Widget switcher({
    required Widget? child,
    Duration? duration,
    double slideYEnter = 8.0,
    double slideYExit = 4.0,
  }) {
    return Builder(
      builder: (context) {
        final bool reduceMotion = reduce(context);
        return AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : (duration ?? durationMedium),
          switchInCurve: curveOut,
          switchOutCurve: curveGentleOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            if (reduceMotion) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
            final bool isEntering = animation.status != AnimationStatus.reverse;
            final double slideOffset = isEntering ? slideYEnter : slideYExit;

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final double y = slideOffset * (1.0 - animation.value);
                final double blurAmount = 4.0 * (1.0 - animation.value);

                Widget result = child!;
                if (blurAmount > 0.05) {
                  result = ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                    child: result,
                  );
                }
                if (y > 0.05) {
                  result = Transform.translate(
                    offset: Offset(0, y),
                    child: result,
                  );
                }
                return Opacity(
                  opacity: animation.value,
                  child: result,
                );
              },
              child: child,
            );
          },
          child: child,
        );
      },
    );
  }
}

class SpringCurve extends Curve {
  final SpringSimulation _sim;
  final double _endTime;

  SpringCurve(SpringDescription spring)
      : _sim = SpringSimulation(spring, 0.0, 1.0, 0.0),
        _endTime = _findEndTime(spring);

  static double _findEndTime(SpringDescription spring) {
    final sim = SpringSimulation(spring, 0.0, 1.0, 0.0);
    // Find when it is close enough to 1.0
    for (double t = 0.01; t < 2.0; t += 0.01) {
      if ((sim.x(t) - 1.0).abs() < 1e-3 && sim.dx(t).abs() < 1e-3) {
        return t;
      }
    }
    return 1.0;
  }

  @override
  double transformInternal(double t) {
    if (t >= 1.0) return 1.0;
    return _sim.x(t * _endTime).clamp(0.0, 1.0);
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion.dart';

/// A single-shot confetti ring that fires once behind a reward medal.
///
/// Cheap by construction: ~20 circles and one ring, drawn by a plain
/// [CustomPainter] with no blur, no images and no library. The controller
/// runs once and is disposed with the screen, so idle cost is zero.
class CelebrationBurst extends StatefulWidget {
  const CelebrationBurst({
    super.key,
    this.radius = 118,
    this.particleCount = 20,
    this.colors = const <Color>[
      RitualColors.amber,
      RitualColors.jade,
      RitualColors.sky,
      RitualColors.violet,
      RitualColors.sun,
    ],
  });

  final double radius;
  final int particleCount;
  final List<Color> colors;

  @override
  State<CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<CelebrationBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RitualMotion.celebrate,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) => CustomPaint(
            size: Size.square(widget.radius * 2),
            painter: _BurstPainter(
              t: _controller.value,
              particleCount: widget.particleCount,
              radius: widget.radius,
              colors: widget.colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.t,
    required this.particleCount,
    required this.radius,
    required this.colors,
  });

  final double t;
  final int particleCount;
  final double radius;
  final List<Color> colors;

  static double _fraction(double seed) {
    final double raw = (math.sin(seed * 12.9898) * 43758.5453).abs();
    return raw - raw.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double eased = Curves.easeOutCubic.transform(t);
    final double fade = 1 - t;

    // The ring: expands just ahead of the particles.
    canvas.drawCircle(
      center,
      radius * (0.26 + 0.74 * eased),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 + 3.4 * fade
        ..color = colors.first.withValues(alpha: 0.5 * fade),
    );

    for (int i = 0; i < particleCount; i++) {
      final double jitter = _fraction(i + 1);
      final double angle = (i / particleCount) * 2 * math.pi -
          math.pi / 2 +
          (jitter - 0.5) * 0.5;
      final double distance =
          radius * (0.30 + 0.70 * eased) * (0.72 + 0.34 * jitter);
      final double dotRadius = (2.2 + 3.8 * jitter) * (0.45 + 0.55 * fade);
      canvas.drawCircle(
        center +
            Offset(math.cos(angle) * distance, math.sin(angle) * distance),
        dotRadius,
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.95 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

/// The daily-goal ring: a rounded progress arc that sweeps to its value and
/// turns amber with a check mark once the daily target is met.
class DailyGoalRing extends StatelessWidget {
  const DailyGoalRing({
    super.key,
    required this.progress,
    required this.size,
    this.reached = false,
    this.strokeWidth = 7,
    this.child,
  });

  final double progress;
  final double size;
  final bool reached;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color active = reached ? RitualColors.amber : RitualColors.jade;
    if (prefersReducedMotion(context)) {
      return _ring(progress.clamp(0.0, 1.0), active);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: RitualMotion.standardCurve,
      builder: (BuildContext context, double value, Widget? _) =>
          _ring(value, active),
    );
  }

  Widget _ring(double value, Color active) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: RitualColors.line,
              color: active,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// The streak flame: grey and static when a streak is not running, softly
/// breathing in amber when it is. One looping ticker, only while alive.
class StreakFlame extends StatefulWidget {
  const StreakFlame({
    super.key,
    required this.streak,
    this.size = 30,
    this.showBadge = false,
  });

  final int streak;
  final double size;

  /// Draws a small tinted disc behind the flame (for stat cards).
  final bool showBadge;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(StreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final bool alive = widget.streak > 0 && !prefersReducedMotion(context);
    if (alive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!alive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool alive = widget.streak > 0;
    final Color color = alive ? RitualColors.amber : RitualColors.faint;

    final Widget flame = Icon(
      Icons.local_fire_department_rounded,
      size: widget.size,
      color: color,
    );

    final Widget body = alive
        ? AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) => Transform.scale(
              scale: 1 + 0.07 * Curves.easeInOut.transform(_controller.value),
              child: child,
            ),
            child: flame,
          )
        : flame;

    if (!widget.showBadge) {
      return body;
    }
    return Container(
      width: widget.size * 1.9,
      height: widget.size * 1.9,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: alive ? RitualColors.amberTint : RitualColors.bg,
        shape: BoxShape.circle,
      ),
      child: body,
    );
  }
}

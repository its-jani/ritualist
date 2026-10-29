import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// The app's whole motion vocabulary - one place, a handful of values.
///
/// Economy of motion (docs/rea-duolingo-findings.md §3h): short, cheap,
/// implicit animations; no particles systems running forever, no images.
/// Every duration below is a paint-only effect that finishes.
class RitualMotion {
  const RitualMotion._();

  /// The press: a surface sinking onto its lip. Matches the measured
  /// 4px lip of the reference study (findings §5), our own timing.
  static const Duration press = Duration(milliseconds: 70);

  /// Color flips on graded tiles.
  static const Duration fast = Duration(milliseconds: 150);

  /// Layout/state swaps (progress bar, counters).
  static const Duration standard = Duration(milliseconds: 240);

  /// The feedback panel sliding up.
  static const Duration panel = Duration(milliseconds: 260);

  /// XP / accuracy tallies on the results screen.
  static const Duration countUp = Duration(milliseconds: 800);

  /// The end-of-session celebration burst.
  static const Duration celebrate = Duration(milliseconds: 1100);

  /// Overshoot used for "pop" entrances and reward feedback.
  static const Curve pop = Cubic(0.34, 1.56, 0.64, 1);

  /// Deceleration for anything that grows into place.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// The one curve used for the winding path and panel slides.
  static const Curve inOut = Curves.easeInOutCubic;
}

/// Honors the platform "reduce motion" accessibility switch. Every looping
/// ornament goes through this; content never does.
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// A card that physically compresses into its darker lip when pressed.
///
/// This is the app's core tactile primitive: the surface translates down by
/// [depth] (the lip height) instead of scaling, so it reads as a physical
/// key being pushed - the interaction measured in the reference study.
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
    this.shadowColor = RitualColors.line,
    this.border,
    this.padding,
    this.radius = 14,
    this.depth = 4,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  /// The darker edge the surface sits on.
  final Color shadowColor;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double depth;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _down = false;

  bool get _interactive => widget.enabled && widget.onTap != null;

  void _setDown(bool value) {
    if (_down == value) {
      return;
    }
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(widget.radius);

    Widget card = Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: widget.depth,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.shadowColor,
              borderRadius: radius,
            ),
          ),
        ),
        AnimatedContainer(
          duration: RitualMotion.press,
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _down && _interactive ? widget.depth : 0,
            0,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: radius,
            border: widget.border,
          ),
          child: widget.child,
        ),
      ],
    );

    if (!_interactive) {
      return Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: card,
      );
    }

    card = Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      ),
    );
    return card;
  }
}

/// A one-shot entrance: fades in while popping from [beginScale].
///
/// The controller is short-lived and disposed with the widget - it is never
/// repeated, so nothing keeps ticking after the entrance is done.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.beginScale = 0.82,
    this.beginOffset = const Offset(0, 0.12),
    this.curve = RitualMotion.pop,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;
  final Offset beginOffset;
  final Curve curve;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return widget.child;
    }
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: RitualMotion.standardCurve,
        )),
        child: ScaleTransition(
          scale: Tween<double>(begin: widget.beginScale, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: widget.curve),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A number that counts up to [value] the first time it appears and re-tallies
/// when the value changes. One implicit animation, no controller.
class BouncyCounter extends StatelessWidget {
  const BouncyCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = RitualMotion.countUp,
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return Text('$prefix$value$suffix', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: RitualMotion.standardCurve,
      builder: (BuildContext context, double current, Widget? _) => Text(
        '$prefix${current.round()}$suffix',
        style: style,
      ),
    );
  }
}

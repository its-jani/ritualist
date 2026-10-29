import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion.dart';

enum PathNodeState { done, current, locked }

/// One circular lesson node on the winding path.
///
/// States are spatial, not just colored: the current node is physically
/// bigger, wrapped in a breathing halo and lifted by its START bubble; done
/// nodes carry a check; locked nodes sink into a flat grey. Every node sits
/// on a darker "lip" so the whole path reads as buttons you can press.
class PathNode extends StatefulWidget {
  const PathNode({
    super.key,
    required this.state,
    required this.palette,
    this.onTap,
    this.iconOverride,
    this.tooltip,
    this.checkpoint = false,
    this.showStartBubble = true,
  });

  final PathNodeState state;
  final UnitPalette palette;
  final VoidCallback? onTap;
  final IconData? iconOverride;
  final String? tooltip;

  /// A unit-final "checkpoint" node: bigger, crowned once cleared.
  final bool checkpoint;

  /// The floating START bubble above the current node.
  final bool showStartBubble;

  /// Diameter of a node face. Shared so the path can reserve exactly the
  /// right row height and keep its trail centred on the circle.
  static double sizeFor(PathNodeState state, {bool checkpoint = false}) =>
      checkpoint ? 86 : (state == PathNodeState.current ? 76 : 66);

  /// Diameter of this node's face.
  double get diameter => sizeFor(state, checkpoint: checkpoint);

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;
  bool _down = false;

  /// Lazily created so non-current nodes never build a ticker at all - and
  /// so `dispose()` can never accidentally construct one on a deactivated
  /// element (which would trip the ancestor-lookup assertion).
  AnimationController _ensurePulse() => _pulse ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      );

  bool get _isCurrent => widget.state == PathNodeState.current;

  bool get _isLocked => widget.state == PathNodeState.locked;

  @override
  void initState() {
    super.initState();
    if (_isCurrent) {
      _ensurePulse().repeat(reverse: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(PathNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final AnimationController? pulse = _pulse;
    if (_isCurrent && !prefersReducedMotion(context)) {
      final AnimationController active = _ensurePulse();
      if (!active.isAnimating) {
        active.repeat(reverse: true);
      }
    } else if (pulse != null && pulse.isAnimating) {
      pulse.stop();
      pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool locked = widget.state == PathNodeState.locked;
    final double size = widget.diameter;

    final Color base = locked ? const Color(0xFFEAEAEA) : widget.palette.base;
    final Color lip = locked ? const Color(0xFFD3D3D3) : widget.palette.lip;
    final Color iconColor = locked ? const Color(0xFFAFAFAF) : Colors.white;

    final IconData icon = widget.iconOverride ??
        switch (widget.state) {
          PathNodeState.done => widget.checkpoint
              ? Icons.emoji_events_rounded
              : Icons.check_rounded,
          PathNodeState.current => widget.checkpoint
              ? Icons.flag_rounded
              : Icons.star_rounded,
          PathNodeState.locked => Icons.lock_rounded,
        };

    Widget node = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _down = false),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: _nodeBox(size: size, base: base, lip: lip, icon: icon, iconColor: iconColor),
      ),
    );

    // The START bubble floats above the node instead of pushing it down, so
    // the trail always runs exactly through the centre of the circle.
    if (_isCurrent && widget.showStartBubble) {
      node = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          node,
          Positioned(
            top: -38,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _ensurePulse(),
                builder: (BuildContext context, Widget? child) =>
                    Transform.translate(
                  offset: Offset(0, -2 - 3 * _ensurePulse().value),
                  child: child,
                ),
                child: _StartBubble(color: widget.palette.base),
              ),
            ),
          ),
        ],
      );
    }

    final String? tip = widget.tooltip;
    if (tip != null) {
      node = Tooltip(message: tip, child: node);
    }
    return node;
  }

  Widget _nodeBox({
    required double size,
    required Color base,
    required Color lip,
    required IconData icon,
    required Color iconColor,
  }) {
    return SizedBox(
      width: size + 40,
      height: size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (_isCurrent) _Halo(pulse: _ensurePulse(), color: base, size: size),
          AnimatedScale(
            scale: _down ? 0.94 : 1,
            duration: RitualMotion.press,
            curve: Curves.easeOut,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: base,
                gradient: _isLocked
                    ? null
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color.lerp(base, Colors.white, 0.16)!,
                          base,
                        ],
                      ),
                border: Border.all(color: lip, width: 2),
                boxShadow: lipShadow(lip, depth: _isCurrent ? 7 : 6),
              ),
              child: Icon(icon, size: size * 0.44, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// The breathing rings behind the current node: a static hairline and a disc
/// that swells and fades with the pulse.
class _Halo extends StatelessWidget {
  const _Halo({required this.pulse, required this.color, required this.size});

  final AnimationController pulse;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (BuildContext context, Widget? _) {
        final double v = Curves.easeInOut.transform(pulse.value);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size + 22,
              height: size + 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.28),
                  width: 2.5,
                ),
              ),
            ),
            Container(
              width: size + 8 + 30 * v,
              height: size + 8 + 30 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.20 * (1 - v * 0.85)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StartBubble extends StatelessWidget {
  const _StartBubble({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
        boxShadow: lipShadow(color.withValues(alpha: 0.35), depth: 2),
      ),
      child: Text(
        'START',
        style: AppText.label.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}

/// The trail segment that runs behind the nodes: a single smooth S-curve
/// painted from the top of the row, through the node centre, to the bottom.
///
/// Passing the three x-offsets in means consecutive rows always meet at the
/// same coordinate, so the path reads as one continuous ribbon without
/// measuring the whole scroll view.
class PathTrail extends StatelessWidget {
  const PathTrail({
    super.key,
    required this.previousDx,
    required this.dx,
    required this.nextDx,
    required this.color,
    this.strokeWidth = 10,
  });

  final double previousDx;
  final double dx;
  final double nextDx;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _TrailPainter(
            previousDx: previousDx,
            dx: dx,
            nextDx: nextDx,
            color: color,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.previousDx,
    required this.dx,
    required this.nextDx,
    required this.color,
    required this.strokeWidth,
  });

  final double previousDx;
  final double dx;
  final double nextDx;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double h = size.height;
    final double topX = cx + (previousDx + dx) / 2;
    final double midX = cx + dx;
    final double bottomX = cx + (dx + nextDx) / 2;

    final Path path = Path()
      ..moveTo(topX, 0)
      ..cubicTo(topX, h * 0.22, midX, h * 0.28, midX, h * 0.5)
      ..cubicTo(midX, h * 0.72, bottomX, h * 0.78, bottomX, h);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.previousDx != previousDx ||
      oldDelegate.dx != dx ||
      oldDelegate.nextDx != nextDx;
}

/// Colored unit header band above a group of nodes on the path.
class UnitBand extends StatelessWidget {
  const UnitBand({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.unitNumber,
    this.lessonCount,
  });

  final UnitPalette palette;
  final String title;
  final String subtitle;

  /// 0..1 completed-lessons ratio for this unit.
  final double progress;
  final int? unitNumber;
  final int? lessonCount;

  bool get _complete => progress >= 1;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = <String>[
      if (unitNumber != null) 'UNIT $unitNumber',
      if (lessonCount != null) '$lessonCount LESSONS',
    ];
    final String? overline = parts.isEmpty ? null : parts.join('  ·  ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: palette.base,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(palette.base, Colors.white, 0.14)!,
            palette.base,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: lipShadow(palette.lip, depth: 4),
        border: Border.all(color: palette.lip, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (overline != null) ...<Widget>[
                      Text(
                        overline,
                        style: AppText.label.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Text(
                      title.toUpperCase(),
                      style: AppText.title.copyWith(color: Colors.white),
                    ),
                    if (subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppText.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_complete) ...<Widget>[
                const SizedBox(width: 10),
                const _CrownChip(),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _UnitProgressBar(progress: progress, complete: _complete),
        ],
      ),
    );
  }
}

class _UnitProgressBar extends StatelessWidget {
  const _UnitProgressBar({required this.progress, required this.complete});

  final double progress;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(color: Colors.white.withValues(alpha: 0.32)),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 650),
              curve: RitualMotion.standardCurve,
              builder: (BuildContext context, double value, Widget? _) =>
                  FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: ColoredBox(
                  color: complete
                      ? RitualColors.amberTint
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrownChip extends StatelessWidget {
  const _CrownChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.workspace_premium_rounded, size: 15, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'DONE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

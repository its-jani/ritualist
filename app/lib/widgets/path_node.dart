import 'package:flutter/material.dart';

import '../theme.dart';

enum PathNodeState { done, current, locked }

/// One circular lesson node on the path: completed (check), current (star,
/// gently pulsing, optional START bubble) or locked (padlock). The lip shadow
/// gives the node the same pressed-3D quality as the buttons.
class PathNode extends StatefulWidget {
  const PathNode({
    super.key,
    required this.state,
    required this.palette,
    this.onTap,
    this.iconOverride,
    this.tooltip,
  });

  final PathNodeState state;
  final UnitPalette palette;
  final VoidCallback? onTap;
  final IconData? iconOverride;
  final String? tooltip;

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  /// Lazily created so non-current nodes never build a ticker at all - and
  /// so `dispose()` can never accidentally construct one on a deactivated
  /// element (which would trip the ancestor-lookup assertion).
  AnimationController _ensurePulse() => _pulse ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );

  @override
  void initState() {
    super.initState();
    if (widget.state == PathNodeState.current) {
      _ensurePulse().repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PathNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final AnimationController? pulse = _pulse;
    if (widget.state == PathNodeState.current) {
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
    final bool current = widget.state == PathNodeState.current;
    final double size = current ? 74 : 66;
    final Color base = locked ? const Color(0xFFE5E5E5) : widget.palette.base;
    final Color lip = locked ? const Color(0xFFD2D2D2) : widget.palette.lip;
    final IconData icon = widget.iconOverride ??
        switch (widget.state) {
          PathNodeState.done => Icons.check_rounded,
          PathNodeState.current => Icons.star_rounded,
          PathNodeState.locked => Icons.lock_rounded,
        };
    final Color iconColor = locked ? const Color(0xFFAFAFAF) : Colors.white;

    Widget node = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (current)
              AnimatedBuilder(
                animation: _ensurePulse(),
                builder: (context, child) {
                  final AnimationController pulse = _ensurePulse();
                  return Transform.translate(
                    offset: Offset(0, -3 - 3 * pulse.value),
                    child: child,
                  );
                },
                child: _StartBubble(color: widget.palette.base),
              ),
            if (current) const SizedBox(height: 10),
            ScaleTransition(
              scale: current
                  ? Tween<double>(begin: 1.0, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _ensurePulse(),
                        curve: Curves.easeInOut,
                      ),
                    )
                  : const AlwaysStoppedAnimation<double>(1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: base,
                  shape: BoxShape.circle,
                  boxShadow: lipShadow(lip, depth: 6),
                ),
                child: Icon(icon, size: size * 0.46, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );

    final tip = widget.tooltip;
    if (tip != null) {
      node = Tooltip(message: tip, child: node);
    }
    return node;
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
      ),
      child: Text(
        'START',
        style: AppText.label.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}

/// Colored unit header band above a group of nodes on the path.
class UnitBand extends StatelessWidget {
  const UnitBand({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final UnitPalette palette;
  final String title;
  final String subtitle;

  /// 0..1 completed-lessons ratio for this unit.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(16),
        boxShadow: lipShadow(palette.lip, depth: 4),
        border: Border.all(color: palette.lip, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: AppText.label.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppText.title.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ColoredBox(color: Colors.white.withValues(alpha: 0.35)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: const ColoredBox(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

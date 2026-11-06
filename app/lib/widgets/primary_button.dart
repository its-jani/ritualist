import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion.dart';

enum RitualButtonSize { regular, small }

enum RitualButtonVariant {
  /// Filled brand button (Owl Green #58cc02).
  primary,

  /// White button with Swan border and blue label (secondary action).
  secondary,

  /// Filled Cardinal Red button (destructive / wrong-answer continue).
  danger,

  /// Text-only, transparent.
  ghost,
}

/// The signature chunky button: a rounded surface floating on a darker "lip"
/// edge that compresses when pressed. Canonical Duolingo parity — 16px
/// radius, 4px bottom lip ([RitualShape.lipDepth]), press translates the
/// surface down by the full lip depth so the shadow collapses to zero.
class RitualButton extends StatefulWidget {
  const RitualButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RitualButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.size = RitualButtonSize.regular,
  });

  final String label;
  final VoidCallback? onPressed;
  final RitualButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final RitualButtonSize size;

  @override
  State<RitualButton> createState() => _RitualButtonState();
}

class _RitualButtonState extends State<RitualButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final (Color base, Color lip, Color fg, Border? border) = switch (widget.variant) {
      RitualButtonVariant.primary => (
          RitualColors.jade,
          RitualColors.jadeLip,
          Colors.white,
          null,
        ),
      RitualButtonVariant.secondary => (
          Colors.white,
          RitualColors.line,
          RitualColors.sky,
          Border.all(color: RitualColors.line, width: RitualShape.borderWidth),
        ),
      RitualButtonVariant.danger => (
          RitualColors.rose,
          RitualColors.roseLip,
          Colors.white,
          null,
        ),
      RitualButtonVariant.ghost => (
          Colors.transparent,
          Colors.transparent,
          RitualColors.jade,
          null,
        ),
    };

    final resolvedBase = _enabled ? base : RitualColors.swanMuted;
    final resolvedLip = _enabled ? lip : RitualColors.swanMutedLip;
    final resolvedFg = _enabled ? fg : RitualColors.faint;
    final resolvedBorder = _enabled ? border : null;
    final height = widget.size == RitualButtonSize.small ? 44.0 : 54.0;
    final fontSize =
        widget.size == RitualButtonSize.small ? 15.0 : 17.0;
    final isGhost = widget.variant == RitualButtonVariant.ghost;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(widget.icon, size: fontSize + 4, color: resolvedFg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label.toUpperCase(),
            style: AppText.button.copyWith(
              fontSize: fontSize,
              color: resolvedFg,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (isGhost) {
      return TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(widget.expand ? double.infinity : 0, height),
          foregroundColor: RitualColors.jade,
        ),
        child: content,
      );
    }

    // The lip the surface sinks into. 4px is the canonical depth declared in
    // [RitualShape.lipDepth]; on press the surface translates down by this
    // amount so the lip visually collapses to zero - the gamepad-button
    // affordance from the reference design system.
    const double lipDepth = RitualShape.lipDepth;

    final surface = AnimatedPositioned(
      duration: RitualMotion.press,
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      top: _down && _enabled ? lipDepth : 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedBase,
          borderRadius: BorderRadius.circular(RitualShape.radius),
          border: resolvedBorder,
        ),
        child: Center(child: content),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: _enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: SizedBox(
          width: widget.expand ? double.infinity : null,
          height: height + lipDepth,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: lipDepth,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: resolvedLip,
                    borderRadius: BorderRadius.circular(RitualShape.radius),
                  ),
                ),
              ),
              surface,
            ],
          ),
        ),
      ),
    );
  }
}

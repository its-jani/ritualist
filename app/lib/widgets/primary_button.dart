import 'package:flutter/material.dart';

import '../theme.dart';

enum RitualButtonSize { regular, small }

enum RitualButtonVariant {
  /// Filled brand button (unguessable green).
  primary,

  /// White button with border, blue text (secondary action).
  secondary,

  /// Filled red button (destructive / wrong-answer continue).
  danger,

  /// Text-only, transparent.
  ghost,
}

/// The signature chunky button: a rounded surface floating on a darker "lip"
/// edge that compresses when pressed (the interaction the REA study measured
/// at lip-width 4px; our own palette and radii).
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
          Border.all(color: RitualColors.line, width: 2),
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

    final resolvedBase = _enabled ? base : const Color(0xFFE5E5E5);
    final resolvedLip = _enabled ? lip : const Color(0xFFD8D8D8);
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

    final surface = AnimatedPositioned(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      top: _down && _enabled ? 3 : 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedBase,
          borderRadius: BorderRadius.circular(14),
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
          height: height + 3,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 3,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: resolvedLip,
                    borderRadius: BorderRadius.circular(14),
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

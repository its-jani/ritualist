import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';
import 'motion.dart';

/// Multiple-choice exercise: a column of chunky option tiles.
///
/// Idle tiles are white keys sitting on a hairline lip; the picked tile
/// presses down and lifts into jade; once checked, the correct tile turns
/// green and a wrong pick turns red, both with a small scale pop. That
/// immediate right/wrong signal is the core of the learning loop
/// (see docs/rea-duolingo-findings.md §4), rendered with our own palette.
class McqView extends StatelessWidget {
  const McqView({
    super.key,
    required this.exercise,
    required this.selectedIndex,
    required this.onSelect,
    this.locked = false,
  });

  final MultipleChoiceExercise exercise;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  /// True while the feedback panel is showing: tiles get graded colors and
  /// stop accepting taps.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final List<AnswerOption> options = exercise.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          _OptionTile(
            index: i,
            option: options[i],
            state: _stateFor(i),
            onTap: locked ? null : () => onSelect(i),
          ),
          if (i != options.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  _TileState _stateFor(int i) {
    if (!locked) {
      return i == selectedIndex ? _TileState.selected : _TileState.idle;
    }
    if (i == exercise.correctIndex) {
      return _TileState.correct;
    }
    if (i == selectedIndex) {
      return _TileState.wrong;
    }
    return _TileState.faded;
  }
}

enum _TileState { idle, selected, correct, wrong, faded }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.option,
    required this.state,
    required this.onTap,
  });

  final int index;
  final AnswerOption option;
  final _TileState state;
  final VoidCallback? onTap;

  /// The A/B/C/D key cap - a small scan affordance mobile apps use instead of
  /// long option rows.
  String get _letter => String.fromCharCode(0x41 + index);

  @override
  Widget build(BuildContext context) {
    final (
      Color bg,
      Color border,
      Color badgeBg,
      Color badgeFg,
      IconData? icon,
      Color iconColor,
    ) = switch (state) {
      _TileState.idle => (
          RitualColors.card,
          RitualColors.line,
          RitualColors.bg,
          RitualColors.subInk,
          null,
          RitualColors.subInk,
        ),
      _TileState.selected => (
          RitualColors.jadeTint,
          RitualColors.jade,
          RitualColors.jade,
          Colors.white,
          Icons.radio_button_checked_rounded,
          RitualColors.jade,
        ),
      _TileState.correct => (
          RitualColors.correctTint,
          RitualColors.correct,
          RitualColors.correct,
          Colors.white,
          Icons.check_circle_rounded,
          RitualColors.correctInk,
        ),
      _TileState.wrong => (
          RitualColors.roseTint,
          RitualColors.rose,
          RitualColors.rose,
          Colors.white,
          Icons.cancel_rounded,
          RitualColors.roseInk,
        ),
      _TileState.faded => (
          RitualColors.card,
          RitualColors.line,
          RitualColors.bg,
          RitualColors.faint,
          null,
          RitualColors.subInk,
        ),
    };
    final bool faded = state == _TileState.faded;
    final bool graded =
        state == _TileState.correct || state == _TileState.wrong;

    return AnimatedOpacity(
      duration: RitualMotion.fast,
      opacity: faded ? 0.45 : 1,
      child: AnimatedScale(
        // A tiny pop on grading: enough to feel like a stamped result.
        scale: graded ? 1.015 : 1,
        duration: RitualMotion.fast,
        curve: RitualMotion.pop,
        child: PressableCard(
          onTap: onTap,
          color: bg,
          border: Border.all(color: border, width: graded ? 2.5 : 2),
          shadowColor: faded ? RitualColors.line : border,
          depth: 4,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          semanticLabel: option.text,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _KeyCap(letter: _letter, background: badgeBg, foreground: badgeFg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(option.text, style: AppText.body),
                    if (option.arabic != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            option.arabic!,
                            style: AppText.arabic.copyWith(fontSize: 20),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: RitualMotion.fast,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(
                  scale: animation.drive(Tween<double>(begin: 0.4, end: 1)),
                  child: child,
                ),
                child: icon == null
                    ? const SizedBox.shrink(key: ValueKey<String>('no-icon'))
                    : Padding(
                        key: ValueKey<IconData>(icon),
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rounded A/B/C/D cap on the left of an option.
class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.letter,
    required this.background,
    required this.foreground,
  });

  final String letter;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: RitualMotion.fast,
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: foreground.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

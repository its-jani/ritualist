import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';

/// Multiple-choice exercise: a column of chunky option tiles.
///
/// Idle tiles are white with a hairline border; the picked tile lifts into
/// jade; once checked, the correct tile turns green and a wrong pick turns
/// red. That immediate right/wrong signal is the core of the learning loop
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
    required this.option,
    required this.state,
    required this.onTap,
  });

  final AnswerOption option;
  final _TileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, IconData? icon, Color iconColor) =
        switch (state) {
      _TileState.idle => (Colors.white, RitualColors.line, null, RitualColors.subInk),
      _TileState.selected => (
          RitualColors.jadeTint,
          RitualColors.jade,
          Icons.radio_button_checked_rounded,
          RitualColors.jade,
        ),
      _TileState.correct => (
          RitualColors.correctTint,
          RitualColors.correctInk,
          Icons.check_circle_rounded,
          RitualColors.correctInk,
        ),
      _TileState.wrong => (
          RitualColors.roseTint,
          RitualColors.rose,
          Icons.cancel_rounded,
          RitualColors.roseInk,
        ),
      _TileState.faded => (
          Colors.white,
          RitualColors.line,
          null,
          RitualColors.subInk,
        ),
    };
    final bool faded = state == _TileState.faded;

    final Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
        boxShadow: state == _TileState.idle || faded
            ? lipShadow(RitualColors.line, depth: 3)
            : null,
      ),
      child: Row(
        children: <Widget>[
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
          if (icon != null) ...<Widget>[
            const SizedBox(width: 10),
            Icon(icon, color: iconColor, size: 24),
          ],
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Opacity(opacity: faded ? 0.55 : 1, child: tile),
      ),
    );
  }
}

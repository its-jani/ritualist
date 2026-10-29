import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';
import 'motion.dart';

/// Matching exercise (Arabic term -> English meaning).
///
/// Interaction: tap a tile on the left, then its match on the right. A correct
/// pairing locks both tiles green with a small pop; a wrong pairing flashes red
/// and counts as a miss (matching never costs a heart - see
/// docs/rea-duolingo-findings.md §4). Once every pair is matched the widget
/// auto-submits via [onCompleted].
class MatchView extends StatefulWidget {
  const MatchView({
    super.key,
    required this.exercise,
    required this.seed,
    required this.onCompleted,
    this.locked = false,
  });

  final MatchPairsExercise exercise;
  final int seed;

  /// Called once all pairs are matched; [missed] is the wrong-attempt count.
  final ValueChanged<int> onCompleted;

  /// True while the feedback panel is showing.
  final bool locked;

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  int? _selectedLeft;
  final Set<int> _matchedLeft = <int>{};
  final Set<int> _matchedRight = <int>{};
  int _missed = 0;
  int? _flashLeft;
  int? _flashRight;
  Timer? _flashTimer;
  Timer? _completeTimer;

  MatchPairsExercise get _exercise => widget.exercise;

  @override
  void dispose() {
    _flashTimer?.cancel();
    _completeTimer?.cancel();
    super.dispose();
  }

  void _tapLeft(int i) {
    if (widget.locked || _matchedLeft.contains(i)) {
      return;
    }
    setState(() => _selectedLeft = _selectedLeft == i ? null : i);
  }

  void _tapRight(int r) {
    final int? left = _selectedLeft;
    if (widget.locked || _matchedRight.contains(r) || left == null) {
      return;
    }
    if (_exercise.isMatchCorrect(left, r)) {
      setState(() {
        _matchedLeft.add(left);
        _matchedRight.add(r);
        _selectedLeft = null;
      });
      if (_matchedLeft.length == _exercise.pairs.length) {
        _completeTimer = Timer(const Duration(milliseconds: 450), () {
          if (mounted) {
            widget.onCompleted(_missed);
          }
        });
      }
    } else {
      setState(() {
        _missed++;
        _flashLeft = left;
        _flashRight = r;
        _selectedLeft = null;
      });
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 550), () {
        if (mounted) {
          setState(() {
            _flashLeft = null;
            _flashRight = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MatchPair> pairs = _exercise.pairs;
    final List<int> rightOrder = matchRightDisplayOrder(_exercise, widget.seed);
    final int matched = _matchedLeft.length;

    final List<Widget> leftTiles = <Widget>[
      for (int i = 0; i < pairs.length; i++)
        _PairTile(
          text: pairs[i].left,
          arabic: pairs[i].leftArabic,
          side: _TileSide.left,
          state: _stateFor(
            matched: _matchedLeft.contains(i),
            selected: _selectedLeft == i,
            flashing: _flashLeft == i,
          ),
          onTap: widget.locked ? null : () => _tapLeft(i),
        ),
    ];
    final List<Widget> rightTiles = <Widget>[
      for (final int i in rightOrder)
        _PairTile(
          text: pairs[i].right,
          arabic: pairs[i].rightArabic,
          side: _TileSide.right,
          state: _stateFor(
            matched: _matchedRight.contains(i),
            selected: false,
            flashing: _flashRight == i,
          ),
          onTap: widget.locked ? null : () => _tapRight(i),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _gapped(leftTiles)),
            const SizedBox(width: 12),
            Expanded(child: _gapped(rightTiles)),
          ],
        ),
        const SizedBox(height: 16),
        _MatchStatus(matched: matched, total: pairs.length, missed: _missed),
      ],
    );
  }

  /// Stacks tiles in a stretched column with uniform 10px gaps.
  static Widget _gapped(List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          tiles[i],
          if (i != tiles.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  _PairState _stateFor({
    required bool matched,
    required bool selected,
    required bool flashing,
  }) {
    if (matched) {
      return _PairState.matched;
    }
    if (flashing) {
      return _PairState.wrong;
    }
    if (selected) {
      return _PairState.selected;
    }
    return _PairState.idle;
  }
}

/// Live status line: pairs cleared vs total, plus the running miss count.
class _MatchStatus extends StatelessWidget {
  const _MatchStatus({
    required this.matched,
    required this.total,
    required this.missed,
  });

  final int matched;
  final int total;
  final int missed;

  @override
  Widget build(BuildContext context) {
    final bool started = matched > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          started ? Icons.check_circle_rounded : Icons.touch_app_rounded,
          size: 16,
          color: started ? RitualColors.correctInk : RitualColors.subInk,
        ),
        const SizedBox(width: 6),
        Text(
          '$matched of $total matched',
          style: AppText.caption.copyWith(
            color: started ? RitualColors.correctInk : RitualColors.subInk,
          ),
        ),
        if (missed > 0) ...<Widget>[
          const SizedBox(width: 12),
          const Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: RitualColors.roseInk,
          ),
          const SizedBox(width: 4),
          Text(
            '$missed wrong',
            style: AppText.caption.copyWith(color: RitualColors.roseInk),
          ),
        ],
      ],
    );
  }
}

enum _TileSide { left, right }

enum _PairState { idle, selected, matched, wrong }

class _PairTile extends StatelessWidget {
  const _PairTile({
    required this.text,
    required this.arabic,
    required this.side,
    required this.state,
    required this.onTap,
  });

  final String text;
  final String? arabic;
  final _TileSide side;
  final _PairState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border) = switch (state) {
      _PairState.idle => (RitualColors.card, RitualColors.line),
      _PairState.selected => (RitualColors.jadeTint, RitualColors.jade),
      _PairState.matched => (
          RitualColors.correctTint,
          RitualColors.correct,
        ),
      _PairState.wrong => (RitualColors.roseTint, RitualColors.rose),
    };
    final bool matched = state == _PairState.matched;
    final bool wrong = state == _PairState.wrong;
    final TextStyle textStyle = AppText.body.copyWith(
      fontSize: 15,
      color: matched ? RitualColors.correctInk : RitualColors.ink,
    );

    return AnimatedScale(
      // Wrong pairs flinch; matched pairs settle with a tiny lift.
      scale: wrong ? 0.965 : (matched ? 1.02 : 1),
      duration: RitualMotion.fast,
      curve: RitualMotion.pop,
      child: PressableCard(
        onTap: onTap,
        color: bg,
        border: Border.all(color: border, width: 2),
        shadowColor: state == _PairState.idle ? RitualColors.line : border,
        depth: 3,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        semanticLabel: text,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(text, style: textStyle),
              if (arabic != null) ...<Widget>[
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: side == _TileSide.left
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Text(
                      arabic!,
                      style: AppText.arabic.copyWith(
                        fontSize: 18,
                        color: matched
                            ? RitualColors.correctInk
                            : RitualColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

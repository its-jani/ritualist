import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../theme.dart';

/// Step-ordering exercise (e.g. "Arrange the correct sequence of Wudu steps").
///
/// The learner taps steps from the shuffled pool into numbered slots. The
/// pool order comes from [stepDisplayOrder] so it is stable across restarts
/// of the same exercise. After checking, each slot is graded green/red and
/// the feedback panel shows the correct sequence.
class OrderView extends StatelessWidget {
  const OrderView({
    super.key,
    required this.exercise,
    required this.seed,
    required this.placed,
    required this.onChanged,
    this.locked = false,
  });

  final OrderStepsExercise exercise;
  final int seed;

  /// Original step indices in the order the learner placed them.
  final List<int> placed;

  final ValueChanged<List<int>> onChanged;

  /// True while the feedback panel is showing.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final List<int> displayOrder = stepDisplayOrder(exercise, seed);
    final List<int> pool =
        displayOrder.where((i) => !placed.contains(i)).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int p = 0; p < placed.length; p++) ...<Widget>[
          _SlotTile(
            number: p + 1,
            option: exercise.steps[placed[p]],
            graded: locked
                ? (placed[p] == p ? _SlotGrade.correct : _SlotGrade.wrong)
                : _SlotGrade.none,
            onTap: locked ? null : () => _removeAt(p),
          ),
          const SizedBox(height: 10),
        ],
        if (!locked && placed.length < exercise.steps.length) ...<Widget>[
          _EmptySlot(number: placed.length + 1),
          const SizedBox(height: 10),
        ],
        if (!locked && placed.isEmpty) ...<Widget>[
          const SizedBox(height: 4),
          const Text(
            'Tap the steps below in the correct order.',
            style: AppText.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        if (pool.isNotEmpty) ...<Widget>[
          const Divider(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final int i in pool)
                _PoolTile(
                  option: exercise.steps[i],
                  onTap: locked ? null : () => _append(i),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _append(int stepIndex) => onChanged(<int>[...placed, stepIndex]);

  void _removeAt(int position) {
    final next = List<int>.of(placed)..removeAt(position);
    onChanged(next);
  }
}

enum _SlotGrade { none, correct, wrong }

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.number,
    required this.option,
    required this.graded,
    required this.onTap,
  });

  final int number;
  final AnswerOption option;
  final _SlotGrade graded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color badgeBg) = switch (graded) {
      _SlotGrade.none => (
          Colors.white,
          RitualColors.jade,
          RitualColors.jade,
        ),
      _SlotGrade.correct => (
          RitualColors.correctTint,
          RitualColors.correctInk,
          RitualColors.correctInk,
        ),
      _SlotGrade.wrong => (
          RitualColors.roseTint,
          RitualColors.rose,
          RitualColors.roseInk,
        ),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _NumberBadge(number: number, color: badgeBg),
              const SizedBox(width: 10),
              Expanded(child: _StepText(option: option)),
              if (graded == _SlotGrade.correct)
                const Icon(Icons.check_rounded,
                    size: 20, color: RitualColors.correctInk)
              else if (graded == _SlotGrade.wrong)
                const Icon(Icons.close_rounded,
                    size: 20, color: RitualColors.roseInk),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RitualColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RitualColors.line, width: 2),
      ),
      child: Row(
        children: <Widget>[
          _NumberBadge(number: number, color: RitualColors.faint),
          const SizedBox(width: 10),
          const Text('Next step goes here', style: AppText.caption),
        ],
      ),
    );
  }
}

class _PoolTile extends StatelessWidget {
  const _PoolTile({required this.option, required this.onTap});

  final AnswerOption option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RitualColors.line, width: 2),
            boxShadow: lipShadow(RitualColors.line, depth: 3),
          ),
          child: _StepText(option: option),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  const _StepText({required this.option});

  final AnswerOption option;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(option.text, style: AppText.body.copyWith(fontSize: 15)),
        if (option.arabic != null) ...<Widget>[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                option.arabic!,
                style: AppText.arabic.copyWith(fontSize: 18),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

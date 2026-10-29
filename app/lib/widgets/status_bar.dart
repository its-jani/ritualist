import 'package:flutter/material.dart';

import '../theme.dart';
import 'celebrate.dart';
import 'motion.dart';

/// Top status row: streak flame, hearts and today's XP vs daily goal.
///
/// Numbers animate implicitly on change (no extra tickers); the goal ring
/// sweeps to its value and flips to amber with a check once the target is
/// met, so the daily loop closes visibly.
class StatusBar extends StatelessWidget {
  const StatusBar({
    super.key,
    required this.streak,
    required this.hearts,
    required this.xpToday,
    required this.dailyGoalProgress,
    required this.goalReached,
    this.goalXp = 20,
  });

  final int streak;
  final int hearts;
  final int xpToday;
  final double dailyGoalProgress;
  final bool goalReached;
  final int goalXp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StatChip(
          leading: StreakFlame(streak: streak, size: 24),
          text: '$streak',
          textColor: streak > 0 ? RitualColors.amberLip : RitualColors.faint,
        ),
        const Spacer(),
        _StatChip(
          leading: const Icon(
            Icons.favorite_rounded,
            size: 22,
            color: RitualColors.rose,
          ),
          text: '$hearts',
          textColor: RitualColors.roseInk,
        ),
        const SizedBox(width: 14),
        _XpChip(
          xpToday: xpToday,
          progress: dailyGoalProgress,
          reached: goalReached,
          goalXp: goalXp,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.leading,
    required this.text,
    required this.textColor,
  });

  final Widget leading;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        leading,
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: RitualMotion.standard,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(
            scale: animation.drive(Tween<double>(begin: 1.4, end: 1)),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Text(
            text,
            key: ValueKey<String>(text),
            style: AppText.button.copyWith(color: textColor, fontSize: 17),
          ),
        ),
      ],
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({
    required this.xpToday,
    required this.progress,
    required this.reached,
    required this.goalXp,
  });

  final int xpToday;
  final double progress;
  final bool reached;
  final int goalXp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 26,
          height: 26,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 700),
                curve: RitualMotion.standardCurve,
                builder: (BuildContext context, double value, Widget? _) =>
                    SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 2.6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: RitualColors.line,
                    color: reached ? RitualColors.amber : RitualColors.jade,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: RitualMotion.standard,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(
                  scale: animation.drive(Tween<double>(begin: 0.4, end: 1)),
                  child: child,
                ),
                child: Icon(
                  reached ? Icons.check_rounded : Icons.bolt_rounded,
                  key: ValueKey<bool>(reached),
                  size: 16,
                  color: reached ? RitualColors.amberLip : RitualColors.faint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$xpToday',
          style: AppText.button.copyWith(
            color: reached ? RitualColors.amberLip : RitualColors.subInk,
            fontSize: 17,
          ),
        ),
        Text('/$goalXp', style: AppText.caption),
      ],
    );
  }
}

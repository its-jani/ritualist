import 'package:flutter/material.dart';

import '../theme.dart';

/// Top status row: streak flame, hearts and today's XP vs daily goal.
/// Numbers animate implicitly on change (rebuild only, no tickers).
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
          icon: Icons.local_fire_department_rounded,
          iconColor: streak > 0 ? RitualColors.amber : RitualColors.faint,
          text: '$streak',
          textColor: streak > 0 ? RitualColors.amberLip : RitualColors.faint,
        ),
        const Spacer(),
        _StatChip(
          icon: Icons.favorite_rounded,
          iconColor: RitualColors.rose,
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
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => ScaleTransition(
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
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 2.6,
                strokeCap: StrokeCap.round,
                backgroundColor: RitualColors.line,
                color: reached ? RitualColors.amber : RitualColors.jade,
              ),
              Icon(
                Icons.bolt_rounded,
                size: 16,
                color: reached ? RitualColors.amber : RitualColors.faint,
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

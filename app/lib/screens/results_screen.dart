import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../state/sfx.dart';
import '../theme.dart';
import '../widgets/celebrate.dart';
import '../widgets/motion.dart';
import '../widgets/primary_button.dart';
import 'lesson_screen.dart';

/// End-of-session summary: the reward moment.
///
/// Everything here is the retention loop made visible - one burst of
/// confetti, a medallion, the XP tally counting up, the daily-goal ring
/// filling and the streak flame still alive - plus a way back to practice when
/// hearts ran out.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.state,
    required this.spec,
    required this.result,
  });

  final AppState state;
  final SessionSpec spec;
  final SessionResult result;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _opening = false;

  bool get _passed => widget.result.passed && !widget.result.abandoned;

  bool get _isReview => widget.spec.kind == SessionKind.review;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_passed ? RitualSfx.celebrate() : RitualSfx.fail());
    });
  }

  @override
  Widget build(BuildContext context) {
    final SessionResult r = widget.result;
    final AppState s = widget.state;

    final String title = _passed
        ? (_isReview ? 'Practice complete!' : 'Lesson complete!')
        : 'Out of hearts';
    final String subtitle = _passed
        ? (_isReview
            ? 'Review keeps what you learned from fading.'
            : 'Come back tomorrow to keep the streak alive.')
        : 'You can practice to earn hearts back right away.';

    final bool heartRestored =
        _passed && _isReview && r.heartsRemaining < s.config.maxHearts;
    final bool perfect = _passed && r.mistakes == 0;

    return Scaffold(
      backgroundColor: RitualColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              if (_passed)
                                const CelebrationBurst(radius: 116),
                              PopIn(
                                beginScale: 0.55,
                                beginOffset: Offset.zero,
                                child: _Medal(passed: _passed),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            style: AppText.display,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: AppText.bodyMuted,
                            textAlign: TextAlign.center,
                          ),
                          if (perfect) ...<Widget>[
                            const SizedBox(height: 10),
                            PopIn(
                              delay: const Duration(milliseconds: 260),
                              child: _PerfectChip(
                                bonusXp: s.config.perfectBonusXp,
                              ),
                            ),
                          ],
                          if (heartRestored) ...<Widget>[
                            const SizedBox(height: 10),
                            const _HeartRestoredNote(),
                          ],
                          const SizedBox(height: 22),
                          PopIn(
                            delay: const Duration(milliseconds: 110),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _GoalCard(
                                    xpToday: s.xpToday,
                                    goalXp: s.progress.dailyGoalXp,
                                    progress: s.dailyGoalProgress,
                                    reached: s.goalReachedToday,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StreakCard(streak: s.streak),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          PopIn(
                            delay: const Duration(milliseconds: 200),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.bolt_rounded,
                                    iconColor: RitualColors.amber,
                                    value: BouncyCounter(
                                      value: r.xpEarned,
                                      prefix: '+',
                                      style: AppText.title,
                                    ),
                                    label: 'XP earned',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.track_changes_rounded,
                                    iconColor: RitualColors.jade,
                                    value: BouncyCounter(
                                      value: (r.accuracy * 100).round(),
                                      suffix: '%',
                                      style: AppText.title,
                                    ),
                                    label: 'Accuracy',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          PopIn(
                            delay: const Duration(milliseconds: 290),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.local_fire_department_rounded,
                                    iconColor: RitualColors.sun,
                                    value: BouncyCounter(
                                      value: r.bestCombo,
                                      style: AppText.title,
                                    ),
                                    label: 'Best combo',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.schedule_rounded,
                                    iconColor: RitualColors.sky,
                                    value: Text(
                                      _formatDuration(r.duration),
                                      style: AppText.title,
                                    ),
                                    label: 'Time',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RitualButton(
                    label: 'Continue',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (!_passed &&
                      widget.state.lessonsCompleted > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    RitualButton(
                      label: 'Practice to earn a heart',
                      variant: RitualButtonVariant.secondary,
                      onPressed: _practice,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _practice() async {
    if (_opening) {
      return;
    }
    _opening = true;
    try {
      final SessionSpec? spec = await widget.state.buildReviewSession();
      if (!mounted) {
        return;
      }
      if (spec == null || spec.items.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LessonScreen(state: widget.state, spec: spec),
        ),
      );
    } finally {
      _opening = false;
    }
  }

  static String _formatDuration(Duration d) {
    final int minutes = d.inMinutes;
    final int seconds = d.inSeconds % 60;
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }
}

/// The session medallion: two concentric discs on a lip, so it reads as a
/// physical medal rather than an icon on a circle.
class _Medal extends StatelessWidget {
  const _Medal({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    final Color bg = passed ? RitualColors.amberTint : RitualColors.roseTint;
    final Color fg = passed ? RitualColors.amberLip : RitualColors.rose;
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withValues(alpha: 0.45), width: 3),
        boxShadow: lipShadow(fg.withValues(alpha: 0.35), depth: 6),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: fg.withValues(alpha: 0.25), width: 2),
          ),
          child: Icon(
            passed ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
            size: 46,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Daily-goal ring plus the tallies that frame the next session.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.xpToday,
    required this.goalXp,
    required this.progress,
    required this.reached,
  });

  final int xpToday;
  final int goalXp;
  final double progress;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Row(
        children: <Widget>[
          DailyGoalRing(
            progress: progress,
            size: 52,
            strokeWidth: 6,
            reached: reached,
            child: Icon(
              reached ? Icons.check_rounded : Icons.bolt_rounded,
              size: 20,
              color: reached ? RitualColors.amberLip : RitualColors.jade,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  reached ? 'Goal reached' : 'Daily goal',
                  style: AppText.caption.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$xpToday / $goalXp XP',
                  style: AppText.title.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Row(
        children: <Widget>[
          StreakFlame(streak: streak, size: 26, showBadge: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Day streak',
                  style: AppText.caption.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$streak ${streak == 1 ? 'day' : 'days'}',
                  style: AppText.title.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfectChip extends StatelessWidget {
  const _PerfectChip({required this.bonusXp});

  final int bonusXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: RitualColors.amberTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RitualColors.amber, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: RitualColors.amberLip,
          ),
          const SizedBox(width: 6),
          Text(
            'Perfect run  ·  +$bonusXp XP',
            style: AppText.button.copyWith(
              fontSize: 13,
              color: RitualColors.amberLip,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRestoredNote extends StatelessWidget {
  const _HeartRestoredNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: RitualColors.roseTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.favorite_rounded, size: 18, color: RitualColors.rose),
          SizedBox(width: 6),
          Text(
            'A heart was restored',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: RitualColors.roseInk,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// The white lip card used by the goal/streak pair.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RitualColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RitualColors.line, width: 2),
        boxShadow: lipShadow(RitualColors.line, depth: 4),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Widget value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          value,
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

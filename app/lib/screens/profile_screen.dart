import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Profile tab: streak/XP stats, daily-goal picker, course progress, module
/// about/disclaimer and a guarded progress reset.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});

  final AppState state;

  static const Map<int, String> _goalLabels = <int, String>{
    10: 'Casual',
    20: 'Regular',
    30: 'Serious',
    50: 'Intense',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final ModuleManifest? m = state.manifest;
        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: <Widget>[
                  const Text('Profile', style: AppText.display),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double w = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          SizedBox(
                            width: w,
                            child: _StatTile(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: RitualColors.amber,
                              value: '${state.streak}',
                              label: 'Day streak',
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatTile(
                              icon: Icons.emoji_events_rounded,
                              iconColor: RitualColors.sun,
                              value: '${state.longestStreak}',
                              label: 'Longest streak',
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatTile(
                              icon: Icons.bolt_rounded,
                              iconColor: RitualColors.jade,
                              value: '${state.totalXp}',
                              label: 'Total XP',
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: _StatTile(
                              icon: Icons.school_rounded,
                              iconColor: RitualColors.sky,
                              value: '${state.lessonsCompleted}',
                              label: 'Lessons done',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle('Daily goal'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (final int xp in state.config.dailyGoalOptions)
                        _GoalChip(
                          xp: xp,
                          label: _goalLabels[xp] ?? '$xp XP',
                          selected: state.progress.dailyGoalXp == xp,
                          onTap: () => state.setDailyGoal(xp),
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle('Course progress'),
                  const SizedBox(height: 10),
                  _CourseProgressCard(state: state),
                  const SizedBox(height: 26),
                  const _SectionTitle('About'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RitualColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: RitualColors.line, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(m?.title ?? 'Ritualist',
                            style: AppText.title.copyWith(fontSize: 17)),
                        const SizedBox(height: 6),
                        Text(
                          m?.description ??
                              'Offline-first micro-learning built on a '
                                  'pluggable course engine.',
                          style: AppText.bodyMuted,
                        ),
                        if (m?.disclaimer != null) ...<Widget>[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: RitualColors.amberTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: RitualColors.amberLip,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    m!.disclaimer!,
                                    style: AppText.caption.copyWith(
                                      color: RitualColors.amberLip,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Text(
                          'Ritualist v1.0 - works fully offline, '
                          'every exercise cites its source.',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  RitualButton(
                    label: 'Reset progress',
                    variant: RitualButtonVariant.secondary,
                    size: RitualButtonSize.small,
                    onPressed: () => _confirmReset(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final bool? reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: RitualColors.rose,
          size: 38,
        ),
        title: const Text('Reset all progress?', style: AppText.title),
        content: const Text(
          'Streak, XP, hearts and lesson progress will be cleared. '
          'This cannot be undone.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          RitualButton(
            label: 'Keep my progress',
            size: RitualButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          RitualButton(
            label: 'Reset',
            variant: RitualButtonVariant.danger,
            size: RitualButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (reset == true) {
      await state.resetProgress();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppText.label);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: RitualColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RitualColors.line, width: 2),
        boxShadow: lipShadow(RitualColors.line, depth: 4),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(value, style: AppText.title.copyWith(fontSize: 18)),
                Text(
                  label,
                  style: AppText.caption.copyWith(fontSize: 12),
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

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.xp,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int xp;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? RitualColors.jade : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? RitualColors.jadeLip : RitualColors.line,
              width: 2,
            ),
            boxShadow: lipShadow(
              selected ? RitualColors.jadeLip : RitualColors.line,
              depth: 3,
            ),
          ),
          child: Column(
            children: <Widget>[
              Text(
                '$xp XP',
                style: AppText.button.copyWith(
                  fontSize: 15,
                  color: selected ? Colors.white : RitualColors.ink,
                ),
              ),
              Text(
                label,
                style: AppText.caption.copyWith(
                  fontSize: 12,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : RitualColors.subInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final int total = state.totalLessons;
    final int done = state.lessonsCompleted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RitualColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RitualColors.line, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$done of $total lessons completed',
            style: AppText.body,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const ColoredBox(color: RitualColors.line),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: state.courseProgress.clamp(0.0, 1.0),
                    child: const ColoredBox(color: RitualColors.jade),
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

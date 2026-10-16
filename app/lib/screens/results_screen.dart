import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import 'lesson_screen.dart';

/// End-of-session summary: XP, accuracy, best combo and time - plus a way
/// back to practice when hearts ran out (the "practice to earn hearts" loop).
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
  Widget build(BuildContext context) {
    final SessionResult r = widget.result;
    final String title = _passed
        ? (_isReview ? 'Practice complete!' : 'Lesson complete!')
        : 'Out of hearts';
    final String subtitle = _passed
        ? (_isReview
            ? 'Review keeps what you learned from fading.'
            : 'Come back tomorrow to keep the streak alive.')
        : 'You can practice to earn hearts back right away.';

    final bool heartRestored = _passed &&
        _isReview &&
        r.heartsRemaining < widget.state.config.maxHearts;

    return Scaffold(
      backgroundColor: RitualColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 24),
                          _Medal(passed: _passed),
                          const SizedBox(height: 20),
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
                          if (heartRestored) ...<Widget>[
                            const SizedBox(height: 14),
                            const _HeartRestoredNote(),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.bolt_rounded,
                                  iconColor: RitualColors.amber,
                                  value: '+${r.xpEarned}',
                                  label: 'XP earned',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.track_changes_rounded,
                                  iconColor: RitualColors.jade,
                                  value: '${(r.accuracy * 100).round()}%',
                                  label: 'Accuracy',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: RitualColors.rose,
                                  value: '${r.bestCombo}',
                                  label: 'Best combo',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.schedule_rounded,
                                  iconColor: RitualColors.sky,
                                  value: _formatDuration(r.duration),
                                  label: 'Time',
                                ),
                              ),
                            ],
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

class _Medal extends StatelessWidget {
  const _Medal({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    final Color bg = passed ? RitualColors.amberTint : RitualColors.roseTint;
    final Color fg = passed ? RitualColors.amberLip : RitualColors.rose;
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: lipShadow(fg.withValues(alpha: 0.35), depth: 6),
      ),
      child: Icon(
        passed ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
        size: 58,
        color: fg,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppText.title),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

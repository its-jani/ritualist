import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/path_node.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_bar.dart';
import 'lesson_screen.dart';

/// The learn/home tab: status row pinned on top, then the winding lesson
/// path of unit bands, nodes and the practice card - the pattern mapped from
/// the reference app's pathway tree (docs/rea-duolingo-findings.md §1).
class PathScreen extends StatefulWidget {
  const PathScreen({super.key, required this.state});

  final AppState state;

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  /// Horizontal offsets of the winding path, repeated down the column.
  static const List<double> _zigzag = <double>[0, 26, 42, 26, 0, -26, -42, -26];

  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final ModuleManifest? m = widget.state.manifest;
        if (m == null) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: StatusBar(
                      streak: widget.state.streak,
                      hearts: widget.state.hearts,
                      xpToday: widget.state.xpToday,
                      dailyGoalProgress: widget.state.dailyGoalProgress,
                      goalReached: widget.state.goalReachedToday,
                      goalXp: widget.state.progress.dailyGoalXp,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 32),
                      children: _buildPath(m),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPath(ModuleManifest m) {
    final AppState s = widget.state;
    final List<Widget> children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(m.title, style: AppText.display),
            const SizedBox(height: 4),
            Text(m.tagline, style: AppText.bodyMuted),
          ],
        ),
      ),
    );

    children.add(_PracticeCard(state: s, onTap: _openReview));

    var nodeIndex = 0;
    for (final ModuleUnit unit in m.units) {
      final UnitPalette palette = UnitPalette.of(unit.colorIndex);
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: UnitBand(
            palette: palette,
            title: unit.title,
            subtitle: unit.subtitle,
            progress: PathLogic.unitProgress(unit, s.progress),
          ),
        ),
      );

      for (final LessonSummary lesson in unit.lessons) {
        final bool done = s.isCompleted(lesson.id);
        final bool current = !done && lesson.id == s.nextLessonId;
        final bool locked = !done && !current;
        final double dx = _zigzag[nodeIndex % _zigzag.length];
        final String? tip =
            locked ? null : '${lesson.title} - ${lesson.exerciseCount} exercises';
        children.add(
          SizedBox(
            height: current ? 134 : 98,
            child: Center(
              child: Transform.translate(
                offset: Offset(dx, 0),
                child: PathNode(
                  state: done
                      ? PathNodeState.done
                      : (current ? PathNodeState.current : PathNodeState.locked),
                  palette: palette,
                  tooltip: tip,
                  onTap: () => _openLesson(lesson.id),
                ),
              ),
            ),
          ),
        );
        nodeIndex++;
      }
    }
    return children;
  }

  Future<void> _openReview() async {
    final AppState s = widget.state;
    if (s.lessonsCompleted == 0) {
      _toast('Finish a lesson first - then practice brings it back.');
      return;
    }
    final SessionSpec? spec = await s.buildReviewSession();
    if (!mounted) {
      return;
    }
    if (spec == null || spec.items.isEmpty) {
      _toast('Nothing to review right now. Come back later.');
      return;
    }
    _pushSession(spec);
  }

  Future<void> _openLesson(String lessonId) async {
    final AppState s = widget.state;
    if (!s.isUnlocked(lessonId)) {
      _toast('Finish the lesson above first.');
      return;
    }
    if (s.hearts <= 0) {
      await _showNoHeartsDialog();
      return;
    }
    if (_opening) {
      return;
    }
    _opening = true;
    try {
      final Lesson? lesson = await s.loadLesson(lessonId);
      if (!mounted) {
        return;
      }
      if (lesson == null) {
        _toast('Lesson content is unavailable.');
        return;
      }
      _pushSession(SessionBuilder.lessonSession(lesson));
    } finally {
      _opening = false;
    }
  }

  void _pushSession(SessionSpec spec) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(state: widget.state, spec: spec),
      ),
    );
  }

  Future<void> _showNoHeartsDialog() async {
    final AppState s = widget.state;
    final int? minutes = s.minutesToNextHeart;
    final bool canPractice = s.lessonsCompleted > 0;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.favorite_border_rounded,
          color: RitualColors.rose,
          size: 42,
        ),
        title: const Text('No hearts left', style: AppText.title),
        content: Text(
          minutes == null
              ? 'Hearts refill over time. Come back soon!'
              : 'Your next heart refills in about $minutes min.'
                  '${canPractice ? ' Or practice now to earn one back.' : ''}',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          if (canPractice)
            RitualButton(
              label: 'Practice',
              size: RitualButtonSize.small,
              expand: false,
              onPressed: () {
                Navigator.of(context).pop();
                _openReview();
              },
            ),
          RitualButton(
            label: 'OK',
            variant: RitualButtonVariant.secondary,
            size: RitualButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// The spaced-repetition "Practice" card at the top of the path.
class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.state, required this.onTap});

  final AppState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = state.lessonsCompleted > 0;
    final int due = state.dueReviewCount;
    final String subtitle = !enabled
        ? 'Complete a lesson to unlock practice'
        : (due > 0
            ? '$due skill${due == 1 ? '' : 's'} due for review'
            : 'Review your weakest skills');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RitualColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RitualColors.line, width: 2),
                boxShadow: lipShadow(RitualColors.line, depth: 4),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: RitualColors.amberTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.replay_rounded,
                      color: due > 0
                          ? RitualColors.amberLip
                          : RitualColors.amber,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Practice', style: AppText.title.copyWith(fontSize: 17)),
                        Text(subtitle, style: AppText.caption),
                      ],
                    ),
                  ),
                  if (due > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RitualColors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$due',
                        style: AppText.button
                            .copyWith(color: Colors.white, fontSize: 14),
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: RitualColors.faint,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

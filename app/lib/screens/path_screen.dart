import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/motion.dart';
import '../widgets/path_node.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_bar.dart';
import 'lesson_screen.dart';

/// The learn/home tab: status row pinned on top, then the winding lesson
/// path of unit bands, nodes and the practice card - the pattern mapped from
/// the reference app's pathway tree (docs/rea-duolingo-findings.md §1).
///
/// The path is a real trail, not a column of icons: one [PathTrail] curve per
/// row, drawn through the exact centre of each node, so consecutive rows meet
/// perfectly and the whole run reads as one winding ribbon.
class PathScreen extends StatefulWidget {
  const PathScreen({super.key, required this.state});

  final AppState state;

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  /// Amplitude of the winding path. Period of six rows keeps the reference
  /// app's lazy S-bend without ever clipping the 520px column.
  static const double _amplitude = 44;

  /// Breathing room the node's pulse halo needs inside each row.
  static const double _nodeChrome = 40;
  static const double _rowGap = 12;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _currentKey = GlobalKey();

  bool _elevated = false;
  bool _opening = false;
  String? _lastAutoScrolledId;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final bool elevated = _scroll.hasClients && _scroll.offset > 6;
    if (elevated != _elevated) {
      setState(() => _elevated = elevated);
    }
  }

  /// Centres the active node the first time the path is shown - and again
  /// whenever finishing a lesson moves the "current" flag down the list.
  void _autoScrollTo(String? lessonId) {
    if (lessonId == null || lessonId == _lastAutoScrolledId) {
      return;
    }
    _lastAutoScrolledId = lessonId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final BuildContext? target = _currentKey.currentContext;
      if (target == null) {
        return;
      }
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 650),
        curve: RitualMotion.inOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (BuildContext context, Widget? _) {
        final ModuleManifest? m = widget.state.manifest;
        if (m == null) {
          return const SizedBox.shrink();
        }
        _autoScrollTo(widget.state.nextLessonId);
        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: <Widget>[
                  _header(),
                  Expanded(
                    child: ScrollConfiguration(
                      // Desktop gets the same inertial drag as touch: the
                      // ultrabook trackpad drives the path like a phone.
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: const <PointerDeviceKind>{
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                          PointerDeviceKind.stylus,
                        },
                        scrollbars: false,
                      ),
                      child: SingleChildScrollView(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 36),
                        child: Column(children: _buildPath(m)),
                      ),
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

  Widget _header() {
    return AnimatedContainer(
      duration: RitualMotion.standard,
      curve: RitualMotion.standardCurve,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: RitualColors.bg,
        border: Border(
          bottom: BorderSide(
            color: _elevated ? RitualColors.line : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: StatusBar(
        streak: widget.state.streak,
        hearts: widget.state.hearts,
        xpToday: widget.state.xpToday,
        dailyGoalProgress: widget.state.dailyGoalProgress,
        goalReached: widget.state.goalReachedToday,
        goalXp: widget.state.progress.dailyGoalXp,
      ),
    );
  }

  List<Widget> _buildPath(ModuleManifest m) {
    final AppState s = widget.state;
    final List<Widget> children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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

    for (int u = 0; u < m.units.length; u++) {
      children.addAll(_buildUnit(m.units[u], u + 1, m.units.length));
    }

    if (s.courseProgress >= 1 && m.units.isNotEmpty) {
      children.add(const _CourseCompleteCard());
    }
    return children;
  }

  List<Widget> _buildUnit(ModuleUnit unit, int number, int totalUnits) {
    final AppState s = widget.state;
    final UnitPalette palette = UnitPalette.of(unit.colorIndex);
    final double progress = PathLogic.unitProgress(unit, s.progress);

    final List<Widget> widgets = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(20, number == 1 ? 4 : 14, 20, 14),
        child: UnitBand(
          palette: palette,
          title: unit.title,
          subtitle: unit.subtitle,
          progress: progress,
          unitNumber: number,
          lessonCount: unit.lessons.length,
        ),
      ),
    ];

    for (int i = 0; i < unit.lessons.length; i++) {
      final LessonSummary lesson = unit.lessons[i];
      final bool done = s.isCompleted(lesson.id);
      final bool current = !done && lesson.id == s.nextLessonId;
      final bool checkpoint = i == unit.lessons.length - 1;

      final PathNodeState state = done
          ? PathNodeState.done
          : (current ? PathNodeState.current : PathNodeState.locked);

      final double dx = _dx(i);
      final double previousDx = i == 0 ? dx : _dx(i - 1);
      final double nextDx = i == unit.lessons.length - 1 ? dx : _dx(i + 1);

      final double height =
          PathNode.sizeFor(state, checkpoint: checkpoint) + _nodeChrome + _rowGap;

      final Color trail = done
          ? palette.base.withValues(alpha: 0.22)
          : (current
              ? palette.base.withValues(alpha: 0.16)
              : RitualColors.line);

      final String tip = done
          ? '${lesson.title} - tap to review'
          : (current
              ? '${lesson.title} - ${lesson.exerciseCount} exercises'
              : 'Finish the lesson above to unlock');

      widgets.add(
        SizedBox(
          key: current ? _currentKey : null,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              PathTrail(
                previousDx: previousDx,
                dx: dx,
                nextDx: nextDx,
                color: trail,
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(dx, 0),
                  child: PathNode(
                    state: state,
                    palette: palette,
                    checkpoint: checkpoint,
                    tooltip: tip,
                    onTap: () => _openLesson(lesson.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  double _dx(int index) => _amplitude * math.sin(index * math.pi / 3);

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
      builder: (BuildContext context) => AlertDialog(
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: PressableCard(
        onTap: onTap,
        enabled: enabled,
        color: RitualColors.card,
        shadowColor: RitualColors.line,
        border: Border.all(color: RitualColors.line, width: 2),
        padding: const EdgeInsets.all(14),
        semanticLabel: 'Practice: $subtitle',
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
                color: due > 0 ? RitualColors.amberLip : RitualColors.amber,
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
            AnimatedSwitcher(
              duration: RitualMotion.standard,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(
                scale: animation.drive(Tween<double>(begin: 0.6, end: 1)),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: due > 0
                  ? Container(
                      key: ValueKey<int>(due),
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
                  : const Icon(
                      Icons.chevron_right_rounded,
                      key: ValueKey<String>('chevron'),
                      color: RitualColors.faint,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The end of the path: a trophy card that pushes the retention loop
/// (practice keeps what you learned) instead of a dead stop.
class _CourseCompleteCard extends StatelessWidget {
  const _CourseCompleteCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: RitualColors.amberTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RitualColors.amber, width: 2),
          boxShadow: lipShadow(RitualColors.amberLip.withValues(alpha: 0.5), depth: 4),
        ),
        child: const Column(
          children: <Widget>[
            Icon(
              Icons.workspace_premium_rounded,
              size: 44,
              color: RitualColors.amberLip,
            ),
            SizedBox(height: 8),
            Text('Every lesson cleared', style: AppText.title),
            SizedBox(height: 4),
            Text(
              'Practice keeps it fresh - that is how the habit holds.',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

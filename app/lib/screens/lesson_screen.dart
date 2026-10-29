import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter/services.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../state/lesson_controller.dart';
import '../state/sfx.dart';
import '../theme.dart';
import '../widgets/exercise_match.dart';
import '../widgets/exercise_mcq.dart';
import '../widgets/exercise_order.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/motion.dart';
import '../widgets/primary_button.dart';
import 'results_screen.dart';

/// Plays one session (lesson or review): top bar with progress + combo +
/// hearts, the exercise, and either the Check button or the sliding feedback
/// panel - the instant feedback loop of the reference study (findings §4).
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.state, required this.spec});

  final AppState state;
  final SessionSpec spec;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonController _controller;

  /// Answer state for the current item, reset on every advance.
  int? _mcqSelected;
  List<int> _orderPlaced = <int>[];

  /// Bumped on advance; keys the exercise view so per-item widget state
  /// (e.g. matched pairs) never leaks into the next item.
  int _itemNo = 0;

  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _controller = LessonController(
      spec: widget.spec,
      startHearts: widget.state.hearts,
      config: widget.state.config,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Single funnel for every answer, so grading sound and haptics can never
  /// drift between exercise types (matching auto-submits on its own).
  void _submit(ExerciseAnswer answer) {
    _controller.submit(answer);
    final Feedback? feedback = _controller.feedback;
    if (feedback == null) {
      return;
    }
    unawaited(feedback.correct ? RitualSfx.correct() : RitualSfx.wrong());
  }

  bool get _canCheck {
    final SessionItem? item = _controller.item;
    if (item == null || _controller.feedback != null) {
      return false;
    }
    return switch (item.exercise) {
      MultipleChoiceExercise() => _mcqSelected != null,
      OrderStepsExercise(:final steps) => _orderPlaced.length == steps.length,
      MatchPairsExercise() => false,
    };
  }

  void _check() {
    final SessionItem? item = _controller.item;
    if (item == null) {
      return;
    }
    switch (item.exercise) {
      case MultipleChoiceExercise():
        final int? selected = _mcqSelected;
        if (selected != null) {
          _submit(MultipleChoiceAnswer(selected));
        }
      case OrderStepsExercise(:final steps):
        if (_orderPlaced.length == steps.length) {
          _submit(OrderStepsAnswer(_orderPlaced));
        }
      case MatchPairsExercise():
        // Auto-submitted by MatchView once every pair is matched.
        break;
    }
  }

  void _continue() {
    _controller.advance();
    _mcqSelected = null;
    _orderPlaced = <int>[];
    _itemNo++;
    if (_controller.isFinished) {
      _finish();
    }
  }

  /// Enter / Space on desktop: check the answer, then advance past feedback.
  void _primaryAction() {
    if (_controller.feedback != null) {
      _continue();
    } else if (_canCheck) {
      _check();
    }
  }

  Future<void> _finish() async {
    final SessionResult? result = _controller.result;
    if (result == null || _finishing) {
      return;
    }
    _finishing = true;
    await widget.state.finishSession(widget.spec, result);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultsScreen(
          state: widget.state,
          spec: widget.spec,
          result: result,
        ),
      ),
    );
  }

  Future<void> _confirmQuit() async {
    final bool? quit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: RitualColors.subInk,
          size: 34,
        ),
        title: const Text('Quit this session?', style: AppText.title),
        content: const Text(
          'Your answers in this session will not count.',
          style: AppText.bodyMuted,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          RitualButton(
            label: 'Keep going',
            size: RitualButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          RitualButton(
            label: 'Quit',
            variant: RitualButtonVariant.secondary,
            size: RitualButtonSize.small,
            expand: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (quit != true || !mounted) {
      return;
    }
    final SessionResult result = _controller.abandon();
    await widget.state.finishSession(widget.spec, result);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _confirmQuit();
        }
      },
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.enter): _primaryAction,
          const SingleActivator(LogicalKeyboardKey.numpadEnter): _primaryAction,
          const SingleActivator(LogicalKeyboardKey.space): _primaryAction,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: RitualColors.bg,
            body: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (BuildContext context, Widget? _) => Column(
                      children: <Widget>[
                        _topBar(),
                        Expanded(child: _exerciseArea()),
                        _bottomArea(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final int combo = _controller.runner.combo;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 18, 6),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: _confirmQuit,
            tooltip: 'Quit',
            icon: const Icon(
              Icons.close_rounded,
              color: RitualColors.subInk,
              size: 26,
            ),
          ),
          Expanded(child: _ProgressBar(value: _controller.progress)),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: RitualMotion.standard,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(
              scale: animation.drive(Tween<double>(begin: 0.5, end: 1)),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: combo >= 2
                ? _ComboChip(key: ValueKey<int>(combo), combo: combo)
                : const SizedBox.shrink(key: ValueKey<String>('no-combo')),
          ),
          const SizedBox(width: 12),
          _HeartCounter(hearts: _controller.hearts),
        ],
      ),
    );
  }

  Widget _exerciseArea() {
    final SessionItem? item = _controller.item;
    if (item == null) {
      return const Center(
        child: CircularProgressIndicator(color: RitualColors.jade),
      );
    }
    return AnimatedSwitcher(
      duration: RitualMotion.standard,
      switchInCurve: RitualMotion.inOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          ...previous,
          if (current != null) current,
        ],
      ),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: SingleChildScrollView(
        key: ValueKey<int>(_itemNo),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              item.exercise.prompt,
              style: AppText.title.copyWith(fontSize: 21, height: 1.3),
            ),
            const SizedBox(height: 18),
            _exerciseView(item),
          ],
        ),
      ),
    );
  }

  Widget _exerciseView(SessionItem item) {
    final bool locked = _controller.feedback != null;
    return switch (item.exercise) {
      final MultipleChoiceExercise exercise => McqView(
          exercise: exercise,
          selectedIndex: _mcqSelected,
          locked: locked,
          onSelect: (int i) {
            unawaited(RitualSfx.tap());
            setState(() => _mcqSelected = i);
          },
        ),
      final OrderStepsExercise exercise => OrderView(
          exercise: exercise,
          seed: item.seed,
          placed: _orderPlaced,
          locked: locked,
          onChanged: (List<int> placed) {
            unawaited(RitualSfx.tap());
            setState(() => _orderPlaced = placed);
          },
        ),
      final MatchPairsExercise exercise => MatchView(
          exercise: exercise,
          seed: item.seed,
          locked: locked,
          onCompleted: (int missed) =>
              _submit(MatchPairsAnswer(missed: missed)),
        ),
    };
  }

  Widget _bottomArea() {
    final Feedback? feedback = _controller.feedback;
    return AnimatedSwitcher(
      duration: RitualMotion.panel,
      switchInCurve: RitualMotion.standardCurve,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<Offset> slide = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: feedback != null
          ? FeedbackPanel(
              key: const ValueKey<String>('feedback'),
              feedback: feedback,
              onContinue: _continue,
            )
          : SafeArea(
              key: const ValueKey<String>('check'),
              top: false,
              child: _checkArea(),
            ),
    );
  }

  Widget _checkArea() {
    final SessionItem? item = _controller.item;
    if (item == null) {
      return const SizedBox.shrink(key: ValueKey<String>('none'));
    }
    final bool isMatch = item.exercise is MatchPairsExercise;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RitualColors.line, width: 2)),
      ),
      child: isMatch
          ? const SizedBox(
              height: 57,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shield_moon_rounded,
                      size: 16,
                      color: RitualColors.subInk,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Matching is practice - no hearts at risk.',
                        style: AppText.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RitualButton(
              label: 'Check',
              onPressed: _canCheck ? _check : null,
            ),
    );
  }
}

/// Rounded progress bar that grows into its new value instead of jumping,
/// with the reference study's top gloss strip (findings §5).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final double target = value.clamp(0.0, 1.0);
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: RitualColors.line,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: const Duration(milliseconds: 420),
        curve: RitualMotion.standardCurve,
        builder: (BuildContext context, double widthFactor, Widget? _) =>
            FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            decoration: BoxDecoration(
              color: RitualColors.jade,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(top: 3, left: 8, right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The combo pill: appears from two correct answers in a row and re-pops on
/// every additional hit, then vanishes the moment the run breaks.
class _ComboChip extends StatelessWidget {
  const _ComboChip({super.key, required this.combo});

  final int combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: RitualColors.amberTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RitualColors.amber, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.local_fire_department_rounded,
            size: 15,
            color: RitualColors.amberLip,
          ),
          const SizedBox(width: 3),
          Text(
            'x$combo',
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

/// Hearts counter that physically reacts when a heart is lost: the chip
/// shakes, the number swaps with a scale pop, and a "-1" floats up.
class _HeartCounter extends StatefulWidget {
  const _HeartCounter({required this.hearts});

  final int hearts;

  @override
  State<_HeartCounter> createState() => _HeartCounterState();
}

class _HeartCounterState extends State<_HeartCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late int _previous = widget.hearts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (prefersReducedMotion(context)) {
      _shake.value = 1;
    }
  }

  @override
  void didUpdateWidget(_HeartCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hearts < _previous && !prefersReducedMotion(context)) {
      _shake.forward(from: 0);
    }
    _previous = widget.hearts;
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (BuildContext context, Widget? child) {
          final double t = _shake.value;
          final bool animating = t > 0 && t < 1;
          final double dx =
              animating ? math.sin(t * math.pi * 4) * 4 * (1 - t) : 0;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Transform.translate(offset: Offset(dx, 0), child: child),
              if (animating)
                Positioned(
                  top: -8 - 12 * t,
                  right: 0,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Text(
                      '-1',
                      style: AppText.button.copyWith(
                        fontSize: 14,
                        color: RitualColors.roseInk,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.favorite_rounded,
              color: RitualColors.rose,
              size: 22,
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(
                scale: animation.drive(Tween<double>(begin: 1.5, end: 1)),
                child: child,
              ),
              child: Text(
                '${widget.hearts}',
                key: ValueKey<int>(widget.hearts),
                style: AppText.button
                    .copyWith(color: RitualColors.roseInk, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

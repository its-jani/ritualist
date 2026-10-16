import 'package:flutter/material.dart' hide Feedback;
import 'package:ritualist_engine/ritualist_engine.dart';

import '../state/app_state.dart';
import '../state/lesson_controller.dart';
import '../theme.dart';
import '../widgets/exercise_match.dart';
import '../widgets/exercise_mcq.dart';
import '../widgets/exercise_order.dart';
import '../widgets/feedback_panel.dart';
import '../widgets/primary_button.dart';
import 'results_screen.dart';

/// Plays one session (lesson or review): top bar with progress + hearts,
/// the exercise, and either the Check button or the sliding feedback panel -
/// the instant feedback loop of the reference study (findings §4).
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

  void _check() {
    final SessionItem? item = _controller.item;
    if (item == null) {
      return;
    }
    switch (item.exercise) {
      case MultipleChoiceExercise():
        final int? selected = _mcqSelected;
        if (selected != null) {
          _controller.submit(MultipleChoiceAnswer(selected));
        }
      case OrderStepsExercise(:final steps):
        if (_orderPlaced.length == steps.length) {
          _controller.submit(OrderStepsAnswer(_orderPlaced));
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
      builder: (context) => AlertDialog(
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
      child: Scaffold(
        backgroundColor: RitualColors.bg,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => Column(
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
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 6),
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
          const SizedBox(width: 14),
          const Icon(
            Icons.favorite_rounded,
            color: RitualColors.rose,
            size: 22,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation.drive(Tween<double>(begin: 1.5, end: 1)),
              child: child,
            ),
            child: Text(
              '${_controller.hearts}',
              key: ValueKey<int>(_controller.hearts),
              style: AppText.button
                  .copyWith(color: RitualColors.roseInk, fontSize: 17),
            ),
          ),
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
    return SingleChildScrollView(
      key: ValueKey<int>(_itemNo),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            item.exercise.prompt,
            style: AppText.title.copyWith(fontSize: 21),
          ),
          const SizedBox(height: 18),
          _exerciseView(item),
        ],
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
          onSelect: (int i) => setState(() => _mcqSelected = i),
        ),
      final OrderStepsExercise exercise => OrderView(
          exercise: exercise,
          seed: item.seed,
          placed: _orderPlaced,
          locked: locked,
          onChanged: (List<int> placed) =>
              setState(() => _orderPlaced = placed),
        ),
      final MatchPairsExercise exercise => MatchView(
          exercise: exercise,
          seed: item.seed,
          locked: locked,
          onCompleted: (int missed) =>
              _controller.submit(MatchPairsAnswer(missed: missed)),
        ),
    };
  }

  Widget _bottomArea() {
    final Feedback? feedback = _controller.feedback;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
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
    final bool canCheck = switch (item.exercise) {
      MultipleChoiceExercise() => _mcqSelected != null,
      OrderStepsExercise(:final steps) => _orderPlaced.length == steps.length,
      MatchPairsExercise() => false,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: RitualColors.line, width: 2)),
      ),
      child: isMatch
          ? const SizedBox(height: 57)
          : RitualButton(
              label: 'Check',
              onPressed: canCheck ? _check : null,
            ),
    );
  }
}

/// Rounded progress bar with the reference study's top gloss strip.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: RitualColors.line,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
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
    );
  }
}

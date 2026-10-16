import '../config.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../util/clock.dart';

/// Phases of a lesson session, mirroring the Duolingo loop:
/// answer -> feedback panel -> next question -> ... -> complete (or failed).
enum RunnerPhase { answering, feedback, complete, failed }

/// Drives one session: tracks the queue, mistake re-injection, combo, hearts
/// and produces the final [SessionResult].
///
/// Key behaviors (observed in Duolingo's client):
///  - a wrong answer costs a heart (except in matching exercises),
///  - every missed exercise is re-queued once at the end of the session,
///  - running out of hearts fails the session immediately after the feedback,
///  - accuracy counts every appearance, including re-injections.
class LessonRunner {
  LessonRunner({
    required this.spec,
    required this.startHearts,
    this.config = const GameConfig(),
    Clock clock = systemClock,
  })  : _clock = clock,
        _hearts = startHearts,
        _queue = List<SessionItem>.of(spec.items),
        _startedAt = clock() {
    if (spec.items.isEmpty) {
      throw ArgumentError.value(spec, 'spec', 'session has no items');
    }
    if (spec.kind == SessionKind.lesson && startHearts <= 0) {
      throw StateError('Cannot start a lesson session with zero hearts');
    }
  }

  final SessionSpec spec;
  final int startHearts;
  final GameConfig config;
  final Clock _clock;

  final List<SessionItem> _queue;
  final Map<String, int> _appearances = <String, int>{};
  final Set<String> _reinjected = <String>{};
  final List<ExerciseOutcome> _outcomes = <ExerciseOutcome>[];
  final Map<String, List<int>> _lessonTally = <String, List<int>>{};

  final DateTime _startedAt;
  int _index = 0;
  int _firstPassAnswered = 0;
  int _hearts;
  int _heartsLost = 0;
  int _mistakes = 0;
  int _combo = 0;
  int _bestCombo = 0;
  DateTime? _lastHeartLossAt;
  RunnerPhase _phase = RunnerPhase.answering;

  RunnerPhase get phase => _phase;
  int get heartsRemaining => _hearts;
  int get combo => _combo;
  int get bestCombo => _bestCombo;
  int get mistakes => _mistakes;

  /// Total exercises in the original plan (re-injections not counted).
  int get plannedExercises => spec.items.length;

  /// Progress of the top progress bar: distinct exercises answered / total.
  double get progress =>
      plannedExercises == 0 ? 1 : _firstPassAnswered / plannedExercises;

  /// The item on screen (current question, or the one being reviewed on the
  /// feedback panel). Null once the session is complete/failed.
  SessionItem? get currentItem =>
      (_phase == RunnerPhase.answering || _phase == RunnerPhase.feedback)
          ? _queue[_index]
          : null;

  /// Submits the user's answer for the current exercise.
  Feedback submit(ExerciseAnswer answer) {
    if (_phase != RunnerPhase.answering) {
      throw StateError('submit() called in phase $_phase');
    }
    final item = _queue[_index];
    final exercise = item.exercise;
    final correct = exercise.check(answer);

    _outcomes.add(ExerciseOutcome(
      exerciseId: exercise.id,
      lessonId: item.lessonId,
      correct: correct,
    ));
    _tally(item.lessonId, correct);
    if (_index < spec.items.length) {
      _firstPassAnswered++;
    }

    final appearances =
        _appearances.update(exercise.id, (v) => v + 1, ifAbsent: () => 1);

    var heartLost = false;
    if (correct) {
      _combo++;
      if (_combo > _bestCombo) {
        _bestCombo = _combo;
      }
    } else {
      _combo = 0;
      _mistakes++;
      if (spec.kind == SessionKind.lesson &&
          exercise.costsHeartOnWrong &&
          _hearts > 0) {
        _hearts--;
        _heartsLost++;
        _lastHeartLossAt = _clock();
        heartLost = true;
      }
      if (appearances == 1 && !_reinjected.contains(exercise.id)) {
        _reinjected.add(exercise.id);
        _queue.add(item); // Duolingo-style mistake re-injection.
      }
    }

    _phase = RunnerPhase.feedback;
    return Feedback(
      correct: correct,
      heartLost: heartLost,
      combo: _combo,
      heartsRemaining: _hearts,
      solution: correct ? null : exercise.solution,
      explanation: exercise.explanation,
      source: exercise.source,
    );
  }

  /// Advances past the feedback panel to the next question, or finishes.
  void next() {
    if (_phase != RunnerPhase.feedback) {
      throw StateError('next() called in phase $_phase');
    }
    if (spec.kind == SessionKind.lesson && _hearts <= 0) {
      _phase = RunnerPhase.failed;
      return;
    }
    if (_index + 1 < _queue.length) {
      _index++;
      _phase = RunnerPhase.answering;
    } else {
      _phase = RunnerPhase.complete;
    }
  }

  /// Result of a finished session.
  SessionResult buildResult() {
    final passed = _phase == RunnerPhase.complete;
    final xp = passed
        ? spec.baseXp + (_mistakes == 0 ? config.perfectBonusXp : 0)
        : 0;
    return _result(passed: passed, abandoned: false, xpEarned: xp);
  }

  /// Result for a session the user quit mid-way: hearts spent still count,
  /// nothing else is credited (no XP, no streak, no SRS, no stats).
  SessionResult abandon() => _result(passed: false, abandoned: true, xpEarned: 0);

  SessionResult _result({
    required bool passed,
    required bool abandoned,
    required int xpEarned,
  }) {
    final duration = _clock().difference(_startedAt);
    return SessionResult(
      kind: spec.kind,
      lessonId: spec.lessonId,
      passed: passed,
      abandoned: abandoned,
      answers: _outcomes.length,
      mistakes: _mistakes,
      heartsLost: _heartsLost,
      heartsRemaining: _hearts,
      lastHeartLossAt: _lastHeartLossAt,
      xpEarned: xpEarned,
      bestCombo: _bestCombo,
      duration: duration.isNegative ? Duration.zero : duration,
      outcomes: List<ExerciseOutcome>.unmodifiable(_outcomes),
      lessons: Map<String, LessonOutcome>.unmodifiable(
        _lessonTally.map((k, v) =>
            MapEntry<String, LessonOutcome>(k, LessonOutcome(answers: v[0], mistakes: v[1]))),
      ),
    );
  }

  void _tally(String lessonId, bool correct) {
    final entry = _lessonTally.putIfAbsent(lessonId, () => <int>[0, 0]);
    entry[0]++;
    if (!correct) {
      entry[1]++;
    }
  }
}

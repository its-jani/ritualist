import 'exercise.dart';
import 'source_ref.dart';

/// What kind of session the runner is playing.
enum SessionKind {
  /// A lesson from the path. Costs hearts, awards `lesson.xp`.
  lesson,

  /// Spaced-repetition practice over due (or weakest) lessons.
  /// Heart-free; passing restores hearts.
  review,
}

/// One exercise scheduled in a session, bound to the lesson it came from
/// (needed for the SRS update after a review session).
class SessionItem {
  const SessionItem({
    required this.lessonId,
    required this.exercise,
    required this.seed,
  });

  final String lessonId;
  final Exercise exercise;

  /// Deterministic shuffle seed so token order is stable per exercise.
  final int seed;
}

/// Immutable plan for one session.
class SessionSpec {
  const SessionSpec({
    required this.kind,
    required this.title,
    required this.baseXp,
    required this.items,
    this.lessonId,
  });

  final SessionKind kind;
  final String title;

  /// XP for a perfect pass is [baseXp] + GameConfig.perfectBonusXp.
  final int baseXp;

  final List<SessionItem> items;

  /// Set for [SessionKind.lesson] sessions.
  final String? lessonId;

  int get exerciseCount => items.length;
}

/// Outcome of a single exercise appearance (a mistake re-injection produces a
/// second outcome with the same exercise id).
class ExerciseOutcome {
  const ExerciseOutcome({
    required this.exerciseId,
    required this.lessonId,
    required this.correct,
  });

  final String exerciseId;
  final String lessonId;
  final bool correct;
}

/// Aggregated per-lesson outcome inside one session.
class LessonOutcome {
  const LessonOutcome({required this.answers, required this.mistakes});

  final int answers;
  final int mistakes;
}

/// What the UI shows on the feedback panel after each answer.
class Feedback {
  const Feedback({
    required this.correct,
    required this.heartLost,
    required this.combo,
    required this.heartsRemaining,
    this.solution,
    this.explanation,
    this.source,
  });

  final bool correct;

  /// True when this wrong answer consumed one heart.
  final bool heartLost;
  final int combo;
  final int heartsRemaining;

  /// Correct solution text, present when [correct] is false.
  final String? solution;
  final String? explanation;
  final SourceRef? source;
}

/// Final (or abandoned) outcome of a session.
class SessionResult {
  const SessionResult({
    required this.kind,
    required this.lessonId,
    required this.passed,
    required this.abandoned,
    required this.answers,
    required this.mistakes,
    required this.heartsLost,
    required this.heartsRemaining,
    required this.lastHeartLossAt,
    required this.xpEarned,
    required this.bestCombo,
    required this.duration,
    required this.outcomes,
    required this.lessons,
  });

  final SessionKind kind;
  final String? lessonId;
  final bool passed;

  /// User quit mid-session: hearts spent still count, nothing else does.
  final bool abandoned;

  final int answers;
  final int mistakes;
  final int heartsLost;
  final int heartsRemaining;

  /// When the last heart was lost this session (regen clock anchor).
  final DateTime? lastHeartLossAt;

  final int xpEarned;
  final int bestCombo;
  final Duration duration;

  /// Every exercise appearance, in order.
  final List<ExerciseOutcome> outcomes;

  /// Per-lesson aggregation (lessonId -> answers/mistakes).
  final Map<String, LessonOutcome> lessons;

  double get accuracy => answers == 0 ? 0 : (answers - mistakes) / answers;
}

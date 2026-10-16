import '../config.dart';
import '../models/exercise.dart';
import '../models/module.dart';
import '../models/session.dart';
import '../progress/progress.dart';
import '../util/prng.dart';

/// Builds [SessionSpec]s from content + progress. Two session kinds exist:
///  - lesson sessions: one lesson, exercises in authored order;
///  - review sessions: spaced-repetition practice over due (or weakest)
///    lessons, with weak exercises picked first.
class SessionBuilder {
  const SessionBuilder._();

  /// A lesson session for [lesson].
  static SessionSpec lessonSession(Lesson lesson) {
    return SessionSpec(
      kind: SessionKind.lesson,
      lessonId: lesson.id,
      title: lesson.title,
      baseXp: lesson.xp,
      items: [
        for (final e in lesson.exercises)
          SessionItem(lessonId: lesson.id, exercise: e, seed: fnv1a(e.id)),
      ],
    );
  }

  /// How many completed lessons are due for review right now.
  static int dueCount(Progress progress, DateTime now) {
    var count = 0;
    for (final lp in progress.lessons.values) {
      if (lp.isCompleted && (lp.srs?.isDueAt(now) ?? false)) {
        count++;
      }
    }
    return count;
  }

  /// Builds a review session, or null when the user has not completed any
  /// lesson yet (nothing to practice).
  ///
  /// Selection: due lessons first (most overdue first); when nothing is due,
  /// the weakest completed lessons (lowest ease, oldest review) are used so
  /// practice is always meaningful.
  static SessionSpec? reviewSession({
    required ModuleManifest manifest,
    required Map<String, UnitFile> units,
    required Progress progress,
    GameConfig config = const GameConfig(),
    required DateTime now,
  }) {
    final resolvedLessons = <String, Lesson>{};
    for (final unitFile in units.values) {
      for (final lesson in unitFile.lessons) {
        resolvedLessons[lesson.id] = lesson;
      }
    }

    final completedIds = <String>[
      for (final entry in progress.lessons.entries)
        if (entry.value.isCompleted && resolvedLessons.containsKey(entry.key))
          entry.key,
    ];
    if (completedIds.isEmpty) {
      return null;
    }

    var selected = <String>[
      for (final id in completedIds)
        if (progress.lessons[id]!.srs?.isDueAt(now) ?? false) id,
    ]..sort((a, b) => progress.lessons[a]!.srs!.dueAt
        .compareTo(progress.lessons[b]!.srs!.dueAt));

    if (selected.isEmpty) {
      // Nothing due: weakest lessons.
      selected = completedIds.toList()
        ..sort((a, b) {
          final la = progress.lessons[a]!;
          final lb = progress.lessons[b]!;
          final ea = la.srs?.ease ?? 2.5;
          final eb = lb.srs?.ease ?? 2.5;
          if (ea != eb) {
            return ea.compareTo(eb);
          }
          final ta = la.lastCompletedAt?.millisecondsSinceEpoch ?? 0;
          final tb = lb.lastCompletedAt?.millisecondsSinceEpoch ?? 0;
          return ta.compareTo(tb);
        });
      selected = selected.take(config.reviewFallbackLessons).toList();
    } else {
      selected = selected.take(config.reviewLessonsMax).toList();
    }

    final perLesson = <List<Exercise>>[];
    for (final lessonId in selected) {
      perLesson.add(_pickExercises(
        resolvedLessons[lessonId]!,
        progress,
        config.reviewExercisesPerLesson,
      ));
    }

    // Round-robin interleave so a review session alternates between lessons.
    final items = <SessionItem>[];
    var depth = 0;
    var added = true;
    while (added && items.length < config.reviewExercisesMax) {
      added = false;
      for (var li = 0; li < selected.length; li++) {
        if (depth < perLesson[li].length) {
          final exercise = perLesson[li][depth];
          items.add(SessionItem(
            lessonId: selected[li],
            exercise: exercise,
            seed: fnv1a(exercise.id),
          ));
          added = true;
          if (items.length >= config.reviewExercisesMax) {
            break;
          }
        }
      }
      depth++;
    }

    if (items.isEmpty) {
      return null;
    }

    return SessionSpec(
      kind: SessionKind.review,
      title: 'Practice',
      baseXp: config.practiceXp,
      items: items,
    );
  }

  /// Weakest exercises first: most wrong, then fewest right, then authored
  /// order (stable). This is what makes review sessions bite exactly where
  /// the learner struggles.
  static List<Exercise> _pickExercises(
    Lesson lesson,
    Progress progress,
    int limit,
  ) {
    final indices = List<int>.generate(lesson.exercises.length, (i) => i);
    indices.sort((a, b) {
      final sa = progress.exerciseStats[lesson.exercises[a].id];
      final sb = progress.exerciseStats[lesson.exercises[b].id];
      final wa = sa?.wrong ?? 0;
      final wb = sb?.wrong ?? 0;
      if (wa != wb) {
        return wb - wa;
      }
      final ra = sa?.right ?? 0;
      final rb = sb?.right ?? 0;
      if (ra != rb) {
        return ra - rb;
      }
      return a - b;
    });
    return [
      for (final i in indices.take(limit)) lesson.exercises[i],
    ];
  }
}

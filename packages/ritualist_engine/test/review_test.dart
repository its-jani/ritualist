import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

/// Builds a module with [lessonCount] lessons and a matching progress where
/// each lesson has a custom SRS record.
({ModuleManifest manifest, Map<String, UnitFile> units}) buildCourse(
  List<Lesson> lessons,
) {
  final manifest = manifestOf('u1', lessons);
  return (manifest: manifest, units: {'u1': unitFile('u1', lessons)});
}

void main() {
  const config = GameConfig();
  final now = refNow();

  group('Lesson sessions', () {
    test('items follow authored order and carry stable seeds', () {
      final lsn = mixedLesson('u1.l1');
      final spec = SessionBuilder.lessonSession(lsn);
      expectEq(spec.kind, SessionKind.lesson);
      expectEq(spec.lessonId, 'u1.l1');
      expectEq(spec.title, lsn.title);
      expectEq(spec.baseXp, 10);
      expectEq(spec.items.length, 3);
      expectEq(spec.items[0].exercise.id, 'u1.l1.e1');
      expectEq(spec.items[0].seed, fnv1a('u1.l1.e1'));
      expectEq(spec.items[2].lessonId, 'u1.l1');
    });
  });

  group('Path logic', () {
    test('only completed lessons and the single next lesson are unlocked', () {
      final lessons = [mixedLesson('u1.l1'), mixedLesson('u1.l2'), mixedLesson('u1.l3')];
      final course = buildCourse(lessons);
      final p = Progress.fresh(now: now);

      expectEq(PathLogic.nextLessonId(course.manifest, p), 'u1.l1');
      expectTrue(PathLogic.isUnlocked(course.manifest, p, 'u1.l1'));
      expectFalse(PathLogic.isUnlocked(course.manifest, p, 'u1.l2'));

      p.lessons['u1.l1'] = LessonProgress(completions: 1);
      expectEq(PathLogic.nextLessonId(course.manifest, p), 'u1.l2');
      expectTrue(PathLogic.isUnlocked(course.manifest, p, 'u1.l2'));
      expectFalse(PathLogic.isUnlocked(course.manifest, p, 'u1.l3'));
      // Completed lessons stay replayable.
      expectTrue(PathLogic.isUnlocked(course.manifest, p, 'u1.l1'));
      expectClose(PathLogic.unitProgress(course.manifest.units.first, p), 1 / 3);
      expectClose(PathLogic.lessonProgress(course.manifest, p), 1 / 3);
    });

    test('unknown lesson ids are locked', () {
      final course = buildCourse([mixedLesson('u1.l1')]);
      final p = Progress.fresh(now: now);
      expectFalse(PathLogic.isUnlocked(course.manifest, p, 'nope'));
    });
  });

  group('Review session building', () {
    test('returns null when nothing was completed yet', () {
      final course = buildCourse([mixedLesson('u1.l1')]);
      final p = Progress.fresh(now: now);
      expectEq(
        SessionBuilder.reviewSession(
          manifest: course.manifest,
          units: course.units,
          progress: p,
          now: now,
        ),
        null,
      );
      expectEq(SessionBuilder.dueCount(p, now), 0);
    });

    test('picks due lessons, weak exercises first, round-robin', () {
      final lessons = [
        lesson('u1.l1', [mcq('u1.l1.e1'), mcq('u1.l1.e2'), mcq('u1.l1.e3')]),
        lesson('u1.l2', [mcq('u1.l2.e1'), mcq('u1.l2.e2'), mcq('u1.l2.e3')]),
        lesson('u1.l3', [mcq('u1.l3.e1'), mcq('u1.l3.e2'), mcq('u1.l3.e3')]),
      ];
      final course = buildCourse(lessons);
      final p = Progress.fresh(now: now);

      SrsRecord dueAt(DateTime d) => SrsRecord(
            ease: 2.5,
            intervalDays: 1,
            reps: 1,
            lapses: 0,
            dueAt: d,
          );

      // l1 due since yesterday, l2 due 3 days ago, l3 not due for a week.
      p.lessons['u1.l1'] = LessonProgress(completions: 1, srs: dueAt(now.subtract(const Duration(days: 1))));
      p.lessons['u1.l2'] = LessonProgress(completions: 1, srs: dueAt(now.subtract(const Duration(days: 3))));
      p.lessons['u1.l3'] = LessonProgress(completions: 1, srs: dueAt(now.add(const Duration(days: 7))));
      // l1.e2 is the weakest exercise overall.
      p.exerciseStats['u1.l1.e2'] = ExerciseStats(right: 0, wrong: 3);
      p.exerciseStats['u1.l1.e3'] = ExerciseStats(right: 2, wrong: 1);

      expectEq(SessionBuilder.dueCount(p, now), 2);

      final spec = SessionBuilder.reviewSession(
        manifest: course.manifest,
        units: course.units,
        progress: p,
        now: now,
      )!;
      expectEq(spec.kind, SessionKind.review);
      expectEq(spec.baseXp, config.practiceXp);

      // Most overdue lesson first; in l1 the weakest exercise leads.
      expectEq(spec.items[0].lessonId, 'u1.l2');
      expectEq(spec.items[1].lessonId, 'u1.l1');
      expectEq(spec.items[1].exercise.id, 'u1.l1.e2');

      // Round-robin: items alternate lessons while both have depth.
      expectEq(spec.items[0].lessonId, 'u1.l2');
      expectEq(spec.items[2].lessonId, 'u1.l2');

      // 2 lessons x 3 exercises each = 6, within caps.
      expectEq(spec.items.length, 6);
      // No l3 exercises selected.
      expectTrue(spec.items.every((i) => i.lessonId != 'u1.l3'));
    });

    test('caps exercises per lesson and in total', () {
      final lessons = [
        lesson('u1.l1', [for (var i = 0; i < 10; i++) mcq('u1.l1.e$i')]),
      ];
      final course = buildCourse(lessons);
      final p = Progress.fresh(now: now);
      p.lessons['u1.l1'] = LessonProgress(
        completions: 1,
        srs: SrsRecord(ease: 2.5, intervalDays: 1, reps: 1, lapses: 0, dueAt: now.subtract(const Duration(hours: 1))),
      );
      final spec = SessionBuilder.reviewSession(
        manifest: course.manifest,
        units: course.units,
        progress: p,
        now: now,
      )!;
      expectEq(spec.items.length, config.reviewExercisesPerLesson);
    });

    test('falls back to weakest lessons when nothing is due', () {
      final lessons = [mixedLesson('u1.l1'), mixedLesson('u1.l2')];
      final course = buildCourse(lessons);
      final p = Progress.fresh(now: now);
      p.lessons['u1.l1'] = LessonProgress(
        completions: 1,
        srs: SrsRecord(ease: 2.4, intervalDays: 6, reps: 2, lapses: 0, dueAt: now.add(const Duration(days: 5))),
      );
      p.lessons['u1.l2'] = LessonProgress(
        completions: 1,
        srs: SrsRecord(ease: 2.6, intervalDays: 6, reps: 2, lapses: 0, dueAt: now.add(const Duration(days: 3))),
      );
      final spec = SessionBuilder.reviewSession(
        manifest: course.manifest,
        units: course.units,
        progress: p,
        now: now,
      )!;
      // Weakest (lowest ease) first.
      expectEq(spec.items.first.lessonId, 'u1.l1');
      expectEq(SessionBuilder.dueCount(p, now), 0);
    });

    test('ignores tracked lessons that no longer exist in content', () {
      final course = buildCourse([mixedLesson('u1.l1')]);
      final p = Progress.fresh(now: now);
      p.lessons['ghost.lesson'] = LessonProgress(
        completions: 1,
        srs: SrsRecord(ease: 2.5, intervalDays: 1, reps: 1, lapses: 0, dueAt: now.subtract(const Duration(days: 1))),
      );
      // dueCount is content-agnostic (a simple badge count); the builder
      // itself resolves against real content and returns null here.
      expectEq(SessionBuilder.dueCount(p, now), 1);
      expectEq(
        SessionBuilder.reviewSession(
          manifest: course.manifest,
          units: course.units,
          progress: p,
          now: now,
        ),
        null,
      );
    });
  });
}

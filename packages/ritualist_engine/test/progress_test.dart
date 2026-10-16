import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

void main() {
  const config = GameConfig();

  group('Hearts regeneration', () {
    test('full hearts stay full and re-anchor the clock', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.hearts = config.maxHearts;
      p.heartsUpdatedAt = now.subtract(const Duration(hours: 5));
      expectFalse(p.applyHeartRegen(now, config));
      expectEq(p.hearts, 5);
      expectEq(p.heartsUpdatedAt, now);
    });

    test('regenerates one heart per 30 minutes', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.hearts = 2;
      p.heartsUpdatedAt = now.subtract(const Duration(minutes: 65));

      expectTrue(p.applyHeartRegen(now, config));
      expectEq(p.hearts, 4); // 2 gained
      // Clock advanced by exactly the two full 30-min periods.
      expectEq(p.heartsUpdatedAt, now.subtract(const Duration(minutes: 5)));
    });

    test('clamps at max and re-anchors', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.hearts = 1;
      p.heartsUpdatedAt = now.subtract(const Duration(hours: 6));
      expectTrue(p.applyHeartRegen(now, config));
      expectEq(p.hearts, 5);
      expectEq(p.heartsUpdatedAt, now);
    });

    test('no regen below one full interval', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.hearts = 3;
      p.heartsUpdatedAt = now.subtract(const Duration(minutes: 29));
      expectFalse(p.applyHeartRegen(now, config));
      expectEq(p.hearts, 3);
    });

    test('minutesToNextHeart', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      expectEq(p.minutesToNextHeart(now, config), null);
      p.hearts = 4;
      p.heartsUpdatedAt = now.subtract(const Duration(minutes: 10));
      expectEq(p.minutesToNextHeart(now, config), 20);
    });
  });

  group('Streak', () {
    test('first activity starts the streak', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      expectEq(p.displayStreak(now), 0);
      expectTrue(p.touchStreak(now));
      expectEq(p.currentStreak, 1);
      expectEq(p.displayStreak(now), 1);
      expectFalse(p.touchStreak(now)); // same day: no double count
      expectEq(p.currentStreak, 1);
    });

    test('consecutive days increment, gap resets', () {
      final p = Progress.fresh(now: refNow());
      p.touchStreak(DateTime(2026, 10, 14, 20));
      p.touchStreak(DateTime(2026, 10, 15, 8));
      expectEq(p.currentStreak, 2);
      expectEq(p.longestStreak, 2);
      // Still displayed as alive on the 16th before practicing.
      expectEq(p.displayStreak(DateTime(2026, 10, 16, 9)), 2);
      // Skipping the 16th: broken on the 17th.
      expectEq(p.displayStreak(DateTime(2026, 10, 17, 9)), 0);
      p.touchStreak(DateTime(2026, 10, 17, 9));
      expectEq(p.currentStreak, 1);
      expectEq(p.longestStreak, 2);
    });
  });

  group('XP and daily goal', () {
    test('addXp accumulates per day and total', () {
      final p = Progress.fresh(now: refNow());
      p.addXp(10, refNow());
      p.addXp(5, DateTime(2026, 10, 16, 23));
      expectEq(p.xpToday(refNow()), 15);
      expectEq(p.totalXp, 15);
      p.addXp(20, DateTime(2026, 10, 17, 0, 5));
      expectEq(p.xpToday(refNow()), 15);
      expectEq(p.totalXp, 35);
    });

    test('goal progress clamps to 1', () {
      final p = Progress.fresh(now: refNow())..dailyGoalXp = 20;
      expectFalse(p.goalReachedToday(refNow()));
      p.addXp(25, refNow());
      expectTrue(p.goalReachedToday(refNow()));
      expectClose(p.dailyGoalProgress(refNow()), 1.0);
    });

    test('daily history is pruned on save', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.dailyXp['2026-01-01'] = 10; // ancient
      p.dailyXp['2026-10-10'] = 10; // within 60 days
      p.encode(now: now);
      expectFalse(p.dailyXp.containsKey('2026-01-01'));
      expectTrue(p.dailyXp.containsKey('2026-10-10'));
    });
  });

  group('applySessionResult', () {
    test('passed lesson: XP, streak, lesson record, SRS init, stats', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      final lsn = mixedLesson('u1.l1');
      final runner = LessonRunner(
        spec: SessionBuilder.lessonSession(lsn),
        startHearts: p.hearts,
        clock: FakeClock(now),
      );
      final result = playSession(runner, (_, __) => true);
      applySessionResult(p, runner.spec, result, now: now);

      expectEq(p.totalXp, 15);
      expectEq(p.xpToday(now), 15);
      expectEq(p.currentStreak, 1);
      expectFalse(p.goalReachedToday(now)); // goal 20 > 15
      final lp = p.lessons['u1.l1']!;
      expectEq(lp.completions, 1);
      expectClose(lp.bestAccuracy, 1.0);
      expectEq(lp.lastCompletedAt, now);
      expectEq(lp.srs?.intervalDays, 1);
      expectEq(lp.srs?.dueAt, now.add(const Duration(days: 1)));
      expectEq(p.exerciseStats['u1.l1.e1']?.right, 1);
    });

    test('failed lesson credits nothing but keeps hearts spent', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      final lsn = lesson('u1.l1', [mcq('u1.l1.e1'), mcq('u1.l1.e2')]);
      final runner = LessonRunner(
        spec: SessionBuilder.lessonSession(lsn),
        startHearts: 1,
        clock: FakeClock(now),
      );
      final result = playSession(runner, (_, __) => false);
      applySessionResult(p, runner.spec, result, now: now);

      expectEq(p.totalXp, 0);
      expectEq(p.currentStreak, 0);
      expectEq(p.lessons.containsKey('u1.l1'), false);
      expectEq(p.hearts, 0);
      expectEq(p.heartsUpdatedAt, now); // anchored at the heart loss
      expectEq(p.exerciseStats.isEmpty, true); // failed: nothing credited
    });

    test('abandoned session keeps only the hearts write-back', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      final lsn = lesson('u1.l1', [mcq('u1.l1.e1')]);
      final runner = LessonRunner(
        spec: SessionBuilder.lessonSession(lsn),
        startHearts: 5,
        clock: FakeClock(now),
      );
      runner.submit(const MultipleChoiceAnswer(9));
      final result = runner.abandon();
      applySessionResult(p, runner.spec, result, now: now);

      expectEq(p.hearts, 4);
      expectEq(p.totalXp, 0);
      expectEq(p.exerciseStats.isEmpty, true); // stats skipped
    });

    test('passed review: interval grows, heart restored, practice XP', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.hearts = 3;
      // Lesson completed yesterday, due today.
      p.lessons['u1.l1'] = LessonProgress(
        completions: 1,
        bestAccuracy: 1.0,
        lastCompletedAt: now.subtract(const Duration(days: 1)),
        srs: SrsRecord.initial(now.subtract(const Duration(days: 1))),
      );
      final lsn = mixedLesson('u1.l1');
      final uf = unitFile('u1', [lsn]);
      final manifest = manifestOf('u1', [lsn]);

      final spec = SessionBuilder.reviewSession(
        manifest: manifest,
        units: {'u1': uf},
        progress: p,
        now: now,
      );
      expectTrue(spec != null);
      final runner = LessonRunner(
        spec: spec!,
        startHearts: p.hearts,
        clock: FakeClock(now),
      );
      final result = playSession(runner, (_, __) => true);
      applySessionResult(p, runner.spec, result, now: now);

      expectEq(result.xpEarned, 10); // 5 practice + 5 perfect
      expectEq(p.totalXp, 10);
      final srs = p.lessons['u1.l1']!.srs!;
      expectEq(srs.reps, 2);
      expectEq(srs.intervalDays, 6);
      expectEq(p.hearts, 4); // practice restored one heart
    });

    test('review with multiple mistakes resets the lesson to a lapse', () {
      final now = refNow();
      final p = Progress.fresh(now: now);
      p.lessons['u1.l1'] = LessonProgress(
        completions: 1,
        bestAccuracy: 1.0,
        lastCompletedAt: now.subtract(const Duration(days: 1)),
        srs: SrsRecord.initial(now.subtract(const Duration(days: 1)))
            .reviewed(5, now.subtract(const Duration(days: 1))), // reps 2, 6 days
      );
      final lsn = mixedLesson('u1.l1');
      final uf = unitFile('u1', [lsn]);
      final manifest = manifestOf('u1', [lsn]);
      final spec = SessionBuilder.reviewSession(
        manifest: manifest,
        units: {'u1': uf},
        progress: p,
        now: now,
      )!;
      final runner = LessonRunner(
        spec: spec,
        startHearts: p.hearts,
        clock: FakeClock(now),
      );
      final result = playSession(runner, (i, _) => i > 2); // first three wrong
      applySessionResult(p, runner.spec, result, now: now);
      final srs = p.lessons['u1.l1']!.srs!;
      expectEq(srs.lapses, 1);
      expectEq(srs.intervalDays, 1);
    });
  });
}

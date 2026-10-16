import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

void main() {
  group('Exercise JSON round-trips', () {
    test('multipleChoice', () {
      final e = mcq('x.e1', correct: 2);
      final json = e.toJson();
      final back = Exercise.fromJson(json);
      expectTrue(back is MultipleChoiceExercise);
      final m = back as MultipleChoiceExercise;
      expectEq(m.options.length, 3);
      expectEq(m.correctIndex, 2);
      expectEq(m.source, src('x.e1'));
      expectEq(m.explanation, 'Explanation for x.e1.');
      expectEq(m.toJson(), json);
    });

    test('orderSteps', () {
      final e = orderEx('x.e2', stepCount: 5);
      final back = Exercise.fromJson(e.toJson());
      expectTrue(back is OrderStepsExercise);
      expectEq((back as OrderStepsExercise).steps.length, 5);
      expectEq(back.toJson(), e.toJson());
    });

    test('matchPairs', () {
      final e = matchEx('x.e3', pairCount: 6);
      final back = Exercise.fromJson(e.toJson());
      expectTrue(back is MatchPairsExercise);
      expectEq((back as MatchPairsExercise).pairs.length, 6);
      expectEq(back.toJson(), e.toJson());
    });

    test('unknown type fails loudly', () {
      expectThrows(() => Exercise.fromJson(<String, Object?>{
            'id': 'bad',
            'type': 'telepathy',
            'prompt': 'P',
          }));
    });

    test('arabic text round-trips when present', () {
      const option = AnswerOption(text: 'In the name of Allah', arabic: 'بسم الله');
      final back = AnswerOption.fromJson(option.toJson());
      expectEq(back, option);
      expectEq(back.arabic, 'بسم الله');
    });
  });

  group('Exercise grading', () {
    test('multipleChoice checks index and rejects wrong answer type', () {
      final e = mcq('x.e1', correct: 1);
      expectTrue(e.check(const MultipleChoiceAnswer(1)));
      expectFalse(e.check(const MultipleChoiceAnswer(0)));
      expectThrows(() => e.check(const MatchPairsAnswer(missed: 0)));
      expectEq(e.solution, 'Option 1');
      expectTrue(e.costsHeartOnWrong);
    });

    test('orderSteps expects the identity arrangement', () {
      final e = orderEx('x.e2', stepCount: 3);
      expectTrue(e.check(const OrderStepsAnswer(<int>[0, 1, 2])));
      expectFalse(e.check(const OrderStepsAnswer(<int>[0, 2, 1])));
      expectFalse(e.check(const OrderStepsAnswer(<int>[0, 1])));
      expectEq(e.solution, 'Step 0  →  Step 1  →  Step 2');
    });

    test('matchPairs grades on missed pairings and is heart-free', () {
      final e = matchEx('x.e3', pairCount: 4);
      expectTrue(e.check(const MatchPairsAnswer(missed: 0)));
      expectFalse(e.check(const MatchPairsAnswer(missed: 1)));
      expectTrue(e.isMatchCorrect(2, 2));
      expectFalse(e.isMatchCorrect(2, 3));
      expectFalse(e.costsHeartOnWrong);
    });
  });

  group('Deterministic shuffles', () {
    test('display orders are stable permutations and never identity', () {
      final steps = orderEx('x.e2', stepCount: 5);
      final a = stepDisplayOrder(steps, fnv1a(steps.id));
      final b = stepDisplayOrder(steps, fnv1a(steps.id));
      expectEq(a, b);
      final sorted = a.toList()..sort();
      expectEq(sorted, <int>[0, 1, 2, 3, 4]);
      expectFalse(a[0] == 0 && a[1] == 1 && a[2] == 2 && a[3] == 3 && a[4] == 4);

      final match = matchEx('x.e3', pairCount: 4);
      final order = matchRightDisplayOrder(match, fnv1a(match.id));
      expectEq(order.toList()..sort(), <int>[0, 1, 2, 3]);
    });

    test('fnv1a is deterministic and spreads different inputs', () {
      expectEq(fnv1a('islam.taharah.l1.e1'), fnv1a('islam.taharah.l1.e1'));
      expectFalse(fnv1a('a') == fnv1a('b'));
    });
  });

  group('Module JSON', () {
    test('manifest round-trips with lesson order', () {
      final lessons = [mixedLesson('m.u1.l1'), mixedLesson('m.u1.l2')];
      final manifest = manifestOf('m.u1', lessons);
      final back = ModuleManifest.fromJson(manifest.toJson());
      expectEq(back.id, 'islam');
      expectEq(back.lessonOrder, <String>['m.u1.l1', 'm.u1.l2']);
      expectEq(back.unitForLesson('m.u1.l2')?.id, 'm.u1');
      expectEq(back.unitForLesson('nope'), null);
      expectEq(back.units.first.lessons.first.exerciseCount, 3);
    });

    test('unit file round-trips with full lesson bodies', () {
      final uf = unitFile('m.u1', [mixedLesson('m.u1.l1')]);
      final back = UnitFile.fromJson(uf.toJson());
      expectEq(back.unitId, 'm.u1');
      expectEq(back.lessons.length, 1);
      expectEq(back.lessonById('m.u1.l1')?.exercises.length, 3);
      expectEq(back.lessonById('missing'), null);
      expectEq(back.toJson(), uf.toJson());
    });
  });

  group('Progress JSON', () {
    test('round-trips full state', () {
      final now = refNow();
      final p = Progress.fresh(now: now)..onboarded = true;
      p.hearts = 3;
      p.heartsUpdatedAt = now.subtract(const Duration(minutes: 10));
      p.totalXp = 42;
      p.dailyGoalXp = 30;
      p.dailyXp['2026-10-16'] = 25;
      p.currentStreak = 4;
      p.longestStreak = 7;
      p.lastStreakDay = '2026-10-15';
      final lp = LessonProgress(completions: 2)
        ..bestAccuracy = 0.9
        ..lastCompletedAt = now
        ..srs = SrsRecord.initial(now);
      p.lessons['m.u1.l1'] = lp;
      p.exerciseStats['m.u1.l1.e1'] = ExerciseStats(right: 3, wrong: 1);

      final encoded = p.encode(now: now);
      final back = Progress.decode(encoded);
      expectEq(back.totalXp, 42);
      expectEq(back.dailyGoalXp, 30);
      expectEq(back.dailyXp['2026-10-16'], 25);
      expectEq(back.hearts, 3);
      expectEq(back.currentStreak, 4);
      expectEq(back.lastStreakDay, '2026-10-15');
      expectEq(back.onboarded, true);
      expectEq(back.lessons['m.u1.l1']?.completions, 2);
      expectClose(back.lessons['m.u1.l1']!.bestAccuracy, 0.9);
      expectEq(back.lessons['m.u1.l1']?.srs?.intervalDays, 1);
      expectEq(back.exerciseStats['m.u1.l1.e1']?.wrong, 1);
    });

    test('decodes minimal/partial JSON with defaults', () {
      final back = Progress.decode('{}');
      expectEq(back.hearts, 5);
      expectEq(back.totalXp, 0);
      expectEq(back.dailyGoalXp, 20);
      expectEq(back.onboarded, false);
      expectEq(back.lessons.isEmpty, true);
    });
  });
}

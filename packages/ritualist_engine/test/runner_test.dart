import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

LessonRunner runnerFor(
  Lesson lsn, {
  int hearts = 5,
  SessionKind kind = SessionKind.lesson,
  GameConfig config = const GameConfig(),
  FakeClock? clock,
}) {
  final spec = SessionBuilder.lessonSession(lsn);
  final effectiveSpec = kind == SessionKind.lesson
      ? spec
      : SessionSpec(
          kind: SessionKind.review,
          title: spec.title,
          baseXp: config.practiceXp,
          items: spec.items,
        );
  return LessonRunner(
    spec: effectiveSpec,
    startHearts: hearts,
    config: config,
    clock: clock ?? FakeClock(refNow()),
  );
}

void main() {
  group('Happy path', () {
    test('perfect lesson completes with full XP and combo', () {
      final lsn = mixedLesson('t.l1');
      final runner = runnerFor(lsn);
      final result = playSession(runner, (_, __) => true);

      expectEq(runner.phase, RunnerPhase.complete);
      expectTrue(result.passed);
      expectFalse(result.abandoned);
      expectEq(result.answers, 3);
      expectEq(result.mistakes, 0);
      expectEq(result.heartsLost, 0);
      expectEq(result.heartsRemaining, 5);
      expectEq(result.xpEarned, 15); // 10 base + 5 perfect bonus
      expectEq(result.bestCombo, 3);
      expectClose(result.accuracy, 1.0);
      expectEq(result.lessons['t.l1']?.answers, 3);
      expectEq(runner.progress, 1.0);
    });

    test('progress bar advances per distinct exercise', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1'), mcq('t.l1.e2')]);
      final runner = runnerFor(lsn);
      expectEq(runner.progress, 0.0);
      runner.submit(const MultipleChoiceAnswer(0));
      expectEq(runner.progress, 0.5);
      runner.next();
      expectEq(runner.progress, 0.5);
      runner.submit(const MultipleChoiceAnswer(0));
      expectEq(runner.progress, 1.0);
      runner.next();
      expectEq(runner.phase, RunnerPhase.complete);
    });
  });

  group('Mistakes and re-injection', () {
    test('wrong answers are re-queued once and reset the combo', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1'), mcq('t.l1.e2')]);
      final runner = runnerFor(lsn);
      var questions = 0;
      final result = playSession(runner, (i, _) {
        questions++;
        return i >= 2; // first two wrong, then correct on re-injection
      });

      // Two originals + two re-injections.
      expectEq(questions, 4);
      expectEq(result.answers, 4);
      expectEq(result.mistakes, 2);
      expectEq(result.heartsLost, 2);
      expectEq(result.heartsRemaining, 3);
      expectTrue(result.passed);
      expectEq(result.xpEarned, 10); // base only, no perfect bonus
      expectEq(result.bestCombo, 2); // two correct re-injections in a row
    });

    test('a re-injected exercise is never queued a third time', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1')]);
      final runner = runnerFor(lsn);
      final result = playSession(runner, (_, __) => false); // always wrong

      expectEq(result.answers, 2); // original + one re-injection, then done
      expectEq(result.mistakes, 2);
      expectTrue(result.passed); // finished, though not perfect
      expectEq(result.heartsLost, 2);
    });

    test('match mistakes cost accuracy but no heart', () {
      final lsn = lesson('t.l1', [matchEx('t.l1.e1')]);
      final runner = runnerFor(lsn);
      final feedback = runner.submit(const MatchPairsAnswer(missed: 2));
      expectFalse(feedback.correct);
      expectFalse(feedback.heartLost);
      expectEq(feedback.heartsRemaining, 5);
      expectEq(feedback.solution, 'L0  —  R0\nL1  —  R1\nL2  —  R2\nL3  —  R3');
    });

    test('feedback carries explanation and source', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1')]);
      final runner = runnerFor(lsn);
      final feedback = runner.submit(const MultipleChoiceAnswer(1));
      expectFalse(feedback.correct);
      expectTrue(feedback.heartLost);
      expectEq(feedback.solution, 'Option 0');
      expectEq(feedback.explanation, 'Explanation for t.l1.e1.');
      expectEq(feedback.source, src('t.l1.e1'));
      expectEq(feedback.combo, 0);
    });
  });

  group('Hearts', () {
    test('running out of hearts fails the session after the feedback', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1'), mcq('t.l1.e2')]);
      final runner = runnerFor(lsn, hearts: 1);
      final feedback = runner.submit(const MultipleChoiceAnswer(1));
      expectTrue(feedback.heartLost);
      expectEq(feedback.heartsRemaining, 0);
      expectEq(runner.phase, RunnerPhase.feedback);
      runner.next();
      expectEq(runner.phase, RunnerPhase.failed);

      final result = runner.buildResult();
      expectFalse(result.passed);
      expectEq(result.xpEarned, 0);
      expectEq(result.heartsRemaining, 0);
      expectEq(result.heartsLost, 1);
      expectTrue(result.lastHeartLossAt != null);
    });

    test('review sessions are heart-free', () {
      final lsn = lesson('t.l1', [mcq('t.l1.e1'), mcq('t.l1.e2')]);
      final runner = runnerFor(lsn, kind: SessionKind.review, hearts: 0);
      final result = playSession(runner, (_, __) => false);
      expectEq(result.heartsLost, 0);
      expectEq(result.heartsRemaining, 0);
      expectTrue(result.passed);
      // 2 originals + 2 re-injections, all wrong.
      expectEq(result.mistakes, 4);
      expectEq(result.answers, 4);
    });

    test('lesson cannot start with zero hearts', () {
      final lsn = mixedLesson('t.l1');
      expectThrows(() => runnerFor(lsn, hearts: 0));
    });
  });

  group('Result bookkeeping', () {
    test('duration uses the injected clock', () {
      final clock = FakeClock(refNow());
      final runner = runnerFor(lesson('t.l1', [mcq('t.l1.e1')]), clock: clock);
      runner.submit(const MultipleChoiceAnswer(0));
      clock.advance(const Duration(seconds: 30));
      runner.next();
      final result = runner.buildResult();
      expectEq(result.duration, const Duration(seconds: 30));
    });

    test('abandon credits nothing but keeps hearts spend', () {
      final runner = runnerFor(lesson('t.l1', [mcq('t.l1.e1')]), hearts: 3);
      runner.submit(const MultipleChoiceAnswer(9)); // wrong -> heart lost
      final result = runner.abandon();
      expectFalse(result.passed);
      expectTrue(result.abandoned);
      expectEq(result.xpEarned, 0);
      expectEq(result.heartsRemaining, 2);
    });

    test('review session aggregates lessons across multiple ids', () {
      final spec = SessionSpec(
        kind: SessionKind.review,
        title: 'Practice',
        baseXp: 5,
        items: [
          SessionItem(lessonId: 'u1.l1', exercise: mcq('e1'), seed: 1),
          SessionItem(lessonId: 'u2.l1', exercise: mcq('e2'), seed: 2),
          SessionItem(lessonId: 'u1.l1', exercise: mcq('e3'), seed: 3),
        ],
      );
      final runner = LessonRunner(
        spec: spec,
        startHearts: 5,
        clock: FakeClock(refNow()),
      );
      final result = playSession(runner, (i, _) => i != 1);
      expectEq(result.lessons['u1.l1']?.answers, 2);
      expectEq(result.lessons['u1.l1']?.mistakes, 0);
      expectEq(result.lessons['u2.l1']?.mistakes, 1);
    });

    test('invalid calls throw', () {
      final runner = runnerFor(mixedLesson('t.l1'));
      expectThrows(() => runner.next()); // not in feedback phase
      runner.submit(const MultipleChoiceAnswer(0));
      expectThrows(() => runner.submit(const MultipleChoiceAnswer(0)));
      runner.next();
      // Second exercise is an orderSteps - a multipleChoice answer is a bug.
      expectThrows(() => runner.submit(const MultipleChoiceAnswer(0)));
    });
  });
}

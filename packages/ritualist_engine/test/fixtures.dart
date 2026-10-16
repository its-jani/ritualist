import 'package:ritualist_engine/ritualist_engine.dart';

/// Deterministic clock for tests.
class FakeClock {
  FakeClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

/// A fixed reference instant (Friday, 2026-10-16, 09:00 local).
DateTime refNow() => DateTime(2026, 10, 16, 9, 0);

SourceRef src([String reference = '1']) => SourceRef(
      collection: 'Sahih al-Bukhari',
      reference: reference,
      grading: 'sahih',
      text: 'Source text $reference.',
    );

MultipleChoiceExercise mcq(
  String id, {
  int correct = 0,
  int optionCount = 3,
  bool withSource = true,
}) {
  return MultipleChoiceExercise(
    id: id,
    prompt: 'Prompt for $id',
    options: [
      for (var i = 0; i < optionCount; i++) AnswerOption(text: 'Option $i'),
    ],
    correctIndex: correct,
    explanation: 'Explanation for $id.',
    source: withSource ? src(id) : null,
  );
}

OrderStepsExercise orderEx(String id, {int stepCount = 4}) {
  return OrderStepsExercise(
    id: id,
    prompt: 'Order the steps of $id',
    steps: [
      for (var i = 0; i < stepCount; i++) AnswerOption(text: 'Step $i'),
    ],
    explanation: 'Explanation for $id.',
    source: src(id),
  );
}

MatchPairsExercise matchEx(String id, {int pairCount = 4}) {
  return MatchPairsExercise(
    id: id,
    prompt: 'Match the pairs of $id',
    pairs: [
      for (var i = 0; i < pairCount; i++)
        MatchPair(left: 'L$i', right: 'R$i'),
    ],
    explanation: 'Explanation for $id.',
    source: src(id),
  );
}

Lesson lesson(String id, List<Exercise> exercises, {String? title, int xp = 10}) {
  return Lesson(
    id: id,
    title: title ?? 'Lesson $id',
    xp: xp,
    exercises: exercises,
  );
}

/// A lesson with one exercise of each type.
Lesson mixedLesson(String id) => lesson(id, [
      mcq('$id.e1'),
      orderEx('$id.e2'),
      matchEx('$id.e3'),
    ]);

UnitFile unitFile(String unitId, List<Lesson> lessons) =>
    UnitFile(unitId: unitId, lessons: lessons);

ModuleManifest manifestOf(
  String unitId,
  List<Lesson> lessons, {
  String moduleId = 'islam',
}) {
  return ModuleManifest(
    schemaVersion: 1,
    id: moduleId,
    title: 'Test Module',
    tagline: 'tag',
    description: 'desc',
    units: [
      ModuleUnit(
        id: unitId,
        title: 'Unit',
        subtitle: 'sub',
        colorIndex: 0,
        file: 'units/$unitId.json',
        lessons: [
          for (final l in lessons)
            LessonSummary(
              id: l.id,
              title: l.title,
              exerciseCount: l.exerciseCount,
            ),
        ],
      ),
    ],
  );
}

/// Runs a whole session by answering everything, using [answerCorrectly] to
/// decide each answer (return true to answer correctly).
SessionResult playSession(
  LessonRunner runner,
  bool Function(int questionIndex, SessionItem item) answerCorrectly,
) {
  var question = 0;
  while (runner.phase == RunnerPhase.answering) {
    final item = runner.currentItem!;
    final beCorrect = answerCorrectly(question, item);
    final exercise = item.exercise;
    final ExerciseAnswer answer;
    switch (exercise) {
      case MultipleChoiceExercise():
        answer = MultipleChoiceAnswer(beCorrect ? exercise.correctIndex : (exercise.correctIndex + 1) % exercise.options.length);
      case OrderStepsExercise():
        answer = OrderStepsAnswer(beCorrect
            ? List<int>.generate(exercise.steps.length, (i) => i)
            : List<int>.generate(exercise.steps.length, (i) => (i + 1) % exercise.steps.length));
      case MatchPairsExercise():
        answer = MatchPairsAnswer(missed: beCorrect ? 0 : 1);
    }
    runner.submit(answer);
    question++;
    if (runner.phase == RunnerPhase.feedback) {
      runner.next();
    }
  }
  return runner.buildResult();
}

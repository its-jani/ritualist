import '../util/json_util.dart';
import '../util/prng.dart';
import 'source_ref.dart';

/// One answer option / step / pair half with optional Arabic script.
class AnswerOption {
  const AnswerOption({required this.text, this.arabic});

  final String text;
  final String? arabic;

  factory AnswerOption.fromJson(Map<String, Object?> m) => AnswerOption(
        text: reqStr(m, 'text'),
        arabic: optStr(m, 'arabic'),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
        if (arabic != null) 'arabic': arabic,
      };

  @override
  bool operator ==(Object other) =>
      other is AnswerOption && other.text == text && other.arabic == arabic;

  @override
  int get hashCode => Object.hash(text, arabic);

  @override
  String toString() => text;
}

/// A left/right pair for matching exercises (e.g. Arabic term -> English meaning).
class MatchPair {
  const MatchPair({
    required this.left,
    required this.right,
    this.leftArabic,
    this.rightArabic,
  });

  final String left;
  final String right;
  final String? leftArabic;
  final String? rightArabic;

  factory MatchPair.fromJson(Map<String, Object?> m) => MatchPair(
        left: reqStr(m, 'left'),
        right: reqStr(m, 'right'),
        leftArabic: optStr(m, 'leftArabic'),
        rightArabic: optStr(m, 'rightArabic'),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'left': left,
        'right': right,
        if (leftArabic != null) 'leftArabic': leftArabic,
        if (rightArabic != null) 'rightArabic': rightArabic,
      };

  @override
  bool operator ==(Object other) =>
      other is MatchPair &&
      other.left == left &&
      other.right == right &&
      other.leftArabic == leftArabic &&
      other.rightArabic == rightArabic;

  @override
  int get hashCode => Object.hash(left, right, leftArabic, rightArabic);
}

/// User answers produced by the UI. One subtype per exercise type.
sealed class ExerciseAnswer {
  const ExerciseAnswer();
}

class MultipleChoiceAnswer extends ExerciseAnswer {
  const MultipleChoiceAnswer(this.index);
  final int index;
}

/// [order] holds original step indices in the order the user arranged them.
/// A correct answer is exactly `[0, 1, ... n-1]` because steps are stored in
/// their correct order.
class OrderStepsAnswer extends ExerciseAnswer {
  const OrderStepsAnswer(this.order);
  final List<int> order;
}

/// Matching is checked incrementally by the UI tile-by-tile; by the time the
/// answer is submitted every pair has been matched, so only the number of
/// wrong pairing attempts ([missed]) remains relevant for grading.
class MatchPairsAnswer extends ExerciseAnswer {
  const MatchPairsAnswer({required this.missed});
  final int missed;
}

/// Base class of all exercises. A lesson is an ordered list of exercises.
sealed class Exercise {
  const Exercise({
    required this.id,
    required this.prompt,
    this.explanation,
    this.source,
  });

  final String id;
  final String prompt;
  final String? explanation;
  final SourceRef? source;

  /// Stable machine name, used in JSON and telemetry.
  String get type;

  /// True when [answer] is fully correct.
  bool check(ExerciseAnswer answer);

  /// Human-readable correct solution, shown on the red feedback panel.
  String get solution;

  /// Whether a wrong answer costs a heart. Matching is forgiving: a wrongly
  /// paired tile in a match exercise costs accuracy, not a heart.
  bool get costsHeartOnWrong => true;

  factory Exercise.fromJson(Map<String, Object?> m) {
    final type = reqStr(m, 'type');
    switch (type) {
      case MultipleChoiceExercise.typeName:
        return MultipleChoiceExercise.fromJson(m);
      case OrderStepsExercise.typeName:
        return OrderStepsExercise.fromJson(m);
      case MatchPairsExercise.typeName:
        return MatchPairsExercise.fromJson(m);
      default:
        throw FormatException('Unknown exercise type "$type" (id: ${m['id']})');
    }
  }

  Map<String, Object?> toJsonBase() => <String, Object?>{
        'id': id,
        'type': type,
        'prompt': prompt,
        if (explanation != null) 'explanation': explanation,
        if (source != null) 'source': source!.toJson(),
      };

  Map<String, Object?> toJson();
}

/// Classic multiple-choice: pick the one correct option.
class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.prompt,
    required this.options,
    required this.correctIndex,
    super.explanation,
    super.source,
  });

  static const String typeName = 'multipleChoice';

  final List<AnswerOption> options;
  final int correctIndex;

  factory MultipleChoiceExercise.fromJson(Map<String, Object?> m) {
    final sourceJson = optMap(m, 'source');
    return MultipleChoiceExercise(
      id: reqStr(m, 'id'),
      prompt: reqStr(m, 'prompt'),
      options: reqList(m, 'options')
          .map((o) => AnswerOption.fromJson(mapOf(o, 'option')))
          .toList(growable: false),
      correctIndex: reqInt(m, 'correctIndex'),
      explanation: optStr(m, 'explanation'),
      source: sourceJson == null ? null : SourceRef.fromJson(sourceJson),
    );
  }

  @override
  String get type => typeName;

  @override
  bool check(ExerciseAnswer answer) {
    if (answer is! MultipleChoiceAnswer) {
      throw ArgumentError('Expected MultipleChoiceAnswer, got ${answer.runtimeType}');
    }
    return answer.index == correctIndex;
  }

  @override
  String get solution => options[correctIndex].text;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...toJsonBase(),
        'options': options.map((o) => o.toJson()).toList(growable: false),
        'correctIndex': correctIndex,
      };
}

/// Arrange steps into the correct order (e.g. Wudu sequence).
class OrderStepsExercise extends Exercise {
  const OrderStepsExercise({
    required super.id,
    required super.prompt,
    required this.steps,
    super.explanation,
    super.source,
  });

  static const String typeName = 'orderSteps';

  /// Steps in their CORRECT order; the UI presents them shuffled.
  final List<AnswerOption> steps;

  factory OrderStepsExercise.fromJson(Map<String, Object?> m) {
    final sourceJson = optMap(m, 'source');
    return OrderStepsExercise(
      id: reqStr(m, 'id'),
      prompt: reqStr(m, 'prompt'),
      steps: reqList(m, 'steps')
          .map((o) => AnswerOption.fromJson(mapOf(o, 'step')))
          .toList(growable: false),
      explanation: optStr(m, 'explanation'),
      source: sourceJson == null ? null : SourceRef.fromJson(sourceJson),
    );
  }

  @override
  String get type => typeName;

  @override
  bool check(ExerciseAnswer answer) {
    if (answer is! OrderStepsAnswer) {
      throw ArgumentError('Expected OrderStepsAnswer, got ${answer.runtimeType}');
    }
    if (answer.order.length != steps.length) {
      return false;
    }
    for (var i = 0; i < steps.length; i++) {
      if (answer.order[i] != i) {
        return false;
      }
    }
    return true;
  }

  @override
  String get solution => steps.map((s) => s.text).join('  →  ');

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...toJsonBase(),
        'steps': steps.map((s) => s.toJson()).toList(growable: false),
      };
}

/// Match left tiles to right tiles (e.g. Arabic term -> English meaning).
class MatchPairsExercise extends Exercise {
  const MatchPairsExercise({
    required super.id,
    required super.prompt,
    required this.pairs,
    super.explanation,
    super.source,
  });

  static const String typeName = 'matchPairs';

  final List<MatchPair> pairs;

  factory MatchPairsExercise.fromJson(Map<String, Object?> m) {
    final sourceJson = optMap(m, 'source');
    return MatchPairsExercise(
      id: reqStr(m, 'id'),
      prompt: reqStr(m, 'prompt'),
      pairs: reqList(m, 'pairs')
          .map((o) => MatchPair.fromJson(mapOf(o, 'pair')))
          .toList(growable: false),
      explanation: optStr(m, 'explanation'),
      source: sourceJson == null ? null : SourceRef.fromJson(sourceJson),
    );
  }

  @override
  String get type => typeName;

  @override
  bool get costsHeartOnWrong => false;

  /// A left tile paired with a right tile is correct iff they belong to the
  /// same [MatchPair] entry.
  bool isMatchCorrect(int leftIndex, int rightIndex) => leftIndex == rightIndex;

  @override
  bool check(ExerciseAnswer answer) {
    if (answer is! MatchPairsAnswer) {
      throw ArgumentError('Expected MatchPairsAnswer, got ${answer.runtimeType}');
    }
    return answer.missed == 0;
  }

  @override
  String get solution =>
      pairs.map((p) => '${p.left}  —  ${p.right}').join('\n');

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...toJsonBase(),
        'pairs': pairs.map((p) => p.toJson()).toList(growable: false),
      };
}

/// Deterministic shuffled display order of an ordering exercise's steps.
/// [seed] comes from [SessionItem.seed]; the order is stable across restarts.
List<int> stepDisplayOrder(OrderStepsExercise exercise, int seed) =>
    displayOrder(exercise.steps.length, seed);

/// Deterministic shuffled display order of a matching exercise's right column.
List<int> matchRightDisplayOrder(MatchPairsExercise exercise, int seed) =>
    displayOrder(exercise.pairs.length, seed);

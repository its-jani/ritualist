import '../models/exercise.dart';
import '../models/module.dart';

/// A single content problem found by [ContentValidator].
class ValidationIssue {
  const ValidationIssue({
    required this.path,
    required this.message,
    this.isError = true,
  });

  final String path;
  final String message;
  final bool isError;

  @override
  String toString() => '${isError ? 'ERROR' : 'WARN '} $path: $message';
}

/// Structural linting for generated course content. The curriculum pipeline
/// runs this (via `tool/validate_content.dart`) before the app ever ships,
/// and the engine test suite runs it against the real Islam module.
///
/// Policy for the V1 Islam module: every exercise must carry an `explanation`
/// and a `source` (requireSources: true) so religious content is always
/// traceable.
class ContentValidator {
  const ContentValidator._();

  static final RegExp _idPattern = RegExp(r'^[a-z0-9][a-z0-9._-]*$');

  /// Validates a full module: manifest + every unit file.
  static List<ValidationIssue> validateModule({
    required ModuleManifest manifest,
    required Map<String, UnitFile> units,
    bool requireSources = false,
  }) {
    final issues = <ValidationIssue>[];
    void err(String path, String message) =>
        issues.add(ValidationIssue(path: path, message: message));

    if (!_idPattern.hasMatch(manifest.id)) {
      err('module', 'invalid module id "${manifest.id}"');
    }
    if (manifest.units.isEmpty) {
      err('module', 'has no units');
    }

    final seenLessonIds = <String>{};
    final seenExerciseIds = <String>{};

    for (final unit in manifest.units) {
      final upath = 'unit ${unit.id}';
      if (!_idPattern.hasMatch(unit.id)) {
        err(upath, 'invalid unit id');
      }
      if (unit.lessons.isEmpty) {
        err(upath, 'has no lessons');
      }
      final unitFile = units[unit.id];
      if (unitFile == null) {
        err(upath, 'no unit file provided for validation');
        continue;
      }
      if (unitFile.unitId != unit.id) {
        err(upath, 'unit file id mismatch ("${unitFile.unitId}")');
      }
      if (unitFile.lessons.length != unit.lessons.length) {
        err(upath,
            'lesson count mismatch: manifest=${unit.lessons.length} file=${unitFile.lessons.length}');
      }

      for (final summary in unit.lessons) {
        final lpath = 'lesson ${summary.id}';
        if (!_idPattern.hasMatch(summary.id)) {
          err(lpath, 'invalid lesson id');
        }
        if (!seenLessonIds.add(summary.id)) {
          err(lpath, 'duplicate lesson id');
        }
        final lesson = unitFile.lessonById(summary.id);
        if (lesson == null) {
          err(lpath, 'missing from unit file');
          continue;
        }
        if (lesson.title != summary.title) {
          err(lpath, 'title mismatch with manifest');
        }
        if (lesson.exercises.length != summary.exerciseCount) {
          err(lpath,
              'exercise count mismatch: manifest=${summary.exerciseCount} file=${lesson.exercises.length}');
        }
        if (lesson.exercises.isEmpty) {
          err(lpath, 'has no exercises');
        }
        if (lesson.xp <= 0) {
          err(lpath, 'xp must be positive');
        }
        for (final exercise in lesson.exercises) {
          _validateExercise(exercise, lpath, err, seenExerciseIds, requireSources);
        }
      }
    }

    return issues;
  }

  static void _validateExercise(
    Exercise e,
    String lessonPath,
    void Function(String, String) err,
    Set<String> seenIds,
    bool requireSources,
  ) {
    final path = '$lessonPath/${e.id}';
    if (!_idPattern.hasMatch(e.id)) {
      err(path, 'invalid exercise id');
    }
    if (!seenIds.add(e.id)) {
      err(path, 'duplicate exercise id');
    }
    if (requireSources && e.source == null) {
      err(path, 'missing source (required for this module)');
    }
    if (requireSources && (e.explanation == null || e.explanation!.trim().isEmpty)) {
      err(path, 'missing explanation (required for this module)');
    }

    switch (e) {
      case MultipleChoiceExercise():
        if (e.options.length < 2) {
          err(path, 'multipleChoice needs at least 2 options');
        }
        if (e.correctIndex < 0 || e.correctIndex >= e.options.length) {
          err(path, 'correctIndex ${e.correctIndex} out of range');
        }
        final optionTexts =
            e.options.map((o) => o.text.trim().toLowerCase()).toList();
        if (optionTexts.toSet().length != optionTexts.length) {
          err(path, 'duplicate option texts');
        }
      case OrderStepsExercise():
        if (e.steps.length < 3) {
          err(path, 'orderSteps needs at least 3 steps');
        }
        final stepTexts =
            e.steps.map((s) => s.text.trim().toLowerCase()).toList();
        if (stepTexts.toSet().length != stepTexts.length) {
          err(path, 'duplicate step texts');
        }
      case MatchPairsExercise():
        if (e.pairs.length < 3) {
          err(path, 'matchPairs needs at least 3 pairs');
        }
        final lefts = e.pairs.map((p) => p.left.trim().toLowerCase()).toList();
        final rights = e.pairs.map((p) => p.right.trim().toLowerCase()).toList();
        if (lefts.toSet().length != lefts.length) {
          err(path, 'duplicate left values');
        }
        if (rights.toSet().length != rights.length) {
          err(path, 'duplicate right values');
        }
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

void main() {
  group('ContentValidator (synthetic)', () {
    test('accepts a well-formed module', () {
      final lessons = [mixedLesson('u1.l1'), mixedLesson('u1.l2')];
      final manifest = manifestOf('u1', lessons);
      final issues = ContentValidator.validateModule(
        manifest: manifest,
        units: {'u1': unitFile('u1', lessons)},
        requireSources: true,
      );
      expectEq(issues, <ValidationIssue>[]);
    });

    test('flags structural problems', () {
      final badLesson = Lesson(
        id: 'u1.l1',
        title: 'Bad',
        xp: 10,
        exercises: [
          // correctIndex out of range + duplicate options.
          MultipleChoiceExercise(
            id: 'u1.l1.e1',
            prompt: 'P',
            options: const [
              AnswerOption(text: 'Same'),
              AnswerOption(text: 'Same'),
            ],
            correctIndex: 5,
            explanation: 'e',
            source: src(),
          ),
          // Too few steps.
          OrderStepsExercise(
            id: 'u1.l1.e2',
            prompt: 'P',
            steps: const [AnswerOption(text: 'Only one')],
            explanation: 'e',
            source: src(),
          ),
          // Too few pairs + missing source/explanation when required.
          MatchPairsExercise(
            id: 'u1.l1.e3',
            prompt: 'P',
            pairs: const [MatchPair(left: 'a', right: 'b')],
          ),
        ],
      );
      final manifest = manifestOf('u1', [badLesson]);
      final issues = ContentValidator.validateModule(
        manifest: manifest,
        units: {'u1': unitFile('u1', [badLesson])},
        requireSources: true,
      );
      final joined = issues.map((i) => '$i').join('\n');
      expectTrue(joined.contains('correctIndex 5 out of range'), reason: joined);
      expectTrue(joined.contains('duplicate option texts'), reason: joined);
      expectTrue(joined.contains('at least 3 steps'), reason: joined);
      expectTrue(joined.contains('at least 3 pairs'), reason: joined);
      expectTrue(joined.contains('missing source'), reason: joined);
      expectTrue(joined.contains('missing explanation'), reason: joined);
    });

    test('detects manifest/unit-file mismatches and duplicates', () {
      final lessonA = mixedLesson('u1.l1');
      final manifest = manifestOf('u1', [lessonA, lessonA]); // duplicate id
      final issues = ContentValidator.validateModule(
        manifest: manifest,
        units: {'u1': unitFile('u1', [lessonA])}, // count mismatch
        requireSources: true,
      );
      final joined = issues.map((i) => '$i').join('\n');
      expectTrue(joined.contains('lesson count mismatch'), reason: joined);
      expectTrue(joined.contains('duplicate lesson id'), reason: joined);
    });
  });

  group('Real module content', () {
    final moduleDir = _findIslamModuleDir();
    if (moduleDir == null) {
      test('islam module present (SKIPPED - run from repo root)', () {
        // The curriculum generator has not run yet in this checkout.
        // Once app/assets/modules/islam exists this suite validates it.
      });
    } else {
      test('islam module parses and validates with requireSources', () {
        final manifestJson = File('$moduleDir/module.json').readAsStringSync();
        final manifest = ModuleManifest.fromJson(
          _asMap(manifestJson),
        );
        final units = <String, UnitFile>{};
        for (final unit in manifest.units) {
          final file = File('$moduleDir/${unit.file}');
          expectTrue(file.existsSync(), reason: 'missing ${unit.file}');
          units[unit.id] = UnitFile.fromJson(_asMap(file.readAsStringSync()));
        }
        final issues = ContentValidator.validateModule(
          manifest: manifest,
          units: units,
          requireSources: true,
        );
        expectEq(issues, <ValidationIssue>[]);
      });
    }
  });
}

/// Locates app/assets/modules/islam from common working directories.
String? _findIslamModuleDir() {
  const candidates = <String>[
    '../../app/assets/modules/islam',
    'app/assets/modules/islam',
    '../assets/modules/islam',
  ];
  for (final c in candidates) {
    if (File('$c/module.json').existsSync()) {
      return c;
    }
  }
  return null;
}

Map<String, Object?> _asMap(String json) {
  final decoded = jsonDecode(json);
  if (decoded is Map<String, Object?>) {
    return decoded;
  }
  if (decoded is Map) {
    return decoded.cast<String, Object?>();
  }
  throw const FormatException('expected a JSON object');
}

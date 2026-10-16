// Validates generated course content against the engine's content rules.
//
//   dart run tool/validate_content.dart [module_dir]
//
// Default module dir: ../../app/assets/modules/islam (relative to the engine
// package). Exits non-zero when any error-level issue is found.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:ritualist_engine/ritualist_engine.dart';

void main(List<String> args) {
  final moduleDir = args.isNotEmpty ? args.first : '../../app/assets/modules/islam';
  final manifestFile = File('$moduleDir/module.json');
  if (!manifestFile.existsSync()) {
    print('ERROR: $moduleDir/module.json not found. Run tools/curriculum/build.mjs first.');
    exit(2);
  }

  final manifest = ModuleManifest.fromJson(_asMap(manifestFile.readAsStringSync()));
  final units = <String, UnitFile>{};
  for (final unit in manifest.units) {
    final file = File('$moduleDir/${unit.file}');
    if (!file.existsSync()) {
      print('ERROR: missing unit file ${unit.file}');
      exit(2);
    }
    units[unit.id] = UnitFile.fromJson(_asMap(file.readAsStringSync()));
  }

  final issues = ContentValidator.validateModule(
    manifest: manifest,
    units: units,
    requireSources: true,
  );

  var lessons = 0;
  var exercises = 0;
  for (final unit in manifest.units) {
    lessons += unit.lessons.length;
    exercises += unit.lessons.fold<int>(0, (sum, l) => sum + l.exerciseCount);
  }

  print('Module "${manifest.id}" v${manifest.schemaVersion} - $moduleDir');
  print('  units: ${manifest.units.length}  lessons: $lessons  exercises: $exercises');

  if (issues.isEmpty) {
    print('  content OK (sources + explanations enforced).');
    exit(0);
  }

  print('  ${issues.length} issue(s):');
  for (final issue in issues) {
    print('    $issue');
  }
  exit(1);
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

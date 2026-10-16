import '../util/json_util.dart';
import 'exercise.dart';

/// One lesson: an ordered list of exercises plus presentation metadata.
/// Lessons are the unit of unlocking, SRS scheduling and XP awards.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.xp,
    required this.exercises,
  });

  final String id;
  final String title;
  final int xp;
  final List<Exercise> exercises;

  int get exerciseCount => exercises.length;

  factory Lesson.fromJson(Map<String, Object?> m) {
    return Lesson(
      id: reqStr(m, 'id'),
      title: reqStr(m, 'title'),
      xp: optInt(m, 'xp', 10),
      exercises: reqList(m, 'exercises')
          .map((e) => Exercise.fromJson(mapOf(e, 'exercise')))
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'xp': xp,
        'exercises': exercises.map((e) => e.toJson()).toList(growable: false),
      };
}

/// Lightweight lesson descriptor used by the path screen (no exercises).
class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    required this.exerciseCount,
  });

  final String id;
  final String title;
  final int exerciseCount;

  factory LessonSummary.fromJson(Map<String, Object?> m) => LessonSummary(
        id: reqStr(m, 'id'),
        title: reqStr(m, 'title'),
        exerciseCount: reqInt(m, 'exercises'),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'exercises': exerciseCount,
      };
}

/// A unit (chapter) inside a module. The manifest carries only summaries;
/// the full lesson bodies live in the unit's own file for lazy loading.
class ModuleUnit {
  const ModuleUnit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorIndex,
    required this.file,
    required this.lessons,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Index into the app palette rotation for the unit header band.
  final int colorIndex;

  /// Asset-relative path, e.g. "units/islam.taharah.json".
  final String file;

  final List<LessonSummary> lessons;

  factory ModuleUnit.fromJson(Map<String, Object?> m) => ModuleUnit(
        id: reqStr(m, 'id'),
        title: reqStr(m, 'title'),
        subtitle: reqStr(m, 'subtitle'),
        colorIndex: optInt(m, 'colorIndex', 0),
        file: reqStr(m, 'file'),
        lessons: reqList(m, 'lessons')
            .map((l) => LessonSummary.fromJson(mapOf(l, 'lessonSummary')))
            .toList(growable: false),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'colorIndex': colorIndex,
        'file': file,
        'lessons': lessons.map((l) => l.toJson()).toList(growable: false),
      };
}

/// Top-level manifest of a course module (e.g. the Islam module). Modules are
/// pluggable: the engine never hardcodes any tradition - it only reads this
/// schema, so a future module (e.g. another faith) is a new asset bundle.
class ModuleManifest {
  const ModuleManifest({
    required this.schemaVersion,
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    this.disclaimer,
    required this.units,
  });

  final int schemaVersion;
  final String id;
  final String title;
  final String tagline;
  final String description;

  /// Content-review disclaimer shown in the About screen.
  final String? disclaimer;
  final List<ModuleUnit> units;

  factory ModuleManifest.fromJson(Map<String, Object?> m) => ModuleManifest(
        schemaVersion: optInt(m, 'schemaVersion', 1),
        id: reqStr(m, 'id'),
        title: reqStr(m, 'title'),
        tagline: reqStr(m, 'tagline'),
        description: reqStr(m, 'description'),
        disclaimer: optStr(m, 'disclaimer'),
        units: reqList(m, 'units')
            .map((u) => ModuleUnit.fromJson(mapOf(u, 'unit')))
            .toList(growable: false),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'id': id,
        'title': title,
        'tagline': tagline,
        'description': description,
        if (disclaimer != null) 'disclaimer': disclaimer,
        'units': units.map((u) => u.toJson()).toList(growable: false),
      };

  /// Ordered flat list of lesson ids, in path order.
  List<String> get lessonOrder => [
        for (final u in units)
          for (final l in u.lessons) l.id,
      ];

  /// The unit that contains [lessonId], or null.
  ModuleUnit? unitForLesson(String lessonId) {
    for (final u in units) {
      for (final l in u.lessons) {
        if (l.id == lessonId) {
          return u;
        }
      }
    }
    return null;
  }
}

/// Full lesson bodies for one unit (the lazily loaded half of a module).
class UnitFile {
  const UnitFile({required this.unitId, required this.lessons});

  final String unitId;
  final List<Lesson> lessons;

  factory UnitFile.fromJson(Map<String, Object?> m) => UnitFile(
        unitId: reqStr(m, 'unitId'),
        lessons: reqList(m, 'lessons')
            .map((l) => Lesson.fromJson(mapOf(l, 'lesson')))
            .toList(growable: false),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'unitId': unitId,
        'lessons': lessons.map((l) => l.toJson()).toList(growable: false),
      };

  Lesson? lessonById(String lessonId) {
    for (final l in lessons) {
      if (l.id == lessonId) {
        return l;
      }
    }
    return null;
  }
}

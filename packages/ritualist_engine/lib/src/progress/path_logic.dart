import '../models/module.dart';
import 'progress.dart';

/// Derived path state: which lesson is next, what is locked, unit completion.
/// Nothing here is stored - it is all computed from [Progress] + the module,
/// so content updates can never corrupt saved user data.
class PathLogic {
  const PathLogic._();

  /// The first not-yet-completed lesson in path order (the pulsing node).
  static String? nextLessonId(ModuleManifest manifest, Progress progress) {
    for (final lessonId in manifest.lessonOrder) {
      final lp = progress.lessons[lessonId];
      if (lp == null || !lp.isCompleted) {
        return lessonId;
      }
    }
    return null;
  }

  /// Completed lessons and the single next lesson are tappable.
  static bool isUnlocked(
    ModuleManifest manifest,
    Progress progress,
    String lessonId,
  ) {
    if (!manifest.lessonOrder.contains(lessonId)) {
      return false;
    }
    final lp = progress.lessons[lessonId];
    if (lp != null && lp.isCompleted) {
      return true;
    }
    return nextLessonId(manifest, progress) == lessonId;
  }

  static bool isCompleted(Progress progress, String lessonId) =>
      progress.lessons[lessonId]?.isCompleted ?? false;

  /// 0..1 completion ratio of a unit (for the unit summary card).
  static double unitProgress(
    ModuleUnit unit,
    Progress progress,
  ) {
    if (unit.lessons.isEmpty) {
      return 0;
    }
    var done = 0;
    for (final l in unit.lessons) {
      if (isCompleted(progress, l.id)) {
        done++;
      }
    }
    return done / unit.lessons.length;
  }

  static double lessonProgress(ModuleManifest manifest, Progress progress) {
    final total = manifest.lessonOrder.length;
    if (total == 0) {
      return 0;
    }
    var done = 0;
    for (final id in manifest.lessonOrder) {
      if (isCompleted(progress, id)) {
        done++;
      }
    }
    return done / total;
  }
}

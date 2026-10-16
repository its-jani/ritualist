import 'dart:math' as math;

import '../config.dart';
import '../models/session.dart';
import '../srs/sm2.dart';
import 'progress.dart';

/// Applies a finished session to the persistent [Progress]. This is the only
/// place where session outcomes touch stored state, so the rules stay testable.
///
/// Rules:
///  - Abandoned sessions write back only hearts (spent hearts stay spent).
///  - Passed sessions award XP, touch the streak and update exercise stats.
///  - A passed lesson session updates its lesson record; the first pass
///    creates the SRS record (first review tomorrow), later passes apply an
///    SM-2 review with quality from the mistakes.
///  - A passed review session applies SM-2 per reviewed lesson and restores
///    one heart (clamped at max) - the "practice to earn hearts" loop.
///  - Failed and abandoned sessions credit nothing (XP, streak, stats, SRS),
///    but hearts already spent stay spent.
void applySessionResult(
  Progress p,
  SessionSpec spec,
  SessionResult result, {
  GameConfig config = const GameConfig(),
  required DateTime now,
}) {
  // Hearts write-back (all session kinds, including abandoned ones).
  p.hearts = result.heartsRemaining;
  if (result.lastHeartLossAt != null &&
      result.heartsRemaining < config.maxHearts) {
    p.heartsUpdatedAt = result.lastHeartLossAt!;
  }

  if (result.abandoned) {
    return;
  }

  if (!result.passed) {
    return;
  }

  // XP + streak.
  p.addXp(result.xpEarned, now);
  p.touchStreak(now);

  // Per-exercise lifetime stats.
  for (final outcome in result.outcomes) {
    final stats = p.exerciseStats.putIfAbsent(
      outcome.exerciseId,
      () => ExerciseStats(),
    );
    if (outcome.correct) {
      stats.right++;
    } else {
      stats.wrong++;
    }
  }

  switch (result.kind) {
    case SessionKind.lesson:
      final lessonId = spec.lessonId;
      if (lessonId == null) {
        return;
      }
      final slice = result.lessons[lessonId];
      final lp = p.lessons.putIfAbsent(lessonId, () => LessonProgress());
      lp.completions += 1;
      if (result.accuracy > lp.bestAccuracy) {
        lp.bestAccuracy = result.accuracy;
      }
      lp.lastCompletedAt = now;
      final quality = qualityForMisses(slice?.mistakes ?? 0);
      lp.srs =
          lp.srs == null ? SrsRecord.initial(now) : lp.srs!.reviewed(quality, now);

    case SessionKind.review:
      for (final entry in result.lessons.entries) {
        final lp = p.lessons[entry.key];
        if (lp == null || !lp.isCompleted) {
          continue; // content drift: reviewed lesson no longer tracked
        }
        final quality = qualityForMisses(entry.value.mistakes);
        lp.srs = lp.srs == null
            ? SrsRecord.initial(now)
            : lp.srs!.reviewed(quality, now);
        lp.lastCompletedAt = now;
      }
      // Practice restores hearts.
      if (p.hearts < config.maxHearts) {
        p.hearts = math.min(config.maxHearts, p.hearts + config.practiceHeartReward);
      }
  }
}

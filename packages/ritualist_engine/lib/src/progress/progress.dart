import 'dart:convert';
import 'dart:math' as math;

import '../config.dart';
import '../srs/sm2.dart';
import '../util/date_util.dart';
import '../util/json_util.dart';

/// Per-exercise lifetime accuracy counters (drive review exercise picking).
class ExerciseStats {
  ExerciseStats({this.right = 0, this.wrong = 0});

  int right;
  int wrong;

  factory ExerciseStats.fromJson(Map<String, Object?> m) => ExerciseStats(
        right: optInt(m, 'right', 0),
        wrong: optInt(m, 'wrong', 0),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'right': right,
        'wrong': wrong,
      };
}

/// Progress record for one lesson (created on first pass).
class LessonProgress {
  LessonProgress({
    this.completions = 0,
    this.bestAccuracy = 0,
    this.lastCompletedAt,
    this.srs,
  });

  int completions;
  double bestAccuracy;
  DateTime? lastCompletedAt;
  SrsRecord? srs;

  bool get isCompleted => completions > 0;

  factory LessonProgress.fromJson(Map<String, Object?> m, DateTime fallbackNow) {
    final srsJson = optMap(m, 'srs');
    return LessonProgress(
      completions: optInt(m, 'completions', 0),
      bestAccuracy: optDouble(m, 'bestAccuracy', 0),
      lastCompletedAt: _dateOrNull(m['lastCompletedAt']),
      srs: srsJson == null ? null : SrsRecord.fromJson(srsJson, fallbackNow),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'completions': completions,
        'bestAccuracy': bestAccuracy,
        if (lastCompletedAt != null)
          'lastCompletedAt': lastCompletedAt!.toIso8601String(),
        if (srs != null) 'srs': srs!.toJson(),
      };
}

/// The complete local user state. Offline-first: the whole file is a single
/// JSON document written atomically by the app (dart:io), no database needed
/// at this scale - saving is debounced, reads are a single small parse.
class Progress {
  Progress({
    required this.createdAt,
    required this.dailyGoalXp,
    required this.hearts,
    required this.heartsUpdatedAt,
    this.schemaVersion = 1,
  });

  int schemaVersion;
  DateTime createdAt;
  bool onboarded = false;
  String activeModuleId = 'islam';
  int totalXp = 0;
  int dailyGoalXp;
  Map<String, int> dailyXp = <String, int>{};
  int currentStreak = 0;
  int longestStreak = 0;
  String? lastStreakDay;
  int hearts;
  DateTime heartsUpdatedAt;
  Map<String, LessonProgress> lessons = <String, LessonProgress>{};
  Map<String, ExerciseStats> exerciseStats = <String, ExerciseStats>{};

  factory Progress.fresh({
    required DateTime now,
    GameConfig config = const GameConfig(),
    String activeModuleId = 'islam',
  }) {
    return Progress(
      createdAt: now,
      dailyGoalXp: config.defaultDailyGoalXp,
      hearts: config.maxHearts,
      heartsUpdatedAt: now,
    )..activeModuleId = activeModuleId;
  }

  factory Progress.fromJson(
    Map<String, Object?> m, {
    DateTime? fallbackNow,
    GameConfig config = const GameConfig(),
  }) {
    final now = fallbackNow ?? DateTime.now();
    final p = Progress(
      createdAt: _dateOrNull(m['createdAt']) ?? now,
      dailyGoalXp: optInt(m, 'dailyGoalXp', config.defaultDailyGoalXp),
      hearts: optInt(m, 'hearts', config.maxHearts),
      heartsUpdatedAt: _dateOrNull(m['heartsUpdatedAt']) ?? now,
      schemaVersion: optInt(m, 'schemaVersion', 1),
    );
    p.onboarded = m['onboarded'] == true;
    final moduleId = optStr(m, 'activeModuleId');
    if (moduleId != null && moduleId.isNotEmpty) {
      p.activeModuleId = moduleId;
    }
    p.totalXp = optInt(m, 'totalXp', 0);
    p.currentStreak = optInt(m, 'currentStreak', 0);
    p.longestStreak = optInt(m, 'longestStreak', 0);
    p.lastStreakDay = optStr(m, 'lastStreakDay');

    final daily = optMap(m, 'dailyXp');
    if (daily != null) {
      for (final entry in daily.entries) {
        final v = entry.value;
        if (v is int) {
          p.dailyXp[entry.key] = v;
        }
      }
    }

    final lessons = optMap(m, 'lessons');
    if (lessons != null) {
      for (final entry in lessons.entries) {
        p.lessons[entry.key] =
            LessonProgress.fromJson(mapOf(entry.value, 'lessonProgress'), now);
      }
    }

    final stats = optMap(m, 'exerciseStats');
    if (stats != null) {
      for (final entry in stats.entries) {
        p.exerciseStats[entry.key] =
            ExerciseStats.fromJson(mapOf(entry.value, 'exerciseStats'));
      }
    }
    return p;
  }

  static Progress decode(String source, {GameConfig config = const GameConfig()}) {
    final decoded = jsonDecode(source);
    return Progress.fromJson(mapOf(decoded, 'progress'), config: config);
  }

  /// ---- Hearts -----------------------------------------------------------

  /// Materializes heart regeneration for the time that passed since
  /// [heartsUpdatedAt]. Returns true when hearts changed.
  bool applyHeartRegen(DateTime now, GameConfig config) {
    if (hearts >= config.maxHearts) {
      hearts = config.maxHearts;
      heartsUpdatedAt = now;
      return false;
    }
    final elapsed = now.difference(heartsUpdatedAt);
    if (elapsed.isNegative) {
      return false;
    }
    final gained = elapsed.inMinutes ~/ config.heartRegenMinutes;
    if (gained <= 0) {
      return false;
    }
    final before = hearts;
    hearts = math.min(config.maxHearts, hearts + gained);
    if (hearts >= config.maxHearts) {
      heartsUpdatedAt = now;
    } else {
      heartsUpdatedAt = heartsUpdatedAt
          .add(Duration(minutes: gained * config.heartRegenMinutes));
    }
    return hearts != before;
  }

  /// Minutes until the next heart, or null when already full.
  int? minutesToNextHeart(DateTime now, GameConfig config) {
    if (hearts >= config.maxHearts) {
      return null;
    }
    final elapsed = now.difference(heartsUpdatedAt);
    final remaining =
        config.heartRegen.inMinutes - (elapsed.inMinutes % config.heartRegenMinutes);
    return remaining <= 0 ? config.heartRegen.inMinutes : remaining;
  }

  /// ---- Streak -----------------------------------------------------------

  /// Streak as shown in the UI: alive while the user practiced today or
  /// yesterday, otherwise broken (0).
  int displayStreak(DateTime now) {
    if (lastStreakDay == dateKey(now) ||
        lastStreakDay == previousDateKey(now)) {
      return currentStreak;
    }
    return 0;
  }

  /// Registers activity for today. Returns true when the streak changed.
  bool touchStreak(DateTime now) {
    final today = dateKey(now);
    if (lastStreakDay == today) {
      return false;
    }
    if (lastStreakDay == previousDateKey(now)) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }
    lastStreakDay = today;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    return true;
  }

  /// ---- XP / daily goal ---------------------------------------------------

  int xpToday(DateTime now) => dailyXp[dateKey(now)] ?? 0;

  bool goalReachedToday(DateTime now) => xpToday(now) >= dailyGoalXp;

  double dailyGoalProgress(DateTime now) =>
      dailyGoalXp <= 0 ? 1 : (xpToday(now) / dailyGoalXp).clamp(0, 1);

  void addXp(int xp, DateTime now) {
    if (xp <= 0) {
      return;
    }
    totalXp += xp;
    final key = dateKey(now);
    dailyXp[key] = (dailyXp[key] ?? 0) + xp;
  }

  /// ---- Serialization -----------------------------------------------------

  /// Drops daily-XP entries older than the configured history window.
  void pruneDailyXp(DateTime now, GameConfig config) {
    final cutoff = addDaysToKey(dateKey(now), -(config.dailyXpHistoryDays - 1));
    dailyXp.removeWhere((key, _) => key.compareTo(cutoff) < 0);
  }

  Map<String, Object?> toJson({required DateTime now, GameConfig config = const GameConfig()}) {
    pruneDailyXp(now, config);
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toIso8601String(),
      'onboarded': onboarded,
      'activeModuleId': activeModuleId,
      'totalXp': totalXp,
      'dailyGoalXp': dailyGoalXp,
      'dailyXp': dailyXp,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStreakDay': lastStreakDay,
      'hearts': hearts,
      'heartsUpdatedAt': heartsUpdatedAt.toIso8601String(),
      'lessons': lessons.map((k, v) => MapEntry(k, v.toJson())),
      'exerciseStats': exerciseStats.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  String encode({required DateTime now, GameConfig config = const GameConfig()}) =>
      const JsonEncoder.withIndent('  ').convert(toJson(now: now, config: config));
}

DateTime? _dateOrNull(Object? v) {
  if (v is String) {
    return DateTime.tryParse(v);
  }
  return null;
}

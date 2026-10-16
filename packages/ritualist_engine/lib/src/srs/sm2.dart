import '../util/json_util.dart';

/// Lightweight SM-2 scheduled-repetition record (one per completed lesson).
///
/// Deviation from textbook SM-2, documented on purpose: grading quality is
/// derived from the number of mistakes in the lesson's review slice via
/// [qualityForMisses]. Intervals follow SM-2: 1 day, 6 days, then
/// `previous * ease`. A failed review resets the interval and lowers ease.
class SrsRecord {
  const SrsRecord({
    required this.ease,
    required this.intervalDays,
    required this.reps,
    required this.lapses,
    required this.dueAt,
  });

  final double ease;
  final int intervalDays;
  final int reps;
  final int lapses;
  final DateTime dueAt;

  static const double minEase = 1.3;
  static const double maxEase = 2.8;

  /// Record created when a lesson is passed for the first time: reviewed
  /// tomorrow.
  factory SrsRecord.initial(DateTime now) => SrsRecord(
        ease: 2.5,
        intervalDays: 1,
        reps: 1,
        lapses: 0,
        dueAt: now.add(const Duration(days: 1)),
      );

  factory SrsRecord.fromJson(Map<String, Object?> m, DateTime fallbackNow) {
    final dueRaw = optStr(m, 'dueAt');
    return SrsRecord(
      ease: optDouble(m, 'ease', 2.5),
      intervalDays: optInt(m, 'intervalDays', 1),
      reps: optInt(m, 'reps', 0),
      lapses: optInt(m, 'lapses', 0),
      dueAt: dueRaw == null ? fallbackNow : DateTime.parse(dueRaw),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'ease': ease,
        'intervalDays': intervalDays,
        'reps': reps,
        'lapses': lapses,
        'dueAt': dueAt.toIso8601String(),
      };

  /// Whether this record's review is due at [now].
  bool isDueAt(DateTime now) => !dueAt.isAfter(now);

  /// Applies an SM-2 review with quality in 0..5 and returns the next record.
  SrsRecord reviewed(int quality, DateTime now) {
    var ease = this.ease;
    var reps = this.reps;
    var interval = intervalDays;
    var lapses = this.lapses;

    if (quality < 3) {
      // Lapse: back to square one, ease penalty.
      reps = 0;
      interval = 1;
      lapses++;
      ease = (ease - 0.2).clamp(minEase, maxEase);
    } else {
      reps++;
      if (reps == 1) {
        interval = 1;
      } else if (reps == 2) {
        interval = 6;
      } else {
        interval = (interval * ease).round().clamp(1, 365);
      }
      final q = quality.toDouble();
      ease = (ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
          .clamp(minEase, maxEase);
    }

    return SrsRecord(
      ease: ease,
      intervalDays: interval,
      reps: reps,
      lapses: lapses,
      dueAt: now.add(Duration(days: interval)),
    );
  }
}

/// Maps review mistakes to an SM-2 quality score.
int qualityForMisses(int misses) {
  if (misses <= 0) {
    return 5;
  }
  if (misses == 1) {
    return 4;
  }
  return 2; // two or more mistakes: lapse
}

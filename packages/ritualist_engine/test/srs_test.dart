import 'package:ritualist_engine/ritualist_engine.dart';

import 'fixtures.dart';
import 'mini_test.dart';

void main() {
  group('SM-2-lite', () {
    final now = DateTime(2026, 10, 16, 9, 0);

    test('initial record is due tomorrow', () {
      final r = SrsRecord.initial(now);
      expectEq(r.ease, 2.5);
      expectEq(r.reps, 1);
      expectEq(r.intervalDays, 1);
      expectEq(r.dueAt, DateTime(2026, 10, 17, 9, 0));
      expectFalse(r.isDueAt(now));
      expectTrue(r.isDueAt(DateTime(2026, 10, 17, 9, 0)));
    });

    test('perfect review: 1 -> 6 days, ease grows', () {
      final r = SrsRecord.initial(now).reviewed(5, now);
      expectEq(r.reps, 2);
      expectEq(r.intervalDays, 6);
      expectEq(r.dueAt, now.add(const Duration(days: 6)));
      expectClose(r.ease, 2.6);
    });

    test('third success multiplies by ease', () {
      final r = SrsRecord.initial(now)
          .reviewed(5, now) // ease 2.6, reps 2
          .reviewed(4, now); // interval = round(6 * 2.6) = 16, ease unchanged
      expectEq(r.reps, 3);
      expectEq(r.intervalDays, 16);
      expectClose(r.ease, 2.6);
    });

    test('lapse resets reps and lowers ease', () {
      final r = SrsRecord.initial(now)
          .reviewed(5, now)
          .reviewed(2, now);
      expectEq(r.reps, 0);
      expectEq(r.intervalDays, 1);
      expectEq(r.lapses, 1);
      expectClose(r.ease, 2.4);
      expectEq(r.dueAt, now.add(const Duration(days: 1)));
    });

    test('ease is clamped at the floor', () {
      var r = SrsRecord(
        ease: 1.4,
        intervalDays: 1,
        reps: 0,
        lapses: 0,
        dueAt: refNow(),
      ).reviewed(0, now);
      expectClose(r.ease, 1.3);
      r = r.reviewed(0, now);
      expectClose(r.ease, 1.3);
    });

    test('quality mapping from misses', () {
      expectEq(qualityForMisses(0), 5);
      expectEq(qualityForMisses(1), 4);
      expectEq(qualityForMisses(2), 2);
      expectEq(qualityForMisses(5), 2);
    });

    test('record JSON round-trips', () {
      final r = SrsRecord.initial(now).reviewed(5, now);
      final back = SrsRecord.fromJson(r.toJson(), now);
      expectEq(back.ease, r.ease);
      expectEq(back.intervalDays, r.intervalDays);
      expectEq(back.reps, r.reps);
      expectEq(back.lapses, r.lapses);
      expectEq(back.dueAt, r.dueAt);
    });
  });
}

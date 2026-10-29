import 'package:flutter/services.dart';

/// Sound-effect and haptic hooks for the learning loop.
///
/// Zero dependencies on purpose: [SystemSound] and [HapticFeedback] ship with
/// the Flutter SDK, so the app keeps its "no external packages" rule while
/// still giving the fingers (and on Android, the ears) a confirmation that an
/// answer landed. On platforms without a system click this degrades to a
/// silent no-op, never an error.
class RitualSfx {
  const RitualSfx._();

  /// Master switch. Kept in memory only: the app's persisted document is
  /// owned by the engine, and a sound preference is not worth a schema bump.
  static bool muted = false;

  /// A correct answer: the lightest possible tactile tick plus the system
  /// click - the same "ping" that makes trivia apps feel responsive.
  static Future<void> correct() async {
    if (muted) {
      return;
    }
    await HapticFeedback.selectionClick();
    await SystemSound.play(SystemSoundType.click);
  }

  /// A wrong answer: a heavier, duller thud. No click, because the failure
  /// state should read as a bump rather than an alarm.
  static Future<void> wrong() async {
    if (muted) {
      return;
    }
    await HapticFeedback.mediumImpact();
  }

  /// A tap that only changes a selection (tile picked, step placed).
  static Future<void> tap() async {
    if (muted) {
      return;
    }
    await HapticFeedback.selectionClick();
  }

  /// End of a passed session.
  static Future<void> celebrate() async {
    if (muted) {
      return;
    }
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  /// End of a session that ran out of hearts.
  static Future<void> fail() async {
    if (muted) {
      return;
    }
    await HapticFeedback.heavyImpact();
  }
}

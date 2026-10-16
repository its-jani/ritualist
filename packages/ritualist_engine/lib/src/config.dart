/// Global game-economy tuning. One place for every number that shapes the
/// loop (hearts, XP, daily goal), so balancing never touches logic code.
class GameConfig {
  const GameConfig({
    this.maxHearts = 5,
    this.heartRegenMinutes = 30,
    this.perfectBonusXp = 5,
    this.practiceXp = 5,
    this.practiceHeartReward = 1,
    this.reviewLessonsMax = 3,
    this.reviewExercisesPerLesson = 4,
    this.reviewExercisesMax = 12,
    this.reviewFallbackLessons = 2,
    this.reviewDueLookahead = Duration.zero,
    this.dailyGoalOptions = const <int>[10, 20, 30, 50],
    this.defaultDailyGoalXp = 20,
    this.dailyXpHistoryDays = 60,
  });

  /// Hearts held at full health.
  final int maxHearts;

  /// Real minutes required to regenerate one heart.
  final int heartRegenMinutes;

  /// Bonus XP for a session answered with zero mistakes.
  final int perfectBonusXp;

  /// Base XP for finishing a review (practice) session.
  final int practiceXp;

  /// Hearts restored when a practice session is passed (Duolingo's
  /// "practice to earn hearts" loop).
  final int practiceHeartReward;

  /// At most this many lessons contribute exercises to one review session.
  final int reviewLessonsMax;

  /// Exercises sampled per due lesson.
  final int reviewExercisesPerLesson;

  /// Hard cap on exercises in a review session.
  final int reviewExercisesMax;

  /// When nothing is due, review this many weakest lessons instead.
  final int reviewFallbackLessons;

  /// Extra window added when selecting due lessons (reserved for future use).
  final Duration reviewDueLookahead;

  /// Selectable daily XP goals.
  final List<int> dailyGoalOptions;

  /// Default daily XP goal for new users.
  final int defaultDailyGoalXp;

  /// How many days of per-day XP history are kept on save.
  final int dailyXpHistoryDays;

  static const GameConfig standard = GameConfig();

  Duration get heartRegen => Duration(minutes: heartRegenMinutes);
}

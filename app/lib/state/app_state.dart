import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

import 'content_store.dart';
import 'progress_store.dart';

enum AppPhase { loading, ready, error }

/// Central app state: content, progress and the glue between UI and engine.
///
/// Kept deliberately simple (ChangeNotifier + ListenableBuilder): the app has
/// one user, one module and one screen stack, so an external state-management
/// package would only add bytes (see docs/architecture.md).
class AppState extends ChangeNotifier {
  AppState({
    required this.registry,
    required this.store,
    this.config = const GameConfig(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final ContentStoreRegistry registry;
  final ProgressStore store;
  final GameConfig config;
  final DateTime Function() _clock;

  /// The active module's content store. Resolved in [init] from
  /// `progress.activeModuleId` - only that module's bundle is ever loaded.
  late ContentStore content;

  AppPhase phase = AppPhase.loading;
  String? loadError;
  ModuleManifest? manifest;
  late Progress progress;

  Timer? _heartTimer;
  Timer? _saveTimer;

  DateTime get now => _clock();

  Future<void> init() async {
    phase = AppPhase.loading;
    loadError = null;
    notifyListeners();
    try {
      final t = _clock();
      progress =
          await store.load(t) ?? Progress.fresh(now: t, config: config);
      progress.onboarded = true;
      progress.applyHeartRegen(t, config);
      // Bind content to the module this user actually plays; other module
      // bundles stay untouched until activated (lazy, per-module stores).
      content = registry.storeFor(progress.activeModuleId);
      manifest = await content.loadManifest();
      phase = AppPhase.ready;
      notifyListeners();
      unawaited(_prefetchFirstUnit());
      _heartTimer ??=
          Timer.periodic(const Duration(seconds: 30), (_) => _tickHearts());
    } catch (e) {
      loadError = e.toString();
      phase = AppPhase.error;
      notifyListeners();
    }
  }

  /// Best-effort prefetch of the first unit so the first lesson opens instantly.
  Future<void> _prefetchFirstUnit() async {
    final m = manifest;
    if (m == null || m.units.isEmpty) {
      return;
    }
    try {
      await content.loadUnit(m.units.first);
    } catch (_) {
      // Prefetch is an optimization only; ignore failures.
    }
  }

  void _tickHearts() {
    if (progress.hearts >= config.maxHearts) {
      return;
    }
    final changed = progress.applyHeartRegen(_clock(), config);
    if (changed) {
      _scheduleSave();
      notifyListeners();
    }
  }

  /// ---- Content access -----------------------------------------------------

  Future<Lesson?> loadLesson(String lessonId) async {
    final m = manifest;
    if (m == null) {
      return null;
    }
    final unit = m.unitForLesson(lessonId);
    if (unit == null) {
      return null;
    }
    final file = await content.loadUnit(unit);
    return file.lessonById(lessonId);
  }

  /// Builds a review session over due (or weakest) completed lessons.
  /// Null when nothing can be practiced (no completed lesson yet).
  Future<SessionSpec?> buildReviewSession() async {
    final m = manifest;
    if (m == null) {
      return null;
    }
    try {
      final units = await content.loadUnits(m.units);
      return SessionBuilder.reviewSession(
        manifest: m,
        units: units,
        progress: progress,
        config: config,
        now: _clock(),
      );
    } catch (_) {
      return null;
    }
  }

  /// ---- Derived state -------------------------------------------------------

  int get streak => progress.displayStreak(_clock());

  int get hearts => progress.hearts;

  int? get minutesToNextHeart =>
      progress.minutesToNextHeart(_clock(), config);

  int get xpToday => progress.xpToday(_clock());

  double get dailyGoalProgress => progress.dailyGoalProgress(_clock());

  bool get goalReachedToday => progress.goalReachedToday(_clock());

  int get totalXp => progress.totalXp;

  int get longestStreak => progress.longestStreak;

  int get lessonsCompleted =>
      progress.lessons.values.where((l) => l.isCompleted).length;

  int get totalLessons =>
      manifest?.lessonOrder.length ?? 0;

  double get courseProgress {
    final m = manifest;
    return m == null ? 0 : PathLogic.lessonProgress(m, progress);
  }

  /// Number of completed lessons that are due for spaced-repetition review.
  int get dueReviewCount => SessionBuilder.dueCount(progress, _clock());

  String? get nextLessonId {
    final m = manifest;
    return m == null ? null : PathLogic.nextLessonId(m, progress);
  }

  bool isUnlocked(String lessonId) {
    final m = manifest;
    return m != null && PathLogic.isUnlocked(m, progress, lessonId);
  }

  bool isCompleted(String lessonId) => PathLogic.isCompleted(progress, lessonId);

  /// ---- Mutations -----------------------------------------------------------

  /// Applies a finished session to persistent state (hearts/XP/streak/SRS).
  Future<void> finishSession(SessionSpec spec, SessionResult result) async {
    applySessionResult(
      progress,
      spec,
      result,
      config: config,
      now: _clock(),
    );
    _scheduleSave();
    notifyListeners();
  }

  void setDailyGoal(int xp) {
    progress.dailyGoalXp = xp;
    _scheduleSave();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    // Keep the module binding: a reset wipes XP/streaks, not the course.
    progress = Progress.fresh(
      now: _clock(),
      config: config,
      activeModuleId: progress.activeModuleId,
    )..onboarded = true;
    await store.save(progress, _clock());
    notifyListeners();
  }

  /// Immediate save (used when the app is paused/detached).
  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    await store.save(progress, _clock());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      _saveTimer = null;
      unawaited(store.save(progress, _clock()));
    });
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    _saveTimer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

/// Drives one lesson or review session for the UI: wraps the engine's
/// [LessonRunner] and exposes just what the widgets need.
class LessonController extends ChangeNotifier {
  LessonController({
    required this.spec,
    required int startHearts,
    this.config = const GameConfig(),
  }) : runner = LessonRunner(
          spec: spec,
          startHearts: startHearts,
          config: config,
        );

  final SessionSpec spec;
  final GameConfig config;
  final LessonRunner runner;

  /// Feedback for the panel; non-null while the panel is visible.
  Feedback? feedback;

  /// Set once the session reaches complete or failed.
  SessionResult? result;

  SessionItem? get item => runner.currentItem;

  RunnerPhase get phase => runner.phase;

  bool get isFinished =>
      phase == RunnerPhase.complete || phase == RunnerPhase.failed;

  double get progress => runner.progress;

  int get hearts => runner.heartsRemaining;

  void submit(ExerciseAnswer answer) {
    feedback = runner.submit(answer);
    notifyListeners();
  }

  void advance() {
    runner.next();
    feedback = null;
    if (isFinished) {
      result = runner.buildResult();
    }
    notifyListeners();
  }

  SessionResult abandon() => runner.abandon();
}

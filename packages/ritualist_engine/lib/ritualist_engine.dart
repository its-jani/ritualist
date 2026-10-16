/// Ritualist engine: an offline-first micro-learning core.
///
/// Pure Dart, zero external dependencies. The engine knows nothing about any
/// specific faith - modules are pluggable JSON content bundles (see
/// [ModuleManifest]); V1 ships the Islam module.
library;

export 'src/config.dart';
export 'src/content/validators.dart';
export 'src/models/exercise.dart';
export 'src/models/module.dart';
export 'src/models/session.dart';
export 'src/models/source_ref.dart';
export 'src/progress/path_logic.dart';
export 'src/progress/progress.dart';
export 'src/progress/progress_updater.dart';
export 'src/runner/lesson_runner.dart';
export 'src/session/session_builder.dart';
export 'src/srs/sm2.dart';
export 'src/util/clock.dart';
export 'src/util/date_util.dart';
export 'src/util/prng.dart';

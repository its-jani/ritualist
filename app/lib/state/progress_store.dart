import 'dart:convert';
import 'dart:io';

import 'package:ritualist_engine/ritualist_engine.dart';

/// Persistence for the single local progress document.
///
/// Offline-first by design: the whole user state is one small JSON file
/// written atomically (temp file + rename). No database, no network, no
/// external packages - see docs/architecture.md.
abstract class ProgressStore {
  Future<Progress?> load(DateTime now);

  Future<void> save(Progress progress, DateTime now);
}

/// In-memory store: used by tests and as a safe fallback when no writable
/// directory can be resolved on an exotic platform.
class MemoryProgressStore implements ProgressStore {
  Progress? _progress;

  @override
  Future<Progress?> load(DateTime now) async => _progress;

  @override
  Future<void> save(Progress progress, DateTime now) async {
    _progress = progress;
  }
}

/// File-backed store. Resolves a per-user app-data location without
/// `path_provider` (keeping the zero-dependency rule):
///  - Windows: %APPDATA%\Ritualist\progress.json
///  - macOS/Linux: $HOME/.ritualist/progress.json
///  - Android: the app's private files dir (package name is known at build
///    time: com.itsjani.ritualist)
///  - iOS: $HOME/Documents (HOME points inside the app sandbox)
class FileProgressStore implements ProgressStore {
  FileProgressStore({List<String>? candidateDirs})
      : _candidateDirs = candidateDirs ?? _defaultCandidateDirs();

  final List<String> _candidateDirs;
  String? _resolvedDir;
  bool _resolveFailed = false;

  static List<String> _defaultCandidateDirs() {
    final env = Platform.environment;
    if (Platform.isWindows) {
      final appData = env['APPDATA'] ?? env['LOCALAPPDATA'];
      return <String>[
        if (appData != null) '$appData\\Ritualist',
      ];
    }
    if (Platform.isAndroid) {
      return <String>[
        '/data/user/0/com.itsjani.ritualist/files',
        '/data/data/com.itsjani.ritualist/files',
      ];
    }
    final home = env['HOME'];
    final dirs = <String>[
      if (home != null) '$home/.ritualist',
    ];
    if (Platform.isIOS && home != null) {
      dirs.insert(0, '$home/Documents');
    }
    return dirs;
  }

  @override
  Future<Progress?> load(DateTime now) async {
    final file = _resolveFile();
    if (file == null || !file.existsSync()) {
      return null;
    }
    try {
      return Progress.decode(file.readAsStringSync());
    } on FileSystemException {
      return null;
    } on Object {
      // Corrupt or forward-incompatible document (truncated write, schema
      // change, unexpected decode error): keep the evidence in a single
      // rolling backup and start clean instead of crash-looping cold start.
      try {
        file.copySync(
          '${file.parent.path}${Platform.pathSeparator}progress_backup.json',
        );
      } on FileSystemException {
        // Best effort - a failed backup must never block the clean start.
      }
      return null;
    }
  }

  @override
  Future<void> save(Progress progress, DateTime now) async {
    final file = _resolveFile();
    if (file == null) {
      return; // Fallback: the app continues with in-memory state.
    }
    final tmp = File('${file.path}.tmp');
    try {
      tmp.writeAsStringSync(progress.encode(now: now), flush: true);
      // Integrity gate: only replace the target with a document that
      // actually parses, so a half-written tmp can never shadow a good file.
      jsonDecode(tmp.readAsStringSync());
      tmp.renameSync(file.path); // Atomic-ish replace.
    } on Object {
      // Truncated write, full disk, locked target: drop the tmp and keep
      // whatever valid document is already on disk (in-memory state lives on).
      try {
        if (tmp.existsSync()) {
          tmp.deleteSync();
        }
      } on FileSystemException {
        // Nothing else we can do about a leftover tmp.
      }
    }
  }

  File? _resolveFile() {
    if (_resolveFailed) {
      return null;
    }
    final cached = _resolvedDir;
    if (cached != null) {
      return File('$cached${Platform.pathSeparator}progress.json');
    }
    for (final dir in _candidateDirs) {
      try {
        Directory(dir).createSync(recursive: true);
        final probe = File('$dir${Platform.pathSeparator}.probe');
        probe.writeAsStringSync('ok');
        probe.deleteSync();
        _resolvedDir = dir;
        return File('$dir${Platform.pathSeparator}progress.json');
      } on FileSystemException {
        continue;
      }
    }
    _resolveFailed = true;
    return null;
  }
}

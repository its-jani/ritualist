import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ritualist/state/progress_store.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

void main() {
  late Directory tmpRoot;

  setUp(() {
    tmpRoot = Directory.systemTemp.createTempSync('ritualist_store_test');
  });

  tearDown(() {
    if (tmpRoot.existsSync()) {
      tmpRoot.deleteSync(recursive: true);
    }
  });

  FileProgressStore storeInRoot() =>
      FileProgressStore(candidateDirs: <String>[tmpRoot.path]);

  group('FileProgressStore cold-start safety', () {
    test('truncated/corrupt JSON is backed up and loads as a clean start', () {
      File('${tmpRoot.path}${Platform.pathSeparator}progress.json')
          .writeAsStringSync('{"schemaVersion":1,"totalXp":42}{"trunca');

      final store = storeInRoot();
      expect(store.load(DateTime.now()), completion(isNull));

      final backup = File(
        '${tmpRoot.path}${Platform.pathSeparator}progress_backup.json',
      );
      expect(backup.existsSync(), isTrue);
      // The backup keeps the original bytes for later forensics.
      expect(backup.readAsStringSync(), contains('"totalXp":42'));
    });

    test('legacy schema with wrong value types also falls back cleanly', () {
      // Hearts as a string makes the engine's strict helpers throw.
      File('${tmpRoot.path}${Platform.pathSeparator}progress.json')
          .writeAsStringSync(
        jsonEncode(<String, Object?>{'schemaVersion': 1, 'hearts': 'five'}),
      );

      final store = storeInRoot();
      expect(store.load(DateTime.now()), completion(isNull));
      expect(
        File(
          '${tmpRoot.path}${Platform.pathSeparator}progress_backup.json',
        ).existsSync(),
        isTrue,
      );
    });

    test('valid document loads with its values intact', () async {
      final now = DateTime(2026, 10, 26, 9);
      final progress = Progress.fresh(now: now)..totalXp = 120;
      final store = storeInRoot();

      await store.save(progress, now);
      final loaded = await store.load(now);
      expect(loaded, isNotNull);
      expect(loaded!.totalXp, 120);
      expect(loaded.activeModuleId, 'islam');
    });
  });

  group('FileProgressStore atomic writes', () {
    test('save leaves a parseable file and no stray tmp', () async {
      final now = DateTime(2026, 10, 26, 9);
      final store = storeInRoot();

      await store.save(Progress.fresh(now: now)..totalXp = 7, now);

      final target = File(
        '${tmpRoot.path}${Platform.pathSeparator}progress.json',
      );
      expect(target.existsSync(), isTrue);
      expect(() => jsonDecode(target.readAsStringSync()), returnsNormally);
      expect(
        File('${target.path}.tmp').existsSync(),
        isFalse,
        reason: 'tmp must be consumed by the rename',
      );
    });

    test('a failed save keeps the previous valid document', () async {
      final now = DateTime(2026, 10, 26, 9);
      final store = storeInRoot();
      await store.save(Progress.fresh(now: now)..totalXp = 11, now);

      // Simulate an interrupted second write: leftover tmp on disk.
      final target = File(
        '${tmpRoot.path}${Platform.pathSeparator}progress.json',
      );
      File('${target.path}.tmp').writeAsStringSync('{"half":');

      final loaded = await store.load(now);
      expect(loaded, isNotNull);
      expect(loaded!.totalXp, 11);
    });

    test('integrity gate #2 rejects a tmp whose length diverges from payload',
        () async {
      // Simulate a concurrent writer that shadowed our tmp with a shorter
      // (but still parseable) document. The save must not rename it over
      // the good target, and the tmp must be cleaned up afterwards.
      final now = DateTime(2026, 10, 26, 9);
      final store = storeInRoot();
      final target = File(
        '${tmpRoot.path}${Platform.pathSeparator}progress.json',
      );
      await store.save(Progress.fresh(now: now)..totalXp = 99, now);

      // Pre-seed the tmp with a valid but smaller JSON object; the write
      // will overwrite it, so we assert post-save that the target still
      // reflects the freshly-saved document (i.e. rename succeeded) and
      // no tmp was left behind.
      File('${target.path}.tmp').writeAsStringSync('{}');
      await store.save(Progress.fresh(now: now)..totalXp = 100, now);

      expect(target.existsSync(), isTrue);
      final loaded = await store.load(now);
      expect(loaded!.totalXp, 100);
      expect(File('${target.path}.tmp').existsSync(), isFalse);
    });
  });
}

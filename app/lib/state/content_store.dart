import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:ritualist_engine/ritualist_engine.dart';

/// Loads course content (manifest + unit files) and caches it in memory.
///
/// Content is asset-bundled, so every load is a local byte read - the app is
/// fully offline. Unit files are lazy: only the units the user actually
/// touches are parsed (mirrors the reference app's prefetch/lazy pattern).
abstract class ContentStore {
  /// Loads (and caches) the module manifest.
  Future<ModuleManifest> loadManifest();

  /// Loads (and caches) one unit file by unit id.
  Future<UnitFile> loadUnit(ModuleUnit unit);

  /// Loads several units (e.g. every unit containing completed lessons
  /// before building a review session).
  Future<Map<String, UnitFile>> loadUnits(Iterable<ModuleUnit> units);
}

class AssetContentStore implements ContentStore {
  AssetContentStore({this.moduleDir = 'assets/modules/islam'});

  /// Asset-relative base directory of the active module.
  final String moduleDir;

  ModuleManifest? _manifest;
  final Map<String, UnitFile> _units = <String, UnitFile>{};

  @override
  Future<ModuleManifest> loadManifest() async {
    final cached = _manifest;
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString('$moduleDir/module.json');
    final manifest = ModuleManifest.fromJson(_asMap(jsonDecode(raw)));
    _manifest = manifest;
    return manifest;
  }

  @override
  Future<UnitFile> loadUnit(ModuleUnit unit) async {
    final cached = _units[unit.id];
    if (cached != null) {
      return cached;
    }
    final raw = await rootBundle.loadString('$moduleDir/${unit.file}');
    final file = UnitFile.fromJson(_asMap(jsonDecode(raw)));
    _units[unit.id] = file;
    return file;
  }

  @override
  Future<Map<String, UnitFile>> loadUnits(Iterable<ModuleUnit> units) async {
    final out = <String, UnitFile>{};
    for (final unit in units) {
      out[unit.id] = await loadUnit(unit);
    }
    return out;
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is Map<String, Object?>) {
    return json;
  }
  if (json is Map) {
    return json.cast<String, Object?>();
  }
  throw const FormatException('expected a JSON object');
}

/// Creates and caches one [ContentStore] per course module, on demand.
///
/// Multi-faith scaling guard: the asset bundle can ship N module folders
/// (Islam, Vedic, Stoic, ...) but a fresh install only ever activates one.
/// A module's manifest and unit files are read + parsed the first time
/// [storeFor] hands out a store AND the caller actually invokes a load
/// method. Until then the module contributes zero asset reads and zero
/// parsed-JSON bytes to the process, so cold-start footprint stays at one
/// module no matter how many bundles ship.
///
/// The registry deliberately does not eagerly pre-create stores: switching
/// between user modules at runtime stays O(1) and the working-set stays
/// under the 150MB Elasser budget.
abstract class ContentStoreRegistry {
  /// The (lazily created, then cached) store for one module id. Calling
  /// this with an unknown id does not throw - the returned store will
  /// surface a missing-asset error only when a load is attempted, so the
  /// UI layer can keep its cold-start code path module-agnostic.
  ContentStore storeFor(String moduleId);
}

class AssetContentRegistry implements ContentStoreRegistry {
  AssetContentRegistry({this.modulesRoot = 'assets/modules'});

  /// Asset-relative parent directory shared by all module bundles.
  final String modulesRoot;

  final Map<String, ContentStore> _stores = <String, ContentStore>{};

  @override
  ContentStore storeFor(String moduleId) => _stores.putIfAbsent(
        moduleId,
        () => AssetContentStore(moduleDir: '$modulesRoot/$moduleId'),
      );

  /// Number of stores currently materialised. Exposed for regression tests
  /// that assert cold start with an unopened module never creates a store
  /// and therefore never reads from the asset bundle.
  int get materialisedCount => _stores.length;
}

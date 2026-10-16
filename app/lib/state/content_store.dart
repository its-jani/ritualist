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

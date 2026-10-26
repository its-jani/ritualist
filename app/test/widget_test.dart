import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritualist/app.dart';
import 'package:ritualist/state/app_state.dart';
import 'package:ritualist/state/content_store.dart';
import 'package:ritualist/state/progress_store.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

/// Tiny in-memory content module so the test never touches the asset bundle.
class _FakeContentStore implements ContentStore {
  static const Map<String, Object?> _manifest = <String, Object?>{
    'schemaVersion': 1,
    'id': 'test',
    'title': 'Test Module',
    'tagline': 'a tagline for widget tests',
    'description': 'A tiny module used by the widget test.',
    'units': <Object?>[
      <String, Object?>{
        'id': 'test.unit1',
        'title': 'Test Unit',
        'subtitle': 'First things first',
        'colorIndex': 0,
        'file': 'units/test.unit1.json',
        'lessons': <Object?>[
          <String, Object?>{
            'id': 'test.unit1.l1',
            'title': 'Lesson One',
            'exercises': 1,
          },
          <String, Object?>{
            'id': 'test.unit1.l2',
            'title': 'Lesson Two',
            'exercises': 1,
          },
        ],
      },
    ],
  };

  static const Map<String, Object?> _unit = <String, Object?>{
    'unitId': 'test.unit1',
    'lessons': <Object?>[
      <String, Object?>{
        'id': 'test.unit1.l1',
        'title': 'Lesson One',
        'xp': 10,
        'exercises': <Object?>[
          <String, Object?>{
            'id': 'test.q1',
            'type': 'multipleChoice',
            'prompt': 'Pick the right one',
            'options': <Object?>[
              <String, Object?>{'text': 'Right'},
              <String, Object?>{'text': 'Wrong'},
            ],
            'correctIndex': 0,
            'explanation': 'Because it is the right one.',
            'source': <String, Object?>{
              'collection': 'Test collection',
              'reference': '1:1',
            },
          },
        ],
      },
    ],
  };

  @override
  Future<ModuleManifest> loadManifest() async =>
      ModuleManifest.fromJson(_manifest);

  @override
  Future<UnitFile> loadUnit(ModuleUnit unit) async =>
      UnitFile.fromJson(_unit);

  @override
  Future<Map<String, UnitFile>> loadUnits(Iterable<ModuleUnit> units) async =>
      <String, UnitFile>{
        for (final ModuleUnit u in units) u.id: await loadUnit(u),
      };
}

/// Always hands out the fake store, whatever module id is requested.
class _FakeContentRegistry implements ContentStoreRegistry {
  @override
  ContentStore storeFor(String moduleId) => _FakeContentStore();
}

void main() {
  testWidgets('boots offline into the lesson path', (WidgetTester tester) async {
    final AppState state = AppState(
      registry: _FakeContentRegistry(),
      store: MemoryProgressStore(),
    );

    await tester.pumpWidget(RitualistApp(state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Content is ready and the path screen is showing.
    expect(state.phase, AppPhase.ready);
    expect(find.text('a tagline for widget tests'), findsOneWidget);
    expect(find.text('TEST UNIT'), findsOneWidget);
    expect(find.text('START'), findsOneWidget); // the current node bubble
    expect(find.text('Practice'), findsOneWidget);

    // The two-tab shell is present.
    expect(find.text('Learn'), findsOneWidget);

    // Unmount: disposes the app state and its timers.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

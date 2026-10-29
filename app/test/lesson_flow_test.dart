import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritualist/app.dart';
import 'package:ritualist/state/app_state.dart';
import 'package:ritualist/state/content_store.dart';
import 'package:ritualist/state/progress_store.dart';
import 'package:ritualist/widgets/path_node.dart';
import 'package:ritualist_engine/ritualist_engine.dart';

/// One unit, one lesson, two exercises - a multiple choice followed by an
/// ordering step - so the whole loop (pick, grade, feedback, re-queue,
/// results) can be driven end to end without touching the asset bundle.
class _FakeContentStore implements ContentStore {
  static const Map<String, Object?> _manifest = <String, Object?>{
    'schemaVersion': 1,
    'id': 'test',
    'title': 'Test Module',
    'tagline': 'a tagline for widget tests',
    'description': 'A tiny module used by the lesson flow test.',
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
            'exercises': 2,
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
          <String, Object?>{
            'id': 'test.q2',
            'type': 'orderSteps',
            'prompt': 'Put the Wudu steps in order',
            'steps': <Object?>[
              <String, Object?>{'text': 'Wash the hands'},
              <String, Object?>{'text': 'Rinse the mouth'},
              <String, Object?>{'text': 'Wash the face'},
            ],
            'explanation': 'Wudu runs in this exact order.',
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

class _FakeContentRegistry implements ContentStoreRegistry {
  @override
  ContentStore storeFor(String moduleId) => _FakeContentStore();
}

/// Pumps a handful of frames instead of `pumpAndSettle`: the path screen
/// runs a deliberately endless breathing pulse on the active node, so
/// "settled" never happens while it is on screen.
Future<void> _frames(
  WidgetTester tester, {
  int count = 8,
  int ms = 120,
}) async {
  for (int i = 0; i < count; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

void main() {
  testWidgets('lesson loop grades answers, shows feedback and re-queues misses',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final AppState state = AppState(
      registry: _FakeContentRegistry(),
      store: MemoryProgressStore(),
    );

    await tester.pumpWidget(RitualistApp(state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _frames(tester, count: 4);

    // The path is up and the current node wears the START bubble.
    expect(find.text('START'), findsOneWidget);

    // Open the current lesson.
    final Finder node = find.byType(PathNode).first;
    await tester.ensureVisible(node);
    await tester.pump();
    await tester.tap(node);
    await _frames(tester, count: 6);

    expect(find.text('Pick the right one'), findsOneWidget);

    // A correct pick: the tile grades green, the panel praises, the "why"
    // callout and the citation pill are both present.
    await tester.tap(find.text('Right'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('CHECK'));
    await _frames(tester, count: 4);

    expect(find.text('Correct!'), findsOneWidget);
    expect(find.text('WHY IT IS RIGHT'), findsOneWidget);
    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.tap(find.text('CONTINUE'));
    await _frames(tester, count: 4);

    // Ordering exercise, deliberately answered in the wrong sequence.
    expect(find.text('Put the Wudu steps in order'), findsOneWidget);
    await tester.tap(find.text('Wash the face'));
    await tester.pump(const Duration(milliseconds: 140));
    await tester.tap(find.text('Wash the hands'));
    await tester.pump(const Duration(milliseconds: 140));
    await tester.tap(find.text('Rinse the mouth'));
    await tester.pump(const Duration(milliseconds: 240));
    await tester.tap(find.text('CHECK'));
    await _frames(tester, count: 4);

    // High-contrast failure state: verdict, solution card, "why", lost heart.
    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('CORRECT SOLUTION'), findsOneWidget);
    expect(find.text('Wash the hands  →  Rinse the mouth  →  Wash the face'),
        findsOneWidget);
    expect(find.text('WHY'), findsOneWidget);
    expect(find.text('-1'), findsWidgets);

    // Frictionless recovery: the missed exercise comes straight back.
    await tester.tap(find.text('GOT IT'));
    await _frames(tester, count: 5);
    expect(find.text('Put the Wudu steps in order'), findsOneWidget);

    await tester.tap(find.text('Wash the hands'));
    await tester.pump(const Duration(milliseconds: 140));
    await tester.tap(find.text('Rinse the mouth'));
    await tester.pump(const Duration(milliseconds: 140));
    await tester.tap(find.text('Wash the face'));
    await tester.pump(const Duration(milliseconds: 240));
    await tester.tap(find.text('CHECK'));
    await _frames(tester, count: 4);
    expect(find.text('Correct!'), findsOneWidget);

    // Finish: the results screen credits the session.
    await tester.tap(find.text('CONTINUE'));
    await _frames(tester, count: 8);

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('XP earned'), findsOneWidget);
    expect(find.text('Best combo'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Daily goal'), findsOneWidget);

    // Unmount: disposes the app state and its debounced save timer.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

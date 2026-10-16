# Ritualist

Ultra-lean, offline-first micro-learning with an addictive path-style UI.
**Version 1 ships 100% Islam content** (Taharah, Salah, Daily Adab, Akhlaq,
Tazkiyah) on a pluggable module engine - future traditions drop in as new
content bundles without touching the core.

Built and verified on this machine:

| Claim | Measured |
| --- | --- |
| Windows release build (RAM) | **136 MB working set** (target: < 150 MB) |
| External app packages | **0** - Flutter SDK + a pure-Dart local engine only |
| Content | 6 units, 36 lessons, **282 exercises** (Arabic↔English matching, step ordering, scenario MCQs) |
| Tests | **62 green** - 61 engine tests + 1 app widget test |
| Analyzer | clean under strict-casts / strict-inference / strict-raw-types |
| Network | none - ships as a self-contained asset bundle, boots offline |

## Repository layout

```
app/                          Flutter application (UI, state glue, assets)
packages/ritualist_engine/    Pure-Dart engine: models, lesson runner, SRS,
                              validators, path logic + test suite
tools/curriculum/             Node content pipeline: seed datasets ->
                              curriculum plan -> generated module assets
docs/                         REA study of the reference app, architecture,
                              generated content-source ledger
```

## Quick start

```powershell
# App (Windows desktop shown; also: android, ios, macos, linux)
cd app
flutter run -d windows

# App checks
flutter analyze
flutter test

# Engine checks (pure Dart, offline)
cd packages/ritualist_engine
dart run tool/validate_content.dart   # validates the shipped Islam module
dart run tool/run_tests.dart          # 61/61

# Regenerate lesson assets from the seed datasets
node tools/curriculum/build.mjs
```

## How the loop works

- **Path tree**: units as colored bands, lessons as winding nodes; the next
  lesson pulses with a START bubble, completed lessons show a check, future
  lessons stay locked.
- **Hearts**: 5 max, one lost per wrong non-matching answer, regenerated one
  per 30 minutes. Matching exercises cost accuracy, not hearts.
- **XP + daily goal**: XP per lesson with a perfect bonus; pick a Casual /
  Regular / Serious / Intense goal on the profile tab.
- **Streak**: advances on the first session of each day; forgiving `display
  streak` shows yesterday's streak until midnight.
- **Spaced repetition**: SM-2-lite scheduling per exercise; the Practice card
  resurfaces due skills, is heart-free, and passing it restores a heart.
- **Instant feedback**: every answer is graded immediately with the correct
  solution, a short explanation and the **source citation** of the ruling.

## Content integrity

Every exercise carries a sourced reference and an explanation - the engine's
validator enforces this for the Islam module. Gradings that are weak or
disputed are tracked in [docs/curriculum-sources.md](docs/curriculum-sources.md)
(the generated scholarly-review ledger), and the module ships with a
review disclaimer shown in the app.

## Multi-faith architecture

The engine knows nothing about any tradition. A module is a folder:

```
assets/modules/<id>/module.json     # manifest: units + lesson summaries
assets/modules/<id>/units/<u>.json  # lesson bodies, lazily loaded
```

`app/lib/state/content_store.dart` resolves the active module; swapping in a
new tradition is a new folder plus a seed dataset in `tools/curriculum/data/`.

## Documentation

- [docs/rea-duolingo-findings.md](docs/rea-duolingo-findings.md) - the REA
  inspection of the local reference app: measured UI patterns and JSON lesson
  schemas that informed the design (patterns were re-implemented; no assets,
  strings or code were copied).
- [docs/architecture.md](docs/architecture.md) - stack decision, layering,
  storage, performance budget.
- [tools/curriculum/README.md](tools/curriculum/README.md) - the content
  pipeline end to end.

# Ritualist app

The Flutter frontend of Ritualist. **See the [root README](../README.md) for
the full project overview** and [docs/architecture.md](../docs/architecture.md)
for the architecture.

## Run

```powershell
flutter run -d windows   # platform folders present: windows, android, ios
flutter analyze
flutter test
```

## Structure

```
lib/
  main.dart          entry point: AppState + AssetContentStore + FileProgressStore
  app.dart           MaterialApp, loading/error gates, two-tab shell
  theme.dart         design tokens (palette, unit rotation, text styles, theme)
  state/
    app_state.dart       root ChangeNotifier: content, progress, heart timer
    lesson_controller.dart  wraps the engine's LessonRunner for one session
    content_store.dart   manifest + lazy unit loading from assets
    progress_store.dart  atomic single-file JSON persistence
  screens/
    path_screen.dart     the winding lesson path (Learn tab)
    lesson_screen.dart   exercise player with feedback panel
    results_screen.dart  end-of-session summary
    profile_screen.dart  stats, daily goal, about, reset (Profile tab)
  widgets/
    path_node.dart       path nodes + unit bands
    exercise_mcq.dart    multiple-choice view
    exercise_order.dart  step-ordering view
    exercise_match.dart  pairing view (auto-submits when complete)
    feedback_panel.dart  instant right/wrong feedback + source pill
    primary_button.dart  chunky lip button
    status_bar.dart      streak / hearts / daily-XP ring
assets/
  modules/islam/       generated course content (module.json + units/*.json)
  fonts/               bundled Nunito variable font
```

The app has **zero external package dependencies** - Flutter SDK plus the
local `ritualist_engine` package only. Keep it that way.

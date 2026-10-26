import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_state.dart';
import 'state/content_store.dart';
import 'state/progress_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RitualistApp(
      state: AppState(
        // Content ships in the bundle (assets/modules/<id>), one lazy store
        // per module; progress is a single small JSON file next to the user's
        // app data. No network, no database, no external packages - see
        // docs/architecture.md.
        registry: AssetContentRegistry(),
        store: FileProgressStore(),
      ),
    ),
  );
}

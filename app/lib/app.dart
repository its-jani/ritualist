import 'package:flutter/material.dart';

import 'screens/path_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/primary_button.dart';

/// Root widget: builds the themed [MaterialApp] and drives [AppState.init].
class RitualistApp extends StatefulWidget {
  const RitualistApp({super.key, required this.state});

  final AppState state;

  @override
  State<RitualistApp> createState() => _RitualistAppState();
}

class _RitualistAppState extends State<RitualistApp> {
  @override
  void initState() {
    super.initState();
    widget.state.init();
  }

  @override
  void dispose() {
    widget.state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritualist',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _Root(state: widget.state),
    );
  }
}

/// Switches between loading / error / ready and flushes progress to disk
/// when the app is backgrounded.
class _Root extends StatefulWidget {
  const _Root({required this.state});

  final AppState state;

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.state.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        switch (widget.state.phase) {
          case AppPhase.loading:
            return const _LoadingScreen();
          case AppPhase.error:
            return _ErrorScreen(
              message: widget.state.loadError,
              onRetry: widget.state.init,
            );
          case AppPhase.ready:
            return HomeShell(state: widget.state);
        }
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: RitualColors.jade),
            SizedBox(height: 16),
            Text('Ritualist', style: AppText.title),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: RitualColors.faint,
              ),
              const SizedBox(height: 14),
              const Text('Could not load content', style: AppText.title),
              const SizedBox(height: 6),
              Text(
                message ?? 'Unknown error',
                style: AppText.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 220,
                child: RitualButton(
                  label: 'Try again',
                  onPressed: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-tab shell: Learn (path) and Profile. The custom bar keeps the
/// bottom strip slim and the colors ours - no Material NavigationBar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: <Widget>[
          PathScreen(state: widget.state),
          ProfileScreen(state: widget.state),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onChanged: (int i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RitualColors.card,
        border: Border(top: BorderSide(color: RitualColors.line, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          width: double.infinity,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Row(
                children: <Widget>[
                  _BarButton(
                    icon: Icons.map_rounded,
                    label: 'Learn',
                    selected: index == 0,
                    onTap: () => onChanged(0),
                  ),
                  _BarButton(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    selected: index == 1,
                    onTap: () => onChanged(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? RitualColors.jade : RitualColors.faint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppText.label.copyWith(
                  fontSize: 11.5,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

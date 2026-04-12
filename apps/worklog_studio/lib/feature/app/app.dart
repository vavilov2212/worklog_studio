import 'package:get_it/get_it.dart';
import 'package:l/l.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio/core/environment/app_environment.dart';
// import 'package:worklog_studio/core/l10n/app_localizations.g.dart';
// import 'package:worklog_studio/feauture/localization_control/presentation/localization_scope.dart';
// import 'package:worklog_studio/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:worklog_studio/core/services/time_tracker_service.dart';
import 'package:worklog_studio/data/sqlite/sqlite_time_entry_repository.dart';
import 'package:worklog_studio/data/sqlite/sqlite_project_repository.dart';
import 'package:worklog_studio/data/sqlite/sqlite_task_repository.dart';
import 'package:worklog_studio/data/system_clock.dart';
import 'package:worklog_studio/feature/app/layout/app_bar/app_bar_scope.dart';
import 'package:worklog_studio/feature/app/layout/app_shell.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio_style_system/ui_kit/src/drawer/drawer_service.dart';

import 'layout/app_bar/app_bar_navigator_observer.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) {
          final clock = SystemClock();
          final repository = SqliteTimeEntryRepository();
          final service = TimeTrackerService(
            repository: repository,
            clock: clock,
          );
          return TimeTrackerState(service: service, clock: clock);
        },
      ),
      ChangeNotifierProvider(
        create: (_) {
          final clock = SystemClock();
          final projectRepo = SqliteProjectRepository();
          final taskRepo = SqliteTaskRepository();
          return ProjectTaskState(
            projectRepository: projectRepo,
            taskRepository: taskRepo,
            clock: clock,
          );
        },
      ),
    ],
    child: MaterialApp(
      title: appEnvironment.config.flavor.appTitle,
      showPerformanceOverlay:
          _getDebugConfig()?.showPerformanceOverlay ?? false,
      debugShowMaterialGrid: _getDebugConfig()?.debugShowMaterialGrid ?? false,
      checkerboardRasterCacheImages:
          _getDebugConfig()?.checkerboardRasterCacheImages ?? false,
      checkerboardOffscreenLayers:
          _getDebugConfig()?.checkerboardOffscreenLayers ?? false,
      showSemanticsDebugger: _getDebugConfig()?.showSemanticsDebugger ?? false,
      debugShowCheckedModeBanner:
          _getDebugConfig()?.debugShowCheckedModeBanner ?? false,
      // locale: LocalizationScope.localeOf(context),
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
      // supportedLocales: AppLocalizations.supportedLocales,
      theme: appEnvironment.config.lightTheme,
      darkTheme: appEnvironment.config.lightTheme,
      // routerConfig: _router,
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [AppBarNavigatorObserver()],
      builder: (context, child) {
        /*
       * This code registers the ROOT Overlay of the application
       * in DrawerService.
       *
       * Why this is done here and in this exact way:
       *
       * 1. In Flutter, Overlay is created by the Navigator.
       *    Documentation:
       *    https://api.flutter.dev/flutter/widgets/Navigator-class.html
       * 
       *    The widget build order looks like this:
       *
       *      MaterialApp
       *        └─ builder (THIS CODE)
       *            └─ Navigator
       *                └─ Overlay
       *
       *    At the moment when `builder` is executed:
       *    ❌ Overlay does NOT exist yet.
       *
       *    Calling:
       *      Overlay.of(context)
       *    at this point will throw:
       *      "No Overlay widget found"
       *
       *    Documentation:
       *    https://api.flutter.dev/flutter/widgets/Overlay/of.html
       *
       *
       * 2. To reliably access the root Overlay, we use a navigatorKey.
       *
       *    NavigatorState.overlay:
       *    https://api.flutter.dev/flutter/widgets/NavigatorState/overlay.html
       *
       *    This is the most stable and recommended way because:
       *    - it does not depend on BuildContext
       *    - it works correctly with nested Navigators
       *    - it uses an officially supported API
       *
       *
       * 3. Why addPostFrameCallback is required:
       *
       *    addPostFrameCallback guarantees that:
       *    - the first frame has already been rendered
       *    - Navigator and Overlay are already inserted into the widget tree
       *
       *    Without this callback, `navigatorKey.currentState?.overlay`
       *    may still be null.
       *
       *    Documentation:
       *    https://api.flutter.dev/flutter/scheduler/WidgetsBinding/addPostFrameCallback.html
       *
       *
       * 4. Why DrawerService does NOT store BuildContext:
       *
       *    DrawerService works only with OverlayState, which makes it:
       *    - independent from the Flutter widget tree
       *    - safe across rebuilds
       *    - callable from AppBar actions, hotkeys, and business logic
       *
       *
       * Summary:
       *  - UI (MaterialApp / Navigator) is responsible for creating Overlay
       *  - DrawerService only attaches to an already initialized Overlay
       *  - no logic depends on BuildContext
       */

        /*
       * ---
       * Edge Cases & Future Considerations
       * ---
       *
       * 1) For nested Navigators (e.g., Shell or nested tabs),
       *    overlay may not be reachable via rootNavigatorKey.
       *    In those cases you'll need a mechanism for obtaining
       *    the appropriate Navigator's OverlayState.
       *
       *    NavigatorState.overlay docs:
       *    https://api.flutter.dev/flutter/widgets/NavigatorState/overlay.html
       *
       * 2) If a new Router implementation (Router2.0 / GoRouter) is used,
       *    consider using Router.observer or GoRouterObserver
       *    instead of NavigatorObserver for navigation-change events
       *    since push/pop may not always use Navigator directly.
       *
       *    Router docs:
       *    https://api.flutter.dev/flutter/widgets/Router-class.html
       *
       * 3) If you add multiple overlay-based components (e.g., modals,
       *    snackbars, contextual menus), consider a unified overlay manager
       *    to avoid conflicts inserting overlays at inconsistent times.
       *
       *    Overlay docs:
       *    https://api.flutter.dev/flutter/widgets/Overlay-class.html
       */
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final overlay = rootNavigatorKey.currentState?.overlay;
            if (overlay != null) {
              GetIt.I<DrawerService>().attachRoot(overlay);
            }
          } catch (e, s) {
            l.e(e, s);
          }
        });

        return AppBarScope(child: child!);
      },
      home: const AppShell(),
    ),
  );
  DebugOptions? _getDebugConfig() => appEnvironment.config.debugOptions;
}

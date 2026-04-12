import 'package:flutter/material.dart';
import 'package:worklog_studio/core/services/service_locator/service_locator.dart';
import 'package:worklog_studio/feature/app/layout/app_bar/app_bar_config.dart';
import 'package:worklog_studio/feature/app/layout/app_bar/app_bar_service.dart';

class AppBarScope extends StatelessWidget {
  const AppBarScope({super.key, required this.child});

  final Widget child;

  static AppBarConfig of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<_AppBarInherited>();

    // ----------------------------
    // 🧠 EDGE CASE: If using multiple nested providers,
    // this will always pick the nearest one.
    // If you introduce complex nesting or multiple scaffold levels,
    // you may want to scope providers by Navigator stack.
    //
    // Documentation:
    // https://api.flutter.dev/flutter/widgets/InheritedWidget/dependOnInheritedWidgetOfExactType.html
    // ----------------------------
    return widget?.config ?? const AppBarConfig.hidden();
  }

  @override
  Widget build(BuildContext context) {
    final appBarService = getIt<AppBarService>();

    return ValueListenableBuilder<AppBarConfig>(
      valueListenable: appBarService,
      builder: (_, config, __) {
        return _AppBarInherited(config: config, child: child);
      },
    );
  }
}

class _AppBarInherited extends InheritedWidget {
  const _AppBarInherited({required this.config, required super.child});

  final AppBarConfig config;

  @override
  bool updateShouldNotify(covariant _AppBarInherited oldWidget) =>
      oldWidget.config != config;
}

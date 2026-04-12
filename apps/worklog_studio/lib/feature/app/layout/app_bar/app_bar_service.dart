import 'package:flutter/foundation.dart';
import 'app_bar_config.dart';

class AppBarService extends ValueNotifier<AppBarConfig> {
  AppBarService() : super(const AppBarConfig.hidden());

  void set(AppBarConfig config) => value = config;
  void reset() => value = const AppBarConfig.hidden();
}

import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
// import 'package:worklog_studio_style_system/resources/assets.gen.dart';
import 'package:flutter/material.dart';

part 'debug_options.dart';
part 'app_config.dart';
part 'flavors.dart';

final appEnvironment = AppEnvironment.instance();

/// AppEnvironment configuration.
class AppEnvironment {
  static AppEnvironment? _instance;
  final ValueNotifier<AppConfig> _config;

  /// Configuration.
  AppConfig get config => _config.value;
  set config(AppConfig c) => _config.value = c;

  AppEnvironment._(AppConfig config) : _config = ValueNotifier(config);

  /// Provides instance [AppEnvironment].
  factory AppEnvironment.instance() => _instance!;

  /// Initializing the AppEnvironment.
  static void init({required AppConfig config}) =>
      _instance ??= AppEnvironment._(config);
}

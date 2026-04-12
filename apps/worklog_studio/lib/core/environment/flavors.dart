part of 'app_environment.dart';

enum Flavor {
  development(
    appTitle: '[Dev] Worklog_studio',
    appFolder: 'Worklog_studio-dev',
  ),
  production(appTitle: 'Worklog Studio', appFolder: 'Worklog_studio');

  final String appTitle;
  final String appFolder;
  const Flavor({required this.appTitle, required this.appFolder});

  String get brandName => switch (this) {
    _ => 'Worklog_studio',
  };

  ThemeData get lightTheme => switch (this) {
    _ => AppTheme.lightThemeData,
  };
  ThemeData get darkTheme => switch (this) {
    _ => AppTheme.darkThemeData,
  };
}

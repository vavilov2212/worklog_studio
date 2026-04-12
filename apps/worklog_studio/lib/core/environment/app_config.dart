part of 'app_environment.dart';

/// Application configuration.
@immutable
class AppConfig {
  /// Server url.
  final String url;
  final String jwtSecret;
  final Flavor flavor;

  /// Additional application settings in debug mode.
  final DebugOptions? debugOptions;

  /// Create an instance [AppConfig].
  const AppConfig({
    this.debugOptions,
    required this.flavor,
    this.url = '',
    this.jwtSecret = '',
  });

  /// Create an instance [AppConfig] with modified parameters.
  AppConfig copyWith({
    String? url,
    String? jwtSecret,
    Flavor? flavor,
    DebugOptions? debugOptions,
  }) => AppConfig(
    url: url ?? this.url,
    jwtSecret: jwtSecret ?? this.jwtSecret,
    flavor: flavor ?? this.flavor,
    debugOptions: debugOptions ?? this.debugOptions,
  );

  String get brandName => flavor.brandName;
  ThemeData get lightTheme => flavor.lightTheme;
  ThemeData get darkTheme => flavor.darkTheme;
}

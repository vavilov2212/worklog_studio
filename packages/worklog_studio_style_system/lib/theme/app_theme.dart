import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette_entity.dart';
import 'package:worklog_studio_style_system/theme/theme_extension/app_theme_extension.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get lightThemeData => lightTheme;
  static ThemeData get darkThemeData => darkTheme;

  static AppThemeExtension themeExtension(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!;
}

final lightTheme = _getTheme(AppThemeExtension.light(), lightColorsPalette);

final darkTheme = _getTheme(
  AppThemeExtension.dark(),
  darkColorsPalette,
  isDark: true,
);

ThemeData _getTheme(
  AppThemeExtension themeExtention,
  ColorsPalette colorsPalette, {
  bool isDark = false,
}) => ThemeData(
  useMaterial3: true,
  extensions: [themeExtention],
  fontFamily: 'Inter',
  scaffoldBackgroundColor: colorsPalette.background.canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: colorsPalette.background.surfaceMuted,
    brightness: isDark ? Brightness.dark : Brightness.light,
    surface: colorsPalette.background.surface,
  ),
  canvasColor: colorsPalette.background.canvas,
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateColor.fromMap({
      WidgetState.disabled: colorsPalette.border.hover,
      WidgetState.selected: colorsPalette.border.hover,
      WidgetState.any: colorsPalette.border.hover,
    }),
    thumbColor: WidgetStateColor.fromMap({
      WidgetState.disabled: colorsPalette.border.hover,
      WidgetState.any: colorsPalette.border.hover,
    }),
    padding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    trackOutlineWidth: const WidgetStatePropertyAll<double>(0),
    trackOutlineColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: colorsPalette.accent.primary,
  ),
);

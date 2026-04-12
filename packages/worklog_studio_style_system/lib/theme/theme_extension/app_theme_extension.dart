import 'package:worklog_studio_style_system/theme/app_theme.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette_entity.dart';
import 'package:worklog_studio_style_system/theme/gradients/gradients.dart';
import 'package:worklog_studio_style_system/theme/radiuses.dart';
import 'package:worklog_studio_style_system/theme/shadows.dart';
import 'package:worklog_studio_style_system/theme/spacings.dart';
import 'package:worklog_studio_style_system/theme/text_styles/common_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ColorsPalette colorsPalette;
  final CommonTextStyles commonTextStyles;
  final Spacings spacings;
  final Radiuses radiuses;
  final Gradients gradients;
  final Shadows shadows;

  AppThemeExtension({required this.colorsPalette})
    : commonTextStyles = CommonTextStyles(),
      spacings = Spacings(),
      radiuses = Radiuses(),
      gradients = Gradients(),
      shadows = Shadows(colorsPalette);

  factory AppThemeExtension.light() =>
      AppThemeExtension(colorsPalette: lightColorsPalette);

  factory AppThemeExtension.dark() =>
      AppThemeExtension(colorsPalette: darkColorsPalette);

  @override
  ThemeExtension<AppThemeExtension> copyWith({ColorsPalette? colorsPalette}) =>
      AppThemeExtension(colorsPalette: colorsPalette ?? this.colorsPalette);

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) => AppThemeExtension(colorsPalette: colorsPalette);
}

extension BuildContextExtension on BuildContext {
  AppThemeExtension get theme => AppTheme.themeExtension(this);
}

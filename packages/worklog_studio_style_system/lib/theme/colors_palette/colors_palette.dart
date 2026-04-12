import 'package:worklog_studio_style_system/theme/colors/colors.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette_entity.dart';

const lightColorsPalette = ColorsPalette(
  base: BsColors(transparent: BaseColors.transparent),
  background: BackgroundColors(
    canvas: BgColors.canvas,
    surface: BgColors.surface,
    surfaceMuted: BgColors.surfaceMuted,
  ),
  border: BorderColors(
    primary: BrdColors.primary,
    hover: BrdColors.hover,
    focus: BrdColors.focus,
  ),
  text: TextColors(
    primary: TxtColors.primary,
    secondary: TxtColors.secondary,
    muted: TxtColors.muted,
  ),
  accent: AccentColors(
    primary: AccColors.primary,
    primaryMuted: AccColors.primaryMuted,
    danger: AccColors.danger,
    success: AccColors.success,
    warning: AccColors.warning,
  ),
);

const darkColorsPalette = ColorsPalette(
  base: BsColors(transparent: BaseColors.transparent),
  background: BackgroundColors(
    canvas: BgColors.canvas,
    surface: BgColors.surface,
    surfaceMuted: BgColors.surfaceMuted,
  ),
  border: BorderColors(
    primary: BrdColors.primary,
    hover: BrdColors.hover,
    focus: BrdColors.focus,
  ),
  text: TextColors(
    primary: TxtColors.primary,
    secondary: TxtColors.secondary,
    muted: TxtColors.muted,
  ),
  accent: AccentColors(
    primary: AccColors.primary,
    primaryMuted: AccColors.primaryMuted,
    danger: AccColors.danger,
    success: AccColors.success,
    warning: AccColors.warning,
  ),
);

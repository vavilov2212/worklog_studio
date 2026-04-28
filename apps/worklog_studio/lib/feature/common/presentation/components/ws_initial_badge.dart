import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

enum WsInitialBadgeSize { small, medium, large }

class WsInitialBadge extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final Color textColor;
  final WsInitialBadgeSize size;

  const WsInitialBadge({
    super.key,
    required this.initials,
    required this.backgroundColor,
    required this.textColor,
    this.size = WsInitialBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    double badgeSize;
    TextStyle textStyle;
    BorderRadius borderRadius;

    switch (size) {
      case WsInitialBadgeSize.small:
        badgeSize = 24.0;
        textStyle = theme.commonTextStyles.caption3Bold;
        borderRadius = theme.radiuses.sm.circular;
        break;
      case WsInitialBadgeSize.medium:
        badgeSize = 32.0;
        textStyle = theme.commonTextStyles.captionBold;
        borderRadius = theme.radiuses.md.circular;
        break;
      case WsInitialBadgeSize.large:
        badgeSize = 40.0;
        textStyle = theme.commonTextStyles.bodyBold;
        borderRadius = theme.radiuses.md.circular;
        break;
    }

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: textStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

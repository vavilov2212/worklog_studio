import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class CardContent extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? description;
  final Widget? trailing;
  final Widget? bottom;

  const CardContent({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.description,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: theme.spacings.s16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,
                  if (subtitle != null) ...[
                    SizedBox(height: theme.spacings.s4),
                    subtitle!,
                  ],
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (description != null) ...[
                    Row(
                      children: [
                        SizedBox(height: theme.spacings.s4),
                        description!,
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: theme.spacings.s16),
              trailing!,
            ],
          ],
        ),
        if (bottom != null) ...[SizedBox(height: theme.spacings.s16), bottom!],
      ],
    );
  }
}

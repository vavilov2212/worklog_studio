import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class DrawerContent extends StatelessWidget {
  final Widget? meta;
  final Widget content;
  final Widget? footer;

  const DrawerContent({
    super.key,
    this.meta,
    required this.content,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (meta != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacings.s32,
              theme.spacings.s24,
              theme.spacings.s32,
              0,
            ),
            child: meta!,
          ),
          SizedBox(height: theme.spacings.s32),
        ],
        Expanded(child: content),
        if (footer != null) ...[
          Padding(padding: EdgeInsets.all(theme.spacings.s24), child: footer!),
        ],
      ],
    );
  }
}

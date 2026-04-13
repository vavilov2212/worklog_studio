import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class SelectTrigger extends StatelessWidget {
  final String? label;
  final String placeholder;

  const SelectTrigger({required this.label, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final hasValue = label != null;

    return Container(
      height: theme.spacings.s48,
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacings.s12,
        vertical: theme.spacings.s12,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: palette.border.primary),
        borderRadius: theme.radiuses.md.circular,
        color: palette.background.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              hasValue ? label! : placeholder,
              style: theme.commonTextStyles.body.copyWith(
                color: hasValue ? palette.text.primary : palette.text.muted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.unfold_more, size: 18, color: palette.text.muted),
        ],
      ),
    );
  }
}

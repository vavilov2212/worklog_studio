import 'package:flutter/material.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/feature/common/presentation/components/card_content.dart';
import 'package:worklog_studio/feature/common/presentation/interactive_card.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette_entity.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class TaskCard extends StatelessWidget {
  final ResolvedTask task;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    Color accentColor;
    IconData trailingIcon;
    Color trailingIconColor;

    switch (task.status) {
      case TaskStatus.open:
        accentColor = palette.accent.primary;
        trailingIcon = Icons.radio_button_unchecked;
        trailingIconColor = palette.text.muted;
        break;
      case TaskStatus.done:
        accentColor = palette.accent.success;
        trailingIcon = Icons.check_circle;
        trailingIconColor = palette.text.secondary;
        break;
      default:
        accentColor = Colors.transparent;
        trailingIcon = Icons.radio_button_unchecked;
        trailingIconColor = palette.text.muted;
        break;
    }

    return InteractiveCard(
      isSelected: isSelected,
      onTap: onTap,
      child: CardContent(
        leading: accentColor != Colors.transparent
            ? Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: theme.radiuses.pill.circular,
                ),
              )
            : const SizedBox(width: 4, height: 40),
        title: Text(
          task.title,
          style: task.status == TaskStatus.done
              ? theme.commonTextStyles.h3.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: palette.text.secondary,
                )
              : theme.commonTextStyles.h3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacings.s8,
                    vertical: theme.spacings.s2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      task.status,
                      palette,
                    ).withValues(alpha: 0.1),
                    borderRadius: theme.radiuses.sm.circular,
                  ),
                  child: Text(
                    _getStatusText(task.status),
                    style: theme.commonTextStyles.caption3Bold.copyWith(
                      color: _getStatusColor(task.status, palette),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(width: theme.spacings.s8),
                Text(
                  task.projectName,
                  style: theme.commonTextStyles.caption.copyWith(
                    color: palette.text.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        description: Text(
          task.description.isEmpty ? 'No description' : task.description,
          style: task.status == TaskStatus.done
              ? theme.commonTextStyles.caption.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: palette.text.secondary.withValues(alpha: 0.5),
                )
              : theme.commonTextStyles.caption.copyWith(
                  color: task.description.isEmpty
                      ? palette.text.secondary.withValues(alpha: 0.5)
                      : palette.text.secondary,
                ),
        ),
        trailing: Icon(trailingIcon, color: trailingIconColor, size: 24),
      ),
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.open:
        return 'OPEN';
      case TaskStatus.done:
        return 'DONE';
      case TaskStatus.archived:
        return 'ARCHIVED';
    }
  }

  Color _getStatusColor(TaskStatus status, ColorsPalette palette) {
    switch (status) {
      case TaskStatus.open:
        return palette.accent.primary;
      case TaskStatus.done:
        return palette.accent.success;
      case TaskStatus.archived:
        return palette.text.secondary;
    }
  }
}

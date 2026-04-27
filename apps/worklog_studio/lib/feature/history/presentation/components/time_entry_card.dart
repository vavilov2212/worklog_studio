import 'package:flutter/material.dart';
import 'package:worklog_studio/feature/common/presentation/components/card_content.dart';
import 'package:worklog_studio/feature/common/presentation/interactive_card.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';

class TimeEntryCard extends StatelessWidget {
  final ResolvedTimeEntry resolvedEntry;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeEntryCard({
    super.key,
    required this.resolvedEntry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return InteractiveCard(
      isSelected: isSelected,
      onTap: onTap,
      child: CardContent(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: palette.accent.primary,
            borderRadius: theme.radiuses.pill.circular,
          ),
        ),
        title: Text(resolvedEntry.taskTitle, style: theme.commonTextStyles.h3),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              resolvedEntry.projectName,
              style: theme.commonTextStyles.caption.copyWith(
                color: palette.text.secondary,
              ),
            ),
          ],
        ),

        description: Text(
          (resolvedEntry.entry.comment?.isEmpty == null ||
                  resolvedEntry.entry.comment?.isEmpty == true)
              ? 'No comment'
              : resolvedEntry.entry.comment!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.commonTextStyles.caption.copyWith(
            color:
                (resolvedEntry.entry.comment?.isEmpty == null ||
                    resolvedEntry.entry.comment?.isEmpty == true)
                ? palette.text.secondary.withValues(alpha: 0.5)
                : palette.text.secondary,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(resolvedEntry.duration(DateTime.now())),
              style: theme.commonTextStyles.bodyBold.copyWith(
                color: resolvedEntry.isRunning
                    ? palette.accent.primary
                    : palette.text.primary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: theme.spacings.s4),
            Text(
              _formatTimeRange(resolvedEntry.startAt, resolvedEntry.endAt),
              style: theme.commonTextStyles.caption.copyWith(
                color: palette.text.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    final startStr = _formatTime(start);
    final endStr = end != null ? _formatTime(end) : 'Now';
    return '$startStr - $endStr';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}

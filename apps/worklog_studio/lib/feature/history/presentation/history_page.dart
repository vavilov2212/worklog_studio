import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'components/time_entry_card.dart';
import 'components/time_entry_drawer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TimeEntry? selectedEntry;

  void _handleCreateEntry() {
    final now = DateTime.now();
    setState(() {
      selectedEntry = TimeEntry(
        id: '',
        startAt: now,
        endAt: now.add(const Duration(hours: 1)),
        status: TimeEntryStatus.stopped,
      );
    });
  }

  void _handleEntrySelected(TimeEntry entry) {
    setState(() {
      if (selectedEntry?.id == entry.id) {
        selectedEntry = null; // Toggle off if clicking the same entry
      } else {
        selectedEntry = entry;
      }
    });
  }

  void _closePanel() {
    setState(() {
      selectedEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EntityResolver, List<ResolvedTimeEntry>>(
      selector: (context, resolver) => resolver.getResolvedTimeEntries(),
      shouldRebuild: (prev, next) => !const ListEquality().equals(prev, next),
      builder: (context, resolvedEntries, child) {
        ResolvedTimeEntry? resolvedSelectedEntry;

        if (selectedEntry != null) {
          resolvedSelectedEntry = resolvedEntries.firstWhereOrNull(
            (e) => e.entry.id == selectedEntry!.id,
          );

          // If it's a new entry (not yet in state), we resolve it manually
          if (resolvedSelectedEntry == null && selectedEntry!.id.isEmpty) {
            final projectTaskState = context.read<ProjectTaskState>();
            final task = selectedEntry!.taskId != null
                ? projectTaskState.tasks
                      .where((t) => t.id == selectedEntry!.taskId)
                      .firstOrNull
                : null;
            final project = selectedEntry!.projectId != null
                ? projectTaskState.projects
                      .where((p) => p.id == selectedEntry!.projectId)
                      .firstOrNull
                : null;

            resolvedSelectedEntry = ResolvedTimeEntry(
              entry: selectedEntry!,
              task: task,
              project: project,
            );
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Content Area (Shrinks when panel opens)
            Expanded(
              child: TimeEntryList(
                entries: resolvedEntries,
                selectedEntry: selectedEntry,
                onEntrySelected: _handleEntrySelected,
                onCreateEntry: _handleCreateEntry,
              ),
            ),
            TimeEntryDrawer(
              resolvedEntry: resolvedSelectedEntry,
              isOpen: resolvedSelectedEntry != null,
              onClose: _closePanel,
              isNew: selectedEntry != null && selectedEntry!.id.isEmpty,
            ),
          ],
        );
      },
    );
  }
}

class TimeEntryList extends StatelessWidget {
  final List<ResolvedTimeEntry> entries;
  final TimeEntry? selectedEntry;
  final ValueChanged<TimeEntry> onEntrySelected;
  final VoidCallback onCreateEntry;

  const TimeEntryList({
    super.key,
    required this.entries,
    required this.selectedEntry,
    required this.onEntrySelected,
    required this.onCreateEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    // Sort entries: latest first
    final sortedEntries = List<ResolvedTimeEntry>.from(entries)
      ..sort((a, b) {
        // Active entries always at the top
        if (a.isRunning && !b.isRunning) return -1;
        if (!a.isRunning && b.isRunning) return 1;
        return b.startAt.compareTo(a.startAt);
      });

    // Group by date
    final Map<DateTime, List<ResolvedTimeEntry>> groupedEntries = {};
    for (final resolvedEntry in sortedEntries) {
      final entry = resolvedEntry.entry;
      final date = DateTime(
        entry.startAt.year,
        entry.startAt.month,
        entry.startAt.day,
      );
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }
      groupedEntries[date]!.add(resolvedEntry);
    }

    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacings.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time History', style: theme.commonTextStyles.displayLarge),
              PrimaryButton(
                onTap: onCreateEntry,
                title: 'New Entry',
                leftIcon: WorklogStudioAssets.vectors.plus24Svg,
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          ...sortedDates.map((date) {
            final dailyEntries = groupedEntries[date]!;
            final totalDuration = dailyEntries.fold<Duration>(
              Duration.zero,
              (prev, resolvedEntry) =>
                  prev + resolvedEntry.entry.duration(DateTime.now()),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: theme.spacings.s16,
                    top: theme.spacings.s16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateHeader(date),
                        style: theme.commonTextStyles.caption3Bold.copyWith(
                          color: palette.text.secondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Total: ${_formatDuration(totalDuration)}',
                        style: theme.commonTextStyles.bodyBold.copyWith(
                          color: palette.text.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  spacing: theme.spacings.s12,
                  children: dailyEntries.map((resolvedEntry) {
                    final entry = resolvedEntry.entry;
                    final isSelected = selectedEntry?.id == entry.id;

                    return TimeEntryCard(
                      resolvedEntry: resolvedEntry,
                      isSelected: isSelected,
                      onTap: () => onEntrySelected(entry),
                    );
                  }).toList(),
                ),
                SizedBox(height: theme.spacings.s24),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateString = '${months[date.month - 1]} ${date.day}';

    if (targetDate == today) {
      return 'TODAY, $dateString';
    } else if (targetDate == yesterday) {
      return 'YESTERDAY, $dateString';
    }
    return dateString;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

import 'package:flutter/material.dart' hide DrawerControllerState;
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/feature/common/presentation/drawer_controller_state.dart';
import 'components/time_entry_card.dart';
import 'components/time_entry_drawer.dart';

enum HistoryViewMode { cards, table }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DrawerControllerState<TimeEntry> _drawerState =
      DrawerControllerState.closed();
  HistoryViewMode _viewMode = HistoryViewMode.table;

  void _handleCreateEntry() {
    setState(() {
      _drawerState = DrawerControllerState.create();
    });
  }

  void _handleEntrySelected(TimeEntry entry) {
    setState(() {
      if (_drawerState.state == DrawerState.edit &&
          _drawerState.entity?.id == entry.id) {
        _drawerState = DrawerControllerState.closed(); // Toggle off
      } else {
        _drawerState = DrawerControllerState.edit(entry);
      }
    });
  }

  void _closePanel() {
    setState(() {
      _drawerState = DrawerControllerState.closed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProjectTaskState>();
    final resolvedEntries = context
        .read<EntityResolver>()
        .getResolvedTimeEntries();

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: TimeEntryList(
              entries: resolvedEntries,
              selectedEntry: _drawerState.entity,
              onEntrySelected: _handleEntrySelected,
              onCreateEntry: _handleCreateEntry,
              viewMode: _viewMode,
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
            ),
          ),
          TimeEntryDrawer(
            resolvedEntry: _drawerState.entity != null
                ? resolvedEntries.firstWhereOrNull(
                    (e) => e.entry.id == _drawerState.entity!.id,
                  )
                : null,
            isOpen: _drawerState.isOpen,
            onClose: _closePanel,
          ),
        ],
      ),
    );
  }
}

class TimeEntryList extends StatelessWidget {
  final List<ResolvedTimeEntry> entries;
  final TimeEntry? selectedEntry;
  final ValueChanged<TimeEntry> onEntrySelected;
  final VoidCallback onCreateEntry;
  final HistoryViewMode viewMode;
  final ValueChanged<HistoryViewMode> onViewModeChanged;

  const TimeEntryList({
    super.key,
    required this.entries,
    required this.selectedEntry,
    required this.onEntrySelected,
    required this.onCreateEntry,
    required this.viewMode,
    required this.onViewModeChanged,
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

    return Padding(
      padding: EdgeInsets.all(theme.spacings.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time History', style: theme.commonTextStyles.displayLarge),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacings.s16,
                children: [
                  _ViewModeToggle(
                    viewMode: viewMode,
                    onChanged: onViewModeChanged,
                  ),
                  PrimaryButton(
                    onTap: onCreateEntry,
                    title: 'New Entry',
                    leftIcon: WorklogStudioAssets.vectors.plus24Svg,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                style: theme.commonTextStyles.captionBold
                                    .copyWith(
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
                        if (viewMode == HistoryViewMode.cards)
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
                          )
                        else
                          WsTable<ResolvedTimeEntry>(
                            showHeader: true,
                            data: dailyEntries,
                            selectedItem: dailyEntries.firstWhereOrNull(
                              (e) => e.entry.id == selectedEntry?.id,
                            ),
                            onRowTap: (item) => onEntrySelected(item.entry),
                            isSelected: (item, selected) =>
                                item.entry.id == selected?.entry.id,
                            columns: _getTableColumns(theme),
                          ),
                        SizedBox(height: theme.spacings.s24),
                      ],
                    );
                  }).toList(),
                  // Footer
                  if (entries.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: theme.spacings.s16),
                      padding: EdgeInsets.only(
                        top: theme.spacings.s24,
                        bottom: theme.spacings.s16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: palette.border.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'View all ${entries.length} sessions'.toUpperCase(),
                        style: theme.commonTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.text.secondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<WsTableColumn<ResolvedTimeEntry>> _getTableColumns(
    AppThemeExtension theme,
  ) {
    return [
      WsTableColumn(
        title: 'Task & Project',
        flex: 3,
        builder: (context, item) {
          final palette = theme.colorsPalette;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.taskTitle,
                style: theme.commonTextStyles.bodyBold.copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.projectName,
                style: theme.commonTextStyles.caption.copyWith(
                  color: palette.text.secondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      WsTableColumn(
        title: 'Duration',
        flex: 2,
        builder: (context, item) {
          final palette = theme.colorsPalette;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatExactDuration(item.duration(DateTime.now())),
                style: theme.commonTextStyles.bodyBold.copyWith(
                  color: item.isRunning
                      ? palette.accent.primary
                      : palette.text.primary,
                ),
              ),
              Text(
                _formatTimeRange(item.startAt, item.endAt),
                style: theme.commonTextStyles.caption.copyWith(
                  color: palette.text.secondary,
                ),
              ),
            ],
          );
        },
      ),
      WsTableColumn(
        title: 'Efficiency',
        flex: 1,
        builder: (context, item) {
          final palette = theme.colorsPalette;
          return Text(
            '94%',
            style: theme.commonTextStyles.body.copyWith(
              color: palette.accent.success,
            ),
          );
        },
      ),
      WsTableColumn(
        title: 'Status',
        flex: 1,
        builder: (context, item) {
          if (item.isRunning) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                status: BadgeStatus.inProgress,
                label: 'Running',
              ),
            );
          }
          return const Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(status: BadgeStatus.ready, label: 'Logged'),
          );
        },
      ),
      WsTableColumn(
        title: 'Actions',
        flex: 1,
        builder: (context, item) {
          return const SizedBox.shrink();
        },
      ),
    ];
  }

  String _formatExactDuration(Duration duration) {
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

class _ViewModeToggle extends StatelessWidget {
  final HistoryViewMode viewMode;
  final ValueChanged<HistoryViewMode> onChanged;

  const _ViewModeToggle({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.background.surfaceMuted,
        borderRadius: theme.radiuses.md.circular,
      ),
      padding: EdgeInsets.all(theme.spacings.s4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            icon: Icons.view_agenda_rounded,
            isSelected: viewMode == HistoryViewMode.cards,
            onTap: () => onChanged(HistoryViewMode.cards),
          ),
          _buildToggleButton(
            context,
            icon: Icons.table_rows_rounded,
            isSelected: viewMode == HistoryViewMode.table,
            onTap: () => onChanged(HistoryViewMode.table),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Material(
      color: isSelected ? palette.background.surface : Colors.transparent,
      borderRadius: theme.radiuses.sm.circular,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(theme.spacings.s8),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: palette.border.primary.withValues(alpha: 0.5),
                  )
                : Border.all(color: Colors.transparent),
            borderRadius: theme.radiuses.sm.circular,
            boxShadow: isSelected ? [theme.shadows.sm] : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? palette.text.primary : palette.text.secondary,
          ),
        ),
      ),
    );
  }
}

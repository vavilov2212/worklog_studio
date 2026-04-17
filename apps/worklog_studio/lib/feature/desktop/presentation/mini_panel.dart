import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/feature/desktop/presentation/mini_tracker_cubit.dart';
import 'package:worklog_studio/feature/time_tracker/presentation/components/active_timer_text.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'package:collection/collection.dart';
import 'package:worklog_studio/core/services/desktop/desktop_service.dart';

class MiniPanel extends StatefulWidget {
  const MiniPanel({super.key});

  @override
  State<MiniPanel> createState() => _MiniPanelState();
}

class _MiniPanelState extends State<MiniPanel> {
  static const _platform = MethodChannel('worklog_studio/ipc');
  bool _isVisible = false;
  bool _isExpanded = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  void _toggleExpansion() {
    setState(() => _isExpanded = !_isExpanded);
    _platform.invokeMethod('resizePopover', {'isExpanded': _isExpanded});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildActiveSession(
    bool isRunning,
    TimeEntry? activeEntry,
    MiniTrackerState state,
    AppThemeExtension theme,
    BuildContext context,
  ) {
    if (!isRunning || activeEntry == null) {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacings.s12),
            child: Text(
              'No active session running.',
              style: theme.commonTextStyles.caption.copyWith(
                color: theme.colorsPalette.text.secondary,
              ),
            ),
          ),
        ],
      );
    }

    final task = activeEntry.taskId != null
        ? state.tasks.firstWhereOrNull(
            (t) =>
                t.id == activeEntry.taskId &&
                t.projectId == activeEntry.projectId,
          )
        : null;
    final project = activeEntry.projectId != null
        ? state.projects.firstWhereOrNull((p) => p.id == activeEntry.projectId)
        : null;

    final taskName = task?.title ?? activeEntry.comment ?? 'Running Task';
    final projectName = project?.name;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorsPalette.background.surface,
        borderRadius: theme.radiuses.md.circular,
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacings.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVE SESSION',
              style: theme.commonTextStyles.caption2.copyWith(
                color: theme.colorsPalette.accent.primary,
              ),
            ),
            SizedBox(height: theme.spacings.s4),
            Text(
              taskName,
              style: theme.commonTextStyles.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (projectName != null) ...[
              SizedBox(height: theme.spacings.s0),
              Text(
                projectName,
                style: theme.commonTextStyles.caption.copyWith(
                  color: theme.colorsPalette.text.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: theme.spacings.s4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _MiniActiveTimerTextWrapper(
                  entry: activeEntry,
                  style: theme.commonTextStyles.title,
                ),
                const Spacer(),
                PrimaryButton(
                  type: ButtonType.danger,
                  size: ButtonSize.sm,
                  leftIconWidget: const Icon(Icons.stop_sharp),
                  onTap: () {
                    context.read<MiniTrackerCubit>().stopTimer();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(AppThemeExtension theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.note_add, size: 16),
              SizedBox(height: theme.spacings.s4),
              Text('Add Note', style: theme.commonTextStyles.body),
            ],
          ),
        ),
        SizedBox(width: theme.spacings.s12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, size: 16),
              SizedBox(height: theme.spacings.s4),
              Text('Log Manual', style: theme.commonTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(
    Task task,
    Project? project,
    AppThemeExtension theme,
    BuildContext context,
    bool isActive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacings.s4),
      child: Row(
        children: [
          Icon(Icons.work, size: 16, color: theme.colorsPalette.accent.primary),
          SizedBox(width: theme.spacings.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.commonTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project != null) ...[
                  SizedBox(height: theme.spacings.s0),
                  Text(
                    project.name,
                    style: theme.commonTextStyles.caption.copyWith(
                      color: theme.colorsPalette.text.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: theme.spacings.s8),
          if (isActive)
            PrimaryButton(
              type: ButtonType.ghost,
              size: ButtonSize.sm,
              leftIconWidget: Icon(
                Icons.stop,
                // color: theme.colorsPalette.semantic.negative,
              ),
              onTap: () {
                context.read<MiniTrackerCubit>().stopTimer();
              },
            )
          else
            PrimaryButton(
              type: ButtonType.ghost,
              size: ButtonSize.sm,
              leftIconWidget: Icon(
                Icons.play_arrow,
                color: theme.colorsPalette.text.primary,
              ),
              onTap: () {
                context.read<MiniTrackerCubit>().startTimer(
                  projectId: project?.id,
                  taskId: task.id,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(MiniTrackerState state, AppThemeExtension theme) {
    // Get unique recent tasks based on all entries (newest entries first usually)
    final recentTaskIds = state.allEntries
        .where((e) => e.taskId != null)
        .map((e) => e.taskId!)
        .toSet()
        .toList();

    var recentTasks = recentTaskIds
        .take(5)
        .map((id) => state.tasks.firstWhereOrNull((t) => t.id == id))
        .whereType<Task>()
        .toList();

    // Fallback if no logged entries
    if (recentTasks.isEmpty) {
      recentTasks = state.tasks.take(5).toList();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: theme.commonTextStyles.caption2Bold.copyWith(
                color: theme.colorsPalette.text.secondary2,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                DesktopService().openHistoryFromTray();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacings.s4,
                  vertical: theme.spacings.s2,
                ),
                child: Text(
                  'View All',
                  style: theme.commonTextStyles.caption2.copyWith(
                    color: theme.colorsPalette.accent.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacings.s4),
        if (recentTasks.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacings.s8),
            child: Text(
              'No recent tasks.',
              style: theme.commonTextStyles.body.copyWith(
                color: theme.colorsPalette.text.muted,
              ),
            ),
          )
        else
          Column(
            children: recentTasks.map((task) {
              final project = task.projectId != null
                  ? state.projects.firstWhereOrNull(
                      (p) => p.id == task.projectId,
                    )
                  : null;
              final isActive =
                  state.isRunning && state.activeEntry?.taskId == task.id;
              return _buildTaskItem(task, project, theme, context, isActive);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSearchResults(MiniTrackerState state, AppThemeExtension theme) {
    final queryLower = _query.toLowerCase();
    final filteredTasks = state.tasks
        .where((t) => t.title.toLowerCase().contains(queryLower))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SEARCH RESULTS',
              style: theme.commonTextStyles.caption2Bold.copyWith(
                color: theme.colorsPalette.text.secondary2,
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacings.s4),
        if (filteredTasks.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacings.s8),
            child: Text(
              'No tasks found.',
              style: theme.commonTextStyles.body.copyWith(
                color: theme.colorsPalette.text.muted,
              ),
            ),
          )
        else
          Column(
            children: filteredTasks.map((task) {
              final project = task.projectId != null
                  ? state.projects.firstWhereOrNull(
                      (p) => p.id == task.projectId,
                    )
                  : null;
              final isActive =
                  state.isRunning && state.activeEntry?.taskId == task.id;
              return _buildTaskItem(task, project, theme, context, isActive);
            }).toList(),
          ),
      ],
    );
  }

  String _formatDateHeader(DateTime date) {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
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
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    // Project and Entity state cannot be easily retrieved dynamically from the Cubit/IPC
    // currently unless we broadcast the whole lookup dictionary.
    // For now we will display the comment.

    return BlocBuilder<MiniTrackerCubit, MiniTrackerState>(
      builder: (context, state) {
        final isRunning = state.isRunning;
        final activeEntry = state.activeEntry;

        // Group entries by date
        final allEntries = state.allEntries.where((e) => !e.isRunning).toList()
          ..sort((a, b) => b.startAt.compareTo(a.startAt));

        final groupedEntries = groupBy(allEntries, (TimeEntry e) {
          final local = e.startAt.toLocal();
          return DateTime(local.year, local.month, local.day);
        });
        final theme = context.theme;
        final palette = theme.colorsPalette;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isVisible ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: palette.background.surface,
              // color: Colors.red,
              borderRadius: BorderRadius.circular(theme.spacings.s12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: palette.border.primary.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.spacings.s12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorsPalette.accent.primaryMuted,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacings.s16,
                          vertical: theme.spacings.s8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Worklog Studio',
                              style: theme.commonTextStyles.captionSemiBold,
                            ),
                            Expanded(flex: 1, child: const SizedBox.shrink()),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIconWidget: const Icon(
                                Icons.keyboard_double_arrow_down_sharp,
                              ),
                              onTap: _toggleExpansion,
                            ),
                            SizedBox(width: theme.spacings.s4),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIconWidget: const Icon(Icons.add_outlined),
                              onTap: () {},
                            ),
                            SizedBox(width: theme.spacings.s4),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIconWidget: const Icon(Icons.desktop_windows),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorsPalette.background.surface,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacings.s16,
                          vertical: theme.spacings.s12,
                        ),
                        child: PrimaryInput(
                          label: null,
                          controller: _searchController,
                          hintText: 'Search or start a task…',
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              _query = value.trim();
                              if (_query.isNotEmpty && !_isExpanded) {
                                _isExpanded = true;
                                _platform.invokeMethod('resizePopover', {
                                  'isExpanded': _isExpanded,
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorsPalette.background.surfaceMuted,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacings.s16,
                          vertical: theme.spacings.s12,
                        ),
                        child: _buildActiveSession(
                          isRunning,
                          activeEntry,
                          state,
                          theme,
                          context,
                        ),
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: theme.colorsPalette.background.surfaceMuted,
                    //   ),
                    //   child: Expanded(
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: theme.spacings.s16,
                    //         vertical: theme.spacings.s12,
                    //       ),
                    //       child: _buildActionGrid(theme),
                    //     ),
                    //   ),
                    // ),
                    if (_isExpanded) ...[
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorsPalette.background.surfaceMuted,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: theme.spacings.s16,
                              vertical: theme.spacings.s12,
                            ),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: _query.isEmpty
                                  ? _buildRecentActivity(state, theme)
                                  : _buildSearchResults(state, theme),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorsPalette.accent.primaryMuted,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacings.s16,
                          vertical: theme.spacings.s8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Today 06h 15m | Total 24h 30m',
                              style: theme.commonTextStyles.caption,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniActiveTimerTextWrapper extends StatefulWidget {
  final TimeEntry? entry;
  final TextStyle? style;

  const _MiniActiveTimerTextWrapper({required this.entry, this.style});

  @override
  State<_MiniActiveTimerTextWrapper> createState() =>
      _MiniActiveTimerTextWrapperState();
}

class _MiniActiveTimerTextWrapperState
    extends State<_MiniActiveTimerTextWrapper> {
  late Stream<int> _timerStream;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _recalc();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  void _recalc() {
    if (widget.entry != null) {
      final now = DateTime.now();
      _seconds = now.difference(widget.entry!.startAt).inSeconds;
    } else {
      _seconds = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _MiniActiveTimerTextWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recalc();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
        _recalc(); // Recalc each second
        final duration = Duration(seconds: _seconds);
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        final formatted =
            "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";

        return Text(
          formatted,
          style:
              widget.style ??
              context.theme.commonTextStyles.captionBold.copyWith(
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio/feature/tasks/presentation/components/tasks_card.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/feature/history/presentation/components/time_entry_card.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacings.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashboardHeader(),
          SizedBox(height: theme.spacings.s32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: const _DailyFocusCard()),
              SizedBox(width: theme.spacings.s24),
              Expanded(child: const _WeeklyEarningsCard()),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: const _TopTasksSection()),
              SizedBox(width: theme.spacings.s24),
              Expanded(flex: 4, child: const _RecentActivitySection()),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final state = context.watch<TimeTrackerState>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: theme.commonTextStyles.displayLarge),
            SizedBox(height: theme.spacings.s4),
            Text(
              'Welcome back. Here\'s your workflow for today.',
              style: theme.commonTextStyles.body.copyWith(
                color: palette.text.secondary,
              ),
            ),
          ],
        ),
        PrimaryButton(
          title: 'Add Time Entry',
          onTap: () {
            state.start();
          },
        ),
      ],
    );
  }
}

class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final state = context.watch<TimeTrackerState>();

    // Calculate total time for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEntries = state.entries.where((e) {
      final start = DateTime(e.startAt.year, e.startAt.month, e.startAt.day);
      return start == today;
    });

    final totalDuration = todayEntries.fold<Duration>(
      Duration.zero,
      (prev, entry) => prev + entry.duration(now),
    );

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final timeString = '${hours}h ${minutes}m';

    return Container(
      padding: EdgeInsets.all(theme.spacings.s24),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: theme.radiuses.lg.circular,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Focus', style: theme.commonTextStyles.title),
              if (state.isRunning)
                const StatusBadge(
                  status: BadgeStatus.inProgress,
                  label: 'ACTIVE',
                ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeString, style: theme.commonTextStyles.h2),
                  Text(
                    'LOGGED TODAY',
                    style: theme.commonTextStyles.caption3Bold.copyWith(
                      color: palette.text.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyEarningsCard extends StatelessWidget {
  const _WeeklyEarningsCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Container(
      padding: EdgeInsets.all(theme.spacings.s24),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: theme.radiuses.lg.circular,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Earnings', style: theme.commonTextStyles.title),
                  Text(
                    'Coming Soon',
                    style: theme.commonTextStyles.body2.copyWith(
                      color: palette.text.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Text(
            'Financial tracking features will be available in a future update.',
            style: theme.commonTextStyles.body.copyWith(
              color: palette.text.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTasksSection extends StatelessWidget {
  const _TopTasksSection();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.watch<ProjectTaskState>();
    final timeTrackerState = context.watch<TimeTrackerState>();

    // Calculate total time per task
    final Map<String, Duration> taskDurations = {};
    for (final entry in timeTrackerState.entries) {
      if (entry.taskId != null) {
        taskDurations[entry.taskId!] =
            (taskDurations[entry.taskId!] ?? Duration.zero) +
            entry.duration(DateTime.now());
      }
    }

    // Sort tasks by duration
    final sortedTasks = List.of(projectTaskState.tasks)
      ..sort((a, b) {
        final durationA = taskDurations[a.id] ?? Duration.zero;
        final durationB = taskDurations[b.id] ?? Duration.zero;
        return durationB.compareTo(durationA);
      });

    final topTasks = sortedTasks.take(5).toList();

    return Container(
      padding: EdgeInsets.all(theme.spacings.s24),
      decoration: BoxDecoration(
        color: palette.background.surfaceMuted,
        borderRadius: theme.radiuses.lg.circular,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Tasks', style: theme.commonTextStyles.h3),
              Text(
                'View All',
                style: theme.commonTextStyles.bodyBold.copyWith(
                  color: palette.accent.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s24),
          if (topTasks.isEmpty)
            Text(
              'No tasks tracked yet.',
              style: theme.commonTextStyles.body.copyWith(
                color: palette.text.muted,
              ),
            )
          else
            Column(
              spacing: theme.spacings.s16,
              children: topTasks.map((task) {
                return TaskCard(task: task, isSelected: false, onTap: () {});
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final state = context.watch<TimeTrackerState>();
    final projectTaskState = context.watch<ProjectTaskState>();

    final sortedEntries = List.of(state.entries)
      ..sort((a, b) {
        if (a.isRunning && !b.isRunning) return -1;
        if (!a.isRunning && b.isRunning) return 1;
        return b.startAt.compareTo(a.startAt);
      });

    final recentEntries = sortedEntries.take(5).toList();

    return Container(
      padding: EdgeInsets.all(theme.spacings.s24),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: theme.radiuses.lg.circular,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.commonTextStyles.h3),
          SizedBox(height: theme.spacings.s24),
          if (recentEntries.isEmpty)
            Text(
              'No recent activity.',
              style: theme.commonTextStyles.body.copyWith(
                color: palette.text.muted,
              ),
            )
          else
            Column(
              spacing: theme.spacings.s12,
              children: recentEntries.map((entry) {
                final task = entry.taskId != null
                    ? projectTaskState.tasks
                          .where((t) => t.id == entry.taskId)
                          .firstOrNull
                    : null;
                final project = entry.projectId != null
                    ? projectTaskState.projects
                          .where((p) => p.id == entry.projectId)
                          .firstOrNull
                    : null;

                final resolvedEntry = ResolvedTimeEntry(
                  entry: entry,
                  task: task,
                  project: project,
                );

                return TimeEntryCard(
                  resolvedEntry: resolvedEntry,
                  isSelected: false,
                  onTap: () {},
                );
              }).toList(),
            ),
          SizedBox(height: theme.spacings.s16),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              title: 'View All History',
              type: ButtonType.ghost,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vector_svg/extension/vector_graphic_extention.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/feature/settings/settings_screen.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/feature/home/presentation/home_page.dart';
import 'package:worklog_studio/feature/projects/presentation/projects_page.dart';
import 'package:worklog_studio/feature/tasks/presentation/tasks_page.dart';
import 'package:worklog_studio/feature/history/presentation/history_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/feature/time_tracker/bloc/time_tracker_bloc.dart';
import 'package:worklog_studio/feature/time_tracker/presentation/components/active_timer_text.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/feature/home/data/mock_data.dart' as mock;

import 'package:worklog_studio/core/services/desktop/desktop_service.dart';
import 'dart:async';

enum AppRoute { dashboard, history, projects, tasks, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppRoute _currentRoute = AppRoute.dashboard;
  StreamSubscription<String>? _navSub;

  @override
  void initState() {
    super.initState();
    _navSub = DesktopService().navigationStream.listen((route) {
      if (route == 'history') {
        _onRouteSelected(AppRoute.history);
      }
    });
  }

  @override
  void dispose() {
    _navSub?.cancel();
    super.dispose();
  }

  void _onRouteSelected(AppRoute route) {
    setState(() {
      _currentRoute = route;
    });
  }

  Widget _buildActiveScreen() {
    return IndexedStack(
      index: _currentRoute.index,
      children: const [
        HomePage(title: 'Dashboard'),
        HistoryScreen(),
        ProjectsScreen(),
        TasksScreen(),
        SettingsScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Scaffold(
      backgroundColor: palette.background.canvas,
      body: Row(
        children: [
          SidebarNavigation(
            currentRoute: _currentRoute,
            onRouteSelected: _onRouteSelected,
          ),
          Expanded(
            child: Column(
              children: [
                const TopAppBar(),
                Expanded(child: _buildActiveScreen()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacings.s32,
        vertical: theme.spacings.s16,
      ),
      decoration: BoxDecoration(color: palette.background.canvas),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: GlobalTimeTrackerPanel()),
          SizedBox(width: theme.spacings.s32),
          IconButton(
            icon: Icon(Icons.notifications_none, color: palette.text.secondary),
            onPressed: () {},
          ),
          SizedBox(width: theme.spacings.s16),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mock.mockUser.name,
                    style: theme.commonTextStyles.bodyBold,
                  ),
                  Text(
                    mock.mockUser.role,
                    style: theme.commonTextStyles.caption.copyWith(
                      color: palette.text.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: theme.spacings.s12),
              CircleAvatar(
                backgroundColor: palette.border.primary,
                child: Icon(Icons.person, color: palette.text.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlobalTimeTrackerPanel extends StatefulWidget {
  const GlobalTimeTrackerPanel({super.key});

  @override
  State<GlobalTimeTrackerPanel> createState() => _GlobalTimeTrackerPanelState();
}

class _GlobalTimeTrackerPanelState extends State<GlobalTimeTrackerPanel> {
  final TextEditingController _commentController = TextEditingController();
  final PopoverController _commentPopoverController = PopoverController();

  @override
  void dispose() {
    _commentController.dispose();
    _commentPopoverController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.read<ProjectTaskState>();

    return BlocListener<TimeTrackerBloc, TimeTrackerBlocState>(
      listenWhen: (previous, current) =>
          previous.activeEntryOrNull != current.activeEntryOrNull,
      listener: (context, state) {
        final activeEntry = state.activeEntryOrNull;
        if (activeEntry != null) {
          projectTaskState.updateDraft(
            projectId: activeEntry.projectId,
            taskId: activeEntry.taskId,
            comment: activeEntry.comment ?? '',
          );
          if (_commentController.text != (activeEntry.comment ?? '')) {
            _commentController.text = activeEntry.comment ?? '';
          }
        }
      },
      child: BlocBuilder<TimeTrackerBloc, TimeTrackerBlocState>(
        buildWhen: (previous, current) =>
            previous.isRunning != current.isRunning ||
            previous.activeEntryOrNull != current.activeEntryOrNull,
        builder: (context, state) {
          final isRunning = state.isRunning;
          final draftProjectId = context.select<ProjectTaskState, String?>(
            (s) => s.draftProjectId,
          );
          final draftTaskId = context.select<ProjectTaskState, String?>(
            (s) => s.draftTaskId,
          );

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacings.s24,
              vertical: theme.spacings.s16,
            ),
            decoration: BoxDecoration(
              color: palette.background.surface,
              borderRadius: theme.radiuses.lg.circular,
              border: Border.all(
                color: isRunning
                    ? palette.accent.primary
                    : palette.border.primary,
                width: isRunning ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildProjectSelector(
                    context,
                    isRunning,
                    draftProjectId,
                  ),
                ),
                SizedBox(width: theme.spacings.s16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: 1,
                    height: 32,
                    color: palette.border.primary,
                  ),
                ),
                SizedBox(width: theme.spacings.s16),
                Expanded(
                  flex: 2,
                  child: _buildTaskSelector(context, isRunning, draftTaskId),
                ),
                SizedBox(width: theme.spacings.s16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    width: 1,
                    height: 32,
                    color: palette.border.primary,
                  ),
                ),
                SizedBox(width: theme.spacings.s16),
                Expanded(
                  flex: 4,
                  child: _buildCommentInput(context, isRunning, draftTaskId),
                ),
                SizedBox(width: theme.spacings.s24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(' ', style: theme.commonTextStyles.caption3Bold),
                    SizedBox(height: theme.spacings.s8),
                    ActiveTimerText(
                      style: theme.commonTextStyles.h1.copyWith(
                        color: isRunning
                            ? palette.text.primary
                            : palette.text.muted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: theme.spacings.s24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(' ', style: theme.commonTextStyles.caption3Bold),
                    SizedBox(height: theme.spacings.s8),
                    isRunning
                        ? PrimaryButton(
                            size: ButtonSize.sm,
                            type: ButtonType.danger,
                            title: 'STOP',
                            leftIcon:
                                WorklogStudioAssets.vectors.squareFilled64Svg,
                            backgroundColor: palette.accent.danger,
                            onTap: () {
                              context.read<TimeTrackerBloc>().add(
                                TimeTrackerStopped(),
                              );
                              projectTaskState.clearDraft();
                              _commentController.clear();
                            },
                          )
                        : PrimaryButton(
                            size: ButtonSize.sm,

                            title: 'START',
                            leftIcon:
                                WorklogStudioAssets.vectors.playFilled64Svg,
                            onTap: () {
                              context.read<TimeTrackerBloc>().add(
                                TimeTrackerStarted(
                                  projectId: draftProjectId,
                                  taskId: draftTaskId,
                                  comment: _commentController.text.isNotEmpty
                                      ? _commentController.text
                                      : null,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectSelector(
    BuildContext context,
    bool isRunning,
    String? selectedId,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.read<ProjectTaskState>();
    final projects = context.select<ProjectTaskState, List<Project>>(
      (s) => s.projects,
    );

    final options = projects
        .map((p) => SelectOption(value: p.id, label: p.name))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PROJECT',
          style: theme.commonTextStyles.caption.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        Select<String>(
          value: selectedId,
          placeholder: 'Select Project',
          searchable: true,
          options: options,
          actionBuilder: (context, query, close) {
            final exactMatchExists = projects.any(
              (p) => p.name.toLowerCase() == query.toLowerCase(),
            );
            if (exactMatchExists && query.isNotEmpty)
              return const SizedBox.shrink();

            return SelectCreateAction(
              label: query.isEmpty
                  ? 'Create new project'
                  : 'Create project "$query"',
              onTap: () async {
                final newProject = await projectTaskState.createProject(
                  query.isEmpty ? 'New project' : query,
                  '',
                );
                projectTaskState.updateDraft(projectId: newProject.id);
                if (isRunning) {
                  context.read<TimeTrackerBloc>().add(
                    TimeTrackerActiveEntryUpdated(
                      projectId: newProject.id,
                      taskId: projectTaskState.draftTaskId,
                      comment: _commentController.text,
                    ),
                  );
                }
                close();
              },
            );
          },
          onChanged: (value) async {
            projectTaskState.updateDraft(projectId: value);
            if (isRunning) {
              context.read<TimeTrackerBloc>().add(
                TimeTrackerActiveEntryUpdated(
                  projectId: value,
                  taskId: projectTaskState.draftTaskId,
                  comment: _commentController.text,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTaskSelector(
    BuildContext context,
    bool isRunning,
    String? selectedId,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.read<ProjectTaskState>();
    final tasks = context.select<ProjectTaskState, List<Task>>((s) => s.tasks);
    final draftProjectId = context.select<ProjectTaskState, String?>(
      (s) => s.draftProjectId,
    );

    final filteredTasks = draftProjectId != null
        ? tasks.where((t) => t.projectId == draftProjectId).toList()
        : tasks;

    final options = filteredTasks
        .map((t) => SelectOption(value: t.id, label: t.title))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TASK',
          style: theme.commonTextStyles.caption.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        Select<String>(
          value: selectedId,
          placeholder: 'Select Task',
          searchable: true,
          options: options,
          actionBuilder: (context, query, close) {
            final exactMatchExists = tasks.any(
              (t) =>
                  t.title.toLowerCase() == query.toLowerCase() &&
                  t.projectId == draftProjectId,
            );
            if (exactMatchExists && query.isNotEmpty)
              return const SizedBox.shrink();

            return SelectCreateAction(
              label: query.isEmpty ? 'Create new task' : 'Create task "$query"',
              onTap: () async {
                if (draftProjectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a project first'),
                    ),
                  );
                  return;
                }
                final newTask = await projectTaskState.createTask(
                  draftProjectId,
                  query.isEmpty ? 'New task' : query,
                  '',
                );
                projectTaskState.updateDraft(taskId: newTask.id);
                if (isRunning) {
                  context.read<TimeTrackerBloc>().add(
                    TimeTrackerActiveEntryUpdated(
                      projectId: draftProjectId,
                      taskId: newTask.id,
                      comment: _commentController.text,
                    ),
                  );
                }
                close();
              },
            );
          },
          onChanged: (value) async {
            if (value == null) {
              projectTaskState.updateDraft(clearTaskId: true);
            } else {
              projectTaskState.updateDraft(taskId: value);
            }
            if (isRunning) {
              context.read<TimeTrackerBloc>().add(
                TimeTrackerActiveEntryUpdated(
                  projectId: draftProjectId,
                  taskId: value,
                  comment: _commentController.text,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    bool isRunning,
    String? selectedId,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.read<ProjectTaskState>();
    final draftProjectId = context.select<ProjectTaskState, String?>(
      (s) => s.draftProjectId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COMMENT',
          style: theme.commonTextStyles.caption.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        PopoverPrimitive(
          controller: _commentPopoverController,
          matchTriggerWidth: true,
          trigger: GestureDetector(
            onTap: () => _commentPopoverController.toggle(),
            child: Container(
              height: theme.spacings.s48,
              padding: EdgeInsets.symmetric(horizontal: theme.spacings.s12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: theme.radiuses.md.circular,
              ),
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _commentController,
                builder: (context, value, child) {
                  return Text(
                    value.text.isEmpty ? 'Add Comment' : value.text,
                    style: theme.commonTextStyles.body.copyWith(
                      color: value.text.isEmpty
                          ? palette.text.muted
                          : palette.text.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ),
          contentBuilder: (context) {
            return _ResizableCommentPopover(
              controller: _commentController,
              onClose: () => _commentPopoverController.hide(),
              onSubmitted: (value) {
                if (isRunning) {
                  context.read<TimeTrackerBloc>().add(
                    TimeTrackerActiveEntryUpdated(
                      projectId: draftProjectId,
                      taskId: projectTaskState.draftTaskId,
                      comment: value,
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _ResizableCommentPopover extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String> onSubmitted;

  const _ResizableCommentPopover({
    required this.controller,
    required this.onClose,
    required this.onSubmitted,
  });

  @override
  State<_ResizableCommentPopover> createState() =>
      _ResizableCommentPopoverState();
}

class _ResizableCommentPopoverState extends State<_ResizableCommentPopover> {
  double _height = 160.0;
  final double _minHeight = 120.0;
  final double _maxHeight = 400.0;
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return PopoverSurface(
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(theme.spacings.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: (focus) =>
                          setState(() => _hasFocus = focus),
                      child: AnimatedContainer(
                        duration: kThemeAnimationDuration,
                        decoration: BoxDecoration(
                          color: palette.background.surface,
                          borderRadius: theme.radiuses.sm.circular,
                          border: Border.all(
                            color: _hasFocus
                                ? palette.border.focus
                                : palette.border.primary,
                          ),
                        ),
                        padding: EdgeInsets.all(theme.spacings.s12),
                        child: TextField(
                          controller: widget.controller,
                          autofocus: true,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
                          cursorColor: palette.text.primary,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Add Comment',
                            hintStyle: theme.commonTextStyles.body.copyWith(
                              color: palette.text.muted,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.commonTextStyles.body.copyWith(
                            color: palette.text.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: theme.spacings.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryButton(
                        type: ButtonType.ghost,
                        title: 'Cancel',
                        onTap: widget.onClose,
                      ),
                      SizedBox(width: theme.spacings.s8),
                      PrimaryButton(
                        type: ButtonType.primary,
                        title: 'Save',
                        onTap: () {
                          widget.onSubmitted(widget.controller.text);
                          widget.onClose();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Resize handle
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _height += details.delta.dy;
                    if (_height < _minHeight) _height = _minHeight;
                    if (_height > _maxHeight) _height = _maxHeight;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: Colors.transparent,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: palette.text.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarNavigation extends StatelessWidget {
  final AppRoute currentRoute;
  final ValueChanged<AppRoute> onRouteSelected;

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Container(
      width: 240,
      color: palette.background.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(theme.spacings.s24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.accent.primary,
                    borderRadius: theme.radiuses.sm.circular,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.work,
                      color: palette.background.surface,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: theme.spacings.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Worklog Studio',
                      style: theme.commonTextStyles.bodyBold,
                    ),
                    Text(
                      'PROFESSIONAL TRACKING',
                      style: theme.commonTextStyles.caption3Bold.copyWith(
                        color: palette.text.muted,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: theme.spacings.s16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacings.s12),
              child: Column(
                children: [
                  SidebarItem(
                    label: 'Dashboard',
                    isActive: currentRoute == AppRoute.dashboard,
                    onTap: () => onRouteSelected(AppRoute.dashboard),
                  ),
                  SidebarItem(
                    label: 'History',
                    isActive: currentRoute == AppRoute.history,
                    onTap: () => onRouteSelected(AppRoute.history),
                  ),
                  SidebarItem(
                    label: 'Projects',
                    isActive: currentRoute == AppRoute.projects,
                    onTap: () => onRouteSelected(AppRoute.projects),
                  ),
                  SidebarItem(
                    label: 'Tasks',
                    isActive: currentRoute == AppRoute.tasks,
                    onTap: () => onRouteSelected(AppRoute.tasks),
                  ),
                  SidebarItem(
                    label: 'Settings',
                    isActive: currentRoute == AppRoute.settings,
                    onTap: () => onRouteSelected(AppRoute.settings),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(theme.spacings.s12),
            child: Column(
              children: [
                SidebarItem(label: 'Help', onTap: () {}),
                SidebarItem(label: 'Logout', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

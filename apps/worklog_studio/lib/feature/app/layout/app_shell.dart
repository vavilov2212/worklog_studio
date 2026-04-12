import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio/feature/settings/settings_screen.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/feature/home/presentation/home_page.dart';
import 'package:worklog_studio/feature/projects/presentation/projects_page.dart';
import 'package:worklog_studio/feature/tasks/presentation/tasks_page.dart';
import 'package:worklog_studio/feature/history/presentation/history_page.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/feature/home/data/mock_data.dart' as mock;

enum AppRoute { dashboard, history, projects, tasks, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppRoute _currentRoute = AppRoute.dashboard;

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
  String? _selectedProjectId;
  String? _selectedTaskId;
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
    final state = context.watch<TimeTrackerState>();

    final isRunning = state.isRunning;
    final activeEntry = state.activeEntry;

    // Sync local state with active entry if running
    if (isRunning && activeEntry != null) {
      if (_selectedProjectId != activeEntry.projectId) {
        _selectedProjectId = activeEntry.projectId;
      }
      if (_selectedTaskId != activeEntry.taskId) {
        _selectedTaskId = activeEntry.taskId;
      }
      if (_commentController.text != (activeEntry.comment ?? '')) {
        _commentController.text = activeEntry.comment ?? '';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacings.s24,
        vertical: theme.spacings.s16,
      ),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: theme.radiuses.lg.circular,
        border: Border.all(
          color: isRunning ? palette.accent.primary : palette.border.primary,
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
            child: _buildProjectSelector(context, isRunning, state),
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
            child: _buildTaskSelector(context, isRunning, state),
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
            child: _buildCommentInput(context, isRunning, state),
          ),
          SizedBox(width: theme.spacings.s24),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(' ', style: theme.commonTextStyles.caption3Bold),
              SizedBox(height: theme.spacings.s8),
              Text(
                _formatDuration(state.elapsed),
                style: theme.commonTextStyles.h1.copyWith(
                  color: isRunning
                      ? palette.accent.primary
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
                      title: 'STOP',
                      leftIcon: WorklogStudioAssets.vectors.square24Svg,
                      backgroundColor: palette.accent.danger,
                      onTap: () {
                        state.stop();
                        setState(() {
                          _selectedProjectId = null;
                          _selectedTaskId = null;
                          _commentController.clear();
                        });
                      },
                    )
                  : PrimaryButton(
                      title: 'START',
                      leftIcon: WorklogStudioAssets.vectors.playerPlay24Svg,
                      onTap: () {
                        state.start(
                          projectId: _selectedProjectId,
                          taskId: _selectedTaskId,
                          comment: _commentController.text.isNotEmpty
                              ? _commentController.text
                              : null,
                        );
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelector(
    BuildContext context,
    bool isRunning,
    TimeTrackerState state,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.watch<ProjectTaskState>();

    final options = [
      SelectOption(value: 'create_new', label: '+ Create Project'),
      ...projectTaskState.projects.map(
        (p) => SelectOption(value: p.id, label: p.name),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PROJECT',
          style: theme.commonTextStyles.caption3Bold.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        Select<String>(
          value: _selectedProjectId,
          placeholder: 'Select Project',
          searchable: true,
          options: options,
          onChanged: (value) async {
            if (value == 'create_new') {
              // Trigger creation flow
              final newProject = await _showCreateProjectDialog(
                context,
                projectTaskState,
              );
              if (newProject != null) {
                setState(() {
                  _selectedProjectId = newProject.id;
                });
                if (isRunning) {
                  state.updateActive(
                    projectId: newProject.id,
                    taskId: _selectedTaskId,
                    comment: _commentController.text,
                  );
                }
              }
              return;
            }

            setState(() {
              _selectedProjectId = value;
            });
            if (isRunning) {
              state.updateActive(
                projectId: value,
                taskId: _selectedTaskId,
                comment: _commentController.text,
              );
            }
          },
          triggerBuilder: (context, selectedOption, isOpen) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacings.s12,
                vertical: theme.spacings.s12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isOpen ? palette.border.focus : palette.border.primary,
                ),
                borderRadius: theme.radiuses.md.circular,
                color: palette.background.surface,
              ),
              child: Row(
                children: [
                  if (selectedOption == null ||
                      selectedOption.value == 'create_new')
                    Icon(
                      Icons.add_circle_outline,
                      size: 16,
                      color: palette.text.muted,
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: palette.accent.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  SizedBox(width: theme.spacings.s8),
                  Expanded(
                    child: Text(
                      selectedOption?.label ?? 'Select Project',
                      style: theme.commonTextStyles.body.copyWith(
                        color:
                            selectedOption != null &&
                                selectedOption.value != 'create_new'
                            ? (isRunning
                                  ? palette.accent.primary
                                  : palette.text.primary)
                            : palette.text.muted,
                        fontWeight:
                            selectedOption != null &&
                                selectedOption.value != 'create_new'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.unfold_more, size: 18, color: palette.text.muted),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskSelector(
    BuildContext context,
    bool isRunning,
    TimeTrackerState state,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.watch<ProjectTaskState>();

    final filteredTasks = _selectedProjectId != null
        ? projectTaskState.tasks
              .where((t) => t.projectId == _selectedProjectId)
              .toList()
        : projectTaskState.tasks;

    final options = [
      SelectOption(value: 'create_new', label: '+ Create Task'),
      ...filteredTasks.map((t) => SelectOption(value: t.id, label: t.title)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TASK',
          style: theme.commonTextStyles.caption3Bold.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        Select<String>(
          value: _selectedTaskId,
          placeholder: 'Select Task',
          searchable: true,
          options: options,
          onChanged: (value) async {
            if (value == 'create_new') {
              if (_selectedProjectId == null) {
                // Cannot create task without project
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a project first'),
                  ),
                );
                return;
              }
              // Trigger creation flow
              final newTask = await _showCreateTaskDialog(
                context,
                projectTaskState,
                _selectedProjectId!,
              );
              if (newTask != null) {
                setState(() {
                  _selectedTaskId = newTask.id;
                });
                if (isRunning) {
                  state.updateActive(
                    projectId: _selectedProjectId,
                    taskId: newTask.id,
                    comment: _commentController.text,
                  );
                }
              }
              return;
            }

            setState(() {
              _selectedTaskId = value;
            });
            if (isRunning) {
              state.updateActive(
                projectId: _selectedProjectId,
                taskId: value,
                comment: _commentController.text,
              );
            }
          },
          triggerBuilder: (context, selectedOption, isOpen) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacings.s12,
                vertical: theme.spacings.s12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isOpen ? palette.border.focus : palette.border.primary,
                ),
                borderRadius: theme.radiuses.md.circular,
                color: palette.background.surface,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedOption?.label ?? 'Select Task',
                      style: theme.commonTextStyles.body.copyWith(
                        color:
                            selectedOption != null &&
                                selectedOption.value != 'create_new'
                            ? palette.text.primary
                            : palette.text.muted,
                        fontWeight:
                            selectedOption != null &&
                                selectedOption.value != 'create_new'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.unfold_more, size: 18, color: palette.text.muted),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<Project?> _showCreateProjectDialog(
    BuildContext context,
    ProjectTaskState state,
  ) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    return showDialog<Project>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final project = await state.createProject(
                  nameController.text,
                  descController.text,
                );
                Navigator.pop(context, project);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<Task?> _showCreateTaskDialog(
    BuildContext context,
    ProjectTaskState state,
    String projectId,
  ) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    return showDialog<Task>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final task = await state.createTask(
                  projectId,
                  titleController.text,
                  descController.text,
                );
                Navigator.pop(context, task);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    bool isRunning,
    TimeTrackerState state,
  ) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COMMENT',
          style: theme.commonTextStyles.caption3Bold.copyWith(
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
                  state.updateActive(
                    projectId: _selectedProjectId,
                    taskId: _selectedTaskId,
                    comment: value,
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

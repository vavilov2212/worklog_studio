import 'package:flutter/material.dart' hide DrawerControllerState;
import 'package:provider/provider.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'components/tasks_card.dart';
import 'components/tasks_drawer.dart';
import 'package:worklog_studio/feature/common/presentation/drawer_controller_state.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  DrawerControllerState<Task> _drawerState = DrawerControllerState.closed();

  void _handleTaskSelected(Task task) {
    setState(() {
      if (_drawerState.state == DrawerState.edit &&
          _drawerState.entity?.id == task.id) {
        _drawerState = DrawerControllerState.closed();
      } else {
        _drawerState = DrawerControllerState.edit(task);
      }
    });
  }

  void _handleCreateTask() {
    setState(() {
      _drawerState = DrawerControllerState.create();
    });
  }

  void _closePanel() {
    setState(() {
      _drawerState = DrawerControllerState.closed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolver = context.watch<EntityResolver>();
    final resolvedTasks = resolver.getResolvedTasks();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TaskList(
            tasks: resolvedTasks,
            selectedTask: _drawerState.entity,
            onTaskSelected: _handleTaskSelected,
            onCreateTask: _handleCreateTask,
          ),
        ),
        TaskDrawer(
          task: _drawerState.entity,
          isOpen: _drawerState.isOpen,
          onClose: _closePanel,
        ),
      ],
    );
  }
}

class TaskList extends StatelessWidget {
  final List<ResolvedTask> tasks;
  final Task? selectedTask;
  final ValueChanged<Task> onTaskSelected;
  final VoidCallback onCreateTask;

  const TaskList({
    super.key,
    required this.tasks,
    required this.selectedTask,
    required this.onTaskSelected,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacings.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Tasks',
                    style: theme.commonTextStyles.displayLarge,
                  ),
                  SizedBox(height: theme.spacings.s4),
                  Text(
                    '${tasks.where((t) => t.status == TaskStatus.open).length} active tasks',
                    style: theme.commonTextStyles.body.copyWith(
                      color: palette.text.secondary,
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                title: 'New Task',
                leftIcon: WorklogStudioAssets.vectors.plus24Svg,
                size: ButtonSize.md,
                onTap: onCreateTask,
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Column(
            spacing: theme.spacings.s12,
            children: tasks.map((task) {
              final isSelected = selectedTask?.id == task.id;
              return TaskCard(
                task: task,
                isSelected: isSelected,
                onTap: () => onTaskSelected(task.task),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

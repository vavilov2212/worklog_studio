import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio/feature/tasks/presentation/components/tasks_card.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'components/tasks_drawer.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Task? selectedTask;

  void _handleTaskSelected(Task task) {
    setState(() {
      if (selectedTask?.id == task.id) {
        selectedTask = null; // Toggle off
      } else {
        selectedTask = task;
      }
    });
  }

  void _handleCreateTask() {
    setState(() {
      selectedTask = Task(
        id: '',
        projectId: '',
        title: '',
        description: '',
        status: TaskStatus.open,
        createdAt: DateTime.now(),
      );
    });
  }

  void _closePanel() {
    setState(() {
      selectedTask = null;
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
            selectedTask: selectedTask,
            onTaskSelected: _handleTaskSelected,
            onCreateTask: _handleCreateTask,
          ),
        ),
        TaskDrawer(
          task: selectedTask,
          isOpen: selectedTask != null,
          onClose: _closePanel,
          isNew: selectedTask != null && selectedTask!.id.isEmpty,
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

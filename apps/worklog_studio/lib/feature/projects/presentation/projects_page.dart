import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'components/project_card.dart';
import 'components/project_drawer.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  Project? selectedProject;

  void _handleProjectSelected(Project project) {
    setState(() {
      if (selectedProject?.id == project.id) {
        selectedProject = null; // Toggle off if clicking the same project
      } else {
        selectedProject = project;
      }
    });
  }

  void _handleCreateProject() {
    setState(() {
      selectedProject = Project(
        id: 'new',
        name: '',
        description: '',
        createdAt: DateTime.now(),
        status: ProjectStatus.open,
      );
    });
  }

  void _closePanel() {
    setState(() {
      selectedProject = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectTaskState = context.watch<ProjectTaskState>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ProjectList(
            projects: projectTaskState.projects,
            selectedProject: selectedProject,
            onProjectSelected: _handleProjectSelected,
            onCreateProject: _handleCreateProject,
          ),
        ),
        ProjectDrawer(
          project: selectedProject,
          isOpen: selectedProject != null,
          onClose: _closePanel,
        ),
      ],
    );
  }
}

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  final Project? selectedProject;
  final ValueChanged<Project> onProjectSelected;
  final VoidCallback onCreateProject;

  const ProjectList({
    super.key,
    required this.projects,
    required this.selectedProject,
    required this.onProjectSelected,
    required this.onCreateProject,
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
                    'Active Projects',
                    style: theme.commonTextStyles.displayLarge,
                  ),
                  SizedBox(height: theme.spacings.s4),
                  Text(
                    '${projects.length} currently in progress',
                    style: theme.commonTextStyles.body.copyWith(
                      color: palette.text.secondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accent.primary,
                  borderRadius: theme.radiuses.sm.circular,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: palette.background.surface),
                  onPressed: onCreateProject,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacings.s32),
          Column(
            spacing: theme.spacings.s16,
            children: projects.map((project) {
              final isSelected = selectedProject?.id == project.id;
              return ProjectCard(
                project: project,
                isSelected: isSelected,
                onTap: () => onProjectSelected(project),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/resolved_project.dart';
import 'package:worklog_studio/feature/common/presentation/interactive_card.dart';
import 'package:worklog_studio/feature/common/presentation/components/card_content.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class ProjectCard extends StatelessWidget {
  final ResolvedProject project;
  final bool isSelected;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
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
        title: Text(project.name, style: theme.commonTextStyles.h3),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              project.project.clientName,
              style: theme.commonTextStyles.caption.copyWith(
                color: palette.text.secondary,
              ),
            ),
            SizedBox(height: theme.spacings.s8),
            LinearProgressIndicator(
              value: project.project.budgetUtilization,
              backgroundColor: palette.border.primary,
              color: palette.accent.primary,
              minHeight: 4,
              borderRadius: theme.radiuses.pill.circular,
            ),
          ],
        ),
        trailing: Text(
          getStatusText(project.status),
          style: theme.commonTextStyles.caption3Bold.copyWith(
            color: palette.text.muted,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

String getStatusText(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.open:
      return 'OPEN';
    case ProjectStatus.done:
      return 'DONE';
    case ProjectStatus.archived:
      return 'ARCHIVED';
  }
}

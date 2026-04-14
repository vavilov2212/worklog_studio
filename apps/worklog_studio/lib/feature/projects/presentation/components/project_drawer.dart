import 'package:flutter/material.dart' hide DrawerHeader;
import 'package:provider/provider.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/feature/common/presentation/components/inline_field_controller.dart';
import 'package:worklog_studio/feature/common/presentation/resizable_drawer.dart';
import 'package:worklog_studio/feature/common/presentation/components/drawer_content.dart';
import 'package:worklog_studio/feature/common/presentation/components/drawer_header.dart';
import 'package:worklog_studio/feature/common/presentation/components/inline_field.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class ProjectDrawer extends StatefulWidget {
  final Project? project;
  final bool isOpen;
  final VoidCallback onClose;
  final DrawerMode mode;
  final bool isNew;

  const ProjectDrawer({
    super.key,
    required this.project,
    required this.isOpen,
    required this.onClose,
    this.mode = DrawerMode.push,
    required this.isNew,
  });

  @override
  State<ProjectDrawer> createState() => _ProjectDrawerState();
}

class _ProjectDrawerState extends State<ProjectDrawer> {
  bool _isConfirmingDelete = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final InlineFieldController _nameFieldController = InlineFieldController();
  final InlineFieldController _descriptionFieldController =
      InlineFieldController();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
  }

  @override
  void didUpdateWidget(ProjectDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpen && oldWidget.isOpen) {
      _isConfirmingDelete = false;
    }
    if (widget.project != oldWidget.project) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFieldController.dispose();
    _descriptionFieldController.dispose();
    super.dispose();
  }

  bool get _isNew => widget.isNew;

  void _handleSave() async {
    final state = context.read<ProjectTaskState>();
    if (_isNew) {
      if (_nameController.text.isNotEmpty) {
        await state.createProject(
          _nameController.text,
          _descriptionController.text,
        );
        widget.onClose();
      }
    } else {
      if (widget.project != null && _nameController.text.isNotEmpty) {
        final updatedProject = widget.project!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
        );
        await state.updateProject(updatedProject);
        widget.onClose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.watch<ProjectTaskState>();
    final projectTasks = widget.project != null && !_isNew
        ? projectTaskState.tasks
              .where((t) => t.projectId == widget.project!.id)
              .toList()
        : [];

    return ResizableDrawer(
      isOpen: widget.isOpen,
      onClose: widget.onClose,
      mode: widget.mode,
      header: DrawerHeader(
        onClose: widget.onClose,
        onDelete: _isNew
            ? null
            : () {
                setState(() {
                  _isConfirmingDelete = true;
                });
              },
      ),
      body: widget.project == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                if (!_isNew)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: _isConfirmingDelete
                        ? Padding(
                            key: const ValueKey('delete_confirmation'),
                            padding: EdgeInsets.fromLTRB(
                              theme.spacings.s32,
                              theme.spacings.s16,
                              theme.spacings.s32,
                              0,
                            ),
                            child: InfoBar(
                              variant: InfoBarVariant.danger,
                              title: const Text('Delete this project?'),
                              description: const Text(
                                'This action cannot be undone',
                              ),
                              actions: Wrap(
                                spacing: theme.spacings.s8,
                                runSpacing: theme.spacings.s8,
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  PrimaryButton(
                                    onTap: () {
                                      if (widget.project != null) {
                                        context
                                            .read<ProjectTaskState>()
                                            .deleteProject(widget.project!.id);
                                        widget.onClose();
                                      }
                                    },
                                    title: 'Delete',
                                    type: ButtonType.danger,
                                    size: ButtonSize.sm,
                                  ),
                                  PrimaryButton(
                                    onTap: () {
                                      setState(() {
                                        _isConfirmingDelete = false;
                                      });
                                    },
                                    title: 'Cancel',
                                    type: ButtonType.ghost,
                                    size: ButtonSize.sm,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('no_confirmation'),
                          ),
                  ),
                Expanded(
                  child: DrawerContent(
                    meta: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isNew) ...[
                          Row(
                            children: [
                              StatusBadge(
                                status: BadgeStatus.ready,
                                label: getStatusText(widget.project!.status),
                              ),
                              SizedBox(width: theme.spacings.s12),
                              Text(
                                'Created ${_formatDate(widget.project!.createdAt)}',
                                style: theme.commonTextStyles.body2.copyWith(
                                  color: palette.text.secondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: theme.spacings.s24),
                        ],
                        // Name Input
                        InlineField(
                          label: 'PROJECT NAME',
                          value: _nameController.text,
                          placeholder: 'Enter project name...',
                          controller: _nameFieldController,
                          textController: _nameController,
                          editWidget: PrimaryInput(
                            label: null,
                            hintText: 'Enter project name...',
                            controller: _nameController,
                            autofocus: true,
                          ),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacings.s32,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          InlineField(
                            label: 'DESCRIPTION',
                            value: _descriptionController.text,
                            placeholder: 'Add a description...',
                            controller: _descriptionFieldController,
                            textController: _descriptionController,
                            isTextArea: true,
                            editWidget: TextArea(
                              label: null,
                              hintText: 'Add a description...',
                              controller: _descriptionController,
                              autofocus: true,
                            ),
                          ),
                          SizedBox(height: theme.spacings.s32),
                          if (!_isNew) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricCard(
                                    title: 'TOTAL TIME',
                                    value:
                                        '${widget.project!.totalHours.toInt()}:15',
                                    unit: 'h',
                                    subtitle: '+12% from last week',
                                    subtitleColor: palette.accent.success,
                                    icon: Icons.trending_up,
                                  ),
                                ),
                                SizedBox(width: theme.spacings.s16),
                                Expanded(
                                  child: _MetricCard(
                                    title: 'BILLABLE AMOUNT',
                                    value:
                                        '\$${_formatCurrency(widget.project!.billableAmount)}',
                                    subtitle:
                                        '\$${widget.project!.averageRate.toInt()}/hr average rate',
                                    subtitleColor: palette.text.secondary,
                                    icon: Icons.payments_outlined,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: theme.spacings.s16),
                            _MetricCard(
                              title: 'BUDGET LEFT',
                              value:
                                  '\$${_formatCurrency(widget.project!.budgetLeft)}',
                              subtitle: 'Approaching limit',
                              subtitleColor: palette.accent.danger,
                              icon: Icons.warning_amber_rounded,
                              fullWidth: true,
                            ),
                            SizedBox(height: theme.spacings.s40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Associated Tasks',
                                  style: theme.commonTextStyles.h3,
                                ),
                                Text(
                                  'VIEW ALL',
                                  style: theme.commonTextStyles.caption3Bold
                                      .copyWith(color: palette.accent.primary),
                                ),
                              ],
                            ),
                            SizedBox(height: theme.spacings.s24),
                            if (projectTasks.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: theme.spacings.s24,
                                ),
                                child: Center(
                                  child: Text(
                                    'No tasks associated with this project yet.',
                                    style: theme.commonTextStyles.body.copyWith(
                                      color: palette.text.muted,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                spacing: theme.spacings.s16,
                                children: projectTasks.map((task) {
                                  return Container(
                                    padding: EdgeInsets.all(theme.spacings.s16),
                                    decoration: BoxDecoration(
                                      color: palette.background.surfaceMuted,
                                      borderRadius: theme.radiuses.md.circular,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            theme.spacings.s8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: palette.background.surface,
                                            borderRadius:
                                                theme.radiuses.sm.circular,
                                          ),
                                          child: Icon(
                                            Icons.task_alt, // Default icon
                                            color: palette.accent.primary,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: theme.spacings.s16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: theme
                                                    .commonTextStyles
                                                    .bodyBold,
                                              ),
                                              SizedBox(
                                                height: theme.spacings.s4,
                                              ),
                                              Text(
                                                getStatusText(
                                                  widget.project!.status,
                                                ),
                                                style: theme
                                                    .commonTextStyles
                                                    .caption
                                                    .copyWith(
                                                      color: palette
                                                          .text
                                                          .secondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '0:00h', // Default time
                                          style:
                                              theme.commonTextStyles.bodyBold,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                          SizedBox(
                            height: theme.spacings.s24,
                          ), // Bottom padding for scroll
                        ],
                      ),
                    ),
                    footer: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            title: _isNew ? 'Create Project' : 'Save Changes',
                            size: ButtonSize.lg,
                            onTap: _handleSave,
                          ),
                        ),
                        if (!_isNew) ...[
                          SizedBox(height: theme.spacings.s16),
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              title: 'Add Task',
                              type: ButtonType.secondary,
                              leftIcon: WorklogStudioAssets.vectors.plus24Svg,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String subtitle;
  final Color subtitleColor;
  final IconData icon;
  final bool fullWidth;

  const _MetricCard({
    required this.title,
    required this.value,
    this.unit,
    required this.subtitle,
    required this.subtitleColor,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(theme.spacings.s24),
      decoration: BoxDecoration(
        color: palette.background.surfaceMuted,
        borderRadius: theme.radiuses.lg.circular,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.commonTextStyles.caption3Bold.copyWith(
              color: palette.text.secondary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: theme.spacings.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: theme.commonTextStyles.h1),
              if (unit != null) ...[
                SizedBox(width: theme.spacings.s4),
                Text(
                  unit!,
                  style: theme.commonTextStyles.h3.copyWith(
                    color: palette.text.secondary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: theme.spacings.s16),
          Row(
            children: [
              Icon(icon, color: subtitleColor, size: 14),
              SizedBox(width: theme.spacings.s8),
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.commonTextStyles.caption.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

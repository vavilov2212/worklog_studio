import 'package:flutter/material.dart' hide DrawerHeader;
import 'package:provider/provider.dart';
import 'package:worklog_studio/feature/common/presentation/components/drawer_content.dart';
import 'package:worklog_studio/feature/common/presentation/components/drawer_header.dart';
import 'package:worklog_studio/feature/common/presentation/resizable_drawer.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';
import 'package:worklog_studio/domain/time_entry.dart';

class TimeEntryDrawer extends StatefulWidget {
  final ResolvedTimeEntry? resolvedEntry;
  final bool isOpen;
  final VoidCallback onClose;
  final DrawerMode mode;
  final bool isNew;

  const TimeEntryDrawer({
    super.key,
    required this.resolvedEntry,
    required this.isOpen,
    required this.onClose,
    this.mode = DrawerMode.push,
    required this.isNew,
  });

  @override
  State<TimeEntryDrawer> createState() => _TimeEntryDrawerState();
}

class _TimeEntryDrawerState extends State<TimeEntryDrawer> {
  bool _isConfirmingDelete = false;
  late TextEditingController _commentController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  String? _selectedProjectId;
  String? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final entry = widget.resolvedEntry?.entry;
    _commentController = TextEditingController(text: entry?.comment ?? '');
    _startTimeController = TextEditingController(
      text: entry != null ? _formatTimeInput(entry.startAt) : '',
    );
    _endTimeController = TextEditingController(
      text: entry?.endAt != null ? _formatTimeInput(entry!.endAt!) : '',
    );
    _selectedProjectId = entry?.projectId;
    _selectedTaskId = entry?.taskId;
  }

  @override
  void didUpdateWidget(TimeEntryDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpen && oldWidget.isOpen) {
      _isConfirmingDelete = false;
    }
    if (widget.resolvedEntry != oldWidget.resolvedEntry) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  bool get _isNew => widget.isNew;

  void _handleSave() async {
    if (widget.resolvedEntry == null) return;

    final state = context.read<TimeTrackerState>();
    final entry = widget.resolvedEntry!.entry;

    final startAt = _parseTimeInput(_startTimeController.text, entry.startAt);
    final endAt = _endTimeController.text.isNotEmpty
        ? _parseTimeInput(_endTimeController.text, entry.endAt ?? entry.startAt)
        : null;

    final updatedEntry = entry.copyWith(
      id: entry.id,
      projectId: _selectedProjectId,
      taskId: _selectedTaskId,
      comment: _commentController.text,
      startAt: startAt,
      endAt: endAt,
      status: entry.status,
    );

    if (widget.isNew) {
      await state.createEntry(updatedEntry);
    } else {
      await state.updateEntry(updatedEntry);
    }

    widget.onClose();
  }

  String _formatTimeInput(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime _parseTimeInput(String input, DateTime baseDate) {
    try {
      final parts = input.split(':');
      if (parts.length != 2) return baseDate;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (e) {
      return baseDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;
    final projectTaskState = context.watch<ProjectTaskState>();

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
      body: widget.resolvedEntry == null
          ? const SizedBox.shrink()
          : Column(
              children: [
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
                            title: const Text('Delete this time entry?'),
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
                                    setState(() {
                                      _isConfirmingDelete = false;
                                    });
                                  },
                                  title: 'Cancel',
                                  type: ButtonType.ghost,
                                  size: ButtonSize.sm,
                                ),
                                PrimaryButton(
                                  onTap: () {
                                    if (widget.resolvedEntry != null) {
                                      context
                                          .read<TimeTrackerState>()
                                          .deleteEntry(
                                            widget.resolvedEntry!.entry.id,
                                          );
                                      widget.onClose();
                                    }
                                  },
                                  title: 'Delete',
                                  type: ButtonType.danger,
                                  size: ButtonSize.sm,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('no_confirmation')),
                ),
                Expanded(
                  child: DrawerContent(
                    meta: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.resolvedEntry!.isRunning)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: theme.spacings.s12,
                              vertical: theme.spacings.s4,
                            ),
                            decoration: BoxDecoration(
                              color: palette.accent.primaryMuted,
                              borderRadius: theme.radiuses.pill.circular,
                            ),
                            child: Text(
                              'ACTIVE LOG',
                              style: theme.commonTextStyles.caption3Bold
                                  .copyWith(color: palette.accent.primary),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (widget.resolvedEntry!.isRunning)
                          SizedBox(height: theme.spacings.s24),

                        Select<String>(
                          value: _selectedProjectId,
                          placeholder: 'Select Project',
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectId = value;
                              _selectedTaskId =
                                  null; // Reset task when project changes
                            });
                          },
                          options: projectTaskState.projects.map((p) {
                            return SelectOption(value: p.id, label: p.name);
                          }).toList(),
                        ),
                        SizedBox(height: theme.spacings.s16),
                        Select<String>(
                          value: _selectedTaskId,
                          placeholder: 'Select Task',
                          onChanged: (value) {
                            setState(() {
                              _selectedTaskId = value;
                            });
                          },
                          options: projectTaskState.tasks
                              .where((t) => t.projectId == _selectedProjectId)
                              .map((t) {
                                return SelectOption(
                                  value: t.id,
                                  label: t.title,
                                );
                              })
                              .toList(),
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
                          // Metrics Grid
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(theme.spacings.s16),
                                  decoration: BoxDecoration(
                                    color: palette.background.surfaceMuted,
                                    borderRadius: theme.radiuses.md.circular,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DURATION',
                                        style: theme
                                            .commonTextStyles
                                            .caption3Bold
                                            .copyWith(
                                              color: palette.text.muted,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      SizedBox(height: theme.spacings.s8),
                                      Text(
                                        _formatDuration(
                                          widget.resolvedEntry!.duration(
                                            DateTime.now(),
                                          ),
                                        ),
                                        style: theme.commonTextStyles.h2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: theme.spacings.s16),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(theme.spacings.s16),
                                  decoration: BoxDecoration(
                                    color: palette.background.surfaceMuted,
                                    borderRadius: theme.radiuses.md.circular,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'COST EST.',
                                        style: theme
                                            .commonTextStyles
                                            .caption3Bold
                                            .copyWith(
                                              color: palette.text.muted,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      SizedBox(height: theme.spacings.s8),
                                      Text(
                                        '\$0.00',
                                        style: theme.commonTextStyles.h2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: theme.spacings.s32),

                          // Timeline
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'START TIME',
                                      style: theme.commonTextStyles.caption3Bold
                                          .copyWith(
                                            color: palette.text.muted,
                                            letterSpacing: 1.0,
                                          ),
                                    ),
                                    SizedBox(height: theme.spacings.s4),
                                    PrimaryInput(
                                      label: 'START TIME',
                                      controller: _startTimeController,
                                      hintText: 'HH:mm',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: theme.spacings.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'END TIME',
                                      style: theme.commonTextStyles.caption3Bold
                                          .copyWith(
                                            color: palette.text.muted,
                                            letterSpacing: 1.0,
                                          ),
                                    ),
                                    SizedBox(height: theme.spacings.s4),
                                    PrimaryInput(
                                      label: 'START TIME',
                                      controller: _endTimeController,
                                      hintText: 'HH:mm',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: theme.spacings.s32),

                          // Comments
                          TextArea(
                            label: 'COMMENTS',
                            hintText: 'Add a comment...',
                            controller: _commentController,
                            maxLines: 4,
                          ),
                          SizedBox(height: theme.spacings.s32),

                          // Tags
                          Text(
                            'AI SUGGESTED TAGS',
                            style: theme.commonTextStyles.caption3Bold.copyWith(
                              color: palette.text.muted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: theme.spacings.s12),
                          Wrap(
                            spacing: theme.spacings.s8,
                            runSpacing: theme.spacings.s8,
                            children: <Widget>[],
                          ),
                          SizedBox(
                            height: theme.spacings.s24,
                          ), // Bottom padding for scroll
                        ],
                      ),
                    ),
                    footer: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onTap: _handleSave,
                        title: _isNew ? 'Create Entry' : 'Save Changes',
                        size: ButtonSize.lg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}

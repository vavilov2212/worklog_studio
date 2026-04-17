import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/feature/desktop/presentation/mini_tracker_cubit.dart';
import 'package:worklog_studio/feature/time_tracker/presentation/components/active_timer_text.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/state/entity_resolver.dart';
import 'package:collection/collection.dart';

class MiniPanel extends StatefulWidget {
  const MiniPanel({super.key});

  @override
  State<MiniPanel> createState() => _MiniPanelState();
}

class _MiniPanelState extends State<MiniPanel> {
  static const _platform = MethodChannel('worklog_studio/ipc');
  bool _isVisible = false;
  bool _isExpanded = false;

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

  Widget _buildActiveSession(
    bool isRunning,
    TimeEntry? activeEntry,
    AppThemeExtension theme,
  ) {
    return !isRunning
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTIVE SESSION', style: theme.commonTextStyles.caption),
              SizedBox(height: theme.spacings.s4),
              Text(
                activeEntry?.comment ?? 'Website Redesign — Hero Section',
                style: theme.commonTextStyles.title,
              ),
              SizedBox(height: theme.spacings.s4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('02:14:45', style: theme.commonTextStyles.title),
                  const Spacer(),
                  PrimaryButton(
                    type: ButtonType.ghost,
                    size: ButtonSize.sm,
                    leftIcon: WorklogStudioAssets.vectors.square24Svg,
                    onTap: () {},
                  ),
                  SizedBox(width: theme.spacings.s4),
                  PrimaryButton(
                    type: ButtonType.ghost,
                    size: ButtonSize.sm,
                    leftIcon: WorklogStudioAssets.vectors.square24Svg,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacings.s8),
            child: Text(
              'No active session running.',
              style: theme.commonTextStyles.caption,
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

  Widget _buildRecentActivity(AppThemeExtension theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('RECENT ACTIVITY', style: theme.commonTextStyles.caption),
            const Spacer(),
            Text('View All', style: theme.commonTextStyles.caption),
          ],
        ),
        SizedBox(height: theme.spacings.s4),
        Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.symmetric(vertical: theme.spacings.s4),
              child: Row(
                children: [
                  const Icon(Icons.work, size: 16),
                  SizedBox(width: theme.spacings.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Task Title', style: theme.commonTextStyles.body),
                        SizedBox(height: theme.spacings.s0),
                        Text(
                          'Logged 1h 20m',
                          style: theme.commonTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

        final comment = isRunning ? activeEntry?.comment : null;

        final displayTitle = isRunning
            ? (comment?.isNotEmpty == true ? comment! : "Running Task")
            : "Ready to work";

        // Group entries by date
        final allEntries = state.allEntries.where((e) => !e.isRunning).toList()
          ..sort((a, b) => b.startAt.compareTo(a.startAt));

        final groupedEntries = groupBy(allEntries, (TimeEntry e) {
          final local = e.startAt.toLocal();
          return DateTime(local.year, local.month, local.day);
        });
        final theme = context.theme;
        final palette = theme.colorsPalette;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isVisible ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: palette.background.surface,
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
                child: Padding(
                  padding: EdgeInsets.all(theme.spacings.s16),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Worklog Studio',
                              style: theme.commonTextStyles.title,
                            ),
                            const Spacer(),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIcon: WorklogStudioAssets.vectors.square24Svg,
                              onTap: _toggleExpansion,
                            ),
                            SizedBox(width: theme.spacings.s4),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIcon: WorklogStudioAssets.vectors.square24Svg,
                              onTap: () {},
                            ),
                            SizedBox(width: theme.spacings.s4),
                            PrimaryButton(
                              type: ButtonType.ghost,
                              size: ButtonSize.sm,
                              leftIcon: WorklogStudioAssets.vectors.square24Svg,
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: theme.spacings.s12),
                        PrimaryInput(
                          label: null,
                          controller: TextEditingController(),
                          hintText: 'Search or start a task…',
                          autofocus: true,
                        ),
                        SizedBox(height: theme.spacings.s12),
                        _buildActiveSession(isRunning, activeEntry, theme),
                        SizedBox(height: theme.spacings.s12),
                        _buildActionGrid(theme),
                        SizedBox(height: theme.spacings.s12),
                        if (_isExpanded) ...[
                          Flexible(
                            fit: FlexFit.loose,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: _buildRecentActivity(theme),
                            ),
                          ),
                        ],
                        SizedBox(height: theme.spacings.s12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Today 06h 15m | Total 24h 30m',
                              style: theme.commonTextStyles.caption,
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  const _MiniActiveTimerTextWrapper({required this.entry});

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
          style: context.theme.commonTextStyles.captionBold.copyWith(
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

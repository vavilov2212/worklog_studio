import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worklog_studio/feature/time_tracker/bloc/time_tracker_bloc.dart';
import 'package:worklog_studio/feature/time_tracker/presentation/components/active_timer_text.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

import 'package:worklog_studio/feature/desktop/bloc/mini_tracker_cubit.dart';
import 'package:worklog_studio/feature/desktop/presentation/components/simple_timer_text.dart';

class MiniPanel extends StatefulWidget {
  const MiniPanel({super.key});

  @override
  State<MiniPanel> createState() => _MiniPanelState();
}

class _MiniPanelState extends State<MiniPanel> with WindowListener {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Trigger enter animation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowBlur() {
    // Hide on blur with a small delay to avoid race conditions
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!mounted) return;
      if (await windowManager.isFocused()) return;
      await windowManager.hide();
    });
  }

  @override
  void onWindowClose() {
    // Notify main window that we are closing
    context.read<MiniTrackerCubit>().close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return BlocBuilder<MiniTrackerCubit, MiniTrackerState>(
      builder: (context, state) {
        final isRunning = state.isRunning;
        final activeEntry = state.activeEntry;
        final draft = state.draft;

        final displayData = isRunning ? activeEntry : draft;
        final projectName = displayData?['projectName'] ?? 'No Project';
        final taskName = displayData?['taskName'] ?? 'No Task';
        final comment = displayData?['comment'];
        final startAtStr = activeEntry?['startAt'];
        final startAt = startAtStr != null ? DateTime.parse(startAtStr) : null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isVisible ? 1.0 : 0.0,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 10.0, end: 0.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: GestureDetector(
                onPanStart: (_) => windowManager.startDragging(),
                child: Container(
                  margin: EdgeInsets.all(theme.spacings.s8),
                  decoration: BoxDecoration(
                    color: palette.background.surface,
                    borderRadius: BorderRadius.circular(theme.spacings.s16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: palette.border.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(theme.spacings.s16),
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacings.s16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      projectName,
                                      style: theme.commonTextStyles.caption3Bold
                                          .copyWith(color: palette.text.muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      taskName,
                                      style: theme.commonTextStyles.bodyBold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SimpleTimerText(
                                startTime: isRunning ? startAt : null,
                                style: theme.commonTextStyles.h2.copyWith(
                                  color: isRunning
                                      ? palette.accent.primary
                                      : palette.text.muted,
                                ),
                              ),
                            ],
                          ),
                          if (comment != null && comment.isNotEmpty) ...[
                            SizedBox(height: theme.spacings.s8),
                            Text(
                              comment,
                              style: theme.commonTextStyles.caption.copyWith(
                                color: palette.text.secondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: theme.spacings.s16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_full),
                                onPressed: () => context
                                    .read<MiniTrackerCubit>()
                                    .openFullApp(),
                                tooltip: 'Full App',
                              ),
                              isRunning
                                  ? PrimaryButton(
                                      title: 'STOP',
                                      leftIcon: WorklogStudioAssets
                                          .vectors
                                          .square24Svg,
                                      backgroundColor: palette.accent.danger,
                                      onTap: () => context
                                          .read<MiniTrackerCubit>()
                                          .stop(),
                                    )
                                  : PrimaryButton(
                                      title: 'START',
                                      leftIcon: WorklogStudioAssets
                                          .vectors
                                          .playerPlay24Svg,
                                      onTap: () => context
                                          .read<MiniTrackerCubit>()
                                          .start(),
                                    ),
                            ],
                          ),
                        ],
                      ),
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

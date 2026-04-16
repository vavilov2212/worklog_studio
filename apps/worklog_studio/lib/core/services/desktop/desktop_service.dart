import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worklog_studio/feature/time_tracker/bloc/time_tracker_bloc.dart';

import 'package:worklog_studio/feature/app/app.dart';
import 'package:worklog_studio/feature/desktop/presentation/mini_panel.dart';

import 'package:worklog_studio/state/entity_resolver.dart';
import 'package:worklog_studio/state/project_task_state.dart';

import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:worklog_studio/core/services/desktop/ipc_service.dart';

class DesktopService {
  static final DesktopService _instance = DesktopService._internal();
  factory DesktopService() => _instance;
  DesktopService._internal();

  final SystemTray _systemTray = SystemTray();
  final IpcService _ipc = IpcService();
  StreamSubscription<TimeTrackerBlocState>? _blocSubscription;
  TimeTrackerBloc? _bloc;
  EntityResolver? _resolver;
  ProjectTaskState? _projectTaskState;
  bool _isInitialized = false;
  bool? _lastIsRunning;
  int? _miniWindowId;
  bool _miniVisible = false;

  Future<void> init(
    TimeTrackerBloc bloc,
    EntityResolver resolver,
    ProjectTaskState projectTaskState,
  ) async {
    if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) return;
    if (_isInitialized) return;

    _bloc = bloc;
    _resolver = resolver;
    _projectTaskState = projectTaskState;

    await windowManager.ensureInitialized();
    _ipc.init();
    _ipc.registerHandler(_handleIpcMessage);

    await _initSystemTray();

    _blocSubscription = bloc.stream.listen((state) {
      _updateTray(state);
      _broadcastSnapshot(state);
    });

    _isInitialized = true;
    // Initial update
    _updateTray(bloc.state);
  }

  Future<void> _initSystemTray() async {
    // Default to idle icon
    String iconPath = 'assets/app_icon_idle.png';

    try {
      await _systemTray.initSystemTray(
        title: "Worklog Studio",
        iconPath: iconPath,
      );
    } catch (e) {
      debugPrint("Failed to init system tray: $e");
    }

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _togglePopover();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  Future<void> _togglePopover() async {
    if (_miniWindowId != null && _miniVisible) {
      try {
        final controller = WindowController.fromWindowId(_miniWindowId!);
        await controller.hide();
        _miniVisible = false;
      } catch (e) {
        debugPrint('Failed to hide mini window, resetting: $e');
        _miniWindowId = null;
        _miniVisible = false;
        await _showPopover();
      }
    } else {
      await _showPopover();
    }
  }

  Future<void> _showPopover() async {
    try {
      if (_miniWindowId == null) {
        final window = await DesktopMultiWindow.createWindow(
          jsonEncode({'type': 'mini_panel'}),
        );
        _miniWindowId = window.windowId;

        const Size popoverSize = Size(320, 400);

        // Position near tray (top-right fallback)
        try {
          final primaryDisplay = await ScreenRetriever.instance
              .getPrimaryDisplay();
          final size = primaryDisplay.size;

          // Position at top-right with some padding
          final x = size.width - popoverSize.width - 20;
          final y = 20.0;

          await window.setFrame(
            Rect.fromLTWH(x, y, popoverSize.width, popoverSize.height),
          );
        } catch (e) {
          debugPrint('Failed to position window: $e');
          await window.setFrame(const Rect.fromLTWH(0, 0, 320, 400));
          await window.center();
        }

        await window.setTitle('Worklog Mini');
      }

      final window = WindowController.fromWindowId(_miniWindowId!);
      await window.show();
      // await window.focus();
      _miniVisible = true;
    } catch (e) {
      debugPrint('Failed to show popover, resetting: $e');
      _miniWindowId = null;
      _miniVisible = false;
      // Re-attempt creation if it failed
      if (e.toString().contains('dead channel')) {
        await _showPopover();
      }
    }
  }

  void _broadcastSnapshot(TimeTrackerBlocState state) {
    if (_miniWindowId == null || !_miniVisible) return;

    final resolver = _resolver;
    final projectTaskState = _projectTaskState;
    if (resolver == null || projectTaskState == null) return;

    final activeEntry = state.activeEntryOrNull;

    final snapshot = {
      'isRunning': state.isRunning,
      'activeEntry': activeEntry != null
          ? {
              'id': activeEntry.id,
              'startAt': activeEntry.startAt.toIso8601String(),
              'projectName':
                  resolver.getProjectName(activeEntry.projectId) ??
                  'No Project',
              'taskName':
                  resolver.getProjectName(activeEntry.taskId) ??
                  resolver.getTaskName(activeEntry.taskId) ??
                  'No Task',
              'comment': activeEntry.comment,
            }
          : null,
      'draft': {
        'projectName':
            resolver.getProjectName(projectTaskState.draftProjectId) ??
            'No Project',
        'taskName':
            resolver.getTaskName(projectTaskState.draftTaskId) ?? 'No Task',
        'comment': projectTaskState.draftComment,
      },
    };

    try {
      _ipc.broadcastSnapshot(_miniWindowId!, snapshot);
    } catch (e) {
      debugPrint('Failed to broadcast snapshot, resetting mini window: $e');
      _miniWindowId = null;
      _miniVisible = false;
    }
  }

  Future<dynamic> _handleIpcMessage(
    String method,
    dynamic arguments,
    int fromWindowId,
  ) async {
    if (method == 'action') {
      final data = jsonDecode(arguments as String);
      if (data['version'] != '1.0') return null;

      final action = data['action'];
      final payload = data['payload'];

      switch (action) {
        case 'ready':
          if (_bloc != null) {
            _broadcastSnapshot(_bloc!.state);
          }
          break;
        case 'closed':
          if (fromWindowId == _miniWindowId) {
            _miniWindowId = null;
            _miniVisible = false;
          }
          break;
        case 'start':
          _bloc?.add(TimeTrackerStarted());
          break;
        case 'stop':
          _bloc?.add(TimeTrackerStopped());
          break;
        case 'openFullApp':
          await _openFullApp();
          break;
      }
    }
    return null;
  }

  Future<void> _openFullApp() async {
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.show();
    await windowManager.focus();
  }

  void _updateTray(TimeTrackerBlocState state) {
    final isRunning = state.isRunning;
    final activeEntry = state.activeEntryOrNull;
    final resolver = _resolver;

    // Update icon only if state changed
    if (_lastIsRunning != isRunning) {
      _lastIsRunning = isRunning;
      final iconPath = isRunning
          ? 'assets/app_icon_running.png'
          : 'assets/app_icon_idle.png';
      _systemTray.setImage(iconPath).catchError((e) {
        debugPrint("Failed to update tray icon: $e");
      });
    }

    String title = "Worklog Studio";
    if (isRunning && activeEntry != null && resolver != null) {
      final projectName = resolver.getProjectName(activeEntry.projectId);
      final taskName = resolver.getTaskName(activeEntry.taskId);
      title = "$projectName - $taskName";
      if (activeEntry.comment != null && activeEntry.comment!.isNotEmpty) {
        title += " (${activeEntry.comment})";
      }
    }

    _systemTray.setTitle(title);
    _rebuildMenu(state);
  }

  Future<void> _rebuildMenu(TimeTrackerBlocState state) async {
    final isRunning = state.isRunning;
    final bloc = _bloc;
    if (bloc == null) return;

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Open Full App',
        onClicked: (menuItem) async {
          await _openFullApp();
        },
      ),
      MenuItemLabel(
        label: 'Open Mini Panel',
        onClicked: (menuItem) => _showPopover(),
      ),
      MenuSeparator(),
      if (!isRunning)
        MenuItemLabel(
          label: 'Start Timer',
          onClicked: (menuItem) => bloc.add(
            TimeTrackerStarted(
              projectId: _projectTaskState?.draftProjectId,
              taskId: _projectTaskState?.draftTaskId,
              comment: _projectTaskState?.draftComment,
            ),
          ),
        )
      else
        MenuItemLabel(
          label: 'Stop Timer',
          onClicked: (menuItem) => bloc.add(TimeTrackerStopped()),
        ),
      MenuSeparator(),
      MenuItemLabel(label: 'Quit', onClicked: (menuItem) => exit(0)),
    ]);

    await _systemTray.setContextMenu(menu);
  }

  // Removed _openMiniPanel as it's replaced by _showPopover

  void dispose() {
    _blocSubscription?.cancel();
  }
}

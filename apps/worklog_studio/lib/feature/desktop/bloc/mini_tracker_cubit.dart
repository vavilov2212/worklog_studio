import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/core/services/desktop/ipc_service.dart';

class MiniTrackerState {
  final bool isRunning;
  final Map<String, dynamic>? activeEntry;
  final Map<String, dynamic>? draft;
  final String version;

  const MiniTrackerState({
    this.isRunning = false,
    this.activeEntry,
    this.draft,
    this.version = '1.0',
  });

  MiniTrackerState copyWith({
    bool? isRunning,
    Map<String, dynamic>? activeEntry,
    Map<String, dynamic>? draft,
    String? version,
  }) {
    return MiniTrackerState(
      isRunning: isRunning ?? this.isRunning,
      activeEntry: activeEntry ?? this.activeEntry,
      draft: draft ?? this.draft,
      version: version ?? this.version,
    );
  }
}

class MiniTrackerCubit extends Cubit<MiniTrackerState> {
  final int windowId;
  final IpcService _ipc = IpcService();

  MiniTrackerCubit({required this.windowId}) : super(const MiniTrackerState()) {
    _init();
  }

  void _init() {
    _ipc.init();
    _ipc.registerHandler(_handleIpcMessage);

    // Notify main window that we are ready to receive snapshots
    _ipc.sendAction(0, 'ready');
  }

  Future<dynamic> _handleIpcMessage(
    String method,
    dynamic arguments,
    int fromWindowId,
  ) async {
    if (method == 'onSnapshot') {
      final data = jsonDecode(arguments as String);
      if (data['version'] != '1.0') return null;

      final payload = data['payload'];
      emit(
        state.copyWith(
          isRunning: payload['isRunning'],
          activeEntry: payload['activeEntry'],
          draft: payload['draft'],
          version: data['version'],
        ),
      );
    }
    return null;
  }

  void start() {
    _ipc.sendAction(0, 'start');
  }

  void stop() {
    _ipc.sendAction(0, 'stop');
  }

  void openFullApp() {
    _ipc.sendAction(0, 'openFullApp');
  }

  @override
  Future<void> close() {
    _ipc.unregisterHandler(_handleIpcMessage);
    _ipc.sendAction(0, 'closed');
    return super.close();
  }
}

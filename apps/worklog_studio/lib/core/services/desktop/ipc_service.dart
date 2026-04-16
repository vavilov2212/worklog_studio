import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

typedef IpcHandler = Future<dynamic> Function(String method, dynamic arguments, int fromWindowId);

class IpcService {
  static final IpcService _instance = IpcService._internal();
  factory IpcService() => _instance;
  IpcService._internal();

  final List<IpcHandler> _handlers = [];
  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      debugPrint('IPC: Received method=${call.method} from=$fromWindowId');
      
      for (final handler in _handlers) {
        try {
          final result = await handler(call.method, call.arguments, fromWindowId);
          if (result != null) return result;
        } catch (e) {
          debugPrint('IPC Error: $e');
        }
      }
      return null;
    });
  }

  void registerHandler(IpcHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  void unregisterHandler(IpcHandler handler) {
    _handlers.remove(handler);
  }

  Future<dynamic> sendAction(int targetWindowId, String action, [Map<String, dynamic>? payload]) async {
    final message = {
      'version': '1.0',
      'type': 'action',
      'action': action,
      'payload': payload ?? {},
    };
    
    final jsonMessage = jsonEncode(message);
    debugPrint('IPC: Sending action=$action to=$targetWindowId');
    
    return DesktopMultiWindow.invokeMethod(
      targetWindowId,
      'action',
      jsonMessage,
    );
  }

  Future<void> broadcastSnapshot(int targetWindowId, Map<String, dynamic> snapshot) async {
    final message = {
      'version': '1.0',
      'type': 'snapshot',
      'payload': snapshot,
    };
    
    final jsonMessage = jsonEncode(message);
    debugPrint('IPC: Broadcasting snapshot to=$targetWindowId');
    
    await DesktopMultiWindow.invokeMethod(
      targetWindowId,
      'onSnapshot',
      jsonMessage,
    );
  }
}

import 'package:flutter/material.dart';
import 'drawer_layer.dart';
import 'drawer_constraints.dart';
import 'drawer_overlay.dart';

class DrawerService {
  OverlayState? _rootOverlay;
  OverlayState? _localOverlay;
  OverlayEntry? _entry;

  bool get isOpen => _entry?.mounted ?? false;

  // --- attach ---

  void attachRoot(OverlayState overlay) {
    _rootOverlay = overlay;
  }

  void attachLocal(OverlayState overlay) {
    _localOverlay = overlay;
  }

  // --- api ---

  void open({
    required WidgetBuilder builder,
    DrawerConstraints constraints = const DrawerConstraints(sizeFactor: 0.8),
    DrawerLayer layer = DrawerLayer.root,
  }) {
    final overlay = _overlayFor(layer);
    if (overlay == null) {
      debugPrint('DrawerService: overlay not attached ($layer)');
      return;
    }

    close();

    _entry = OverlayEntry(
      builder: (_) => DrawerOverlay(
        layer: layer,
        constraints: constraints,
        childBuilder: builder,
        onClose: close,
      ),
    );

    overlay.insert(_entry!);
  }

  void close() {
    final entry = _entry;
    if (entry == null) return;

    if (entry.mounted) {
      entry.remove();
    }
    _entry = null;
  }

  void toggle({
    required WidgetBuilder builder,
    DrawerLayer layer = DrawerLayer.local,
  }) {
    isOpen ? close() : open(builder: builder, layer: layer);
  }

  OverlayState? _overlayFor(DrawerLayer layer) {
    return switch (layer) {
      DrawerLayer.root => _rootOverlay,
      DrawerLayer.local => _localOverlay,
    };
  }
}

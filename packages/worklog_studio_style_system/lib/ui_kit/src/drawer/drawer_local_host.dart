import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'drawer_service.dart';

class LocalDrawerHost extends StatefulWidget {
  const LocalDrawerHost({super.key, required this.child});

  final Widget child;

  @override
  State<LocalDrawerHost> createState() => _LocalDrawerHostState();
}

class _LocalDrawerHostState extends State<LocalDrawerHost> {
  final _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = _overlayKey.currentState;
      if (overlay != null) {
        GetIt.I<DrawerService>().attachLocal(overlay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Overlay(key: _overlayKey),
      ],
    );
  }
}

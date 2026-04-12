import 'package:flutter/material.dart';
import 'drawer_layer.dart';
import 'drawer_constraints.dart';

class DrawerOverlay extends StatelessWidget {
  final DrawerLayer layer;
  final DrawerConstraints constraints;
  final WidgetBuilder childBuilder;
  final VoidCallback onClose;

  const DrawerOverlay({
    super.key,
    required this.childBuilder,
    required this.onClose,
    this.layer = DrawerLayer.root,
    this.constraints = const DrawerConstraints(
      sizeFactor: 0.8,
      alignment: Alignment.centerRight,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final alignment = constraints.alignment;
    final isVertical =
        alignment == Alignment.topCenter || alignment == Alignment.bottomCenter;
    double sizeFactor = constraints.sizeFactor ?? 0.8;
    double width = screenWidth * sizeFactor;
    double height = screenHeight * sizeFactor;
    if (constraints.absoluteWidth != null) {
      width = constraints.absoluteWidth!;
    }

    if (constraints.anchorRect != null) {
      width = screenWidth - constraints.anchorRect!.left;
    }

    Widget drawer = Align(
      alignment: alignment,
      child: Material(
        elevation: 16,
        child: SizedBox(
          width: isVertical ? double.infinity : width,
          height: isVertical ? height : double.infinity,
          child: childBuilder(context),
        ),
      ),
    );

    if (layer == DrawerLayer.local) {
      drawer = SafeArea(child: drawer);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        drawer,
      ],
    );
  }
}

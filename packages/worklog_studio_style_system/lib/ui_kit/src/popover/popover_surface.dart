import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class PopoverSurface extends StatelessWidget {
  final Widget child;

  const PopoverSurface({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorsPalette.background.surface,
        border: Border.all(color: context.theme.colorsPalette.border.primary),
        borderRadius: context.theme.radiuses.md.circular,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge, // Чтобы контент не вылезал за радиус
      child: child,
    );
  }
}

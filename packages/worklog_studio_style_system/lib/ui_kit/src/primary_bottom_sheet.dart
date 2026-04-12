import 'dart:async';

import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';
import 'package:worklog_studio_style_system/ui_kit/src/modal_indicator.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as cmbs;

mixin PrimaryBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool bounce = true,
    bool expand = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    Clip? clipBehavior,
    EdgeInsets? padding,
    BorderRadiusGeometry? borderRadius,
    Color? backgroundColor,
  }) async {
    final modalBottomSheet = cmbs.ModalSheetRoute<T>(
      builder: builder,
      bounce: bounce,
      containerBuilder: (_, __, child) => _BottomSheet(
        child: child,
        padding: padding,
        clipBehavior: clipBehavior,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
      ),
      expanded: expand,
      barrierLabel:
          '123', // MaterialLocalizations.of(context).modalBarrierDismissLabel,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      settings: settings,
    );

    final result = await Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push<T>(modalBottomSheet);
    return result;
  }
}

class _BottomSheet extends StatelessWidget {
  final Widget child;
  final Clip? clipBehavior;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;

  const _BottomSheet({
    required this.child,
    this.clipBehavior,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSheetTheme = Theme.of(context).bottomSheetTheme;
    final theme = context.theme;
    return Padding(
      padding:
          padding ?? EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorsPalette.background.surface,
          borderRadius:
              borderRadius ??
              BorderRadius.vertical(top: Radius.circular(theme.radiuses.md)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ModalIndicator()),
            Flexible(
              child: Material(
                shape: bottomSheetTheme.shape,
                clipBehavior:
                    clipBehavior ??
                    bottomSheetTheme.clipBehavior ??
                    Clip.hardEdge,
                color: Colors.transparent,
                child: SizedBox(
                  width: double.infinity,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

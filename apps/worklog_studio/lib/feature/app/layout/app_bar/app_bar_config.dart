import 'package:flutter/material.dart';

class AppBarConfig {
  final Widget? title;
  final List<Widget>? actions;
  final bool visible;

  const AppBarConfig({this.title, this.actions, this.visible = true});

  const AppBarConfig.hidden() : title = null, actions = null, visible = false;
}

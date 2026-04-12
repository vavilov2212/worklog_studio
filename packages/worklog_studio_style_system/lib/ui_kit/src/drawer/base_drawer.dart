import 'package:flutter/material.dart';

class BaseDrawer extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? footer;

  const BaseDrawer({super.key, this.header, required this.body, this.footer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header!,
        Expanded(child: body),
        if (footer != null) footer!,
      ],
    );
  }
}

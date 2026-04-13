import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class InlineField extends StatefulWidget {
  final String label;
  final String value;
  final String placeholder;
  final Widget editWidget;
  final bool isEditing;
  final VoidCallback onTap;
  final bool isTextArea;

  const InlineField({
    super.key,
    required this.label,
    required this.value,
    this.placeholder = 'Empty',
    required this.editWidget,
    required this.isEditing,
    required this.onTap,
    this.isTextArea = false,
  });

  @override
  State<InlineField> createState() => _InlineFieldState();
}

class _InlineFieldState extends State<InlineField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.commonTextStyles.caption.copyWith(
            color: palette.text.muted,
          ),
        ),
        SizedBox(height: theme.spacings.s8),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: widget.isEditing
                ? widget.editWidget
                : Container(
                    width: double.infinity,
                    height: widget.isTextArea ? null : theme.spacings.s48,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isTextArea
                          ? theme.spacings.s16
                          : theme.spacings.s12,
                      vertical: widget.isTextArea
                          ? theme.spacings.s16
                          : theme.spacings.s12,
                    ),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? palette.background.surfaceMuted
                          : Colors.transparent,
                      borderRadius: theme.radiuses.md.circular,
                    ),
                    child: Text(
                      widget.value.isEmpty ? widget.placeholder : widget.value,
                      style: theme.commonTextStyles.body.copyWith(
                        color: widget.value.isEmpty
                            ? palette.text.muted
                            : palette.text.primary,
                        fontStyle: widget.value.isEmpty
                            ? FontStyle.italic
                            : null,
                      ),
                      maxLines: widget.isTextArea ? null : 1,
                      overflow: widget.isTextArea
                          ? null
                          : TextOverflow.ellipsis,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

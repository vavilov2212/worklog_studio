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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacings.s0),
              child: Text(
                widget.label,
                style: theme.commonTextStyles.captionSemiBold.copyWith(
                  color: _isHovered || widget.isEditing
                      ? palette.text.primary
                      : palette.text.secondary2,
                ),
              ),
            ),
            SizedBox(height: theme.spacings.s8),
            if (widget.isTextArea && widget.isEditing)
              widget.editWidget
            else
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // View Mode (Base Layer)
                  // Always rendered with Visibility(maintainSize: true) to ensure layout stability
                  Visibility(
                    visible: !widget.isEditing,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacings.s12,
                        vertical: theme.spacings.s12,
                      ),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? palette.background.surfaceMuted
                            : Colors.transparent,
                        borderRadius: theme.radiuses.md.circular,
                        // Add transparent border to match edit mode's border size
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        spacing: theme.spacings.s8,
                        children: [
                          Expanded(
                            child: Text(
                              widget.value.isEmpty
                                  ? widget.placeholder
                                  : widget.value,
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
                          _isHovered
                              ? Icon(
                                  Icons.edit_sharp,
                                  color: _isHovered
                                      ? palette.text.secondary
                                      : palette.text.muted,
                                  size: 16.0,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  // Edit Mode (Overlay Layer) - Only for non-TextArea fields
                  if (widget.isEditing && !widget.isTextArea)
                    Positioned.fill(child: widget.editWidget),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

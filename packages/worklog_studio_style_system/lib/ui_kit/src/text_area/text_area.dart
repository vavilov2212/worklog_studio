import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/theme/colors_palette/colors_palette_entity.dart';
import 'package:worklog_studio_style_system/theme/radiuses.dart';
import 'package:worklog_studio_style_system/theme/theme_extension/app_theme_extension.dart';

class TextArea extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final TextInputType keyboardType;
  final bool enabled;
  final bool hasError;
  final bool autofocus;
  final int maxLength;
  final int? maxLines;
  final bool showCounter;

  const TextArea({
    required this.hintText,
    required this.controller,
    this.label,
    this.enabled = true,
    this.autofocus = false,
    this.hasError = false,
    this.showCounter = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 5,
    this.maxLength = 3000,
    super.key,
  });

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  TextEditingController get controller => widget.controller;
  ColorsPalette get palette => context.theme.colorsPalette;
  bool _hasFocus = false;

  Color get _borderColor {
    if (!widget.enabled) return palette.border.primary;
    if (_hasFocus) return palette.border.focus;
    return palette.border.primary;
  }

  Color get _labelColor {
    if (!widget.enabled) return palette.text.muted;
    return palette.text.primary;
  }

  Color get _counterColor {
    if (!widget.enabled) return palette.text.muted;
    return palette.text.secondary;
  }

  Color get _textColor {
    if (!widget.enabled) return palette.text.muted;
    return palette.text.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.theme.spacings.s8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: context.theme.commonTextStyles.caption.copyWith(
              color: _labelColor,
            ),
          ),
        Focus(
          onFocusChange: (focus) => setState(() => _hasFocus = focus),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            decoration: BoxDecoration(
              color: palette.background.surface,
              borderRadius: context.theme.radiuses.sm.circular,
              border: Border.all(color: _borderColor),
            ),
            padding: EdgeInsets.all(context.theme.spacings.s16),
            child: TextField(
              autofocus: widget.autofocus,
              controller: controller,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              cursorColor: palette.text.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: context.theme.commonTextStyles.body.copyWith(
                  color: palette.text.muted,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => const SizedBox.shrink(),
              style: context.theme.commonTextStyles.body.copyWith(
                color: _textColor,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        if (widget.showCounter)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${controller.text.length}/${widget.maxLength}',
              style: context.theme.commonTextStyles.caption2.copyWith(
                color: _counterColor,
              ),
            ),
          ),
      ],
    );
  }
}

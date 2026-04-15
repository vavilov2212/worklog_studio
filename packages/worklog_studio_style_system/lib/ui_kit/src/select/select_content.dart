import 'package:flutter/material.dart';
import 'package:worklog_studio_style_system/worklog_studio_style_system.dart';

class SelectContent<T> extends StatefulWidget {
  final bool searchable;
  final TextEditingController searchController;
  final List<SelectOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelect;
  final String searchQuery;
  final Widget Function(BuildContext context, String searchQuery)?
  footerBuilder;
  final Widget Function(BuildContext context, String searchQuery)? emptyBuilder;

  const SelectContent({
    super.key,
    required this.searchable,
    required this.searchController,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    required this.searchQuery,
    this.footerBuilder,
    this.emptyBuilder,
  });

  @override
  State<SelectContent<T>> createState() => _SelectContentState<T>();
}

class _SelectContentState<T> extends State<SelectContent<T>> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.searchable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final palette = theme.colorsPalette;

    final hasFooter = widget.footerBuilder != null;

    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: palette.background.surface,
        borderRadius: theme.radiuses.md.circular,
        border: Border.all(color: palette.border.primary),
        boxShadow: [theme.shadows.md],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.options.isEmpty && !hasFooter)
            Padding(
              padding: EdgeInsets.all(theme.spacings.s16),
              child: widget.emptyBuilder != null
                  ? widget.emptyBuilder!(context, widget.searchQuery)
                  : Text(
                      'No results found',
                      style: theme.commonTextStyles.body.copyWith(
                        color: palette.text.muted,
                      ),
                      textAlign: TextAlign.center,
                    ),
            )
          else
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.options.length + (hasFooter ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == widget.options.length) {
                    return widget.footerBuilder!(context, widget.searchQuery);
                  }

                  final option = widget.options[index];
                  final isSelected = option.value == widget.selectedValue;

                  return InkWell(
                    onTap: () => widget.onSelect(option.value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacings.s12,
                        vertical: theme.spacings.s12,
                      ),
                      color: isSelected
                          ? palette.accent.primary.withValues(alpha: 0.08)
                          : null,
                      child: Row(
                        children: [
                          if (option.leading != null) ...[
                            option.leading!,
                            SizedBox(width: theme.spacings.s8),
                          ],
                          Expanded(
                            child: Text(
                              option.label,
                              style: theme.commonTextStyles.body.copyWith(
                                color: isSelected
                                    ? palette.accent.primary
                                    : palette.text.primary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              size: 16,
                              color: palette.accent.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

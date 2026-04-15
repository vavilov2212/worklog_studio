import 'package:flutter/material.dart';

import '../combobox/combobox.dart';
import '../combobox/combobox_controller.dart';
import 'select_content.dart';
import 'select_option.dart';
import 'select_trigger.dart';
import 'select_types.dart';

class Select<T> extends StatefulWidget {
  /// Controlled value
  final T? value;

  /// Called when value changes
  final ValueChanged<T?>? onChanged;

  /// Uncontrolled initial value
  final T? defaultValue;

  /// Options list
  final List<SelectOption<T>> options;

  /// Placeholder when nothing selected
  final String placeholder;

  /// Enable search field
  final bool searchable;

  /// Disable component
  final bool enabled;

  /// External Combobox controller (optional)
  final ComboboxController? controller;
  final SelectSize size;
  final SelectVariant variant;
  final SelectMode mode;
  final bool matchTriggerWidth;

  /// Custom trigger builder
  final Widget Function(
    BuildContext context,
    SelectOption<T>? selectedOption,
    bool isOpen,
  )?
  triggerBuilder;

  final bool autoOpen;
  final ValueChanged<bool>? onOpenChange;
  final Object? tapRegionGroupId;

  /// Builder for custom footer actions (e.g., "Create New")
  final Widget Function(
    BuildContext context,
    String searchQuery,
    VoidCallback close,
  )?
  footerBuilder;

  /// Builder for custom empty state
  final Widget Function(BuildContext context, String searchQuery)? emptyBuilder;

  const Select({
    super.key,
    this.value,
    this.onChanged,
    this.defaultValue,
    required this.options,
    this.placeholder = 'Select option...',
    this.searchable = false,
    this.enabled = true,
    this.controller,
    this.size = SelectSize.md,
    this.variant = SelectVariant.outline,
    this.mode = SelectMode.single,
    this.matchTriggerWidth = true,
    this.triggerBuilder,
    this.autoOpen = false,
    this.onOpenChange,
    this.tapRegionGroupId,
    this.footerBuilder,
    this.emptyBuilder,
  }) : assert(
         !(value != null && defaultValue != null),
         'Select cannot be both controlled and uncontrolled.',
       );

  @override
  State<Select<T>> createState() => _SelectState<T>();
}

class _SelectState<T> extends State<Select<T>> {
  late final ComboboxController _controller;
  late final TextEditingController _searchController;

  T? _internalValue;
  String _searchQuery = '';

  bool get _isControlled => widget.value != null;

  T? get _currentValue => _isControlled ? widget.value : _internalValue;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? ComboboxController();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    if (!_isControlled) {
      _internalValue = widget.defaultValue;
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _controller.addListener(_handleOpenChange);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (!_controller.isOpen) {
          _controller.open();
        }
      }
    });

    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          _controller.open();
        }
      });
    }
  }

  void _handleOpenChange() {
    widget.onOpenChange?.call(_controller.isOpen);
    if (!_controller.isOpen) {
      _searchController.clear();
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant Select<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_handleOpenChange);
        _controller.dispose();
      } else {
        oldWidget.controller!.removeListener(_handleOpenChange);
      }
      _controller = widget.controller ?? ComboboxController();
      _controller.addListener(_handleOpenChange);
    }

    if (!_isControlled && oldWidget.defaultValue != widget.defaultValue) {
      _internalValue = widget.defaultValue;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleOpenChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSelect(T value) {
    if (!_isControlled) {
      setState(() => _internalValue = value);
    }

    widget.onChanged?.call(value);
    _controller.close();
  }

  List<SelectOption<T>> get _filteredOptions {
    if (!widget.searchable || _searchQuery.isEmpty) {
      return widget.options;
    }

    return widget.options
        .where(
          (option) =>
              option.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = widget.options
        .where((o) => o.value == _currentValue)
        .cast<SelectOption<T>?>()
        .firstWhere((o) => o != null, orElse: () => null);

    return Combobox(
      controller: _controller,
      enabled: widget.enabled,
      matchTriggerWidth: widget.matchTriggerWidth,
      tapRegionGroupId: widget.tapRegionGroupId,
      triggerBuilder: (context, open, isOpen) {
        if (widget.triggerBuilder != null) {
          return widget.triggerBuilder!(context, selectedOption, isOpen);
        }
        return SelectTrigger(
          label: selectedOption?.label,
          placeholder: widget.placeholder,
          controller: widget.searchable ? _searchController : null,
          focusNode: widget.searchable ? _focusNode : null,
          isOpen: isOpen,
        );
      },
      contentBuilder: (context, close) {
        return SelectContent<T>(
          searchable: widget.searchable,
          searchController: _searchController,
          options: _filteredOptions,
          selectedValue: _currentValue,
          onSelect: (value) {
            _handleSelect(value);
            close();
          },
          searchQuery: _searchQuery,
          footerBuilder: widget.footerBuilder != null
              ? (context, query) => widget.footerBuilder!(context, query, close)
              : null,
          emptyBuilder: widget.emptyBuilder,
        );
      },
    );
  }
}

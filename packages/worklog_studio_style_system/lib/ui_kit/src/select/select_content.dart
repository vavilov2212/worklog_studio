import 'package:flutter/material.dart';

import 'select_option.dart';

class SelectContent<T> extends StatelessWidget {
  final bool searchable;
  final TextEditingController searchController;
  final List<SelectOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelect;

  const SelectContent({
    required this.searchable,
    required this.searchController,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (searchable)
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.value == selectedValue;

                return InkWell(
                  onTap: () => onSelect(option.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.08)
                        : null,
                    child: Row(
                      children: [
                        if (option.leading != null) ...[
                          option.leading!,
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: Text(option.label)),
                        if (isSelected) const Icon(Icons.check, size: 16),
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

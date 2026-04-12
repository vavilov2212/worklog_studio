import 'package:flutter/material.dart';

class SelectTrigger extends StatelessWidget {
  final String? label;
  final String placeholder;

  const SelectTrigger({required this.label, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    final hasValue = label != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              hasValue ? label! : placeholder,
              style: TextStyle(
                color: hasValue ? Colors.black : Colors.grey.shade500,
              ),
            ),
          ),
          const Icon(Icons.unfold_more, size: 18),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Data model for Select option
class SelectOption<T> {
  final T value;
  final String label;
  final Widget? leading;

  const SelectOption({required this.value, required this.label, this.leading});
}

import 'package:flutter/material.dart';

class DrawerConstraints extends BoxConstraints {
  final double? sizeFactor;
  final double? absoluteWidth;
  final Rect? anchorRect;
  final Alignment alignment;

  const DrawerConstraints({
    this.sizeFactor = 0.8,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
    this.absoluteWidth,
    this.anchorRect,
    this.alignment = Alignment.centerRight,
  }) : super(
         minWidth: minWidth,
         maxWidth: maxWidth,
         minHeight: minHeight,
         maxHeight: maxHeight,
       );

  @override
  BoxConstraints copyWith({
    double? sizeFactor,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return DrawerConstraints(
      sizeFactor: sizeFactor ?? this.sizeFactor,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }
}

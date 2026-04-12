import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

extension VectorGraphicAsset on String {
  VectorGraphic vector({
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
    Widget Function(BuildContext)? placeholderBuilder,
    Widget Function(BuildContext, Object, StackTrace)? errorBuilder,
    ColorFilter? colorFilter,
    Animation<double>? opacity,
  }) {
    return VectorGraphic(
      key: key,
      loader: AssetBytesLoader(this),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
      placeholderBuilder: placeholderBuilder,
      errorBuilder: errorBuilder,
      colorFilter: colorFilter,
      opacity: opacity,
    );
  }
}

extension ColorToColorFilter on Color {
  ColorFilter get filter => ColorFilter.mode(this, BlendMode.srcIn);
}

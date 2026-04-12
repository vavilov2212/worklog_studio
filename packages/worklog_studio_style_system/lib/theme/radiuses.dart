import 'package:flutter/material.dart';

class Radiuses {
  final double sm = 6;

  final double md = 10;

  final double lg = 16;

  final double pill = 999;

  static const Radiuses _instance = Radiuses._();
  factory Radiuses() => _instance;
  const Radiuses._();
}

extension CircularBorderRadius on double {
  BorderRadius get circular => BorderRadius.circular(this);
}

import 'package:flutter/material.dart';

class Gradients {
  LinearGradient primaryHorizontal = const LinearGradient(colors: [Color(0xFF_7A38FF), Color(0xFF_3471FE)]);

  LinearGradient primaryVertical = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF_7A38FF), Color(0xFF_3471FE)],
  );

  LinearGradient primaryVerticalReverse = const LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xFF_7A38FF), Color(0xFF_3471FE)],
  );
}

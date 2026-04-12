import 'package:flutter/material.dart';

class DrawerController extends ChangeNotifier {
  bool _isOpen;

  DrawerController({bool initialOpen = false}) : _isOpen = initialOpen;

  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}

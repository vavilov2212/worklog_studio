import 'package:flutter/material.dart';

/// CONTROLLER: Управляет состоянием (открыт/закрыт)
class PopoverController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void show() {
    _isOpen = true;
    notifyListeners();
  }

  void hide() {
    _isOpen = false;
    notifyListeners();
  }

  void toggle() => _isOpen ? hide() : show();
}

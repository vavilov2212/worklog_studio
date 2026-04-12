import 'package:flutter/foundation.dart';

class ComboboxController extends ChangeNotifier {
  /// TODO(architecture):
  /// Consider adding a fully controlled mode:
  ///
  /// final bool? isOpen;
  /// final ValueChanged<bool>? onOpenChange;
  ///
  /// This would allow React-style controlled usage:
  ///
  /// Combobox(
  ///   isOpen: externalState,
  ///   onOpenChange: (value) => setState(() => externalState = value),
  /// )
  ///
  /// Current implementation uses ComboboxController for imperative control.
  /// In the future, we may support:
  /// 1. Controlled mode (isOpen + onOpenChange)
  /// 2. Uncontrolled mode (internal state)
  /// 3. Controller-based imperative mode
  ///
  /// If implemented, controller and controlled mode must be mutually exclusive.

  bool _isOpen = false;

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
    _isOpen ? close() : open();
  }
}

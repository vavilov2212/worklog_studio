import 'package:flutter/foundation.dart';

class InlineFieldController extends ChangeNotifier {
  bool _isEditing = false;
  String? _currentValue;
  final Object tapRegionGroupId = Object();

  bool get isEditing => _isEditing;
  String? get currentValue => _currentValue;

  void enterEditMode([String? initialValue]) {
    if (_isEditing) return;
    _isEditing = true;
    _currentValue = initialValue;
    notifyListeners();
  }

  void exitEditMode() {
    if (!_isEditing) return;
    _isEditing = false;
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing ? exitEditMode() : enterEditMode();
  }

  void updateValue(String newValue) {
    if (_currentValue != newValue) {
      _currentValue = newValue;
      notifyListeners();
    }
  }

  void resetValue() {
    if (_currentValue != null) {
      _currentValue = null;
      notifyListeners();
    }
  }

  // Standardized editor events
  void handleEditorCommit([String? newValue]) {
    if (newValue != null) {
      _currentValue = newValue;
    }
    exitEditMode();
  }

  void handleEditorCancel() {
    resetValue();
    exitEditMode();
  }

  void handleEditorClose() {
    exitEditMode();
  }
}

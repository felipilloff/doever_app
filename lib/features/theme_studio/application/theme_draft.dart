import 'package:flutter/foundation.dart';

import '../domain/custom_theme.dart';

/// In-memory editing only. A slider gesture occupies one history entry.
class ThemeDraft extends ChangeNotifier {
  ThemeDraft(CustomTheme baseline) : _baseline = baseline, _current = baseline;

  CustomTheme _baseline;
  CustomTheme _current;
  final _past = <CustomTheme>[];
  final _future = <CustomTheme>[];
  bool _gesture = false;

  CustomTheme get baseline => _baseline;
  CustomTheme get current => _current;
  bool get isDirty => _current != _baseline;
  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  void update(CustomTheme value, {bool coalesce = false}) {
    if (value == _current) return;
    if (!coalesce || !_gesture) {
      _past.add(_current);
      if (_past.length > 100) _past.removeAt(0);
    }
    _gesture = coalesce;
    _future.clear();
    _current = value;
    notifyListeners();
  }

  void endGesture() => _gesture = false;

  void undo() {
    endGesture();
    if (!canUndo) return;
    _future.add(_current);
    _current = _past.removeLast();
    notifyListeners();
  }

  void redo() {
    endGesture();
    if (!canRedo) return;
    _past.add(_current);
    _current = _future.removeLast();
    notifyListeners();
  }

  void reset() => update(_baseline);

  void resetLayer(int index) => update(switch (index) {
    0 => _current.copyWith(foundation: _baseline.foundation),
    1 => _current.copyWith(surface: _baseline.surface),
    2 => _current.copyWith(accent: _baseline.accent),
    _ => throw RangeError.index(index, [0, 1, 2]),
  });

  void markSaved(CustomTheme value) {
    _current = _baseline = value;
    _past.clear();
    _future.clear();
    endGesture();
    notifyListeners();
  }
}

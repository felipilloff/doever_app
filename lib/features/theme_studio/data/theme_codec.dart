import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../domain/custom_theme.dart';

abstract final class ThemeCodec {
  static const maxFileBytes = 64 * 1024;
  static const _format = 'doever-theme';
  static const _version = 1;

  static String encode(CustomTheme theme) {
    _validateTheme(theme, validateId: false);
    return jsonEncode({
      'format': _format,
      'version': _version,
      'name': theme.name,
      'baseMode': theme.baseMode.name,
      'autoBalance': theme.autoBalance,
      'foundation': _encodeLayer(theme.foundation),
      'surface': _encodeLayer(theme.surface),
      'accent': _encodeLayer(theme.accent),
    });
  }

  static CustomTheme decode(
    String source, {
    DateTime Function()? clock,
    String Function()? createId,
  }) {
    try {
      if (source.length > maxFileBytes ||
          utf8.encode(source).length > maxFileBytes) {
        throw const FormatException('Theme file is too large');
      }
      final value = jsonDecode(source);
      final map = _object(value, const {
        'format',
        'version',
        'name',
        'baseMode',
        'autoBalance',
        'foundation',
        'surface',
        'accent',
      });
      if (map['format'] != _format ||
          map['version'] is! int ||
          map['version'] != _version) {
        throw const FormatException('Unsupported theme format');
      }
      final now = (clock ?? DateTime.now)().toUtc();
      final theme = CustomTheme(
        id: (createId ?? const Uuid().v4)(),
        name: _string(map['name']),
        baseMode: _enumValue(ThemeBrightnessMode.values, map['baseMode']),
        foundation: _decodeLayer(map['foundation']),
        surface: _decodeLayer(map['surface']),
        accent: _decodeLayer(map['accent']),
        createdAt: now,
        updatedAt: now,
        autoBalance: _bool(map['autoBalance']),
      );
      _validateTheme(theme);
      return theme;
    } on AppFailure {
      rethrow;
    } on Object {
      throw const AppFailure(FailureKind.validation);
    }
  }

  static Map<String, Object> _encodeLayer(LayerTheme layer) => {
    'colors': layer.colors,
    'mode': layer.mode.name,
    'direction': layer.direction.name,
    'tone': layer.tone,
    'intensity': layer.intensity,
    'gradientStrength': layer.gradientStrength,
  };

  static LayerTheme _decodeLayer(Object? value) {
    final map = _object(value, const {
      'colors',
      'mode',
      'direction',
      'tone',
      'intensity',
      'gradientStrength',
    });
    return LayerTheme(
      colors: _list(map['colors']).map(_color).toList(),
      mode: _enumValue(ThemeLayerMode.values, map['mode']),
      direction: _enumValue(ThemeGradientDirection.values, map['direction']),
      tone: _number(map['tone']),
      intensity: _number(map['intensity']),
      gradientStrength: _number(map['gradientStrength']),
    );
  }

  static Map<String, Object?> _object(Object? value, Set<String> keys) {
    if (value is! Map<String, Object?> ||
        value.length != keys.length ||
        !value.keys.toSet().containsAll(keys)) {
      throw const FormatException('Unexpected theme fields');
    }
    return value;
  }

  static List<Object?> _list(Object? value) {
    if (value is! List<Object?>) throw const FormatException('Expected list');
    return value;
  }

  static String _string(Object? value) {
    if (value is! String) throw const FormatException('Expected string');
    return value;
  }

  static bool _bool(Object? value) {
    if (value is! bool) throw const FormatException('Expected boolean');
    return value;
  }

  static double _number(Object? value) {
    if (value is! num) throw const FormatException('Expected number');
    final result = value.toDouble();
    if (!result.isFinite) throw const FormatException('Expected finite number');
    return result;
  }

  static int _color(Object? value) {
    if (value is! int) throw const FormatException('Expected ARGB integer');
    return value;
  }

  static T _enumValue<T extends Enum>(List<T> values, Object? value) {
    if (value is! String) throw const FormatException('Expected enum name');
    return values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw const FormatException('Unknown enum value'),
    );
  }

  static void _validateTheme(CustomTheme theme, {bool validateId = true}) {
    final name = theme.name.trim();
    if (name.isEmpty || name != theme.name || name.length > 200) {
      throw const AppFailure(FailureKind.validation);
    }
    if (validateId && !_customId.hasMatch(theme.id)) {
      throw const AppFailure(FailureKind.validation);
    }
    for (final layer in [theme.foundation, theme.surface, theme.accent]) {
      final expectedLength = switch (layer.mode) {
        ThemeLayerMode.solid => layer.colors.length == 1,
        ThemeLayerMode.gradient =>
          layer.colors.length == 2 || layer.colors.length == 3,
      };
      if (!expectedLength ||
          layer.colors.any(
            (color) => color < 0xff000000 || color > 0xffffffff,
          ) ||
          !_percent(layer.tone) ||
          !_percent(layer.intensity) ||
          !_percent(layer.gradientStrength)) {
        throw const AppFailure(FailureKind.validation);
      }
    }
  }

  static bool _percent(double value) =>
      value.isFinite && value >= 0 && value <= 100;

  static final _customId = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
}

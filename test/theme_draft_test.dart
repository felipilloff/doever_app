import 'package:flutter_test/flutter_test.dart';

import 'package:doever/features/theme_studio/application/theme_draft.dart';
import 'package:doever/features/theme_studio/domain/custom_theme.dart';
import 'package:doever/features/theme_studio/domain/theme_presets.dart';

void main() {
  test('coalesced slider updates undo and redo as one session step', () {
    final draft = ThemeDraft(themePresets.first);
    final first = draft.current.copyWith(
      accent: draft.current.accent.copyWith(tone: 55),
    );
    final last = first.copyWith(accent: first.accent.copyWith(tone: 65));

    draft.update(first, coalesce: true);
    draft.update(last, coalesce: true);
    draft.endGesture();

    expect(draft.current, last);
    draft.undo();
    expect(draft.current, themePresets.first);
    expect(draft.canRedo, isTrue);
    draft.redo();
    expect(draft.current, last);
  });

  test('resetLayer restores only that semantic layer and remains undoable', () {
    final baseline = themePresets.first;
    final draft = ThemeDraft(baseline);
    final changed = baseline.copyWith(
      foundation: baseline.foundation.copyWith(tone: 10),
      surface: baseline.surface.copyWith(tone: 20),
      accent: baseline.accent.copyWith(tone: 30),
    );
    draft.update(changed);

    draft.resetLayer(1);

    expect(draft.current.foundation.tone, 10);
    expect(draft.current.surface, baseline.surface);
    expect(draft.current.accent.tone, 30);
    draft.undo();
    expect(draft.current, changed);
    draft.redo();
    expect(draft.current.surface, baseline.surface);
  });

  test('reset restores the full theme as one undoable change', () {
    final baseline = themePresets.first;
    final draft = ThemeDraft(baseline);
    final changed = baseline.copyWith(
      foundation: LayerTheme(colors: const [0xff101820]),
      surface: LayerTheme(colors: const [0xff202830]),
      accent: LayerTheme(colors: const [0xfff2aa4c]),
    );
    draft.update(changed);

    draft.reset();

    expect(draft.current, baseline);
    draft.undo();
    expect(draft.current, changed);
    draft.redo();
    expect(draft.current, baseline);
  });

  test('built-in presets and their color lists stay immutable', () {
    final preset = themePresets.first;
    final originalFoundation = preset.foundation.colors;

    expect(
      () => preset.foundation.colors.add(0xff000000),
      throwsA(isA<UnsupportedError>()),
    );

    final draft = ThemeDraft(preset);
    draft.update(
      preset.copyWith(
        foundation: preset.foundation.copyWith(colors: const [0xff101820]),
      ),
    );

    expect(themePresets.first.foundation.colors, originalFoundation);
    expect(
      themePresets.first.foundation.colors,
      isNot(draft.current.foundation.colors),
    );
  });
}

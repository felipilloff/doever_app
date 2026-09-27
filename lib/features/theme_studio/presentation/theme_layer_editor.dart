import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

import '../../../app/theme/doever_theme.dart';
import '../application/theme_draft.dart';
import '../domain/custom_theme.dart';
import 'hsv_color_picker.dart';

class ThemeLayerEditor extends StatefulWidget {
  const ThemeLayerEditor({
    super.key,
    required this.title,
    required this.description,
    required this.index,
    required this.layer,
    required this.draft,
    required this.onChanged,
    this.recentColors = const [],
  });

  final String title, description;
  final int index;
  final LayerTheme layer;
  final ThemeDraft draft;
  final void Function(LayerTheme layer, {bool coalesce}) onChanged;
  final List<int> recentColors;

  @override
  State<ThemeLayerEditor> createState() => _ThemeLayerEditorState();
}

class _ThemeLayerEditorState extends State<ThemeLayerEditor> {
  int _selectedStop = 0;

  @override
  void didUpdateWidget(ThemeLayerEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedStop >= widget.layer.colors.length) {
      _selectedStop = widget.layer.colors.length - 1;
    }
  }

  void _color(Color value) {
    final colors = widget.layer.colors.toList();
    colors[_selectedStop] = value.toARGB32();
    widget.onChanged(widget.layer.copyWith(colors: colors), coalesce: true);
  }

  String _directionName(ThemeGradientDirection direction) =>
      switch (direction) {
        ThemeGradientDirection.topToBottom => AppLocalizations.of(
          context,
        ).themeTopBottom,
        ThemeGradientDirection.bottomToTop => AppLocalizations.of(
          context,
        ).themeBottomTop,
        ThemeGradientDirection.leftToRight => AppLocalizations.of(
          context,
        ).themeLeftRight,
        ThemeGradientDirection.rightToLeft => AppLocalizations.of(
          context,
        ).themeRightLeft,
        ThemeGradientDirection.topLeftToBottomRight => AppLocalizations.of(
          context,
        ).themeTopLeftBottomRight,
        ThemeGradientDirection.topRightToBottomLeft => AppLocalizations.of(
          context,
        ).themeTopRightBottomLeft,
        ThemeGradientDirection.bottomLeftToTopRight => AppLocalizations.of(
          context,
        ).themeBottomLeftTopRight,
        ThemeGradientDirection.bottomRightToTopLeft => AppLocalizations.of(
          context,
        ).themeBottomRightTopLeft,
      };

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => widget.draft.resetLayer(widget.index),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(AppLocalizations.of(context).themeResetLayer),
                ),
              ],
            ),
            const SizedBox(height: Space.lg),
            SegmentedButton<ThemeLayerMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeLayerMode.solid,
                  label: Text(AppLocalizations.of(context).themeSolid),
                  icon: Icon(Icons.square_rounded),
                ),
                ButtonSegment(
                  value: ThemeLayerMode.gradient,
                  label: Text(AppLocalizations.of(context).themeGradient),
                  icon: Icon(Icons.gradient_rounded),
                ),
              ],
              selected: {layer.mode},
              onSelectionChanged: (value) {
                final mode = value.single;
                var colors = layer.colors;
                if (mode == ThemeLayerMode.solid) {
                  colors = [colors.first];
                } else if (colors.length == 1) {
                  colors = [colors.first, _companion(colors.first)];
                }
                setState(() => _selectedStop = 0);
                widget.onChanged(layer.copyWith(mode: mode, colors: colors));
              },
            ),
            const SizedBox(height: Space.lg),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).themeColors,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                if (layer.mode == ThemeLayerMode.gradient &&
                    layer.colors.length == 2)
                  TextButton.icon(
                    onPressed: () {
                      final colors = [...layer.colors];
                      colors.insert(1, _blend(colors.first, colors.last));
                      widget.onChanged(layer.copyWith(colors: colors));
                      setState(() => _selectedStop = 1);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(AppLocalizations.of(context).themeAddStop),
                  ),
                if (layer.colors.length == 3)
                  TextButton.icon(
                    onPressed: () {
                      final colors = [...layer.colors]..removeAt(_selectedStop);
                      widget.onChanged(layer.copyWith(colors: colors));
                      setState(() => _selectedStop = 0);
                    },
                    icon: const Icon(Icons.remove, size: 18),
                    label: Text(AppLocalizations.of(context).themeRemoveStop),
                  ),
              ],
            ),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                for (var i = 0; i < layer.colors.length; i++) ...[
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: _selectedStop == i,
                      label: AppLocalizations.of(context).themeColorStop(i + 1),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedStop = i),
                        child: AnimatedContainer(
                          duration: Layout.motion,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Color(layer.colors[i]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedStop == i
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                              width: _selectedStop == i ? 3 : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i != layer.colors.length - 1)
                    const SizedBox(width: Space.sm),
                ],
              ],
            ),
            const SizedBox(height: Space.lg),
            HsvColorPicker(
              color: Color(layer.colors[_selectedStop]),
              recentColors: widget.recentColors.map(Color.new).toList(),
              onChanged: _color,
              onChangeEnd: widget.draft.endGesture,
            ),
            if (layer.mode == ThemeLayerMode.gradient) ...[
              const SizedBox(height: Space.lg),
              DropdownButtonFormField<ThemeGradientDirection>(
                key: ValueKey(layer.direction),
                isExpanded: true,
                initialValue: layer.direction,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).themeDirection,
                ),
                items: [
                  for (final direction in ThemeGradientDirection.values)
                    DropdownMenuItem(
                      value: direction,
                      child: Text(_directionName(direction)),
                    ),
                ],
                onChanged: (value) => value == null
                    ? null
                    : widget.onChanged(layer.copyWith(direction: value)),
              ),
            ],
            const SizedBox(height: Space.md),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context).themeAdvanced),
              subtitle: Text(
                AppLocalizations.of(context).themeAdvancedDescription,
              ),
              children: [
                _PercentSlider(
                  sliderKey: 'theme-tone',
                  label: AppLocalizations.of(context).themeTone,
                  value: layer.tone,
                  neutral: 50,
                  onChanged: (value) => widget.onChanged(
                    layer.copyWith(tone: value),
                    coalesce: true,
                  ),
                  onChangeEnd: widget.draft.endGesture,
                ),
                _PercentSlider(
                  sliderKey: 'theme-intensity',
                  label: AppLocalizations.of(context).themeIntensity,
                  value: layer.intensity,
                  onChanged: (value) => widget.onChanged(
                    layer.copyWith(intensity: value),
                    coalesce: true,
                  ),
                  onChangeEnd: widget.draft.endGesture,
                ),
                if (layer.mode == ThemeLayerMode.gradient)
                  _PercentSlider(
                    sliderKey: 'theme-gradient-strength',
                    label: AppLocalizations.of(context).themeGradientStrength,
                    value: layer.gradientStrength,
                    onChanged: (value) => widget.onChanged(
                      layer.copyWith(gradientStrength: value),
                      coalesce: true,
                    ),
                    onChangeEnd: widget.draft.endGesture,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentSlider extends StatelessWidget {
  const _PercentSlider({
    required this.sliderKey,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    this.neutral,
  });
  final String label;
  final String sliderKey;
  final double value;
  final double? neutral;
  final ValueChanged<double> onChanged;
  final VoidCallback onChangeEnd;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(width: 118, child: Text(label)),
      Expanded(
        child: Slider(
          key: ValueKey(sliderKey),
          value: value,
          min: 0,
          max: 100,
          semanticFormatterCallback: (value) =>
              AppLocalizations.of(context).themePercent(label, value.round()),
          divisions: 100,
          label: '${value.round()}%',
          secondaryTrackValue: neutral,
          onChanged: onChanged,
          onChangeEnd: (_) => onChangeEnd(),
        ),
      ),
      SizedBox(
        width: 44,
        child: Text('${value.round()}%', textAlign: TextAlign.end),
      ),
    ],
  );
}

int _companion(int argb) {
  final hsv = HSVColor.fromColor(Color(argb));
  return hsv
      .withHue((hsv.hue + 28) % 360)
      .withValue((hsv.value * .82).clamp(.18, 1))
      .toColor()
      .toARGB32();
}

int _blend(int a, int b) => Color.lerp(Color(a), Color(b), .5)!.toARGB32();

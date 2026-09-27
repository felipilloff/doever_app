import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/doever_theme.dart';

class HsvColorPicker extends StatefulWidget {
  const HsvColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.onChangeEnd,
    this.recentColors = const [],
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final VoidCallback? onChangeEnd;
  final List<Color> recentColors;

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late HSVColor _hsv;
  late final TextEditingController _hex;
  final _hexKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.color);
    _hex = TextEditingController(text: _formatHex(widget.color));
  }

  @override
  void didUpdateWidget(HsvColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color.toARGB32() != widget.color.toARGB32()) {
      _hsv = HSVColor.fromColor(widget.color);
      if (_hex.text.toUpperCase() != _formatHex(widget.color)) {
        final color = widget.color;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || widget.color != color) return;
          _hex.value = TextEditingValue(
            text: _formatHex(color),
            selection: const TextSelection.collapsed(offset: 7),
          );
          _hexKey.currentState?.validate();
        });
      }
    }
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _set(HSVColor hsv, {bool ended = false}) {
    setState(() => _hsv = hsv);
    final color = hsv.toColor().withValues(alpha: 1);
    _hex.text = _formatHex(color);
    widget.onChanged(color);
    if (ended) widget.onChangeEnd?.call();
  }

  void _submitHex(String value) {
    if (!(_hexKey.currentState?.validate() ?? false)) return;
    final digits = value.replaceFirst('#', '');
    _set(
      HSVColor.fromColor(Color(0xff000000 | int.parse(digits, radix: 16))),
      ended: true,
    );
  }

  void _editHex(String value) {
    _hexKey.currentState?.validate();
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) return;
    final color = Color(0xff000000 | int.parse(value.substring(1), radix: 16));
    setState(() => _hsv = HSVColor.fromColor(color));
    widget.onChanged(color);
    widget.onChangeEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                label: 'Saturation and brightness',
                value:
                    '${(_hsv.saturation * 100).round()}%, ${(_hsv.value * 100).round()}%',
                child: SizedBox(
                  height: 160,
                  child: _PickerArea(
                    hsv: _hsv,
                    onChanged: (value) => _set(value),
                    onChangeEnd: widget.onChangeEnd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Space.md),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _hsv.toColor(),
                shape: BoxShape.circle,
                border: Border.all(color: colors.outlineVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Semantics(
          label: 'Hue',
          value: '${_hsv.hue.round()} degrees',
          child: SizedBox(
            height: 28,
            child: _HueBar(
              hue: _hsv.hue,
              onChanged: (hue) => _set(_hsv.withHue(hue)),
              onChangeEnd: widget.onChangeEnd,
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        TextFormField(
          key: _hexKey,
          controller: _hex,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'HEX',
            hintText: '#426B59',
            prefixIcon: Icon(Icons.tag),
          ),
          validator: (value) =>
              RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value ?? '')
              ? null
              : 'Use #RRGGBB',
          onFieldSubmitted: _submitHex,
          onChanged: _editHex,
          onEditingComplete: () => _submitHex(_hex.text),
        ),
        if (widget.recentColors.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Text('Recent colors', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final color in widget.recentColors.take(10))
                Tooltip(
                  message: _formatHex(color),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _set(HSVColor.fromColor(color), ended: true),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outlineVariant),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PickerArea extends StatelessWidget {
  const _PickerArea({
    required this.hsv,
    required this.onChanged,
    this.onChangeEnd,
  });
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  final VoidCallback? onChangeEnd;

  void _update(Offset point, Size size) => onChanged(
    hsv
        .withSaturation((point.dx / size.width).clamp(0, 1))
        .withValue((1 - point.dy / size.height).clamp(0, 1)),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      return Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }
          final key = event.logicalKey;
          final step = HardwareKeyboard.instance.isShiftPressed ? .1 : .01;
          final next = switch (key) {
            LogicalKeyboardKey.arrowLeft => hsv.withSaturation(
              (hsv.saturation - step).clamp(0, 1),
            ),
            LogicalKeyboardKey.arrowRight => hsv.withSaturation(
              (hsv.saturation + step).clamp(0, 1),
            ),
            LogicalKeyboardKey.arrowUp => hsv.withValue(
              (hsv.value + step).clamp(0, 1),
            ),
            LogicalKeyboardKey.arrowDown => hsv.withValue(
              (hsv.value - step).clamp(0, 1),
            ),
            _ => null,
          };
          if (next == null) return KeyEventResult.ignored;
          onChanged(next);
          onChangeEnd?.call();
          return KeyEventResult.handled;
        },
        child: Builder(
          builder: (context) => GestureDetector(
            onTapDown: (event) {
              Focus.of(context).requestFocus();
              _update(event.localPosition, size);
            },
            onTapUp: (_) => onChangeEnd?.call(),
            onPanUpdate: (event) => _update(event.localPosition, size),
            onPanEnd: (_) => onChangeEnd?.call(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _SvPainter(hsv),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SvPainter extends CustomPainter {
  const _SvPainter(this.hsv);
  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor()],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );
    final point = Offset(
      hsv.saturation * size.width,
      (1 - hsv.value) * size.height,
    );
    canvas
      ..drawCircle(point, 7, Paint()..color = Colors.white)
      ..drawCircle(point, 5, Paint()..color = hsv.toColor());
  }

  @override
  bool shouldRepaint(_SvPainter oldDelegate) => oldDelegate.hsv != hsv;
}

class _HueBar extends StatelessWidget {
  const _HueBar({required this.hue, required this.onChanged, this.onChangeEnd});
  final double hue;
  final ValueChanged<double> onChanged;
  final VoidCallback? onChangeEnd;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                for (var i = 0; i <= 6; i++)
                  HSVColor.fromAHSV(1, i * 60, 1, 1).toColor(),
              ],
            ),
          ),
        ),
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          thumbColor: Colors.white,
          trackHeight: 0,
          overlayShape: SliderComponentShape.noOverlay,
        ),
        child: Slider(
          value: hue,
          min: 0,
          max: 360,
          divisions: 360,
          semanticFormatterCallback: (value) => 'Hue ${value.round()} degrees',
          onChanged: onChanged,
          onChangeEnd: (_) => onChangeEnd?.call(),
        ),
      ),
    ],
  );
}

String _formatHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

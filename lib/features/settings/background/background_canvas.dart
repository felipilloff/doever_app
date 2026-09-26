import 'dart:typed_data';

import 'package:flutter/material.dart';

/// The same image treatment is used in the workspace and settings preview.
class BackgroundCanvas extends StatelessWidget {
  const BackgroundCanvas({super.key, required this.image, required this.child});
  final Uint8List? image;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (image == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: Image.memory(
              image!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xff23352f)),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xb8000000),
                  Color(0x59000000),
                  Color(0xb8000000),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

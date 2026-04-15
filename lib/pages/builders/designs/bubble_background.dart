import 'package:flutter/material.dart';

// import for app themes
import 'package:fins/themes/logic/app_themes.dart';

class Bubble extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final double opacity;

  const Bubble({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.bubble.withOpacity(opacity),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GradientWarm extends StatelessWidget {
  const GradientWarm({super.key, required this.child, this.borderRadius});

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE85D04), Color(0xFFF59E0B)],
        ),
      ),
      child: child,
    );
  }
}

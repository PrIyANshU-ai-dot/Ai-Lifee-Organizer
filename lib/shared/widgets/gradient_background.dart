import 'package:flutter/material.dart';

/// Full-screen gradient background matching app theme.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Gradient g = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E1B4B),
                  const Color(0xFF312E81),
                ]
              : [
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE0E7FF),
                  const Color(0xFFEDE9FE),
                ],
        );
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: g),
      child: child,
    );
  }
}

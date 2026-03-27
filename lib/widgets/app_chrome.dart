import 'package:flutter/material.dart';

class AppPalette {
  static const deepTeal = Color(0xFF0D3B3F);
  static const ocean = Color(0xFF1B6B70);
  static const coral = Color(0xFFF08A5D);
  static const sand = Color(0xFFF8F1E9);
  static const card = Color(0xFFFDF7F2);
}

class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF5EA), Color(0xFFE6F5F7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: _Blob(
              color: AppPalette.coral.withValues(alpha: 0.17),
              size: 220,
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _Blob(
              color: AppPalette.ocean.withValues(alpha: 0.16),
              size: 250,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

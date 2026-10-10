import 'package:flutter/material.dart';

import '../constants/app_config.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.25,
  });

  final Widget child;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppConfig.backgroundAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF132B25), Color(0xFF0A1513)],
              ),
            ),
          ),
        ),
        // Subtle dark gradient vignette for readable text and button
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: overlayOpacity),
                Colors.black.withValues(alpha: 0.60),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
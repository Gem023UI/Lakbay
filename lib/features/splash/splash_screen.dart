import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: Curves.easeIn,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  ));

  Timer? _autoNavTimer;

  @override
  void initState() {
    super.initState();
    // Auto-proceed after 2.6 seconds or tap anywhere to proceed instantly
    _autoNavTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) _goToNext();
    });
  }

  void _goToNext() {
    _autoNavTimer?.cancel();
    context.go('/country');
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fullscreen Wallpaper Image
            Image.asset(
              AppConfig.backgroundAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F261C)),
            ),

            // 2. Subtle Dark Vignette Overlay (exactly matching the user photo)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000), // Soft darkness at the top
                    Color(0x55000000), // Mid tone
                    Color(0x88000000), // Center area
                    Color(0xCC000000), // Deeper contrast near bottom
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),

            // 3. Centered Content: LAKBAY. and Subtitle
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "LAKBAY." with exact Playfair serif and period
                          Text(
                            'LAKBAY.',
                            textAlign: TextAlign.center,
                            style: AppTheme.serif(
                              64,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // "Offline AI-Powered Travel Companion for ASEAN Travelers"
                          const Text(
                            'Offline AI-Powered Travel Companion\nfor ASEAN Travelers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 1.35,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
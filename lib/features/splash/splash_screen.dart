import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final Animation<double> _title = _interval(0.0, 0.4);
  late final Animation<double> _subtitle = _interval(0.25, 0.65);
  late final Animation<double> _button = _interval(0.8, 1.0);

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  Widget _reveal(Animation<double> a, Widget child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
              .animate(a),
          child: child,
        ),
      );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        overlayOpacity: 0.55,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),
                _reveal(
                  _title,
                  Text(
                    AppConfig.appTitle,
                    style: AppTheme.serif(56, letterSpacing: 4, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                _reveal(
                  _subtitle,
                  Text(
                    AppConfig.tagline,
                    textAlign: TextAlign.center,
                    style: AppTheme.serif(18,
                        weight: FontWeight.w400, color: Colors.white70),
                  ),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, child) =>
                      IgnorePointer(ignoring: _c.value < 0.85, child: child),
                  child: FadeTransition(
                    opacity: _button,
                    child: SizedBox(
                      width: 220,
                      child: AppButton(
                        label: 'Proceed',
                        icon: Icons.arrow_forward,
                        onTap: () => context.go('/country'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
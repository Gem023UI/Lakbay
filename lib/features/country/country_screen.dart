import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/flag_card.dart';
import '../../providers/providers.dart';

class CountryScreen extends ConsumerStatefulWidget {
  const CountryScreen({super.key});

  @override
  ConsumerState<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends ConsumerState<CountryScreen> {
  static const _countries = AppConfig.countries;
  static final _base = _countries.length * 1000;

  late final int _startIndex;
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    final current = ref.read(selectedCountryProvider);
    _startIndex = _countries.indexOf(current).clamp(0, _countries.length - 1);
    _index = _startIndex;
    _controller = PageController(
      viewportFraction: 0.65,
      initialPage: _base + _startIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _currentPage() {
    if (_controller.hasClients && _controller.position.hasPixels) {
      return _controller.page ?? _controller.initialPage.toDouble();
    }
    return _controller.initialPage.toDouble();
  }

  String _getCountryBgImage(String code) {
    switch (code.toUpperCase()) {
      case 'TH':
        return 'assets/images/countries/thailand/place/bangkok.png';
      case 'VN':
        return 'assets/images/countries/vietnam/place/halong.png';
      case 'PH':
        return 'assets/images/countries/philippines/place/palawan.png';
      case 'ID':
      default:
        return 'assets/images/countries/indonesia/place/borobudur.png';
    }
  }

  void _confirm() {
    ref.read(selectedCountryProvider.notifier).select(_countries[_index]);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final country = _countries[_index];
    final bgImage = _getCountryBgImage(country.code);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic Background Image with Smooth CrossFade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Image.asset(
              bgImage,
              key: ValueKey(bgImage),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF0F382A),
              ),
            ),
          ),

          // 2. Scenic Lighting Gradient Overlay (Ensures text & cards pop cleanly)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE60A2016), // Dark evergreen at top
                  Color(0x99000000), // Mid translucent
                  Color(0x77000000), // Flag focus zone
                  Color(0xCC081A12), // Deep tint for country details
                  Color(0xF504100B), // Solid dark footer
                ],
                stops: [0.0, 0.28, 0.55, 0.78, 1.0],
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Top Header Text
                Text(
                  'Where are you headed?',
                  style: AppTheme.serif(
                    27,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'SELECT YOUR DESTINATION',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                    color: Color(0xFFCFE0D5),
                  ),
                ),

                // Center Flags Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) =>
                        setState(() => _index = i % _countries.length),
                    itemBuilder: (context, i) {
                      final c = _countries[i % _countries.length];
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final diff = (_currentPage() - i).abs();
                          final scale = (1 - diff * 0.22).clamp(0.75, 1.0);
                          final opacity = (1 - diff * 0.45).clamp(0.45, 1.0);
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(opacity: opacity, child: child),
                              ),
                            ),
                          );
                        },
                        child: FlagCard(asset: c.flagAsset),
                      );
                    },
                  ),
                ),

                // Country Name & Language
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(country.code),
                    children: [
                      Text(
                        country.name,
                        style: AppTheme.serif(
                          34,
                          color: Colors.white,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        country.languageName,
                        style: const TextStyle(
                          color: Color(0xFFD6E8DC),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF144D37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(
                            color: Color(0x556DA27D),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 6,
                        shadowColor: Colors.black54,
                      ),
                      icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: _confirm,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
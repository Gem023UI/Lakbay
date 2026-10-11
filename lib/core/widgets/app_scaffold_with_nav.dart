import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/translate/presentation/translate_flow.dart';

class AppScaffoldWithNav extends ConsumerWidget {
  final Widget child;

  const AppScaffoldWithNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/phrasebook') || location.startsWith('/tts')) return 2;
    if (location.startsWith('/toolkit')) return 3;
    if (location.startsWith('/currency')) return 0; // opened from home currency card
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFBFBF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Home
                _NavButton(
                  icon: Icons.home_filled,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    if (selectedIndex != 0) context.go('/home');
                  },
                ),

                // 2. Scan (Instant Camera OCR)
                _NavButton(
                  icon: Icons.crop_free_rounded,
                  label: 'Scan',
                  isSelected: false,
                  onTap: () {
                    startImageFlow(context, ref, ImageSource.camera);
                  },
                ),

                // 3. Phrasebook
                _NavButton(
                  icon: Icons.menu_book_outlined,
                  label: 'Phrasebook',
                  isSelected: selectedIndex == 2,
                  onTap: () {
                    if (selectedIndex != 2) context.go('/phrasebook');
                  },
                ),

                // 4. Toolkit
                _NavButton(
                  icon: Icons.work_outline_rounded,
                  label: 'Toolkit',
                  isSelected: selectedIndex == 3,
                  onTap: () {
                    if (selectedIndex != 3) context.go('/toolkit');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0F382A);
    const inactiveColor = Color(0xFF86968B);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25,
            color: isSelected ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 24 : 0,
            height: 2.2,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

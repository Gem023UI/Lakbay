import 'package:flutter/material.dart';

class FlagCard extends StatelessWidget {
  const FlagCard({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x22FFFFFF),
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1E3A2F),
              alignment: Alignment.center,
              child: const Icon(Icons.flag_rounded, size: 48, color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
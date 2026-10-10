import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../domain/translation_controller.dart';
import 'translate_flow.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(translationControllerProvider);
    final result = s.result;

    return Scaffold(
      backgroundColor: AppTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Sleek, Low-Profile Header (Not tall!)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF1E8),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.forestGreen,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Translation',
                    style: AppTheme.serif(19, color: AppTheme.forestGreen),
                  ),
                  const Spacer(),
                  if (result != null)
                    GestureDetector(
                      onTap: s.busy
                          ? null
                          : () => ref
                              .read(translationControllerProvider.notifier)
                              .swapLanguages(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSage,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFC8D6C0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${languageLabel(result.source)} ⇄ ${languageLabel(result.target)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.forestGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 15,
                              color: AppTheme.forestGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Main Content
            Expanded(
              child: _content(context, ref, s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, TranslationState s) {
    final result = s.result;

    if (result == null) {
      if (s.busy) {
        return const _Message(
          text: 'Reading and translating image text...',
          busy: true,
        );
      }
      return _Message(
        icon: Icons.search_off_rounded,
        text: s.error ?? 'No readable text was detected.',
        action: Column(
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Type or Paste Text', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () {
                context.pop();
                startTextFlow(context, ref);
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Home', style: TextStyle(color: Color(0xFF4C6154))),
            ),
          ],
        ),
      );
    }

    final canToggle = result.source != TranslateLanguage.tagalog;
    final tts = ref.watch(ttsServiceProvider);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        if (s.busy)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(color: AppTheme.forestGreen),
          ),

        // Photo Preview (Compact & Clean)
        if (result.imagePath != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E7DA)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(result.imagePath!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

        // Detected Text Strip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E7DA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4D7C5F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'DETECTED (${languageLabel(result.source).toUpperCase()})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Color(0xFF6E8276),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: s.busy
                        ? null
                        : () async {
                            final controller = TextEditingController(text: result.recognized);
                            final edited = await showDialog<String>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFFFBFBF8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                title: Text(
                                  'Edit Recognized Text',
                                  style: AppTheme.serif(18, color: AppTheme.forestGreen),
                                ),
                                content: TextField(
                                  controller: controller,
                                  maxLines: 4,
                                  style: const TextStyle(
                                    color: AppTheme.forestGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    hintText: 'Edit text...',
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E8276))),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.forestGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                    child: const Text('Retranslate'),
                                  ),
                                ],
                              ),
                            );
                            if (edited != null && edited.isNotEmpty && context.mounted) {
                              ref
                                  .read(translationControllerProvider.notifier)
                                  .updateTextAndRetranslate(edited);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF1E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 13, color: AppTheme.forestGreen),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                result.recognized,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2A3F35),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Language Target Selector (if available)
        if (canToggle)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'TRANSLATE TO: ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Color(0xFF6E8276),
                  ),
                ),
                const SizedBox(width: 8),
                _LanguagePill(
                  label: 'English',
                  isSelected: result.target == TranslateLanguage.english,
                  onTap: s.busy ? null : () => switchTarget(context, ref, TranslateLanguage.english),
                ),
                const SizedBox(width: 8),
                _LanguagePill(
                  label: 'Tagalog',
                  isSelected: result.target == TranslateLanguage.tagalog,
                  onTap: s.busy ? null : () => switchTarget(context, ref, TranslateLanguage.tagalog),
                ),
              ],
            ),
          ),

        // Hero Translation Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E7DA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRANSLATION (${languageLabel(result.target).toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Color(0xFF6E8276),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 2.2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D7C5F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SelectableText(
                result.translated,
                style: AppTheme.serif(
                  23,
                  color: AppTheme.forestGreen,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),

              // Action Toolbar: Audio Speak & Copy
              Row(
                children: [
                  // Audio TTS
                  GestureDetector(
                    onTap: () {
                      final langCode = result.target == TranslateLanguage.tagalog ? 'tl' : 'en';
                      tts.speak(result.translated, languageCode: langCode);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDDE6D5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded, size: 16, color: AppTheme.forestGreen),
                          SizedBox(width: 6),
                          Text(
                            'Listen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Copy Translation
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: result.translated));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied translation to clipboard'),
                          backgroundColor: AppTheme.forestGreen,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDDE6D5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 15, color: AppTheme.forestGreen),
                          SizedBox(width: 6),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (s.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              s.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),

        const SizedBox(height: 16),

        // Subtle, Non-Intrusive Traveler Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE5B4)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFD9822B), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Traveler note: Double-check food allergens, medical doses, and transport signs before acting on critical decisions.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7A5826),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguagePill({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.forestGreen : const Color(0xFFEBF1E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.forestGreen : const Color(0xFFD4DEC8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4C6154),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    this.icon,
    this.busy = false,
    this.action,
  });

  final String text;
  final IconData? icon;
  final bool busy;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) const CircularProgressIndicator(color: AppTheme.forestGreen),
            if (icon != null) Icon(icon, size: 48, color: const Color(0xFF86968B)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF35473D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
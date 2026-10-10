import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_config.dart';
import '../../../providers/providers.dart';
import '../domain/translation_controller.dart';
import 'adjust_photo_screen.dart';

final _picker = ImagePicker();

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Scan (camera) / Pick Picture (gallery) entry point.
Future<void> startImageFlow(
  BuildContext context,
  WidgetRef ref,
  ImageSource source,
) async {
  final country = ref.read(selectedCountryProvider);

  if (!country.ocrSupported) {
    await startTextFlow(context, ref, country);
    return;
  }

  XFile? picked;
  try {
    picked = await _picker.pickImage(source: source, maxWidth: 2560);
  } catch (e) {
    if (context.mounted) {
      final where = source == ImageSource.camera ? 'the camera' : 'the gallery';
      _snack(context, 'Could not open $where: $e');
    }
    return;
  }
  if (picked == null || !context.mounted) return;
  final pickedPath = picked.path;

  // Let the user crop and highlight the exact text to translate using custom AdjustPhotoScreen
  final croppedPath = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (_) => AdjustPhotoScreen(imagePath: pickedPath),
    ),
  );

  if (croppedPath == null || !context.mounted) return;
  final imagePathToUse = croppedPath;

  if (!context.mounted) return;

  final target = ref.read(targetLanguageProvider);
  if (!await _ensureModels(context, ref, country.language, target)) return;
  if (!context.mounted) return;

  final job = ref
      .read(translationControllerProvider.notifier)
      .fromImage(imagePathToUse, country.language, target);
  context.push('/result');
  await job;
}

Future<void> startTextFlow(
  BuildContext context,
  WidgetRef ref, [
  Country? country,
]) async {
  final Country activeCountry = country ?? ref.read(selectedCountryProvider);
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(languageName: activeCountry.languageName),
  );
  if (text == null || text.isEmpty || !context.mounted) return;

  final target = ref.read(targetLanguageProvider);
  if (!await _ensureModels(context, ref, activeCountry.language, target)) return;
  if (!context.mounted) return;

  final job = ref
      .read(translationControllerProvider.notifier)
      .fromText(text, activeCountry.language, target);
  context.push('/result');
  await job;
}

/// Called from the result screen when the user toggles English/Tagalog.
Future<void> switchTarget(
  BuildContext context,
  WidgetRef ref,
  TranslateLanguage requested,
) async {
  final result = ref.read(translationControllerProvider).result;
  if (result == null) return;
  if (!await _ensureModels(context, ref, result.source, requested)) return;
  if (!context.mounted) return;

  ref.read(targetLanguageProvider.notifier).select(requested);
  await ref.read(translationControllerProvider.notifier).retranslate(requested);
}

/// Returns true when every needed model is on the device
/// (downloading them first if the user agrees and is online).
Future<bool> _ensureModels(
  BuildContext context,
  WidgetRef ref,
  TranslateLanguage source,
  TranslateLanguage requestedTarget,
) async {
  final controller = ref.read(translationControllerProvider.notifier);
  final missing = await controller.missingModels(source, requestedTarget);
  if (missing.isEmpty) return true;
  if (!context.mounted) return false;

  final names = missing.map(languageLabel).join(', ');
  final results = await Connectivity().checkConnectivity();
  final online = !results.contains(ConnectivityResult.none);
  if (!context.mounted) return false;

  if (!online) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Language packs needed'),
        content: Text(
          'Connect to the internet once to download: $names. '
          'After that, translation works offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  }

  final agreed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Download language packs?'),
      content: Text(
        '$names. Each pack is roughly 30 MB and is stored on your device '
        'so translation works offline.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Download'),
        ),
      ],
    ),
  );
  if (agreed != true || !context.mounted) return false;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Downloading language packs...')),
          ],
        ),
      ),
    ),
  );

  String? error;
  try {
    await controller.downloadModels(missing);
  } catch (e) {
    error = '$e';
  }
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
    if (error != null) _snack(context, 'Download failed: $error');
  }
  return error == null;
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.languageName});

  final String languageName;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFBFBF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "${widget.languageName} Image Scanning",
        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F382A)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline OCR is being optimized. You can type or paste text to translate immediately:',
            style: TextStyle(fontSize: 13, color: Color(0xFF35473D)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(color: Color(0xFF0F382A), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Type or paste ${widget.languageName} text...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E8276))),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F382A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Translate'),
        ),
      ],
    );
  }
}
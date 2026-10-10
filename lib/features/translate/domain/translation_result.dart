import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationResult {
  const TranslationResult({
    required this.recognized,
    required this.translated,
    required this.source,
    required this.target,
    this.imagePath,
  });

  final String? imagePath;
  final String recognized;
  final String translated;
  final TranslateLanguage source;
  final TranslateLanguage target;
}
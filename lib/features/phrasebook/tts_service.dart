import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(0.45); // Comfortable speaking rate
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _initialized = true;
  }

  /// Maps language codes to TTS locales (e.g. 'th' -> 'th-TH', 'tl' -> 'fil-PH', 'en' -> 'en-US')
  String getTtsLocale(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'th':
      case 'thai':
        return 'th-TH';
      case 'tl':
      case 'tagalog':
      case 'fil':
        return 'fil-PH';
      case 'id':
      case 'indonesian':
        return 'id-ID';
      case 'vi':
      case 'vietnamese':
        return 'vi-VN';
      default:
        return 'en-US';
    }
  }

  Future<void> speak(String text, {required String languageCode}) async {
    if (text.trim().isEmpty) return;
    await _ensureInit();
    final locale = getTtsLocale(languageCode);
    await _flutterTts.setLanguage(locale);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract class TranslationService {
  Future<String> translate(
    String text, {
    required TranslateLanguage from,
    required TranslateLanguage to,
  });
}

class MlKitTranslationService implements TranslationService {
  @override
  Future<String> translate(
    String text, {
    required TranslateLanguage from,
    required TranslateLanguage to,
  }) async {
    final translator = OnDeviceTranslator(
      sourceLanguage: from,
      targetLanguage: to,
    );
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  }
}
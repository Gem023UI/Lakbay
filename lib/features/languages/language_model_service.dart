import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageModelService {
  final _manager = OnDeviceTranslatorModelManager();

  Future<bool> isReady(TranslateLanguage lang) =>
      _manager.isModelDownloaded(lang.bcpCode);

  Future<bool> download(TranslateLanguage lang, {bool wifiOnly = false}) =>
      _manager.downloadModel(lang.bcpCode, isWifiRequired: wifiOnly);

  Future<bool> delete(TranslateLanguage lang) =>
      _manager.deleteModel(lang.bcpCode);

  Future<List<TranslateLanguage>> missing(Iterable<TranslateLanguage> languages) async {
    final list = <TranslateLanguage>[];
    for (final lang in languages) {
      if (!await isReady(lang)) {
        list.add(lang);
      }
    }
    return list;
  }
}

// Riverpod wiring for services and repositories

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../core/constants/app_config.dart';
import '../data/repositories/exchange_rate_repository.dart';
import '../features/currency/currency_service.dart';
import '../features/languages/language_model_service.dart';
import '../features/phrasebook/phrasebook_service.dart';
import '../features/phrasebook/tts_service.dart';
import '../features/toolkit/toolkit_data.dart';
import '../features/translate/data/ocr_service.dart';
import '../features/translate/data/translation_service.dart';

class SelectedCountryNotifier extends Notifier<Country> {
  @override
  Country build() => AppConfig.defaultCountry;

  void select(Country country) => state = country;
}

final selectedCountryProvider =
    NotifierProvider<SelectedCountryNotifier, Country>(
        SelectedCountryNotifier.new);

/// Requested output language (English or Tagalog).
class TargetLanguageNotifier extends Notifier<TranslateLanguage> {
  @override
  TranslateLanguage build() => TranslateLanguage.english;

  void select(TranslateLanguage language) => state = language;
}

final targetLanguageProvider =
    NotifierProvider<TargetLanguageNotifier, TranslateLanguage>(
        TargetLanguageNotifier.new);

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(service.dispose);
  return service;
});

final translationServiceProvider =
    Provider<TranslationService>((ref) => MlKitTranslationService());

final languageModelServiceProvider =
    Provider<LanguageModelService>((ref) => LanguageModelService());

final exchangeRateRepositoryProvider =
    Provider<ExchangeRateRepository>((ref) => ExchangeRateRepository());

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final repo = ref.watch(exchangeRateRepositoryProvider);
  return CurrencyService(repo);
});

final exchangeRateBundleFutureProvider =
    FutureProvider<ExchangeRateBundle>((ref) {
  final service = ref.watch(currencyServiceProvider);
  return service.loadRates();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

final phrasebookServiceProvider = Provider<PhrasebookService>((ref) {
  return PhrasebookService();
});

final toolkitDataServiceProvider = Provider<ToolkitDataService>((ref) {
  return ToolkitDataService();
});

final countryPhrasesFutureProvider = FutureProvider<List<PhraseItem>>((ref) {
  final country = ref.watch(selectedCountryProvider);
  final service = ref.watch(phrasebookServiceProvider);
  return service.loadPhrases(countryCode: country.code);
});

final countryToolkitFutureProvider = FutureProvider<CountryToolkit>((ref) {
  final country = ref.watch(selectedCountryProvider);
  final service = ref.watch(toolkitDataServiceProvider);
  return service.getToolkit(country.code);
});
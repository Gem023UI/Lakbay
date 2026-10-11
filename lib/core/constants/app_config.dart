import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class Country {
  const Country({
    required this.code,
    required this.name,
    required this.flagAsset,
    required this.language,
    required this.languageName,
    required this.ocrSupported,
    required this.currencyCode,
    required this.currencySymbol,
  });

  final String code;
  final String name;
  final String flagAsset;
  final TranslateLanguage language;
  final String languageName;

  /// ML Kit OCR supports Latin script only here. Thai is not supported.
  final bool ocrSupported;
  final String currencyCode;
  final String currencySymbol;
}

class AppConfig {
  AppConfig._();

  static const appTitle = 'LAKBAY.';
  static const tagline = 'Offline AI-Powered Travel Companion\nfor ASEAN Travelers';
  static const backgroundAsset = 'assets/images/LAKBAY..png';

  static const philippines = Country(
    code: 'PH',
    name: 'Philippines',
    flagAsset: 'assets/images/flags/philippines.png',
    language: TranslateLanguage.tagalog,
    languageName: 'Tagalog',
    ocrSupported: true,
    currencyCode: 'PHP',
    currencySymbol: '₱',
  );
  static const indonesia = Country(
    code: 'ID',
    name: 'Indonesia',
    flagAsset: 'assets/images/flags/indonesia.png',
    language: TranslateLanguage.indonesian,
    languageName: 'Indonesian',
    ocrSupported: true,
    currencyCode: 'IDR',
    currencySymbol: 'Rp',
  );
  static const vietnam = Country(
    code: 'VN',
    name: 'Vietnam',
    flagAsset: 'assets/images/flags/vietnam.png',
    language: TranslateLanguage.vietnamese,
    languageName: 'Vietnamese',
    ocrSupported: true,
    currencyCode: 'VND',
    currencySymbol: '₫',
  );
  static const thailand = Country(
    code: 'TH',
    name: 'Thailand',
    flagAsset: 'assets/images/flags/thailand.png',
    language: TranslateLanguage.thai,
    languageName: 'Thai',
    ocrSupported: true,
    currencyCode: 'THB',
    currencySymbol: '฿',
  );

  static const countries = <Country>[indonesia, vietnam, thailand];
  static const defaultCountry = indonesia;
}

String languageLabel(TranslateLanguage l) =>
    l.name[0].toUpperCase() + l.name.substring(1);
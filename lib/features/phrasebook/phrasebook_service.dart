import 'dart:convert';
import 'package:flutter/services.dart';

class PhraseItem {
  final String category;
  final String english;
  final String foreign;
  final String phonetic;
  final String countryCode;

  const PhraseItem({
    required this.category,
    required this.english,
    required this.foreign,
    required this.phonetic,
    required this.countryCode,
  });

  factory PhraseItem.fromJson(Map<String, dynamic> json) {
    return PhraseItem(
      category: json['category'] as String? ?? 'General',
      english: json['english'] as String? ?? '',
      foreign: json['foreign'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
  }
}

class PhrasebookService {
  List<PhraseItem>? _cachedPhrases;

  Future<List<PhraseItem>> loadPhrases({String? countryCode}) async {
    if (_cachedPhrases == null) {
      final jsonStr = await rootBundle.loadString('assets/data/phrasebook.json');
      final list = json.decode(jsonStr) as List<dynamic>;
      _cachedPhrases = list
          .map((item) => PhraseItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (countryCode != null && countryCode.isNotEmpty) {
      return _cachedPhrases!
          .where((p) => p.countryCode.toUpperCase() == countryCode.toUpperCase())
          .toList();
    }
    return _cachedPhrases!;
  }
}

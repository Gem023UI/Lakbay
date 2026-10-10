import 'dart:convert';
import 'package:flutter/services.dart';

class ExchangeRateBundle {
  final String base;
  final String lastUpdated;
  final Map<String, double> rates; // Base is PHP (e.g. THB: 0.60)
  final Map<String, Map<String, String>> currencies;

  const ExchangeRateBundle({
    required this.base,
    required this.lastUpdated,
    required this.rates,
    required this.currencies,
  });

  factory ExchangeRateBundle.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = rawRates.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    final rawCurrencies = json['currencies'] as Map<String, dynamic>? ?? {};
    final parsedCurrencies = rawCurrencies.map(
      (k, v) => MapEntry(
        k,
        (v as Map<String, dynamic>).map((ik, iv) => MapEntry(ik, iv.toString())),
      ),
    );

    return ExchangeRateBundle(
      base: json['base'] as String? ?? 'PHP',
      lastUpdated: json['last_updated'] as String? ?? '',
      rates: parsedRates,
      currencies: parsedCurrencies,
    );
  }
}

class ExchangeRateRepository {
  ExchangeRateBundle? _cachedBundle;

  Future<ExchangeRateBundle> getRates() async {
    if (_cachedBundle != null) {
      return _cachedBundle!;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/currencies.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      _cachedBundle = ExchangeRateBundle.fromJson(data);
      return _cachedBundle!;
    } catch (e) {
      // Fallback hardcoded defaults if asset loading fails
      _cachedBundle = const ExchangeRateBundle(
        base: 'PHP',
        lastUpdated: 'Offline default',
        rates: {
          'THB': 0.60,
          'PHP': 1.00,
          'IDR': 274.50,
          'VND': 435.00,
        },
        currencies: {
          'THB': {'name': 'Thai Baht', 'symbol': '฿', 'country': 'Thailand'},
          'PHP': {'name': 'Philippine Peso', 'symbol': '₱', 'country': 'Philippines'},
        },
      );
      return _cachedBundle!;
    }
  }
}

import '../../data/repositories/exchange_rate_repository.dart';

enum ConversionDirection {
  foreignToPhp, // e.g. THB -> PHP
  phpToForeign, // e.g. PHP -> THB
}

class CurrencyService {
  final ExchangeRateRepository _repository;

  CurrencyService(this._repository);

  Future<ExchangeRateBundle> loadRates() => _repository.getRates();

  /// Given [foreignCode] (e.g. 'THB') where 1 PHP = [rate] in foreign currency:
  /// - 1 PHP = 0.60 THB  =>  1 THB = (1 / 0.60) ≈ 1.6667 PHP
  double convert({
    required double amount,
    required String foreignCode,
    required ConversionDirection direction,
    required Map<String, double> rates,
  }) {
    final rate = rates[foreignCode] ?? 1.0;
    if (rate <= 0) return 0;

    switch (direction) {
      case ConversionDirection.foreignToPhp:
        // Foreign currency to PHP
        return amount / rate;
      case ConversionDirection.phpToForeign:
        // PHP to foreign currency
        return amount * rate;
    }
  }

  /// Returns text description of rate, e.g. "1 THB ≈ 1.67 PHP"
  String getRateDescription({
    required String foreignCode,
    required Map<String, double> rates,
    String foreignSymbol = '',
  }) {
    final rate = rates[foreignCode] ?? 1.0;
    if (rate <= 0) return '';
    final phpEquivalent = 1.0 / rate;
    return '1 $foreignSymbol$foreignCode ≈ ₱${phpEquivalent.toStringAsFixed(2)} PHP';
  }
}

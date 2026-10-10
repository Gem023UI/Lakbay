import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'currency_service.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final _amountController = TextEditingController(text: '100');
  ConversionDirection _direction = ConversionDirection.foreignToPhp;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapDirection() {
    setState(() {
      _direction = _direction == ConversionDirection.foreignToPhp
          ? ConversionDirection.phpToForeign
          : ConversionDirection.foreignToPhp;
    });
  }

  void _setPreset(double val) {
    setState(() {
      _amountController.text = val.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(selectedCountryProvider);
    final service = ref.watch(currencyServiceProvider);
    final bundleAsync = ref.watch(exchangeRateBundleFutureProvider);

    final foreignCode = country.currencyCode;
    final foreignSymbol = country.currencySymbol;

    return Scaffold(
      backgroundColor: AppTheme.softBg,
      body: SafeArea(
        child: bundleAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.forestGreen),
          ),
          error: (err, _) => Center(
            child: Text(
              'Could not load currency rates: $err',
              style: const TextStyle(color: AppTheme.charcoal),
            ),
          ),
          data: (bundle) {
            final double inputVal =
                double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

            final double convertedVal = service.convert(
              amount: inputVal,
              foreignCode: foreignCode,
              direction: _direction,
              rates: bundle.rates,
            );

            final rateDescription = service.getRateDescription(
              foreignCode: foreignCode,
              rates: bundle.rates,
              foreignSymbol: foreignSymbol,
            );

            final isForeignToPhp =
                _direction == ConversionDirection.foreignToPhp;
            final sourceCode = isForeignToPhp ? foreignCode : 'PHP';
            final sourceSymbol = isForeignToPhp ? foreignSymbol : '₱';
            final targetCode = isForeignToPhp ? 'PHP' : foreignCode;
            final targetSymbol = isForeignToPhp ? '₱' : foreignSymbol;

            return Column(
              children: [
                // 1. Top App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF1E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.forestGreen,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currency Exchange',
                              style: AppTheme.serif(21, color: AppTheme.forestGreen),
                            ),
                            Text(
                              '${country.name.toUpperCase()} ⇄ PHILIPPINES',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: Color(0xFF6E8276),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSage,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC8D6C0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.offline_pin_rounded, color: AppTheme.forestGreen, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Offline Ready',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.forestGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main Content
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      // Rate Banner Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4EB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E7DA)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDDE6D5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.currency_exchange_rounded,
                                color: AppTheme.forestGreen,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rateDescription,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.forestGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Preloaded rates for ${country.name} travel',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF5A7264),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Input Card (From)
                      _CurrencyCard(
                        label: 'YOU SEND ($sourceCode)',
                        symbol: sourceSymbol,
                        currencyName: isForeignToPhp ? country.name : 'Philippines',
                        isInput: true,
                        controller: _amountController,
                        onChanged: (_) => setState(() {}),
                        backgroundColor: Colors.white,
                      ),

                      // Swap Direction Button
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: GestureDetector(
                            onTap: _swapDirection,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.forestGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.forestGreen.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.swap_vert_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Result Card (To)
                      _CurrencyCard(
                        label: 'YOU RECEIVE ($targetCode)',
                        symbol: targetSymbol,
                        currencyName: isForeignToPhp ? 'Philippines' : country.name,
                        isInput: false,
                        displayValue: convertedVal.toStringAsFixed(2),
                        backgroundColor: AppTheme.creamCard,
                      ),

                      const SizedBox(height: 24),

                      // Quick presets chips
                      const Text(
                        'QUICK AMOUNTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: Color(0xFF5A7264),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [20.0, 50.0, 100.0, 500.0, 1000.0, 2000.0].map((preset) {
                          return GestureDetector(
                            onTap: () => _setPreset(preset),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF1E8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFD4DEC8)),
                              ),
                              child: Text(
                                '$sourceSymbol${preset.toInt()}',
                                style: const TextStyle(
                                  color: AppTheme.forestGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Travel Math Tip
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9EE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFE5B4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD9822B), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isForeignToPhp
                                    ? 'Quick traveler tip: Multiply ${country.name} currency by the rate shown above to estimate your total budget in Philippine Pesos.'
                                    : 'Quick traveler tip: Divide Philippine Pesos by the rate shown above to calculate what you can spend in ${country.name}.',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF7A5826),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String label;
  final String symbol;
  final String currencyName;
  final bool isInput;
  final TextEditingController? controller;
  final String? displayValue;
  final ValueChanged<String>? onChanged;
  final Color backgroundColor;

  const _CurrencyCard({
    required this.label,
    required this.symbol,
    required this.currencyName,
    required this.isInput,
    this.controller,
    this.displayValue,
    this.onChanged,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E7DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Color(0xFF6E8276),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF1E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currencyName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isInput
                    ? TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: onChanged,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.forestGreen,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Color(0xFFB5C3B8)),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        displayValue ?? '0.00',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.forestGreen,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


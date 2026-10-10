import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'phrasebook_service.dart';

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends ConsumerState<PhrasebookScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Greetings',
    'Dining',
    'Shopping',
    'Directions',
    'Transportation',
    'Emergency',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(selectedCountryProvider);
    final phrasesAsync = ref.watch(countryPhrasesFutureProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                          '${country.name} Phrasebook',
                          style: AppTheme.serif(21, color: AppTheme.forestGreen),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'OFFLINE AUDIO PRONUNCIATION',
                          style: TextStyle(
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
                        Icon(Icons.volume_up_rounded, color: AppTheme.forestGreen, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Offline TTS',
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

            // 2. Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E6DA)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: AppTheme.forestGreen, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search phrases or English words...',
                    hintStyle: const TextStyle(color: Color(0xFF86968B), fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4D7C5F)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF6E8276)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
              ),
            ),

            // 3. Category Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.forestGreen : const Color(0xFFEBF1E8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.forestGreen : const Color(0xFFD4DEC8),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.forestGreen.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF4C6154),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // 4. Phrases List
            Expanded(
              child: phrasesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.forestGreen),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading phrases: $err',
                    style: const TextStyle(color: AppTheme.charcoal),
                  ),
                ),
                data: (phrases) {
                  final filtered = phrases.where((p) {
                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category.toLowerCase() == _selectedCategory.toLowerCase();
                    final matchesQuery = _searchQuery.isEmpty ||
                        p.english.toLowerCase().contains(_searchQuery) ||
                        p.foreign.toLowerCase().contains(_searchQuery) ||
                        p.phonetic.toLowerCase().contains(_searchQuery);
                    return matchesCategory && matchesQuery;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, color: Color(0xFFB5C3B8), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No phrases found for "$_selectedCategory"',
                            style: const TextStyle(color: Color(0xFF6E8276)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final p = filtered[idx];
                      return _PhraseCard(
                        phrase: p,
                        countryCode: country.code,
                        onSpeak: () => tts.speak(p.foreign, languageCode: country.code),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final PhraseItem phrase;
  final String countryCode;
  final VoidCallback onSpeak;

  const _PhraseCard({
    required this.phrase,
    required this.countryCode,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7DA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF1E8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        phrase.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Color(0xFF4C6154),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phrase.english,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  phrase.foreign,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF144D37),
                    height: 1.25,
                  ),
                ),
                if (phrase.phonetic.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Pronunciation: "${phrase.phonetic}"',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF5A7264),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSpeak,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEBF1E8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4DEC8)),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.forestGreen,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

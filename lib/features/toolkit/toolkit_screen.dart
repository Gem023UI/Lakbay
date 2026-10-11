import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'toolkit_data.dart';

class ToolkitScreen extends ConsumerStatefulWidget {
  const ToolkitScreen({super.key});

  @override
  ConsumerState<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends ConsumerState<ToolkitScreen> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now().toUtc();

  // Accordion style: only one card expanded at a time (null if none)
  String? _expandedCard;

  // Track checklist checked items (persisted via SharedPreferences)
  final Set<String> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadPersistedChecklist();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now().toUtc());
      }
    });
  }

  Future<void> _loadPersistedChecklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('travel_checklist_items');
      if (saved != null && mounted) {
        setState(() {
          _checkedItems.addAll(saved);
        });
      }
    } catch (_) {}
  }

  Future<void> _savePersistedChecklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('travel_checklist_items', _checkedItems.toList());
    } catch (_) {}
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _toggleExpanded(String key) {
    setState(() {
      // Accordion behavior: tapping an open card collapses it; tapping another closes current and opens new
      if (_expandedCard == key) {
        _expandedCard = null;
      } else {
        _expandedCard = key;
      }
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _getCountryImage(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TH':
        return 'assets/images/countries/thailand/place/bangkok.png';
      case 'ID':
        return 'assets/images/countries/indonesia/place/borobudur.png';
      case 'VN':
        return 'assets/images/countries/vietnam/place/halong.png';
      case 'PH':
      default:
        return 'assets/images/countries/philippines/place/palawan.png';
    }
  }

  String _getTimezoneAbbrev(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TH':
        return 'ICT';
      case 'VN':
        return 'ICT';
      case 'ID':
        return 'WIB';
      case 'PH':
      default:
        return 'PST';
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(selectedCountryProvider);
    final toolkitAsync = ref.watch(countryToolkitFutureProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header (LAKBAY [COUNTRY] + P -> Currency Pill)
            _buildHeader(context, country.name, country.currencySymbol),

            // 2. Scrollable Body
            Expanded(
              child: toolkitAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F382A)),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading toolkit: $err',
                    style: const TextStyle(color: Color(0xFF1E3A2F)),
                  ),
                ),
                data: (toolkit) {
                  final localTime = _now.add(Duration(hours: toolkit.utcOffsetHours));
                  final manilaTime = _now.add(const Duration(hours: 8));
                  final tzAbbr = _getTimezoneAbbrev(country.code);
                  final tzOffsetStr = toolkit.utcOffsetHours >= 0
                      ? 'UTC+${toolkit.utcOffsetHours}'
                      : 'UTC${toolkit.utcOffsetHours}';

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                    children: [
                      // Subtitle & Title: TOOLKIT / Travel Essentials
                      const Text(
                        'TOOLKIT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: Color(0xFF55685C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Travel Essentials',
                        style: AppTheme.serif(
                          26,
                          color: const Color(0xFF113829),
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Helpful tips for a smoother journey.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7E72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card 1: LOCAL TIME CONVERTER Banner Card
                      _buildTimeConverterCard(
                        country: country,
                        toolkit: toolkit,
                        localTimeStr: _formatTime(localTime),
                        manilaTimeStr: _formatTime(manilaTime),
                        tzAbbr: tzAbbr,
                        tzOffsetStr: tzOffsetStr,
                      ),

                      const SizedBox(height: 14),

                      // Card 2: Emergency Numbers (Expandable)
                      _buildExpandableToolkitCard(
                        cardKey: 'emergency',
                        iconWidget: const _CustomToolkitIcon(type: _ToolkitIconType.phone),
                        title: 'Emergency Numbers',
                        subtitle: 'Important contacts at a glance',
                        isExpanded: _expandedCard == 'emergency',
                        onTap: () => _toggleExpanded('emergency'),
                        content: _buildEmergencyContent(toolkit.emergencies),
                      ),

                      const SizedBox(height: 12),

                      // Card 3: Tipping & Money Culture (Expandable)
                      _buildExpandableToolkitCard(
                        cardKey: 'tipping',
                        iconWidget: const _CustomToolkitIcon(type: _ToolkitIconType.wallet),
                        title: 'Tipping & Money Culture',
                        subtitle: 'Cash, tips, and local customs',
                        isExpanded: _expandedCard == 'tipping',
                        onTap: () => _toggleExpanded('tipping'),
                        content: _buildTippingContent(toolkit.tipping),
                      ),

                      const SizedBox(height: 12),

                      // Card 4: Cultural Etiquette (Expandable)
                      _buildExpandableToolkitCard(
                        cardKey: 'etiquette',
                        iconWidget: const _CustomToolkitIcon(type: _ToolkitIconType.temple),
                        title: 'Cultural Etiquette',
                        subtitle: 'Dos, don\'ts, and respectful travel',
                        isExpanded: _expandedCard == 'etiquette',
                        onTap: () => _toggleExpanded('etiquette'),
                        content: _buildEtiquetteContent(toolkit.etiquette),
                      ),

                      const SizedBox(height: 12),

                      // Card 5: Travel & Packing Checklist (Expandable + Interactive Checkboxes)
                      _buildExpandableToolkitCard(
                        cardKey: 'checklist',
                        iconWidget: const _CustomToolkitIcon(type: _ToolkitIconType.luggage),
                        title: 'Travel & Packing Checklist',
                        subtitle: 'Get ready before you go',
                        isExpanded: _expandedCard == 'checklist',
                        onTap: () => _toggleExpanded('checklist'),
                        content: _buildChecklistContent(toolkit.checklist),
                      ),

                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildHeader(BuildContext context, String countryName, String currencySymbol) {
    return Container(
      color: const Color(0xFFF7F8F4),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mountain Logo + LAKBAY [COUNTRY] (Tapping opens country switcher)
          GestureDetector(
            onTap: () => context.go('/country'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _MountainLogo(size: 24, color: Color(0xFF0F382A)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LAKBAY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                        color: Color(0xFF0F382A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countryName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                        color: Color(0xFF4C6154),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Currency Swap Pill (₱ ⇄ [Symbol])
          GestureDetector(
            onTap: () => context.push('/currency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE6D5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC7D5BF)),
              ),
              child: Text(
                '₱ ⇄ $currencySymbol',
                style: const TextStyle(
                  color: Color(0xFF0F382A),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Card 1: Local Time Converter Card ---
  Widget _buildTimeConverterCard({
    required Country country,
    required CountryToolkit toolkit,
    required String localTimeStr,
    required String manilaTimeStr,
    required String tzAbbr,
    required String tzOffsetStr,
  }) {
    final imageAsset = _getCountryImage(country.code);

    return Container(
      width: double.infinity,
      height: 168,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFE5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E7DB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Country scenery background image on right half
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 175,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),

            // Soft gradient fading the image to match the card background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFEBEFE5),
                      Color(0xFFEBEFE5),
                      Color(0xCCEBEFE5),
                      Color(0x33EBEFE5),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.48, 0.65, 0.80, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge: 🌐 LOCAL TIME CONVERTER
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E2CE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC3D4BA)),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF1E3A2F),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LOCAL TIME CONVERTER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Color(0xFF384D40),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Two Time Blocks side by side with ⇄ between them
                  Row(
                    children: [
                      // Selected Country Time Block
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country.name,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF55685C),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                localTimeStr,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF113829),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$tzAbbr · $tzOffsetStr',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF788C80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Swap / arrows icon circle in middle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E2CE),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC3D4BA)),
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: Color(0xFF1E3A2F),
                          ),
                        ),
                      ),

                      // Philippines (PH) Time Block
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PH',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF55685C),
                                ),
                              ),
                              SizedBox(height: 2),
                              _ManilaClockWidget(),
                              SizedBox(height: 1),
                              Text(
                                'PHT · UTC+8',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF788C80),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Expandable Toolkit Card Container ---
  Widget _buildExpandableToolkitCard({
    required String cardKey,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded ? const Color(0xFFC3D4BA) : const Color(0xFFE2E8DC),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar (Clickable)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Icon
                  iconWidget,
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.serif(
                            17,
                            color: const Color(0xFF143B2B),
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF5C7063),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Circular Arrow Pill (Rotates downwards when expanded)
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: isExpanded ? 0.25 : 0.0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6D5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC8D6BF)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFF1B3D2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content Section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFDCE4D5)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: content,
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // --- Content 1: Emergency Numbers ---
  Widget _buildEmergencyContent(List<EmergencyContact> emergencies) {
    return Column(
      children: emergencies.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E7DC)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFF354B3E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.number,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB52B27),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: e.number));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ${e.number} to clipboard'),
                      backgroundColor: const Color(0xFF0F382A),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4E2CD)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 13, color: Color(0xFF0F382A)),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F382A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Content 2: Tipping Guide ---
  Widget _buildTippingContent(List<String> tipping) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tipping.map((tip) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Icon(Icons.circle, size: 6, color: Color(0xFF3B5747)),
              ),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(
                    color: Color(0xFF283A30),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Content 3: Cultural Etiquette ---
  Widget _buildEtiquetteContent(List<String> etiquette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: etiquette.map((note) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Icon(Icons.circle, size: 6, color: Color(0xFF2A503D)),
              ),
              Expanded(
                child: Text(
                  note,
                  style: const TextStyle(
                    color: Color(0xFF283A30),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Content 4: Travel & Packing Checklist with Checkboxes ---
  Widget _buildChecklistContent(List<String> checklist) {
    final completedCount = checklist.where((c) => _checkedItems.contains(c)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedCount of ${checklist.length} completed',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4C6154),
              ),
            ),
            if (_checkedItems.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() => _checkedItems.clear());
                  _savePersistedChecklist();
                },
                child: const Text(
                  'Reset all',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF86968B),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Checkbox items
        ...checklist.map((item) {
          final isChecked = _checkedItems.contains(item);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  _checkedItems.remove(item);
                } else {
                  _checkedItems.add(item);
                }
              });
              _savePersistedChecklist();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0xFFE5EDE0) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFB8CDAF) : const Color(0xFFE0E7DC),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFF0F382A) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isChecked ? const Color(0xFF0F382A) : const Color(0xFF8BA093),
                          width: 1.6,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isChecked ? const Color(0xFF7A8E81) : const Color(0xFF283A30),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

}

// --- Manila Clock Widget ---
class _ManilaClockWidget extends ConsumerWidget {
  const _ManilaClockWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manilaTime = DateTime.now().toUtc().add(const Duration(hours: 8));
    final hour = manilaTime.hour.toString().padLeft(2, '0');
    final minute = manilaTime.minute.toString().padLeft(2, '0');
    final second = manilaTime.second.toString().padLeft(2, '0');

    return Text(
      '$hour:$minute:$second',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF113829),
        letterSpacing: 0.2,
      ),
    );
  }
}

// --- Custom Toolkit Icons Matching Reference Mockup ---
enum _ToolkitIconType { phone, wallet, temple, luggage }

class _CustomToolkitIcon extends StatelessWidget {
  final _ToolkitIconType type;

  const _CustomToolkitIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6D5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCDCC4)),
      ),
      child: Center(
        child: _buildIcon(type),
      ),
    );
  }

  Widget _buildIcon(_ToolkitIconType type) {
    const iconColor = Color(0xFF163E2D);
    switch (type) {
      case _ToolkitIconType.phone:
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.phone_rounded, color: iconColor, size: 24),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  color: Color(0xFF163E2D),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      case _ToolkitIconType.wallet:
        return const Icon(Icons.account_balance_wallet_outlined, color: iconColor, size: 24);
      case _ToolkitIconType.temple:
        return const Icon(Icons.temple_buddhist_outlined, color: iconColor, size: 24);
      case _ToolkitIconType.luggage:
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.luggage_outlined, color: iconColor, size: 24),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF163E2D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 9, color: Colors.white),
              ),
            ),
          ],
        );
    }
  }
}



// --- Mountain Logo Widget ---
class _MountainLogo extends StatelessWidget {
  final double size;
  final Color color;

  const _MountainLogo({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.35, size),
      painter: _MountainPainter(color),
    );
  }
}

class _MountainPainter extends CustomPainter {
  final Color color;

  _MountainPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.90);
    path1.lineTo(size.width * 0.36, size.height * 0.05);
    path1.lineTo(size.width * 0.54, size.height * 0.55);
    path1.lineTo(size.width * 0.44, size.height * 0.38);
    path1.lineTo(size.width * 0.36, size.height * 0.22);
    path1.lineTo(size.width * 0.12, size.height * 0.85);
    path1.close();

    final path2 = Path();
    path2.moveTo(size.width * 0.36, size.height * 0.05);
    path2.lineTo(size.width * 0.72, size.height * 0.92);
    path2.lineTo(size.width * 0.54, size.height * 0.92);
    path2.lineTo(size.width * 0.36, size.height * 0.40);
    path2.close();

    final path3 = Path();
    path3.moveTo(size.width * 0.54, size.height * 0.55);
    path3.lineTo(size.width * 0.82, size.height * 0.18);
    path3.lineTo(size.width * 1.0, size.height * 0.92);
    path3.lineTo(size.width * 0.84, size.height * 0.92);
    path3.lineTo(size.width * 0.80, size.height * 0.40);
    path3.close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


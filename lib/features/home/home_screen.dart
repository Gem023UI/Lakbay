import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'home_carousel_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final country = ref.watch(selectedCountryProvider);
    final bundleAsync = ref.watch(exchangeRateBundleFutureProvider);

    // Calculate conversion rate text (e.g. 1.87)
    final rateDouble = bundleAsync.when(
      data: (bundle) {
        final r = bundle.rates[country.currencyCode] ?? 0.60;
        return r > 0 ? (1.0 / r) : 1.67;
      },
      loading: () => 1.87,
      error: (err, stack) => 1.87,
    );
    final rateText = rateDouble.toStringAsFixed(2);

    final places = HomeCountryData.getPlaces(country.code);
    final dishes = HomeCountryData.getDishes(country.code);
    final festivals = HomeCountryData.getFestivals(country.code);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Sleek Compact Header (Always visible while scrolling carousels, not tall!)
            _buildHeader(context, country.name, country.currencySymbol),

            // 2. Scrollable Body: Currency Rate Card & Carousels
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // Currency Rate Card
                  _buildCurrencyRateCard(context, rateText, country.currencySymbol),

                  const SizedBox(height: 16),

                  // Category 1: Explore Card (Carousel)
                  _CarouselCard(
                    categoryType: _CardType.place,
                    items: places,
                    onTapPill: (item) => _showItemDetailModal(context, item),
                  ),

                  const SizedBox(height: 16),

                  // Category 2: Dishes Card (Carousel)
                  _CarouselCard(
                    categoryType: _CardType.dish,
                    items: dishes,
                    onTapArrow: (item) => _showItemDetailModal(context, item),
                  ),

                  const SizedBox(height: 16),

                  // Category 3: Events & Festivals Card (Carousel)
                  _CarouselCard(
                    categoryType: _CardType.festival,
                    items: festivals,
                    onTapArrow: (item) => _showItemDetailModal(context, item),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String countryName, String currencySymbol) {
    return Container(
      color: const Color(0xFFF7F8F4),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button + Mountain Logo + LAKBAY + Country Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back Button before Lakbay Philippines
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/country');
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF1E8),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDDE6D5)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: Color(0xFF0F382A),
                  ),
                ),
              ),
              const SizedBox(width: 10),

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
            ],
          ),

          // Currency Swap Pill (₱ ⇄ ฿)
          GestureDetector(
            onTap: () => context.push('/currency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE6D5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8D6C0)),
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

  Widget _buildCurrencyRateCard(BuildContext context, String rateText, String currencySymbol) {
    return GestureDetector(
      onTap: () => context.push('/currency'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CURRENCY RATE',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Color(0xFF4C6154),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₱$rateText',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F382A),
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  height: 20,
                  width: 1.2,
                  color: const Color(0xFFC3CEC2),
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                ),
                Text(
                  '₱ ➔ $currencySymbol',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C6154),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showItemDetailModal(BuildContext context, CarouselItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFBFBF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imageAsset,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 170,
                  color: const Color(0xFFDDE6D5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, size: 48, color: Color(0xFF0F382A)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.chipLabel ?? item.title,
              style: AppTheme.serif(24, color: const Color(0xFF0F382A)),
            ),
            const SizedBox(height: 8),
            Text(
              item.description ?? item.subtitle.replaceAll('\n', ' '),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF384A40),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F382A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CardType { place, dish, festival }

class _CarouselCard extends StatefulWidget {
  final _CardType categoryType;
  final List<CarouselItem> items;
  final ValueChanged<CarouselItem>? onTapPill;
  final ValueChanged<CarouselItem>? onTapArrow;

  const _CarouselCard({
    required this.categoryType,
    required this.items,
    this.onTapPill,
    this.onTapArrow,
  });

  @override
  State<_CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<_CarouselCard> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    if (widget.items.length > 1) {
      _autoTimer = Timer.periodic(const Duration(seconds: 8), (_) {
        if (!mounted || widget.items.isEmpty) return;
        final next = (_currentIndex + 1) % widget.items.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 950),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = widget.categoryType == _CardType.place ? 200 : 185;

    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
              onPageChanged: (idx) {
                setState(() => _currentIndex = idx);
                _startTimer();
              },
              itemBuilder: (context, index) {
                final item = widget.items[index];
                switch (widget.categoryType) {
                  case _CardType.place:
                    return _buildPlaceCard(item);
                  case _CardType.dish:
                    return _buildDishCard(item);
                  case _CardType.festival:
                    return _buildFestivalCard(item);
                }
              },
            ),
          ),

          // Small Page Indicators
          if (widget.items.length > 1)
            Positioned(
              right: 14,
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.items.length, (i) {
                  final isSel = i == _currentIndex;
                  final dotColor = widget.categoryType == _CardType.place
                      ? Colors.white.withValues(alpha: isSel ? 0.95 : 0.35)
                      : const Color(0xFF0F382A).withValues(alpha: isSel ? 0.8 : 0.2);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: isSel ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // 1. Explore / Place Card
  Widget _buildPlaceCard(CarouselItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Photo
        Image.asset(
          item.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E3A2F)),
        ),

        // Gradient Overlay on the Left for text clarity
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.40),
                Colors.transparent,
              ],
              stops: const [0.0, 0.52, 0.85],
            ),
          ),
        ),

        // Text & Content on the Left
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: AppTheme.serif(30, color: Colors.white, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DA27D),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),

              // Chip (e.g. 📍 Bangkok ➔)
              if (item.chipLabel != null)
                GestureDetector(
                  onTap: () => widget.onTapPill?.call(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.chipLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 13),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Dishes Card
  Widget _buildDishCard(CarouselItem item) {
    return Container(
      color: const Color(0xFFF7F3EC),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dish Photo positioned on the right with soft fade-in
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 230,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.40],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // Content on the Left
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Color(0xFF4C6154),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: AppTheme.serif(28, color: const Color(0xFF0F382A), weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D7C5F),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF35473D),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),

                // Circular Forward Arrow Button
                GestureDetector(
                  onTap: () => widget.onTapArrow?.call(item),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCE6D5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0F382A),
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Events & Festivals Card
  Widget _buildFestivalCard(CarouselItem item) {
    return Container(
      color: const Color(0xFFF3EFE7),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Festival Photo positioned on the right with soft fade-in
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 240,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.40],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // Content on the Left
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Color(0xFF4C6154),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: AppTheme.serif(
                        22,
                        color: const Color(0xFF0F382A),
                        weight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),

                // Circular Forward Arrow Button
                GestureDetector(
                  onTap: () => widget.onTapArrow?.call(item),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCE6D5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0F382A),
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



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

    // Stylized geometric mountain peaks matching mockup
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
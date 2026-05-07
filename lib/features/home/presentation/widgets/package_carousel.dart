import 'dart:async';
import 'package:flutter/material.dart';

class PackageCarousel extends StatefulWidget {
  const PackageCarousel({super.key});

  @override
  State<PackageCarousel> createState() => _PackageCarouselState();
}

class _PackageCarouselState extends State<PackageCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> packages = [
    {
      'title': 'باقة 6 غسلات',
      'subtitle': 'حل سريع ومرن لاحتياجك الأسبوعي',
      'count': '6 غسلات',
      'price': '280 ريال',
      'oldPrice': '316.4',
      'image': 'assets/images/package_6.png',
    },
    {
      'title': 'باقة 12 غسلة',
      'subtitle': 'الخيار الأفضل للاستخدام المتكرر',
      'count': '12 غسلة',
      'price': '520 ريال',
      'oldPrice': '610',
      'image': 'assets/images/package_12.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      _currentPage++;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPackageCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8FA8FF).withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Image.asset(
                item['image']!,
                height: 155,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['title']!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18224B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['subtitle']!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF687089),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EBF7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['count']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF677089),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item['price']!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18224B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['oldPrice']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7D8597),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final item = packages[index % packages.length];
          return _buildPackageCard(item);
        },
      ),
    );
  }
}
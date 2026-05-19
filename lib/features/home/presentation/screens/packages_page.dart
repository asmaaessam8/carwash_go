import 'package:flutter/material.dart';
import '../../data/repositories/package_repository.dart';
import 'package_success_page.dart';

class PackagesPage extends StatelessWidget {
  PackagesPage({super.key});

  final PackageRepository _repo = PackageRepository();

  Future<void> _subscribePackage(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    required String image,
  }) async {
    try {
      await _repo.subscribePackage(
        title: title,
        description: description,
        price: price,
        image: image,
      );

      final remaining = _repo.washesCount(title);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackageSuccessPage(
            packageTitle: title,
            remainingWashes: remaining,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الاشتراك: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final packages = [
      {
        'title': 'باقة 12 غسلة',
        'description': 'للغسيل الكامل والاحترافي صالح لمدة 90 يوم',
        'price': '150 ريال',
        'oldPrice': '720',
        'image': 'assets/images/package_12.png',
        'badge': 'الأكثر طلباً',
      },
      {
        'title': 'باقة 6 غسلات',
        'description': 'للغسيل الخارجي الأساسي صالح لمدة 45 يوم',
        'price': '70.00 ريال',
        'oldPrice': '316.4',
        'image': 'assets/images/package_6.png',
        'badge': '',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1670FF),
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الباقات',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1560D6),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'اختري باقة غسيل تناسب احتياجاتك',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF5F677B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.local_offer_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1976FF),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final item = packages[index];

                  return _PackageCard(
                    title: item['title']!,
                    description: item['description']!,
                    price: item['price']!,
                    oldPrice: item['oldPrice']!,
                    image: item['image']!,
                    badge: item['badge']!,
                    onSubscribe: () {
                      _subscribePackage(
                        context,
                        title: item['title']!,
                        description: item['description']!,
                        price: item['price']!,
                        image: item['image']!,
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

class _PackageCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String oldPrice;
  final String image;
  final String badge;
  final VoidCallback onSubscribe;

  const _PackageCard({
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.badge,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 250,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE8EDFF),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF9DB5FF).withOpacity(0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Image.asset(
                        image,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            title,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF151B4A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF5F677B),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE7EAF4),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                price,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF151B4A),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                oldPrice,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF7D8597),
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
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 42,
                    width: 145,
                    child: ElevatedButton(
                      onPressed: onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6BFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'اشترك الآن',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (badge.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8B63F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
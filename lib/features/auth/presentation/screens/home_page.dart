import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/services_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  int _selectedIndex = 0;
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
      'image': 'assets/images/package_12.jpeg',
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

  Widget _buildServiceCard({
    required String title,
    required String image,
    required bool showButton,
  }) {
    return Expanded(
      child: Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF18224B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Image.asset(
                  image,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (showButton)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59A2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text(
                      'احجز الآن',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _bottomItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Color(0xFF1976FF),
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الرئيسية',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1560D6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'أهلاً بك، اختر الخدمة المناسبة لسيارتك',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5F677B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 225,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final item = packages[index % packages.length];
                    return _buildPackageCard(item);
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              const ServicesRow(),

              const SizedBox(height: 18),

              Row(
                children: [
                  _buildServiceCard(
                    title: 'غسيل خارجي',
                    image: 'assets/images/service_wash.jpeg',
                    showButton: true,
                  ),
                  const SizedBox(width: 12),
                  _buildServiceCard(
                    title: 'تنظيف داخلي',
                    image: 'assets/images/service_interior.jpeg',
                    showButton: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildServiceCard(
                    title: 'غسيل كامل',
                    image: 'assets/images/service_cleaning.jpeg',
                    showButton: true,
                  ),
                  const SizedBox(width: 12),
                  _buildServiceCard(
                    title: 'إضافات',
                    image: 'assets/images/service_addons.jpeg',
                    showButton: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E7BAA).withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1670FF),
          unselectedItemColor: const Color(0xFF8B95A7),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: [
            _bottomItem(icon: Icons.home_rounded, label: 'الرئيسية'),
            _bottomItem(icon: Icons.calendar_month_rounded, label: 'حجوزاتي'),
            _bottomItem(icon: Icons.local_offer_rounded, label: 'الباقات'),
            _bottomItem(icon: Icons.person_rounded, label: 'الحساب'),
          ],
        ),
      ),
    );
  }
}
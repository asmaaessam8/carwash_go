import 'package:flutter/material.dart';

class ProductCardsSection extends StatelessWidget {
  const ProductCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: ProductCard(
                title: 'غسيل خارجي',
                image: 'assets/images/service_wash.jpeg',
                showButton: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ProductCard(
                title: 'تنظيف داخلي',
                image: 'assets/images/service_interior.jpeg',
                showButton: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: ProductCard(
                title: 'غسيل كامل',
                image: 'assets/images/service_cleaning.jpeg',
                showButton: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ProductCard(
                title: 'إضافات',
                image: 'assets/images/service_addons.jpeg',
                showButton: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String image;
  final bool showButton;

  const ProductCard({
    super.key,
    required this.title,
    required this.image,
    required this.showButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
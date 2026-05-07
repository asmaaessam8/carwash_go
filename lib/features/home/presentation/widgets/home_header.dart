import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
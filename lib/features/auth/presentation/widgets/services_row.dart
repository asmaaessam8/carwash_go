import 'package:flutter/material.dart';

class ServicesRow extends StatelessWidget {
  const ServicesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(title: 'غسيل خارجي', icon: Icons.local_car_wash),
          _Item(title: 'تنظيف داخلي', icon: Icons.cleaning_services),
          _Item(title: 'تلميع داخلي', icon: Icons.auto_fix_high),
          _Item(title: 'إضافات', icon: Icons.add_box_outlined),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final IconData icon;

  const _Item({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE9EEFF),
          child: Icon(
            icon,
            color: Color(0xFF0D2BFF),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5F677B),
          ),
        ),
      ],
    );
  }
}
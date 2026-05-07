import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _supportCard(
              icon: Icons.phone_rounded,
              title: 'اتصال بالدعم',
              subtitle: '+966 55 000 0000',
            ),
            const SizedBox(height: 14),
            _supportCard(
              icon: Icons.email_rounded,
              title: 'البريد الإلكتروني',
              subtitle: 'support@carwash.com',
            ),
            const SizedBox(height: 14),
            _supportCard(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              subtitle: 'سيتم إضافة الأسئلة الشائعة قريباً',
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDFF)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1670FF), size: 30),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF151B4A),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F677B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'my_programs_page.dart';

class PackageSuccessPage extends StatelessWidget {
  final String packageTitle;
  final int remainingWashes;

  const PackageSuccessPage({
    super.key,
    required this.packageTitle,
    required this.remainingWashes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF7F8FC),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white12
                      : const Color(0xFFE8FFF2),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF12C96F),
                  size: 70,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'تم الاشتراك بنجاح',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF151B4A),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                packageTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1670FF),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'الغسلات المتبقية: $remainingWashes',
                style: TextStyle(
                  fontSize: 17,
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF5F677B),
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyProgramsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text(
                    'الذهاب إلى برامجي',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6BFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'الرجوع للباقات',
                  style: TextStyle(
                    color: Color(0xFF1670FF),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
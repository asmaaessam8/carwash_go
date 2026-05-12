import 'package:flutter/material.dart';

import 'home_page.dart';

class PackageBookingSuccessPage extends StatelessWidget {
  final String packageTitle;
  final String date;
  final String time;
  final String location;
  final String carInfo;

  const PackageBookingSuccessPage({
    super.key,
    required this.packageTitle,
    required this.date,
    required this.time,
    required this.location,
    required this.carInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF2),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF12C96F),
                    size: 70,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'تم حجز موعد الغسيل بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF151B4A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  packageTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1670FF),
                  ),
                ),
                const SizedBox(height: 20),
                _info('التاريخ', date),
                _info('الوقت', time),
                _info('الموقع', location),
                _info('السيارة', carInfo),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF151B4A),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5F677B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

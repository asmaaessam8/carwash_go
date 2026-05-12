import 'package:flutter/material.dart';

import 'home_page.dart';

class BookingSuccessPage extends StatelessWidget {
  final String serviceTitle;
  final String date;
  final String time;
  final String location;
  final String carInfo;
  final List<String> addons;
  final String paymentMethod;
  final int totalPrice;

  const BookingSuccessPage({
    super.key,
    required this.serviceTitle,
    required this.date,
    required this.time,
    required this.location,
    required this.carInfo,
    this.addons = const [],
    required this.paymentMethod,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF7F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  width: 105,
                  height: 105,

                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white12
                            : const Color(0xFFEAF8F0),

                    borderRadius: BorderRadius.circular(34),
                  ),

                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF12C96F),
                    size: 72,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'تم تأكيد الحجز بنجاح',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,

                    color:
                        isDark
                            ? Colors.white
                            : const Color(0xFF151B4A),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'عامل غسيل السيارات في الطريق إليك الآن',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 17,

                    color:
                        isDark
                            ? Colors.white70
                            : const Color(0xFF5F677B),
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,

                    borderRadius: BorderRadius.circular(26),

                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white12
                              : const Color(0xFFE8EDFF),
                    ),
                  ),

                  child: Column(
                    children: [
                      _row(
                        context,
                        'الخدمة',
                        serviceTitle,
                        Icons.local_car_wash_rounded,
                      ),

                      _row(
                        context,
                        'التاريخ',
                        date,
                        Icons.calendar_month_rounded,
                      ),

                      _row(
                        context,
                        'الوقت',
                        time,
                        Icons.access_time_rounded,
                      ),

                      _row(
                        context,
                        'الموقع',
                        location,
                        Icons.location_on_rounded,
                      ),

                      _row(
                        context,
                        'السيارة',
                        carInfo,
                        Icons.directions_car_rounded,
                      ),

                      if (addons.isNotEmpty)
                        _row(
                          context,
                          'الإضافات',
                          addons.join('، '),
                          Icons.add_box_rounded,
                        ),

                      _row(
                        context,
                        'طريقة الدفع',
                        paymentMethod,
                        Icons.payments_rounded,
                      ),

                      Divider(
                        height: 24,
                        color:
                            isDark
                                ? Colors.white12
                                : const Color(0xFFE7EAF4),
                      ),

                      Row(
                        children: [
                          Text(
                            '$totalPrice ريال',

                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF1670FF),
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            'إجمالي الرسوم',

                            style: TextStyle(
                              fontSize: 18,

                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(
                                        0xFF151B4A,
                                      ),

                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder:
                              (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0D6BFF),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),

                    child: const Text(
                      'العودة للرئيسية',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Expanded(
            child: Text(
              value,

              textAlign: TextAlign.left,

              style: TextStyle(
                fontSize: 15,

                color:
                    isDark
                        ? Colors.white
                        : const Color(0xFF151B4A),

                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            title,

            style: TextStyle(
              fontSize: 15,

              color:
                  isDark
                      ? Colors.white70
                      : const Color(0xFF5F677B),

              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 10),

          Icon(
            icon,
            color: const Color(0xFF1670FF),
          ),
        ],
      ),
    );
  }
}
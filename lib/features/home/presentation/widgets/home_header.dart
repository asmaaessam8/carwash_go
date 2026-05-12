import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

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
                  : const Color(0xFFE1E6F5),
        ),

        boxShadow:
            isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(
                        0xFF8FA8FF,
                      ).withOpacity(0.08),

                      blurRadius: 18,

                      offset: const Offset(0, 8),
                    ),
                  ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white12
                      : const Color(0xFFEAF2FF),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              Icons.home_rounded,

              color:
                  isDark
                      ? Colors.white
                      : const Color(0xFF1670FF),

              size: 32,
            ),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Text(
                'الرئيسية',

                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,

                  color:
                      isDark
                          ? Colors.white
                          : const Color(
                            0xFF151B4A,
                          ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'أهلاً بك، اختر الخدمة المناسبة لسيارتك',

                textAlign: TextAlign.right,

                style: TextStyle(
                  fontSize: 14,

                  color:
                      isDark
                          ? Colors.white70
                          : const Color(
                            0xFF5F677B,
                          ),

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
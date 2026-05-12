import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'faq_page.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String phone = '77739412';
  static const String email = 'support@carwash.com';

  Future<void> _callSupport() async {
    final Uri phoneUri = Uri.parse('tel:$phone');

    try {
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not launch phone');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri.parse(
      'mailto:$email?subject=طلب دعم',
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? const Color(0xFF0F1115)
              : const Color(0xFFF7F8FC),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,

        backgroundColor: const Color(0xFF1670FF),

        foregroundColor: Colors.white,

        title: const Text(
          'الدعم والمساعدة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            GestureDetector(
              onTap: _callSupport,

              child: _supportCard(
                context: context,
                icon: Icons.phone_rounded,
                title: 'اتصال بالدعم',
                subtitle: '77739412',
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: _sendEmail,

              child: _supportCard(
                context: context,
                icon: Icons.email_rounded,
                title: 'البريد الإلكتروني',
                subtitle: 'support@carwash.com',
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FAQPage(),
                  ),
                );
              },

              child: _supportCard(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'الأسئلة الشائعة',
                subtitle:
                    'اضغط لعرض الأسئلة الشائعة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1A1D24)
                : Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color:
              isDark
                  ? Colors.white10
                  : const Color(0xFFE8EDFF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black26
                    : Colors.black12,

            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white10
                      : const Color(0xFFEAF2FF),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Icon(
              icon,
              size: 28,

              color:
                  isDark
                      ? Colors.white
                      : const Color(0xFF1670FF),
            ),
          ),

          const Spacer(),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Text(
                title,

                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,

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
                subtitle,

                style: TextStyle(
                  fontSize: 14,

                  color:
                      isDark
                          ? Colors.white70
                          : const Color(
                            0xFF5F677B,
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
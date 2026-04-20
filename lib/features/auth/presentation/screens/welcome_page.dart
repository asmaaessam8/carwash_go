import 'package:flutter/material.dart';
import '../../../../core/routes/routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/top_wave.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const TopWave(),
            const SizedBox(height: 6),
            const Text(
              'اهلاً بك',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF151B4A),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/welcome_car.png',
              height: 230,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
               'غسيل وتلميع غسيل سيارتك الان',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF8B90A3),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'إنشاء حساب',
                    isPrimary: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  static Widget _buildDot(bool isActive) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1450FF) : const Color(0xFFD8DDF0),
        shape: BoxShape.circle,
      ),
    );
  }
}
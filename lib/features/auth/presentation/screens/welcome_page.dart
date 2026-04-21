import 'package:flutter/material.dart';

import '../../../../core/routes/routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/top_wave.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const TopWave(),
                      const SizedBox(height: 20),
                      const Text(
                        'أهلاً بك',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF151B4A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/images/welcome_car.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'غسيل وتلميع سيارتك الآن',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8B90A3),
                        ),
                      ),
                      const SizedBox(height: 36),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
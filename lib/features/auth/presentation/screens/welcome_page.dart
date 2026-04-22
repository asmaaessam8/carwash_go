import 'package:flutter/material.dart';
import '../../../../core/routes/routes.dart';
import '../widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Stack(
          children: [
            // الخلفية العلوية بعرض الشاشة كامل
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF0FF),
                    ),
                  ),
                  Container(
                    height: 55,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(300, 70),
                        bottomRight: Radius.elliptical(300, 70),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // المحتوى
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          const Text(
                            'أهلاً بك',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF151B4A),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Image.asset(
                            'assets/images/welcome_car.png',
                            height: size.width < 380 ? 170 : 220,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'غسيل وتلميع سيارتك الآن',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF8B90A3),
                            ),
                          ),
                          const SizedBox(height: 40),
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
          ],
        ),
      ),
    );
  }
}
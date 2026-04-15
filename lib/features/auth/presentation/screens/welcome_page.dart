import 'package:flutter/material.dart';
import '../../../../core/routes/routes.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Sign In',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sign Up',
              isPrimary: false,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
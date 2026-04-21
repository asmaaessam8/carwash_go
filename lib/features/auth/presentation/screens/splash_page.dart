import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/routes/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _lottieFadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _logoSlideAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _lottieFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logoSize = size.width < 600 ? size.width * 0.38 : 190.0;
    final lottieHeight = size.width < 600 ? size.height * 0.22 : 180.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _logoSlideAnimation.value),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'غسيل سيارات',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF0800FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'نظافة • تلميع • سرعة',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color.fromARGB(
                                          179,
                                          21,
                                          0,
                                          255,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: _lottieFadeAnimation.value,
                      child: SizedBox(
                        height: lottieHeight,
                        width: size.width < 600 ? size.width * 0.65 : 260,
                        child: Lottie.asset(
                          'assets/animations/car_wash.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: _lottieFadeAnimation.value,
                      child: Text(
                        'جاري التحميل...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color.fromARGB(179, 0, 13, 255),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
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

    _logoFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _logoSlideAnimation = Tween<double>(
      begin: -30,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _lottieFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                children: [
                  const Spacer(flex: 2),

                  Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _logoSlideAnimation.value),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'CAR WASH',
                            style: TextStyle(
                              color: Color.fromARGB(255, 8, 0, 255),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Clean • Shine • Go',
                            style: TextStyle(
                              color: Color.fromARGB(179, 21, 0, 255),
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Opacity(
                    opacity: _lottieFadeAnimation.value,
                    child: SizedBox(
                      height: 220,
                      width: 300,
                      child: Lottie.asset(
                        'assets/animations/car_wash.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  Opacity(
                    opacity: _lottieFadeAnimation.value,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 26),
                      child: Text(
                        'Loading...',
                        style: TextStyle(
                          color: Color.fromARGB(179, 0, 13, 255),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
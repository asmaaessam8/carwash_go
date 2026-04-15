import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/routes/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _backgroundScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _backgroundScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildBubble({
    required double size,
    required double left,
    required double top,
    required int duration,
    required double begin,
    required double end,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: Duration(seconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Positioned(
          left: left,
          top: top + value,
          child: Opacity(
            opacity: 0.25,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white70,
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: _backgroundScaleAnimation.value,
                child: Image.asset(
                  'assets/images/car_wash.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.45),
              ),

              buildBubble(
                size: 18,
                left: 50,
                top: 620,
                duration: 4,
                begin: 0,
                end: -120,
              ),
              buildBubble(
                size: 28,
                left: 100,
                top: 700,
                duration: 5,
                begin: 0,
                end: -160,
              ),
              buildBubble(
                size: 14,
                left: 280,
                top: 650,
                duration: 4,
                begin: 0,
                end: -110,
              ),
              buildBubble(
                size: 22,
                left: 320,
                top: 730,
                duration: 6,
                begin: 0,
                end: -170,
              ),
              buildBubble(
                size: 16,
                left: 180,
                top: 760,
                duration: 5,
                begin: 0,
                end: -140,
              ),

              Center(
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Clean. Shine. Go.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
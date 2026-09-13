import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _drop;
  late Animation<double> _titleIn;
  late Animation<double> _glow;

  static const _splashBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF4FAF6),
      Colors.white,
      Colors.white,
    ],
    stops: [0.0, 0.4, 1.0],
  );

  static const _brandGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _drop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    _titleIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.72, curve: Curves.easeOutCubic),
    );

    _glow = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _splashBackground),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final drop = _drop.value.clamp(0.0, 1.0);
            final title = _titleIn.value.clamp(0.0, 1.0);
            final glow = _glow.value.clamp(0.0, 1.0);

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lockup: logo mark + "Baraya" wordmark (no gap between).
                  Transform.translate(
                    offset: Offset(0, (1 - _drop.value) * -340),
                    child: Opacity(
                      opacity: drop,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 220,
                            height: 205,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Soft radial glow behind the logo.
                                Transform.scale(
                                  scale: 0.8 + 0.25 * glow,
                                  child: Container(
                                    width: 220,
                                    height: 205,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _brandGreen
                                              .withValues(alpha: 0.18 * glow),
                                          _brandGreen.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: Image.asset(
                                    'assets/logo1.1.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // "Baraya" wordmark sits right under the logomark.
                          Transform.translate(
                            offset: Offset(0, (1 - title) * 24),
                            child: Opacity(
                              opacity: title,
                              child: Transform.scale(
                                scale: 0.92 + 0.08 * title,
                                child: SizedBox(
                                  width: 210,
                                  height: 78,
                                  child: Image.asset(
                                    'assets/Baraya.1.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Opacity(
                    opacity: title.clamp(0.0, 1.0),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _brandGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
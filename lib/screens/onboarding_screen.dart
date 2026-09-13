import 'package:flutter/material.dart';
import '../widgets/aura_logo.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final String logoAsset;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.logoAsset,
    required this.title,
    required this.description,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      logoAsset: 'assets/op1.png',
      title: 'Kelola & Ikuti Event',
      description:
          'Buat event komunitas, konfirmasi kehadiran, dan ketahui siapa saja '
          'yang ikut semua dalam satu tempat.',
    ),
    _OnboardingPage(
      logoAsset: 'assets/op2.png',
      title: 'Info & Pengumuman',
      description:
          'Tetap terupdate dengan pengumuman penting dan informasi terbaru '
          'untuk seluruh anggota komunitasmu.',
    ),
    _OnboardingPage(
      logoAsset: 'assets/op3.png',
      title: 'Bagi Tugas Bersama',
      description:
          'Bagi-bagi tugas, pantau progresnya, dan wujudkan setiap acara '
          'yang sukses bareng-bareng.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _next() {
    if (_current >= _pages.length - 1) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _current = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        Widget content = Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AuraLogo(
                                asset: page.logoAsset,
                                size: 200,
                                auraSize: 280,
                              ),
                              const SizedBox(height: 28),
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F3D24),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                page.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF5F6F65),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        );
                        if (_controller.hasClients) {
                          final pagePos = _controller.position.pixels /
                              _controller.position.viewportDimension;
                          final diff = pagePos - index;
                          content = Transform.translate(
                            offset: Offset(-90 * diff, 0),
                            child: Opacity(
                              opacity: (1 - diff.abs()).clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: (1 - diff.abs() * 0.10).clamp(0.88, 1.0),
                                child: content,
                              ),
                            ),
                          );
                        }
                        return content;
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 8),
                      width: active ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF16A34A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: Text(
                          _current == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

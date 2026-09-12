import 'package:flutter/material.dart';


const appAuthGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF16803D),
    Color(0xFF4FD88B),
    Color(0xFFE8F9F0),
    Colors.white,
    Colors.white,
  ],
  stops: [0.0, 0.10, 0.35, 0.55, 1.0],
);


class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0C1711), Color(0xFF13291C), Color(0xFF0F1115)]
              : const [
                  Color(0xFFE7F7EE),
                  Color(0xFFFAFDFB),
                  Colors.white,
                ],
          stops: isDark ? null : const [0.0, 0.3, 1.0],
        ),
      ),
      child: child,
    );
  }
}




class AuthGradientBackground extends StatelessWidget {
  final Widget child;

  const AuthGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: appAuthGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Align(
            alignment: Alignment(0, 0.35),
            child: _SoftGlow(),
          ),
          child,
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FractionallySizedBox(
        widthFactor: 1.4,
        heightFactor: 0.9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(800),
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

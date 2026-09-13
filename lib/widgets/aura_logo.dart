import 'package:flutter/material.dart';

class AuraLogo extends StatelessWidget {
  final String asset;
  final double size;
  final double auraSize;

  const AuraLogo({
    super.key,
    required this.asset,
    this.size = 120,
    this.auraSize = 170,
  });

  static const Color _aura = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: auraSize,
      height: auraSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: auraSize,
            height: auraSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _aura.withValues(alpha: 0.45),
                  _aura.withValues(alpha: 0.16),
                  _aura.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
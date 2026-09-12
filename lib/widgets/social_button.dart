import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final double height;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.textColor = const Color(0xFF333333),
    this.backgroundColor = const Color(0xFFF6F8F7),
    this.borderColor = const Color(0xFFE1E7E3),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            IconTheme(
              data: const IconThemeData(size: 20),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Center(child: icon),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

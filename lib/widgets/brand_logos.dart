import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class AppleLogo extends StatelessWidget {
  final double size;
  final Color color;

  const AppleLogo({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF000000),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ApplePainter(color: color)),
    );
  }
}

class FacebookLogo extends StatelessWidget {
  final double size;

  const FacebookLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2),
          borderRadius: BorderRadius.circular(size * 0.27),
          border: Border.all(color: const Color(0x14000000), width: 0.6),
        ),
        child: const CustomPaint(painter: _FacebookFPainter()),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tiny SVG path parser (subset: M/m L/l H/h V/v C/c S/s Q/q Z/z).
// ---------------------------------------------------------------------------
ui.Path _parseSvgPath(String data) {
  final path = ui.Path();
  var i = 0;
  var x = 0.0, y = 0.0;
  var subX = 0.0, subY = 0.0;
  var cmd = '';
  var lastWasCurve = false;
  var lastCx = 0.0, lastCy = 0.0;

  double nextNumber() {
    while (i < data.length &&
        (data[i] == ' ' ||
            data[i] == ',' ||
            data[i] == '\t' ||
            data[i] == '\n' ||
            data[i] == '\r')) {
      i++;
    }
    final start = i;
    var sawDot = false;
    if (i < data.length && (data[i] == '+' || data[i] == '-')) i++;
    while (i < data.length) {
      final c = data.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        i++;
      } else if (c == 46 && !sawDot) {
        sawDot = true;
        i++;
      } else {
        break;
      }
    }
    return double.parse(data.substring(start, i));
  }

  bool isCommand(String c) => RegExp(r'[A-Za-z]').hasMatch(c);

  while (i < data.length) {
    if (isCommand(data[i])) {
      cmd = data[i];
      i++;
      continue;
    }
    switch (cmd) {
      case 'M':
        x = nextNumber();
        y = nextNumber();
        path.moveTo(x, y);
        subX = x;
        subY = y;
        cmd = 'L';
        lastWasCurve = false;
      case 'm':
        x += nextNumber();
        y += nextNumber();
        path.moveTo(x, y);
        subX = x;
        subY = y;
        cmd = 'l';
        lastWasCurve = false;
      case 'L':
        x = nextNumber();
        y = nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'l':
        x += nextNumber();
        y += nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'H':
        x = nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'h':
        x += nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'V':
        y = nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'v':
        y += nextNumber();
        path.lineTo(x, y);
        lastWasCurve = false;
      case 'C':
        final c1x = nextNumber();
        final c1y = nextNumber();
        final c2x = nextNumber();
        final c2y = nextNumber();
        final ex = nextNumber();
        final ey = nextNumber();
        path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
        x = ex;
        y = ey;
        lastCx = c2x;
        lastCy = c2y;
        lastWasCurve = true;
      case 'c':
        final c1x = x + nextNumber();
        final c1y = y + nextNumber();
        final c2x = x + nextNumber();
        final c2y = y + nextNumber();
        final ex = x + nextNumber();
        final ey = y + nextNumber();
        path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
        lastCx = c2x;
        lastCy = c2y;
        x = ex;
        y = ey;
        lastWasCurve = true;
      case 'S':
        final c1x = lastWasCurve ? 2 * x - lastCx : x;
        final c1y = lastWasCurve ? 2 * y - lastCy : y;
        final c2x = nextNumber();
        final c2y = nextNumber();
        final ex = nextNumber();
        final ey = nextNumber();
        path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
        lastCx = c2x;
        lastCy = c2y;
        x = ex;
        y = ey;
        lastWasCurve = true;
      case 's':
        final c1x = lastWasCurve ? 2 * x - lastCx : x;
        final c1y = lastWasCurve ? 2 * y - lastCy : y;
        final c2x = x + nextNumber();
        final c2y = y + nextNumber();
        final ex = x + nextNumber();
        final ey = y + nextNumber();
        path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
        lastCx = c2x;
        lastCy = c2y;
        x = ex;
        y = ey;
        lastWasCurve = true;
      case 'Q':
        final qx = nextNumber();
        final qy = nextNumber();
        final ex = nextNumber();
        final ey = nextNumber();
        path.quadraticBezierTo(qx, qy, ex, ey);
        lastCx = qx;
        lastCy = qy;
        x = ex;
        y = ey;
        lastWasCurve = true;
      case 'q':
        final qx = x + nextNumber();
        final qy = y + nextNumber();
        final ex = x + nextNumber();
        final ey = y + nextNumber();
        path.quadraticBezierTo(qx, qy, ex, ey);
        lastCx = qx;
        lastCy = qy;
        x = ex;
        y = ey;
        lastWasCurve = true;
      case 'Z':
      case 'z':
        path.close();
        x = subX;
        y = subY;
        lastWasCurve = false;
    }
  }
  return path;
}

void _drawCentered(Canvas canvas, ui.Path source, Size size, Paint paint,
    {double fill = 1.0}) {
  final path = source;
  final bounds = path.getBounds();
  final scale =
      size.shortestSide * fill / (bounds.width > bounds.height ? bounds.width : bounds.height);
  canvas.save();
  canvas.translate(
    (size.width - bounds.width * scale) / 2 - bounds.left * scale,
    (size.height - bounds.height * scale) / 2 - bounds.top * scale,
  );
  canvas.scale(scale);
  canvas.drawPath(path, paint);
  canvas.restore();
}

// ---------------------------------------------------------------------------
// Google "G" mark (official 4-color paths, viewBox 0 0 24 24).
// ---------------------------------------------------------------------------
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  static const _bluePath = 'M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h'
      '5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 '
      '3.28-8.09z';
  static const _greenPath = 'M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c'
      '-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99'
      ' 20.53 7.7 23 12 23z';
  static const _yellowPath = 'M5.84 14.1c-.22-.66-.35-1.36-.35-2.1s.13-1.44'
      '.35-2.1V7.06H2.18C1.44 8.55 1 10.22 1 12s.44 3.45 1.18 4.94l3.66-2.84z';
  static const _redPath = 'M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45'
      '2.09 14.97 1 12 1C7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53'
      ' 6.16-4.53z';

  static final List<(ui.Path, Color)> _parts = [
    (_parseSvgPath(_bluePath), _blue),
    (_parseSvgPath(_greenPath), _green),
    (_parseSvgPath(_yellowPath), _yellow),
    (_parseSvgPath(_redPath), _red),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide * 0.92 / 24.0;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-12, -12);
    for (final (path, color) in _parts) {
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Facebook "f" glyph (official white f on brand blue tile).
// ---------------------------------------------------------------------------
class _FacebookFPainter extends CustomPainter {
  const _FacebookFPainter();

  static const _fPath = 'M279.14 288l14.22-92.66h-88.91v-60.13c0-25.35 '
      '12.42-50.06 52.24-50.06h40.42V6.26S260.43 0 225.36 0c-73.22 0-121.08 '
      '44.38-121.08 124.72v70.62H22.89V288h81.39v224h100.17V288z';

  static final ui.Path _f = _parseSvgPath(_fPath);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    _drawCentered(
      canvas,
      _f,
      canvasSize,
      Paint()..color = Colors.white,
      fill: 0.78,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Apple logo (Simple Icons vector path, viewBox 0 0 24 24).
// ---------------------------------------------------------------------------
class _ApplePainter extends CustomPainter {
  final Color color;

  const _ApplePainter({required this.color});

  ui.Path _applePath() {
    return Path()
      ..moveTo(12.152, 6.896)
      ..cubicTo(11.204, 6.896, 9.737, 5.818, 8.192, 5.856)
      ..cubicTo(6.152, 5.883, 4.282, 7.039, 3.231, 8.870)
      ..cubicTo(1.114, 12.545, 2.685, 17.973, 4.750, 20.960)
      ..cubicTo(5.763, 22.414, 6.958, 24.050, 8.542, 23.999)
      ..cubicTo(10.062, 23.934, 10.632, 23.012, 12.477, 23.012)
      ..cubicTo(14.308, 23.012, 14.827, 23.999, 16.437, 23.960)
      ..cubicTo(18.074, 23.934, 19.113, 22.480, 20.113, 21.012)
      ..cubicTo(21.269, 19.324, 21.749, 17.687, 21.775, 17.597)
      ..cubicTo(21.736, 17.584, 18.593, 16.376, 18.555, 12.740)
      ..cubicTo(18.529, 9.700, 21.035, 8.246, 21.152, 8.181)
      ..cubicTo(19.723, 6.091, 17.529, 5.857, 16.762, 5.805)
      ..cubicTo(14.762, 5.649, 13.087, 6.895, 12.152, 6.895)
      ..close()
      ..moveTo(15.53, 3.83)
      ..cubicTo(16.373, 2.818, 16.93, 1.403, 16.775, 0.0)
      ..cubicTo(15.568, 0.052, 14.113, 0.805, 13.243, 1.818)
      ..cubicTo(12.463, 2.714, 11.789, 4.156, 11.97, 5.532)
      ..cubicTo(13.308, 5.636, 14.685, 4.844, 15.53, 3.83)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawCentered(canvas, _applePath(), size, Paint()..color = color,
        fill: 0.92);
  }

  @override
  bool shouldRepaint(covariant _ApplePainter oldDelegate) => oldDelegate.color != color;
}
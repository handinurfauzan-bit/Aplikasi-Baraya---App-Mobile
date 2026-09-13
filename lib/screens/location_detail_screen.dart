import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';

class LocationDetailScreen extends StatelessWidget {
  final String communityName;
  final Event event;

  const LocationDetailScreen({
    super.key,
    required this.communityName,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayName = DateFormat('EEEE', 'id_ID').format(event.dateTime);
    final dayNum = DateFormat('d', 'id_ID').format(event.dateTime);
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(event.dateTime);
    final timeStr = DateFormat('HH:mm', 'id_ID').format(event.dateTime);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Lokasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            Text(
              communityName,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _MapPainter()),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Lokasi Event',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 52,
                          color: colorScheme.primary,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '$dayName, $dayNum $monthYear',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pukul $timeStr WIB',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Penjelasan Lokasi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF3EFE2),
    );

    final grid = Paint()
      ..color = const Color(0xFFE3DCC9)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    final park = Paint()..color = const Color(0xFFCBE6C4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.10, w * 0.26, h * 0.30),
        const Radius.circular(8),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.14, w * 0.30, h * 0.20),
        const Radius.circular(8),
      ),
      park,
    );

    final building = Paint()..color = const Color(0xFFE6E0CE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.50, w * 0.18, h * 0.20),
        const Radius.circular(6),
      ),
      building,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.74, h * 0.36, w * 0.18, h * 0.22),
        const Radius.circular(6),
      ),
      building,
    );

    final river = Paint()
      ..color = const Color(0xFFB7D6E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final riverPath = Path()
      ..moveTo(w * 0.58, h * 0.02)
      ..cubicTo(w * 0.64, h * 0.22, w * 0.52, h * 0.34, w * 0.60, h * 0.52)
      ..cubicTo(w * 0.66, h * 0.66, w * 0.54, h * 0.80, w * 0.62, h * 0.98);
    canvas.drawPath(riverPath, river);

    final roadCasing = Paint()
      ..color = const Color(0xFFDBD4C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final roadA = Path()
      ..moveTo(w * 0.02, h * 0.30)
      ..quadraticBezierTo(w * 0.5, h * 0.40, w * 0.98, h * 0.28);
    canvas.drawPath(roadA, roadCasing);
    canvas.drawPath(roadA, road);

    final roadB = Path()
      ..moveTo(w * 0.42, h * 0.02)
      ..quadraticBezierTo(w * 0.34, h * 0.5, w * 0.44, h * 0.98);
    canvas.drawPath(roadB, roadCasing);
    canvas.drawPath(roadB, road);

    final roadC = Path()
      ..moveTo(w * 0.06, h * 0.88)
      ..quadraticBezierTo(w * 0.5, h * 0.70, w * 0.98, h * 0.62);
    canvas.drawPath(roadC, roadCasing);
    canvas.drawPath(roadC, road);

    final routeDash = Paint()
      ..color = const Color(0xFF16A34A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(w * 0.10, h * 0.86)
      ..quadraticBezierTo(w * 0.30, h * 0.62, w * 0.5, h * 0.52);
    for (final metric in route.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(
          metric.extractPath(d, d + 5),
          routeDash,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
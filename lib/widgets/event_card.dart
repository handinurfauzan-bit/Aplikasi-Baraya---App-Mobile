import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../utils/countdown.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;
  final ValueChanged<String>? onRSVP;
  final VoidCallback? onToggleReminder;
  final int taskCount;

  const EventCard({
    super.key,
    required this.event,
    required this.currentUserId,
    this.isSelected = false,
    required this.onTap,
    this.onRSVP,
    this.onToggleReminder,
    this.taskCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final myRsvp = event.rsvps[currentUserId];

    return Card(
      elevation: isSelected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(colorScheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      _buildReminderButton(colorScheme),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 15, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_alt_outlined,
                              size: 16, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${event.joinedCount} Ikut',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (event.maybeCount > 0) ...[
                            Text(
                              ' • ${event.maybeCount} Ragu',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRsvpOption(
                            label: 'Ikut',
                            icon: Icons.check,
                            isSelected: myRsvp == 'joined',
                            selectedColor: Colors.green.shade700,
                            selectedBg: Colors.green.shade50,
                            colorScheme: colorScheme,
                            onTap: () => onRSVP?.call('joined'),
                          ),
                          const SizedBox(width: 6),
                          _buildRsvpOption(
                            label: 'Ragu',
                            icon: Icons.help_outline,
                            isSelected: myRsvp == 'maybe',
                            selectedColor: Colors.orange.shade800,
                            selectedBg: Colors.orange.shade50,
                            colorScheme: colorScheme,
                            onTap: () => onRSVP?.call('maybe'),
                          ),
                          const SizedBox(width: 6),
                          _buildRsvpOption(
                            label: 'Gak',
                            icon: Icons.close,
                            isSelected: myRsvp == 'declined',
                            selectedColor: Colors.red.shade700,
                            selectedBg: Colors.red.shade50,
                            colorScheme: colorScheme,
                            onTap: () => onRSVP?.call('declined'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(ColorScheme colorScheme) {
    final dayName = DateFormat('EEE').format(event.dateTime).toUpperCase();
    final dayNum = DateFormat('d').format(event.dateTime);
    final monthName = DateFormat('MMM').format(event.dateTime).toUpperCase();
    final timeStr = DateFormat('HH:mm').format(event.dateTime);

    return Container(
      height: 168,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -24,
            top: -28,
            child: _bannerCircle(120, 0.14),
          ),
          Positioned(
            left: -20,
            bottom: -36,
            child: _bannerCircle(150, 0.1),
          ),
          Positioned(
            right: 40,
            bottom: -12,
            child: _bannerCircle(60, 0.12),
          ),
          Icon(
            _bannerIcon(),
            size: 86,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildBannerCountdown(colorScheme),
          ),
          if (taskCount > 0)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.checklist, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '$taskCount tugas',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _buildDatePill(
                colorScheme, dayName, dayNum, monthName, timeStr),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePill(
    ColorScheme colorScheme,
    String dayName,
    String dayNum,
    String monthName,
    String timeStr,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayNum,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 26,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(width: 10),
          Icon(Icons.schedule, size: 15, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCountdown(ColorScheme colorScheme) {
    final color = _countdownColor(colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_countdownIcon(), size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            countdownLabel(event.dateTime),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerCircle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  IconData _bannerIcon() {
    final t = event.title.toLowerCase();
    if (t.contains('gowes') ||
        t.contains('sepeda') ||
        t.contains('touring') ||
        t.contains('ride')) {
      return Icons.directions_bike;
    }
    if (t.contains('workshop') ||
        t.contains('servis') ||
        t.contains('belajar') ||
        t.contains('pelatihan')) {
      return Icons.build_circle_outlined;
    }
    if (t.contains('kopdar') ||
        t.contains('ngopi') ||
        t.contains('makan') ||
        t.contains('buka puasa')) {
      return Icons.local_cafe_outlined;
    }
    if (t.contains('foto') ||
        t.contains('photo') ||
        t.contains('hunting') ||
        t.contains('shooting')) {
      return Icons.photo_camera_outlined;
    }
    if (t.contains('lari') || t.contains('marathon') || t.contains('run')) {
      return Icons.directions_run;
    }
    return Icons.event_available;
  }

  Widget _buildReminderButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        event.reminderSet
            ? Icons.notifications_active
            : Icons.notifications_none_outlined,
        color: event.reminderSet
            ? Colors.amber.shade700
            : colorScheme.onSurfaceVariant,
        size: 22,
      ),
      tooltip:
          event.reminderSet ? 'Pengingat H-1 aktif' : 'Nyalakan pengingat H-1',
      visualDensity: VisualDensity.compact,
      onPressed: onToggleReminder,
    );
  }

  Widget _buildRsvpOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBg,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedBg
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected ? selectedColor : colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected ? selectedColor : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _countdownColor(ColorScheme colorScheme) {
    final days = DateTime.now().difference(event.dateTime).inDays;
    if (days < 0) return colorScheme.outline;
    if (days == 0) return Colors.red.shade700;
    if (days == 1) return Colors.orange.shade800;
    return colorScheme.primary;
  }

  IconData _countdownIcon() {
    final days = DateTime.now().difference(event.dateTime).inDays;
    if (days < 0) return Icons.check_circle_outline;
    if (days == 0) return Icons.alarm_on;
    return Icons.hourglass_top;
  }
}

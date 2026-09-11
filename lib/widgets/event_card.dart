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

    final dayName = DateFormat('EEE').format(event.dateTime).toUpperCase();
    final dayNum = DateFormat('dd').format(event.dateTime);
    final monthName = DateFormat('MMM').format(event.dateTime).toUpperCase();
    final timeStr = DateFormat('HH:mm').format(event.dateTime);

    return Card(
      elevation: isSelected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Date Badge + Title/Time + Reminder button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date box
                  Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          dayNum,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          monthName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '$timeStr WIB',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (taskCount > 0) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.checklist, size: 12, color: colorScheme.onSecondaryContainer),
                                    const SizedBox(width: 3),
                                    Text(
                                      '$taskCount tugas',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (event.location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: colorScheme.onSurfaceVariant),
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
                      ],
                    ),
                  ),

                  // H-1 Reminder action
                  IconButton(
                    icon: Icon(
                      event.reminderSet
                          ? Icons.notifications_active
                          : Icons.notifications_none_outlined,
                      color: event.reminderSet
                          ? Colors.amber.shade700
                          : colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    tooltip: event.reminderSet
                        ? 'Pengingat H-1 aktif'
                        : 'Nyalakan pengingat H-1',
                    onPressed: onToggleReminder,
                  ),
                ],
              ),

              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Countdown chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _countdownColor(colorScheme).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _countdownColor(colorScheme).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _countdownIcon(),
                      size: 14,
                      color: _countdownColor(colorScheme),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      countdownLabel(event.dateTime),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _countdownColor(colorScheme),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // RSVP Bar & Participant Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Attendees count
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 16, color: colorScheme.primary),
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

                  // RSVP action buttons
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
      ),
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
          color: isSelected ? selectedBg : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
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
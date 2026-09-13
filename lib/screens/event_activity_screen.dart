import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../widgets/compact_event_card.dart';
import 'event_detail_screen.dart';

class EventActivityScreen extends StatelessWidget {
  final String communityId;

  const EventActivityScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final colorScheme = Theme.of(context).colorScheme;
    final community = dataService.getCommunity(communityId);

    final events = dataService.getEventsForCommunity(communityId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            Text(
              community?.name ?? 'Komunitas',
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
          Text(
            '${events.length} event tersedia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            _buildEmptyCard(colorScheme)
          else
            ...events.map(
              (event) => CompactEventCard(
                event: event,
                currentUserId: dataService.currentUserId,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(
                        communityId: communityId,
                        eventId: event.id,
                      ),
                    ),
                  );
                },
                onRSVP: (status) => dataService.setRSVP(event.id, status),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 34,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada event komunitas.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Event yang dibuat di komunitas ini akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

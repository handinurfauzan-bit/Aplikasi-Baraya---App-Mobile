import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings.dart';
import '../services/data_service.dart';
import '../widgets/announcement_feed.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    final colorScheme = Theme.of(context).colorScheme;
    final community = dataService.getCommunity(settings.communityId);
    final announcements =
        dataService.getAnnouncementsForCommunity(settings.communityId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            'Notifikasi',
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
      body: announcements.isEmpty
          ? Center(
              child: Text(
                'Belum ada notifikasi.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AnnouncementFeed(
                  announcements: announcements,
                  onTogglePin: (id) {
                    dataService.togglePinAnnouncement(id);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/data_service.dart';
import '../widgets/announcement_feed.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            const Text('Notifikasi'),
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_outlined,
                          color: Colors.green.shade800, size: 24),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Info penting & pengumuman terbaru dari pengurus komunitasmu.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                AnnouncementFeed(
                  announcements: announcements,
                  onTogglePin: (id) {
                    dataService.togglePinAnnouncement(id);
                  },
                  onAnnouncementTap: (ann) =>
                      _showDetail(context, dataService, ann),
                ),
              ],
            ),
    );
  }

  void _showDetail(
      BuildContext context, DataService dataService, Announcement ann) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ann.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ann.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Oleh ${ann.authorName} • ${DateFormat('d MMMM yyyy, HH:mm').format(ann.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                ann.body,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
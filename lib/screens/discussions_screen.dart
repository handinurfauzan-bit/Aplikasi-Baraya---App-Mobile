import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/data_service.dart';
import 'community_detail_screen.dart';

class DiscussionsScreen extends StatelessWidget {
  const DiscussionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final communities = dataService.getAllCommunities();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Diskusi'),
            Text(
              'Pilih komunitas untuk membuka diskusi',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: communities.isEmpty
          ? const Center(child: Text('Belum ada komunitas.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: communities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = communities[index];
                final isActive = c.id == settings.communityId;
                final events = dataService.getEventsForCommunity(c.id);
                return _DiscussionCommunityCard(
                  community: c,
                  isActive: isActive,
                  memberCount: c.members.length,
                  eventCount: events.length,
                  onTap: () {
                    settings.selectCommunity(c.id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CommunityDiscussionScreen(communityId: c.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _DiscussionCommunityCard extends StatelessWidget {
  final Community community;
  final bool isActive;
  final int memberCount;
  final int eventCount;
  final VoidCallback onTap;

  const _DiscussionCommunityCard({
    required this.community,
    required this.isActive,
    required this.memberCount,
    required this.eventCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: community.logo.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          community.logo,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text(
                        community.name.isNotEmpty
                            ? community.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            community.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$memberCount anggota • ${community.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$eventCount event • Buka diskusi komunitas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.forum, size: 20, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
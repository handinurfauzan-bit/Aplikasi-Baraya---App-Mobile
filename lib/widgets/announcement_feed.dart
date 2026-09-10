import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class AnnouncementFeed extends StatefulWidget {
  final List<Announcement> announcements;
  final ValueChanged<String>? onTogglePin;
  final ValueChanged<Announcement>? onAnnouncementTap;

  const AnnouncementFeed({
    super.key,
    required this.announcements,
    this.onTogglePin,
    this.onAnnouncementTap,
  });

  @override
  State<AnnouncementFeed> createState() => _AnnouncementFeedState();
}

class _AnnouncementFeedState extends State<AnnouncementFeed> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categories = ['Semua', 'Disematkan', 'Penting', 'Keuangan', 'Aturan', 'Umum'];

    final filtered = widget.announcements.where((a) {
      if (_selectedCategory == 'Semua') return true;
      if (_selectedCategory == 'Disematkan') return a.pinned;
      return a.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    cat == 'Disematkan' ? '📌 Disematkan' : cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        if (filtered.isEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.feed_outlined, size: 48, color: colorScheme.outline),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada pengumuman di kategori ini',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        ] else ...[
          ...filtered.map((ann) => _buildAnnouncementCard(context, ann)),
        ],
      ],
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Announcement ann) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color categoryColor;
    Color categoryBg;

    switch (ann.category.toLowerCase()) {
      case 'penting':
        categoryColor = Colors.red.shade700;
        categoryBg = Colors.red.shade50;
        break;
      case 'keuangan':
        categoryColor = Colors.green.shade800;
        categoryBg = Colors.green.shade50;
        break;
      case 'aturan':
        categoryColor = Colors.deepOrange.shade800;
        categoryBg = Colors.deepOrange.shade50;
        break;
      default:
        categoryColor = colorScheme.primary;
        categoryBg = colorScheme.primaryContainer.withValues(alpha: 0.5);
    }

    final timeString = _formatRelativeTime(ann.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: ann.pinned ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: ann.pinned
              ? Colors.amber.shade300
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: ann.pinned ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onAnnouncementTap?.call(ann),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: ann.pinned ? Colors.amber.withValues(alpha: 0.04) : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Pinned Badge + Category + Pin Button
              Row(
                children: [
                  if (ann.pinned) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 12, color: Colors.amber.shade900),
                          const SizedBox(width: 3),
                          Text(
                            'PINNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ann.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: categoryColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Pin / Unpin button
                  IconButton(
                    icon: Icon(
                      ann.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                      color: ann.pinned ? Colors.amber.shade800 : colorScheme.outline,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: ann.pinned ? 'Lepas Sematan' : 'Sematkan Pengumuman',
                    onPressed: () => widget.onTogglePin?.call(ann.id),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                ann.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              // Body
              Text(
                ann.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Author & Time
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      ann.authorName.isNotEmpty ? ann.authorName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ann.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    timeString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 0 ? 1 : diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('d MMM').format(dateTime);
    }
  }
}
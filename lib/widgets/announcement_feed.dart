import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class AnnouncementFeed extends StatelessWidget {
  final List<Announcement> announcements;
  final ValueChanged<String>? onTogglePin;

  const AnnouncementFeed({
    super.key,
    required this.announcements,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: announcements.map((ann) {
        return _ExpandableAnnouncementCard(
          key: ValueKey(ann.id),
          ann: ann,
          onTogglePin: onTogglePin,
        );
      }).toList(),
    );
  }
}

class _ExpandableAnnouncementCard extends StatefulWidget {
  final Announcement ann;
  final ValueChanged<String>? onTogglePin;

  const _ExpandableAnnouncementCard({
    super.key,
    required this.ann,
    this.onTogglePin,
  });

  @override
  State<_ExpandableAnnouncementCard> createState() =>
      _ExpandableAnnouncementCardState();
}

class _ExpandableAnnouncementCardState
    extends State<_ExpandableAnnouncementCard> {
  bool _expanded = false;

  _CategoryStyle get _style => _categoryStyle(widget.ann.category);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ann = widget.ann;
    final expanded = _expanded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: expanded
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded
              ? _style.color.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        onExpansionChanged: (value) => setState(() => _expanded = value),
        tilePadding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.onSurfaceVariant,
        collapsedIconColor: colorScheme.onSurfaceVariant,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _style.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_style.icon, size: 21, color: _style.color),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                ann.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
            if (ann.pinned) ...[
              const SizedBox(width: 6),
              Icon(Icons.push_pin, size: 15, color: Colors.amber.shade800),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _style.bg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  ann.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: _style.color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatRelativeTime(ann.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        children: [
          const SizedBox(height: 4),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            ann.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  ann.authorName.isNotEmpty
                      ? ann.authorName[0].toUpperCase()
                      : '?',
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
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (widget.onTogglePin != null)
                IconButton(
                  icon: Icon(
                    ann.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: ann.pinned
                        ? Colors.amber.shade800
                        : colorScheme.outline,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: ann.pinned ? 'Lepas Sematan' : 'Sematkan Pengumuman',
                  onPressed: () => widget.onTogglePin?.call(ann.id),
                ),
            ],
          ),
        ],
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

class _CategoryStyle {
  final IconData icon;
  final Color color;
  final Color bg;

  const _CategoryStyle({
    required this.icon,
    required this.color,
    required this.bg,
  });
}

_CategoryStyle _categoryStyle(String category) {
  switch (category.toLowerCase()) {
    case 'penting':
      return _CategoryStyle(
        icon: Icons.campaign_outlined,
        color: Colors.red.shade700,
        bg: Colors.red.shade50,
      );
    case 'keuangan':
      return _CategoryStyle(
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green.shade800,
        bg: Colors.green.shade50,
      );
    case 'aturan':
      return _CategoryStyle(
        icon: Icons.rule_outlined,
        color: Colors.deepOrange.shade800,
        bg: Colors.deepOrange.shade50,
      );
    default:
      return const _CategoryStyle(
        icon: Icons.campaign_outlined,
        color: Color(0xFF15803D),
        bg: Color(0xFFE7F4EC),
      );
  }
}
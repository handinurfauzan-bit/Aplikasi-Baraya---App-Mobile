import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/data_service.dart';
import '../widgets/task_card.dart';
import 'members_screen.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String communityId;

  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(communityId);

    if (community == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Komunitas')),
        body: const Center(child: Text('Komunitas tidak ditemukan.')),
      );
    }

    final membersCount = community.members.length;
    final tasks = dataService.getAllTasksForCommunity(communityId);
    final isMember =
        community.members.any((m) => m.id == dataService.currentUserId);
    final isAdmin = community.adminId == dataService.currentUserId;
    final eventLocations = dataService
        .getEventsForCommunity(communityId)
        .where((e) => e.location.isNotEmpty)
        .length;

    final menus = <({String label, String subtitle, IconData icon, Widget page})>[
      (
        label: 'Lihat Anggota',
        subtitle: '$membersCount anggota • role admin & pengurus',
        icon: Icons.people_alt_outlined,
        page: MembersScreen(communityId: communityId),
      ),
      (
        label: 'Tugas dari Admin',
        subtitle: '${tasks.length} tugas panitia untuk dikerjakan',
        icon: Icons.checklist,
        page: CommunityTasksScreen(communityId: communityId),
      ),
      (
        label: 'Diskusi',
        subtitle: 'Tanya jawab & komentar sesama anggota',
        icon: Icons.forum_outlined,
        page: CommunityDiscussionScreen(communityId: communityId),
      ),
      (
        label: 'Kas Komunitas',
        subtitle: 'Iuran, pemasukan, dan pengeluaran',
        icon: Icons.account_balance_wallet_outlined,
        page: CommunityTreasuryScreen(communityId: communityId),
      ),
      (
        label: 'Lokasi Event',
        subtitle: '$eventLocations lokasi kegiatan komunitas',
        icon: Icons.map_outlined,
        page: CommunityLocationsScreen(communityId: communityId),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Detail Komunitas • $membersCount anggota',
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
          _CommunityHeader(
            community: community,
            isMember: isMember,
            isAdmin: isAdmin,
            onJoin: () {
              dataService.joinCommunity(communityId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kamu bergabung ke ${community.name}!'),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Fitur Komunitas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola komunitasmu lewat fitur-fitur di bawah ini.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...menus.map(
            (m) => _FeatureTile(
              icon: m.icon,
              label: m.label,
              subtitle: m.subtitle,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => m.page),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  final Community community;
  final bool isMember;
  final bool isAdmin;
  final VoidCallback? onJoin;

  const _CommunityHeader({
    required this.community,
    required this.isMember,
    required this.isAdmin,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primary,
              child: community.logo.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(7),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      community.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    community.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isMember && onJoin != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onJoin,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Bergabung ke Komunitas'),
                      ),
                    )
                  else if (isMember && isAdmin)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings,
                                size: 15, color: colorScheme.primary),
                            const SizedBox(width: 5),
                            Text(
                              'Anda Admin Komunitas ini',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isMember)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 15, color: Colors.green),
                            const SizedBox(width: 5),
                            Text(
                              'Anda sudah bergabung',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
      ),
    );
  }
}

class CommunityTasksScreen extends StatelessWidget {
  final String communityId;

  const CommunityTasksScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(communityId);
    final tasks = dataService.getAllTasksForCommunity(communityId);
    final done = tasks.where((t) => t.isCompleted).length;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
    final isAdmin =
        community != null && community.adminId == dataService.currentUserId;
    final members = community?.members ?? const <User>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tugas dari Admin'),
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
          Card(
            elevation: 0,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Tugas Panitia',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$done dari $tasks.length selesai',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Text(
                'Belum ada tugas yang diberikan admin.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...tasks.map((task) {
              final event = dataService.getEvent(task.eventId);
              final assignees = task.assigneeIds
                  .map((id) => dataService.getUser(id))
                  .whereType<User>()
                  .toList();
              return TaskCard(
                task: task,
                eventTitle: event?.title,
                assignees: assignees,
                onToggle: () => dataService.toggleTask(task.id),
                onDelete: isAdmin
                    ? () => dataService.deleteTask(task.id)
                    : null,
              );
            }),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showAddTaskSheet(context, dataService, members),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add_task),
              label: const Text('Tambah Tugas'),
            )
          : null,
    );
  }

  void _showAddTaskSheet(
    BuildContext context,
    DataService dataService,
    List<User> members,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedIds = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sheetColor = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tambah Tugas Anggota',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Admin dapat membagi tugas untuk anggota komunitas.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        hintText: 'misal: Siapkan konsumsi kopdar',
                        prefixIcon: Icon(Icons.checklist),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        hintText: 'Detail tugas yang perlu dikerjakan...',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Untuk Anggota',
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: members.map((m) {
                        final selected = selectedIds.contains(m.id);
                        return FilterChip(
                          avatar: CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                Theme.of(ctx).colorScheme.primaryContainer,
                            child: Text(
                              m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(ctx)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                          label: Text(m.name.split(' ').first),
                          selected: selected,
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedIds.add(m.id);
                              } else {
                                selectedIds.remove(m.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (selectedIds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Pilih minimal satu anggota.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: sheetColor.primary,
                          foregroundColor: sheetColor.onPrimary,
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty || selectedIds.isEmpty) return;
                          dataService.addTask(
                            Task(
                              id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                              eventId: '',
                              communityId: communityId,
                              title: title,
                              description: descController.text.trim(),
                              assigneeIds: selectedIds.toList(),
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tugas "$title" berhasil ditambahkan!'),
                              backgroundColor: Colors.green.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_task),
                        label: const Text('Simpan Tugas'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Thread {
  final String author;
  final String role;
  final String time;
  final String text;
  final List<String> replies;

  const _Thread({
    required this.author,
    required this.role,
    required this.time,
    required this.text,
    required this.replies,
  });
}

class CommunityDiscussionScreen extends StatefulWidget {
  final String communityId;

  const CommunityDiscussionScreen({super.key, required this.communityId});

  @override
  State<CommunityDiscussionScreen> createState() =>
      _CommunityDiscussionScreenState();
}

class _CommunityDiscussionScreenState extends State<CommunityDiscussionScreen> {
  final TextEditingController _inputController = TextEditingController();
  List<_Thread> _threads = const [];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  List<_Thread> _seed(DataService dataService) {
    final community = dataService.getCommunity(widget.communityId);
    final events = dataService.getEventsForCommunity(widget.communityId);
    final nextEvent = events.isNotEmpty ? events.first : null;

    final threads = <_Thread>[
      _Thread(
        author: 'Farhan Wijaya',
        role: 'Ketua Komunitas',
        time: '2 jam lalu',
        text:
            'Halo semuanya! Selamat bergabung di ${community?.name ?? 'komunitas ini'}. Silakan kenalan dan langsung tanya apa saja di sini ya!',
        replies: const [
          'Welcome bang!',
          'Siap Ketua, salam kenal semua!',
        ],
      ),
      if (nextEvent != null)
        _Thread(
          author: 'Yusuf Ramadhan',
          role: 'Koordinator Lokasi',
          time: '40 menit lalu',
          text:
              'Teman-teman, untuk titik kumpul ${nextEvent.title} apakah tetap di ${nextEvent.location}? Mohon konfirmasinya sebelum H-1 ya.',
          replies: const [
            'Tetap, sudah cek lokasi kemarin.',
            'Oke, capcus!',
          ],
        ),
      const _Thread(
        author: 'Anggota Komunitas',
        role: 'Anggota',
        time: '5 menit lalu',
        text:
            'Ada info kapan jadwal kumpul rutin bulan depan? Semoga nggak bentrok sama kerjaan hehe.',
        replies: [],
      ),
    ];
    return threads;
  }

  void _postMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _threads = [
        _Thread(
          author: 'Dimas Aditya',
          role: 'Anggota Aktif',
          time: 'Baru saja',
          text: text,
          replies: const [],
        ),
        ..._threads,
      ];
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(widget.communityId);

    if (_threads.isEmpty) {
      _threads = _seed(dataService);
    }

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
              community?.name ?? 'Komunitas',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _DiscussionCard(thread: _threads[index]),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              color: colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Tulis diskusi...',
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _postMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _postMessage,
                    icon: const Icon(Icons.send),
                    color: colorScheme.onPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final _Thread thread;

  const _DiscussionCard({required this.thread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    thread.author.isNotEmpty ? thread.author[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${thread.role} • ${thread.time}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              thread.text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            if (thread.replies.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...thread.replies.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.reply,
                            size: 14, color: colorScheme.outline),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _KasEntry {
  final String title;
  final String date;
  final String nominal;
  final bool isIncome;

  const _KasEntry({
    required this.title,
    required this.date,
    required this.nominal,
    required this.isIncome,
  });
}

class CommunityTreasuryScreen extends StatelessWidget {
  final String communityId;

  const CommunityTreasuryScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(communityId);
    final members = community?.members ?? const <User>[];
    final treasury = dataService.getTreasuryInfo(communityId);

    final monthlyIuran = treasury.monthlyIuran;
    final saldo = treasury.saldo;
    final totalIn = treasury.totalIn;
    final totalOut = treasury.totalOut;
    final entries = treasury.entries
        .map(
          (e) => _KasEntry(
            title: e.title,
            date: e.date,
            nominal: _formatRupiah(e.nominal),
            isIncome: e.isIncome,
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kas Komunitas'),
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Kas Komunitas',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp $saldo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _kasStat(
                      label: 'Pemasukan',
                      value: _formatRupiah(totalIn),
                      icon: Icons.south_west,
                    ),
                    const SizedBox(width: 24),
                    _kasStat(
                      label: 'Pengeluaran',
                      value: _formatRupiah(totalOut),
                      icon: Icons.north_east,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Status Iuran Anggota',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Iuran bulanan ${_formatRupiah(monthlyIuran)} • ${members.length} orang',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...members.map(
            (m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(m.name, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  m.role,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Lunas',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Riwayat Transaksi',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...entries.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (e.isIncome
                            ? Colors.green
                            : colorScheme.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    e.isIncome ? Icons.south_west : Icons.north_east,
                    size: 18,
                    color: e.isIncome ? Colors.green.shade700 : colorScheme.error,
                  ),
                ),
                title: Text(e.title, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  e.date,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  e.nominal,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: e.isIncome
                        ? Colors.green.shade700
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kasStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatRupiah(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'Rp $buffer';
  }
}

class CommunityLocationsScreen extends StatelessWidget {
  final String communityId;

  const CommunityLocationsScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(communityId);
    final events = dataService
        .getEventsForCommunity(communityId)
        .where((e) => e.location.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lokasi Event'),
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
      body: events.isEmpty
          ? const Center(child: Text('Belum ada lokasi event.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = events[index];
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
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.location_on,
                              color: colorScheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                e.location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Buka Navigasi',
                          icon: Icon(Icons.navigation_outlined,
                              color: colorScheme.primary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Navigasi menuju ${e.location} akan segera hadir.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
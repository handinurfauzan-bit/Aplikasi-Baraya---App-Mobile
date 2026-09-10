import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../widgets/announcement_feed.dart';
import '../widgets/event_card.dart';
import '../widgets/task_card.dart';
import 'event_detail_screen.dart';
import 'members_screen.dart';

class HomeScreen extends StatefulWidget {
  final String communityId;
  final NotificationService? notificationService;

  const HomeScreen({
    super.key,
    this.communityId = 'kumpul_001',
    this.notificationService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final NotificationService _notificationService;
  String _taskFilterEventId = 'all';
  String _communityId = 'kumpul_001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _notificationService = widget.notificationService ?? NotificationService();
    _notificationService.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    _communityId = settings.communityId;
    final community = dataService.getCommunity(_communityId);
    final events = dataService.getEventsForCommunity(_communityId);
    final announcements = dataService.getAnnouncementsForCommunity(_communityId);
    final allTasks = dataService.getAllTasksForCommunity(_communityId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community?.name ?? 'Kumpul.in',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${community?.members.length ?? 0} Anggota • ${community?.category ?? 'Komunitas'}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Ganti Komunitas',
            onPressed: () => _showCommunitySwitcher(context),
          ),
          IconButton(
            icon: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: settings.themeMode == ThemeMode.dark
                ? 'Ganti ke Mode Terang'
                : 'Ganti ke Mode Gelap',
            onPressed: () => _toggleTheme(settings),
          ),
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Daftar Anggota',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MembersScreen(communityId: _communityId),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.calendar_month, size: 20),
              text: 'Event (${events.length})',
            ),
            Tab(
              icon: const Icon(Icons.campaign, size: 20),
              text: 'Pengumuman (${announcements.length})',
            ),
            Tab(
              icon: const Icon(Icons.checklist, size: 20),
              text: 'Tugas (${allTasks.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: EVENT & JADWAL
          _buildEventsTab(dataService, events),

          // TAB 2: PENGUMUMAN TERPISAH
          _buildAnnouncementsTab(dataService, announcements),

          // TAB 3: PEMBAGIAN TUGAS
          _buildTasksTab(dataService, events, allTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddEventDialog(context, dataService);
          } else if (_tabController.index == 1) {
            _showAddAnnouncementDialog(context, dataService);
          } else {
            _showAddTaskDialog(context, dataService, events);
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: Icon(_getFabIcon()),
        label: Text(_getFabLabel()),
      ),
    );
  }

  IconData _getFabIcon() {
    switch (_tabController.index) {
      case 0:
        return Icons.add_alarm;
      case 1:
        return Icons.post_add;
      default:
        return Icons.add_task;
    }
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Buat Event';
      case 1:
        return 'Pengumuman Baru';
      default:
        return 'Tambah Tugas';
    }
  }

  // ==================== TAB 1: EVENTS ====================
  Widget _buildEventsTab(DataService dataService, List<Event> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Belum ada event jadwal komunitas.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text('Tekan tombol "Buat Event" untuk membuat jadwal baru!'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ketuk event untuk lihat detail, RSVP, dan tugas panitia.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Events List
        ...events.map((event) {
          final tasks = dataService.getTasksForEvent(event.id);

          return EventCard(
            event: event,
            currentUserId: dataService.currentUserId,
            isSelected: false,
            taskCount: tasks.length,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(
                    communityId: _communityId,
                    eventId: event.id,
                  ),
                ),
              );
            },
            onRSVP: (status) {
              dataService.setRSVP(event.id, status);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    status == 'joined'
                        ? 'Anda konfirmasi Ikut pada "${event.title}"! 🎉'
                        : status == 'maybe'
                            ? 'Status Anda diubah ke Ragu-ragu.'
                            : 'Status Anda diubah ke Tidak Ikut.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onToggleReminder: () async {
              final newStatus = !event.reminderSet;
              dataService.toggleEventReminder(event.id, newStatus);
              if (newStatus) {
                await _notificationService.scheduleH1Reminder(
                  id: event.id.hashCode,
                  eventTitle: event.title,
                  eventDateTime: event.dateTime,
                  location: event.location,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⏰ Pengingat H-1 aktif untuk "${event.title}"'),
                      backgroundColor: Colors.teal.shade700,
                    ),
                  );
                }
              } else {
                await _notificationService.cancel(event.id.hashCode);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pengingat dimatikan untuk "${event.title}"'),
                    ),
                  );
                }
              }
            },
          );
        }),

        const SizedBox(height: 72),
      ],
    );
  }

  // ==================== TAB 2: PENGUMUMAN ====================
  Widget _buildAnnouncementsTab(
      DataService dataService, List<Announcement> announcements) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Explanatory Header
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, color: Colors.amber.shade900, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Feed khusus info penting komunitas agar tidak tertimbun obrolan chat harian.',
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
          onAnnouncementTap: (ann) {
            _showAnnouncementDetailSheet(context, ann);
          },
        ),

        const SizedBox(height: 72),
      ],
    );
  }

  // ==================== TAB 3: PEMBAGIAN TUGAS ====================
  Widget _buildTasksTab(
    DataService dataService,
    List<Event> events,
    List<Task> allTasks,
  ) {
    final filteredTasks = _taskFilterEventId == 'all'
        ? allTasks
        : allTasks.where((t) => t.eventId == _taskFilterEventId).toList();

    final completedCount = filteredTasks.where((t) => t.isCompleted).length;
    final totalCount = filteredTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Event Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Semua Event'),
                  selected: _taskFilterEventId == 'all',
                  onSelected: (_) {
                    setState(() {
                      _taskFilterEventId = 'all';
                    });
                  },
                ),
              ),
              ...events.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.title),
                    selected: _taskFilterEventId == e.id,
                    onSelected: (_) {
                      setState(() {
                        _taskFilterEventId = e.id;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Progress Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress Tugas Panitia',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '$completedCount dari $totalCount selesai (${(progress * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0 ? Colors.teal : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (filteredTasks.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in_outlined,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                const Text('Belum ada tugas untuk kategori ini.'),
              ],
            ),
          )
        ] else ...[
          ...filteredTasks.map((task) {
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
              onDelete: () => dataService.deleteTask(task.id),
            );
          }),
        ],

        const SizedBox(height: 72),
      ],
    );
  }

  // ==================== DIALOGS & SHEETS ====================

  void _showAddEventDialog(BuildContext context, DataService dataService) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Buat Event Komunitas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Event',
                        hintText: 'misal: Gowes Pagi Sudirman',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi / Titik Kumpul',
                        hintText: 'misal: Gate 1 GBK Senayan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(DateFormat('d MMM yyyy').format(selectedDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(selectedTime.format(context)),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setModalState(() => selectedTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Singkat',
                        hintText: 'Perlengkapan yang harus dibawa, rute, dll.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;

                          final eventDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          final newEvent = Event(
                            id: 'event_${DateTime.now().millisecondsSinceEpoch}',
                            communityId: _communityId,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            location: locController.text.trim(),
                            dateTime: eventDateTime,
                            creatorId: dataService.currentUserId,
                            rsvps: {dataService.currentUserId: 'joined'},
                            reminderSet: true,
                          );

                          dataService.addEvent(newEvent);
                          _notificationService.scheduleH1Reminder(
                            id: newEvent.id.hashCode,
                            eventTitle: newEvent.title,
                            eventDateTime: newEvent.dateTime,
                            location: newEvent.location,
                          );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Event "${newEvent.title}" berhasil dibuat! 🎉'),
                              backgroundColor: Colors.teal.shade700,
                            ),
                          );
                        },
                        child: const Text('Simpan & Terbitkan Event'),
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

  void _showAddAnnouncementDialog(BuildContext context, DataService dataService) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String category = 'Penting';
    bool pinned = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Buat Pengumuman Baru',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Pengumuman',
                        hintText: 'misal: Iuran Kas Bulan Ini',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ['Penting', 'Keuangan', 'Aturan', 'Umum'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Isi Pengumuman',
                        hintText: 'Tuliskan informasi penting selengkapnya di sini...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sematkan di Atas (Pin)'),
                      subtitle: const Text('Biar gampang dicari & tidak ketimbun'),
                      value: pinned,
                      onChanged: (val) => setModalState(() => pinned = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty ||
                              bodyController.text.trim().isEmpty) {
                            return;
                          }

                          final newAnn = Announcement(
                            id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
                            communityId: _communityId,
                            title: titleController.text.trim(),
                            body: bodyController.text.trim(),
                            authorId: dataService.currentUserId,
                            authorName: dataService.currentUser.name,
                            category: category,
                            pinned: pinned,
                            createdAt: DateTime.now(),
                          );

                          dataService.addAnnouncement(newAnn);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pengumuman "${newAnn.title}" diterbitkan! 📢'),
                              backgroundColor: Colors.teal.shade700,
                            ),
                          );
                        },
                        child: const Text('Publikasikan Pengumuman'),
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

  void _showAddTaskDialog(
    BuildContext context,
    DataService dataService,
    List<Event> events, {
    String? defaultEventId,
  }) {
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buat event terlebih dahulu sebelum menambah tugas!')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String targetEventId = defaultEventId ?? events.first.id;
    final List<String> selectedAssignees = [];
    final communityUsers = dataService.getMembers(_communityId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambah Tugas Kepanitiaan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: targetEventId,
                      decoration: const InputDecoration(
                        labelText: 'Event Terkait',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event_note),
                      ),
                      items: events.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            e.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => targetEventId = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        hintText: 'misal: Bawa P3K & Konsumsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task_alt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan / Deskripsi',
                        hintText: 'Detail kebutuhan tugas...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tugaskan Kepada Anggota:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: communityUsers.map((u) {
                        final isAssigned = selectedAssignees.contains(u.id);
                        return FilterChip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Text(u.name.isNotEmpty ? u.name[0] : '?'),
                          ),
                          label: Text(u.name.split(' ').first),
                          selected: isAssigned,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedAssignees.add(u.id);
                              } else {
                                selectedAssignees.remove(u.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;

                          final newTask = Task(
                            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                            eventId: targetEventId,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            assigneeIds: selectedAssignees,
                            isCompleted: false,
                          );

                          dataService.addTask(newTask);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tugas "${newTask.title}" berhasil ditambahkan! ✅'),
                              backgroundColor: Colors.teal.shade700,
                            ),
                          );
                        },
                        child: const Text('Simpan Tugas'),
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

  void _toggleTheme(AppSettings settings) {
    settings.setThemeMode(
      settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void _showCommunitySwitcher(BuildContext context) {
    final dataService = context.read<DataService>();
    final communities = dataService.getAllCommunities();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Komunitas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...communities.map((c) {
                  final isActive = c.id == _communityId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: isActive ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isActive
                            ? Theme.of(ctx).colorScheme.primary
                            : Theme.of(ctx).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isActive
                            ? Theme.of(ctx).colorScheme.primary
                            : Theme.of(ctx).colorScheme.primaryContainer,
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Theme.of(ctx).colorScheme.onPrimary
                                : Theme.of(ctx).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${c.members.length} Anggota • ${c.category}'),
                      trailing: isActive
                          ? Icon(Icons.check_circle, color: Theme.of(ctx).colorScheme.primary)
                          : null,
                      onTap: () {
                        final settings = context.read<AppSettings>();
                        settings.selectCommunity(c.id);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 4),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnnouncementDetailSheet(BuildContext context, Announcement ann) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ann.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Oleh ${ann.authorName} • ${DateFormat('d MMMM yyyy, HH:mm').format(ann.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
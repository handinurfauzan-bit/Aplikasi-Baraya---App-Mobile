import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../utils/countdown.dart';
import '../widgets/task_card.dart';

class EventDetailScreen extends StatefulWidget {
  final String communityId;
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.communityId,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final event = dataService.getEvent(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: const Text('Detail Event'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 80,
                child: CustomPaint(painter: _NotFoundPainter()),
              ),
              const SizedBox(height: 12),
              const Text('Event tidak ditemukan.'),
            ],
          ),
        ),
      );
    }

    final tasks = dataService.getTasksForEvent(event.id);
    final communityUsers = dataService.getMembers(widget.communityId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('Detail Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Event',
            onPressed: () => _showEditEventDialog(event),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Event',
            onPressed: () => _confirmDeleteEvent(event),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(event, colorScheme),
          const SizedBox(height: 12),

          if (event.description.isNotEmpty) ...[
            _buildSectionCard(
              title: 'Deskripsi',
              icon: Icons.notes,
              child: Text(
                event.description,
                style: const TextStyle(height: 1.5, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
          ],

          _buildSectionCard(
            title: 'Status Saya',
            icon: Icons.how_to_reg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _buildStatusText(event, dataService.currentUserId),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildRsvpButton(
                      label: 'Ikut',
                      icon: Icons.check_circle_outline,
                      isSelected: event.rsvps[dataService.currentUserId] == 'joined',
                      color: Colors.green.shade700,
                      onTap: () => _setRsvp(dataService, event, 'joined'),
                    ),
                    const SizedBox(width: 8),
                    _buildRsvpButton(
                      label: 'Ragu',
                      icon: Icons.help_outline,
                      isSelected: event.rsvps[dataService.currentUserId] == 'maybe',
                      color: Colors.orange.shade800,
                      onTap: () => _setRsvp(dataService, event, 'maybe'),
                    ),
                    const SizedBox(width: 8),
                    _buildRsvpButton(
                      label: 'Gak',
                      icon: Icons.cancel_outlined,
                      isSelected: event.rsvps[dataService.currentUserId] == 'declined',
                      color: Colors.red.shade700,
                      onTap: () => _setRsvp(dataService, event, 'declined'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildSectionCard(
            title: 'Peserta (${event.joinedCount + event.maybeCount} dari ${communityUsers.length} anggota)',
            icon: Icons.people_alt_outlined,
            child: _buildAttendees(communityUsers, event.rsvps, dataService.currentUserId),
          ),
          const SizedBox(height: 12),

          _buildSectionCard(
            title: 'Pengingat',
            icon: Icons.notifications_outlined,
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  event.reminderSet
                      ? 'Pengingat H-1 AKTIF'
                      : 'Aktifkan pengingat H-1',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Notifikasi dikirim 24 jam sebelum acara',
                  style: TextStyle(fontSize: 12),
                ),
                value: event.reminderSet,
                activeThumbColor: Colors.amber.shade700,
                onChanged: (val) => _toggleReminder(event, val),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildSectionCard(
            title: 'Tugas Panitia (${tasks.length})',
            icon: Icons.checklist,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'Belum ada tugas untuk event ini.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...tasks.map((task) {
                    final assignees = task.assigneeIds
                        .map((id) => dataService.getUser(id))
                        .whereType<User>()
                        .toList();
                    return TaskCard(
                      task: task,
                      assignees: assignees,
                      onToggle: () => dataService.toggleTask(task.id),
                      onDelete: () => dataService.deleteTask(task.id),
                    );
                  }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_task, size: 18),
                    label: const Text('Tambah Tugas'),
                    onPressed: () => _showAddTaskDialog(event),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeaderCard(Event event, ColorScheme colorScheme) {
    final dayName = DateFormat('EEEE', 'id_ID').format(event.dateTime);
    final dayNum = DateFormat('d', 'id_ID').format(event.dateTime);
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(event.dateTime);
    final timeStr = DateFormat('HH:mm', 'id_ID').format(event.dateTime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15803D), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$dayName, $dayNum $monthYear',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      countdownShortLabel(event.dateTime) == 'Hari ini'
                          ? Icons.alarm_on
                          : Icons.hourglass_top,
                      size: 13,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      countdownShortLabel(event.dateTime),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '$timeStr WIB',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people_alt, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '${event.joinedCount} Ikut',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (event.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(color: Colors.white, height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _buildStatusText(Event event, String currentUserId) {
    final myRsvp = event.rsvps[currentUserId];
    switch (myRsvp) {
      case 'joined':
        return 'Anda sudah konfirmasi IKUT. Sampai jumpa di titik kumpul!';
      case 'maybe':
        return 'Anda masih ragu. Update status kalau sudah yakin ya.';
      case 'declined':
        return 'Anda tidak hadir di event ini.';
      default:
        return 'Belum ada status. Pilih salah satu untuk mengonfirmasi kehadiran.';
    }
  }

  Widget _buildRsvpButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border.all(
              color: isSelected ? color : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: isSelected ? color : colorScheme.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ATTENDEES ====================

  Widget _buildAttendees(
    List<User> allUsers,
    Map<String, String> rsvps,
    String currentUserId,
  ) {
    final joined = <User>[];
    final maybe = <User>[];
    final declined = <User>[];
    final notSet = <User>[];

    for (final user in allUsers) {
      final status = rsvps[user.id];
      switch (status) {
        case 'joined':
          joined.add(user);
          break;
        case 'maybe':
          maybe.add(user);
          break;
        case 'declined':
          declined.add(user);
          break;
        default:
          notSet.add(user);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAttendeeGroup(
          label: 'Ikut',
          count: joined.length,
          users: joined,
          color: Colors.green.shade700,
          currentUserId: currentUserId,
        ),
        if (maybe.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAttendeeGroup(
            label: 'Ragu',
            count: maybe.length,
            users: maybe,
            color: Colors.orange.shade800,
            currentUserId: currentUserId,
          ),
        ],
        if (declined.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAttendeeGroup(
            label: 'Tidak',
            count: declined.length,
            users: declined,
            color: Colors.red.shade700,
            currentUserId: currentUserId,
          ),
        ],
        if (notSet.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAttendeeGroup(
            label: 'Belum Konfirmasi',
            count: notSet.length,
            users: notSet,
            color: Colors.grey.shade600,
            currentUserId: currentUserId,
          ),
        ],
      ],
    );
  }

  Widget _buildAttendeeGroup({
    required String label,
    required int count,
    required List<User> users,
    required Color color,
    required String currentUserId,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: users.map((user) {
                  final isMe = user.id == currentUserId;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isMe ? color : color.withValues(alpha: 0.3),
                        width: isMe ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isMe ? '${user.name} (Anda)' : user.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _setRsvp(DataService dataService, Event event, String status) async {
    dataService.setRSVP(event.id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'joined'
              ? 'Anda konfirmasi Ikut pada "${event.title}"!'
              : status == 'maybe'
                  ? 'Status Anda diubah ke Ragu-ragu.'
                  : 'Status Anda diubah ke Tidak Ikut.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleReminder(Event event, bool enabled) async {
    final dataService = context.read<DataService>();
    dataService.toggleEventReminder(event.id, enabled);

    if (enabled) {
      await _notificationService.scheduleH1Reminder(
        id: event.id.hashCode,
        eventTitle: event.title,
        eventDateTime: event.dateTime,
        location: event.location,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengingat H-1 aktif untuk "${event.title}"'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } else {
      await _notificationService.cancel(event.id.hashCode);
    }
  }

  Future<void> _confirmDeleteEvent(Event event) async {
    final dataService = context.read<DataService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Event?'),
        content: Text(
          '"${event.title}" dan semua tugas terkait akan dihapus. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.cancel(event.id.hashCode);
      dataService.deleteEvent(event.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${event.title}" dihapus.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showEditEventDialog(Event event) {
    final dataService = context.read<DataService>();
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    final locController = TextEditingController(text: event.location);
    DateTime selectedDate = event.dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(event.dateTime);

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
                          'Edit Event',
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
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi / Titik Kumpul',
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
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;

                          final eventDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          final updated = event.copyWith(
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            location: locController.text.trim(),
                            dateTime: eventDateTime,
                          );

                          dataService.updateEvent(updated);

                          if (updated.reminderSet) {
                            await _notificationService
                                .cancel(updated.id.hashCode);
                            await _notificationService.scheduleH1Reminder(
                              id: updated.id.hashCode,
                              eventTitle: updated.title,
                              eventDateTime: updated.dateTime,
                              location: updated.location,
                            );
                          }

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Event "${updated.title}" berhasil diupdate!'),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          }
                        },
                        child: const Text('Simpan Perubahan'),
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

  void _showAddTaskDialog(Event event) {
    final dataService = context.read<DataService>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedAssignees = <String>[];
    final communityUsers = dataService.getMembers(widget.communityId);

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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tugas',
                        hintText: 'misal: Bawa P3K & Konsumsi',
                        prefixIcon: Icon(Icons.task_alt),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan / Deskripsi',
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
                            eventId: event.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            assigneeIds: selectedAssignees,
                            isCompleted: false,
                          );

                          dataService.addTask(newTask);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tugas "${newTask.title}" berhasil ditambahkan!'),
                              backgroundColor: Colors.green.shade700,
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
}

class _NotFoundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const primary = Color(0xFF16A34A);

    // Calendar
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.12, w * 0.64, h * 0.7),
      const Radius.circular(14),
    );
    canvas.drawRRect(bodyRect, Paint()..color = primary.withValues(alpha: 0.08));
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Bindings
    final ringPaint = Paint()
      ..color = primary.withValues(alpha: 0.7)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 2; i++) {
      final cx = w * (0.32 + i * 0.36);
      canvas.drawArc(
        Rect.fromLTWH(cx - 4, h * 0.08, 8, h * 0.16),
        3.14159,
        3.14159,
        false,
        ringPaint,
      );
    }
    // Question mark
    final qPaint = Paint()
      ..color = primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.44, h * 0.4)
      ..quadraticBezierTo(w * 0.52, h * 0.26, w * 0.56, h * 0.4)
      ..quadraticBezierTo(w * 0.6, h * 0.52, w * 0.5, h * 0.58);
    canvas.drawPath(path, qPaint);
    canvas.drawCircle(Offset(w * 0.49, h * 0.72), 2.5, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
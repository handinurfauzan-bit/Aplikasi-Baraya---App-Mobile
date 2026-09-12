import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../utils/countdown.dart';
import '../widgets/announcement_feed.dart';
import '../widgets/event_card.dart';
import '../widgets/task_card.dart';
import 'about_screen.dart';
import 'communities_screen.dart';
import 'event_detail_screen.dart';
import 'profile_screen.dart';

const List<String> _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

class HomeScreen extends StatefulWidget {
  final String communityId;
  final NotificationService? notificationService;
  final String? welcomeName;

  const HomeScreen({
    super.key,
    this.communityId = 'kumpul_001',
    this.notificationService,
    this.welcomeName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final NotificationService _notificationService;
  String _taskFilterEventId = 'all';
  String _communityId = 'kumpul_001';
  String _searchQuery = '';
  String _rsvpFilter = 'semua';
  String _monthFilter = 'semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _notificationService = widget.notificationService ?? NotificationService();
    _notificationService.init();
    if (widget.welcomeName != null && widget.welcomeName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${widget.welcomeName}!'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    if (_communityId != settings.communityId) {
      _communityId = settings.communityId;
      _searchController.clear();
      _searchQuery = '';
      _rsvpFilter = 'semua';
      _monthFilter = 'semua';
      _taskFilterEventId = 'all';
    }
    final events = dataService.getEventsForCommunity(_communityId);
    final announcements =
        dataService.getAnnouncementsForCommunity(_communityId);
    final allTasks = dataService.getAllTasksForCommunity(_communityId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/logo1.1.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Baraya',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          if (settings.demoMode)
            _buildDemoBanner(context, dataService, settings),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(dataService, events),
                _buildAnnouncementsTab(dataService, announcements),
                _buildTasksTab(dataService, events, allTasks),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) => _tabController.animateTo(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            activeIcon: Icon(Icons.calendar_month, size: 26),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            activeIcon: Icon(Icons.campaign, size: 26),
            label: 'Pengumuman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            activeIcon: Icon(Icons.checklist, size: 26),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, size: 26),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _showAddEventDialog(context, dataService);
                } else if (_tabController.index == 1) {
                  _showAnnouncementFormDialog(context, dataService);
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
      case 2:
        return Icons.add_task;
      default:
        return Icons.person;
    }
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Buat Event';
      case 1:
        return 'Pengumuman Baru';
      case 2:
        return 'Tambah Tugas';
      default:
        return '';
    }
  }

  Widget _buildEventsTab(DataService dataService, List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 100,
              child: CustomPaint(painter: _EventEmptyPainter()),
            ),
            const SizedBox(height: 16),
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

    final now = DateTime.now();
    final hasActiveFilters = _searchQuery.isNotEmpty ||
        _rsvpFilter != 'semua' ||
        _monthFilter != 'semua';

    final filtered = events.where((event) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!event.title.toLowerCase().contains(q) &&
            !event.location.toLowerCase().contains(q)) {
          return false;
        }
      }
      switch (_rsvpFilter) {
        case 'joined':
          if (event.rsvps[dataService.currentUserId] != 'joined') return false;
          break;
        case 'maybe':
          if (event.rsvps[dataService.currentUserId] != 'maybe') return false;
          break;
        case 'declined':
          if (event.rsvps[dataService.currentUserId] != 'declined') {
            return false;
          }
          break;
        case 'belum':
          if (event.rsvps[dataService.currentUserId] != null) return false;
          break;
      }
      if (_monthFilter == 'bulan_ini') {
        if (event.dateTime.month != now.month ||
            event.dateTime.year != now.year) {
          return false;
        }
      } else if (_monthFilter == 'bulan_depan') {
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        if (event.dateTime.month != nextMonth.month ||
            event.dateTime.year != nextMonth.year) {
          return false;
        }
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!hasActiveFilters) _buildNextEventHero(dataService, events, now),
        const SizedBox(height: 16),
        _buildFeatureRow(colorScheme),
        const SizedBox(height: 16),
        _buildSearchField(colorScheme),
        const SizedBox(height: 16),
        _buildFilterPanel(colorScheme, hasActiveFilters),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _buildNoResultsCard(colorScheme)
        else ...[
          Row(
            children: [
              Text(
                '${filtered.length} event ditemukan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () => _resetEventFilters(),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: const Text('Reset Filter'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...filtered.map((event) {
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
                          ? 'Anda konfirmasi Ikut pada "${event.title}"!'
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
                        content:
                            Text('Pengingat H-1 aktif untuk "${event.title}"'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                } else {
                  await _notificationService.cancel(event.id.hashCode);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Pengingat dimatikan untuk "${event.title}"'),
                      ),
                    );
                  }
                }
              },
            );
          }),
        ],
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _buildFeatureRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommunitiesScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.diversity_3,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Komunitas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kelola & tambah komunitas',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.8), size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.rule_outlined,
                        color: colorScheme.primary, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengaturan',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Info & setelan aplikasi',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari event (judul / lokasi)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterPanel(ColorScheme colorScheme, bool hasActiveFilters) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 8, bottom: 10),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Filter Event',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: () => _resetEventFilters(),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: _buildFilterGroupLabel(
                'Status Kehadiran', Icons.fact_check_outlined),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                    label: 'Semua',
                    icon: Icons.filter_list,
                    selected: _rsvpFilter == 'semua',
                    onTap: () => setState(() => _rsvpFilter = 'semua')),
                _buildFilterChip(
                    label: 'Ikut',
                    icon: Icons.check_circle_outline,
                    selected: _rsvpFilter == 'joined',
                    onTap: () => setState(() => _rsvpFilter = 'joined')),
                _buildFilterChip(
                    label: 'Ragu',
                    icon: Icons.help_outline,
                    selected: _rsvpFilter == 'maybe',
                    onTap: () => setState(() => _rsvpFilter = 'maybe')),
                _buildFilterChip(
                    label: 'Tidak',
                    icon: Icons.cancel_outlined,
                    selected: _rsvpFilter == 'declined',
                    onTap: () => setState(() => _rsvpFilter = 'declined')),
                _buildFilterChip(
                    label: 'Belum RSVP',
                    icon: Icons.event_note,
                    selected: _rsvpFilter == 'belum',
                    onTap: () => setState(() => _rsvpFilter = 'belum')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 12, 0, 6),
            child: _buildFilterGroupLabel('Periode', Icons.event_outlined),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                    label: 'Semua Waktu',
                    selected: _monthFilter == 'semua',
                    onTap: () => setState(() => _monthFilter = 'semua')),
                _buildFilterChip(
                    label: 'Bulan Ini',
                    selected: _monthFilter == 'bulan_ini',
                    onTap: () => setState(() => _monthFilter = 'bulan_ini')),
                _buildFilterChip(
                    label: 'Bulan Depan',
                    selected: _monthFilter == 'bulan_depan',
                    onTap: () => setState(() => _monthFilter = 'bulan_depan')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGroupLabel(String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 56,
            child: CustomPaint(painter: _SearchEmptyPainter()),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada event yang cocok dengan filter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci atau reset filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _resetEventFilters(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  void _resetEventFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _rsvpFilter = 'semua';
      _monthFilter = 'semua';
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 15,
                  color: selected ? colorScheme.onPrimaryContainer : null),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  Widget _buildNextEventHero(
      DataService dataService, List<Event> events, DateTime now) {
    final colorScheme = Theme.of(context).colorScheme;
    final nextEvent = events.firstWhere(
      (e) => e.dateTime.isAfter(now),
      orElse: () => events.last,
    );
    final members = dataService.getMembers(_communityId);
    final joined = nextEvent.rsvps.values.where((s) => s == 'joined').length;
    final maybe = nextEvent.rsvps.values.where((s) => s == 'maybe').length;
    final tasks = dataService.getTasksForEvent(nextEvent.id);
    final completed = tasks.where((t) => t.isCompleted).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                communityId: _communityId,
                eventId: nextEvent.id,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt,
                      color: Colors.white.withValues(alpha: 0.9), size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'EVENT TERDEKAT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      countdownShortLabel(nextEvent.dateTime),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextEvent.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_formatDate(nextEvent.dateTime)} • Pukul ${nextEvent.dateTime.hour.toString().padLeft(2, '0')}:${nextEvent.dateTime.minute.toString().padLeft(2, '0')}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      nextEvent.location,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _heroStatChip(
                      icon: Icons.people,
                      label:
                          '${joined + maybe}/${members.length} berencana hadir'),
                  _heroStatChip(
                      icon: Icons.checklist,
                      label: tasks.isEmpty
                          ? 'Belum ada tugas panitia'
                          : 'Tugas $completed/${tasks.length} selesai'),
                ],
              ),
              if (tasks.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.flag_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Progres Tugas Panitia',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                    Text(
                      '$completed/${tasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completed / tasks.length,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFBBF24)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day} ${_bulan[d.month - 1]} ${d.year}';
  }

  Widget _buildAnnouncementsTab(
      DataService dataService, List<Announcement> announcements) {
    return ListView(
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
              Icon(Icons.campaign_outlined,
                  color: Colors.green.shade800, size: 24),
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
            _showAnnouncementDetailSheet(context, dataService, ann);
          },
        ),
        const SizedBox(height: 72),
      ],
    );
  }

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
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      progress == 1.0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
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
                SizedBox(
                  width: 100,
                  height: 90,
                  child: CustomPaint(painter: _TaskEmptyPainter()),
                ),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi / Titik Kumpul',
                        hintText: 'misal: Gate 1 GBK Senayan',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                                DateFormat('d MMM yyyy').format(selectedDate)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
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
                              content: Text(
                                  'Event "${newEvent.title}" berhasil dibuat!'),
                              backgroundColor: Colors.green.shade700,
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

  void _showAnnouncementFormDialog(
      BuildContext context, DataService dataService,
      {Announcement? ann}) {
    final isEditing = ann != null;
    final titleController = TextEditingController(text: ann?.title);
    final bodyController = TextEditingController(text: ann?.body);
    String category = ann?.category ?? 'Penting';
    bool pinned = ann?.pinned ?? true;

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
                        Text(
                          isEditing
                              ? 'Edit Pengumuman'
                              : 'Buat Pengumuman Baru',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items:
                          ['Penting', 'Keuangan', 'Aturan', 'Umum'].map((cat) {
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
                        hintText:
                            'Tuliskan informasi penting selengkapnya di sini...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sematkan di Atas (Pin)'),
                      subtitle:
                          const Text('Biar gampang dicari & tidak ketimbun'),
                      value: pinned,
                      onChanged: (val) => setModalState(() => pinned = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty ||
                              bodyController.text.trim().isEmpty) {
                            return;
                          }

                          if (isEditing) {
                            final updated = Announcement(
                              id: ann.id,
                              communityId: _communityId,
                              title: titleController.text.trim(),
                              body: bodyController.text.trim(),
                              authorId: ann.authorId,
                              authorName: ann.authorName,
                              category: category,
                              pinned: pinned,
                              createdAt: ann.createdAt,
                            );
                            dataService.updateAnnouncement(updated);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Pengumuman "${updated.title}" diperbarui'),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          } else {
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
                                content: Text(
                                    'Pengumuman "${newAnn.title}" diterbitkan!'),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          }
                        },
                        child: Text(isEditing
                            ? 'Simpan Perubahan'
                            : 'Publikasikan Pengumuman'),
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
        const SnackBar(
            content:
                Text('Buat event terlebih dahulu sebelum menambah tugas!')),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                        if (val != null) {
                          setModalState(() => targetEventId = val);
                        }
                      },
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
                        hintText: 'Detail kebutuhan tugas...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tugaskan Kepada Anggota:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
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
                              content: Text(
                                  'Tugas "${newTask.title}" berhasil ditambahkan!'),
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

  void _toggleTheme(AppSettings settings) {
    settings.setThemeMode(
      settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Widget _buildDemoBanner(
      BuildContext context, DataService dataService, AppSettings settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.tertiaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.movie_filter,
                size: 20, color: colorScheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MODE DEMO',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  Text(
                    'Data contoh tersimpan lokal di perangkat ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                dataService.resetToSeedData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Data demo dikembalikan ke versi awal'),
                    backgroundColor: Colors.green.shade700,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
              child: const Text('Reset Data'),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Sembunyikan banner',
              color: colorScheme.onTertiaryContainer,
              onPressed: () => settings.setDemoMode(false),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetailSheet(
      BuildContext context, DataService dataService, Announcement ann) {
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
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Pengumuman',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAnnouncementFormDialog(context, dataService,
                          ann: ann);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Hapus Pengumuman',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Text('Hapus Pengumuman?'),
                          content:
                              Text('"${ann.title}" akan dihapus permanen.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, true),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        dataService.deleteAnnouncement(ann.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Pengumuman "${ann.title}" dihapus'),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      }
                    },
                  ),
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

class _EventEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const primary = Color(0xFF16A34A);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.14, w * 0.76, h * 0.72),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()..color = primary.withValues(alpha: 0.08),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.14, w * 0.76, h * 0.18),
        const Radius.circular(16),
      ),
      Paint()..color = primary.withValues(alpha: 0.14),
    );

    final ringPaint = Paint()
      ..color = primary.withValues(alpha: 0.7)
      ..strokeWidth = 2.5;
    for (int i = 0; i < 2; i++) {
      final cx = w * (0.28 + i * 0.44);
      canvas.drawArc(
        Rect.fromLTWH(cx - 4, h * 0.05, 8, h * 0.2),
        3.14159,
        3.14159,
        false,
        ringPaint,
      );
    }

    final checkPaint = Paint()
      ..color = primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.36, h * 0.52)
      ..lineTo(w * 0.47, h * 0.63)
      ..lineTo(w * 0.66, h * 0.4);
    canvas.drawPath(path, checkPaint);

    final dotPaint = Paint()..color = primary.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(w * 0.82, h * 0.28), 3, dotPaint);
    canvas.drawCircle(Offset(w * 0.2, h * 0.85), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaskEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const primary = Color(0xFF16A34A);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.1, w * 0.64, h * 0.8),
      const Radius.circular(14),
    );
    canvas.drawRRect(
        bodyRect, Paint()..color = primary.withValues(alpha: 0.08));
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.4, h * 0.02, w * 0.2, h * 0.14),
        const Radius.circular(6),
      ),
      Paint()..color = primary.withValues(alpha: 0.5),
    );

    final linePaint = Paint()
      ..color = primary.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final y = h * (0.34 + i * 0.22);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.26, y, w * 0.48, 6),
          const Radius.circular(3),
        ),
        linePaint,
      );

      canvas.drawCircle(
        Offset(w * 0.48, y + 3),
        7,
        Paint()
          ..color = primary.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final checkPaint = Paint()
      ..color = primary
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.28, h * 0.24)
        ..lineTo(w * 0.35, h * 0.3)
        ..lineTo(w * 0.44, h * 0.2),
      checkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final Color primary = const Color(0xFF16A34A).withValues(alpha: 0.6);

    canvas.drawCircle(
      Offset(w * 0.45, h * 0.42),
      h * 0.32,
      Paint()
        ..color = primary.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * 0.45, h * 0.42),
      h * 0.32,
      Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(w * 0.66, h * 0.62),
      Offset(w * 0.88, h * 0.84),
      Paint()
        ..color = primary
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(w * 0.45, h * 0.35),
      4,
      Paint()..color = primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

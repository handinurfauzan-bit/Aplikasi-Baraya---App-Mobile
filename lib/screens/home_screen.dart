import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../widgets/compact_event_card.dart';
import 'add_community_screen.dart';
import 'communities_screen.dart';
import 'community_detail_screen.dart';
import 'discussions_screen.dart';
import 'event_detail_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

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
  final String _communityId = 'kumpul_001';
  String _searchQuery = '';
  String _rsvpFilter = 'semua';
  String _monthFilter = 'semua';
  final TextEditingController _searchController = TextEditingController();
  final PageController _heroController = PageController();
  int _heroIndex = 0;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _notificationService = widget.notificationService ?? NotificationService();
    _notificationService.init();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroController.hasClients) return;
      final next = (_heroIndex + 1) % 3;
      _heroController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
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
    _heroTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final settings = context.watch<AppSettings>();
    final events = dataService.getEventsForCommunity(_communityId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, Justhan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Text(
                  'Selamat datang di Baraya',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifikasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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
                _buildBerandaTab(dataService, events),
                _buildCommunitiesTab(dataService, settings),
                _buildEventsTab(dataService, events),
                _buildKasTab(dataService),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, size: 26),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_3_outlined),
            activeIcon: Icon(Icons.diversity_3, size: 26),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month, size: 26),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet, size: 26),
            label: 'Kas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, size: 26),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: (_tabController.index == 1)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddCommunityScreen()),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Komunitas'),
            )
          : (_tabController.index == 0 || _tabController.index == 2)
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddEventDialog(context, dataService),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Buat Event'),
                )
              : null,
    );
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
            return CompactEventCard(
              event: event,
              currentUserId: dataService.currentUserId,
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
            );
          }),
        ],
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _buildBerandaTab(DataService dataService, List<Event> events) {
    final colorScheme = Theme.of(context).colorScheme;
    final upcoming =
        events.take(2).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroCarousel(colorScheme),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Fitur Baraya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        _buildFeatureGrid(colorScheme),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Event Terdekat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _tabController.animateTo(2),
                child: const Text('Semua Event'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ...upcoming.map(
            (event) => CompactEventCard(
              event: event,
              currentUserId: dataService.currentUserId,
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
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCommunitiesTab(DataService dataService, AppSettings settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final communities = dataService.getAllCommunities();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Pilih Komunitas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '${communities.length} komunitas tersedia untukmu',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (communities.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: Text('Belum ada komunitas.')),
            ),
          )
        else
          ...communities.map((c) {
            final isActive = c.id == settings.communityId;
            final isMember =
                c.members.any((m) => m.id == dataService.currentUserId);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: colorScheme.surface,
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
                onTap: () {
                  settings.selectCommunity(c.id);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CommunityDetailScreen(communityId: c.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primaryContainer,
                        child: c.logo.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  c.logo,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Text(
                                c.name.isNotEmpty
                                    ? c.name[0].toUpperCase()
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
                                    c.name,
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
                              '${c.members.length} anggota',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMember)
                            FilledButton(
                              onPressed: () {
                                dataService.joinCommunity(c.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Kamu bergabung ke ${c.name}!',
                                    ),
                                    backgroundColor: Colors.green.shade700,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                              child: const Text(
                                'Bergabung',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: colorScheme.outline),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildKasTab(DataService dataService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final community = dataService.getCommunity(_communityId);
    final members = community?.members ?? const <User>[];
    final treasury = dataService.getTreasuryInfo(_communityId);

    return ListView(
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
                'Saldo Kas ${community?.name ?? 'Komunitas'}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatRupiah(treasury.saldo),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildKasStat(
                    label: 'Pemasukan',
                    value: _formatRupiah(treasury.totalIn),
                    icon: Icons.south_west,
                  ),
                  const SizedBox(width: 24),
                  _buildKasStat(
                    label: 'Pengeluaran',
                    value: _formatRupiah(treasury.totalOut),
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
          'Iuran bulanan ${_formatRupiah(treasury.monthlyIuran)} • ${members.length} orang',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        ...treasury.entries.map(
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
                  color: (e.isIncome ? Colors.green : colorScheme.error)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  e.isIncome ? Icons.south_west : Icons.north_east,
                  size: 18,
                  color:
                      e.isIncome ? Colors.green.shade700 : colorScheme.error,
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
                _formatRupiah(e.nominal),
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildKasStat({
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
              style: const TextStyle(fontSize: 11, color: Colors.white70),
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

  Widget _buildFeatureGrid(ColorScheme colorScheme) {
    final features = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.diversity_3,
        label: 'Komunitas',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CommunitiesScreen()),
        ),
      ),
      (
        icon: Icons.calendar_month,
        label: 'Event',
        onTap: () => _tabController.animateTo(2),
      ),
      (
        icon: Icons.forum,
        label: 'Diskusi',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DiscussionsScreen()),
        ),
      ),
      (
        icon: Icons.account_balance_wallet,
        label: 'Kas',
        onTap: () => _tabController.animateTo(3),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: features.map((f) {
        return Material(
          color: colorScheme.surface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: f.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      f.icon,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari event',
          hintStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Bersihkan pencarian',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textInputAction: TextInputAction.search,
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

  Widget _buildHeroCarousel(ColorScheme colorScheme) {
    final cards = [
      _buildHeroCard(
        colorScheme,
        title: 'Baraya, yuk mulai aksi!',
        subtitle:
            'Kelola event, bagi tugas panitia, dan pantau pengumuman komunitasmu di satu aplikasi.',
        icon: Icons.add_alarm,
        ctaLabel: 'Buat Event Sekarang',
        image: 'assets/sam1.png',
      ),
      _buildHeroCard(
        colorScheme,
        title: 'Semangat, Baraya!',
        subtitle:
            'Komunitas hebat tercipta dari anggota yang saling mendukung. Terus melangkah dan bangga jadi Baraya!',
        icon: Icons.emoji_events,
        ctaLabel: 'Tetap Semangat',
        image: 'assets/op2.png',
      ),
      _buildHeroCard(
        colorScheme,
        title: 'Bagi tugas, menang bareng!',
        subtitle:
            'Wujudkan event tanpa drama dengan berbagi tugas panitia. Semua kebagian, semua kebantu.',
        icon: Icons.checklist,
        ctaLabel: 'Kelola Tugas',
        image: 'assets/op3.png',
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _heroController,
            itemCount: cards.length,
            padEnds: false,
            onPageChanged: (index) => setState(() => _heroIndex = index),
            itemBuilder: (context, index) => cards[index],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (i) {
            final active = i == _heroIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String ctaLabel,
    required String image,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: const Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          Text(
                            ctaLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
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

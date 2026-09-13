import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class DataService extends ChangeNotifier {
  static const String _storageKey = 'kumpul_in_data_v2';

  final String currentUserId = 'user_001';

  final Map<String, User> _users = {};
  final Map<String, Community> _communities = {};
  final Map<String, Event> _events = {};
  final Map<String, Announcement> _announcements = {};
  final Map<String, Task> _tasks = {};

  bool _isLoaded = false;

  DataService() {
    _loadInitialData();
  }

  Future<void> init() async {
    if (_isLoaded) return;
    _isLoaded = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) {
        await _persist();
        return;
      }

      final data = jsonDecode(raw) as Map<String, dynamic>;

      _users.clear();
      for (final e in (data['users'] as List<dynamic>? ?? [])) {
        final u = User.fromJson(e as Map<String, dynamic>);
        _users[u.id] = u;
      }

      _communities.clear();
      for (final e in (data['communities'] as List<dynamic>? ?? [])) {
        final c = Community.fromJson(e as Map<String, dynamic>);
        _communities[c.id] = c;
      }

      _events.clear();
      for (final e in (data['events'] as List<dynamic>? ?? [])) {
        final ev = Event.fromJson(e as Map<String, dynamic>);
        _events[ev.id] = ev;
      }

      _announcements.clear();
      for (final e in (data['announcements'] as List<dynamic>? ?? [])) {
        final a = Announcement.fromJson(e as Map<String, dynamic>);
        _announcements[a.id] = a;
      }

      _tasks.clear();
      for (final e in (data['tasks'] as List<dynamic>? ?? [])) {
        final t = Task.fromJson(e as Map<String, dynamic>);
        _tasks[t.id] = t;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('DataService init error, falling back to seed data: $e');
      await _persist();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'users': _users.values.map((e) => e.toJson()).toList(),
        'communities': _communities.values.map((e) => e.toJson()).toList(),
        'events': _events.values.map((e) => e.toJson()).toList(),
        'announcements': _announcements.values.map((e) => e.toJson()).toList(),
        'tasks': _tasks.values.map((e) => e.toJson()).toList(),
      });
      await prefs.setString(_storageKey, payload);
    } catch (e) {
      debugPrint('DataService persist error: $e');
    }
  }

  void _loadInitialData() {
    final usersList = [
      const User(
        id: 'user_001',
        name: 'Dimas Aditya',
        avatarUrl: '',
        role: 'Anggota Aktif',
      ),
      const User(
        id: 'user_002',
        name: 'Budi Santoso',
        avatarUrl: '',
        role: 'Ketua Komunitas',
      ),
      const User(
        id: 'user_003',
        name: 'Siti Rahma',
        avatarUrl: '',
        role: 'Bendahara',
      ),
      const User(
        id: 'user_004',
        name: 'Reza Pratama',
        avatarUrl: '',
        role: 'Koordinator Rute',
      ),
      const User(
        id: 'user_005',
        name: 'Dewi Lestari',
        avatarUrl: '',
        role: 'Sie Konsumsi',
      ),
    ];

    for (final u in usersList) {
      _users[u.id] = u;
    }

    const commId = 'kumpul_001';
    _communities[commId] = Community(
      id: commId,
      name: 'Komunitas Gowes Batavia',
      description:
          'Wadah silaturahmi goweser Jakarta dan sekitarnya. Gowes santai, sehat, dan guyub!',
      category: 'Gowes & Olahraga',
      adminId: 'user_002',
      logo: 'assets/logo1.1.png',
      members: usersList,
    );

    final now = DateTime.now();
    final event1 = Event(
      id: 'event_001',
      communityId: commId,
      title: 'Gowes Minggu Pagi ke Monas',
      description:
          'Gowes santai CFD Senayan - Monas - Bundaran HI. Pace 15-20 km/jam, cocok buat semua level. Jangan lupa bawa helm dan botol minum!',
      dateTime: DateTime(now.year, now.month, now.day + 2, 6, 30),
      location: 'Titik Kumpul: GBK Senayan Gate 1',
      creatorId: 'user_002',
      rsvps: {
        'user_001': 'joined',
        'user_002': 'joined',
        'user_003': 'joined',
        'user_004': 'joined',
        'user_005': 'maybe',
      },
      reminderSet: true,
    );

    final event2 = Event(
      id: 'event_002',
      communityId: commId,
      title: 'Kopdar & Workshop Servis Mandiri',
      description:
          'Belajar cara tambal ban darurat, stel rem, dan pelumasan rantai bareng mekanik tamu. Bawa sepeda masing-masing ya!',
      dateTime: DateTime(now.year, now.month, now.day + 6, 16, 0),
      location: 'Cafe Kopi Sepeda, Kemang',
      creatorId: 'user_004',
      rsvps: {
        'user_001': 'maybe',
        'user_002': 'joined',
        'user_004': 'joined',
      },
      reminderSet: false,
    );

    final event3 = Event(
      id: 'event_003',
      communityId: commId,
      title: 'Touring Tipis Sentul KM 0',
      description:
          'Tantangan gowes tanjakan santai Sentul KM 0. Ada marshall pengawal dan mobil evakuasi siaga.',
      dateTime: DateTime(now.year, now.month, now.day + 12, 6, 0),
      location: 'Start: Mall Bellanova Sentul',
      creatorId: 'user_002',
      rsvps: {
        'user_002': 'joined',
        'user_003': 'declined',
      },
      reminderSet: false,
    );

    _events[event1.id] = event1;
    _events[event2.id] = event2;
    _events[event3.id] = event3;

    final tasksList = [
      Task(
        id: 'task_001',
        eventId: 'event_001',
        title: 'Bawa Toolkit & Pompa Portable',
        description:
            'Bawa pompa lantai portabel & kunci L di titik kumpul GBK.',
        assigneeIds: ['user_004'],
        isCompleted: true,
      ),
      Task(
        id: 'task_002',
        eventId: 'event_001',
        title: 'Siapkan Pisang & Air Mineral',
        description:
            'Beli 2 kardus air mineral 330ml dan 2 sisir pisang cavendish.',
        assigneeIds: ['user_005', 'user_001'],
        isCompleted: false,
      ),
      Task(
        id: 'task_003',
        eventId: 'event_001',
        title: 'Briefing Rute & Safety Marshall',
        description: 'Sepakati sinyal tangan dan titik putar balik CFD.',
        assigneeIds: ['user_004', 'user_002'],
        isCompleted: false,
      ),
      Task(
        id: 'task_004',
        eventId: 'event_001',
        title: 'Dokumentasi Foto & Video Reels',
        description:
            'Ambil konten di Bundaran HI & Monas untuk feed Instagram komunitas.',
        assigneeIds: ['user_001'],
        isCompleted: false,
      ),
      Task(
        id: 'task_005',
        eventId: 'event_002',
        title: 'Booking Area Outdoor Cafe',
        description:
            'Konfirmasi kapasitas 20 orang dan area parkir sepeda aman.',
        assigneeIds: ['user_003'],
        isCompleted: true,
      ),
      Task(
        id: 'task_006',
        eventId: 'event_002',
        title: 'Siapkan Ban Dalam Bekas Buat Latihan',
        description: 'Kumpulkan ban dalam bocor untuk simulasi tambal ban.',
        assigneeIds: ['user_004'],
        isCompleted: false,
      ),
    ];

    for (final t in tasksList) {
      _tasks[t.id] = t;
    }

    final ann1 = Announcement(
      id: 'ann_001',
      communityId: commId,
      title: 'Info Pengalihan Rute CFD Minggu Ini',
      body:
          'Diberitahukan kepada seluruh anggota, jalur Thamrin arah Monas ada penyesuaian karena pengerjaan MRT. Rute gowes Minggu nanti dialihkan melalui jalur Kebon Sirih. Tetap beriringan dan taati rambu lalu lintas!',
      authorId: 'user_004',
      authorName: 'Reza Pratama (Koord. Rute)',
      createdAt: now.subtract(const Duration(hours: 3)),
      pinned: true,
      category: 'Penting',
    );

    final ann2 = Announcement(
      id: 'ann_002',
      communityId: commId,
      title: 'Jersey Resmi Batavia 2026 Sudah Siap Dipesan',
      body:
          'Desain jersey edisi 2026 warna Deep Navy kombinasi Electric Lime sudah final. Silakan transfer DP 50% ke rekening bendahara Siti Rahma sebelum tanggal 20 bulan ini. Info ukuran ada di spreadsheet pengumuman.',
      authorId: 'user_003',
      authorName: 'Siti Rahma (Bendahara)',
      createdAt: now.subtract(const Duration(days: 1)),
      pinned: true,
      category: 'Keuangan',
    );

    final ann3 = Announcement(
      id: 'ann_003',
      communityId: commId,
      title: 'Aturan & Etika Gowes Bareng (Wajib Dibaca)',
      body:
          'Pengingat bagi seluruh member baru & lama:\n1. Helm sepeda adalah WAJIB (tidak pakai helm dilarang ikut peleton).\n2. Lampu depan & belakang harus terpasang aktif.\n3. Dilarang memakai earphone ganda saat di jalan raya.\nUtamakan keselamatan bersama!',
      authorId: 'user_002',
      authorName: 'Budi Santoso (Ketua)',
      createdAt: now.subtract(const Duration(days: 4)),
      pinned: false,
      category: 'Aturan',
    );

    _announcements[ann1.id] = ann1;
    _announcements[ann2.id] = ann2;
    _announcements[ann3.id] = ann3;

    _seedPhotographyCommunity(now);
    _seedHikingCommunity(now);
  }

  void _seedPhotographyCommunity(DateTime now) {
    const commId = 'comm_photo';

    final members = [
      const User(
        id: 'user_101',
        name: 'Nina Kusuma',
        avatarUrl: '',
        role: 'Anggota Aktif',
      ),
      const User(
        id: 'user_102',
        name: 'Farhan Wijaya',
        avatarUrl: '',
        role: 'Ketua Komunitas',
      ),
      const User(
        id: 'user_103',
        name: 'Maya Anggraini',
        avatarUrl: '',
        role: 'Sie Konten',
      ),
      const User(
        id: 'user_104',
        name: 'Yusuf Ramadhan',
        avatarUrl: '',
        role: 'Koordinator Lokasi',
      ),
    ];
    for (final u in members) {
      _users[u.id] = u;
    }

    _communities[commId] = Community(
      id: commId,
      name: 'Komunitas Foto Jakarta',
      description:
          'Belajar fotografi bareng: dari teori komposisi sampai hunting sunrise. Open untuk semua level kamera!',
      category: 'Fotografi & Kreatif',
      adminId: 'user_102',
      logo: 'assets/logo1.1.png',
      members: members,
    );

    final e1 = Event(
      id: 'event_101',
      communityId: commId,
      title: 'Hunting Sunrise Pantai Indah',
      description:
          'Golden hour pagi buta. Bawa tripod, filter ND, dan lensa wide. Kita berangkat bersama dari Karawaci 04.00.',
      dateTime: DateTime(now.year, now.month, now.day + 2, 4, 30),
      location: 'Titik Kumpul: Alfa Karawaci',
      creatorId: 'user_102',
      rsvps: {
        'user_101': 'joined',
        'user_102': 'joined',
        'user_103': 'joined',
        'user_104': 'maybe',
      },
      reminderSet: true,
    );
    final e2 = Event(
      id: 'event_102',
      communityId: commId,
      title: 'Workshop Editing Lightroom Dasar',
      description:
          'Praktek grading foto landscape dan portrait. Bawa laptop dengan Lightroom Classic terinstall.',
      dateTime: DateTime(now.year, now.month, now.day + 9, 9, 0),
      location: 'Kafe Kreativ, Blok M',
      creatorId: 'user_103',
      rsvps: {
        'user_101': 'maybe',
        'user_103': 'joined',
      },
      reminderSet: false,
    );
    _events[e1.id] = e1;
    _events[e2.id] = e2;

    _tasks['task_101'] = Task(
      id: 'task_101',
      eventId: 'event_101',
      title: 'Pinjam Tripod Cadangan',
      description: 'Bawa tripod cadangan + pemberat untuk 2 orang baru.',
      assigneeIds: ['user_101', 'user_104'],
      isCompleted: false,
    );
    _tasks['task_102'] = Task(
      id: 'task_102',
      eventId: 'event_102',
      title: 'Siapkan File Contoh Foto RAW',
      description: 'Kirim 5 file contoh RAW gratis untuk bahan praktek.',
      assigneeIds: ['user_104'],
      isCompleted: false,
    );

    _announcements['ann_101'] = Announcement(
      id: 'ann_101',
      communityId: commId,
      title: 'Calling Model untuk Photoshoot Tema Vintage',
      body:
          'Kita butuh 3-4 model sukarela untuk photoshoot komunal bulan depan di Kota Tua. Foto hasil dikelola komunitas dan bisa dipakai untuk portfolio. Daftar langsung di kolom komentar pengumuman.',
      authorId: 'user_102',
      authorName: 'Farhan Wijaya (Ketua)',
      createdAt: now.subtract(const Duration(hours: 5)),
      pinned: true,
      category: 'Penting',
    );
    _announcements['ann_102'] = Announcement(
      id: 'ann_102',
      communityId: commId,
      title: 'Tips Tambahan: White Balance Saat Golden Hour',
      body:
          'Buat pemula yang ikut hunting nanti, set white balance ke "Cloudy" supaya warna tetap hangat. Jangan gunakan auto WB di kondisi kontras.',
      authorId: 'user_103',
      authorName: 'Maya Anggraini (Sie Konten)',
      createdAt: now.subtract(const Duration(days: 1)),
      pinned: false,
      category: 'Umum',
    );
  }

  void _seedHikingCommunity(DateTime now) {
    const commId = 'comm_hike';

    final members = [
      const User(
        id: 'user_201',
        name: 'Caca Rahayu',
        avatarUrl: '',
        role: 'Anggota Aktif',
      ),
      const User(
        id: 'user_202',
        name: 'Ardi Nugraha',
        avatarUrl: '',
        role: 'Ketua Komunitas',
      ),
      const User(
        id: 'user_203',
        name: 'Bunga Puspita',
        avatarUrl: '',
        role: 'Sie Logistik',
      ),
      const User(
        id: 'user_204',
        name: 'Raka Wijaya',
        avatarUrl: '',
        role: 'Sie Medis & Evakuasi',
      ),
    ];
    for (final u in members) {
      _users[u.id] = u;
    }

    _communities[commId] = Community(
      id: commId,
      name: 'Pendaki Merapi Ceria',
      description:
          'Komunitas pecinta gunung. Rutin naik tiap bulan, selalu safety first dan zero waste.',
      category: 'Mendaki & Outdoor',
      adminId: 'user_202',
      logo: 'assets/logo1.1.png',
      members: members,
    );

    final e1 = Event(
      id: 'event_201',
      communityId: commId,
      title: 'Pendakian Gede Pangrango 2 Hari',
      description:
          'Rute Cibodas - Alun Alun. Bawa jaket gunung minimal 300 gr, headlamp, dan bivak. Fix cost transportasi 150rb/orang.',
      dateTime: DateTime(now.year, now.month, now.day + 5, 5, 0),
      location: 'Start: Gerbang Cibodas',
      creatorId: 'user_202',
      rsvps: {
        'user_201': 'joined',
        'user_202': 'joined',
        'user_203': 'joined',
        'user_204': 'joined',
      },
      reminderSet: true,
    );
    final e2 = Event(
      id: 'event_202',
      communityId: commId,
      title: 'Kopdar Pembagian Regu & Briefing',
      description:
          'Pembagian regu traking, telepon darurat, dan checklist barang bawaan. Wajib hadir untuk yang terdaftar naik.',
      dateTime: DateTime(now.year, now.month, now.day + 2, 19, 0),
      location: 'Warung Kopi Senja, Bogor',
      creatorId: 'user_203',
      rsvps: {
        'user_201': 'maybe',
        'user_202': 'joined',
      },
      reminderSet: false,
    );
    _events[e1.id] = e1;
    _events[e2.id] = e2;

    _tasks['task_201'] = Task(
      id: 'task_201',
      eventId: 'event_201',
      title: 'Cek Perlengkapan Tenda & Flysheet',
      description:
          'Pastikan 3 tenda dan flysheet kering, patch kebocoran bila ada.',
      assigneeIds: ['user_203', 'user_201'],
      isCompleted: false,
    );
    _tasks['task_202'] = Task(
      id: 'task_202',
      eventId: 'event_201',
      title: 'Siapkan P3K, Obat Mabuk Tiga & Salep',
      description: 'Lengkapi kotak P3K sesuai daftar standar BUMN Gunung.',
      assigneeIds: ['user_204'],
      isCompleted: false,
    );

    _announcements['ann_201'] = Announcement(
      id: 'ann_201',
      communityId: commId,
      title: 'Aturan Baru: Wajib Kantong Sampah Pribadi',
      body:
          'Demikian mulai bulan ini setiap pendaki WAJIB membawa kantong sampah pribadi. Bajwa pulang membawa sampahnya masing-masing. Pelanggaran akan dicatat dan dilarang ikut pendakian bulan berikutnya.',
      authorId: 'user_202',
      authorName: 'Ardi Nugraha (Ketua)',
      createdAt: now.subtract(const Duration(hours: 8)),
      pinned: true,
      category: 'Aturan',
    );
    _announcements['ann_202'] = Announcement(
      id: 'ann_202',
      communityId: commId,
      title: 'Transportasi: Sewa Elf Kapasitas 10 Orang',
      body:
          'Penawaran elf 10 seat dari Bogor ke Cibodas PP 1.2jt. Kalau full kuota naik, dapat turun jadi sekitar 120rb/orang. TF DP 40% ke bendahara sebelum H-3.',
      authorId: 'user_204',
      authorName: 'Raka Wijaya (Sie Medis & Evakuasi)',
      createdAt: now.subtract(const Duration(days: 1)),
      pinned: false,
      category: 'Keuangan',
    );
  }

  User get currentUser =>
      _users[currentUserId] ??
      const User(id: 'user_001', name: 'Dimas Aditya', role: 'Anggota Aktif');

  User? getUser(String id) => _users[id];

  List<User> getAllUsers() => _users.values.toList();

  List<User> getMembers(String communityId) =>
      _communities[communityId]?.members ?? const [];

  List<Community> getAllCommunities() =>
      _communities.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  void addCommunity(Community community) {
    _communities[community.id] = community;
    notifyListeners();
    _persist();
  }

  void addUserToCommunity(String communityId, User user) {
    final community = _communities[communityId];
    if (community == null) return;
    if (community.members.any((m) => m.id == user.id)) return;
    _users[user.id] = user;
    _communities[communityId] = Community(
      id: community.id,
      name: community.name,
      description: community.description,
      category: community.category,
      adminId: community.adminId,
      logo: community.logo,
      members: [...community.members, user],
    );
    notifyListeners();
    _persist();
  }

  void joinCommunity(String communityId) {
    addUserToCommunity(communityId, currentUser);
  }

  Event? getEventById(String eventId) => _events[eventId];

  Community? getCommunity(String id) => _communities[id];

  ({int saldo, int totalIn, int totalOut, int monthlyIuran, List<
      ({String title, String date, int nominal, bool isIncome})> entries})
      getTreasuryInfo(String communityId) {
    final community = getCommunity(communityId);
    final members = community?.members.length ?? 1;
    final seed = (communityId.hashCode % 1000).abs();

    final monthlyIuran = 25000 + (members * 10000) + (seed % 25000);
    final months = 2 + (seed % 3);
    final totalIn = (members * monthlyIuran * months) + ((seed % 7) * 50000);
    final totalOut = totalIn * (50 + (seed % 25)) ~/ 100;
    final saldo = totalIn - totalOut;

    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 5);
    final curMonth = DateTime(now.year, now.month, 2);

    String fmt(DateTime d) => '${d.day} ${_monthName(d.month)} ${d.year}';

    final entries = <({String title, String date, int nominal, bool isIncome})>[
      (
        title: 'Iuran Bulanan Anggota',
        date: fmt(curMonth),
        nominal: members * monthlyIuran,
        isIncome: true,
      ),
      (
        title: 'Sewa Transportasi',
        date: fmt(DateTime(now.year, now.month, 5)),
        nominal: totalOut ~/ 2,
        isIncome: false,
      ),
      (
        title: 'Perlengkapan Event',
        date: fmt(DateTime(now.year, now.month, 8)),
        nominal: (totalOut ~/ 2) + (seed % 50000),
        isIncome: false,
      ),
      (
        title: 'Donasi Kegiatan',
        date: fmt(DateTime(now.year, now.month, 12)),
        nominal: totalIn ~/ 3,
        isIncome: true,
      ),
      (
        title: 'Iuran Bulanan Anggota',
        date: fmt(prevMonth),
        nominal: members * monthlyIuran,
        isIncome: true,
      ),
    ];

    return (
      saldo: saldo,
      totalIn: totalIn,
      totalOut: totalOut,
      monthlyIuran: monthlyIuran,
      entries: entries,
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  List<Event> getEventsForCommunity(String communityId) {
    final list =
        _events.values.where((e) => e.communityId == communityId).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Event? getEvent(String id) => _events[id];

  List<Announcement> getAnnouncementsForCommunity(String communityId) {
    final list = _announcements.values
        .where((a) => a.communityId == communityId)
        .toList();

    list.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<Task> getTasksForEvent(String eventId) {
    final list = _tasks.values.where((t) => t.eventId == eventId).toList();

    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<Task> getAllTasksForCommunity(String communityId) {
    final communityEventIds =
        getEventsForCommunity(communityId).map((e) => e.id).toSet();
    final list = _tasks.values
        .where((t) =>
            t.communityId == communityId ||
            communityEventIds.contains(t.eventId))
        .toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<Task> getTasksForUser(String communityId, String userId) {
    final communityEventIds =
        getEventsForCommunity(communityId).map((e) => e.id).toSet();
    final list = _tasks.values
        .where((t) =>
            (t.communityId == communityId ||
                communityEventIds.contains(t.eventId)) &&
            t.assigneeIds.contains(userId))
        .toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<({Event event, String status})> getRSVPsForUser(
      String communityId, String userId) {
    final result = <({Event event, String status})>[];
    for (final event in getEventsForCommunity(communityId)) {
      final status = event.rsvps[userId];
      if (status != null) {
        result.add((event: event, status: status));
      }
    }
    return result;
  }

  void setRSVP(String eventId, String status) {
    final event = _events[eventId];
    if (event == null) return;

    final updatedRsvps = Map<String, String>.from(event.rsvps);
    if (updatedRsvps[currentUserId] == status) {
      updatedRsvps.remove(currentUserId);
    } else {
      updatedRsvps[currentUserId] = status;
    }

    _events[eventId] = event.copyWith(rsvps: updatedRsvps);
    notifyListeners();
    _persist();
  }

  void toggleEventReminder(String eventId, bool enabled) {
    final event = _events[eventId];
    if (event == null) return;
    _events[eventId] = event.copyWith(reminderSet: enabled);
    notifyListeners();
    _persist();
  }

  void addEvent(Event event) {
    _events[event.id] = event;
    notifyListeners();
    _persist();
  }

  void updateEvent(Event event) {
    _events[event.id] = event;
    notifyListeners();
    _persist();
  }

  void deleteEvent(String eventId) {
    _events.remove(eventId);
    _tasks.removeWhere((id, task) => task.eventId == eventId);
    notifyListeners();
    _persist();
  }

  void toggleTask(String taskId) {
    final task = _tasks[taskId];
    if (task == null) return;
    _tasks[taskId] = task.copyWith(isCompleted: !task.isCompleted);
    notifyListeners();
    _persist();
  }

  void addTask(Task task) {
    _tasks[task.id] = task;
    notifyListeners();
    _persist();
  }

  void deleteTask(String taskId) {
    _tasks.remove(taskId);
    notifyListeners();
    _persist();
  }

  void addAnnouncement(Announcement announcement) {
    _announcements[announcement.id] = announcement;
    notifyListeners();
    _persist();
  }

  void updateAnnouncement(Announcement announcement) {
    _announcements[announcement.id] = announcement;
    notifyListeners();
    _persist();
  }

  void deleteAnnouncement(String announcementId) {
    _announcements.remove(announcementId);
    notifyListeners();
    _persist();
  }

  void updateUser(User user) {
    _users[user.id] = user;

    for (final id in _communities.keys.toList()) {
      final c = _communities[id]!;
      if (c.members.any((m) => m.id == user.id)) {
        _communities[id] = Community(
          id: c.id,
          name: c.name,
          description: c.description,
          category: c.category,
          adminId: c.adminId,
          logo: c.logo,
          members: c.members.map((m) => m.id == user.id ? user : m).toList(),
        );
      }
    }

    notifyListeners();
    _persist();
  }

  void resetToSeedData() {
    _users.clear();
    _communities.clear();
    _events.clear();
    _announcements.clear();
    _tasks.clear();
    _loadInitialData();
    notifyListeners();
    _persist();
  }

  void togglePinAnnouncement(String announcementId) {
    final ann = _announcements[announcementId];
    if (ann == null) return;
    _announcements[announcementId] = ann.copyWith(pinned: !ann.pinned);
    notifyListeners();
    _persist();
  }
}

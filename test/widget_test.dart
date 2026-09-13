import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kumpul_in/main.dart';
import 'package:kumpul_in/models/models.dart';
import 'package:kumpul_in/screens/notification_screen.dart';
import 'package:kumpul_in/services/app_settings.dart';
import 'package:kumpul_in/services/data_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  final dataService = DataService();
  await dataService.init();
  final settings = AppSettings();
  await settings.init();
  await tester.pumpWidget(
    KumpulApp(dataService: dataService, settings: settings),
  );

  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lewati'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Lanjutkan dengan Google'));
  await tester.pumpAndSettle();
}

Future<void> _tapBottomNav(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('Beranda menampilkan sapaan, fitur, dan navigasi bawah',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.text('Hi, Justhan'), findsOneWidget);
    expect(find.text('Fitur Baraya'), findsOneWidget);
    expect(find.text('Diskusi'), findsOneWidget);

    for (final label in ['Beranda', 'Komunitas', 'Event', 'Kas', 'Profil']) {
      expect(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('Navigasi bawah menampilkan Kas, Profil, Komunitas, dan Event',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await _tapBottomNav(tester, 'Kas');
    expect(find.textContaining('Saldo Kas'), findsOneWidget);
    expect(find.text('Status Iuran Anggota'), findsOneWidget);

    await _tapBottomNav(tester, 'Profil');
    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);

    await _tapBottomNav(tester, 'Komunitas');
    expect(find.text('Pilih Komunitas'), findsOneWidget);
    expect(find.text('Komunitas Gowes Batavia'), findsWidgets);
    expect(find.text('Tambah Komunitas'), findsOneWidget);

    await _tapBottomNav(tester, 'Event');
    expect(find.text('Filter Event'), findsOneWidget);
    expect(find.text('Gowes Minggu Pagi ke Monas'), findsWidgets);
  });

  testWidgets('Event detail screen opens when tapping an event card',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await _tapBottomNav(tester, 'Event');
    await tester.tap(find.text('Gowes Minggu Pagi ke Monas').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Event'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Status Saya'), findsOneWidget);
    expect(find.textContaining('Peserta'), findsWidgets);

    await tester.scrollUntilVisible(
      find.textContaining('Tugas Panitia'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Tugas Panitia'), findsOneWidget);
  });
  testWidgets('Communities screen lists communities and opens its members',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();
    expect(find.text('Komunitas'), findsOneWidget);
    expect(find.text('Komunitas Foto Jakarta'), findsOneWidget);
    expect(find.text('Tambah Komunitas'), findsOneWidget);

    await tester.tap(find.text('Komunitas Foto Jakarta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Anggota'));
    await tester.pumpAndSettle();

    expect(find.text('Anggota Komunitas'), findsOneWidget);
    expect(find.text('Nina Kusuma'), findsOneWidget);
  });
  testWidgets('Theme toggle switches to dark mode',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mode Gelap'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });
  testWidgets('Members screen opens via community list and shows member stats',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Komunitas Gowes Batavia'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Anggota'));
    await tester.pumpAndSettle();

    expect(find.text('Anggota Komunitas'), findsOneWidget);
    expect(find.text('Dimas Aditya'), findsOneWidget);
    expect(find.text('Anda'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);

    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Status Event Mereka'), findsOneWidget);
  });

  testWidgets('About screen shows app settings and development info',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Penampilan'), findsOneWidget);
    expect(find.text('Mode Gelap'), findsOneWidget);
    expect(find.text('Mode Demo'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Baraya'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Baraya'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });

  testWidgets('User can add a new community', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Komunitas'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nama Komunitas'),
      'Komunitas Lari Pagi',
    );
    await tester.tap(find.text('Buat Komunitas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Komunitas Lari Pagi'), findsWidgets);
  });

  test('DataService persists and restores data across instances', () async {
    SharedPreferences.setMockInitialValues({});

    final first = DataService();
    await first.init();
    first.setRSVP('event_001', 'maybe');
    first.togglePinAnnouncement('ann_003');
    first.addEvent(Event(
      id: 'event_9',
      communityId: 'kumpul_001',
      title: 'Event Test Persistence',
      description: '',
      dateTime: DateTime.now().add(const Duration(days: 30)),
      creatorId: 'user_001',
      reminderSet: true,
    ));

    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < 20; i++) {
      if ((prefs.getString('kumpul_in_data_v2') ?? '').contains('event_9')) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    final restored = DataService();
    await restored.init();

    final restoredEvent = restored.getEvent('event_9');
    expect(restoredEvent, isNotNull);
    expect(restoredEvent!.title, 'Event Test Persistence');
    expect(restored.getEvent('event_001')!.rsvps['user_001'], 'maybe');
    expect(
        restored
            .getAnnouncementsForCommunity('kumpul_001')
            .firstWhere((a) => a.id == 'ann_003')
            .pinned,
        isTrue);
  });

  test('DataService reset restores seed data', () async {
    SharedPreferences.setMockInitialValues({});

    final ds = DataService();
    await ds.init();
    ds.addEvent(Event(
      id: 'event_x',
      communityId: 'kumpul_001',
      title: 'Event Shenanigans',
      description: '',
      dateTime: DateTime.now().add(const Duration(days: 10)),
      creatorId: 'user_001',
      reminderSet: false,
    ));
    expect(ds.getEvent('event_x'), isNotNull);

    ds.resetToSeedData();

    expect(ds.getEvent('event_x'), isNull);
    expect(ds.getAllCommunities().length, 3);
    expect(ds.getEventsForCommunity('kumpul_001').length, 3);
  });

  testWidgets('Search filters events by title', (WidgetTester tester) async {
    await _pumpApp(tester);

    await _tapBottomNav(tester, 'Event');
    await tester.enterText(find.byType(TextField), 'Monas');
    await tester.pumpAndSettle();

    expect(find.text('1 event ditemukan'), findsOneWidget);
    expect(find.text('Gowes Minggu Pagi ke Monas'), findsWidgets);
    expect(find.text('Kopdar & Workshop Servis Mandiri'), findsNothing);
  });

  testWidgets('Profile screen opens from app bar avatar',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Dimas Aditya'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Komunitas Saya'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Komunitas Saya'), findsOneWidget);
  });

  testWidgets('Notifikasi menampilkan pengumuman dan detailnya',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.textContaining('Info penting & pengumuman'), findsOneWidget);
    expect(find.textContaining('Info Pengalihan Rute CFD'), findsWidgets);

    await tester.tap(find.textContaining('Info Pengalihan Rute CFD'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Diberitahukan kepada seluruh anggota'),
        findsWidgets);
  });

  testWidgets('Notifikasi dapat menyematkan pengumuman',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    final ds = Provider.of<DataService>(
      tester.element(find.byType(NotificationScreen)),
      listen: false,
    );
    expect(
        ds.getAnnouncementsForCommunity('kumpul_001')
            .where((a) => a.pinned)
            .length,
        2);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final pinCard = find.ancestor(
      of: find.textContaining('Aturan & Etika Gowes Bareng'),
      matching: find.byType(Card),
    );
    await tester.ensureVisible(pinCard.first);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: pinCard.first,
      matching: find.byIcon(Icons.push_pin_outlined),
    ));
    await tester.pumpAndSettle();

    expect(
        ds.getAnnouncementsForCommunity('kumpul_001')
            .where((a) => a.pinned)
            .length,
        3);
  });
}

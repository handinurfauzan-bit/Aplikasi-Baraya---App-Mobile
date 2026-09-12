import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kumpul_in/main.dart';
import 'package:kumpul_in/models/models.dart';
import 'package:kumpul_in/services/app_settings.dart';
import 'package:kumpul_in/services/data_service.dart';
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('Baraya loads and displays community header and tabs', (WidgetTester tester) async {
    await _pumpApp(tester);


    expect(find.text('Komunitas Gowes Batavia'), findsOneWidget);

    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Pengumuman'), findsOneWidget);
    expect(find.text('Tugas'), findsOneWidget);

    expect(find.text('Gowes Minggu Pagi ke Monas'), findsWidgets);

    expect(find.text('Ikut'), findsWidgets);
  });

  testWidgets('Switching tabs displays Announcements and Tasks', (WidgetTester tester) async {
    await _pumpApp(tester);


    await tester.tap(find.text('Pengumuman'));
    await tester.pumpAndSettle();


    expect(find.textContaining('Info Pengalihan Rute CFD'), findsOneWidget);
    expect(find.text('PINNED'), findsWidgets);


    await tester.tap(find.text('Tugas'));
    await tester.pumpAndSettle();


    expect(find.text('Progress Tugas Panitia'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Siapkan Pisang & Air Mineral'), findsOneWidget);
  });

  testWidgets('Event detail screen opens when tapping an event card', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Gowes Minggu Pagi ke Monas').first);
    await tester.pumpAndSettle();


    expect(find.text('Detail Event'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Status Saya'), findsOneWidget);
    expect(find.textContaining('Peserta'), findsOneWidget);


    await tester.scrollUntilVisible(
      find.textContaining('Tugas Panitia'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Tugas Panitia'), findsOneWidget);
  });

  testWidgets('Community switcher changes displayed data', (WidgetTester tester) async {
    await _pumpApp(tester);


    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Komunitas'), findsOneWidget);


    await tester.tap(find.text('Komunitas Foto Jakarta'));
    await tester.pumpAndSettle();

    expect(find.text('Komunitas Foto Jakarta'), findsOneWidget);
    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Hunting Sunrise Pantai Indah'), findsWidgets);
  });

  testWidgets('Theme toggle switches to dark mode', (WidgetTester tester) async {
    await _pumpApp(tester);


    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();


    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);


    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('Members screen shows members and their stats', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    expect(find.text('Anggota Komunitas'), findsOneWidget);
    expect(find.text('Dimas Aditya'), findsOneWidget);
    expect(find.text('Anda'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);


    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Status Event Mereka'), findsOneWidget);
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
      if ((prefs.getString('kumpul_in_data_v1') ?? '').contains('event_9')) {
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
    expect(restored.getAnnouncementsForCommunity('kumpul_001')
        .firstWhere((a) => a.id == 'ann_003').pinned, isTrue);
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

    await tester.enterText(find.byType(TextField), 'Monas');
    await tester.pumpAndSettle();

    expect(find.text('1 event ditemukan'), findsOneWidget);
    expect(find.text('Gowes Minggu Pagi ke Monas'), findsWidgets);
    expect(find.text('Kopdar & Workshop Servis Mandiri'), findsNothing);
  });

  testWidgets('Profile screen opens from app bar avatar', (WidgetTester tester) async {
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

  testWidgets('Announcement edit updates content', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Pengumuman'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Jersey Resmi Batavia'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.textContaining('Jersey Resmi Batavia'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Jersey Resmi Batavia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit Pengumuman'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Jersey Resmi Batavia 2026 Sudah Siap Dipesan'),
      'Jersey Edisi Demo 2026',
    );
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jersey Edisi Demo 2026'), findsWidgets);
  });

  testWidgets('Announcement delete removes it', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Pengumuman'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Aturan & Etika Gowes Bareng'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.textContaining('Aturan & Etika Gowes Bareng'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Aturan & Etika Gowes Bareng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Aturan & Etika Gowes Bareng (Wajib Dibaca)'), findsNothing);
  });
}

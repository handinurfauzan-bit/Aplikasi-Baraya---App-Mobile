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

  // Let the splash timer fire and navigate to HomeScreen
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('KumpulApp loads and displays community header and tabs', (WidgetTester tester) async {
    await _pumpApp(tester);

    // Verify community name is displayed
    expect(find.text('Komunitas Gowes Batavia'), findsOneWidget);

    // Verify tabs exist
    expect(find.text('Event (3)'), findsOneWidget);
    expect(find.text('Pengumuman (3)'), findsOneWidget);
    expect(find.text('Tugas (6)'), findsOneWidget);

    // Verify default event is visible
    expect(find.text('Gowes Minggu Pagi ke Monas'), findsWidgets);

    // Verify RSVP button exists
    expect(find.text('Ikut'), findsWidgets);
  });

  testWidgets('Switching tabs displays Announcements and Tasks', (WidgetTester tester) async {
    await _pumpApp(tester);

    // Tap on Pengumuman Tab
    await tester.tap(find.text('Pengumuman (3)'));
    await tester.pumpAndSettle();

    // Verify announcement title (using textContaining so emoji variation won't cause failure)
    expect(find.textContaining('Info Pengalihan Rute CFD'), findsOneWidget);
    expect(find.text('PINNED'), findsWidgets);

    // Tap on Tugas Tab
    await tester.tap(find.text('Tugas (6)'));
    await tester.pumpAndSettle();

    // Verify progress card and task items
    expect(find.text('Progress Tugas Panitia'), findsOneWidget);
    expect(find.text('Siapkan Pisang & Air Mineral'), findsOneWidget);
  });

  testWidgets('Event detail screen opens when tapping an event card', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Gowes Minggu Pagi ke Monas').first);
    await tester.pumpAndSettle();

    // Detail screen shows header, RSVP options, and attendees
    expect(find.text('Detail Event'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Status Saya'), findsOneWidget);
    expect(find.textContaining('Peserta'), findsOneWidget);

    // Scroll down to the tasks section
    await tester.scrollUntilVisible(
      find.textContaining('Tugas Panitia'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Tugas Panitia'), findsOneWidget);
  });

  testWidgets('Community switcher changes displayed data', (WidgetTester tester) async {
    await _pumpApp(tester);

    // Open community switcher
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Komunitas'), findsOneWidget);

    // Switch to the photography community
    await tester.tap(find.text('Komunitas Foto Jakarta'));
    await tester.pumpAndSettle();

    expect(find.text('Komunitas Foto Jakarta'), findsOneWidget);
    expect(find.text('Event (2)'), findsOneWidget);
    expect(find.text('Pengumuman (2)'), findsOneWidget);
    expect(find.text('Hunting Sunrise Pantai Indah'), findsWidgets);
  });

  testWidgets('Theme toggle switches to dark mode', (WidgetTester tester) async {
    await _pumpApp(tester);

    // Initially in light mode, moon icon is shown
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    // After switching to dark mode, the sun icon appears
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

    // Verify MaterialApp is actually in dark brightness
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('Members screen shows members and their stats', (WidgetTester tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    expect(find.text('Anggota Komunitas'), findsOneWidget);
    expect(find.text('Dimas Aditya (Anda)'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);

    // Open a member detail
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

    // Wait until the async persist has flushed to storage
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
    expect(restored.getEvent('event_001')!.rsvps['user_001'], 'maybe'); // RSVP persisted
    expect(restored.getAnnouncementsForCommunity('kumpul_001')
        .firstWhere((a) => a.id == 'ann_003').pinned, isTrue);
  });
}